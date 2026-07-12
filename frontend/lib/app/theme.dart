import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// DESIGN TOKENS — Kirimin (dark, minimal, sleek)
/// ----------------------------------------------------------------------------
/// Single source of truth: docs/design-system.md. A money app that reads like a
/// premium finance product, never like a crypto wallet. Dark mode only.
///
/// Rules baked in here:
///  • Depth without flatness: a soft near black GRADIENT background, not a flat
///    fill (see [appBackgroundGradient], painted by AppScaffold).
///  • Separate by tone first, border second: surfaces step up in lightness
///    (surface / surfaceAlt / surface3); a hairline is added only when tone
///    alone is too subtle (inputs, floating nav).
///  • One loud color: yellow ([primary]) is the ONLY saturated hue — CTA,
///    active nav, focus, money moments. Everything else stays neutral.
///  • Big honest numbers: money uses tabular figures so digits never shift.
///
/// SEMUA screen mengambil warna, teks, dan spacing dari sini. Jangan hardcode
/// hex di screen. Nama token dijaga stabil supaya screen lama tetap jalan.
/// ============================================================================

class AppColors {
  AppColors._();

  // --- Background ramp (the off dark gradient) ---
  static const bgTop = Color(0xFF101114); // gradient start (top)
  static const bgBase = Color(0xFF0A0B0D); // gradient mid / solid fallback
  static const bgBottom = Color(0xFF070709); // gradient end (bottom)
  static const background = bgBase;

  // --- Surfaces (tonal elevation; each step a touch lighter) ---
  static const surface = Color(0xFF141518); // surface1: cards, sheets, lists
  static const surfaceAlt = Color(0xFF1C1E22); // surface2: inputs, inner tiles, nav
  static const surface3 = Color(0xFF26282E); // pressed / selected / menu

  // --- Borders (soft, used sparingly) ---
  static const hairline = Color(0x0FFFFFFF); // 6% white — default soft edge
  static const hairlineStrong = Color(0x1AFFFFFF); // 10% white — inputs, nav, focus

  // --- Brand yellow (the one accent) ---
  static const primary = Color(0xFFF5B301);
  static const primaryHi = Color(0xFFFFC933); // lighter gradient stop / hover
  static const primaryPressed = Color(0xFFD99A00);
  static const primarySoft = Color(0x1FF5B301); // 12% — tinted highlight / active pill
  static const onPrimary = Color(0xFF0A0B0D); // near black text/icon ON yellow

  // Accent = brand yellow (kept for older screens; yellow is the single accent).
  static const accent = primary;
  static const accentSoft = primarySoft;

  // --- Semantic (always paired with an icon/label, never color alone) ---
  static const success = Color(0xFF34C759);
  static const successSoft = Color(0x2434C759); // 14%
  static const danger = Color(0xFFFF453A);
  static const dangerSoft = Color(0x24FF453A); // 14%

  // --- Text ---
  static const textPrimary = Color(0xFFF4F5F7); // ~17:1 on bgBase
  static const textSecondary = Color(0xFFA2A6AE); // ~7:1 on bgBase
  static const textTertiary = Color(0xFF6C7079); // large / non essential only
  static const textOnPrimary = onPrimary; // on yellow: near black, never white
  static const textDisabled = textTertiary;

  // Near black brand ink (surfaces/scrims). Kept for compatibility.
  static const ink = Color(0xFF0A0B0D);
}

/// Scaffold background — a subtle top lit vertical gradient over neutral near
/// black. Painted once by AppScaffold behind every screen. Depth, never flat.
const appBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.bgTop, AppColors.bgBase, AppColors.bgBottom],
  stops: [0.0, 0.45, 1.0],
);

/// Scrim behind modals/sheets so foreground stays legible (rgba(0,0,0,0.55)).
const kSheetScrim = Color(0x8C000000);

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Padding standar tepi layar. Pakai ini di setiap screen agar konsisten.
  static const screen = EdgeInsets.symmetric(horizontal: lg);
}

class AppRadii {
  AppRadii._();
  static const sm = 8.0; // chips, inputs
  static const md = 12.0; // buttons
  static const lg = 16.0; // cards
  static const xl = 24.0; // sheets, hero card
  static const pill = 999.0;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xl));
}

/// Icon size tokens (design system §8). No arbitrary in between sizes.
class AppIconSize {
  AppIconSize._();
  static const sm = 16.0;
  static const md = 20.0; // default
  static const lg = 24.0;
}

/// Skala tipografi. Nama-role, bukan ukuran, supaya screen tetap konsisten.
/// Family sengaja dibiarkan null di sini: keluarga font (Plus Jakarta Sans,
/// design system §4) di-inject sekali di [buildAppTheme] lewat google_fonts,
/// lalu mengalir ke seluruh teks via DefaultTextStyle + theme. Style ini tetap
/// `const` supaya screen yang memakai `const Text(style: AppText.x)` tak pecah.
class AppText {
  AppText._();
  static const _family = null; // di-isi via theme (google_fonts), lihat buildAppTheme

  static const displayMoney = TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const displayMoneyLg = TextStyle(
    fontFamily: _family,
    fontSize: 52,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const h1 = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );
  static const h2 = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  static const title = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );
  static const bodyMuted = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );
  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );
  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary, // near black on yellow
  );
}

/// ThemeData tunggal (dark) — dipakai di MaterialApp.router.
ThemeData buildAppTheme() {
  // Plus Jakarta Sans (§4). Di-inject sekali di sini; AppText tetap null-family
  // dan mewarisi keluarga ini lewat DefaultTextStyle + theme.
  final family = GoogleFonts.plusJakartaSans().fontFamily;
  TextStyle f(TextStyle s) => s.copyWith(fontFamily: family);

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
    outline: AppColors.hairlineStrong,
    outlineVariant: AppColors.hairline,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: family,
    // Gradient is painted by AppScaffold; bgBase is the solid fallback.
    scaffoldBackgroundColor: AppColors.bgBase,
    canvasColor: AppColors.bgBase,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // let the gradient show through
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: f(AppText.h2),
      foregroundColor: AppColors.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: const BorderSide(color: AppColors.hairline),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textTertiary,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        textStyle: f(AppText.button),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: AppColors.hairlineStrong),
        textStyle: f(AppText.title),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: f(AppText.title),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      hintStyle: f(AppText.bodyMuted),
      labelStyle: f(AppText.label),
      border: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.hairlineStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.hairlineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      modalBarrierColor: kSheetScrim,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: AppColors.hairlineStrong,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
    textTheme: const TextTheme(
      displaySmall: AppText.displayMoney,
      headlineMedium: AppText.h1,
      titleLarge: AppText.h2,
      titleMedium: AppText.title,
      bodyMedium: AppText.body,
      labelLarge: AppText.label,
    ).apply(fontFamily: family),
  );
}
