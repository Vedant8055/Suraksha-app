import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Circular refresh control for community alerts (same visuals/behavior).
class CommunityAlertsRefreshButton extends StatefulWidget {
  const CommunityAlertsRefreshButton({
    super.key,
    required this.isLight,
    required this.canRefresh,
    required this.isRefreshing,
    required this.shouldEmphasizeRefresh,
    required this.onPressed,
  });

  final bool isLight;
  final bool canRefresh;
  final bool isRefreshing;
  final bool shouldEmphasizeRefresh;
  final VoidCallback onPressed;

  @override
  State<CommunityAlertsRefreshButton> createState() =>
      _CommunityAlertsRefreshButtonState();
}

class _CommunityAlertsRefreshButtonState
    extends State<CommunityAlertsRefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  Future<void> _handleTap() async {
    if (!widget.canRefresh && !widget.isRefreshing) return;
    unawaited(_controller.forward(from: 0));
    if (widget.canRefresh && !widget.isRefreshing) {
      widget.onPressed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.canRefresh
        ? const [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF0F172A)]
        : [
            const Color(0xFFBFD1E8).withValues(alpha: 0.8),
            const Color(0xFF7FA0C8).withValues(alpha: 0.9),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: widget.shouldEmphasizeRefresh && !widget.isRefreshing
                  ? const Color(
                      0xFFF3B13E,
                    ).withValues(alpha: widget.isLight ? 0.64 : 0.5)
                  : Colors.white.withValues(alpha: 0.18),
              width: widget.shouldEmphasizeRefresh && !widget.isRefreshing
                  ? 2
                  : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.shouldEmphasizeRefresh && !widget.isRefreshing
                    ? const Color(
                        0xFFF3B13E,
                      ).withValues(alpha: widget.isLight ? 0.42 : 0.28)
                    : const Color(
                        0xFF3B82F6,
                      ).withValues(alpha: widget.isLight ? 0.30 : 0.22),
                blurRadius:
                    widget.shouldEmphasizeRefresh && !widget.isRefreshing
                    ? 28
                    : 18,
                spreadRadius:
                    widget.shouldEmphasizeRefresh && !widget.isRefreshing
                    ? 2
                    : 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: widget.isLight ? 0.42 : 0.08,
                ),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = Curves.easeInOut.transform(_controller.value);
              final turns = progress;
              final scale =
                  1 + (0.08 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0));
              return Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: turns * 2 * math.pi,
                  child: child,
                ),
              );
            },
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Icon(
                    Icons.refresh_rounded,
                    size: 28,
                    color: Colors.white.withValues(
                      alpha: widget.isRefreshing ? 0.88 : 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick-action card with press/pop animation (same visuals/behavior).
class PoppingActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double width;
  final VoidCallback? onTap;

  const PoppingActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.width,
    required this.onTap,
  });

  @override
  State<PoppingActionCard> createState() => _PoppingActionCardState();
}

class _PoppingActionCardState extends State<PoppingActionCard> {
  bool _pressed = false;
  bool _popped = false;

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;

    setState(() {
      _pressed = false;
      _popped = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 135));
    if (!mounted) return;

