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
    setState(() => _from = picked);
    await _reload();
  }

  Future<void> _pickTo() async {
    final picked = await _pickDateTime(_to);
    if (picked == null) return;
    setState(() => _to = picked);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('activityLogsTitle')),
        actions: [
          if (_unlocked)
            IconButton(
              tooltip: l10n.t('activityLogsExport'),
              onPressed: _export,
              icon: const Icon(Icons.ios_share_rounded),
            ),
        ],
      ),
      body: !_unlocked
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error ?? l10n.t('activityLogsUnlockCancelled'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _unlockAndLoad();
                      },
                      child: Text(l10n.t('activityLogsUnlockAction')),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    l10n.t('activityLogsSubtitle'),
                    style: TextStyle(
                      color: isLight ? const Color(0xFF5F6F8A) : Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: Text(
                          '${l10n.t('activityLogsFrom')}: ${stamp.format(_from)}',
                        ),
                        onPressed: _pickFrom,
                      ),
                      ActionChip(
                        label: Text(
                          '${l10n.t('activityLogsTo')}: ${stamp.format(_to)}',
                        ),
                        onPressed: _pickTo,
                      ),
                      ActionChip(
                        label: Text(l10n.t('activityLogsLast24h')),
                        onPressed: () {
                          setState(() {
                            _to = DateTime.now();
                            _from = _to.subtract(const Duration(hours: 24));
                          });
                          _reload();
                        },
                      ),
                      ActionChip(
                        label: Text(l10n.t('activityLogsYesterday')),
                        onPressed: () {
                          final now = DateTime.now();
                          final start = DateTime(now.year, now.month, now.day)
                              .subtract(const Duration(days: 1));
                          setState(() {
                            _from = start;
                            _to = start.add(const Duration(days: 1));
                          });
                          _reload();
                        },
                      ),
                    ],
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
                          ? Center(child: Text(l10n.t('activityLogsEmpty')))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _entries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final row = _entries[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? Colors.white
                                        : AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: row.tampered
                                          ? Colors.orange
                                          : (isLight
                                              ? const Color(0xFFDCE5F6)
                                              : Colors.white12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm:ss')
                                            .format(row.timestamp.toLocal()),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isLight
                                              ? const Color(0xFF5F6F8A)
                                              : Colors.white60,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        row.event,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (row.details.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(row.details),
                                      ],
                                      if (row.tampered)
                                        Text(
                                          l10n.t('activityLogsTampered'),
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
