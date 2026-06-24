import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/liability.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Call this from anywhere (onboarding OR the Home screen) to add a loan.
/// This is the answer to "adding a new loan isn't available on Home" -
/// it's now just one shared sheet, reachable from both places.
Future<void> showAddLiabilitySheet(BuildContext context, {required String loanType}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddLiabilitySheet(loanType: loanType),
  );
}

class _AddLiabilitySheet extends StatefulWidget {
  final String loanType;
  const _AddLiabilitySheet({required this.loanType});

  @override
  State<_AddLiabilitySheet> createState() => _AddLiabilitySheetState();
}

class _AddLiabilitySheetState extends State<_AddLiabilitySheet> {
  final _lender = TextEditingController();
  final _original = TextEditingController();
  final _outstanding = TextEditingController();
  final _rate = TextEditingController();
  final _emi = TextEditingController();
  final _dueDate = TextEditingController();
  final _notes = TextEditingController();
  // Gold-loan-only
  final _goldWeight = TextEditingController();
  final _goldPurity = TextEditingController();
  final _renewalDate = TextEditingController();
  final _auctionDate = TextEditingController();
  final _branch = TextEditingController();
  String _status = 'Active';

  bool get isGold => widget.loanType == 'Gold Loan';

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 18,
        bottom: 18 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add ${widget.loanType}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            _field('Lender name', _lender, hint: 'e.g. Muthoot Finance'),
            Row(children: [
              Expanded(child: _field('Original amount', _original, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('Outstanding', _outstanding, keyboardType: TextInputType.number)),
            ]),
            Row(children: [
              Expanded(child: _field('Interest rate %', _rate, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('EMI', _emi, keyboardType: TextInputType.number)),
            ]),
            _field('Due date (YYYY-MM-DD)', _dueDate, hint: '2026-07-05'),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Active', 'Overdue', 'Closed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? 'Active'),
            ),
            if (isGold) ...[
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: _field('Gold weight (g)', _goldWeight, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _field('Purity', _goldPurity, hint: '22K')),
              ]),
              _field('Renewal date', _renewalDate, hint: '2026-12-01'),
              _field('Auction date', _auctionDate, hint: '2027-03-01'),
              _field('Branch name', _branch, hint: 'e.g. Anna Nagar branch'),
            ],
            _field('Notes (optional)', _notes),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final liability = Liability(
                  id: appState.newId(),
                  type: widget.loanType,
                  lender: _lender.text.isEmpty ? '${widget.loanType} Lender' : _lender.text,
                  original: double.tryParse(_original.text) ?? 0,
                  outstanding: double.tryParse(_outstanding.text) ?? double.tryParse(_original.text) ?? 0,
                  rate: double.tryParse(_rate.text) ?? 0,
                  emi: double.tryParse(_emi.text) ?? 0,
                  dueDate: _dueDate.text.isEmpty ? null : _dueDate.text,
                  status: _status,
                  notes: _notes.text.isEmpty ? null : _notes.text,
                  goldWeightGrams: isGold ? double.tryParse(_goldWeight.text) : null,
                  goldPurity: isGold && _goldPurity.text.isNotEmpty ? _goldPurity.text : null,
                  renewalDate: isGold && _renewalDate.text.isNotEmpty ? _renewalDate.text : null,
                  auctionDate: isGold && _auctionDate.text.isNotEmpty ? _auctionDate.text : null,
                  branchName: isGold && _branch.text.isNotEmpty ? _branch.text : null,
                );
                await appState.addLiability(liability);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add liability'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

/// Chip grid used to pick a loan type before opening the sheet above.
/// Used on both the onboarding screen and the Home screen's "+ Add liability".
class LoanTypeChipGrid extends StatelessWidget {
  final void Function(String type) onPick;
  const LoanTypeChipGrid({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kLoanTypes.map((t) {
        return ActionChip(
          label: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          onPressed: () => onPick(t),
        );
      }).toList(),
    );
  }
}
