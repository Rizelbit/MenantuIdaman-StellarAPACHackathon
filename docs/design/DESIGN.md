---
version: 1.0
name: Kirimin
description: "A dark-first finance app for sending money to family and splitting bills. Near-black tonal-lift surfaces, poster-grade Manrope display type with aggressive negative tracking, Inter for reading text, and a single confident blue (#0099FF) reserved for links, focus, and selection. One gradient 'spotlight' card is the only decorative/atmospheric device. Full inverse light palette included for system light mode."

colors:
  # Dark (primary)
  canvas: "#090909"
  surface1: "#141414"
  surface2: "#1C1C1C"
  hairline: "#262626"
  hairlineSoft: "#1A1A1A"
  ink: "#FFFFFF"
  inkMuted: "#999999"
  accentBlue: "#0099FF"
  success: "#22C55E"
  danger: "#EF4444"
  gradientAuroraStart: "#0A4BD6"
  gradientAuroraMid: "#0099FF"
  gradientAuroraEnd: "#4CD4FF"
  gradientSunsetStart: "#FF7A3D"
  gradientSunsetMid: "#FF9D3D"
  gradientSunsetEnd: "#FFC24D"
  # Light (inverse)
  canvasLight: "#FFFFFF"
  surface1Light: "#F4F3F1"
  surface2Light: "#ECEAE7"
  hairlineLight: "#E4E2DE"
  hairlineSoftLight: "#EFEDEA"
  inkLight: "#0A0A0A"
  inkMutedLight: "#6F6F6F"
  accentBlueLight: "#0080D6"
  successLight: "#16A34A"
  dangerLight: "#DC2626"

typography:
  display-xxl: { fontFamily: Manrope, fontWeight: 700, fontSize: 110px, lineHeight: 0.85, letterSpacing: -5.5px }
  display-xl:  { fontFamily: Manrope, fontWeight: 700, fontSize: 85px,  lineHeight: 0.95, letterSpacing: -4.25px }
  display-lg:  { fontFamily: Manrope, fontWeight: 600, fontSize: 62px,  lineHeight: 1.00, letterSpacing: -3.1px }
  display-md:  { fontFamily: Manrope, fontWeight: 600, fontSize: 32px,  lineHeight: 1.13, letterSpacing: -1.0px }
  headline:    { fontFamily: Inter,   fontWeight: 700, fontSize: 22px,  lineHeight: 1.20, letterSpacing: -0.8px }
  subhead:     { fontFamily: Inter,   fontWeight: 400, fontSize: 24px,  lineHeight: 1.30, letterSpacing: -0.01px }
  body-lg:     { fontFamily: Inter,   fontWeight: 400, fontSize: 18px,  lineHeight: 1.30, letterSpacing: -0.18px }
  body:        { fontFamily: Inter,   fontWeight: 400, fontSize: 15px,  lineHeight: 1.30, letterSpacing: -0.15px }
  body-sm:     { fontFamily: Inter,   fontWeight: 500, fontSize: 14px,  lineHeight: 1.40, letterSpacing: -0.14px }
  caption:     { fontFamily: Inter,   fontWeight: 500, fontSize: 13px,  lineHeight: 1.20, letterSpacing: 0.14em, textTransform: uppercase }
  micro:       { fontFamily: Inter,   fontWeight: 400, fontSize: 12px,  lineHeight: 1.20, letterSpacing: -0.12px }
  button:      { fontFamily: Inter,   fontWeight: 600, fontSize: 14px,  lineHeight: 1.0,  letterSpacing: -0.14px }

rounded:
  xs: 4px
  sm: 6px
  md: 10px
  lg: 15px
  xl: 20px
  xxl: 22px
  pill: 100px
  full: 9999px

spacing:
  hair: 1px
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 14px
  lg: 20px
  xl: 26px
  xxl: 40px
  section: 96px

