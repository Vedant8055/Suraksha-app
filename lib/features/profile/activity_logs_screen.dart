import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_entry.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/core/security/device_credential_auth.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

enum _LogRangePreset { custom, last24h, yesterday }

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final _auth = DeviceCredentialAuth();
  bool _unlocked = false;
  bool _loading = true;
  String? _error;
  List<ActivityLogEntry> _entries = const [];
  DateTime _from = DateTime.now().subtract(const Duration(days: 1));
  DateTime _to = DateTime.now();
  _LogRangePreset _preset = _LogRangePreset.last24h;

  @override
  void initState() {
    super.initState();
    _unlockAndLoad();
  }

  Future<void> _unlockAndLoad() async {
    final l10n = await AppLocalizations.current();
    final available = await _auth.isAvailable();
    if (!available) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.t('activityLogsLockMissing');
      });
      return;
    }
    final ok = await _auth.authenticate(reason: l10n.t('activityLogsUnlockReason'));
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _loading = false;
        _error = l10n.t('activityLogsUnlockCancelled');
      });
      return;
    }
    setState(() => _unlocked = true);
    await AppActivityLog.instance.record('logs_opened');
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final rows = await AppActivityLog.instance.store.readRange(_from, _to);
      if (!mounted) return;
      setState(() {
        _entries = rows;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).t('activityLogsLoadFailed');
      });
    }
  }

  Future<void> _pickFrom() async {
    final picked = await _pickDateTime(_from);
    if (picked == null) return;
    setState(() {
      _from = picked;
      _preset = _LogRangePreset.custom;
    });
    await _reload();
  }

  Future<void> _pickTo() async {
    final picked = await _pickDateTime(_to);
    if (picked == null) return;
    setState(() {
      _to = picked;
      _preset = _LogRangePreset.custom;
    });
    await _reload();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _applyLast24h() async {
    setState(() {
      _to = DateTime.now();
      _from = _to.subtract(const Duration(hours: 24));
      _preset = _LogRangePreset.last24h;
    });
    await _reload();
  }

  Future<void> _applyYesterday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    setState(() {
      _from = start;
      _to = start.add(const Duration(days: 1));
      _preset = _LogRangePreset.yesterday;
    });
    await _reload();
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    if (!_unlocked) return;
    final ok = await _auth.authenticate(reason: l10n.t('activityLogsExportUnlock'));
    if (!ok || !mounted) return;
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('activityLogsEmpty'))),
      );
      return;
    }
    final buf = StringBuffer();
    buf.writeln('Suraksha activity logs');
    buf.writeln('From: ${_from.toIso8601String()}');
    buf.writeln('To: ${_to.toIso8601String()}');
    buf.writeln('---');
    final chronological = [..._entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (final row in chronological) {
      final flag = row.tampered ? ' [TAMPERED]' : '';
      buf.writeln(
        '${row.timestamp.toLocal().toIso8601String()} | ${row.event} | ${row.details}$flag',
      );
    }
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/suraksha_logs_${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    await file.writeAsString(buf.toString(), flush: true);
    await AppActivityLog.instance.record(
      'logs_exported',
      details: {
        'from': _from.toIso8601String(),
        'to': _to.toIso8601String(),
        'count': '${_entries.length}',
      },
    );
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/plain', name: 'suraksha_logs.txt')],
      subject: l10n.t('activityLogsTitle'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final stamp = DateFormat('dd MMM, HH:mm');
    final bg = isLight ? const Color(0xFFF4F7FC) : Colors.black;
    final textColor = isLight ? const Color(0xFF101828) : Colors.white;
    final muted = isLight ? const Color(0xFF667085) : const Color(0xFF9BB0CC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(l10n.t('activityLogsTitle')),
        actions: [
          if (_unlocked)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: l10n.t('activityLogsExport'),
                onPressed: _export,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.14),
                  foregroundColor: AppTheme.primaryColor,
                ),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ),
        ],
      ),
      body: !_unlocked
          ? _LockedState(
              message: _error ?? l10n.t('activityLogsUnlockCancelled'),
              title: l10n.t('activityLogsUnlockTitle'),
              actionLabel: l10n.t('activityLogsUnlockAction'),
              onUnlock: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _unlockAndLoad();
              },
              isLight: isLight,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _VaultHeader(
                    subtitle: l10n.t('activityLogsSubtitle'),
                    encrypted: l10n.t('activityLogsEncryptedBadge'),
                    retention: l10n.t('activityLogsRetentionBadge'),
                    countLabel: l10n
                        .t('activityLogsEventCount')
                        .replaceAll('{count}', '${_entries.length}'),
                    isLight: isLight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FilterCard(
                    fromLabel: l10n.t('activityLogsFrom'),
                    toLabel: l10n.t('activityLogsTo'),
                    fromValue: stamp.format(_from),
                    toValue: stamp.format(_to),
                    last24h: l10n.t('activityLogsLast24h'),
                    yesterday: l10n.t('activityLogsYesterday'),
                    preset: _preset,
                    onFrom: _pickFrom,
                    onTo: _pickTo,
                    onLast24h: _applyLast24h,
                    onYesterday: _applyYesterday,
                    isLight: isLight,
                    muted: muted,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : _entries.isEmpty
                          ? _EmptyLogs(
                              title: l10n.t('activityLogsEmpty'),
                              hint: l10n.t('activityLogsEmptyHint'),
                              muted: muted,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                              itemCount: _entries.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _LogEntryCard(
                                  entry: _entries[index],
                                  tamperedLabel: l10n.t('activityLogsTampered'),
                                  isLight: isLight,
                                  textColor: textColor,
                                  muted: muted,
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}

class _LockedState extends StatelessWidget {
  const _LockedState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onUnlock,
    required this.isLight,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onUnlock;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.22),
                    AppTheme.secondaryColor.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                color: isLight ? const Color(0xFF667085) : Colors.white70,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultHeader extends StatelessWidget {
  const _VaultHeader({
    required this.subtitle,
    required this.encrypted,
    required this.retention,
    required this.countLabel,
    required this.isLight,
  });

  final String subtitle;
  final String encrypted;
  final String retention;
  final String countLabel;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [Color(0xFF1D8CF8), Color(0xFF2ED6C5)]
              : const [Color(0xFF123A6B), Color(0xFF0F2A44)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isLight ? 0.28 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SoftBadge(icon: Icons.lock_rounded, label: encrypted),
              _SoftBadge(icon: Icons.schedule_rounded, label: retention),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.fromLabel,
    required this.toLabel,
    required this.fromValue,
    required this.toValue,
    required this.last24h,
    required this.yesterday,
    required this.preset,
    required this.onFrom,
    required this.onTo,
    required this.onLast24h,
    required this.onYesterday,
    required this.isLight,
    required this.muted,
    required this.textColor,
  });

  final String fromLabel;
  final String toLabel;
  final String fromValue;
  final String toValue;
  final String last24h;
  final String yesterday;
  final _LogRangePreset preset;
  final VoidCallback onFrom;
  final VoidCallback onTo;
  final VoidCallback onLast24h;
  final VoidCallback onYesterday;
  final bool isLight;
  final Color muted;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final hairline = isLight
        ? const Color(0xFFE4EAF3)
        : Colors.white.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: fromLabel,
                  value: fromValue,
                  icon: Icons.calendar_month_rounded,
                  onTap: onFrom,
                  isLight: isLight,
                  muted: muted,
                  textColor: textColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  label: toLabel,
                  value: toValue,
                  icon: Icons.event_available_rounded,
                  onTap: onTo,
                  isLight: isLight,
                  muted: muted,
                  textColor: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PresetChip(
                  label: last24h,
                  selected: preset == _LogRangePreset.last24h,
                  onTap: onLast24h,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PresetChip(
                  label: yesterday,
                  selected: preset == _LogRangePreset.yesterday,
                  onTap: onYesterday,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.isLight,
    required this.muted,
    required this.textColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLight;
  final Color muted;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isLight ? const Color(0xFFF6F9FE) : AppTheme.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w800,
                      color: muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.primaryColor
          : AppTheme.primaryColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs({
    required this.title,
    required this.hint,
    required this.muted,
  });

  final String title;
  final String hint;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: muted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(hint, textAlign: TextAlign.center, style: TextStyle(color: muted)),
          ],
        ),
      ),
    );
  }
}

