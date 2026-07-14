# Kirimin Design-System Rebuild — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Kirimin's entire visual layer (theme + widgets + screens) with the imported "Kirimin Screens" design — dark+light, Manrope/Inter, blue accent, pill CTAs — and build all 6 flows (~16 screens) interactive on mock data, keeping routing/state/services/models.

**Architecture:** Keep the brain (go_router shell + auth redirect, Riverpod controllers, `Result`/`Ok`/`Err` services, `Env.useMock` injection, money/FX core, data models); delete and rebuild the skin. New `lib/theme/` ports `docs/DESIGN.md`; a new `lib/widgets/` kit maps the design's component list; new models/controllers/mock-data drive the new flows; every screen is rebuilt on the kit.

**Tech Stack:** Flutter (Material 3), `flutter_riverpod`, `go_router`, `google_fonts` (Manrope + Inter), `intl`. No new packages.

## Global Constraints

- **Design tokens are the only source of color/space/type** — never hardcode a hex in a widget/screen. Read via `KColors`/`KRadius`/`KSpace`/`Theme.of(context)`. (verbatim: `docs/DESIGN.md`)
- **Accent blue `#0099FF` is signal-only** — links, focus ring, selected-avatar border, "active" status chip. **Never** a button or card fill.
- **Display text routes through `Theme.of(context).textTheme`** so negative letter-spacing is never lost to Flutter's default `0`.
- **One gradient spotlight card per screen, max.**
- **No bottom tab/navigation bar** — navigation is push routes + sheets from within screens.
- **Theme:** supply both `theme` and `darkTheme`; `ThemeMode.system`; no widget hardcodes one palette.
- **UI copy is Indonesian** (Kirim/Minta/Split/Terima/Riwayat…), matching the existing app and the "no-crypto, Bahasa-first" north star — even though the design deck's mockups show English labels. No crypto terms surface in UI (no seed phrase/wallet/gas; amounts always `Rp`).
- **Completion gate:** `flutter analyze` reports **zero** issues on every touched file (const hoisting, arg order, `library;` directives, import collisions). Run from `frontend/`.
- **Demo fee = Rp 0** (`Env.feeRate = 0`) to match the deck's "No admin fee".
- **Money formatting only via `core/money.dart`** (`formatMoney`, `SendQuote`). Screens never format numbers themselves.
- Working dir for all Flutter commands: `frontend/`. Git commits from repo root `MenantuIdaman-StellarAPACHackathon/`.
- End every commit message with: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

**Design frame reference:** exact per-screen layout/copy lives in Claude Design project
`7113bcb7-4e1a-4781-9cac-d2ec53bb9029` → `Kirimin Screens.dc.html` (read a frame with
`DesignSync get_file` when building a screen). Each screen task below embeds the frame's component
list + verbatim copy so the frame is a visual cross-check, not a dependency.

---

## Phase 1 — Theme foundation

### Task 1: Design tokens

**Files:**
- Create: `frontend/lib/theme/tokens.dart`
- Delete (later, in Task 4): `frontend/lib/app/theme.dart`

**Interfaces:**
- Produces: `KColors` (per-brightness getters via `KColors.of(Brightness)` returning a `KPalette`), `KRadius`, `KSpace`, `KColors.auroraGradient`, `KColors.sunsetGradient`.

- [ ] **Step 1: Write `tokens.dart`** with the exact values from `docs/DESIGN.md`:

```dart
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
```

- [ ] **Step 2: Verify it analyzes clean**

Run: `cd frontend && flutter analyze lib/theme/tokens.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add frontend/lib/theme/tokens.dart
git commit -m "feat(theme): design tokens (KColors/KRadius/KSpace) from Claude Design

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Text theme

**Files:**
- Create: `frontend/lib/theme/text_theme.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `TextTheme buildTextTheme(Color ink)`.

- [ ] **Step 1: Write `text_theme.dart`** (Manrope display, Inter body; negative tracking exact per `docs/DESIGN.md`):

```dart
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
```

- [ ] **Step 2: Analyze clean** — `cd frontend && flutter analyze lib/theme/text_theme.dart` → `No issues found!`
- [ ] **Step 3: Commit** — `git add frontend/lib/theme/text_theme.dart && git commit -m "feat(theme): Manrope/Inter text theme + tabular money style" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"`

---

### Task 3: App theme + `main.dart` wiring

**Files:**
- Create: `frontend/lib/theme/app_theme.dart`
- Modify: `frontend/lib/main.dart`

**Interfaces:**
- Consumes: `KColors`, `KRadius`, `buildTextTheme`.
- Produces: `ThemeData buildTheme({required bool dark})`.

- [ ] **Step 1: Write `app_theme.dart`:**

```dart
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
```

- [ ] **Step 2: Rewrite `main.dart`** to wire both themes + system mode:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: KiriminApp()));
}

