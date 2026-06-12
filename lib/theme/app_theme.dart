import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,

      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    ),
  );
}