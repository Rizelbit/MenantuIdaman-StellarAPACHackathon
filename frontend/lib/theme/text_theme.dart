import 'package:flutter/material.dart';

/// Type scale from docs/design/DESIGN-2.md v1.1. Manrope is the sole
/// typeface (Inter has been fully retired from the design system) — bundled
/// offline via the pubspec `fonts:` asset, so every style below is a plain
/// `TextStyle(fontFamily: 'Manrope', ...)` rather than `GoogleFonts.manrope`,
/// which would hit the network on every cold start.
///
/// Hierarchy = size + tracking, not weight ramp. Negative letter-spacing is
/// intentional and tightens with size — never loosen it "for readability".
TextTheme buildTextTheme(Color ink) => TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Manrope', fontSize: 110, height: 0.85, fontWeight: FontWeight.w700, letterSpacing: -5.5, color: ink), // display-xxl
      displayMedium: TextStyle(
          fontFamily: 'Manrope', fontSize: 68, height: 0.95, fontWeight: FontWeight.w700, letterSpacing: -4.25, color: ink), // display-xl
      displaySmall: TextStyle(
          fontFamily: 'Manrope', fontSize: 52, height: 1.0, fontWeight: FontWeight.w600, letterSpacing: -3.1, color: ink), // display-lg
      headlineLarge: TextStyle(
          fontFamily: 'Manrope', fontSize: 32, height: 1.13, fontWeight: FontWeight.w600, letterSpacing: -1.0, color: ink), // display-md
      headlineMedium: TextStyle(
          fontFamily: 'Manrope', fontSize: 22, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: ink), // headline
      titleMedium: TextStyle(
          fontFamily: 'Manrope', fontSize: 17, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: ink), // subhead — card/row group titles; also carries eyebrow/section labels (no separate caption token)
      bodyLarge: TextStyle(
          fontFamily: 'Manrope', fontSize: 18, height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.18, color: ink),
      bodyMedium: TextStyle(
          fontFamily: 'Manrope', fontSize: 15, height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.15, color: ink),
      bodySmall: TextStyle(
          fontFamily: 'Manrope', fontSize: 14, height: 1.40, fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink), // body-sm — row titles, buttons
      labelMedium: TextStyle(
          fontFamily: 'Manrope', fontSize: 14, height: 1.0, fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink), // button
    );

/// `typography.micro` (12px) — meta/timestamps. TextTheme has no 7th label
/// slot, so this ships as a standalone style per DESIGN-2.md's note.
TextStyle microStyle(Color color) => TextStyle(
      fontFamily: 'Manrope',
      fontSize: 12,
      height: 1.20,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.12,
      color: color,
    );

/// Money display: Manrope with tabular figures so digits never shift.
TextStyle moneyStyle({required double size, required Color color, FontWeight weight = FontWeight.w700}) =>
    TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      height: 1.0,
      fontWeight: weight,
      letterSpacing: size >= 48 ? -2.0 : -1.0,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
