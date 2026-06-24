import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/add_liability_sheet.dart';
import 'root_shell.dart';

class OnboardingLiabilitiesScreen extends StatelessWidget {
  const OnboardingLiabilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final liabilities = appState.data.liabilities;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STEP 2 OF 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Add your liabilities', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Tap a loan type to add it. You can edit details anytime.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 18),
              LoanTypeChipGrid(onPick: (type) => showAddLiabilitySheet(context, loanType: type)),
              const SizedBox(height: 18),
              Expanded(
                child: liabilities.isEmpty
                    ? const Center(child: Text('No liabilities added yet.', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        itemCount: liabilities.length,
                        itemBuilder: (_, i) {
                          final l = liabilities[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.border)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(l.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                                  Text(l.lender, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                ]),
                                Text('₹${l.outstanding.round()}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: liabilities.isEmpty
                    ? null
                    : () async {
                        await appState.completeOnboarding();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RootShell()), (r) => false);
                        }
                      },
                child: const Text('Finish setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
