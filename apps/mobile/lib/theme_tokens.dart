import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Commercial-grade design tokens for Sharma Video Care.
/// Uses crisp neutral surfaces, tailored slate hierarchy, and optics brand orange.
class SvcColors {
  static const primary = Color(0xFFE86F1C);
  static const primaryDark = Color(0xFFC2570D);
  static const primarySoft = Color(0xFFFFF7ED);
  static const primaryBorder = Color(0xFFFFEDD5);

  // Modern 3-tier ink system (Slate palette)
  static const ink = Color(0xFF0F172A); // Slate 900 - Primary readable text
  static const muted = Color(0xFF64748B); // Slate 500 - Secondary text & labels
  static const subtle = Color(0xFF94A3B8); // Slate 400 - Captions, icons, placeholders

  // Modern clean surface layers
  static const canvas = Color(0xFFF8FAFC); // Slate 50 - Crisp modern app background
  static const surface = Color(0xFFFFFFFF); // Pure white cards & navigation
  static const surfaceSubtle = Color(0xFFF1F5F9); // Slate 100 - Secondary fills

  // Refined borders
  static const border = Color(0xFFE2E8F0); // Slate 200 - Clean structural borders
  static const borderSubtle = Color(0xFFF1F5F9); // Slate 100 - Divider lines

  // Semantic status colors
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
}

class SvcShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

class SvcTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SvcColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SvcColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: SvcColors.primary,
        onPrimary: Colors.white,
        surface: SvcColors.surface,
        onSurface: SvcColors.ink,
      ),
    );

    final interTextTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: interTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: SvcColors.ink),
        displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: SvcColors.ink),
        headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: SvcColors.ink),
        headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.15, color: SvcColors.ink),
        headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: SvcColors.ink),
        titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: SvcColors.ink),
        titleMedium: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500, color: SvcColors.ink),
        titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: SvcColors.ink),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: SvcColors.ink, height: 1.45),
        bodyMedium: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w400, color: SvcColors.ink, height: 1.4),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: SvcColors.muted, height: 1.35),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: SvcColors.ink),
        labelMedium: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: SvcColors.muted),
        labelSmall: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: SvcColors.muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SvcColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: SvcColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: SvcColors.ink),
      ),
      cardTheme: CardThemeData(
        color: SvcColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: SvcColors.border, width: 0.8),
        ),
      ),
    );
  }
}

class SvcTypography {
  static TextStyle get headingTight => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 17,
    letterSpacing: -0.2,
    color: SvcColors.ink,
  );

  static TextStyle get statValue => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: -0.2,
    color: SvcColors.ink,
  );

  static TextStyle get statLabel => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.2,
    color: SvcColors.muted,
  );

  static TextStyle get cardTitle => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    fontSize: 14.5,
    color: SvcColors.ink,
  );

  static TextStyle get badgeText => GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.1,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    color: SvcColors.ink,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 11.5,
    color: SvcColors.muted,
  );
}
