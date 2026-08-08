import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_offline_banner.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Full-screen placeholder shown while the device location is still being
/// resolved (or failed to resolve), with a retry action and emergency
/// quick-dial chips.
class MapLocatingView extends StatelessWidget {
  const MapLocatingView({
    super.key,
    required this.isLoading,
    required this.isLight,
    required this.statusText,
    required this.onRetry,
    required this.onDialPolice,
    required this.onDialHelpline,
  });

  final bool isLoading;
  final bool isLight;
  final String? statusText;
  final VoidCallback onRetry;
  final VoidCallback onDialPolice;
  final VoidCallback onDialHelpline;

  @override
  Widget build(BuildContext context) {
    final canRetry = !isLoading && statusText != null;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isLight ? const Color(0xFFF4F7FB) : AppTheme.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: AppTheme.primaryColor)
              else
                Icon(
                  Icons.location_searching_rounded,
                  size: 42,
                  color: isLight ? AppTheme.primaryColor : Colors.white70,
                ),
              const SizedBox(height: 18),
              Text(
                statusText ?? 'Fetching your current location...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLight ? const Color(0xFF26364D) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).t('mapWillOpenAroundYou'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLight ? const Color(0xFF65758F) : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (canRetry) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppLocalizations.of(context).t('tryAgain')),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context).t('mapOfflineEmergencyHint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF65758F) : Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OfflineActionChip(
                      label: AppLocalizations.of(context).t('policeEmergency'),
                      onTap: onDialPolice,
                    ),
                    OfflineActionChip(
                      label: AppLocalizations.of(context).t('womenHelpline'),
                      onTap: onDialHelpline,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
