import 'package:flutter/material.dart';

/// Small accessibility helpers — prefer these over one-off MediaQuery checks.
class Accessibility {
  Accessibility._();

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Prefer the animated child when motion is allowed; otherwise return [child].
  static Widget motionAware({
    required BuildContext context,
    required Widget child,
    required Widget Function(Widget child) animate,
  }) {
    if (reduceMotion(context)) return child;
    return animate(child);
  }

  /// Minimum interactive size for custom hit targets (Material guideline).
  static const double minTouchTarget = 48;
}
