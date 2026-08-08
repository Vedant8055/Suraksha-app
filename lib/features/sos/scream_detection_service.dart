import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/distress_foreground_controller.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/distress_phrases.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/offline_speech_engine.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/scream_audio_classifier.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_provider.dart';

final screamDetectionProvider =
    StateNotifierProvider<ScreamDetectionService, ScreamDetectionState>(
      (ref) => ScreamDetectionService(ref)..loadPreference(),
    );

enum DistressTriggerType { scream, phrase, unknown }

class ScreamDetectionState {
  final bool enabled;
  final bool monitoring;
  final bool permissionGranted;
  final bool countdownActive;
  final int countdownSeconds;
  final bool testMode;
  final DistressSensitivity sensitivity;
  final String? lastDetectedPhrase;
  final String? lastSpeechSnippet;
  final double? lastScreamScore;
  final DistressTriggerType? lastTriggerType;
  final String? error;
  final bool batteryRestricted;
  final int falsePositiveCount;
  final DateTime? lastTestDetectionAt;

  const ScreamDetectionState({
    this.enabled = false,
    this.monitoring = false,
    this.permissionGranted = false,
    this.countdownActive = false,
    this.countdownSeconds = 10,
    this.testMode = false,
    this.sensitivity = DistressSensitivity.medium,
    this.lastDetectedPhrase,
    this.lastSpeechSnippet,
    this.lastScreamScore,
    this.lastTriggerType,
    this.error,
    this.batteryRestricted = false,
    this.falsePositiveCount = 0,
    this.lastTestDetectionAt,
  });

  ScreamDetectionState copyWith({
    bool? enabled,
    bool? monitoring,
    bool? permissionGranted,
    bool? countdownActive,
    int? countdownSeconds,
    bool? testMode,
    DistressSensitivity? sensitivity,
    String? lastDetectedPhrase,
    String? lastSpeechSnippet,
    double? lastScreamScore,
    DistressTriggerType? lastTriggerType,
    bool clearLastDetection = false,
    String? error,
    bool? batteryRestricted,
    int? falsePositiveCount,
    DateTime? lastTestDetectionAt,
  }) {
    return ScreamDetectionState(
      enabled: enabled ?? this.enabled,
      monitoring: monitoring ?? this.monitoring,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      countdownActive: countdownActive ?? this.countdownActive,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      testMode: testMode ?? this.testMode,
      sensitivity: sensitivity ?? this.sensitivity,
      lastDetectedPhrase: clearLastDetection
          ? null
          : (lastDetectedPhrase ?? this.lastDetectedPhrase),
      lastSpeechSnippet: clearLastDetection
          ? null
          : (lastSpeechSnippet ?? this.lastSpeechSnippet),
      lastScreamScore: clearLastDetection
          ? null
          : (lastScreamScore ?? this.lastScreamScore),
      lastTriggerType: clearLastDetection
          ? null
          : (lastTriggerType ?? this.lastTriggerType),
      error: error,
      batteryRestricted: batteryRestricted ?? this.batteryRestricted,
      falsePositiveCount: falsePositiveCount ?? this.falsePositiveCount,
      lastTestDetectionAt: lastTestDetectionAt ?? this.lastTestDetectionAt,
    );
  }
}

class ScreamDetectionService extends StateNotifier<ScreamDetectionState> {
  ScreamDetectionService(this._ref) : super(const ScreamDetectionState());

  final Ref _ref;
  final OfflineSpeechEngine _speech = OfflineSpeechEngine();
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _audioSub;
  Timer? _countdownTimer;
  Timer? _speechCycleTimer;
  Timer? _permissionTimer;
  bool _starting = false;
  bool _speechCycleActive = false;
  bool _foregroundListenerAttached = false;
  DateTime? _lastTriggerAt;
  DateTime? _lastScreamSignalAt;
  int _screamChunkStreak = 0;

