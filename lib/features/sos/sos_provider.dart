import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/config/app_environment.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/core/network/auth_interceptor.dart';
import 'package:suraksha_women_safety_app/core/network/auth_token_storage.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_actions_service.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_sms_service.dart';

/// Only recreate the SOS notifier when the signed-in user changes.
/// Watching the full auth state used to dispose an active SOS on profile updates.
final sosProvider = StateNotifierProvider<SOSNotifier, SOSState>((ref) {
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  return SOSNotifier(ref, userId);
});

enum SosDeliveryStatus {
  idle,
  sending,
  sent,
  partial,
  failed,
  unavailable,
}

class SOSState {
  final bool isActive;
  final Position? currentPosition;
  final String? error;
  final bool isStreaming;
  final DateTime? lastLocationUpdate;
  final String? sosEventId;
  final String? trackingUrl;
  final SosDeliveryStatus serverDelivery;
  final SosDeliveryStatus smsDelivery;
  final SosDeliveryStatus safeSmsDelivery;
  final bool socketConnected;
  final bool isRecovered;
  final int smsSentCount;
  final int smsTotalCount;

  SOSState({
    this.isActive = false,
    this.currentPosition,
    this.error,
    this.isStreaming = false,
    this.lastLocationUpdate,
    this.sosEventId,
    this.trackingUrl,
    this.serverDelivery = SosDeliveryStatus.idle,
    this.smsDelivery = SosDeliveryStatus.idle,
    this.safeSmsDelivery = SosDeliveryStatus.idle,
    this.socketConnected = false,
    this.isRecovered = false,
    this.smsSentCount = 0,
    this.smsTotalCount = 0,
  });

  SOSState copyWith({
    bool? isActive,
    Position? currentPosition,
    String? error,
    bool? isStreaming,
    DateTime? lastLocationUpdate,
    String? sosEventId,
    bool clearSosEventId = false,
    String? trackingUrl,
    bool clearTrackingUrl = false,
    SosDeliveryStatus? serverDelivery,
    SosDeliveryStatus? smsDelivery,
    SosDeliveryStatus? safeSmsDelivery,
    bool? socketConnected,
    bool? isRecovered,
    int? smsSentCount,
    int? smsTotalCount,
  }) {
    return SOSState(
      isActive: isActive ?? this.isActive,
      currentPosition: currentPosition ?? this.currentPosition,
      error: error,
      isStreaming: isStreaming ?? this.isStreaming,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      sosEventId: clearSosEventId ? null : (sosEventId ?? this.sosEventId),
      trackingUrl: clearTrackingUrl ? null : (trackingUrl ?? this.trackingUrl),
      serverDelivery: serverDelivery ?? this.serverDelivery,
      smsDelivery: smsDelivery ?? this.smsDelivery,
      safeSmsDelivery: safeSmsDelivery ?? this.safeSmsDelivery,
      socketConnected: socketConnected ?? this.socketConnected,
      isRecovered: isRecovered ?? this.isRecovered,
      smsSentCount: smsSentCount ?? this.smsSentCount,
      smsTotalCount: smsTotalCount ?? this.smsTotalCount,
    );
  }
}

class SOSNotifier extends StateNotifier<SOSState> {
  static const _snapshotActive = 'sos_snapshot_active_v2';
  static const _snapshotEventId = 'sos_snapshot_event_id_v2';
  static const _snapshotTrackingUrl = 'sos_snapshot_tracking_url_v2';
  socket_io.Socket? _socket;
  final Ref? _ref;
  final String? _userId;
  StreamSubscription<Position>? _positionSubscription;
  final _dioClient = DioClient();
  final _smsService = SOSSmsService();
  final _actions = SosActionsService();
  static const _secure = FlutterSecureStorage();

  SOSNotifier(this._ref, this._userId) : super(SOSState()) {
    if (_userId != null && _userId.isNotEmpty) {
      AuthInterceptor.onTokensRefreshed = () {
        unawaited(refreshSocketAuth());
      };
      unawaited(_initialize());
    }
  }

  SOSNotifier.test({String? userId})
    : _ref = null,
      _userId = userId,
      super(SOSState());

  String _snapshotKey(String base) => '${base}_${_userId ?? 'anonymous'}';

