import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class SignedInDevicesScreen extends ConsumerStatefulWidget {
  const SignedInDevicesScreen({super.key});

  @override
  ConsumerState<SignedInDevicesScreen> createState() =>
      _SignedInDevicesScreenState();
}

class _SignedInDevicesScreenState extends ConsumerState<SignedInDevicesScreen> {
  List<AuthSessionInfo> _sessions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await ref.read(authProvider.notifier).fetchSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).t('sessionsLoadFailed');
      });
    }
  }

  Future<void> _revoke(AuthSessionInfo session) async {
    final l10n = AppLocalizations.of(context);
    if (session.isCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('sessionsCannotRevokeCurrent'))),
      );
      return;
    }

    await ref.read(authProvider.notifier).revokeSession(session.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('sessionRevoked'))),
    );
    await _load();
  }

  Future<void> _revokeOthers() async {
    final count = await ref.read(authProvider.notifier).revokeOtherSessions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .t('sessionsRevokedOthers')
              .replaceAll('{count}', '$count'),
        ),
      ),
    );
    await _load();
  }

  Future<void> _revokeAll() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('sessionsRevokeAllTitle')),
        content: Text(l10n.t('sessionsRevokeAllMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('sessionsRevokeAllConfirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(authProvider.notifier).revokeAllSessions();
    if (!mounted) return;
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('signedInDevicesTitle'))),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.t('signedInDevicesSubtitle'),
              style: TextStyle(
                color: isLight ? const Color(0xFF64748B) : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent))
            else if (_sessions.isEmpty)
              Text(l10n.t('sessionsEmpty'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  final label = session.deviceLabel ??
                      session.platform ??
                      l10n.t('unknownDevice');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        session.isCurrent
                            ? Icons.phone_android_rounded
                            : Icons.devices_other_rounded,
                        color: session.isCurrent
                            ? AppTheme.primaryColor
                            : null,
                      ),
                      title: Text(label),
                      subtitle: Text(
                        session.isCurrent
                            ? l10n.t('currentDevice')
                            : l10n.t('otherDevice'),
                      ),
                      trailing: session.isCurrent
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.logout_rounded),
                              onPressed: () => _revoke(session),
                            ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _revokeOthers,
              icon: const Icon(Icons.phonelink_erase_rounded),
              label: Text(l10n.t('sessionsRevokeOthers')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading ? null : _revokeAll,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: Text(
                l10n.t('sessionsRevokeAllConfirm'),
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
