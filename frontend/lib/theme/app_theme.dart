import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';
import 'text_theme.dart';

/// Single ThemeData builder for both modes. Pill CTAs (ink fill), surface
/// inputs with accent focus ring, hairline dividers. Accent is `secondary`
/// only — never a button fill (that is `primary: ink`).
ThemeData buildTheme({required bool dark}) {
  final p = KColors.of(dark ? Brightness.dark : Brightness.light);
  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: p.ink,
    onPrimary: p.canvas,
    secondary: p.accent,
    onSecondary: dark ? Colors.white : Colors.white,
    surface: p.surface1,
    onSurface: p.ink,
    error: p.danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.canvas,
    canvasColor: p.canvas,
    textTheme: buildTextTheme(p.ink),
    dividerTheme: DividerThemeData(color: p.hairlineSoft, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: p.ink,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: p.ink),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.ink,
        foregroundColor: p.canvas,
        disabledBackgroundColor: p.surface2,
        disabledForegroundColor: p.inkMuted,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: p.accent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface1,
      contentPadding: const EdgeInsets.symmetric(horizontal: KSpace.md, vertical: KSpace.sm),
      hintStyle: GoogleFonts.inter(fontSize: 15, color: p.inkMuted),
      border: OutlineInputBorder(borderRadius: KRadius.input, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: KRadius.input, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: KRadius.input,
        borderSide: BorderSide(color: p.accent, width: 1),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface1,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: p.surface1,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: p.hairline,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KRadius.xxl)),
      ),
    ),
  );
}
