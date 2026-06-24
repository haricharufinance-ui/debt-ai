import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_income_screen.dart';
import 'screens/root_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(LocalFileStorageService())..init(),
      child: const DebtZeroApp(),
    ),
  );
}

class DebtZeroApp extends StatelessWidget {
  const DebtZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebtZero AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _StartupGate(),
    );
  }
}

/// Waits for the local JSON file to load, then routes to the right screen:
/// no phone saved -> Login, phone but onboarding incomplete -> Onboarding,
/// otherwise -> the main app (Home/Transactions/AI Coach/Profile).
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (appState.data.phone == null) return const LoginScreen();
    if (!appState.data.onboardingComplete) return const OnboardingIncomeScreen();
    return const RootShell();
  }
}