class KiriminApp extends ConsumerWidget {
  const KiriminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kirimin',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(dark: false),
      darkTheme: buildTheme(dark: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 3: Analyze** — `cd frontend && flutter analyze lib/theme/app_theme.dart lib/main.dart`. Expected: `main.dart` will still fail to fully analyze only if old `app/theme.dart` is imported elsewhere; those come out in later tasks. `app_theme.dart` itself: `No issues found!`
- [ ] **Step 4: Commit** — `git add frontend/lib/theme/app_theme.dart frontend/lib/main.dart && git commit -m "feat(theme): dark+light ThemeData + wire ThemeMode.system in main" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"`

---

### Task 4: GlowBackground + AppScaffold; delete old theme

**Files:**
- Create: `frontend/lib/widgets/glow_background.dart`
- Create: `frontend/lib/widgets/app_scaffold.dart` (replaces old one)
- Delete: `frontend/lib/app/theme.dart`

**Interfaces:**
- Consumes: `KColors`, `KSpace`.
- Produces: `GlowBackground({child})`; `AppScaffold({title?, child, bottom?, scrollable=true, leading?, actions?})`.

- [ ] **Step 1: `glow_background.dart`** (radial glow, brightness-aware):

```dart
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Full-screen background: canvas + a barely-there off-center radial glow so the
/// dark is never flat. Light mode uses a warm off-white glow.
class GlowBackground extends StatelessWidget {
  final Widget child;
  const GlowBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.9),
          radius: 1.3,
          colors: dark
              ? const [Color(0xFF1A160F), Color(0xFF0E0C0A), Color(0xFF090909)]
              : const [Color(0xFFFDFBF7), Color(0xFFF7F4EF), Color(0xFFFFFFFF)],
          stops: const [0.0, 0.45, 0.8],
        ),
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 2: `app_scaffold.dart`** (no bottom nav; glow background; adaptive overlay):

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';
import 'glow_background.dart';

/// Standard page shell. Every screen uses this for consistent padding, optional
/// title/back, and an optional pinned bottom CTA. No bottom navigation bar.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom;
  final bool scrollable;
  final Widget? leading;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.bottom,
    this.scrollable = true,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = Padding(padding: KSpace.screenH, child: child);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: GlowBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: title == null
              ? null
              : AppBar(title: Text(title!), leading: leading, actions: actions),
          body: SafeArea(
            top: title == null,
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: KSpace.xl), child: body)
                : body,
          ),
          bottomNavigationBar: bottom == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(KSpace.lg, 0, KSpace.lg, KSpace.lg),
                  child: bottom,
                ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Delete old theme** — `git rm frontend/lib/app/theme.dart` (screens/widgets that import it are deleted/rebuilt in later tasks; app won't compile fully until Phase 4 — expected).
- [ ] **Step 4: Analyze the two new files** — `cd frontend && flutter analyze lib/widgets/glow_background.dart lib/widgets/app_scaffold.dart` → `No issues found!`
- [ ] **Step 5: Commit** — `git add -A frontend/lib/widgets/glow_background.dart frontend/lib/widgets/app_scaffold.dart frontend/lib/app/theme.dart && git commit -m "feat(ui): GlowBackground + AppScaffold; remove old theme" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"`

---

## Phase 2 — Widget kit

> All kit widgets read palette via `KColors.of(Theme.of(context).brightness)`. Old widget files
> (`buttons.dart`, `money_widgets.dart`, `states.dart`, `transaction_tile.dart`) are replaced across
> Tasks 5–8; delete each as its replacement lands.

### Task 5: Buttons — pill, icon, quick action

**Files:**
- Create: `frontend/lib/widgets/pill_button.dart`, `frontend/lib/widgets/icon_button.dart`, `frontend/lib/widgets/quick_action.dart`
- Delete: `frontend/lib/widgets/buttons.dart`

**Interfaces:**
- Produces: `PrimaryPillButton({label, icon?, onPressed, loading=false})`, `SecondaryPillButton({label, icon?, onPressed})`, `CircleIconButton({icon, onPressed, filled=false})`, `QuickAction({icon, label, onPressed, primary=false})`.

- [ ] **Step 1:** `pill_button.dart` — `PrimaryPillButton` = themed `ElevatedButton` (ink fill, stadium, height 52), optional leading icon, `loading` swaps child for a 20px `CircularProgressIndicator` in `onPrimary`. `SecondaryPillButton` = `ElevatedButton` with `styleFrom(backgroundColor: KColors.of(b).surface1, foregroundColor: ink, shape: StadiumBorder())`. Full code follows the button-primary/secondary tokens (fill from tokens, `StadiumBorder`, padding 12/20 already in theme; only override background for secondary).
- [ ] **Step 2:** `icon_button.dart` — `CircleIconButton`: 40px `Material`/`InkWell` circle, `filled ? ink : surface1` background, icon color `filled ? canvas : ink`, `KRadius.full`.
- [ ] **Step 3:** `quick_action.dart` — `QuickAction`: column of a 56px circle (`primary ? ink : surface1`, icon `primary ? canvas : ink`) + `KSpace.xs` gap + `labelSmall`-ish caption in `ink`. Whole column tappable.
- [ ] **Step 4:** `git rm frontend/lib/widgets/buttons.dart`.
- [ ] **Step 5: Analyze** the 3 new files → `No issues found!`
- [ ] **Step 6: Commit** — `git commit -m "feat(ui): pill/icon/quick-action buttons; remove old buttons"` (+ co-author trailer).

**Reference `pill_button.dart` (full):**
```dart
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class PrimaryPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  const PrimaryPillButton(
      {required this.label, this.onPressed, this.icon, this.loading = false, super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: p.canvas))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: KSpace.xs)],
                Text(label),
              ],
            ),
    );
  }
}

class SecondaryPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const SecondaryPillButton({required this.label, this.onPressed, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: p.surface1,
        foregroundColor: p.ink,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: KSpace.xs)],
          Text(label),
        ],
      ),
    );
  }
}
```

---

### Task 6: Cards, gradient spotlight, avatar, status chip

**Files:**
- Create: `frontend/lib/widgets/cards.dart` (`SurfaceCard`, `GradientSpotlight`), `frontend/lib/widgets/avatar.dart` (`MonogramAvatar`), `frontend/lib/widgets/status_chip.dart` (`StatusChip`)

**Interfaces:**
- Produces:
  - `SurfaceCard({child, elevated=false, padding=22, onTap?})` — `elevated` → surface2 + `KRadius.xxl`, else surface1 + `KRadius.xl`.
  - `GradientSpotlight({child, sunset=false, padding=22})` — aurora default; text color white (aurora) / `#1A1207` (sunset).
  - `MonogramAvatar({initials, size=44, selected=false})` — surface2 circle, ink text; `selected` adds 2px accent border.
  - `StatusChip.success/danger/info(String label)` — pill, `color.withValues(alpha: 0.14)` bg, colored text.

- [ ] **Step 1:** Write the three files per interfaces above (complete widget code; colors via `KColors.of`).
- [ ] **Step 2: Analyze** → `No issues found!`
- [ ] **Step 3: Commit** — `feat(ui): surface/spotlight cards, monogram avatar, status chip`.

---

### Task 7: Transaction row, money text, keypad, sheets, states

**Files:**
- Create: `frontend/lib/widgets/transaction_row.dart`, `frontend/lib/widgets/money_text.dart`, `frontend/lib/widgets/amount_keypad.dart`, `frontend/lib/widgets/sheets.dart`, `frontend/lib/widgets/states.dart`
- Delete: `frontend/lib/widgets/money_widgets.dart`, `frontend/lib/widgets/states.dart` (old), `frontend/lib/widgets/transaction_tile.dart`

**Interfaces:**
- Produces:
  - `TransactionRow({avatarInitials?, icon?, title, subtitle, amountIdr, direction (TxDirection), onTap?})` — 64px row, hairline divider, signed amount colored: `receive` → `+`/success, `send`/`split` → `−`/ink (danger only on failed). Consumes `AppTransaction` fields (see Task 9).
  - `MoneyText({amountIdr, size, hidden=false})` — tabular Manrope via `moneyStyle`; `hidden` → `Rp ••••••`. Uses `formatMoney(amountIdr, Currency.idr)`.
  - `AmountKeypad({onKey(String digit), onBackspace()})` — 3×4 grid `1-9`, `000`, `0`, backspace icon; borderless, ink text.
  - `showBiometricConfirmSheet(context, {headline, subline, confirmLabel})` → `Future<bool>` — Face ID sheet; confirm = `PrimaryPillButton`.
  - `EmptyView({icon, title, subtitle})`, `LoadingView()`.
- Note: `TxDirection` enum lives in models (Task 9). This task may reference it; sequence Task 9 before wiring, or define the enum here and re-home — **decision: define `enum TxDirection { send, receive, split }` in `models.dart` (Task 9)** and Task 7 imports it. If executing Task 7 first, add the enum stub to `models.dart` now.

- [ ] **Step 1:** Ensure `enum TxDirection { send, receive, split }` exists in `models.dart` (add if Task 9 not yet done).
- [ ] **Step 2:** Write the five files.
- [ ] **Step 3:** `git rm` old `money_widgets.dart`, `transaction_tile.dart` (and overwrite `states.dart`).
- [ ] **Step 4: Analyze** → `No issues found!`
- [ ] **Step 5: Commit** — `feat(ui): transaction row, money text, keypad, biometric sheet, states`.

---

### Task 8: Widget barrel + kit gallery smoke

**Files:**
- Create: `frontend/lib/widgets/widgets.dart` (barrel)
- Test: `frontend/test/kit_smoke_test.dart`

- [ ] **Step 1:** Barrel exports every kit file:
```dart
/// Barrel — one import for the whole UI kit: `import '../widgets/widgets.dart';`
library;
export 'app_scaffold.dart';
export 'glow_background.dart';
export 'pill_button.dart';
export 'icon_button.dart';
export 'quick_action.dart';
export 'cards.dart';
export 'avatar.dart';
export 'status_chip.dart';
export 'transaction_row.dart';
export 'money_text.dart';
export 'amount_keypad.dart';
export 'sheets.dart';
export 'states.dart';
```
- [ ] **Step 2:** Write `kit_smoke_test.dart` — pump each kit widget inside `MaterialApp(theme: buildTheme(dark:true), home: Scaffold(body: <widget>))`; `expect(find.byType(...), findsOneWidget)`. Covers `PrimaryPillButton`, `SurfaceCard`, `GradientSpotlight`, `MonogramAvatar`, `StatusChip`, `TransactionRow`, `MoneyText`, `AmountKeypad`.
- [ ] **Step 3: Run** — `cd frontend && flutter test test/kit_smoke_test.dart` → all pass.
- [ ] **Step 4: Analyze** — `cd frontend && flutter analyze lib/widgets` → `No issues found!`
- [ ] **Step 5: Commit** — `test(ui): kit barrel + widget smoke test`.

---

## Phase 3 — Data layer

### Task 9: Models

**Files:**
- Modify: `frontend/lib/models/models.dart`

**Interfaces:**
- Produces: `Contact`, `PromoBanner`, `SpotlightVariant`, `MoneyRequest`, `RequestStatus`, `SplitBill`, `SplitParticipant`, `ParticipantStatus`, `TxDirection`; extended `AppTransaction` with `type`, `reference`, `note`.

- [ ] **Step 1:** Add models (keep existing `Wallet`, passkey envelopes). Extend `AppTransaction`:
```dart
enum TxDirection { send, receive, split }

class AppTransaction {
  final String id;
  final String counterpartyName;   // was recipientName
  final double amountIdr;
  final DateTime createdAt;
  final TxStatus status;
  final TxDirection direction;
  final String? reference;         // e.g. KRM-8F2A091
  final String? note;
  const AppTransaction({
    required this.id,
    required this.counterpartyName,
    required this.amountIdr,
    required this.createdAt,
    required this.status,
    this.direction = TxDirection.send,
    this.reference,
    this.note,
  });
}
```
- [ ] **Step 2:** Add `Contact { id, name, relation, initials, accountRef, isFavorite, lastSentAt? }` (const ctor); `SpotlightVariant { aurora, sunset }`; `PromoBanner { id, title, subtitle, ctaLabel, deepLink, badge?, spotlight }`; `RequestStatus { pending, paid, declined, expired }`; `MoneyRequest { id, fromContactId, amountIdr, note?, status, createdAt }`; `ParticipantStatus { pending, paid }`; `SplitParticipant { contactId, name, shareIdr, isSelf, status }` (with `copyWith`); `SplitBill { id, title, totalIdr, createdAt, participants }` with getters `collectedIdr` (Σ paid shares) and `isBalanced` (Σ shares == totalIdr).
- [ ] **Step 3:** Grep for old field name — `cd frontend && grep -rn "recipientName" lib` — every hit is in files being rebuilt (`send_controller.dart`, mocks); update `send_controller.dart` + `mock_services.dart` references to `counterpartyName`/`direction` now to keep them compiling.
- [ ] **Step 4: Analyze** — `cd frontend && flutter analyze lib/models lib/state/send_controller.dart lib/services/mock_services.dart` → `No issues found!`
- [ ] **Step 5: Commit** — `feat(models): contacts, promos, requests, split bill; extend transaction`.

---

### Task 10: Mock data + service surface

**Files:**
- Modify: `frontend/lib/services/wallet_api.dart` (add stubbed endpoint signatures + handoff TODOs), `frontend/lib/services/mock_services.dart` (implement with mock data)
- Create: `frontend/lib/services/mock_data.dart` (the seed dataset)

**Interfaces:**
- Produces on `WalletApi`: `Future<Result<HomeFeed>> getHomeFeed(String userId)`, `Future<Result<List<Contact>>> listContacts(String userId)`, `Future<Result<Contact>> addContact(...)`, `Future<Result<MoneyRequest>> createRequest(...)`, `Future<Result<SplitBill>> createSplit(...)`, `Future<Result<SplitBill>> getSplit(String id)`. `HomeFeed { balanceIdr, greetingName, promos, favoriteContacts, recentTransactions }` (define in `models.dart` or `mock_data.dart`).

- [ ] **Step 1:** `mock_data.dart` — seed from `docs/specs/mobile-ui-handoff-spec.md` + the deck: greeting `Rani`, account `•••• 4821`, balance `4250000`; contacts Ibu (`IB`, Mother, `•••• 3092`, fav), Ayu (Adik) (`AY`, Sister, `•••• 7741`, fav), Pak Slamet (`PS`, Father, `•••• 5510`); 2 promos (Split-launch = sunset spotlight, badge "Baru"; Fee-transparency = aurora); recent tx (Ibu send 995.000 success today; Electricity split 150.000 pending; Ayu receive 200.000 success 9 Jul; + Slamet send 500.000, Ibu send 1.000.000 for History "This week"); 1 sample split (Listrik Juli 450.000, 3×150.000, Ibu paid / Ayu pending / You paid).
- [ ] **Step 2:** Add the new endpoint signatures to `WalletApi` throwing `UnimplementedError()` (real backend later) with `// TODO(handoff): see docs/backend_handoff.md` comments.
- [ ] **Step 3:** Implement them in `MockWalletApi` returning `Ok(...)` from `mock_data.dart` with `_mockDelay`; mutate in-memory so status/balance changes persist within a session.
- [ ] **Step 4: Analyze** — `cd frontend && flutter analyze lib/services lib/models` → `No issues found!`
- [ ] **Step 5: Commit** — `feat(services): mock data + home-feed/contacts/request/split endpoints`.

---

### Task 11: Home-feed + contacts controllers

**Files:**
- Create: `frontend/lib/state/home_feed.dart`, `frontend/lib/state/contacts_controller.dart`

**Interfaces:**
- Produces: `homeFeedProvider` (`FutureProvider<HomeFeed>` reading `walletApiProvider.getHomeFeed`); `contactsControllerProvider` (`NotifierProvider<ContactsController, List<Contact>>`) with `toggleFavorite(id)`, `addContact(...)`, and a `favoriteContacts` getter.

- [ ] **Step 1:** Write both, following `providers.dart` injection + `state/*` Notifier style.
- [ ] **Step 2: Analyze** → `No issues found!`
- [ ] **Step 3: Commit** — `feat(state): home-feed + contacts controllers`.

---

### Task 12: Request + split controllers (with split-math test)

**Files:**
- Create: `frontend/lib/state/request_controller.dart`, `frontend/lib/state/split_controller.dart`
- Test: `frontend/test/split_controller_test.dart`

**Interfaces:**
- Produces:
  - `requestControllerProvider` — `RequestState { fromContact?, amountIdr, note, status }`; `setContact`, `setAmount`, `setNote`, `submit()` → mock `createRequest`, sets `status = pending`, `reset()`.
  - `splitControllerProvider` — `SplitState { title, totalIdr, participants, splitEvenly }`; `setTotal`, `setTitle`, `toggleParticipant(Contact)`, `setSplitEvenly(bool)`, `setShare(contactId, idr)`, getters `assignedIdr` (Σ shares) + `isBalanced` (`assignedIdr == totalIdr`), `submit()` → mock `createSplit`.
  - Even split: when `splitEvenly` true or total/participants change, recompute each share = `totalIdr / n` with the remainder (from integer division) added to the first participant so `Σ == total` exactly.

- [ ] **Step 1: Write failing test** `split_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/state/split_controller.dart';
import 'package:frontend/models/models.dart';

void main() {
  ProviderContainer make() => ProviderContainer();
  const ibu = Contact(id: 'c1', name: 'Ibu', relation: 'Ibu', initials: 'IB', accountRef: '•••• 3092', isFavorite: true);
  const ayu = Contact(id: 'c2', name: 'Ayu', relation: 'Adik', initials: 'AY', accountRef: '•••• 7741', isFavorite: true);

  test('even split of 450000 across 3 (incl. self) => 150000 each, balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(450000);
    ctrl.toggleParticipant(ibu);
    ctrl.toggleParticipant(ayu); // + self is always a participant
    final s = c.read(splitControllerProvider);
    expect(s.participants.length, 3);
    expect(s.participants.every((p) => p.shareIdr == 150000), isTrue);
    expect(s.isBalanced, isTrue);
  });

  test('even split with remainder puts leftover on first participant, stays balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(100000);
    ctrl.toggleParticipant(ibu);
    ctrl.toggleParticipant(ayu); // 3-way of 100000 => 33334/33333/33333
    final s = c.read(splitControllerProvider);
    expect(s.assignedIdr, 100000);
    expect(s.isBalanced, isTrue);
  });

  test('manual override that breaks total is not balanced', () {
    final c = make();
    final ctrl = c.read(splitControllerProvider.notifier);
    ctrl.setTotal(450000);
    ctrl.toggleParticipant(ibu);
    ctrl.setSplitEvenly(false);
    ctrl.setShare('c1', 999999);
    expect(c.read(splitControllerProvider).isBalanced, isFalse);
  });
}
```
- [ ] **Step 2: Run — fails** (`splitControllerProvider` undefined). `cd frontend && flutter test test/split_controller_test.dart` → FAIL.
- [ ] **Step 3: Implement** `split_controller.dart` + `request_controller.dart` per interfaces (self is auto-added as a participant on init; even-split remainder rule as tested).
- [ ] **Step 4: Run — passes.** `cd frontend && flutter test test/split_controller_test.dart` → all pass.
- [ ] **Step 5: Analyze** — `cd frontend && flutter analyze lib/state` → `No issues found!`
- [ ] **Step 6: Commit** — `feat(state): request + split controllers with even/custom share math`.

---

## Phase 4 — Screens + routing

> Each screen task: build the screen on the kit, wire data from its controller, add its route to
> `router.dart`, then analyze clean. Copy below is verbatim from the deck (translate labels to
> Indonesian per Global Constraints). Read the matching frame from `Kirimin Screens.dc.html` for the
> exact visual arrangement. Each screen is a `ConsumerWidget`/`ConsumerStatefulWidget` on `AppScaffold`.

### Task 13: Re-skin splash + onboarding

**Files:** Modify `frontend/lib/screens/splash_screen.dart`, `frontend/lib/screens/onboarding_screen.dart`.

- [ ] **Step 1:** Splash — centered Kirimin wordmark (Manrope 800-ish `headlineLarge`) + the blue circle send-glyph badge on `GlowBackground`. Keep its existing role in the auth redirect.
- [ ] **Step 2:** Onboarding — headline + subhead + `PrimaryPillButton('Buat akun dengan Face ID')` calling `authControllerProvider.notifier.registerWithPasskey(...)`; keep existing controller call, only restyle to kit + tokens.
- [ ] **Step 3: Analyze** both → `No issues found!`
- [ ] **Step 4: Commit** — `feat(ui): re-skin splash + onboarding to new design`.

### Task 14: Home screen

**Files:** Modify `frontend/lib/screens/home_screen.dart`.
**Frame:** Home — `BalanceHero · PromoCarousel · QuickActionsRow · FamilyShortcuts · RecentTransactions`.
**Copy:** "Good evening, {name}" → "Selamat malam, Rani"; "Total balance" → "Total saldo"; "•••• 4821 · Main account" → "•••• 4821 · Rekening utama"; promo "Split the bill! …" → sunset `GradientSpotlight` with CTA "Ayo split"; quick actions **Kirim / Minta / Split / Terima**; "Send to family"→"Kirim ke keluarga" + "Manage"→"Kelola"; family shortcuts (favorites + "+ Tambah"); "Recent activity"→"Aktivitas terbaru" + "See all"→"Lihat semua" → 3 `TransactionRow`.

- [ ] **Step 1:** Build sections top-to-bottom reading `homeFeedProvider` (`.when(loading/error/data)`); balance hide toggle local state; quick actions nav: Kirim→`Routes.sendAmount` (reset send ctrl), Minta→`Routes.requestAmount`, Split→`Routes.splitCreate`, Terima→`Routes.receive`; shortcut tap → prefill send recipient + go send; "+ Tambah"/"Kelola"→`Routes.contacts`; row tap→`Routes.txDetail` with id; promo tap→`Routes.promoDetail`; "Lihat semua"→`Routes.history`.
- [ ] **Step 2:** Add `Routes.home` already exists; ensure new route names referenced exist (added in their tasks — until then, comment the nav or land Task 15+ first). **Execution note:** land routes as their target screens are built; Home's nav lines compile once Routes constants exist (add all `Routes` name constants in Task 15's router edit up front).
- [ ] **Step 3: Analyze** → `No issues found!`
- [ ] **Step 4: Commit** — `feat(ui): rebuild Home (balance, promo, quick actions, shortcuts, recent)`.

### Task 15: Send flow (amount → review → success) + router constants

**Files:** Modify `frontend/lib/screens/send_amount_screen.dart`, `send_review_screen.dart`, `send_success_screen.dart`, `frontend/lib/app/router.dart`, `frontend/lib/app/env.dart` (set `feeRate = 0`).
**Frames:** Send Amount (`RecipientHeader · AmountDisplay · FeeHintRow · NumericKeypad`), Send Review (`RecipientCard · FeeBreakdown · NoteRow · BiometricConfirmButton`), Send Success (`SuccessCheck · ReceiptSummary · DoneButton`).
**Copy:** "Amount to send"→"Nominal kirim"; "No admin fee"→"Tanpa biaya admin"; "Review"→"Tinjau"; "You send/Fee/They receive/Total to pay"→"Kamu kirim/Biaya/Mereka terima/Total bayar"; "One quick Face ID and you're done"→"Cukup satu Face ID"; "Hold to confirm"→"Tahan untuk konfirmasi"; "Money's on its way"→"Uang sedang dikirim"; "Reference"→"Referensi"; "Done"→"Selesai"; "Share receipt"→"Bagikan bukti".

- [ ] **Step 1:** In `router.dart`, add **all** `Routes` name constants used across Phase 4 (`requestAmount`, `requestConfirm`, `requestSent`, `splitCreate`, `splitShares`, `splitConfirm`, `splitDetail`, `contacts`, `txDetail`, `promoDetail`) and their `GoRoute`s (temporary `builder` → the screens land in their tasks; use the real screen for send now). Set `Env.feeRate = 0`.
- [ ] **Step 2:** send_amount — `RecipientHeader` (MonogramAvatar + name + accountRef + "Ubah"), big `MoneyText` of typed amount, "Tanpa biaya admin" hint, `AmountKeypad` driving `sendControllerProvider.setAmount`, bottom `PrimaryPillButton('Tinjau')` → `Routes.sendReview`.
- [ ] **Step 3:** send_review — `SurfaceCard` recipient, fee breakdown from `SendQuote` (fee row shows `Rp 0`), note row, bottom biometric confirm via `showBiometricConfirmSheet` then `confirmAndSend()`; on success go `Routes.sendSuccess`.
- [ ] **Step 4:** send_success — success check, receipt (`Nominal`, `Referensi`), `PrimaryPillButton('Selesai')`→`Routes.home`, `SecondaryPillButton('Bagikan bukti')`.
- [ ] **Step 5: Analyze** all touched → `No issues found!`
- [ ] **Step 6: Commit** — `feat(ui): rebuild send flow + route constants + zero demo fee`.

### Task 16: Receive screen

**Files:** Modify `frontend/lib/screens/receive_screen.dart`.
**Frame:** Receive — `QrCard · AccountRefRow · ShareButton`. **Copy:** "Receive"→"Terima"; "Scan this to send me money"→"Pindai untuk mengirimiku uang"; "Kirimin ID rani.putri"; "Account •••• 4821"→"Rekening •••• 4821"; "Share details"→"Bagikan detail".

- [ ] **Step 1:** `SurfaceCard(elevated:true)` with a placeholder QR block (use `Icon(Icons.qr_code_2, size: 160)` in ink — no QR package), name "Rani Putri", "Kirimin ID rani.putri", account ref row, bottom `PrimaryPillButton('Bagikan detail')`.
- [ ] **Step 2: Analyze** → `No issues found!`
- [ ] **Step 3: Commit** — `feat(ui): rebuild Receive`.

### Task 17: Request flow (amount → confirm → sent)

**Files:** Modify `frontend/lib/screens/request_amount_screen.dart`, create `request_confirm_screen.dart`, `request_sent_screen.dart`; ensure their routes point to real screens.
**Frames:** Request Amount (`ContactPicker · AmountField · NoteField`), Request Confirm (`RequestSummaryCard · NoBiometricHint`), Request Sent (`PendingBadge · StatusTimeline · DoneButton`).
**Copy:** "Request"→"Minta"; "From"→"Dari"; "Amount"→"Nominal"; "Note / For school books"→"Catatan / Buat beli buku sekolah"; "Continue"→"Lanjut"; "Confirm request"→"Konfirmasi permintaan"; "You're requesting Rp X from Y"→"Kamu meminta Rp X dari Y"; "Send request"→"Kirim permintaan"; "Request sent"→"Permintaan terkirim"; "Waiting to be paid"→"Menunggu dibayar"; "We'll let you know the second Ayu pays"→"Kami kabari begitu Ayu bayar".

- [ ] **Step 1:** amount — contact picker (tap → sheet listing favorite contacts from `contactsControllerProvider`), amount field/keypad, note field → `requestControllerProvider`; "Lanjut"→confirm.
- [ ] **Step 2:** confirm — summary card, "Tanpa Face ID — tidak ada dana yang berpindah" hint, "Kirim permintaan" → `submit()` → sent.
- [ ] **Step 3:** sent — pending `StatusChip.info`, simple timeline, "Selesai"→home.
- [ ] **Step 4: Analyze** → `No issues found!`
- [ ] **Step 5: Commit** — `feat(ui): request money flow`.

### Task 18: Split flow (create → shares → confirm → detail)

**Files:** Modify `frontend/lib/screens/split_create_screen.dart`… create `split_shares_screen.dart`, `split_confirm_screen.dart`, `split_detail_screen.dart`.
**Frames:** Split Create (`TotalAmountField · TitleField · ParticipantPicker`), Split Shares (`SplitEvenlyToggle · ShareRow · BalanceValidator`), Split Confirm (`SplitSummaryCard · SendRequestsButton`), Split Detail (`CollectionProgress · ParticipantStatusRow`).
**Copy:** "Split a bill"→"Split tagihan"; "Total bill"→"Total tagihan"; "What's it for?"→"Untuk apa?" (placeholder "Listrik, Juli 2026"); "Split with"→"Bagi dengan"; "Next"→"Lanjut"; "Who pays what"→"Siapa bayar berapa"; "Split evenly"→"Bagi rata"; "…of Rp 450.000. All balanced!"→"…dari Rp 450.000. Sudah pas!"; "Continue"→"Lanjut"; "Confirm split"→"Konfirmasi split"; "Everyone gets a friendly request for their share"→"Tiap orang dapat permintaan untuk bagiannya"; "Send requests"→"Kirim permintaan"; "Collected Rp X of Rp Y"→"Terkumpul Rp X dari Rp Y"; "Paid/Pending"→"Lunas/Menunggu"; "Nudge Ayu"→"Ingatkan Ayu".

- [ ] **Step 1:** create — total field, title field, participant picker (favorite contacts + self always included) → `splitControllerProvider`; "Lanjut"→shares.
- [ ] **Step 2:** shares — "Bagi rata" `Switch` (→ `setSplitEvenly`), a `ShareRow` per participant (editable when not evenly), `BalanceValidator` line reading `assignedIdr`/`totalIdr`/`isBalanced` (green check + "Sudah pas!" when balanced; danger when off); "Lanjut" enabled only when `isBalanced`.
- [ ] **Step 3:** confirm — summary card of shares; "Kirim permintaan"→`submit()`→detail.
- [ ] **Step 4:** detail — `CollectionProgress` (progress bar `collectedIdr/totalIdr`), participant rows with `StatusChip` Lunas/Menunggu, "Ingatkan {name}" secondary button. Route `Routes.splitDetail` takes `:id` and reads `getSplit`.
- [ ] **Step 5: Analyze** → `No issues found!`
- [ ] **Step 6: Commit** — `feat(ui): split bill flow (create/shares/confirm/detail)`.

### Task 19: Family Contacts

**Files:** Modify `frontend/lib/screens/family_contacts_screen.dart`.
**Frame:** `ContactListTile · FavoriteToggle · AddContactButton`. **Copy:** "Family"→"Keluarga"; "Favorites"→"Favorit"; "All contacts"→"Semua kontak"; "Add contact"→"Tambah kontak"; relations "Mother/Sister/Father"→"Ibu/Adik/Ayah".

- [ ] **Step 1:** Two sections (Favorit / Semua kontak) from `contactsControllerProvider`; each row = `MonogramAvatar` + name + "relation · accountRef" + star `IconButton` (`toggleFavorite`); bottom `PrimaryPillButton('Tambah kontak')` → sheet with name/relation/account fields → `addContact`; tapping a row → prefill send + go send.
- [ ] **Step 2: Analyze** → `No issues found!`
- [ ] **Step 3: Commit** — `feat(ui): family contacts (favorites, add, toggle)`.

### Task 20: Transaction Detail + Promo Detail

**Files:** Modify `frontend/lib/screens/transaction_detail_screen.dart`, `promo_detail_screen.dart`.
**Frames:** Transaction Detail (`AmountHeader · StatusChip · DetailRows`), Promo Detail (`PromoHero · FeatureList · CtaButton`).
**Copy (tx):** signed amount header, `StatusChip` "Terkirim/Lunas/Gagal"; rows "Ke/Tanggal/Biaya/Referensi/Catatan"; buttons "Kirim lagi"/"Bagikan bukti". **(promo):** badge "Baru", "Split tagihan!", feature list (Bagi rata atau custom / Lihat siapa sudah bayar / Pengingat halus), CTA "Ayo split".

- [ ] **Step 1:** tx detail reads the tx by `:id` (from home-feed/history list via a lookup provider or passed extra); `direction`-aware sign/color; "Kirim lagi"→prefill send.
- [ ] **Step 2:** promo detail reads promo by `:id`; hero `GradientSpotlight`; CTA follows `deepLink` (e.g. `Routes.splitCreate`).
- [ ] **Step 3: Analyze** → `No issues found!`
- [ ] **Step 4: Commit** — `feat(ui): transaction detail + promo detail`.

### Task 21: History

**Files:** Modify `frontend/lib/screens/history_screen.dart`.
**Frame:** `TransactionGroup · TransactionRow · EmptyView`. **Copy:** "History"→"Riwayat"; groups "Today/This week"→"Hari ini/Minggu ini".

- [ ] **Step 1:** Read full transaction list (home-feed recent + extra seed); group by relative day bucket (Hari ini / Minggu ini / older date) using a helper in `core/money.dart` (or `core/time.dart`); render `TransactionRow`s under section headers; `EmptyView` when empty; row tap → `Routes.txDetail`.
- [ ] **Step 2: Analyze** → `No issues found!`
- [ ] **Step 3: Commit** — `feat(ui): rebuild History with day grouping`.

---

## Phase 5 — Verification

### Task 22: Full analyze, tests, and smoke run (light + dark)

**Files:** none (verification); fix-ups as needed.

- [ ] **Step 1: Analyze whole app** — `cd frontend && flutter analyze` → **`No issues found!`** (completion gate). Fix every reported item on touched files.
- [ ] **Step 2: Run tests** — `cd frontend && flutter test` → all pass (kit smoke + split math).
- [ ] **Step 3: Build sanity** — `cd frontend && flutter build web --no-tree-shake-icons` (fast headless compile check) or `flutter run -d chrome` for a live smoke.
- [ ] **Step 4: Smoke both themes** — launch (via `/run`), navigate every flow: Home → Send(3) → Receive → Request(3) → Split(4) → Contacts → Tx Detail → Promo Detail → History; toggle OS dark/light and confirm both palettes render (no hardcoded-palette bleed). Confirm no crypto term/seed/gas surfaces and all amounts are `Rp`.
- [ ] **Step 5: Commit** any fix-ups — `fix(ui): analyze + smoke cleanups across redesign`.
- [ ] **Step 6:** Invoke `superpowers:finishing-a-development-branch` to decide merge/PR.

---

## Self-Review

**Spec coverage:** Every spec §maps to tasks — design system §3→T1-3; widgets §4→T4-8; models §5.1→T9; services §5.3→T10; controllers §5.2→T11-12; screens §6→T13-21; routing §8→T15 (constants) + per-screen; theme mode §9→T3/T4; fee §7→T15; verification §10→T22; build order §11 matches phases. No gap.

**Placeholder scan:** Foundation/kit/data tasks carry complete code; screen tasks carry exact file, kit widgets, verbatim copy, data source, and nav target (the design frame is the visual cross-check, not a missing detail). No "TBD/handle edge cases" left. The only intentional `UnimplementedError`/`TODO(handoff)` are real backend stubs in `wallet_api.dart` (T10), which the app never calls in mock mode.

**Type consistency:** `AppTransaction.counterpartyName`/`direction`/`reference` (T9) used by `TransactionRow` (T7) and screens; `TxDirection` defined in T9 and imported by T7 (guarded by T7 Step 1). `splitControllerProvider` names (`setTotal`, `toggleParticipant`, `setSplitEvenly`, `setShare`, `assignedIdr`, `isBalanced`) consistent between T12 test, controller, and T18 screens. `Routes.*` constants all declared in T15 Step 1 before any screen references them. `HomeFeed` fields consistent between T10 and T11/T14.
