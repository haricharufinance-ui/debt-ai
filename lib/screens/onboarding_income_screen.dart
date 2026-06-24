import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'onboarding_liabilities_screen.dart';

class OnboardingIncomeScreen extends StatefulWidget {
  const OnboardingIncomeScreen({super.key});
  @override
  State<OnboardingIncomeScreen> createState() => _OnboardingIncomeScreenState();
}

class _OnboardingIncomeScreenState extends State<OnboardingIncomeScreen> {
  final _salary = TextEditingController(text: '65000');
  final _other = TextEditingController(text: '5000');
  final _date = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STEP 1 OF 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Your monthly income', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text("This is how we calculate what's safe to spend after your EMIs.",
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              TextField(controller: _salary, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Salary')),
              const SizedBox(height: 14),
              TextField(controller: _other, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Other income')),
              const SizedBox(height: 14),
              TextField(controller: _date, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Salary date (day of month)')),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AppState>().saveIncome(
                        salary: double.tryParse(_salary.text) ?? 0,
                        other: double.tryParse(_other.text) ?? 0,
                        salaryDate: int.tryParse(_date.text) ?? 1,
                      );
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingLiabilitiesScreen()));
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
