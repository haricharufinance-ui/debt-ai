import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/liability.dart';
import '../theme/app_theme.dart';

class DonutChart extends StatelessWidget {
  final List<Liability> liabilities;
  const DonutChart({super.key, required this.liabilities});

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final l in liabilities) {
      totals[l.type] = (totals[l.type] ?? 0) + l.outstanding;
    }
    final total = totals.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          width: 148,
          height: 148,
          child: total <= 0
              ? Container(
                  decoration: const BoxDecoration(color: Color(0xFFEAEEF1), shape: BoxShape.circle),
                  child: const Center(
                    child: Text('₹0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(148, 148),
                      painter: _DonutPainter(totals: totals, total: total),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${total.round()}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'JetBrainsMono'),
                        ),
                        const SizedBox(height: 2),
                        const Text('total debt', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        if (total > 0)
          ...((totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).map((e) {
            final pct = (e.value / total * 100).round();
            final color = AppColors.liabilityTypeColors[e.key] ?? const Color(0xFF94A3B8);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(e.key, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                  Text('₹${e.value.round()} · $pct%', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          })),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> totals;
  final double total;
  _DonutPainter({required this.totals, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(0);
    const strokeWidth = 22.0;
    double startAngle = -math.pi / 2;

    for (final entry in totals.entries) {
      final sweep = (entry.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = AppColors.liabilityTypeColors[entry.key] ?? const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.totals != totals || oldDelegate.total != total;
}
