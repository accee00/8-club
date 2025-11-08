import 'package:eightclub/core/constants/app_colors.dart';
import 'package:eightclub/core/constants/app_typo.dart';
import 'package:flutter/material.dart';

// Theme Data
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
    useSystemColors: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColors.primaryAccent,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.base2Second,
      error: AppColors.negative,
      onSurface: AppColors.text1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      hintStyle: AppTypography.h3Regular.copyWith(color: AppColors.text5Color),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryAccent),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    textTheme: TextTheme(
      // Headings
      displayLarge: AppTypography.h1Bold.copyWith(color: AppColors.text1),
      displayMedium: AppTypography.h2Bold.copyWith(color: AppColors.text1),
      displaySmall: AppTypography.h3Bold.copyWith(color: AppColors.text1),

      // Headlines
      headlineLarge: AppTypography.h1Regular.copyWith(color: AppColors.text1),
      headlineMedium: AppTypography.h2Regular.copyWith(color: AppColors.text1),
      headlineSmall: AppTypography.h3Regular.copyWith(color: AppColors.text1),

      // Body
      bodyLarge: AppTypography.b1Regular.copyWith(color: AppColors.text1),
      bodyMedium: AppTypography.b2Regular.copyWith(color: AppColors.text2Color),
      bodySmall: AppTypography.s1Regular.copyWith(color: AppColors.text3Color),

      // Title
      titleLarge: AppTypography.b1Bold.copyWith(color: AppColors.text1),
      titleMedium: AppTypography.b2Bold.copyWith(color: AppColors.text1),
      titleSmall: AppTypography.s1Bold.copyWith(color: AppColors.text1),

      // Label
      labelLarge: AppTypography.b2Regular.copyWith(color: AppColors.text2Color),
      labelMedium: AppTypography.s1Regular.copyWith(
        color: AppColors.text3Color,
      ),
      labelSmall: AppTypography.s2.copyWith(color: AppColors.text4Color),
    ),
  );
}
