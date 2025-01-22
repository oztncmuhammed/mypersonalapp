import 'package:flutter/material.dart';

TextTheme buildTextTheme(double fontSize) {
  return TextTheme(
    bodyLarge: TextStyle(fontSize: fontSize + 2),
    bodyMedium: TextStyle(fontSize: fontSize),
    bodySmall: TextStyle(fontSize: fontSize - 2),
    titleLarge: TextStyle(fontSize: fontSize + 6, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(fontSize: fontSize + 2),
    labelMedium: TextStyle(fontSize: fontSize),
    labelSmall: TextStyle(fontSize: fontSize - 2),
    displaySmall: TextStyle(fontSize: fontSize),
    displayMedium: TextStyle(fontSize: fontSize + 2),
    displayLarge: TextStyle(fontSize: fontSize + 4),
    headlineMedium: TextStyle(fontSize: fontSize + 4),
    headlineSmall: TextStyle(fontSize: fontSize + 2),
  );
}
