import 'package:flutter/material.dart';

/// Immutable palette for one brightness. Widgets read colors through
/// `KColors.of(Theme.of(context).brightness)` so light/dark stay 1:1.
class KPalette {
  final Color canvas, surface1, surface2, hairline, hairlineSoft, ink, inkMuted,
      accent, success, danger;
  const KPalette({
    required this.canvas,
    required this.surface1,
    required this.surface2,
    required this.hairline,
    required this.hairlineSoft,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.success,
    required this.danger,
  });
}

class KColors {
  KColors._();

  static const _dark = KPalette(
    canvas: Color(0xFF090909),
    surface1: Color(0xFF141414),
    surface2: Color(0xFF1C1C1C),
    hairline: Color(0xFF262626),
    hairlineSoft: Color(0xFF1A1A1A),
    ink: Color(0xFFFFFFFF),
    inkMuted: Color(0xFF999999),
    accent: Color(0xFF0099FF),
    success: Color(0xFF22C55E),
    danger: Color(0xFFEF4444),
  );

  static const _light = KPalette(
    canvas: Color(0xFFFFFFFF),
    surface1: Color(0xFFF4F3F1),
    surface2: Color(0xFFECEAE7),
    hairline: Color(0xFFE4E2DE),
    hairlineSoft: Color(0xFFEFEDEA),
    ink: Color(0xFF0A0A0A),
    inkMuted: Color(0xFF6F6F6F),
    accent: Color(0xFF0080D6),
    success: Color(0xFF16A34A),
    danger: Color(0xFFDC2626),
  );

  static KPalette of(Brightness b) => b == Brightness.dark ? _dark : _light;

  static const auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A4BD6), Color(0xFF0099FF), Color(0xFF4CD4FF)],
    stops: [0.0, 0.55, 1.0],
  );
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A3D), Color(0xFFFF9D3D), Color(0xFFFFC24D)],
    stops: [0.0, 0.55, 1.0],
  );
}

class KRadius {
  KRadius._();
  static const xs = 4.0, sm = 6.0, md = 10.0, lg = 15.0, xl = 20.0, xxl = 22.0,
      pill = 100.0, full = 9999.0;
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get spotlight => BorderRadius.circular(xxl);
  static BorderRadius get input => BorderRadius.circular(md);
}

class KSpace {
  KSpace._();
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 14.0, lg = 20.0, xl = 26.0,
      xxl = 40.0, section = 96.0;
  /// Standard screen horizontal padding (20px).
  static const screenH = EdgeInsets.symmetric(horizontal: lg);
}

/// Fixed component sizes (avatars, icon tiles, row heights) — pinned values,
/// not a range. See docs/design/DESIGN-2.md components section.
class KSize {
  KSize._();
  static const iconButton = 40.0; // button-icon-circular
  static const quickAction = 56.0; // quick-action-primary/secondary
  static const avatarSm = 40.0; // avatar-monogram in transaction/list rows
  static const avatarMd = 52.0; // avatar-monogram in family shortcuts row
  static const avatarLg = 56.0; // avatar-monogram showcase / selected
  static const iconTileLg = 72.0; // Welcome screen Face ID tile
  static const brandBadge = 64.0; // Welcome screen mark
  static const rowHeight = 64.0; // transaction-row target
}
