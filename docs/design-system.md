# Kirimin — Design System

Dark, minimal, sleek. A money app that reads like a premium finance product, never like a crypto wallet. This document is the single source of truth for color, type, spacing, elevation, and component behavior. Every screen (including agent generated ones) pulls tokens from here through `frontend/lib/app/theme.dart`. No hardcoded hex in screens.

> **North star tie in:** "User just uses Face ID. Balance shows in Rupiah. Family receives Rupiah. The words crypto, wallet, seed phrase, gas never appear." The visual language reinforces that: calm surfaces, one loud accent, big honest numbers, transparent fees.

---

## 0. Heads up: this replaces the current theme

The existing `theme.dart` is a **light mode, teal + warm amber** system. This design system is a deliberate pivot to **dark mode with a single yellow brand accent**. When implemented, `AppColors`, `buildAppTheme()`, and `AppText._family` change. The **token names and structure stay the same** (`AppColors`, `AppSpacing`, `AppRadii`, `AppText`), so screens that already follow the contract keep working. This is a re skin, not a re architecture.

---

## 1. Design direction

| Principle | What it means here |
|---|---|
| **Minimal, low clutter** | One primary action per screen. Group related info into a single card. Generous negative space. Kill every non essential line, label, and box. |
| **Depth without flatness** | The background is a soft near black gradient, not one flat color. Surfaces sit above it by a small step in lightness (tonal elevation), not by drop shadows (shadows read poorly on dark). |
| **Separate by tone first, border second** | A card is visible because it is slightly lighter than the background. Add a soft 1px hairline border **only** when the tonal step alone is too subtle (small chips, inputs, the floating nav). |
| **One loud color** | Yellow is the only saturated color. It marks the primary CTA, the active nav item, focus, and money "received" moments. Everything else is neutral so yellow always wins attention. |
| **Big honest numbers** | Balances and amounts are oversized display type with tabular figures. The fee breakdown ("you send X, family gets Y, fee Z") is a signature component and must always be legible before confirm. |
| **Framer grade polish** | Soft radii, precise spacing rhythm, restrained spring motion, crisp vector icons at one stroke weight. |

Reference feel: the "LOCC" style board (near black, soft bordered cards, minimal) is the closest north star among the reference images; borrow its restraint, not the teal fintech clichés.

---

## 2. Color tokens

All values are dark mode only (the app ships dark). Hex is authoritative; Flutter `Color(0xFF……)` given for direct paste.

### 2.1 Background ramp + the off dark gradient

The scaffold background is **not** a flat fill. It is a subtle top lit vertical gradient over a neutral near black with a faint cool tilt, giving depth without ever looking blue.

| Token | Hex | Flutter | Use |
|---|---|---|---|
| `bgTop` | `#101114` | `Color(0xFF101114)` | Gradient start (top of screen) |
| `bgBase` | `#0A0B0D` | `Color(0xFF0A0B0D)` | Gradient mid / solid fallback |
| `bgBottom` | `#070709` | `Color(0xFF070709)` | Gradient end (bottom) |

```dart
// Scaffold background — apply as a Container decoration behind every screen.
const appBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF101114), Color(0xFF0A0B0D), Color(0xFF070709)],
  stops: [0.0, 0.45, 1.0],
);
```

Optional accent: a single very faint radial glow (`#F59E0B` at 4 to 6% opacity, large blur) behind the balance hero on the home screen only, to lift the money number. Never more than one glow per screen, never behind body content.

### 2.2 Surfaces (tonal elevation)

Each step up in elevation is a small step up in lightness. This is how components separate from the background.

| Token | Hex | Flutter | Use |
|---|---|---|---|
| `surface1` | `#141518` | `Color(0xFF141518)` | Cards, list containers, sheets (the default surface) |
| `surface2` | `#1C1E22` | `Color(0xFF1C1E22)` | Raised elements on a card: inner tiles, input fields, the floating bottom nav |
| `surface3` | `#26282E` | `Color(0xFF26282E)` | Pressed / hovered surface, selected chip, menu |

**Rule:** background → `surface1` is ~2 steps of lightness, enough to read on its own. `surface1` → `surface2` is smaller; pair it with a hairline border when it sits on another surface.

### 2.3 Borders (soft, used sparingly)

