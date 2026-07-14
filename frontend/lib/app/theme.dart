import 'package:flutter/material.dart';

/// ============================================================================
/// DESIGN TOKENS — "Invisible Crypto Remittance"
/// ----------------------------------------------------------------------------
/// Arah desain: tenang, terpercaya, hangat — terasa seperti aplikasi keuangan
/// modern untuk keluarga, BUKAN aplikasi crypto. Tidak ada neon, tidak ada
/// dark-mode acid, tidak ada jargon.
///
/// Signature element = "kartu rincian biaya" (FeeBreakdownCard) + angka nominal
/// besar dengan preview "keluarga terima". Semua warna aksen dijaga tenang agar
/// dua elemen itu yang menonjol.
///
/// SEMUA screen (termasuk hasil generate agent) HARUS mengambil warna & spacing
/// dari sini — jangan hardcode hex di screen. Lihat frontend/README.md.
/// ============================================================================

class AppColors {
  AppColors._();

  // Brand / ink — deep pine, bukan biru fintech generik
  static const ink = Color(0xFF12332E);
  static const primary = Color(0xFF0B6E63); // teal aksi
  static const primaryPressed = Color(0xFF095A51);

  // Permukaan
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F6F4); // paper dingin (hindari cream tell)
  static const surfaceAlt = Color(0xFFEFF2F0);

  // Aksen "uang diterima" — amber hangat, dipakai HEMAT (momen sukses)
  static const accent = Color(0xFFC8892E);
  static const accentSoft = Color(0xFFF6ECD9);

  // Semantik
  static const success = Color(0xFF1B7F4B);
  static const successSoft = Color(0xFFE4F2E9);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFF9E7E4);

  // Teks
  static const textPrimary = ink;
  static const textSecondary = Color(0xFF5B6763);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textDisabled = Color(0xFF9AA5A0);

  // Garis / pembatas
  static const hairline = Color(0xFFE4E7E4);
}

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
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xl));
}

/// Skala tipografi. Nama-role, bukan ukuran, supaya screen tetap konsisten.
/// Font family default dibiarkan null (pakai default platform). Untuk identitas
/// lebih kuat, tambahkan `google_fonts` (mis. Plus Jakarta Sans — kebetulan
/// typeface rancangan Indonesia, cocok dengan narasi produk) lalu isi `fontFamily`.
class AppText {
  AppText._();
  static const _family = null; // TODO: 'PlusJakartaSans' via google_fonts

  static const displayMoney = TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const h1 = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
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
    color: AppColors.textOnPrimary,
  );
}

/// ThemeData tunggal — dipakai di MaterialApp.router.
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    surface: AppColors.surface,
    error: AppColors.danger,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.h2,
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
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppText.title,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      hintStyle: AppText.bodyMuted,
      border: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.button,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displaySmall: AppText.displayMoney,
      headlineMedium: AppText.h1,
      titleLarge: AppText.h2,
      titleMedium: AppText.title,
      bodyMedium: AppText.body,
      labelLarge: AppText.label,
    ),
  );
}
