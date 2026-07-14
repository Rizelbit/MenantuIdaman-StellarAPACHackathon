import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale from docs/DESIGN.md. Manrope for display, Inter for reading.
/// Hierarchy = size + tracking, not weight ramp. Negative letter-spacing is
/// intentional — never loosen it.
TextTheme buildTextTheme(Color ink) => TextTheme(
      displayLarge: GoogleFonts.manrope(
          fontSize: 110, height: 0.85, fontWeight: FontWeight.w700, letterSpacing: -5.5, color: ink),
      displayMedium: GoogleFonts.manrope(
          fontSize: 85, height: 0.95, fontWeight: FontWeight.w700, letterSpacing: -4.25, color: ink),
      displaySmall: GoogleFonts.manrope(
          fontSize: 62, height: 1.0, fontWeight: FontWeight.w600, letterSpacing: -3.1, color: ink),
      headlineLarge: GoogleFonts.manrope(
          fontSize: 32, height: 1.13, fontWeight: FontWeight.w600, letterSpacing: -1.0, color: ink),
      headlineMedium: GoogleFonts.inter(
          fontSize: 22, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: ink),
      titleMedium: GoogleFonts.inter(
          fontSize: 24, height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.01, color: ink),
      bodyLarge: GoogleFonts.inter(
          fontSize: 18, height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.18, color: ink),
      bodyMedium: GoogleFonts.inter(
          fontSize: 15, height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.15, color: ink),
      bodySmall: GoogleFonts.inter(
          fontSize: 14, height: 1.40, fontWeight: FontWeight.w500, letterSpacing: -0.14, color: ink),
      labelSmall: GoogleFonts.inter(
          fontSize: 13, height: 1.20, fontWeight: FontWeight.w500, letterSpacing: 2.0, color: ink),
      labelMedium: GoogleFonts.inter(
          fontSize: 14, height: 1.0, fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink),
    );

/// Money display: Manrope with tabular figures so digits never shift.
TextStyle moneyStyle({required double size, required Color color, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.manrope(
      fontSize: size,
      height: 1.0,
      fontWeight: weight,
      letterSpacing: size >= 48 ? -2.0 : -1.0,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
