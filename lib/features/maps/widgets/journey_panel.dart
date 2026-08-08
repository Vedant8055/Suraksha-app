import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Draggable bottom panel showing the active/preview journey summary
/// (destination, progress, ETA) with start/stop and collapse controls.
class JourneyPanel extends StatelessWidget {
  const JourneyPanel({
    super.key,
    required this.isLight,
    required this.journeyActive,
    required this.journeyPanelCollapsed,
    required this.selectedDestinationName,
    required this.coveredDistanceMeters,
    required this.routeDistanceMeters,
    required this.remainingDistanceMeters,
    required this.remainingEtaSeconds,
    required this.onSetCollapsed,
    required this.onStartJourney,
    required this.onStopJourney,
  });

  final bool isLight;
  final bool journeyActive;
  final bool journeyPanelCollapsed;
  final String? selectedDestinationName;
  final double coveredDistanceMeters;
  final double? routeDistanceMeters;
  final double? remainingDistanceMeters;
  final int? remainingEtaSeconds;
  final ValueChanged<bool> onSetCollapsed;
  final VoidCallback onStartJourney;
  final VoidCallback onStopJourney;

  @override
  Widget build(BuildContext context) {
    final destinationName = selectedDestinationName ?? 'Selected destination';
    final remaining = remainingDistanceMeters;
    final eta = remainingEtaSeconds;
    final routeDistance = routeDistanceMeters;
    final compact = journeyPanelCollapsed;
    final progress = (routeDistance != null && routeDistance > 0)
        ? (coveredDistanceMeters / routeDistance).clamp(0.0, 1.0)
        : 0.0;
    final accentColor = journeyActive
        ? const Color(0xFF0F766E)
        : const Color(0xFF4A148C);
    final accentSoft = journeyActive
        ? const Color(0xFF14B8A6)
        : const Color(0xFF7C3AED);
    final topGradient = isLight
        ? [
            const Color(0xFFFFFFFF).withValues(alpha: 0.70),
            const Color(0xFFF8FBFF).withValues(alpha: 0.58),
            const Color(0xFFEEF4FF).withValues(alpha: 0.50),
          ]
        : [
            const Color(0xFF1A2337).withValues(alpha: 0.72),
            const Color(0xFF121B2D).withValues(alpha: 0.62),
            const Color(0xFF0A1221).withValues(alpha: 0.54),
          ];
    final statusPillGradient = journeyActive
        ? const [Color(0xFF0F766E), Color(0xFF14B8A6)]
        : const [Color(0xFF4A148C), Color(0xFF7C3AED)];
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 180) {
            onSetCollapsed(true);
          } else if (velocity < -180) {
            onSetCollapsed(false);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(
                16,
                compact ? 8 : 10,
                16,
                (compact ? 8 : 12) + safeBottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: topGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isLight
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.58)
                      : Colors.white.withValues(alpha: 0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isLight ? 0.10 : 0.26,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSetCollapsed(!journeyPanelCollapsed),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 2),
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isLight
                                  ? const Color(
                                      0xFFAFC1DE,
                                    ).withValues(alpha: 0.72)
                                  : Colors.white.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (compact) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  eta == null ? '--' : _formatDuration(eta),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLight
                                        ? const Color(0xFF172235)
                                        : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  remaining == null
                                      ? destinationName
                                      : 'Remaining ${_formatDistance(remaining)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLight
                                        ? const Color(0xFF60708B)
                                        : Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  destinationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLight
                                        ? const Color(0xFF8A98AE)
                                        : Colors.white54,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _journeyActionButton(
                            label: journeyActive ? 'Stop' : 'Start',
                            icon: journeyActive
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            onTap: journeyActive
                                ? onStopJourney
                                : onStartJourney,
                            isLight: isLight,
                            backgroundColor: journeyActive
                                ? const Color(0xFFDC2626)
                                : accentColor,
                          ),
                          const SizedBox(width: 8),
                          _journeyRoundButton(
                            icon: Icons.keyboard_arrow_up_rounded,
                            onTap: () => onSetCollapsed(!journeyPanelCollapsed),
                            isLight: isLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              routeDistance == null
                                  ? AppLocalizations.of(
                                      context,
                                    ).t('calculatingRoute')
                                  : '${_formatDistance(routeDistance)} total route',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF60708B)
                                    : Colors.white60,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF344256)
                                  : Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: statusPillGradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    journeyActive
                                        ? 'Live navigation'
                                        : 'Route preview',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  destinationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLight
                                        ? const Color(0xFF172235)
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  journeyActive
                                      ? AppLocalizations.of(
                                          context,
                                        ).t('followingYourRoute')
                                      : AppLocalizations.of(context).t(
                                          'readyWithDistanceAndEstimatedTravelTime',
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLight
                                        ? const Color(0xFF60708B)
                                        : Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              _journeyRoundButton(
                                icon: Icons.keyboard_arrow_down_rounded,
                                onTap: () =>
                                    onSetCollapsed(!journeyPanelCollapsed),
                                isLight: isLight,
                              ),
                              const SizedBox(height: 10),
                              _journeyActionButton(
                                label: AppLocalizations.of(
                                  context,
                                ).t(journeyActive ? 'stop' : 'start'),
                                icon: journeyActive
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                onTap: journeyActive
                                    ? onStopJourney
                                    : onStartJourney,
                                isLight: isLight,
                                backgroundColor: journeyActive
                                    ? const Color(0xFFDC2626)
                                    : accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: compact ? 8 : 7,
                        value: progress,
                        backgroundColor: isLight
                            ? const Color(0xFFDDE7F6).withValues(alpha: 0.48)
                            : Colors.white.withValues(alpha: 0.10),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          journeyActive ? accentSoft : accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!compact) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.route_rounded,
                            size: 15,
                            color: isLight
                                ? const Color(0xFF60708B)
                                : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              routeDistance == null
                                  ? AppLocalizations.of(
                                      context,
                                    ).t('calculatingRouteDistance')
                                  : '${_formatDistance(routeDistance)} total route',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF60708B)
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF344256)
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _journeyStat(
                              label: AppLocalizations.of(context).t('covered'),
                              value: _formatDistance(coveredDistanceMeters),
                              isLight: isLight,
                              icon: Icons.explore_rounded,
                              accent: const Color(0xFF14B8A6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _journeyStat(
                              label: AppLocalizations.of(
                                context,
                              ).t('remaining'),
                              value: remaining == null
                                  ? '--'
                                  : _formatDistance(remaining),
                              isLight: isLight,
                              icon: Icons.alt_route_rounded,
                              accent: accentSoft,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _journeyStat(
                              label: AppLocalizations.of(context).t('eta'),
                              value: eta == null ? '--' : _formatDuration(eta),
                              isLight: isLight,
                              icon: Icons.schedule_rounded,
                              accent: accentColor,
                              emphasizeValue: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _journeyActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLight,
    required Color backgroundColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _journeyRoundButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLight,
    bool filled = false,
    Color? fillColor,
  }) {
    return Material(
      color: filled
          ? (fillColor ?? AppTheme.primaryColor)
          : (isLight
                ? const Color(0xFFF6F9FF)
                : Colors.white.withValues(alpha: 0.06)),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 20,
            color: filled
                ? Colors.white
                : (isLight ? const Color(0xFF344256) : Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _journeyStat({
    required String label,
    required String value,
    required bool isLight,
    required IconData icon,
    required Color accent,
    bool emphasizeValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [
                  const Color(0xFFF8FBFF),
                  Color.lerp(const Color(0xFFF0F6FF), accent, 0.10)!,
                ]
              : [
                  Colors.white.withValues(alpha: 0.05),
                  accent.withValues(alpha: 0.12),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: isLight ? 0.18 : 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF65758F) : Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight ? const Color(0xFF172235) : Colors.white,
                fontSize: emphasizeValue ? 16 : 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(meters >= 10000 ? 0 : 1)} km';
  }
  return '${meters.round()} m';
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '<1 min';

  final minutes = (seconds / 60).round();
  if (minutes < 60) return '$minutes min';

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (remainingMinutes == 0) return '${hours}h';
  return '${hours}h ${remainingMinutes}m';
}
