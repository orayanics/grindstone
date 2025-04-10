import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class GrindstoneTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentPurple,
      scaffoldBackgroundColor: white,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
          backgroundColor: white,
          iconTheme: IconThemeData(color: black),
          titleTextStyle: TextStyle(color: black, fontSize: 20),
          elevation: 2.0,
          centerTitle: true,
          shadowColor: Colors.black45,
          surfaceTintColor: Colors.transparent),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentPurple,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