components:
  button-primary:
    background: "{colors.ink}"          # white on dark canvas / near-black on light (inverse)
    text: "{colors.canvas}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 20px"
  button-secondary:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 20px"
  button-icon-circular:
    background: "{colors.surface1}"
    size: 40px
    rounded: "{rounded.full}"
  quick-action-primary:
    background: "{colors.ink}"
    iconColor: "{colors.canvas}"
    size: 56px
    rounded: "{rounded.full}"
  quick-action-secondary:
    background: "{colors.surface1}"
    iconColor: "{colors.ink}"
    size: 56px
    rounded: "{rounded.full}"
  text-input:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "12px 14px"
  text-input-focused:
    extends: text-input
    ring: "0 0 0 3px rgba(0,153,255,0.18)"
    border: "1px solid {colors.accentBlue}"
  card-surface-1:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    rounded: "{rounded.xl}"
    padding: "22px"
  card-surface-2:
    background: "{colors.surface2}"
    text: "{colors.ink}"
    rounded: "{rounded.xxl}"
    padding: "22px"
  gradient-spotlight-aurora:
    background: "linear-gradient(140deg, {colors.gradientAuroraStart} 0%, {colors.gradientAuroraMid} 55%, {colors.gradientAuroraEnd} 100%)"
    text: "#FFFFFF"
    rounded: "{rounded.xxl}"
    padding: "22px"
  gradient-spotlight-sunset:
    background: "linear-gradient(140deg, {colors.gradientSunsetStart} 0%, {colors.gradientSunsetMid} 55%, {colors.gradientSunsetEnd} 100%)"
    text: "#1A1207"
    rounded: "{rounded.xxl}"
    padding: "22px"
  avatar-monogram:
    background: "{colors.surface2}"
    text: "{colors.ink}"
    size: 40-56px
    rounded: "{rounded.full}"
  avatar-selected:
    extends: avatar-monogram
    border: "2px solid {colors.accentBlue}"
  status-chip-success:
    background: "rgba(34,197,94,0.14)"
    text: "{colors.success}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  status-chip-danger:
    background: "rgba(239,68,68,0.14)"
    text: "{colors.danger}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  status-chip-info:
    background: "rgba(0,153,255,0.14)"
    text: "{colors.accentBlue}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  transaction-row:
    background: transparent
    divider: "{colors.hairlineSoft}"
    typography: "{typography.body}"
    height: 64px
---

## Overview

Kirimin is a single-screen money app for sending funds to family and splitting shared bills. The surface language is dark-first: `{colors.canvas}` near-black with a barely-there warm radial glow behind it for depth (never a flat, lifeless black). Hierarchy is carried by **tonal lift** — canvas → surface-1 → surface-2 — not by opacity or gray-on-gray tricks. Display type is set in **Manrope** at large, hard-negative tracking for a poster feel; body and UI text is **Inter**. The only chromatic accent is `{colors.accentBlue}`, reserved strictly for links, focus rings, and selection — never a button fill. Money outcomes use green (received) / red (failed) — that's the only place status color appears. One gradient "spotlight" card (blue aurora or amber sunset) is used sparingly as the sole atmospheric/decorative device.

A full **inverse light palette** mirrors every dark token 1:1 so the same component spec renders correctly in system light mode.

**Key characteristics:**
- Two anchor surfaces per mode (canvas + ink), three surface-lift steps, one hairline.
- Manrope display type, -1% to -5% letter-spacing scaling with size; Inter for everything at reading scale.
- All primary actions are pills or full circles — never a squared button.
- `{colors.accentBlue}` only on links, focus rings, selected avatar border, and the "Split active" status chip — never a background fill.
- Gradient spotlight cards are scarce: one per screen max.
- No bottom tab bar — navigation happens from within the single home surface (sheets/pushes from quick actions and list rows).

## Colors

