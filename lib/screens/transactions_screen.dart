import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _syncing = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final added = await context.read<AppState>().syncSms();
    setState(() => _syncing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(added > 0 ? 'Synced $added new transaction(s) from SMS.' : 'No new transactions found (or SMS permission was denied).')),
    );
  }

  final _categories = const [
    'Food', 'Travel', 'Medical', 'Shopping', 'Utilities', 'Subscriptions',
    'Gold Loan', 'Personal Loan', 'Home Loan', 'Vehicle Loan', 'Credit Card', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final txns = [...appState.data.transactions]..sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transactions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              IconButton(
                onPressed: _syncing ? null : _sync,
                icon: _syncing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
              ),
            ],
          ),
          const Text('Auto-detected from real SMS & UPI alerts on this device.', style: TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Expanded(
            child: txns.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(children: [
                        const Text('No transactions yet.', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        TextButton(onPressed: _sync, child: const Text('Sync from SMS now')),
                      ]),
                    ),
                  )
                : ListView.separated(
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) {
                      final t = txns[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.merchantRaw, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text('${t.date} · ${t.source}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  DropdownButton<String>(
                                    value: _categories.contains(t.category) ? t.category : 'Other',
                                    isDense: true,
                                    underline: const SizedBox(),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (v) {
                                      if (v != null) context.read<AppState>().correctTransactionCategory(t.id, v);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${t.direction.name == 'credit' ? '+' : '-'}₹${t.amount.round()}',
                              style: TextStyle(fontWeight: FontWeight.w700, color: t.direction.name == 'credit' ? AppColors.success : AppColors.text),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
