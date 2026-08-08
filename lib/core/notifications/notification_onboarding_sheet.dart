import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suraksha_women_safety_app/core/notifications/push_notification_service.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// One-time post-login sheet explaining why notifications matter, then requests permission.
class NotificationOnboardingSheet extends StatefulWidget {
  const NotificationOnboardingSheet({
    super.key,
    required this.onCompleted,
  });

  final Future<void> Function() onCompleted;

  static Future<void> showIfNeeded(
    BuildContext context, {
    required bool alreadyDone,
    required Future<void> Function() onCompleted,
  }) async {
    if (alreadyDone || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => NotificationOnboardingSheet(onCompleted: onCompleted),
    );
  }

  @override
  State<NotificationOnboardingSheet> createState() =>
      _NotificationOnboardingSheetState();
}

class _NotificationOnboardingSheetState
    extends State<NotificationOnboardingSheet> {
  bool _busy = false;
  String? _status;

  Future<void> _enable() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final granted = await PushNotificationService.instance.requestPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() {
        _busy = false;
        _status = AppLocalizations.of(context).t('notifPermissionDeniedHint');
      });
      return;
    }
    await PushNotificationService.instance.registerTokenIfAuthenticated();
    await widget.onCompleted();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openSettings() async {
    await PushNotificationService.instance.openSystemNotificationSettings();
  }

  Future<void> _skip() async {
    await widget.onCompleted();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.t('notifOnboardingTitle'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('notifOnboardingBody'),
            style: const TextStyle(height: 1.4, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _Bullet(l10n.t('notifOnboardingBulletSos')),
          _Bullet(l10n.t('notifOnboardingBulletRoute')),
          _Bullet(l10n.t('notifOnboardingBulletCommunity')),
          _Bullet(l10n.t('notifOnboardingBulletReminders')),
          if (_status != null) ...[
            const SizedBox(height: 10),
            Text(
              _status!,
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _enable,
              child: Text(
                _busy
                    ? l10n.t('pleaseWait')
                    : l10n.t('notifEnableNotifications'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _busy ? null : _openSettings,
              child: Text(l10n.t('notifOpenSettings')),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _skip,
            child: Text(l10n.t('notifSkipForNow')),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> notificationPermissionGranted() async {
  final status = await Permission.notification.status;
  return status.isGranted || status.isLimited;
}