### Dark (primary)
- **Canvas** `{colors.canvas}` #090909 — page background, always paired with the soft off-center radial glow (see Depth).
- **Surface 1** `{colors.surface1}` #141414 — default content card, secondary button, icon buttons.
- **Surface 2** `{colors.surface2}` #1C1C1C — featured/balance card, avatar fill.
- **Hairline** `{colors.hairline}` #262626 / **Hairline Soft** `{colors.hairlineSoft}` #1A1A1A — dividers only, never a full border-box.
- **Ink** `{colors.ink}` #FFFFFF — all primary text and the primary-button fill.
- **Ink Muted** `{colors.inkMuted}` #999999 — secondary text, timestamps, deselected state.
- **Accent Blue** `{colors.accentBlue}` #0099FF — links, focus ring, selected-avatar border, "active" status chip. Never a CTA fill.
- **Success** `{colors.success}` #22C55E — incoming money only.
- **Danger** `{colors.danger}` #EF4444 — failed transaction only.

### Light (inverse)
Same roles, values flipped through the middle of the scale:
- Canvas `{colors.canvasLight}` #FFFFFF · Surface 1 `{colors.surface1Light}` #F4F3F1 · Surface 2 `{colors.surface2Light}` #ECEAE7
- Hairline `{colors.hairlineLight}` #E4E2DE
- Ink `{colors.inkLight}` #0A0A0A · Ink Muted `{colors.inkMutedLight}` #6F6F6F
- Accent Blue `{colors.accentBlueLight}` #0080D6 (deepened for 4.5:1+ contrast on white)
- Success `{colors.successLight}` #16A34A · Danger `{colors.dangerLight}` #DC2626

### Anti-patterns
- ❌ Accent blue as a button/card fill — signal color only.
- ❌ Any accent besides blue + the two gradient hues (no purple/pink/neon).
- ❌ Flat, uniform black with no radial depth.
- ❌ Boxing every element in a bordered card — separate with space and tone first.

## Typography

- **Manrope** (600/700) for all display sizes — geometric, confident, tracked hard-negative at scale.
- **Inter** (400–700) for headline down to micro. No other typefaces.
- Letter-spacing tightens as size grows (-5.5px at 110px down to -0.12px at 12px) — never loosen this "for readability"; reduce size instead if space is tight.
- Weight stays narrow: display 600–700, body 400, body-sm/caption 500. Hierarchy = size + tracking, not a weight ramp.

## Layout & Spacing

Base unit 4px: `{spacing.xxs}` 4 · `{spacing.xs}` 8 · `{spacing.sm}` 12 · `{spacing.md}` 14 · `{spacing.lg}` 20 · `{spacing.xl}` 26 · `{spacing.xxl}` 40 · `{spacing.section}` 96.
- Screen horizontal margin: 20px (`{spacing.lg}`).
- Card interior padding: 22px.
- Vertical rhythm between home-screen blocks: 22px; between major spec sections: 96px.
- Row height (list/transaction): 64px, hairline divider only, no per-row card.

## Depth

| Level | Treatment | Use |
|---|---|---|
| 0 | Flat, no shadow | List rows, dividers, text on canvas |
| Background glow | `radial-gradient(135% 78% at 20% 4%, {warm tone} 0%, {mid tone} 45%, {canvas} 80%)` — barely-there, low chroma | Full-screen background only |
| 1 | Surface-1 tonal lift | Default cards, secondary buttons |
| 2 | Surface-2 tonal lift | Featured/balance card, avatar fill |
| 3 (focus) | `0 0 0 3px rgba(0,153,255,0.18)` + 1px accent border | Focused input only |
| Decorative | Gradient spotlight fill | One promo card per screen, max |

## Shapes

`{rounded.xs}` 4 chips · `{rounded.md}` 10 inputs · `{rounded.xl}` 20 cards · `{rounded.xxl}` 22 balance/spotlight cards · `{rounded.pill}` 100 all CTAs · `{rounded.full}` circular avatars/icon buttons.

## Components (reference)

