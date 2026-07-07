import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Full-screen dark gradient shell for login/signup (no white gaps at bottom).
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({super.key, required this.child});

  final Widget child;

  static const Color _gradientEnd = Color(0xFF1E1E2E);

  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: _gradientEnd,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        backgroundColor: _gradientEnd,
        resizeToAvoidBottomInset: true,
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.backgroundColor, _gradientEnd],
              ),
            ),
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}
