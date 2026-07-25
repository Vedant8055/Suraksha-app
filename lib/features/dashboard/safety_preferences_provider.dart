import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';

class SafetyPreferencesState {
  final bool journeyAlertsEnabled;
  final bool sosAlertsEnabled;
  final bool routeWarningsEnabled;
  final bool communityAlertsEnabled;
  final bool safetyRemindersEnabled;
  final bool notificationOnboardingDone;
  final bool loading;
  final String? error;

  const SafetyPreferencesState({
    this.journeyAlertsEnabled = true,
    this.sosAlertsEnabled = true,
    this.routeWarningsEnabled = true,
    this.communityAlertsEnabled = true,
    this.safetyRemindersEnabled = true,
    this.notificationOnboardingDone = false,
    this.loading = false,
    this.error,
  });

  SafetyPreferencesState copyWith({
    bool? journeyAlertsEnabled,
    bool? sosAlertsEnabled,
    bool? routeWarningsEnabled,
    bool? communityAlertsEnabled,
    bool? safetyRemindersEnabled,
    bool? notificationOnboardingDone,
    bool? loading,
    String? error,
  }) {
    return SafetyPreferencesState(
      journeyAlertsEnabled: journeyAlertsEnabled ?? this.journeyAlertsEnabled,
      sosAlertsEnabled: sosAlertsEnabled ?? this.sosAlertsEnabled,
      routeWarningsEnabled: routeWarningsEnabled ?? this.routeWarningsEnabled,
      communityAlertsEnabled:
          communityAlertsEnabled ?? this.communityAlertsEnabled,
      safetyRemindersEnabled:
          safetyRemindersEnabled ?? this.safetyRemindersEnabled,
      notificationOnboardingDone:
          notificationOnboardingDone ?? this.notificationOnboardingDone,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final safetyPreferencesProvider =
    StateNotifierProvider<SafetyPreferencesNotifier, SafetyPreferencesState>(
      (ref) => SafetyPreferencesNotifier(),
    );

class SafetyPreferencesNotifier extends StateNotifier<SafetyPreferencesState> {
  SafetyPreferencesNotifier() : super(const SafetyPreferencesState()) {
    _loadLocal();
  }

  static const _journeyKey = 'safety_journey_alerts_enabled_v1';
  static const _sosKey = 'notif_sos_alerts_enabled_v1';
  static const _routeKey = 'notif_route_warnings_enabled_v1';
  static const _communityKey = 'notif_community_alerts_enabled_v1';
  static const _reminderKey = 'notif_safety_reminders_enabled_v1';
  static const _onboardingKey = 'notif_onboarding_done_v1';

  final _dio = DioClient().dio;

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      journeyAlertsEnabled: prefs.getBool(_journeyKey) ?? true,
      sosAlertsEnabled: prefs.getBool(_sosKey) ?? true,
      routeWarningsEnabled: prefs.getBool(_routeKey) ?? true,
      communityAlertsEnabled: prefs.getBool(_communityKey) ?? true,
      safetyRemindersEnabled: prefs.getBool(_reminderKey) ?? true,
      notificationOnboardingDone: prefs.getBool(_onboardingKey) ?? false,
    );
    await _syncFromServer();
  }

  Future<void> _syncFromServer() async {
    try {
      final response = await _dio.get(ApiConstants.safetyIntelligencePreferences);
      final data = response.data;
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final prefs = await SharedPreferences.getInstance();

      Future<void> applyBool(String apiKey, String localKey, void Function(bool) set) async {
        if (!map.containsKey(apiKey)) return;
        final value = map[apiKey] == true;
        set(value);
        await prefs.setBool(localKey, value);
      }

      var next = state;
      await applyBool('journeyAlertsEnabled', _journeyKey, (v) {
        next = next.copyWith(journeyAlertsEnabled: v);
      });
      await applyBool('sosAlertsEnabled', _sosKey, (v) {
        next = next.copyWith(sosAlertsEnabled: v);
      });
      await applyBool('routeWarningsEnabled', _routeKey, (v) {
        next = next.copyWith(routeWarningsEnabled: v);
      });
      await applyBool('communityAlertsEnabled', _communityKey, (v) {
        next = next.copyWith(communityAlertsEnabled: v);
      });
      await applyBool('safetyRemindersEnabled', _reminderKey, (v) {
        next = next.copyWith(safetyRemindersEnabled: v);
      });
      state = next.copyWith(error: null);
    } catch (_) {}
  }

  Future<void> _persistAndSync({
    required String localKey,
    required String apiKey,
    required bool enabled,
    required SafetyPreferencesState Function(bool) apply,
  }) async {
    state = apply(enabled).copyWith(loading: true, error: null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(localKey, enabled);
    try {
      await _dio.patch(
        ApiConstants.safetyIntelligencePreferences,
        data: {apiKey: enabled},
      );
      state = state.copyWith(loading: false);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Saved locally. Sign in to sync across devices.',
      );
    }
  }

  Future<void> setJourneyAlertsEnabled(bool enabled) => _persistAndSync(
        localKey: _journeyKey,
        apiKey: 'journeyAlertsEnabled',
        enabled: enabled,
        apply: (v) => state.copyWith(journeyAlertsEnabled: v),
      );

  Future<void> setSosAlertsEnabled(bool enabled) => _persistAndSync(
        localKey: _sosKey,
        apiKey: 'sosAlertsEnabled',
        enabled: enabled,
        apply: (v) => state.copyWith(sosAlertsEnabled: v),
      );

  Future<void> setRouteWarningsEnabled(bool enabled) => _persistAndSync(
        localKey: _routeKey,
        apiKey: 'routeWarningsEnabled',
        enabled: enabled,
        apply: (v) => state.copyWith(routeWarningsEnabled: v),
      );

  Future<void> setCommunityAlertsEnabled(bool enabled) => _persistAndSync(
        localKey: _communityKey,
        apiKey: 'communityAlertsEnabled',
        enabled: enabled,
        apply: (v) => state.copyWith(communityAlertsEnabled: v),
      );

  Future<void> setSafetyRemindersEnabled(bool enabled) => _persistAndSync(
        localKey: _reminderKey,
        apiKey: 'safetyRemindersEnabled',
        enabled: enabled,
        apply: (v) => state.copyWith(safetyRemindersEnabled: v),
      );

  Future<void> markNotificationOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = state.copyWith(notificationOnboardingDone: true);
  }

  static Future<bool> isRouteWarningsEnabledLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_routeKey) ?? true;
  }

  static Future<bool> isSosAlertsEnabledLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sosKey) ?? true;
  }

  static Future<bool> isCommunityAlertsEnabledLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_communityKey) ?? true;
  }

  static Future<bool> isSafetyRemindersEnabledLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderKey) ?? true;
  }
}