See front-matter `components:` block for exact token bindings — button-primary/secondary, icon-circular, quick-action-primary/secondary, text-input(-focused), card-surface-1/2, gradient-spotlight-aurora/sunset, avatar-monogram(-selected), status-chip-success/danger/info, transaction-row.

---

## Flutter Transferability

### 1. Fonts
Add to `pubspec.yaml` (or use `google_fonts` package — both families are on Google Fonts):
```yaml
dependencies:
  google_fonts: ^6.2.1
```
```dart
final displayFont = GoogleFonts.manrope;
final bodyFont = GoogleFonts.inter;
```

### 2. Design tokens (`lib/theme/tokens.dart`)
```dart
class KColors {
  // Dark (primary)
  static const canvas       = Color(0xFF090909);
  static const surface1     = Color(0xFF141414);
  static const surface2     = Color(0xFF1C1C1C);
  static const hairline     = Color(0xFF262626);
  static const hairlineSoft = Color(0xFF1A1A1A);
  static const ink          = Color(0xFFFFFFFF);
  static const inkMuted     = Color(0xFF999999);
  static const accentBlue   = Color(0xFF0099FF);
  static const success      = Color(0xFF22C55E);
  static const danger       = Color(0xFFEF4444);

  // Light (inverse)
  static const canvasLight       = Color(0xFFFFFFFF);
  static const surface1Light     = Color(0xFFF4F3F1);
  static const surface2Light     = Color(0xFFECEAE7);
  static const hairlineLight     = Color(0xFFE4E2DE);
  static const inkLight          = Color(0xFF0A0A0A);
  static const inkMutedLight     = Color(0xFF6F6F6F);
  static const accentBlueLight   = Color(0xFF0080D6);
  static const successLight      = Color(0xFF16A34A);
  static const dangerLight       = Color(0xFFDC2626);

  static const auroraGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0A4BD6), Color(0xFF0099FF), Color(0xFF4CD4FF)],
    stops: [0.0, 0.55, 1.0],
  );
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A3D), Color(0xFFFF9D3D), Color(0xFFFFC24D)],
    stops: [0.0, 0.55, 1.0],
  );
}

class KRadius {
  static const xs = 4.0, sm = 6.0, md = 10.0, lg = 15.0, xl = 20.0, xxl = 22.0, pill = 100.0, full = 9999.0;
}

class KSpace {
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 14.0, lg = 20.0, xl = 26.0, xxl = 40.0, section = 96.0;
}
```

### 3. Text theme (`lib/theme/text_theme.dart`)
```dart
TextTheme buildTextTheme(Color ink) => TextTheme(
  displayLarge:  GoogleFonts.manrope(fontSize: 110, height: 0.85, fontWeight: FontWeight.w700, letterSpacing: -5.5, color: ink),
  displayMedium: GoogleFonts.manrope(fontSize: 85,  height: 0.95, fontWeight: FontWeight.w700, letterSpacing: -4.25, color: ink),
  displaySmall:  GoogleFonts.manrope(fontSize: 62,  height: 1.00, fontWeight: FontWeight.w600, letterSpacing: -3.1, color: ink),
  headlineLarge: GoogleFonts.manrope(fontSize: 32,  height: 1.13, fontWeight: FontWeight.w600, letterSpacing: -1.0, color: ink),
  headlineMedium:GoogleFonts.inter(fontSize: 22,   height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: ink),
  titleMedium:   GoogleFonts.inter(fontSize: 24,   height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.01, color: ink),
  bodyLarge:     GoogleFonts.inter(fontSize: 18,   height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.18, color: ink),
  bodyMedium:    GoogleFonts.inter(fontSize: 15,   height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.15, color: ink),
  bodySmall:     GoogleFonts.inter(fontSize: 14,   height: 1.40, fontWeight: FontWeight.w500, letterSpacing: -0.14, color: ink),
  labelSmall:    GoogleFonts.inter(fontSize: 13,   height: 1.20, fontWeight: FontWeight.w500, letterSpacing: 2.0 /* uppercase captions */, color: ink),
  labelMedium:   GoogleFonts.inter(fontSize: 14,   height: 1.0,  fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink), // button
);
```

