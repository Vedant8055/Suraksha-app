import 'dart:async';

import 'package:flutter/material.dart';

class BrandSplashGate extends StatefulWidget {
  const BrandSplashGate({
    super.key,
    required this.child,
    this.minimumDisplayDuration = const Duration(milliseconds: 1350),
  });

  final Widget child;
  final Duration minimumDisplayDuration;

  @override
  State<BrandSplashGate> createState() => _BrandSplashGateState();
}

class _BrandSplashGateState extends State<BrandSplashGate> {
  bool _showChild = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.minimumDisplayDuration, () {
      if (!mounted) return;
      setState(() => _showChild = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showChild ? widget.child : const _BrandSplashScreen(),
    );
  }
}

class _BrandSplashScreen extends StatelessWidget {
  const _BrandSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.12, -0.18),
            radius: 1.05,
            colors: [
              Color(0xFF172B49),
              Color(0xFF08111F),
              Color(0xFF02060D),
            ],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              left: -90,
              child: _glowBlob(const Color(0xFFEDB25A), 280, 0.18),
            ),
            Positioned(
              right: -110,
              bottom: 60,
              child: _glowBlob(const Color(0xFFE85A7A), 240, 0.12),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'brand-logo',
                    child: Image.asset(
                      'assets/images/brand_logo.png',
                      width: 210,
                      height: 210,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'SURAKSHA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Women safety, reimagined',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(Color color, double size, double opacity) {
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
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
