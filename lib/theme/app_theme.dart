import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const text = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const brand = Color(0xFF1E3A5F);
  static const gold = Color(0xFFB8860B);
  static const goldSoft = Color(0xFFFDF3DC);

  static const Map<String, Color> liabilityTypeColors = {
    'Gold Loan': gold,
    'Personal Loan': brand,
    'Home Loan': Color(0xFF0D9488),
    'Vehicle Loan': Color(0xFF7C3AED),
    'Credit Card': danger,
    'Friends/Family Loan': Color(0xFF0EA5E9),
    'Chit Fund': warning,
  };
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      background: AppColors.bg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
