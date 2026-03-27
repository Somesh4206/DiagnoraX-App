import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors — exact match from web app
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF111111);
  static const Color neonGreen = Color(0xFF00FFAA);
  static const Color neonGreenDim = Color(0x1A00FFAA);
  static const Color neonGreenBorder = Color(0x3300FFAA);
  static const Color neonGlow = Color(0x4D00FFAA);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color borderColor = Color(0x0DFFFFFF);
  static const Color borderColorLight = Color(0x1AFFFFFF);

  // Severity Colors
  static const Color severityLow = Color(0xFF4ADE80);
  static const Color severityMedium = Color(0xFFFBBF24);
  static const Color severityHigh = Color(0xFFFB923C);
  static const Color severityCritical = Color(0xFFEF4444);

  // Feature Colors
  static const Color blueAccent = Color(0xFF60A5FA);
  static const Color purpleAccent = Color(0xFFA78BFA);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color yellowAccent = Color(0xFFFBBF24);
  static const Color emeraldAccent = Color(0xFF34D399);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonGreen,
        background: background,
        surface: surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0DFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonGreenBorder, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonGreen,
          side: const BorderSide(color: neonGreen, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x0DFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: neonGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Neon Glow Box Decoration
BoxDecoration neonCardDecoration({bool highlight = false}) {
  return BoxDecoration(
    color: const Color(0x0DFFFFFF),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: highlight
          ? AppTheme.neonGreenBorder
          : AppTheme.borderColor,
    ),
    boxShadow: highlight
        ? [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ]
        : null,
  );
}

// Neon glow shadow
List<BoxShadow> neonGlowShadow({double opacity = 0.3}) {
  return [
    BoxShadow(
      color: AppTheme.neonGreen.withOpacity(opacity),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];
}
