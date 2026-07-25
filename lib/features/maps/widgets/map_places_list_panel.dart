import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Floating list panel showing nearby police stations and hospitals,
/// toggled on from the quick controls / list-view action.
class MapPlacesListPanel extends StatelessWidget {
  const MapPlacesListPanel({
    super.key,
    required this.isLight,
    required this.isOffline,
    required this.isSearchOpen,
    required this.markers,
    required this.onClose,
    required this.onPlaceTap,
  });

  final bool isLight;
  final bool isOffline;
  final bool isSearchOpen;
  final Set<Marker> markers;
  final VoidCallback onClose;
  final void Function(LatLng position, String title) onPlaceTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final places = markers
        .where(
          (m) =>
              m.markerId.value.startsWith('police_') ||
              m.markerId.value.startsWith('hospital_'),
        )
        .toList(growable: false);

    return Positioned(
      left: 16,
      right: 72,
      top: isOffline ? (isSearchOpen ? 210 : 148) : (isSearchOpen ? 78 : 16),
      bottom: 120,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight
                  ? const Color(0xFFDCE5F6)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('mapNearbyPlacesListTitle'),
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF172235)
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: places.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            isOffline
                                ? l10n.t('mapOfflinePlacesUnavailable')
                                : l10n.t('noNearbyPlaces'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF64748B)
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                        itemCount: places.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final marker = places[index];
                          final isPolice = marker.markerId.value.startsWith(
                            'police_',
                          );
                          final serviceLabel = isPolice
                              ? l10n.t('mapPoliceStationsLabel')
                              : l10n.t('mapHospitalsLabel');
                          final title = marker.infoWindow.title ?? serviceLabel;
                          final spoken =
                              '$serviceLabel: $title. ${l10n.t('mapTapToOpenPlace')}';
                          return Semantics(
                            button: true,
                            label: spoken,
                            child: ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: isLight
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white.withValues(alpha: 0.06),
                              leading: Icon(
                                isPolice
                                    ? Icons.local_police_rounded
                                    : Icons.local_hospital_rounded,
                                color: isPolice
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE53935),
                              ),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                serviceLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLight
                                      ? const Color(0xFF64748B)
                                      : Colors.white60,
                                ),
                              ),
                              onTap: () => onPlaceTap(marker.position, title),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
