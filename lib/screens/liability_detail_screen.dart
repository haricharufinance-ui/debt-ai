import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import 'surplus_screen.dart';

class LiabilityDetailScreen extends StatelessWidget {
  final String liabilityId;
  const LiabilityDetailScreen({super.key, required this.liabilityId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = appState.data.liabilities.firstWhere((x) => x.id == liabilityId);
    final pct = l.percentPaidOff;
    final monthlySave = (l.outstanding * (l.rate / 100 / 12)).round();
    final extra = (l.outstanding * 0.05).clamp(0, 5000).round();

    return Scaffold(
      appBar: AppBar(title: Text(l.type)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StatCard(
            label: 'Outstanding',
            value: '₹${l.outstanding.round()}',
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: const Color(0xFFEAEEF1), color: AppColors.brand),
                ),
                const SizedBox(height: 4),
                Text('${pct.round()}% paid off', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Row(children: [
            Expanded(child: StatCard(label: 'Interest rate', value: '${l.rate}%')),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'EMI', value: '₹${l.emi.round()}')),
          ]),
          Row(children: [
            Expanded(child: StatCard(label: 'Due date', value: l.dueDate ?? '—')),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Lender', value: l.lender)),
          ]),
          if (l.type == 'Gold Loan') ...[
            Row(children: [
              Expanded(child: StatCard(label: 'Gold weight', value: l.goldWeightGrams != null ? '${l.goldWeightGrams}g' : '—')),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Purity', value: l.goldPurity ?? '—')),
            ]),
            Row(children: [
              Expanded(child: StatCard(label: 'Renewal date', value: l.renewalDate ?? '—')),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'Auction date', value: l.auctionDate ?? '—')),
            ]),
          ],
          StatCard(
            label: 'AI recommendation',
            value: 'Paying ₹$extra extra this month saves about ₹$monthlySave in interest and brings your closure date closer.',
            ai: true,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurplusScreen(preselectedLiabilityId: l.id))),
            child: const Text('Add a surplus payment'),
          ),
        ],
      ),
    );
  }
}
