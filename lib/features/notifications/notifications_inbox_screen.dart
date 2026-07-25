import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_deep_link.dart';
import 'package:suraksha_women_safety_app/core/notifications/push_notification_service.dart';
import 'package:suraksha_women_safety_app/features/notifications/notifications_repository.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/widgets/app_async_states.dart';

/// Lists server-backed alerts with delivery status (critical SOS / journey / etc.).
class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() =>
      _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  final _repo = NotificationsRepository();
  bool _loading = true;
  String? _error;
  List<_InboxItem> _items = const [];

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
      final list = await _repo.listActive();
      final items = list.map(_InboxItem.fromJson).toList();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.response?.data is Map
            ? (error.response!.data['message']?.toString() ??
                error.message ??
                'Failed to load')
            : (error.message ?? 'Failed to load');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load';
      });
    }
  }

  Future<void> _openItem(_InboxItem item) async {
    final l10n = AppLocalizations.of(context);
    final ack = await PushNotificationService.instance
        .acknowledgeNotification(item.id);
    if (!mounted) return;
    if (ack == NotificationAckResult.expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('notifExpiredHandled'))),
      );
      await _load();
      return;
    }

    final route = item.deepLink.isNotEmpty
        ? item.deepLink
        : NotificationDeepLink.dashboard;
    NotificationNavigation.handle({'route': route});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('notifInboxTitle')),
        actions: [
          IconButton(
            tooltip: l10n.t('refresh'),
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? AppAsyncStates.loading(message: l10n.t('pleaseWait'))
          : _error != null
              ? AppAsyncStates.errorWithRetry(
                  message: _error!,
                  onRetry: _load,
                  retryLabel: l10n.t('retry'),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.t('notifInboxEmpty'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            leading: Icon(
                              item.isCritical
                                  ? Icons.warning_amber_rounded
                                  : Icons.notifications_outlined,
                              color: item.isCritical
                                  ? const Color(0xFFE53935)
                                  : AppTheme.primaryColor,
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(item.body),
                                const SizedBox(height: 6),
                                Text(
                                  l10n
                                      .t('notifDeliveryStatusLabel')
                                      .replaceAll(
                                        '{status}',
                                        item.deliveryStatus,
                                      ),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                                if (item.deliveryStatus == 'failed' ||
                                    item.deliveryStatus == 'partial') ...[
                                  const SizedBox(height: 6),
                                  AppAsyncStates.partialSuccessBanner(
                                    message: l10n.t('partialDeliveryBanner'),
                                    accent: const Color(0xFFB45309),
                                  ),
                                ],
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () => _openItem(item),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _InboxItem {
  const _InboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.deliveryStatus,
    required this.deepLink,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String deliveryStatus;
  final String deepLink;

  bool get isCritical => category == 'sos' || deliveryStatus == 'failed';

  factory _InboxItem.fromJson(Map<String, dynamic> json) {
    return _InboxItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Suraksha alert').toString(),
      body: (json['body'] ?? '').toString(),
      category: (json['category'] ?? 'general').toString(),
      deliveryStatus: (json['deliveryStatus'] ?? 'pending').toString(),
      deepLink: (json['deepLink'] ?? '').toString(),
    );
  }
}
