import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/calculations.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/donut_chart.dart';
import '../widgets/add_liability_sheet.dart';
import 'liability_detail_screen.dart';
import 'surplus_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final d = appState.data;
    final score = Calculations.healthScore(d);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text('Home', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        StatCard(label: 'Total debt', value: '₹${Calculations.totalDebt(d).round()}'),
        Row(children: [
          Expanded(child: StatCard(label: 'Available cash', value: '₹${Calculations.availableCash(d).round()}')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'Safe to spend', value: '₹${Calculations.safeToSpend(d).round()}', valueColor: AppColors.success)),
        ]),
        StatCard(
          label: 'Debt health score',
          value: '$score / 100',
          trailing: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFEAEEF1),
                color: score > 65 ? AppColors.success : (score > 40 ? AppColors.warning : AppColors.danger),
              ),
            ),
          ),
        ),
        StatCard(label: 'AI recommendation', value: Calculations.topAiSuggestion(d), ai: true),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Debt breakdown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Center(child: DonutChart(liabilities: d.liabilities)),
              ],
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('YOUR LIABILITIES', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: .5)),
            TextButton.icon(
              onPressed: () => _showLoanTypePicker(context),
              icon: const Icon(Icons.add_circle, size: 18),
              label: const Text('Add liability'),
              style: TextButton.styleFrom(foregroundColor: AppColors.brand, padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (d.liabilities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No liabilities added yet.', style: TextStyle(color: AppColors.textMuted))),
          )
        else
          ...d.liabilities.map((l) {
            final pct = l.percentPaidOff;
            final barColor = pct >= 66 ? AppColors.success : (pct >= 33 ? AppColors.warning : AppColors.brand);
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiabilityDetailScreen(liabilityId: l.id))),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          Text('${l.lender} · ${l.rate}%', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                        ]),
                        Text('₹${l.outstanding.round()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: const Color(0xFFEAEEF1), color: barColor),
                    ),
                    const SizedBox(height: 4),
                    Text('${pct.round()}% paid off', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurplusScreen())),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Add a surplus payment'),
        ),
      ],
    );
  }

  void _showLoanTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add a liability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            LoanTypeChipGrid(onPick: (type) {
              Navigator.pop(sheetContext);
              showAddLiabilitySheet(context, loanType: type);
            }),
          ],
        ),
      ),
    );
  }
}
