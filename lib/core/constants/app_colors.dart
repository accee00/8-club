import 'package:flutter/material.dart';

class AppColors {
  // Text Colors
  static const Color text1 = Color(0xFFFFFFFF); // 100%
  static const Color text2 = Color(0xFFFFFFFF); // 72%
  static const Color text3 = Color(0xFFFFFFFF); // 48%
  static const Color text4 = Color(0xFFFFFFFF); // 24%
  static const Color text5 = Color(0xFFFFFFFF); // 24%

  // Base Colors
  static const Color base2First = Color(0xFF101010); // 100%
  static const Color base2Second = Color(0xFF151515); // 100%

  // Surface Colors
  static const Color surfaceWhite1 = Color(0xFFFFFFFF); // 2%
  static const Color surfaceWhite2 = Color(0xFFFFFFFF); // 5%
  static const Color surfaceBlack1 = Color(0xFF101010); // 90%
  static const Color surfaceBlack2 = Color(0xFF101010); // 70%
  static const Color surfaceBlack3 = Color(0xFF101010); // 50%

  // Accent Colors
  static const Color primaryAccent = Color(0xFF9196FF); // 100%
  static const Color secondaryAccent = Color(0xFF5964FF); // 100%
  static const Color positive = Color(0xFFFE5BDB); // 100%
  static const Color negative = Color(0xFFC22743); // 100%

  // Border Colors
  static const Color border1 = Color(0xFFFFFFFF); // 8%
  static const Color border2 = Color(0xFFFFFFFF); // 16%
  static const Color border3 = Color(0xFFFFFFFF); // 24%

  // Text colors
  static Color get text1Color => text1;
  static Color get text2Color => text2.withAlpha((255 * 0.72).round());
  static Color get text3Color => text3.withAlpha((255 * 0.48).round());
  static Color get text4Color => text4.withAlpha((255 * 0.24).round());
  static Color get text5Color => text5.withAlpha((255 * 0.16).round());

  // Surface colors
  static Color get surfaceWhite1Color =>
      surfaceWhite1.withAlpha((255 * 0.02).round());
  static Color get surfaceWhite2Color =>
      surfaceWhite2.withAlpha((255 * 0.05).round());
  static Color get surfaceBlack1Color =>
      surfaceBlack1.withAlpha((255 * 0.90).round());
  static Color get surfaceBlack2Color =>
      surfaceBlack2.withAlpha((255 * 0.70).round());
  static Color get surfaceBlack3Color =>
      surfaceBlack3.withAlpha((255 * 0.50).round());

  // Border colors
  static Color get border1Color => border1.withAlpha((255 * 0.08).round());
  static Color get border2Color => border2.withAlpha((255 * 0.16).round());
  static Color get border3Color => border3.withAlpha((255 * 0.24).round());
}
