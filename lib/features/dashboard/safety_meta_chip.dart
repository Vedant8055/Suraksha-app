import 'package:flutter/material.dart';

/// Small pill used to surface metadata (updated-at, data source, confidence)
/// on the safety intelligence card (Phase 2 extract).
class SafetyMetaChip extends StatelessWidget {
  const SafetyMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isLight,
  });

  final IconData icon;
  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isLight ? const Color(0xFF475569) : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isLight ? const Color(0xFF475569) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
