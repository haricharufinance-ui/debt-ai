import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text('DebtZero AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
              const SizedBox(height: 34),
              const Text('Welcome back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Log in with your mobile number. No passwords, ever.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 26),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'Mobile number', hintText: '98765 43210', counterText: ''),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  if (_phone.text.trim().length < 6) return;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phone: _phone.text.trim())));
                },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 14),
              const Text(
                'By continuing you agree to read-only SMS & notification access for transaction detection.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
