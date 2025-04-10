import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class GrindstoneTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentPurple,
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        iconTheme: IconThemeData(color: black),
        titleTextStyle: TextStyle(color: black, fontSize: 20),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentPurple,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
