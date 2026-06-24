import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool ai;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.ai = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ai ? AppColors.goldSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ai ? const Color(0xFFF1E0AC) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ai ? const Color(0xFF7C5800) : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: ai ? 13.5 : 22,
              fontWeight: ai ? FontWeight.w600 : FontWeight.w800,
              color: ai ? const Color(0xFF5B4A14) : (valueColor ?? AppColors.text),
              height: 1.4,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