class _LogEntryCard extends StatelessWidget {
  const _LogEntryCard({
    required this.entry,
    required this.tamperedLabel,
    required this.isLight,
    required this.textColor,
    required this.muted,
  });

  final ActivityLogEntry entry;
  final String tamperedLabel;
  final bool isLight;
  final Color textColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final style = _LogVisual.forEvent(entry);
    final pairs = _parseDetailPairs(entry.details);
    final hairline = entry.tampered
        ? const Color(0xFFF79009)
        : (isLight ? const Color(0xFFE4EAF3) : Colors.white.withValues(alpha: 0.08));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF7FAFF)]
              : const [Color(0xFF152238), Color(0xFF101A2D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(style.icon, color: style.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('dd MMM yyyy · HH:mm:ss')
                          .format(entry.timestamp.toLocal()),
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              if (style.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: style.badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    style.badge!,
                    style: TextStyle(
                      color: style.badgeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (pairs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pairs
                  .map(
                    (pair) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFF2F6FC)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${pair.$1}  ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: muted,
                              ),
                            ),
                            TextSpan(
                              text: pair.$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ] else if (entry.details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.details, style: TextStyle(color: muted, height: 1.35)),
          ],
          if (entry.tampered) ...[
            const SizedBox(height: 8),
            Text(
              tamperedLabel,
              style: const TextStyle(
                color: Color(0xFFF79009),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogVisual {
  const _LogVisual({
    required this.title,
    required this.icon,
    required this.color,
    this.badge,
    this.badgeColor = AppTheme.primaryColor,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color badgeColor;

  static _LogVisual forEvent(ActivityLogEntry entry) {
    final details = _parseDetails(entry.details);
    final status = int.tryParse(details['status'] ?? '');
    final method = details['method'];

    switch (entry.event) {
      case 'api_call':
        final ok = status != null && status >= 200 && status < 400;
        return _LogVisual(
          title: 'API call',
          icon: Icons.cloud_sync_rounded,
          color: ok ? const Color(0xFF12B76A) : AppTheme.primaryColor,
          badge: method ?? (status == null ? null : '$status'),
          badgeColor: status == null
              ? AppTheme.primaryColor
              : (ok ? const Color(0xFF12B76A) : const Color(0xFFF04438)),
        );
      case 'screen_opened':
        return const _LogVisual(
          title: 'Screen opened',
          icon: Icons.layers_rounded,
          color: AppTheme.primaryColor,
        );
      case 'logs_opened':
        return const _LogVisual(
          title: 'Logs opened',
          icon: Icons.visibility_rounded,
          color: AppTheme.secondaryColor,
        );
      case 'logs_exported':
        return const _LogVisual(
          title: 'Logs exported',
          icon: Icons.ios_share_rounded,
          color: AppTheme.secondaryColor,
        );
      case 'app_started':
        return const _LogVisual(
          title: 'App started',
          icon: Icons.play_circle_fill_rounded,
          color: AppTheme.primaryColor,
        );
      case 'login_success':
        return const _LogVisual(
          title: 'Signed in',
          icon: Icons.login_rounded,
          color: Color(0xFF12B76A),
          badge: 'OK',
          badgeColor: Color(0xFF12B76A),
        );
      case 'login_failed':
        return const _LogVisual(
          title: 'Sign-in failed',
          icon: Icons.error_outline_rounded,
          color: Color(0xFFF04438),
          badge: 'Failed',
          badgeColor: Color(0xFFF04438),
        );
      case 'signup_success':
        return const _LogVisual(
          title: 'Account created',
          icon: Icons.person_add_alt_1_rounded,
          color: Color(0xFF12B76A),
        );
      case 'signup_failed':
        return const _LogVisual(
          title: 'Signup failed',
          icon: Icons.person_off_outlined,
          color: Color(0xFFF04438),
        );
      case 'logout':
        return const _LogVisual(
          title: 'Signed out',
          icon: Icons.logout_rounded,
          color: Color(0xFF667085),
        );
      case 'sos_triggered':
        return const _LogVisual(
          title: 'SOS triggered',
          icon: Icons.sos_rounded,
          color: AppTheme.accentColor,
          badge: 'SOS',
          badgeColor: AppTheme.accentColor,
        );
      case 'sos_cancelled':
        return const _LogVisual(
          title: 'SOS cancelled',
          icon: Icons.cancel_outlined,
          color: Color(0xFFF79009),
        );
      case 'sos_blocked_no_contacts':
        return const _LogVisual(
          title: 'SOS blocked',
          icon: Icons.block_rounded,
          color: Color(0xFFF79009),
        );
      case 'profile_photo_updated':
        return const _LogVisual(
          title: 'Photo updated',
          icon: Icons.photo_camera_rounded,
          color: AppTheme.primaryColor,
        );
      case 'integrity_error':
        return const _LogVisual(
          title: 'Integrity warning',
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFF79009),
          badge: 'Check',
          badgeColor: Color(0xFFF79009),
        );
      default:
        return _LogVisual(
          title: _humanizeEvent(entry.event),
          icon: Icons.bolt_rounded,
          color: AppTheme.primaryColor,
        );
    }
  }
}

Map<String, String> _parseDetails(String raw) {
  if (raw.trim().isEmpty) return const {};
  final map = <String, String>{};
  for (final part in raw.split(';')) {
    final trimmed = part.trim();
    if (trimmed.isEmpty) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    map[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
  }
  return map;
}

String _humanizeEvent(String event) {
  return event
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

List<(String, String)> _detailPairs(Map<String, String> map) {
  const order = ['method', 'path', 'status', 'screen', 'from', 'to', 'count'];
  final pairs = <(String, String)>[];
  final used = <String>{};
  for (final key in order) {
    final value = map[key];
    if (value == null || value.isEmpty) continue;
    pairs.add((_prettyKey(key), _prettyValue(key, value)));
    used.add(key);
  }
  for (final entry in map.entries) {
    if (used.contains(entry.key) || entry.value.isEmpty) continue;
    pairs.add((_prettyKey(entry.key), entry.value));
  }
  return pairs;
}

List<(String, String)> _parseDetailPairs(String raw) =>
    _detailPairs(_parseDetails(raw));

String _prettyKey(String key) {
  switch (key) {
    case 'method':
      return 'Method';
    case 'path':
      return 'Path';
    case 'status':
      return 'Status';
    case 'screen':
      return 'Screen';
    case 'from':
      return 'From';
    case 'to':
      return 'To';
    case 'count':
      return 'Count';
    default:
      return _humanizeEvent(key);
  }
}

String _prettyValue(String key, String value) {
  if (key == 'screen') {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('PageRouteBuilder', 'Screen')
        .trim();
  }
  return value;
}