### 4. ThemeData (dark + light)
```dart
ThemeData buildTheme({required bool dark}) {
  final ink = dark ? KColors.ink : KColors.inkLight;
  final canvas = dark ? KColors.canvas : KColors.canvasLight;
  final surface1 = dark ? KColors.surface1 : KColors.surface1Light;
  final surface2 = dark ? KColors.surface2 : KColors.surface2Light;
  final accent = dark ? KColors.accentBlue : KColors.accentBlueLight;

  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: ink, onPrimary: canvas,
      secondary: accent, onSecondary: Colors.white,
      surface: surface1, onSurface: ink,
      error: dark ? KColors.danger : KColors.dangerLight, onError: Colors.white,
    ),
    textTheme: buildTextTheme(ink),
    dividerColor: dark ? KColors.hairlineSoft : KColors.hairlineLight,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ink, foregroundColor: canvas,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface1,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(KRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KRadius.md),
        borderSide: BorderSide(color: accent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
// Wire both into MaterialApp: theme: buildTheme(dark:false), darkTheme: buildTheme(dark:true), themeMode: ThemeMode.system
```

### 5. Background glow (reusable widget)
```dart
class GlowBackground extends StatelessWidget {
  final Widget child; final bool dark;
  const GlowBackground({required this.child, required this.dark, super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-0.6, -0.9), radius: 1.3,
        colors: dark
          ? [const Color(0xFF1A160F), const Color(0xFF0E0C0A), KColors.canvas]
          : [const Color(0xFFFDFBF7), const Color(0xFFF7F4EF), const Color(0xFFF2EFE9)],
        stops: const [0.0, 0.45, 0.8],
      ),
    ),
    child: child,
  );
}
```

### 6. Component → widget map
| Token | Flutter widget |
|---|---|
| `button-primary` | `ElevatedButton` (themed above) |
| `button-secondary` | `TextButton` with `StadiumBorder`, `backgroundColor: surface1` |
| `button-icon-circular` / `quick-action-*` | `CircleAvatar(radius: 20 or 28, backgroundColor: …)` wrapping an `Icon`/`SvgPicture` |
| `text-input(-focused)` | `TextField` with the `inputDecorationTheme` above |
| `card-surface-1/2` | `Container(decoration: BoxDecoration(color: …, borderRadius: BorderRadius.circular(KRadius.xl)))` |
| `gradient-spotlight-*` | `Container(decoration: BoxDecoration(gradient: KColors.auroraGradient, borderRadius: BorderRadius.circular(KRadius.xxl)))` |
| `avatar-monogram(-selected)` | `CircleAvatar` + `Text` initials; selected = `Container` wrapper with `Border.all(color: accentBlue, width: 2)` |
| `status-chip-*` | `Chip` or custom `Container` + `StadiumBorder`, background `color.withOpacity(0.14)` |
| `transaction-row` | `ListTile` (or custom `Row`) + `Divider(color: hairlineSoft, height: 1)` — no `Card` wrapper |

### 7. Notes for the Flutter team
- No bottom `NavigationBar`/`BottomNavigationBar` — navigation is via in-page `showModalBottomSheet` / `Navigator.push` triggered from quick actions and row taps, keeping a single scrolling home `Scaffold`.
- Respect `ThemeMode.system` — both `theme` and `darkTheme` must be supplied; never hardcode one palette.
- Keep `letterSpacing` negative values exactly as specified on display styles; do not let Flutter's default (`0`) creep back in via unstyled `Text` widgets — always route display text through `Theme.of(context).textTheme`.
- Gradient spotlight cards: cap at one visible per screen.
- Accent blue never becomes a `ButtonStyle.backgroundColor` — lint/PR-check for this if possible.
