import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/core/accessibility/accessibility.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:suraksha_women_safety_app/widgets/app_async_states.dart';
import 'package:suraksha_women_safety_app/widgets/premium_dialog.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

class EmergencyModeScreen extends ConsumerStatefulWidget {
  const EmergencyModeScreen({super.key});

  @override
  ConsumerState<EmergencyModeScreen> createState() =>
      _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends ConsumerState<EmergencyModeScreen> {
  bool _contactPopupShown = false;

  void _showContactsInformedPopup(SOSState sosState) {
    final contacts = ref.read(emergencyContactsProvider);
    if (contacts.isEmpty || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final message = sosState.hasLiveTracking
        ? l10n.t('liveLocationSharedWith')
        : l10n.t('smsAlertsSentNoLiveTrack');

    showDialog(
      context: context,
      builder: (dialogContext) => PremiumDialogSurface(
        title: l10n.t('emergencyContactsInformed'),
        message: message,
        icon: Icons.groups_rounded,
        accentColor: const Color(0xFFE53935),
        actions: [
          OutlinedButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  Theme.of(dialogContext).brightness == Brightness.light
                  ? const Color(0xFF172235)
                  : Colors.white,
              side: BorderSide(
                color: const Color(0xFFE53935).withValues(
                  alpha: Theme.of(dialogContext).brightness == Brightness.light
                      ? 0.34
                      : 0.42,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(AppLocalizations.of(dialogContext).t('ok')),
          ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in contacts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(dialogContext).brightness ==
                                Brightness.light
                            ? const Color(0xFFF4F7FC)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE53935).withValues(
                            alpha:
                                Theme.of(dialogContext).brightness ==
                                    Brightness.light
                                ? 0.14
                                : 0.24,
                          ),
                        ),
                      ),
                      child: Text(
                        '${c.name} (${c.phone})',
                        style: TextStyle(
                          color:
                              Theme.of(dialogContext).brightness ==
                                  Brightness.light
                              ? const Color(0xFF172235)
                              : Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _deliveryLabel(
    AppLocalizations l10n,
    SosDeliveryStatus status,
  ) {
    return switch (status) {
      SosDeliveryStatus.idle => l10n.t('sosDeliveryWaiting'),
      SosDeliveryStatus.sending => l10n.t('sosDeliverySending'),
      SosDeliveryStatus.sent => l10n.t('sosDeliverySent'),
      SosDeliveryStatus.partial => l10n.t('sosDeliveryPartial'),
      SosDeliveryStatus.failed => l10n.t('sosDeliveryFailed'),
      SosDeliveryStatus.unavailable => l10n.t('sosDeliveryUnavailable'),
    };
  }

  Future<void> _confirmAndCancel() async {
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.t('sosSafeConfirmTitle')),
            content: Text(l10n.t('sosSafeConfirmMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('keepSosActive')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.t('confirmSafe')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await ref.read(sosProvider.notifier).cancelSOS();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sosState = ref.watch(sosProvider);

    ref.listen<SOSState>(sosProvider, (previous, next) {
      if (_contactPopupShown) return;
      final smsReady = next.smsDelivery == SosDeliveryStatus.sent ||
          next.smsDelivery == SosDeliveryStatus.partial;
      if (!smsReady) return;
      _contactPopupShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showContactsInformedPopup(next);
      });
    });

    final locationText = sosState.currentPosition != null
        ? '${sosState.currentPosition!.latitude.toStringAsFixed(4)}, ${sosState.currentPosition!.longitude.toStringAsFixed(4)}'
        : l10n.t('emergencyFetchingLocation');

    final statusText = !sosState.isStreaming
        ? l10n.t('emergencyLiveTransmissionPaused')
        : sosState.hasLiveTracking
            ? (sosState.lastLocationUpdate != null
                ? l10n
                    .t('emergencyLiveFeedActive')
                    .replaceAll(
                      '{time}',
                      TimeOfDay.fromDateTime(
                        sosState.lastLocationUpdate!,
                      ).format(context),
                    )
                : l10n.t('emergencyLiveTransmissionStarting'))
            : l10n.t('emergencySmsOnlyNoLiveTrack');

    return Scaffold(
      backgroundColor: Colors.red.shade900,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Semantics(
                label: l10n.t('emergencyModeActive'),
                child: Accessibility.motionAware(
                  context: context,
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                  animate: (child) => Flash(infinite: true, child: child),
                ),
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.t('emergencyModeActive'),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('helpOnTheWay'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 36),
              _buildInfoCard(
                l10n.t('currentLocation'),
                locationText,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                l10n.t('status'),
                statusText,
                liveRegion: true,
              ),
              if (sosState.isSmsOnlyWithoutLiveTrack) ...[
                const SizedBox(height: 12),
                AppAsyncStates.partialSuccessBanner(
                  message: l10n.t('sosSmsOnlyBanner'),
                  accent: const Color(0xFFF59E0B),
                ),
              ],
              if (ref.watch(emergencyContactsProvider).isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sosState.hasLiveTracking
                            ? l10n.t('liveLocationSharingWith')
                            : l10n.t('emergencyContactsAlertedLabel'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final c in ref.watch(emergencyContactsProvider))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${c.name} (${c.phone})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildInfoCard(
                l10n.t('sosServerAlert'),
                _deliveryLabel(l10n, sosState.serverDelivery),
                liveRegion: true,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                l10n.t('sosSmsAlert'),
                '${_deliveryLabel(l10n, sosState.smsDelivery)}'
                '${sosState.smsTotalCount > 0 ? ' (${sosState.smsSentCount}/${sosState.smsTotalCount})' : ''}',
                liveRegion: true,
              ),
              if (sosState.smsDelivery == SosDeliveryStatus.partial) ...[
                const SizedBox(height: 12),
                AppAsyncStates.partialSuccessBanner(
                  message: l10n.t('partialDeliveryBanner'),
                  accent: const Color(0xFFF59E0B),
                ),
              ],
              if (sosState.error != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(l10n.t('error'), sosState.error!),
              ],
              if (sosState.trackingUrl != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: l10n.t('copyLiveTrackingLink'),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: sosState.trackingUrl!),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.t('sosTrackingLinkCopied')),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 48),
                      side: const BorderSide(color: Colors.white54),
                    ),
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(l10n.t('copyLiveTrackingLink')),
                  ),
                ),
              ],
              if (sosState.serverDelivery == SosDeliveryStatus.failed ||
                  sosState.smsDelivery == SosDeliveryStatus.failed ||
                  sosState.smsDelivery == SosDeliveryStatus.partial ||
                  sosState.isSmsOnlyWithoutLiveTrack) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.t('retry'),
                        child: OutlinedButton.icon(
                          onPressed: () => ref
                              .read(sosProvider.notifier)
                              .retryFailedDelivery(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.t('retry')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: l10n.t('openSmsComposer'),
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              ref.read(sosProvider.notifier).openSmsFallback(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.sms_outlined),
                          label: Text(l10n.t('openSmsComposer')),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              Semantics(
                button: true,
                label: l10n.t('iAmSafeCancelSos'),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _confirmAndCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade900,
                      minimumSize: const Size(48, 48),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.t('iAmSafeCancelSos')),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value, {
    bool liveRegion = false,
  }) {
    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
