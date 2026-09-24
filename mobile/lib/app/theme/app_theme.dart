import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// CAMP Typography and Global Theme System
class AppTheme {
  AppTheme._();

  /// Light theme for CAMP
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme();

    final textTheme = baseTextTheme.copyWith(
      // Big stat numbers: 28-32 / extrabold
      displayLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.4,
      ),
      // Title: 24 / bold
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.2,
      ),
      // Card title: 16 / semibold
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkCharcoal,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkCharcoal,
      ),
      // Body: 13-14 / regular
      bodyLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkCharcoal,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppColors.darkCharcoal,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
        height: 1.35,
      ),
      // Overline / label: 10-11 / semibold uppercase with 1.2 letter spacing
      labelMedium: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.mutedText,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.mutedText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.clay,
      fontFamily: GoogleFonts.manrope().fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.tacticalOrange,
        onPrimary: Colors.white,
        secondary: AppColors.tacticalOrangeDark,
        onSecondary: Colors.white,
        surface: AppColors.clay,
        onSurface: AppColors.darkCharcoal,
        error: AppColors.alertRed,
        onError: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x14000000),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Convenience typography accessors adhering to the CAMP design system
class AppTextStyles {
  AppTextStyles._();

  /// Title: 24/bold, primary darkCharcoal
  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.3,
      );

  /// Card title: 16/semibold, primary darkCharcoal
  static TextStyle get cardTitle => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkCharcoal,
      );

  /// Sub-card title or item title: 14-15/semibold
  static TextStyle get itemTitle => GoogleFonts.manrope(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: AppColors.darkCharcoal,
      );

  /// Body: 13-14/regular, primary darkCharcoal
  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppColors.darkCharcoal,
        height: 1.4,
      );

  /// Body secondary / muted: 13-14/regular, secondary mutedText
  static TextStyle get bodySecondary => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
        height: 1.35,
      );

  /// Caption: 12/regular, mutedText
  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
      );

  /// Overline / label: 10-11/semibold uppercase with 1.2 letter spacing
  static TextStyle get overline => GoogleFonts.manrope(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.mutedText,
      );

  /// Overline in primary orange: 10-11/semibold uppercase with 1.2 letter spacing
  static TextStyle get overlineOrange => GoogleFonts.manrope(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.tacticalOrangeDark,
      );

  /// Overline terracotta / dark accent
  static TextStyle get overlineTerracotta => GoogleFonts.manrope(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.terracotta,
      );

  /// Big stat numbers: 28-32/extrabold
  static TextStyle get bigStat => GoogleFonts.manrope(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.5,
      );

  /// Stat number (medium): 20-22/extrabold
  static TextStyle get statMedium => GoogleFonts.manrope(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: AppColors.darkCharcoal,
      );

  /// Orange link / label: tacticalOrangeDark
  static TextStyle get orangeLink => GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.tacticalOrangeDark,
      );
}