  static const String _preferenceKey = 'scream_detection_enabled_v1';
  static const String _sensitivityKey = 'distress_sensitivity_v1';
  static const String _testModeKey = 'distress_test_mode_v1';
  static const String _localeKey = 'app_locale_v1';
  static const String _falsePositiveCountKey =
      'distress_false_positive_count_v1';
  static const Duration _triggerCooldown = Duration(minutes: 2);
  static const Duration _speechCycleInterval = Duration(seconds: 10);
  static const Duration _initialSpeechDelay = Duration(seconds: 3);
  static const Duration _speechBurstDuration = Duration(seconds: 7);
  static const Duration _screamDebounce = Duration(seconds: 5);
  static const int _screamChunksRequired = 3;
  static const int _countdownStartSeconds = 10;

  Future<void> _startAudioStream() async {
    await _stopAudioStream();
    final recorder = AudioRecorder();
    if (!await recorder.hasPermission()) return;

    try {
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
        ),
      );
      _recorder = recorder;
      _audioSub = stream.listen(_onAudioChunk);
    } catch (_) {
      await recorder.dispose();
    }
  }

  Future<void> _stopAudioStream() async {
    await _audioSub?.cancel();
    _audioSub = null;
    if (_recorder != null) {
      try {
        await _recorder!.stop();
        await _recorder!.dispose();
      } catch (_) {}
    }
    _recorder = null;
    ScreamAudioClassifier.instance.resetSession();
  }

  void _onAudioChunk(Uint8List chunk) {
    final result = ScreamAudioClassifier.instance.analyzePcm(
      chunk,
      sampleRate: 16000,
      sensitivity: state.sensitivity,
    );
    if (!result.isScream) {
      _screamChunkStreak = 0;
      return;
    }

    _screamChunkStreak++;
    if (_screamChunkStreak < _screamChunksRequired) return;
    _screamChunkStreak = 0;

    final now = DateTime.now();
    if (_lastScreamSignalAt != null &&
        now.difference(_lastScreamSignalAt!) < _screamDebounce) {
      return;
    }
    _lastScreamSignalAt = now;

    onDistressDetected(
      type: DistressTriggerType.scream,
      screamScore: result.score,
      phrase: null,
      speechText: null,
      testMode: state.testMode,
    );
  }

  Future<void> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_preferenceKey) ?? false;
      final sensitivity = _parseSensitivity(prefs.getString(_sensitivityKey));
      final testMode = prefs.getBool(_testModeKey) ?? false;
      state = state.copyWith(
        enabled: enabled,
        sensitivity: sensitivity,
        testMode: testMode,
        falsePositiveCount: prefs.getInt(_falsePositiveCountKey) ?? 0,
      );
      if (enabled) {
        await startMonitoring();
      }
    } catch (_) {
      state = state.copyWith(
        enabled: false,
        monitoring: false,
        error: l10nSync('screamDetectionEnableFailed'),
      );
    }
  }

  Future<bool> setEnabled(
    bool enabled, {
    bool allowBatteryPrompt = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!enabled) {
      await stopMonitoring();
      await prefs.setBool(_preferenceKey, false);
      state = state.copyWith(enabled: false, error: null);
      return true;
    }

    if (!FeatureFlags.backgroundMicrophone) {
      state = state.copyWith(
        enabled: false,
        error: l10nSync('featureUnavailable'),
      );
      return false;
    }

    final started = await startMonitoring(
      allowBatteryPrompt: allowBatteryPrompt,
    );
    if (started) {
      await prefs.setBool(_preferenceKey, true);
      state = state.copyWith(enabled: true, error: null);
      return true;
    }

    await prefs.setBool(_preferenceKey, false);
    state = state.copyWith(enabled: false);
    return false;
  }

  Future<void> setSensitivity(DistressSensitivity sensitivity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sensitivityKey, sensitivity.name);
    state = state.copyWith(sensitivity: sensitivity);
    if (state.monitoring) {
      await DistressForegroundController.start(
        sensitivity: sensitivity.name,
        testMode: state.testMode,
      );
    }
  }

  Future<void> setTestMode(bool testMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_testModeKey, testMode);
    _speech.setTestMode(testMode);
    state = state.copyWith(testMode: testMode);
    if (state.monitoring) {
      await DistressForegroundController.start(
        sensitivity: state.sensitivity.name,
        testMode: testMode,
      );
    }
  }

  Future<void> resumeIfEnabled() async {
    if (state.enabled && await Permission.microphone.status != PermissionStatus.granted) {
      await _handlePermissionLoss();
      return;
    }
    if (state.enabled && !state.monitoring) {
      await startMonitoring();
    } else if (state.enabled && state.monitoring && _audioSub == null && !_speechCycleActive) {
      await _startAudioStream();
      _startSpeechCycle();
    }
  }

  Future<bool> startMonitoring({bool allowBatteryPrompt = false}) async {
    if (!FeatureFlags.backgroundMicrophone) {
      state = state.copyWith(
        monitoring: false,
        enabled: false,
        error: l10nSync('featureUnavailable'),
      );
      return false;
    }
    if (state.monitoring) return true;
    if (_starting) return false;
    _starting = true;

    final mic = await Permission.microphone.request();
    if (mic != PermissionStatus.granted) {
      state = state.copyWith(
        monitoring: false,
        permissionGranted: false,
        error: l10nSync('sosMicrophonePermissionNeeded'),
      );
      _starting = false;
      return false;
    }

    try {
      await ScreamAudioClassifier.instance.ensureLoaded();
      final fgStarted = await DistressForegroundController.start(
        sensitivity: state.sensitivity.name,
        testMode: state.testMode,
        allowBatteryPrompt: allowBatteryPrompt,
      );
      if (!fgStarted) {
        throw StateError(l10nSync('screamDetectionEnableFailed'));
      }
      if (!_foregroundListenerAttached) {
        DistressForegroundController.addDataListener(_onForegroundData);
        _foregroundListenerAttached = true;
      }

      _speech.setTestMode(state.testMode);
      await _startAudioStream();
      _startSpeechCycle();

      state = state.copyWith(
        monitoring: true,
        permissionGranted: true,
        batteryRestricted:
            await DistressForegroundController.isBatteryRestricted(),
        error: null,
      );
      _startPermissionMonitor();
      return true;
    } catch (error) {
      await stopMonitoring();
      state = state.copyWith(
        monitoring: false,
        permissionGranted: true,
        error: l10nSync('screamDetectionEnableFailed'),
      );
      return false;
    } finally {
      _starting = false;
    }
  }

  void _startSpeechCycle() {
    _speechCycleTimer?.cancel();
    _speechCycleTimer = Timer.periodic(_speechCycleInterval, (_) {
      if (!state.monitoring || _speechCycleActive) return;
      unawaited(_runSpeechBurst());
    });
    unawaited(Future<void>.delayed(_initialSpeechDelay, _runSpeechBurst));
  }

  void _startPermissionMonitor() {
    _permissionTimer?.cancel();
    _permissionTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!state.monitoring) return;
      if (await Permission.microphone.status != PermissionStatus.granted) {
        await _handlePermissionLoss();
      }
    });
  }

  void _onForegroundData(Object data) {
    if (data is Map && data['cmd'] == 'stop_monitoring') {
      unawaited(setEnabled(false));
    }
  }

  Future<void> _handlePermissionLoss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preferenceKey, false);
    await stopMonitoring();
    state = state.copyWith(
      enabled: false,
      monitoring: false,
      permissionGranted: false,
      error: l10nSync('sosMicrophonePermissionNeeded'),
    );
  }

  Future<void> _runSpeechBurst() async {
    if (!state.monitoring || _speechCycleActive || state.countdownActive) return;
    _speechCycleActive = true;
    await _stopAudioStream();
    _speech.setTestMode(state.testMode);
    _speech.setBurstDuration(_speechBurstDuration);
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_localeKey) ?? 'en';
    _speech.setPreferredLocales(DistressPhrases.speechLocalesForLanguage(lang));
    await _speech.startListening(onResult: _onSpeechResult);
    await Future<void>.delayed(_speechBurstDuration);
    await _speech.stopListening();
    _speechCycleActive = false;
    if (state.monitoring) {
      await _startAudioStream();
    }
  }

  Future<void> stopMonitoring() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _speechCycleTimer?.cancel();
    _speechCycleTimer = null;
    _permissionTimer?.cancel();
    _permissionTimer = null;
    _speechCycleActive = false;
    _screamChunkStreak = 0;
    await _speech.stopListening();
    await _stopAudioStream();
    await DistressForegroundController.stop();
    state = state.copyWith(
      monitoring: false,
      countdownActive: false,
      countdownSeconds: _countdownStartSeconds,
      error: null,
    );
  }

  void _onSpeechResult({
    required String text,
    required bool matched,
    String? phrase,
    required bool testMode,
  }) {
    state = state.copyWith(
      lastSpeechSnippet: text,
      lastDetectedPhrase: matched ? phrase : state.lastDetectedPhrase,
    );
    if (!matched) return;
    onDistressDetected(
      type: DistressTriggerType.phrase,
      phrase: phrase,
      speechText: text,
      testMode: testMode || state.testMode,
    );
  }

  void onDistressDetected({
    required DistressTriggerType type,
    String? phrase,
    String? speechText,
    double? screamScore,
    required bool testMode,
  }) {
    final now = DateTime.now();
    if (_lastTriggerAt != null &&
        now.difference(_lastTriggerAt!) < _triggerCooldown &&
        !testMode) {
      return;
    }
    if (state.countdownActive) return;

    state = state.copyWith(
      lastTriggerType: type,
      lastDetectedPhrase: phrase,
      lastSpeechSnippet: speechText ?? state.lastSpeechSnippet,
      lastScreamScore: screamScore,
      clearLastDetection: false,
      lastTestDetectionAt: testMode ? now : state.lastTestDetectionAt,
    );

    if (testMode) return;
    unawaited(_startDistressCountdown(type));
  }

  Future<void> _startDistressCountdown(DistressTriggerType type) async {
    if (state.countdownActive) return;
    _lastTriggerAt = DateTime.now();

    state = state.copyWith(
      countdownActive: true,
      countdownSeconds: _countdownStartSeconds,
      lastTriggerType: type,
      error: null,
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.countdownSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        unawaited(confirmPendingDistress());
        return;
      }
      state = state.copyWith(countdownSeconds: remaining);
    });
  }

  Future<void> confirmPendingDistress() async {
    if (!state.countdownActive) return;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = state.copyWith(
      countdownActive: false,
      countdownSeconds: _countdownStartSeconds,
    );
    await _ref.read(sosProvider.notifier).triggerSOS();
  }

  void cancelPendingDistress() {
    if (!state.countdownActive) return;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = state.copyWith(
      countdownActive: false,
      countdownSeconds: _countdownStartSeconds,
      clearLastDetection: true,
    );
  }

  Future<void> openMicrophoneSettings() {
    return openAppSettings();
  }

  Future<void> recordFalsePositive() async {
    final prefs = await SharedPreferences.getInstance();
    final count = state.falsePositiveCount + 1;
    await prefs.setInt(_falsePositiveCountKey, count);
    cancelPendingDistress();
    state = state.copyWith(falsePositiveCount: count);
  }

  DistressSensitivity _parseSensitivity(String? raw) {
    return switch (raw) {
      'low' => DistressSensitivity.low,
      'high' => DistressSensitivity.high,
      _ => DistressSensitivity.medium,
    };
  }

  @override
  void dispose() {
    if (_foregroundListenerAttached) {
      DistressForegroundController.removeDataListener(_onForegroundData);
    }
    stopMonitoring();
    super.dispose();
  }
}
