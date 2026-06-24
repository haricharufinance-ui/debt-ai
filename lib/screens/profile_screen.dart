import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().data;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: ListView(
        children: [
          const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _row('Mobile number', d.phone ?? '—'),
          _row('Monthly salary', '₹${d.income.salary.round()}'),
          _row('Other income', '₹${d.income.other.round()}'),
          _row('Salary date', '${d.income.salaryDate} of every month'),
          const SizedBox(height: 14),
          const Text('SECURITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
          _row('OTP-only login', 'ON', good: true),
          _row('Bank password storage', 'NEVER', good: false),
          _row('UPI PIN collection', 'NEVER', good: false),
          _row('Data storage', 'Local file on this device', good: true),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await context.read<AppState>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              }
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v, {bool? good}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          if (good == null)
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: good ? const Color(0xFFE8F7EC) : const Color(0xFFFDF4F4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: good ? AppColors.success : AppColors.danger)),
            ),
        ],
      ),
    );
  }
}