    setState(() => _popped = false);
    await Future<void>.delayed(const Duration(milliseconds: 55));
    if (!mounted) return;

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF172235) : Colors.white;
    final mutedIconColor = isLight
        ? const Color(0xFF60708B)
        : Colors.white.withValues(alpha: 0.66);
    final scale = _pressed ? 0.96 : (_popped ? 1.07 : 1.0);
    final lift = _popped ? -5.0 : (_pressed ? 2.0 : 0.0);
    final safeWidth = widget.width.clamp(0.0, double.infinity);
    final compact = safeWidth < 176;
    final horizontalPadding = compact ? 12.0 : 16.0;
    final iconBoxSize = compact ? 42.0 : 46.0;
    final labelFontSize = compact ? 13.5 : 15.0;
    final gap = compact ? 10.0 : 13.0;
    final arrowSize = compact ? 17.0 : 19.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 165),
        curve: Curves.easeOutBack,
        child: AnimatedSlide(
          offset: Offset(0, lift / 100),
          duration: const Duration(milliseconds: 165),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            width: safeWidth,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isLight
                      ? Color.lerp(Colors.white, widget.color, 0.08)!
                      : Color.lerp(AppTheme.cardColor, widget.color, 0.18)!,
                  isLight
                      ? Color.lerp(const Color(0xFFF8FBFF), widget.color, 0.16)!
                      : Color.lerp(
                          const Color(0xFF0C182D),
                          widget.color,
                          0.26,
                        )!,
                  isLight
                      ? Color.lerp(
                          const Color(0xFFF2F6FF),
                          widget.color,
                          _popped ? 0.22 : 0.13,
                        )!
                      : Color.lerp(
                          const Color(0xFF071121),
                          widget.color,
                          _popped ? 0.34 : 0.22,
                        )!,
                ],
                stops: const [0.0, 0.58, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _popped
                    ? widget.color.withValues(alpha: isLight ? 0.42 : 0.48)
                    : widget.color.withValues(alpha: isLight ? 0.20 : 0.26),
                width: _popped ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: isLight
                        ? (_popped ? 0.22 : 0.12)
                        : (_popped ? 0.30 : 0.18),
                  ),
                  blurRadius: _popped ? 24 : 14,
                  spreadRadius: _popped ? 1 : 0,
                  offset: Offset(0, _popped ? 11 : 7),
                ),
                BoxShadow(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.65)
                      : Colors.black.withValues(alpha: 0.24),
                  blurRadius: _popped ? 14 : 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -18,
                  top: -22,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    width: _popped ? 72 : 58,
                    height: _popped ? 72 : 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(
                        alpha: isLight ? 0.10 : 0.16,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 190),
                      curve: Curves.easeOutCubic,
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withValues(
                              alpha: isLight ? 0.22 : 0.28,
                            ),
                            widget.color.withValues(
                              alpha: _popped ? 0.34 : 0.16,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: compact ? 22 : 24,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: SizedBox(
                        height: 22,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: labelFontSize,
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    AnimatedRotation(
                      turns: _popped ? -0.08 : 0,
                      duration: const Duration(milliseconds: 190),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: arrowSize,
                        color: _popped ? widget.color : mutedIconColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Press/pop wrapper used around community alert cards.
class PoppingAlertCard extends StatefulWidget {
  const PoppingAlertCard({super.key, required this.child});

  final Widget child;

  @override
  State<PoppingAlertCard> createState() => _PoppingAlertCardState();
}

class _PoppingAlertCardState extends State<PoppingAlertCard> {
  bool _pressed = false;
  bool _popped = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    if (!pressed) {
      unawaited(_pop());
    }
    setState(() => _pressed = pressed);
  }

  Future<void> _pop() async {
    setState(() => _popped = true);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _popped = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scale = _pressed ? 0.94 : (_popped ? 1.06 : 1.0);
    final lift = _pressed ? 2.0 : (_popped ? -4.0 : 0.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        scale: scale,
        child: Transform.translate(
          offset: Offset(0, lift),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _popped ? 0.02 : 0.08),
                  blurRadius: _popped ? 10 : 16,
                  offset: Offset(0, _popped ? 2 : 7),
                ),
                BoxShadow(
                  color: isLight
                      ? const Color(
                          0xFF3B82F6,
                        ).withValues(alpha: _popped ? 0.18 : 0.06)
                      : const Color(
                          0xFF2ED6C5,
                        ).withValues(alpha: _popped ? 0.16 : 0.04),
                  blurRadius: _popped ? 18 : 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Soft gradient backdrop behind the dashboard.
class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? const [Color(0xFFF8FBFF), Color(0xFFF3F7FD), Color(0xFFEFF4FA)]
              : const [Colors.black, Color(0xFF07101F), Color(0xFF050A14)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -100,
            child: _glowCircle(
              isLight ? const Color(0xFFBFD7FF) : const Color(0xFF133B5F),
              280,
              opacity: isLight ? 0.34 : 0.16,
            ),
          ),
          Positioned(
            right: -110,
            top: 100,
            child: _glowCircle(
              isLight ? const Color(0xFFCCF4E8) : const Color(0xFF2A1A43),
              240,
              opacity: isLight ? 0.26 : 0.12,
            ),
          ),
          Positioned(
            bottom: -160,
            left: -40,
            child: _glowCircle(
              isLight ? const Color(0xFFF8DCE8) : const Color(0xFF0E2A48),
              300,
              opacity: isLight ? 0.24 : 0.10,
            ),
          ),
          Positioned(
            top: 180,
            left: 36,
            right: 36,
            child: IgnorePointer(
              child: Opacity(
                opacity: isLight ? 0.15 : 0.06,
                child: CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _SoftWavePainter(
                    color: isLight
                        ? const Color(0xFFB3C7E3)
                        : const Color(0xFF29405F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(Color color, double size, {double opacity = 0.14}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.8),
            blurRadius: 60,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _SoftWavePainter extends CustomPainter {
  _SoftWavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.34);
    path.cubicTo(
      size.width * 0.18,
      size.height * 0.12,
      size.width * 0.36,
      size.height * 0.55,
      size.width * 0.52,
      size.height * 0.36,
    );
    path.cubicTo(
      size.width * 0.66,
      size.height * 0.20,
      size.width * 0.80,
      size.height * 0.58,
      size.width,
      size.height * 0.32,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full-screen location gate shown when GPS permission/fix is unavailable.
class DashboardLocationRequiredView extends StatelessWidget {
  const DashboardLocationRequiredView({
    super.key,
    required this.statusMessage,
    required this.onRetry,
  });

  final String statusMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 106,
                  height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLight
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFF1F2937),
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    size: 56,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.t('locationRequiredTitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF172235) : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('locationRequiredMessage'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF4B5563)
                        : Colors.white.withValues(alpha: 0.72),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.localizeStatusMessage(statusMessage),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF475569)
                        : Colors.white.withValues(alpha: 0.62),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.t('locationAutoRefreshMessage'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF64748B)
                        : Colors.white.withValues(alpha: 0.62),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.t('retryLocation')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
