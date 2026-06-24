import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'onboarding_income_screen.dart';
import 'root_shell.dart';

/// NOTE: there's no real OTP backend wired up yet (no server in this build).
/// Any 4 digits work here. Swap-to-real-OTP-later: call Firebase Phone Auth
/// or an SMS-OTP provider (MSG91/Twilio) from `_verify()` instead.
class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());

  Future<void> _verify() async {
    final appState = context.read<AppState>();
    await appState.setPhone(widget.phone);
    if (!mounted) return;
    if (appState.data.onboardingComplete) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RootShell()), (r) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingIncomeScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify your number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Enter any 4 digits — demo build, no real OTP sent to ${widget.phone}.',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Row(
                children: List.generate(4, (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          controller: _controllers[i],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(counterText: ''),
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 3) FocusScope.of(context).nextFocus();
                          },
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 22),
              ElevatedButton(onPressed: _verify, child: const Text('Verify & continue')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('← Use a different number')),
            ],
          ),
        ),
      ),
    );
  }
}
