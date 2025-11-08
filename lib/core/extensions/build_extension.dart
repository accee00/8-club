import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  ThemeData get themeData => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get size => MediaQuery.of(this).size;

  double get width => size.width;

  double get height => size.height;
}