| Token | Value | Flutter | Use |
|---|---|---|---|
| `hairline` | `rgba(255,255,255,0.06)` | `Color(0x0FFFFFFF)` | Default soft divider / card edge when tone alone is not enough |
| `hairlineStrong` | `rgba(255,255,255,0.10)` | `Color(0x1AFFFFFF)` | Inputs, the floating nav outline, focused card edge |

Borders are additive, not the primary separator. If a card already reads clearly against the background, it needs no border.

### 2.4 Brand yellow (the one accent)

| Token | Hex | Flutter | Use |
|---|---|---|---|
| `primary` | `#F5B301` | `Color(0xFFF5B301)` | Primary CTA fill, active nav, focus ring, key numbers on success |
| `primaryHi` | `#FFC933` | `Color(0xFFFFC933)` | Hover / lighter gradient stop on CTA |
| `primaryPressed` | `#D99A00` | `Color(0xFFD99A00)` | Pressed CTA |
| `primarySoft` | `rgba(245,179,1,0.12)` | `Color(0x1FF5B301)` | Tinted background behind yellow icons, active nav pill, subtle highlight |
| `onPrimary` | `#0A0B0D` | `Color(0xFF0A0B0D)` | Text/icon **on** a yellow fill — always near black, never white |

The signature CTA is **near black text on a yellow pill**. High contrast, unmistakable, and it keeps yellow as the single attention magnet.

### 2.5 Text

| Token | Hex | Flutter | Contrast on `bgBase` | Use |
|---|---|---|---|---|
| `textPrimary` | `#F4F5F7` | `Color(0xFFF4F5F7)` | ~17:1 | Headings, balances, primary body |
| `textSecondary` | `#A2A6AE` | `Color(0xFFA2A6AE)` | ~7:1 | Labels, captions, secondary info |
| `textTertiary` | `#6C7079` | `Color(0xFF6C7079)` | ~3.6:1 | Disabled hints, timestamps (large / non essential only) |
| `onPrimary` | `#0A0B0D` | `Color(0xFF0A0B0D)` | — | On yellow surfaces |

### 2.6 Semantic

Functional color always pairs with an icon or text label, never color alone.

| Token | Hex | Flutter | Use |
|---|---|---|---|
| `success` | `#34C759` | `Color(0xFF34C759)` | Money received, tx settled, positive delta |
| `successSoft` | `rgba(52,199,89,0.14)` | `Color(0x2434C759)` | Success chip / badge background |
| `danger` | `#FF453A` | `Color(0xFFFF453A)` | Errors, destructive, failed tx |
| `dangerSoft` | `rgba(255,69,58,0.14)` | `Color(0x24FF453A)` | Error field / banner background |

> Yellow is the brand accent, **not** a semantic status. Success is green, error is red. Keep those distinct so yellow never gets read as "warning."

---

## 3. Elevation & separation strategy (dark mode specifics)

1. **Tone is the primary separator.** Step lightness up per elevation level (`bg` → `surface1` → `surface2` → `surface3`).
2. **Shadows are minimal.** On dark, use at most a soft ambient shadow (`0 8px 24px rgba(0,0,0,0.4)`) under floating elements (bottom nav, bottom sheet, modal) to detach them. No shadows on inline cards.
3. **Border only when needed.** Add `hairline` when two adjacent surfaces are close in tone, or to define the floating nav and inputs.
4. **Scrim for overlays.** Modals/sheets dim the background with `rgba(0,0,0,0.55)` so foreground stays legible.

---

## 4. Typography

**Primary typeface: Plus Jakarta Sans** (geometric, friendly, and an Indonesian designed face that fits the product narrative). Fallback / safe alternative: **Inter**. Add via `google_fonts` and set `AppText._family = 'PlusJakartaSans'`.

- Money and any tabular number **must** use `FontFeature.tabularFigures()` so digits do not shift width.
- Headings 600–700, body 400, labels 500–600. Tight tracking (`-0.5`) on the big display number only.

