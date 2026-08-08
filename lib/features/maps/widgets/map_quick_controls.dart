import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/accessibility/accessibility.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Vertical stack of round quick-action controls floating over the map
/// (my location, list view, traffic, layers, toilets, live safety).
class MapQuickControls extends StatelessWidget {
  const MapQuickControls({
    super.key,
    required this.isSearchOpen,
    required this.followMe,
    required this.showPlacesList,
    required this.trafficEnabled,
    required this.onMyLocationTap,
    required this.onTogglePlacesList,
    required this.onToggleTraffic,
    required this.onLayersTap,
    required this.onToiletsTap,
    required this.onSafetyTap,
  });

  final bool isSearchOpen;
  final bool followMe;
  final bool showPlacesList;
  final bool trafficEnabled;
  final VoidCallback onMyLocationTap;
  final VoidCallback onTogglePlacesList;
  final VoidCallback onToggleTraffic;
  final VoidCallback onLayersTap;
  final VoidCallback onToiletsTap;
  final VoidCallback onSafetyTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return Positioned(
      right: 16,
      top: isLandscape ? 56 : (isSearchOpen ? 82 : 92),
      child: Column(
        children: <Widget>[
          MapCircleControl(
            icon: followMe ? Icons.gps_fixed : Icons.gps_not_fixed,
            semanticLabel: l10n.t('myLocation'),
            onTap: onMyLocationTap,
          ),
          SizedBox(height: isLandscape ? 6 : 10),
          MapCircleControl(
            icon: showPlacesList ? Icons.map_rounded : Icons.list_alt_rounded,
            onTap: onTogglePlacesList,
            semanticLabel: l10n.t(showPlacesList ? 'mapView' : 'listView'),
          ),
          SizedBox(height: isLandscape ? 6 : 10),
          MapCircleControl(
            icon: trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
            semanticLabel: l10n.t('mapTraffic'),
            onTap: onToggleTraffic,
          ),
          SizedBox(height: isLandscape ? 6 : 10),
          MapCircleControl(
            icon: Icons.layers,
            semanticLabel: l10n.t('mapLayers'),
            onTap: onLayersTap,
          ),
          SizedBox(height: isLandscape ? 6 : 10),
          MapCircleControl(
            icon: Icons.wc_rounded,
            semanticLabel: l10n.t('nearbyCleanToilets'),
            onTap: onToiletsTap,
          ),
          SizedBox(height: isLandscape ? 6 : 10),
          MapCircleControl(
            icon: Icons.safety_check,
            semanticLabel: l10n.t('liveSafetyMapTitle'),
            onTap: onSafetyTap,
          ),
        ],
      ),
    );
  }
}

/// Single round floating control button used by [MapQuickControls].
class MapCircleControl extends StatelessWidget {
  const MapCircleControl({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppTheme.cardColor,
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: Accessibility.minTouchTarget,
              minHeight: Accessibility.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
