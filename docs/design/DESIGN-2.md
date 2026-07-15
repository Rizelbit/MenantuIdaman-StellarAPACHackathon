<!--
CHANGELOG — v1.0 → v1.1 (read this first if you're implementing against an existing v1.0 build)

1. TYPEFACE: Inter is removed entirely. Manrope is now the only typeface in the system, for display
   AND body/UI text. Grep the codebase for `GoogleFonts.inter` / any Inter font asset and replace with
   `GoogleFonts.manrope` at the same size/weight/letterSpacing.

2. UNITS: every font-size, letter-spacing, padding, gap, radius, and component-size token is now
   expressed in rem (1rem = 16px root = 16dp/sp in Flutter). See "The Rem Rule" section. Px values in
   the Flutter code samples are unchanged numerically (rem * 16) — no visual resize, just a spec-unit
   change — EXCEPT where called out in points 3-5 below, which ARE real size corrections.

3. AVATAR SIZES: was a loose "40-56px" range. Now pinned to exactly three sizes used in the shipped
   screens: 40px (transaction rows), 52px (family shortcuts row), 56px (avatar showcase / selected).
   Audit existing avatar widgets against context and fix any that used an arbitrary in-between size.

4. TRANSACTION ROW HEIGHT: was a flat 64px spec that some screens implemented as 68px (14px vertical
   padding + 40px avatar). Standardize ALL list screens (Home "Recent", History) on the 64px variant:
   11px vertical padding + 40px avatar. Fix any row using 14px padding.

5. ICON BUTTONS: confirmed 40px everywhere (header back/notification buttons) — if any screen scaled
   these up or down, correct to 40px.

6. NEW COMPONENTS (Welcome / Face ID screen — did not exist in v1.0):
   - `icon-tile-lg`: 72px, rounded 22px, surface2 background, accentBlue icon — Face ID glyph tile.
   - `brand-badge`: 64px circular, accentBlue background, white icon — Kirimin mark on Welcome.
   Implement these at the exact sizes in `KSize` (theme tokens section), not eyeballed from the mock.

7. Accent blue, gradients, dark/light color tokens are UNCHANGED from v1.0 — no action needed there.
-->

---
version: 1.1
name: Kirimin
description: "A dark-first finance app for sending money to family and splitting bills. Near-black tonal-lift surfaces, a single typeface (Manrope) carrying both poster-grade display type and all UI/body text, and one confident blue (#0099FF) reserved for links, focus, and selection. One gradient 'spotlight' card is the only decorative/atmospheric device. Full inverse light palette included for system light mode. All type and spacing values are specified in rem (root 16px) for exact web/Flutter parity."

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

# All fontSize / letterSpacing / spacing / size values are in rem. Root = 16px, so 1rem = 16px = 16dp/sp in Flutter.
typography:
  display-xxl: { fontFamily: Manrope, fontWeight: 700, fontSize: 6.875rem, lineHeight: 0.85, letterSpacing: -0.344rem }   # 110px / -5.5px — hero cover only
  display-xl:  { fontFamily: Manrope, fontWeight: 700, fontSize: 4.25rem,  lineHeight: 0.95, letterSpacing: -0.266rem }   # 68px / -4.25px — section headers
  display-lg:  { fontFamily: Manrope, fontWeight: 600, fontSize: 3.25rem,  lineHeight: 1.00, letterSpacing: -0.194rem }   # 52px / -3.1px
  display-md:  { fontFamily: Manrope, fontWeight: 600, fontSize: 2rem,     lineHeight: 1.13, letterSpacing: -0.063rem }   # 32px / -1.0px — balance-style figures
  headline:    { fontFamily: Manrope, fontWeight: 700, fontSize: 1.375rem, lineHeight: 1.20, letterSpacing: -0.05rem }    # 22px / -0.8px — section labels ("Recent activity")
  subhead:     { fontFamily: Manrope, fontWeight: 700, fontSize: 1.0625rem,lineHeight: 1.2,  letterSpacing: -0.025rem }   # 17px / -0.4px — card/row group titles; also carries eyebrow/section labels (optionally uppercase, letter-spacing 0.14em) where a caption was previously used
  body-lg:     { fontFamily: Manrope, fontWeight: 400, fontSize: 1.125rem, lineHeight: 1.30, letterSpacing: -0.011rem }  # 18px
  body:        { fontFamily: Manrope, fontWeight: 400, fontSize: 0.9375rem,lineHeight: 1.30, letterSpacing: -0.009rem }  # 15px
  body-sm:     { fontFamily: Manrope, fontWeight: 600, fontSize: 0.875rem, lineHeight: 1.40, letterSpacing: -0.009rem }  # 14px — row titles, buttons
  micro:       { fontFamily: Manrope, fontWeight: 400, fontSize: 0.75rem,  lineHeight: 1.20, letterSpacing: -0.008rem }  # 12px — meta/timestamps
  button:      { fontFamily: Manrope, fontWeight: 600, fontSize: 0.875rem, lineHeight: 1.0,  letterSpacing: -0.009rem } # 14px
  mono-annotation: { fontFamily: "ui-monospace, Menlo, monospace", fontWeight: 400, fontSize: 0.75rem, lineHeight: 1.2 } # handoff/dart-file labels only, never in-product

rounded:
  xs: 0.25rem    # 4px  chips
  sm: 0.375rem   # 6px
  md: 0.625rem   # 10px inputs
  lg: 0.9375rem  # 15px
  xl: 1.25rem    # 20px cards
  xxl: 1.375rem  # 22px balance/spotlight cards
  pill: 6.25rem  # 100px CTAs
  full: 9999px   # circular (avatars/icon buttons — intentionally unitless/px, not a rem-scalable radius)

spacing:
  hair: 0.0625rem  # 1px
  xxs: 0.25rem     # 4px
  xs: 0.5rem       # 8px
  sm: 0.75rem      # 12px
  md: 0.875rem     # 14px
  lg: 1.25rem      # 20px
  xl: 1.625rem     # 26px
  xxl: 2.5rem      # 40px
  section: 6rem    # 96px

# Component sizing reconciled against the built screens (Home, Send, Receive, Request, Split Bill, Welcome) —
# use these exact values in Flutter; several earlier spec numbers (e.g. row height, icon-button size) had drifted from implementation.
components:
  button-primary:
    background: "{colors.ink}"          # white on dark canvas / near-black on light (inverse)
    text: "{colors.canvas}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "0.75rem 1.25rem"   # 12px 20px
  button-primary-large:               # full-width CTAs (Send, Split, Welcome Face ID)
    extends: button-primary
    padding: "1rem"               # 16px
    fontSize: 1rem                 # 16px
  button-secondary:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    typography: "{typography.button}"
    fontWeight: 500
    rounded: "{rounded.pill}"
    padding: "0.75rem 1.25rem"   # 12px 20px
  button-icon-circular:
    background: "{colors.surface1}"
    size: 2.5rem                    # 40px — header icon buttons (notification, back)
    rounded: "{rounded.full}"
  quick-action-primary:
    background: "{colors.ink}"
    iconColor: "{colors.canvas}"
    size: 3.5rem                    # 56px
    rounded: "{rounded.full}"
  quick-action-secondary:
    background: "{colors.surface1}"
    iconColor: "{colors.ink}"
    size: 3.5rem                    # 56px
    rounded: "{rounded.full}"
  text-input:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "0.75rem 0.875rem"   # 12px 14px
  text-input-focused:
    extends: text-input
    ring: "0 0 0 0.1875rem rgba(0,153,255,0.18)"  # 3px
    border: "0.0625rem solid {colors.accentBlue}" # 1px
  card-surface-1:
    background: "{colors.surface1}"
    text: "{colors.ink}"
    rounded: "{rounded.xl}"
    padding: "1.375rem"   # 22px
  card-surface-2:
    background: "{colors.surface2}"
    text: "{colors.ink}"
    rounded: "{rounded.xxl}"
    padding: "1.375rem"   # 22px
  gradient-spotlight-aurora:
    background: "linear-gradient(140deg, {colors.gradientAuroraStart} 0%, {colors.gradientAuroraMid} 55%, {colors.gradientAuroraEnd} 100%)"
    text: "#FFFFFF"
    rounded: "{rounded.xxl}"
    padding: "1.375rem"   # 22px
  gradient-spotlight-sunset:
    background: "linear-gradient(140deg, {colors.gradientSunsetStart} 0%, {colors.gradientSunsetMid} 55%, {colors.gradientSunsetEnd} 100%)"
    text: "#1A1207"
    rounded: "{rounded.xxl}"
    padding: "1.375rem"   # 22px
  avatar-monogram:
    background: "{colors.surface2}"
    text: "{colors.ink}"
    size: [2.5rem, 3.25rem, 3.5rem]   # 40px transaction rows · 52px family row · 56px avatar showcase
    rounded: "{rounded.full}"
  avatar-selected:
    extends: avatar-monogram
    border: "0.125rem solid {colors.accentBlue}"  # 2px
  avatar-add-dashed:
    extends: avatar-monogram
    background: "{colors.surface1}"
    border: "0.0625rem dashed #3A3A3A"  # 1px, light: #CFCCC6
  icon-tile-lg:                          # Welcome screen Face ID tile
    background: "{colors.surface2}"
    iconColor: "{colors.accentBlue}"
    size: 4.5rem                          # 72px
    rounded: "{rounded.xxl}"
  brand-badge:                            # Welcome screen mark
    background: "{colors.accentBlue}"
    iconColor: "#FFFFFF"
    size: 4rem                            # 64px
    rounded: "{rounded.full}"
  status-chip-success:
    background: "rgba(34,197,94,0.14)"
    text: "{colors.success}"
    rounded: "{rounded.pill}"
    padding: "0.375rem 0.75rem"   # 6px 12px
  status-chip-danger:
    background: "rgba(239,68,68,0.14)"
    text: "{colors.danger}"
    rounded: "{rounded.pill}"
    padding: "0.375rem 0.75rem"
  status-chip-info:
    background: "rgba(0,153,255,0.14)"
    text: "{colors.accentBlue}"
    rounded: "{rounded.pill}"
    padding: "0.375rem 0.75rem"
  transaction-row:
    background: transparent
    divider: "{colors.hairlineSoft}"
    typography: "{typography.body-sm}"
    metaTypography: "{typography.micro}"
    avatarSize: "{components.avatar-monogram.size.0}"  # 2.5rem / 40px
    verticalPadding: "0.6875rem"   # 11px — matches shipped Home/History rows (not the old 64px flat spec)
    height: 4rem                  # 64px target when paired with 40px avatar + 11px vertical padding
---

## Overview

Kirimin is a single-screen money app for sending funds to family and splitting shared bills. The surface language is dark-first: `{colors.canvas}` near-black with a barely-there warm radial glow behind it for depth (never a flat, lifeless black). Hierarchy is carried by **tonal lift** — canvas → surface-1 → surface-2 — not by opacity or gray-on-gray tricks. **Manrope is the only typeface in the system** — display sizes at large, hard-negative tracking for a poster feel; the same family carries all body and UI text at near-neutral tracking. The only chromatic accent is `{colors.accentBlue}`, reserved strictly for links, focus rings, and selection — never a button fill. Money outcomes use green (received) / red (failed) — that's the only place status color appears. One gradient "spotlight" card (blue aurora or amber sunset) is used sparingly as the sole atmospheric/decorative device.

A full **inverse light palette** mirrors every dark token 1:1 so the same component spec renders correctly in system light mode.

**Key characteristics:**
- Two anchor surfaces per mode (canvas + ink), three surface-lift steps, one hairline.
- Single typeface (Manrope), -1% to -5% letter-spacing scaling with size at display sizes; near-neutral tracking below 1.375rem (22px).
- All primary actions are pills or full circles — never a squared button.
- `{colors.accentBlue}` only on links, focus rings, selected avatar border, and the "Split active" status chip — never a background fill.
- Gradient spotlight cards are scarce: one per screen max.
- No bottom tab bar — navigation happens from within the single home surface (sheets/pushes from quick actions and list rows).
- All type, spacing, radius, and component-size tokens are authored in **rem** (root 16px) for exact 1:1 handoff — see the Rem Rule section below.

## Colors

### Dark (primary)
- **Canvas** `{colors.canvas}` #090909 — page background, always paired with the soft off-center radial glow (see Depth).
- **Surface 1** `{colors.surface1}` #141414 — default content card, secondary button, icon buttons.
- **Surface 2** `{colors.surface2}` #1C1C1C — featured/balance card, avatar fill.
- **Hairline** `{colors.hairline}` #262626 / **Hairline Soft** `{colors.hairlineSoft}` #1A1A1A — dividers only, never a full border-box.
- **Ink** `{colors.ink}` #FFFFFF — all primary text and the primary-button fill.
- **Ink Muted** `{colors.inkMuted}` #999999 — secondary text, timestamps, deselected state.
- **Accent Blue** `{colors.accentBlue}` #0099FF — links, focus ring, selected-avatar border, "active" status chip, Face ID glyph. Never a CTA fill.
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
- ❌ A second typeface anywhere (no Inter, no system-serif fallback beyond the Manrope stack) — an earlier draft of this system specified Inter for body text; that has been fully replaced by Manrope everywhere.

## Typography

- **Manrope (400–800)** is the only typeface — display, headline, body, button, all of it. No second family, except the monospace annotation style reserved for Flutter/dart file-name labels in handoff docs (never shown in-product).
- Eyebrow/uppercase-tracked labels use **subhead**, not a dedicated caption style — there is no separate `caption` token.
- Letter-spacing tightens as size grows (-0.344rem at 6.875rem/110px down to near 0 at 0.75rem/12px) — never loosen this "for readability"; reduce size instead if space is tight.
- Weight stays narrow: display 600–700, body 400, body-sm/subhead/headline 600–700, micro 400–500. Hierarchy = size + tracking, not a weight ramp.
- `display-xxl`/`display-xl` are contextual hero sizes (cover/section headers scale between 4–6.875rem depending on composition budget) — treat the listed rem value as the max, not a fixed instance.

## The Rem Rule

Every size in this system — font-size, letter-spacing, padding, gap, radius, component dimensions — is authored in **rem against a 16px root**, so `1rem = 16px`. This is a straight numeric mapping into Flutter: **1rem = 16 logical pixels = 16dp = 16sp**. When porting a token, multiply the rem value by 16 to get the `double` you pass to `EdgeInsets`, `fontSize`, `SizedBox`, `BorderRadius.circular`, etc. Circular full-round radii (`{rounded.full}` = 9999px) are the one exception left in raw px, since they're a "large enough to always be a circle" sentinel, not a measured value.

## Layout & Spacing

Base unit 0.25rem (4px): `{spacing.xxs}` 0.25rem · `{spacing.xs}` 0.5rem · `{spacing.sm}` 0.75rem · `{spacing.md}` 0.875rem · `{spacing.lg}` 1.25rem · `{spacing.xl}` 1.625rem · `{spacing.xxl}` 2.5rem · `{spacing.section}` 6rem.
- Screen horizontal margin: 1.25rem (20px).
- Card interior padding: 1.375rem (22px).
- Vertical rhythm between home-screen blocks: 1.375rem (22px); between major spec sections: 6rem (96px).
- Row height (list/transaction): 4rem (64px) target — built from a 2.5rem (40px) avatar + 0.6875rem (11px) vertical padding top/bottom, hairline divider only, no per-row card. (A denser 4.25rem/68px variant appears where rows use 0.875rem/14px padding instead — pick one padding value per screen and stay consistent; don't mix both in the same list.)

## Depth

| Level | Treatment | Use |
|---|---|---|
| 0 | Flat, no shadow | List rows, dividers, text on canvas |
| Background glow | `radial-gradient(135% 78% at 20% 4%, {warm tone} 0%, {mid tone} 45%, {canvas} 80%)` — barely-there, low chroma | Full-screen background only |
| 1 | Surface-1 tonal lift | Default cards, secondary buttons |
| 2 | Surface-2 tonal lift | Featured/balance card, avatar fill, Face ID icon tile |
| 3 (focus) | `0 0 0 0.1875rem rgba(0,153,255,0.18)` + 0.0625rem accent border | Focused input only |
| Decorative | Gradient spotlight fill | One promo card per screen, max |

## Shapes

`{rounded.xs}` 0.25rem chips · `{rounded.md}` 0.625rem inputs · `{rounded.xl}` 1.25rem cards · `{rounded.xxl}` 1.375rem balance/spotlight/icon-tile · `{rounded.pill}` 6.25rem all CTAs · `{rounded.full}` circular avatars/icon buttons/brand badge.

## Components (reference)

See front-matter `components:` block for exact token bindings — button-primary(-large)/secondary, icon-circular, quick-action-primary/secondary, text-input(-focused), card-surface-1/2, gradient-spotlight-aurora/sunset, avatar-monogram(-selected/-add-dashed), icon-tile-lg, brand-badge, status-chip-success/danger/info, transaction-row.

**Corrections vs. earlier handoff (v1.0):** avatar sizes are a defined 3-value set (40/52/56px), not a loose "40-56px" range — use the one matching context (row/family-shortcut/showcase). Transaction-row height is pinned to a specific padding+avatar combination (64px), not a flat number applied inconsistently. Icon-circular buttons are 40px everywhere (header actions), never scaled up. Two new component tokens (`icon-tile-lg`, `brand-badge`) cover the Welcome/Face ID screen, which introduced sizes (72px, 64px) not present in v1.0.

---

## Flutter Transferability

### 1. Fonts
Add to `pubspec.yaml` (or use `google_fonts` package):
```yaml
dependencies:
  google_fonts: ^6.2.1
```
```dart
final appFont = GoogleFonts.manrope; // the only font family in the app
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

// 1rem = 16.0 logical pixels — every value below is (rem token * 16)
class KRadius {
  static const xs = 4.0, sm = 6.0, md = 10.0, lg = 15.0, xl = 20.0, xxl = 22.0, pill = 100.0, full = 9999.0;
}

class KSpace {
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 14.0, lg = 20.0, xl = 26.0, xxl = 40.0, section = 96.0;
}

class KSize {
  static const iconButton = 40.0;      // button-icon-circular
  static const quickAction = 56.0;     // quick-action-primary/secondary
  static const avatarSm = 40.0;        // avatar-monogram in transaction rows
  static const avatarMd = 52.0;        // avatar-monogram in family shortcuts
  static const avatarLg = 56.0;        // avatar-monogram showcase / selected
  static const iconTileLg = 72.0;      // Welcome screen Face ID tile
  static const brandBadge = 64.0;      // Welcome screen mark
  static const rowHeight = 64.0;       // transaction-row target
}
```

### 3. Text theme (`lib/theme/text_theme.dart`)
```dart
TextTheme buildTextTheme(Color ink) => TextTheme(
  displayLarge:  GoogleFonts.manrope(fontSize: 110, height: 0.85, fontWeight: FontWeight.w700, letterSpacing: -5.5, color: ink),  // display-xxl
  displayMedium: GoogleFonts.manrope(fontSize: 68,  height: 0.95, fontWeight: FontWeight.w700, letterSpacing: -4.25, color: ink), // display-xl
  displaySmall:  GoogleFonts.manrope(fontSize: 52,  height: 1.00, fontWeight: FontWeight.w600, letterSpacing: -3.1, color: ink),  // display-lg
  headlineLarge: GoogleFonts.manrope(fontSize: 32,  height: 1.13, fontWeight: FontWeight.w600, letterSpacing: -1.0, color: ink),  // display-md
  headlineMedium:GoogleFonts.manrope(fontSize: 22,  height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: ink),  // headline
  titleMedium:   GoogleFonts.manrope(fontSize: 17,  height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: ink),  // subhead
  bodyLarge:     GoogleFonts.manrope(fontSize: 18,  height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.18, color: ink),
  bodyMedium:    GoogleFonts.manrope(fontSize: 15,  height: 1.30, fontWeight: FontWeight.w400, letterSpacing: -0.15, color: ink),
  bodySmall:     GoogleFonts.manrope(fontSize: 14,  height: 1.40, fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink), // row titles
  labelMedium:   GoogleFonts.manrope(fontSize: 14,  height: 1.0,  fontWeight: FontWeight.w600, letterSpacing: -0.14, color: ink), // button
  labelSmall2:   GoogleFonts.manrope(fontSize: 12,  height: 1.20, fontWeight: FontWeight.w400, letterSpacing: -0.12, color: ink), // micro/meta — add as a custom style, TextTheme has no 7th label slot
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
        textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.14),
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
| Token | Flutter widget | Size |
|---|---|---|
| `button-primary` | `ElevatedButton` (themed above) | pill, 12/20 padding |
| `button-primary-large` | `ElevatedButton` full width | pill, 16 padding, 16sp text |
| `button-secondary` | `TextButton` with `StadiumBorder`, `backgroundColor: surface1` | pill, 12/20 padding |
| `button-icon-circular` | `CircleAvatar(radius: 20, backgroundColor: surface1)` wrapping an `Icon` | 40×40 (`KSize.iconButton`) |
| `quick-action-primary/secondary` | `CircleAvatar(radius: 28, …)` | 56×56 (`KSize.quickAction`) |
| `text-input(-focused)` | `TextField` with the `inputDecorationTheme` above | — |
| `card-surface-1/2` | `Container(decoration: BoxDecoration(color: …, borderRadius: BorderRadius.circular(KRadius.xl)))` | 22 padding |
| `gradient-spotlight-*` | `Container(decoration: BoxDecoration(gradient: KColors.auroraGradient, borderRadius: BorderRadius.circular(KRadius.xxl)))` | 22 padding |
| `avatar-monogram(-selected)` | `CircleAvatar` + `Text` initials; selected = `Container` wrapper with `Border.all(color: accentBlue, width: 2)` | 40 / 52 / 56 (`KSize.avatarSm/Md/Lg`) |
| `icon-tile-lg` | `Container` rounded 22, `surface2` bg, centered `Icon`/`SvgPicture` (accentBlue) | 72×72 (`KSize.iconTileLg`) |
| `brand-badge` | `CircleAvatar(backgroundColor: accentBlue)` + icon | 64×64 (`KSize.brandBadge`) |
| `status-chip-*` | `Chip` or custom `Container` + `StadiumBorder`, background `color.withOpacity(0.14)` | 6/12 padding |
| `transaction-row` | `ListTile` (or custom `Row`) + `Divider(color: hairlineSoft, height: 1)` — no `Card` wrapper | 64 target height |

### 7. Notes for the Flutter team
- No bottom `NavigationBar`/`BottomNavigationBar` — navigation is via in-page `showModalBottomSheet` / `Navigator.push` triggered from quick actions and row taps, keeping a single scrolling home `Scaffold`. The Welcome screen is the sole exception (a full-screen route shown pre-auth, not part of the scrolling home surface).
- Respect `ThemeMode.system` — both `theme` and `darkTheme` must be supplied; never hardcode one palette.
- Keep `letterSpacing` negative values exactly as specified on display styles; do not let Flutter's default (`0`) creep back in via unstyled `Text` widgets — always route display text through `Theme.of(context).textTheme`.
- **Single font family**: confirm no `Inter`/other family references remain anywhere in the codebase (an earlier design draft specified Inter for body text — fully superseded by Manrope; grep for `GoogleFonts.inter` before merging).
- Standardize `transaction-row` on the 64px/11px-padding variant across every list screen (Home "Recent", History) — don't let some screens use the 68px/14px-padding variant found in early component mockups.
- Gradient spotlight cards: cap at one visible per screen.
- Accent blue never becomes a `ButtonStyle.backgroundColor` — lint/PR-check for this if possible.
- Welcome/Face ID screen: use `local_auth` for the biometric call: the Face ID button and icon tile are new components (`icon-tile-lg`, `brand-badge`) not present in the original v1.0 handoff — implement per the sizes in `KSize` above rather than guessing dimensions from the mock.