| Role | Size | Weight | Tracking | Notes |
|---|---|---|---|---|
| `displayMoney` | 40 | 700 | -0.5 | Balance / amount hero. Tabular figures. Line height 1.05. |
| `displayMoneyLg` | 52 | 700 | -1.0 | Optional larger balance on Home only. Tabular. |
| `h1` | 26 | 700 | -0.2 | Screen titles |
| `h2` | 20 | 700 | 0 | Section headers |
| `title` | 17 | 600 | 0 | Card titles, list item primary |
| `body` | 15 | 400 | 0 | Body text, line height 1.45 |
| `bodyMuted` | 15 | 400 | 0 | Secondary body (`textSecondary`) |
| `label` | 13 | 600 | 0.2 | Eyebrow labels, nav labels, captions |
| `button` | 16 | 700 | 0 | CTA text (`onPrimary` on yellow) |

Minimum body size on mobile is 15–16 to avoid unreadable text; never go below 12 for any legible label.

---

## 5. Spacing, radius, layout

Keep the existing 4/8 rhythm — it is already correct.

- **Spacing scale:** 4 · 8 · 12 · 16 · 24 · 32 · 48. Screen edge padding = 16 horizontal.
- **Section rhythm:** 16 within a group, 24 between groups, 32 before a major block.
- **Radius:** `sm 8` (chips, inputs) · `md 12` (buttons) · `lg 16` (cards) · `xl 24` (sheets, hero card) · `pill 999` (CTA pill, nav, avatars).
- **Touch targets:** every tappable element ≥ 44×44. CTA height 56. Input height ≥ 52.
- **Safe areas:** honor top notch and bottom gesture bar. The floating bottom nav sits above the home indicator with its own inset; scroll content reserves bottom padding so nothing hides behind it.

---

## 6. Component specs

### 6.1 Primary CTA
Yellow pill, near black text, full width, height 56, radius `md`–`pill`. One per screen. Optional subtle gradient `primary → primaryHi` top to bottom. Pressed = `primaryPressed` + scale 0.98. Loading = disabled + small dark spinner, label swaps to progress. Disabled = `surface2` fill, `textTertiary` label.

### 6.2 Secondary / ghost button
Transparent fill, `hairlineStrong` border, `textPrimary` label. For "cancel", "see all", "add card". Never competes with the yellow CTA.

### 6.3 Card (default container)
`surface1` fill, radius `lg`, padding 16. Border only if it sits on another surface or reads too soft (then `hairline`). No shadow inline.

### 6.4 Balance hero (Home)
Large `displayMoney`/`displayMoneyLg` in `textPrimary`, an eyebrow `label` above ("Total Balance"), an eye toggle to hide/show. Optional faint yellow radial glow behind the number. This is the emotional anchor of the home screen — give it space.

### 6.5 Fee breakdown card (signature)
The most important component. Shown before every send confirm. Three clear rows:
- "You send" — amount in Rp, `title`
- "Family receives" — amount in Rp, emphasized, `success` colored value
- "Fee" — amount + percent, `textSecondary`, phrased as "biaya layanan", never "network fee" or "gas"

Rows separated by `hairline`. The received amount is the visual hero of the card. Total transparency, zero jargon.

### 6.6 Input / amount field
`surface2` fill, `hairlineStrong` border, radius `sm`–`md`, height ≥ 52. Focus = `primary` border 1.6px, no glow. Visible label above (not placeholder only). Error = `danger` border + message below with icon. Amount entry uses the money keyboard and tabular figures.

### 6.7 PIN / biometric entry
Numeric keypad on `surface1` keys, `surface2` pressed. PIN dots fill yellow as entered. Confirm CTA is the yellow pill. Biometric prompt is OS native — the app only shows a calm "Confirm with Face ID" affordance.

### 6.8 Floating bottom nav
Pill shaped bar on `surface2` with `hairlineStrong` border and a soft ambient shadow, floating above the safe area. Max 5 items, icon + label. Active item: yellow icon in a `primarySoft` pill, label brightens to `textPrimary`. Inactive: `textSecondary`. Icon only nav is not allowed — keep labels.

### 6.9 Transaction list tile
Leading rounded icon/avatar on `surface2`, primary title `title`, secondary `bodyMuted` (merchant/date), trailing amount right aligned with tabular figures. Positive amounts `success`, outgoing `textPrimary`. Group by date with a small `label` header. Rows separated by tone or `hairline`, not heavy dividers.

### 6.10 Bottom sheet / modal
`surface1`, top radius `xl`, grab handle, background scrim `rgba(0,0,0,0.55)`. Animates up from its trigger. Clear close affordance; swipe down to dismiss; confirm before dismissing unsaved input.

