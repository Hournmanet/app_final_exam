import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_environment.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Colors.black;
  static const Color accent = Colors.black;
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color greyText = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);

  static ThemeData light(AppEnvironment env) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: greyText, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.black87,
      ),
    );
    return base;
  }

  static LinearGradient headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.white],
  );

  static Color envBadgeColor(AppEnvironment env) => switch (env) {
        AppEnvironment.dev => const Color(0xFF5C6BC0),
        AppEnvironment.uat => const Color(0xFFFF8F00),
        AppEnvironment.demo => const Color(0xFF8E24AA),
        AppEnvironment.production => Colors.black,
      };
}
