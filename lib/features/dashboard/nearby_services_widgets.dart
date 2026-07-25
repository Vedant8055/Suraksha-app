import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Selectable service-type tile (hospitals, police, pharmacies, etc.)
/// (Phase 2 extract, same visuals/behavior).
class NearbyServiceTile extends StatelessWidget {
  const NearbyServiceTile({
    super.key,
    required this.width,
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.loading,
    required this.useCustomAsset,
    required this.onPressed,
  });

  final double width;
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final bool loading;
  final bool useCustomAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = active
        ? Colors.white
        : (isLight ? const Color(0xFF172235) : Colors.white);
    final inactiveBase = color.withValues(alpha: isLight ? 0.12 : 0.18);
    final inactiveEdge = color.withValues(alpha: isLight ? 0.2 : 0.28);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [color, Color.lerp(color, Colors.black, 0.18)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      inactiveBase,
                      color.withValues(alpha: isLight ? 0.06 : 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? Colors.white.withValues(alpha: 0.32)
                  : inactiveEdge,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? color.withValues(alpha: 0.32)
                    : isLight
                    ? color.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.18),
                blurRadius: active ? 18 : 10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.22)
                          : color.withValues(alpha: isLight ? 0.14 : 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: loading
                        ? const Padding(
                            padding: EdgeInsets.all(9),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : useCustomAsset
                        ? Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                              'assets/icons/pharmacy_badge.svg',
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(icon, color: active ? Colors.white : color),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: active
                        ? Colors.white.withValues(alpha: 0.86)
                        : color.withValues(alpha: 0.82),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status/empty/loading panel for the nearby services results
/// (Phase 2 extract, same visuals/behavior).
class NearbyStatusPanel extends StatelessWidget {
  const NearbyStatusPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.tone,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final Color tone;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.76)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight
              ? const Color(0xFFD8E5F7)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: isLight ? 0.13 : 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: loading
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tone,
                    ),
                  )
                : Icon(icon, color: tone, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isLight ? const Color(0xFF334158) : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small labelled chip used inside [NearbyResultCard]
/// (Phase 2 extract, same visuals/behavior).
class NearbyChip extends StatelessWidget {
  const NearbyChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isLight ? 0.1 : 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isLight ? const Color(0xFF334158) : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single nearby place result row (Phase 2 extract, same visuals/behavior).
class NearbyResultCard extends StatelessWidget {
  const NearbyResultCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  final NearbyPlaceItem place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final ratingText = place.rating != null
        ? place.rating!.toStringAsFixed(1)
        : l10n.t('notAvailableShort');
    final openText = place.isOpenNow == null
        ? l10n.t('hoursUnavailable')
        : (place.isOpenNow! ? l10n.t('openNow') : l10n.t('closedNow'));
    final openColor = place.isOpenNow == true
        ? const Color(0xFF2FB79E)
        : place.isOpenNow == false
        ? const Color(0xFFE66E41)
        : const Color(0xFF8E7CF4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.88)
                : AppTheme.surfaceSoft.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight
                  ? const Color(0xFFD8E5F7)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF3B82F6,
                  ).withValues(alpha: isLight ? 0.12 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: Color(0xFF3B82F6),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF172235) : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight
                            ? const Color(0xFF627491)
                            : Colors.white.withValues(alpha: 0.64),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        NearbyChip(
                          icon: Icons.route_rounded,
                          label: place.distanceTextFor(
                            Localizations.localeOf(context).languageCode,
                          ),
                          color: const Color(0xFF3B82F6),
                        ),
                        NearbyChip(
                          icon: Icons.star_rounded,
                          label: ratingText,
                          color: const Color(0xFFF3B13E),
                        ),
                        NearbyChip(
                          icon: Icons.schedule_rounded,
                          label: openText,
                          color: openColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isLight ? const Color(0xFF8FA2BE) : Colors.white30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full nearby-services card: service-type grid + results/status
/// (Phase 2 extract, same visuals/behavior).
class NearbyServicesBlock extends ConsumerWidget {
  const NearbyServicesBlock({super.key, required this.onOpenPlace});

  final Future<void> Function(BuildContext, NearbyPlaceItem) onOpenPlace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final nearbyState = ref.watch(nearbyPlacesProvider);
    final activeType = nearbyState.activeType;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF6FAFF), Color(0xFFEAF3FF)]
              : const [Color(0xFF15233A), Color(0xFF0B172A), Color(0xFF101827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0xFFCFE0F6)
              : Colors.white.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? const Color(0xFF7892B8).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2FB79E), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2FB79E).withValues(alpha: 0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('nearbyServices'),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: isLight ? const Color(0xFF13243D) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nearbyState.places.isNotEmpty
                          ? l10n
                                .t('nearbyResultsCount')
                                .replaceFirst(
                                  '{count}',
                                  nearbyState.places.length.toString(),
                                )
                          : l10n.t('chooseServiceToScanYourArea'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? const Color(0xFF627491)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final tileWidth = (constraints.maxWidth - gap) / 2;
              Widget rowTile({
                required String label,
                required IconData icon,
                required Color color,
                required NearbyPlaceType type,
                bool useCustomAsset = false,
              }) {
                return NearbyServiceTile(
                  width: tileWidth,
                  label: label,
                  icon: icon,
                  color: color,
                  active: activeType == type,
                  loading: nearbyState.isLoading && activeType == type,
                  useCustomAsset: useCustomAsset,
                  onPressed: () => ref
                      .read(nearbyPlacesProvider.notifier)
                      .toggleNearby(type),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      rowTile(
                        label: l10n.t('nearbyHospitals'),
                        icon: Icons.local_hospital_rounded,
                        color: const Color(0xFFE45858),
                        type: NearbyPlaceType.hospitals,
                      ),
                      const SizedBox(width: gap),
                      rowTile(
                        label: l10n.t('policeStations'),
                        icon: Icons.local_police_rounded,
                        color: const Color(0xFF3B82F6),
                        type: NearbyPlaceType.policeStations,
                      ),
                    ],
                  ),
                  const SizedBox(height: gap),
                  Row(
                    children: [
                      rowTile(
                        label: l10n.t('nearbyPharmacies'),
                        icon: Icons.local_pharmacy_rounded,
                        color: const Color(0xFF2EAD74),
                        type: NearbyPlaceType.pharmacies,
                        useCustomAsset: true,
                      ),
                      const SizedBox(width: gap),
                      rowTile(
                        label: l10n.t('nearbyPetrolPumps'),
                        icon: Icons.local_gas_station_rounded,
                        color: const Color(0xFFF59E0B),
                        type: NearbyPlaceType.petrolPumps,
                      ),
                    ],
                  ),
                  const SizedBox(height: gap),
                  Row(
                    children: [
                      rowTile(
                        label: l10n.t('nearbyWashrooms'),
                        icon: Icons.wc_rounded,
                        color: const Color(0xFF2FB79E),
                        type: NearbyPlaceType.washrooms,
                      ),
                      const SizedBox(width: gap),
                      rowTile(
                        label: l10n.t('nearbyBloodBanks'),
                        icon: Icons.bloodtype_rounded,
                        color: const Color(0xFFD64271),
                        type: NearbyPlaceType.bloodBanks,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (nearbyState.error != null)
            NearbyStatusPanel(
              icon: Icons.warning_amber_rounded,
              title: nearbyState.error!,
              tone: const Color(0xFFE66E41),
            )
          else if (nearbyState.isLoading)
            NearbyStatusPanel(
              icon: Icons.radar_rounded,
              title: l10n.t('scanningNearbyPlaces'),
              tone: activeType == NearbyPlaceType.bloodBanks
                  ? const Color(0xFFD64271)
                  : activeType == NearbyPlaceType.petrolPumps
                  ? const Color(0xFFF59E0B)
                  : activeType == NearbyPlaceType.pharmacies
                  ? const Color(0xFF2EAD74)
                  : activeType == NearbyPlaceType.washrooms
                  ? const Color(0xFF2FB79E)
                  : activeType == NearbyPlaceType.policeStations
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE45858),
              loading: true,
            )
          else if (nearbyState.activeType != null && nearbyState.places.isEmpty)
            NearbyStatusPanel(
              icon: Icons.search_off_rounded,
              title: l10n.t('noNearbyPlaces'),
              tone: const Color(0xFF8E7CF4),
            )
          else if (nearbyState.places.isNotEmpty)
            Column(
              children: nearbyState.places.take(8).map((place) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NearbyResultCard(
                    place: place,
                    onTap: () => onOpenPlace(context, place),
                  ),
                );
              }).toList(),
            )
          else
            NearbyStatusPanel(
              icon: Icons.touch_app_rounded,
              title: l10n.t('tapToLoadNearby'),
              tone: const Color(0xFF3B82F6),
            ),
        ],
      ),
    );
  }
}