### 6.11 States (never skip these)
- **Loading:** skeleton shimmer on `surface1`/`surface2` for anything over ~300ms, not a blank spinner screen.
- **Empty:** a short friendly line + one action ("Belum ada transaksi. Kirim uang pertamamu.") — active voice, an invitation.
- **Error:** cause + fix, Bahasa Indonesia, no stack traces, no "Error 500". Retry always available.
- **Success:** brief green check + settle confirmation; the money moment can flash yellow once.

---

## 7. Motion

Restrained, spring based, meaningful. Match the "Framer" feel without decoration.

- **Micro interactions:** 150–250ms, `ease-out` in / `ease-in` out. Press = scale 0.98 with a spring settle.
- **Screen transitions:** forward slides/fades left-up, back reverses. 250–350ms. Keep spatial continuity; shared element on the balance card where possible.
- **Money confirm:** a single satisfying spring + green check + optional light haptic on settle. Animate 1–2 elements max, never the whole screen.
- **Respect `prefers-reduced-motion`:** drop to simple crossfades; content readable immediately.
- Animate `transform`/`opacity` only. Never animate width/height/layout.

---

## 8. Iconography

- One vector set, one stroke weight (1.5–2px). Lucide or Heroicons style outline for nav and actions; filled only for the single active nav state if desired (keep filled vs outline disciplined per hierarchy level).
- Icon size tokens: `sm 16` · `md 20` (default) · `lg 24`. No arbitrary in between sizes.
- **No emoji as icons** anywhere. No raster PNG icons.
- Icons meet 3:1 contrast minimum against their surface; give every icon-only button an `accessibilityLabel`.

---

## 9. Accessibility contrast (verify before ship)

| Pair | Ratio | Verdict |
|---|---|---|
| `textPrimary` #F4F5F7 on `bgBase` #0A0B0D | ~17:1 | AAA |
| `textSecondary` #A2A6AE on `bgBase` | ~7:1 | AAA |
| `textPrimary` on `surface1` #141518 | ~15:1 | AAA |
| `onPrimary` #0A0B0D on `primary` #F5B301 | ~10:1 | AAA — this is why CTA text is near black |
| `primary` #F5B301 as large text on `bgBase` | ~11:1 | AAA (large) |
| `success` #34C759 on `bgBase` | ~7:1 | AA+ |
| `danger` #FF453A on `bgBase` | ~4.7:1 | AA (pair with icon) |

`textTertiary` is for large or non essential text only — do not use it for meaningful body copy.

---

## 10. Anti patterns (do not do)

- ❌ White text on yellow (use near black `onPrimary`).
- ❌ Yellow as a warning/status color (it is brand only; use green/red for status).
- ❌ Purple / pink "AI" gradients, neon glows, or cyberpunk type (Orbitron etc.) — reads as crypto, violates the north star.
- ❌ Flat pure `#000000` everywhere with no depth — use the gradient + tonal surfaces.
- ❌ Heavy drop shadows to separate inline cards — separate by tone.
- ❌ Boxes around everything — group with space first, border only when necessary.
- ❌ The words crypto, wallet, seed phrase, gas, XLM, USDC, network fee anywhere in UI copy.
- ❌ Unclear fees — the fee breakdown is always explicit and before confirm.

---

## 11. Implementation checklist (theme.dart migration)

- [ ] Swap `AppColors` to the dark tokens above (keep the names; screens depend on them).
- [ ] Add `appBackgroundGradient`; wrap the scaffold body in a gradient container (or a shared `AppScaffold` background).
- [ ] Set `brightness: Brightness.dark` and rebuild `ColorScheme.fromSeed(seedColor: primary, brightness: dark)`.
- [ ] Add `google_fonts` and set `AppText._family = 'PlusJakartaSans'` (fallback Inter). Keep tabular figures on money styles.
- [ ] Card theme: `surface1` fill, `hairline` side only where needed, elevation 0.
- [ ] Elevated button: `primary` fill, `onPrimary` text, height 56, radius `md`, pressed `primaryPressed`.
- [ ] Input theme: `surface2` fill, `hairlineStrong` border, `primary` focus.
- [ ] Verify the contrast table on device; test with reduced motion and largest Dynamic Type.
- [ ] Re run the invisible crypto copy check — no forbidden terms leak into any state.
