import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/calculations.dart';
import '../theme/app_theme.dart';

class SurplusScreen extends StatefulWidget {
  final String? preselectedLiabilityId;
  const SurplusScreen({super.key, this.preselectedLiabilityId});
  @override
  State<SurplusScreen> createState() => _SurplusScreenState();
}

class _SurplusScreenState extends State<SurplusScreen> {
  final _amount = TextEditingController();
  List<SurplusOption> _options = [];
  String? _selected;
  bool _applied = false;

  void _generate() {
    final amt = double.tryParse(_amount.text) ?? 0;
    final d = context.read<AppState>().data;
    setState(() {
      _options = Calculations.surplusOptions(d, amt);
      _selected = null;
      _applied = false;
    });
  }

  Future<void> _apply() async {
    final option = _options.firstWhere((o) => o.id == _selected);
    final appState = context.read<AppState>();
    option.apply(appState.data);
    await appState.save();
    setState(() => _applied = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surplus money')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("Got a bonus, incentive, refund or gift? Tell us how much, and we'll suggest where it should go.",
                style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Extra amount', hintText: '15000'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: _generate, child: const Text('Get AI suggestions')),
            const SizedBox(height: 18),
            ..._options.map((o) => InkWell(
                  onTap: () => setState(() => _selected = o.id),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _selected == o.id ? AppColors.brand : AppColors.border, width: _selected == o.id ? 1.5 : 1),
                      color: _selected == o.id ? const Color(0xFFF2F6FA) : Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        const SizedBox(height: 6),
                        Text(o.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )),
            if (_selected != null && !_applied)
              ElevatedButton(onPressed: _apply, child: const Text('Apply this option')),
            if (_applied)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFF1E0AC))),
                child: const Text('Done — your numbers are updated. Check your dashboard.', style: TextStyle(color: Color(0xFF5B4A14), fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