  Future<void> _initialize() async {
    await _restoreSnapshot();
    await _initSocket();
    await restoreActiveSOS();
  }

  Future<void> _persistSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_snapshotKey(_snapshotActive), state.isActive);
      final eventId = state.sosEventId;
      final trackingUrl = state.trackingUrl;
      if (eventId == null) {
        await prefs.remove(_snapshotKey(_snapshotEventId));
      } else {
        await prefs.setString(_snapshotKey(_snapshotEventId), eventId);
      }
      // Live SOS URLs are capability tokens — keep them out of SharedPreferences.
      final trackingKey = _snapshotKey(_snapshotTrackingUrl);
      await prefs.remove(trackingKey);
      if (trackingUrl == null || trackingUrl.isEmpty) {
        await _secure.delete(key: trackingKey);
      } else {
        await _secure.write(key: trackingKey, value: trackingUrl);
      }
    } catch (_) {
      // Persistence is recovery support; it must never block an SOS action.
    }
  }

  Future<void> _clearSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackingKey = _snapshotKey(_snapshotTrackingUrl);
      await Future.wait([
        prefs.remove(_snapshotKey(_snapshotActive)),
        prefs.remove(_snapshotKey(_snapshotEventId)),
        prefs.remove(trackingKey),
        _secure.delete(key: trackingKey),
      ]);
    } catch (_) {
      // Keep cancellation reliable when local storage is unavailable.
    }
  }

  Future<void> _restoreSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_snapshotKey(_snapshotActive)) != true) return;
    final trackingKey = _snapshotKey(_snapshotTrackingUrl);
    var trackingUrl = await _secure.read(key: trackingKey);
    // One-time migrate any leftover plaintext URL out of prefs.
    if (trackingUrl == null || trackingUrl.isEmpty) {
      trackingUrl = prefs.getString(trackingKey);
      if (trackingUrl != null && trackingUrl.isNotEmpty) {
        await _secure.write(key: trackingKey, value: trackingUrl);
      }
      await prefs.remove(trackingKey);
    }
    state = state.copyWith(
      isActive: true,
      isStreaming: true,
      sosEventId: prefs.getString(_snapshotKey(_snapshotEventId)),
      trackingUrl: trackingUrl,
      isRecovered: true,
      serverDelivery: SosDeliveryStatus.sending,
    );
  }

  Future<String?> _readAccessToken() async {
    return AuthTokenStorage.storage.read(key: AuthTokenStorage.tokenKey);
  }

  Future<void> _initSocket() async {
    final token = await _readAccessToken();
    if (token == null || token.isEmpty) return;

    _socket?.dispose();
    _socket = socket_io.io(
      ApiConstants.socketUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      state = state.copyWith(socketConnected: true);
      final activeSosId = state.sosEventId;
      if (activeSosId != null && activeSosId.isNotEmpty) {
        _socket!.emit('join_sos', {'sosEventId': activeSosId});
        final position = state.currentPosition;
        if (state.isActive && position != null) {
          _socket!.emit('update_location', {
            'lat': position.latitude,
            'lng': position.longitude,
            'sosEventId': activeSosId,
          });
        }
      } else {
        _socket!.emit('join_sos');
      }
    });

    _socket!.onConnectError((error) {
      developer.log(
        'SOS socket connect error',
        name: 'SOSNotifier',
        error: error,
      );
      state = state.copyWith(
        socketConnected: false,
        error: l10nSync('sosRealtimeConnectionFailed'),
      );
    });
    _socket!.onDisconnect((_) {
      state = state.copyWith(socketConnected: false);
    });

    _socket!.connect();
  }

  /// Re-auth the SOS socket after HTTP access-token refresh.
  Future<void> refreshSocketAuth() async {
    if (_userId == null || _userId.isEmpty) return;
    try {
      await _initSocket();
    } catch (error, stack) {
      developer.log(
        'SOS socket auth refresh failed',
        name: 'SOSNotifier',
        error: error,
        stackTrace: stack,
      );
    }
  }

  void _joinSosRoom(String? sosEventId) {
    if (_socket == null || !_socket!.connected) return;
    if (sosEventId == null || sosEventId.isEmpty) {
      _socket!.emit('join_sos');
      return;
    }
    _socket!.emit('join_sos', {'sosEventId': sosEventId});
  }

  Future<void> restoreActiveSOS() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.activeSOS);
      final raw = response.data;
      if (raw is! List) return;
      Map<String, dynamic>? active;
      for (final item in raw) {
        if (item is Map<String, dynamic> && item['status'] == 'active') {
          active = item;
          break;
        }
      }
      if (active == null) {
        if (state.isRecovered) {
          state = SOSState();
          await _clearSnapshot();
        }
        return;
      }

      final eventId = (active['_id'] ?? active['id'])?.toString();
      final shareToken = active['shareToken']?.toString();
      final trackingUrl = _actions.sanitizeTrackingUrl(
        shareToken == null
            ? state.trackingUrl
            : '${AppEnvironment.socketBaseUrl.replaceAll(RegExp(r'/$'), '')}/live-sos/$shareToken',
      );
      state = state.copyWith(
        isActive: true,
        isStreaming: true,
        sosEventId: eventId,
        trackingUrl: trackingUrl,
        serverDelivery: SosDeliveryStatus.sent,
        isRecovered: true,
        error: null,
      );
      _joinSosRoom(eventId);
      _startLiveTracking();
      await _persistSnapshot();
    } catch (error, stack) {
      developer.log(
        'Active SOS recovery failed',
        name: 'SOSNotifier',
        error: error,
        stackTrace: stack,
      );
      if (state.isActive) {
        state = state.copyWith(
          serverDelivery: SosDeliveryStatus.failed,
          error: l10nSync('sosRealtimeConnectionFailed'),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _createSosWithRetry(Position position) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _dioClient.dio.post(
          ApiConstants.createSOS,
          data: {
            'lat': position.latitude,
            'lng': position.longitude,
            'mode': 'normal',
          },
        );
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        throw StateError('Invalid SOS response');
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future<void>.delayed(Duration(milliseconds: 400 << attempt));
        }
      }
    }
    throw lastError ?? StateError('SOS create failed');
  }

  Future<void> triggerSOS({Position? fallbackPosition}) async {
    if (state.isActive) return;

    await _ref?.read(emergencyContactsProvider.notifier).loadContacts();
    final contacts = _ref?.read(emergencyContactsProvider) ?? const <EmergencyContact>[];
    if (contacts.isEmpty) {
      state = state.copyWith(
        error: l10nSync('saveEmergencyContactFirstMessage'),
        serverDelivery: SosDeliveryStatus.unavailable,
        smsDelivery: SosDeliveryStatus.unavailable,
      );
      unawaited(AppActivityLog.instance.record(
        'sos_blocked_no_contacts',
        message: 'SOS blocked — no emergency contacts saved',
      ));
      return;
    }

    unawaited(AppActivityLog.instance.record(
      'sos_triggered',
      message:
          'SOS triggered — ${contacts.length} emergency contact${contacts.length == 1 ? '' : 's'} on file',
      details: {'contacts': '${contacts.length}'},
    ));

    state = state.copyWith(
      isActive: true,
      isStreaming: true,
      error: null,
      serverDelivery: SosDeliveryStatus.sending,
      smsDelivery: SosDeliveryStatus.sending,
      safeSmsDelivery: SosDeliveryStatus.idle,
      isRecovered: false,
    );
    await _persistSnapshot();

    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      state = state.copyWith(currentPosition: lastKnownPosition);
    }

    Position? position;
    try {
      position = await _actions.resolveSosPosition(
        fallback: fallbackPosition ?? lastKnownPosition,
      );
    } catch (_) {
      position = fallbackPosition ?? lastKnownPosition;
    }
    if (position != null) {
      state = state.copyWith(currentPosition: position);
    }

    String? sosEventId;
    String? trackingUrl;
    if (position != null) {
      try {
        final data = await _createSosWithRetry(position);
        sosEventId = (data?['_id'] ?? data?['id'])?.toString();
        final shareToken = data?['shareToken']?.toString();
        final responseTrackingUrl = data?['trackingUrl']?.toString();
        trackingUrl = _actions.sanitizeTrackingUrl(
          responseTrackingUrl ??
              (shareToken == null
                  ? null
                  : '${AppEnvironment.socketBaseUrl.replaceAll(RegExp(r'/$'), '')}/live-sos/$shareToken'),
        );
        state = state.copyWith(
          sosEventId: sosEventId,
          trackingUrl: trackingUrl,
          serverDelivery: SosDeliveryStatus.sent,
        );
        _joinSosRoom(sosEventId);
      } catch (error, stack) {
        developer.log(
          'SOS REST create failed after retries',
          name: 'SOSNotifier',
          error: error,
          stackTrace: stack,
        );
        state = state.copyWith(
          serverDelivery: SosDeliveryStatus.failed,
          error: l10nSync('sosRealtimeConnectionFailed'),
        );
      }
    } else {
      state = state.copyWith(
        serverDelivery: SosDeliveryStatus.unavailable,
        error: l10nSync('nearbyGpsUnavailable'),
      );
    }

    if (_socket != null && _socket!.connected && position != null) {
      _socket!.emit('trigger_sos', {
        'lat': position.latitude,
        'lng': position.longitude,
        'sosEventId': sosEventId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    await _sendEmergencySms(position, trackingUrl: trackingUrl);
    if (position != null) _startLiveTracking();
    await _persistSnapshot();
  }

  Future<void> _sendEmergencySms(
    Position? position, {
    String? trackingUrl,
  }) async {
    if (!FeatureFlags.sosAutoSms) {
      state = state.copyWith(
        smsDelivery: SosDeliveryStatus.unavailable,
        smsSentCount: 0,
        smsTotalCount: 0,
      );
      return;
    }
    try {
      final result = await _actions.sendEmergencySmsIfEnabled(
        position: position,
        contacts: await _emergencyContactsForSms(),
        trackingUrl: trackingUrl,
        senderName: _currentUserName(),
      );
      final delivery = result.allSent
          ? SosDeliveryStatus.sent
          : result.anySent
          ? SosDeliveryStatus.partial
          : result.total == 0
          ? SosDeliveryStatus.unavailable
          : SosDeliveryStatus.failed;
      state = state.copyWith(
        smsDelivery: delivery,
        smsSentCount: result.sentCount,
        smsTotalCount: result.total,
      );
      unawaited(AppActivityLog.instance.record(
        'sos_sms_sent',
        message:
            'SOS messages sent to ${result.sentCount} of ${result.total} emergency contacts',
        details: {
          'sent': '${result.sentCount}',
          'total': '${result.total}',
        },
      ));
      if (!result.anySent && FeatureFlags.sosAutoSms) {
        state = state.copyWith(
          error: l10nSync('sosActivatedSmsPermissionNeeded'),
        );
      }
    } catch (_) {
      state = state.copyWith(
        smsDelivery: SosDeliveryStatus.failed,
        error: l10nSync('sosActivatedSmsPermissionNeeded'),
      );
    }
  }

  Future<bool> _cancelSosOnServer(String? sosEventId) async {
    if (sosEventId == null || sosEventId.isEmpty) return false;

    try {
      await _dioClient.dio.post(
        ApiConstants.cancelSOS,
        data: {'sosEventId': sosEventId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> sendSafeSms() async {
    final currentPosition = state.currentPosition;
    try {
      state = state.copyWith(safeSmsDelivery: SosDeliveryStatus.sending);
      final result = await _smsService.sendSafeSms(
        await _emergencyContactsForSms(),
        senderName: _currentUserName(),
        position: currentPosition,
      );
      state = state.copyWith(
        safeSmsDelivery: result.allSent
            ? SosDeliveryStatus.sent
            : result.anySent
            ? SosDeliveryStatus.partial
            : result.total == 0
            ? SosDeliveryStatus.unavailable
            : SosDeliveryStatus.failed,
      );
      if (!result.anySent) {
        state = state.copyWith(
          error: l10nSync('sosActivatedSmsPermissionNeeded'),
        );
      }
    } catch (_) {
      state = state.copyWith(
        safeSmsDelivery: SosDeliveryStatus.failed,
        error: l10nSync('sosActivatedSmsPermissionNeeded'),
      );
    }
  }

  Future<bool> openSmsFallback({bool safe = false}) async {
    final result = await _smsService.openEmergencyComposer(
      contacts: await _emergencyContactsForSms(),
      position: state.currentPosition,
      trackingUrl: _actions.sanitizeTrackingUrl(state.trackingUrl),
      senderName: _currentUserName(),
      safe: safe,
    );
    return result.composerOpened;
  }

  Future<void> retryFailedDelivery() async {
    if (!state.isActive) return;
    final position = state.currentPosition;
    if (state.serverDelivery != SosDeliveryStatus.sent && position != null) {
      state = state.copyWith(serverDelivery: SosDeliveryStatus.sending);
      try {
        final data = await _createSosWithRetry(position);
        final eventId = (data?['_id'] ?? data?['id'])?.toString();
        final shareToken = data?['shareToken']?.toString();
        final trackingUrl = _actions.sanitizeTrackingUrl(
          data?['trackingUrl']?.toString() ??
              (shareToken == null
                  ? null
                  : '${AppEnvironment.socketBaseUrl.replaceAll(RegExp(r'/$'), '')}/live-sos/$shareToken'),
        );
        state = state.copyWith(
          sosEventId: eventId,
          trackingUrl: trackingUrl,
          serverDelivery: SosDeliveryStatus.sent,
          error: null,
        );
        _joinSosRoom(eventId);
      } catch (_) {
        state = state.copyWith(
          serverDelivery: SosDeliveryStatus.failed,
          error: l10nSync('sosRealtimeConnectionFailed'),
        );
      }
    }
    if (state.smsDelivery != SosDeliveryStatus.sent) {
      state = state.copyWith(smsDelivery: SosDeliveryStatus.sending);
      await _sendEmergencySms(
        state.currentPosition,
        trackingUrl: state.trackingUrl,
      );
    }
    await _persistSnapshot();
  }

  String? _currentUserName() {
    final ref = _ref;
    if (ref == null) return null;
    return ref.read(authProvider).user?.name;
  }

  Future<List<EmergencyContact>> _emergencyContactsForSms() async {
    final ref = _ref;
    if (ref == null) return const [];

    await ref.read(emergencyContactsProvider.notifier).loadContacts();
    return ref.read(emergencyContactsProvider);
  }

  void _startLiveTracking() {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (state.isActive) {
            state = state.copyWith(
              currentPosition: position,
              lastLocationUpdate: DateTime.now(),
            );
            if (_socket != null && _socket!.connected) {
              _socket!.emit('update_location', {
                'lat': position.latitude,
                'lng': position.longitude,
                'sosEventId': state.sosEventId,
              });
            }
            unawaited(
              _dioClient.dio
                  .post(
                    ApiConstants.updateLocation,
                    data: {
                      'lat': position.latitude,
                      'lng': position.longitude,
                      if (state.sosEventId != null)
                        'sosEventId': state.sosEventId,
                      'accuracy': position.accuracy,
                      'heading': position.heading,
                      'speed': position.speed,
                    },
                  )
                  .then(
                    (_) {},
                    onError: (Object error, StackTrace stack) {
                      developer.log(
                        'SOS location POST failed',
                        name: 'SOSNotifier',
                        error: error,
                        stackTrace: stack,
                      );
                    },
                  ),
            );
          }
        });
  }

  Future<void> cancelSOS() async {
      unawaited(AppActivityLog.instance.record('sos_cancelled', message: 'SOS cancelled'));
    final currentEventId = state.sosEventId;
    final currentPosition = state.currentPosition;

    state = state.copyWith(
      isActive: false,
      isStreaming: false,
      clearSosEventId: true,
      clearTrackingUrl: true,
    );
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    final cancelPersisted = await _cancelSosOnServer(currentEventId);

    await sendSafeSms();

    final cancelPayload = <String, dynamic>{};
    if (currentEventId != null) {
      cancelPayload['sosEventId'] = currentEventId;
    }
    if (cancelPersisted) {
      cancelPayload['skipPersistence'] = true;
    }

    _socket?.emit('cancel_sos', cancelPayload);
    if (currentEventId != null && currentEventId.isNotEmpty) {
      _socket?.emit('leave_sos', {'sosEventId': currentEventId});
    }

    state = state.copyWith(currentPosition: currentPosition);
    await _clearSnapshot();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _socket?.dispose();
    super.dispose();
  }
}
