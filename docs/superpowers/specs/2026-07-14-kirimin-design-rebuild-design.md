# Kirimin — Design-System Rebuild (Claude Design import)

**Date:** 2026-07-14
**Status:** Approved design → ready for implementation plan
**Owner:** frontend
**Sources of truth:**
- Design system: `docs/DESIGN.md` (Manrope/Inter, blue `#0099FF`, dark+light tokens, ready-to-paste Flutter)
- Screen information architecture: `docs/specs/mobile-ui-handoff-spec.md`
- Exact screen layouts & copy: Claude Design project `7113bcb7-4e1a-4781-9cac-d2ec53bb9029`
  ("Finance app design system") → `Kirimin Screens.dc.html` (16 frames across 6 flows)

---

## 1. Goal & non-goals

**Goal.** Scrap the current visual layer (yellow / Plus Jakarta Sans design system, its widget
kit, and its screens) and rebuild the app against the newly-imported "Kirimin Screens" design:
dark-first with a full inverse light palette, Manrope display + Inter body, one blue accent used
only for links/focus/selection, ink-fill pill CTAs, tonal-lift surfaces, and a single radial glow.
Build **all 6 flows** (~16 screens), support **system light + dark**, and make new flows
**interactive against in-memory mock data**.

**Non-goals.**
- No backend work. Real `WalletApi` gains stubbed endpoints flagged for handoff; the app runs on
  mocks (`Env.useMock = true`).
- No change to the auth/session/passkey **contracts** or the `Result`/`Ok`/`Err` pattern.
- No new packages beyond what's already present (`google_fonts` already pulls Manrope + Inter).
- Splash and Onboarding are **not** in the design deck → re-skinned to the new tokens only, no
  structural redesign.

## 2. Architecture principle — keep the brain, replace the skin

The app's non-visual "brain" is kept and extended. The entire presentation layer is deleted and
rebuilt. New screens plug into new Riverpod controllers + mock services following the **existing**
patterns already in the repo (`Notifier`/`AsyncNotifier`, `NotifierProvider`, `Result` switch-case,
`Env.useMock` injection in `state/providers.dart`).

| Layer | File(s) | Action |
|---|---|---|
| App entry | `lib/main.dart` | **Edit** — wire `theme`+`darkTheme`+`ThemeMode.system`; drop forced-light status bar |
| Routing shell | `lib/app/router.dart` | **Extend** — add new named routes; keep auth redirect verbatim |
| Env | `lib/app/env.dart` | **Edit** — set demo `feeRate = 0` (see §7); everything else kept |
| Money/FX core | `lib/core/money.dart`, `lib/core/result.dart` | **Keep** (money may gain relative-time + grouping helpers) |
| Models | `lib/models/models.dart` | **Extend** — new models; extend `AppTransaction` |
| State | `lib/state/*` | **Keep + add** — keep `auth_controller`, `send_controller`, `providers`; add controllers |
| Services | `lib/services/*` | **Keep + extend** — extend mock + real API surface with new endpoints |
| Theme | `lib/app/theme.dart` | **DELETE** → new `lib/theme/*` |
| Widget kit | `lib/widgets/*` | **DELETE all** → rebuilt kit |
| Screens | `lib/screens/*` | **DELETE all 8** → rebuilt + new screens |

## 3. Design-system layer — `lib/theme/` (replaces `lib/app/theme.dart`)

Ported directly from `docs/DESIGN.md` §"Flutter Transferability".

- `lib/theme/tokens.dart` — `KColors` (dark + inverse light sets), `KRadius`
  (`xs 4 · sm 6 · md 10 · lg 15 · xl 20 · xxl 22 · pill 100 · full 9999`),
  `KSpace` (`xxs 4 · xs 8 · sm 12 · md 14 · lg 20 · xl 26 · xxl 40 · section 96`),
  `auroraGradient`, `sunsetGradient`.
- `lib/theme/text_theme.dart` — `buildTextTheme(Color ink)`: Manrope 600/700 display roles
  (display L/M/S at 110/85/62, headlineLarge 32), Inter for headline→micro. **Negative
  letter-spacing preserved exactly per token**; all display text must route through
  `Theme.of(context).textTheme` so Flutter's default `0` tracking never creeps back in.
- `lib/theme/app_theme.dart` — `buildTheme({required bool dark})` → `ThemeData` for each mode:
  scaffold = canvas; `ColorScheme(primary: ink, onPrimary: canvas, secondary: accent)`;
  `ElevatedButton` = ink fill, `StadiumBorder`, 12/20 padding (the pill CTA); input theme =
  surface1 fill, `KRadius.md`, 1px accent focus border + focus ring; divider = hairlineSoft.
- **Accent-blue is never a button/card fill** — signal color only (links, focus ring, selected
  avatar border, "active" status chip). This is a design invariant to uphold in every widget.

`main.dart`: `theme: buildTheme(dark:false)`, `darkTheme: buildTheme(dark:true)`,
`themeMode: ThemeMode.system`. Replace the hardcoded `SystemUiOverlayStyle.light` +
`AppColors.bgBottom` with brightness-adaptive overlay (set per-screen via `AppScaffold`).

## 4. Shared widget kit — `lib/widgets/` (replaces all existing widgets)

Mapping from `docs/DESIGN.md` §"Component → widget map". One barrel `widgets.dart`.

| File | Provides | Design component |
|---|---|---|
| `glow_background.dart` | `GlowBackground(dark:)` radial-glow page background | Depth "Background glow" |
| `app_scaffold.dart` | Page shell on `GlowBackground`; transparent `Scaffold`; **no bottom tab bar**; adaptive status-bar overlay; optional title/back/actions + optional bottom CTA | layout |
| `pill_button.dart` | `PrimaryPillButton` (ink fill), `SecondaryPillButton` (surface1 fill) — both `StadiumBorder` | button-primary/secondary |
| `icon_button.dart` | `CircleIconButton` (40px surface1 circle) | button-icon-circular |
| `quick_action.dart` | 56px circle (ink for primary / surface for rest) + caption label | quick-action-primary/secondary |
| `cards.dart` | `SurfaceCard` (surface1 xl / surface2 xxl), `GradientSpotlight` (aurora/sunset, one per screen max) | card-surface-1/2, gradient-spotlight |
| `avatar.dart` | `MonogramAvatar` (initials, 40–56px) + optional selected accent ring | avatar-monogram(-selected) |
| `status_chip.dart` | `StatusChip.success/danger/info` pill, `color.withValues(alpha:.14)` bg | status-chip-* |
| `transaction_row.dart` | 64px row: avatar/icon, title, `type · time`, signed amount (green +/red −/ink), hairline divider — **no card wrapper** | transaction-row |
| `amount_keypad.dart` | Numeric keypad (`1–9`, `000`, `0`, backspace) driving an amount string | Send/Request amount |
| `money_text.dart` | Big tabular `Rp` display + hidden `••••` variant | balance/amount displays |
| `sheets.dart` | `showBiometricConfirmSheet` ("Hold to confirm" / Face ID) reused by Send | sign moment |
| `states.dart` | `EmptyView`, `LoadingView`, inline error | empty/loading |

## 5. Data layer

### 5.1 Models — extend `lib/models/models.dart`
Keep `Wallet`, `PasskeyAttestation`, `PasskeyAssertion`. Add:

- `Contact { id, name, relation, initials, accountRef ("•••• 3092"), isFavorite, lastSentAt }`
- `PromoBanner { id, title, subtitle, ctaLabel, deepLink, badge?, spotlight (aurora|sunset) }`
- `QuickActionType` enum (`send, request, split, receive`) — static row config lives in UI.
- `MoneyRequest { id, fromContactId, amountIdr, note?, status (pending|paid|declined|expired), createdAt }`
- `SplitBill { id, title, totalIdr, createdAt, participants: List<SplitParticipant> }`
- `SplitParticipant { contactId, name, shareIdr, isSelf, status (pending|paid) }`
- **Extend `AppTransaction`**: add `type (send|receive|split)`, `reference` (e.g. `KRM-8F2A091`),
  `note?`, `counterparty` naming that covers send/receive/split. Keep `TxStatus`; add relative-time
  + Today/This-week grouping helpers (in `core/money.dart` or a small `core/time.dart`).

### 5.2 State — add controllers under `lib/state/`
Follow existing `Notifier`/`NotifierProvider` style; read services via `providers.dart`.

- `home_feed.dart` — `homeFeedProvider` exposing balance (Rp), greeting name, promo banners,
  favorite contacts, recent transactions (3–5). Backed by mock service.
- `contacts_controller.dart` — list, favorites subset, `addContact`, `toggleFavorite`.
- `request_controller.dart` — pick contact, set amount + note, submit (no biometric — no funds
  move), yields `MoneyRequest` with `pending` status.
- `split_controller.dart` — set total + title, select participants, **even-split default with
  custom per-person override + live balance validator** (Σ shares must equal total), submit →
  fan-out `MoneyRequest` per participant; `SplitBill` detail tracks per-participant paid/pending
  and collected total.
- Keep `auth_controller`, `send_controller`; `send_controller` gains optional recipient/contact
  prefill so Home shortcuts and "Send again" can seed it.

### 5.3 Services — extend `lib/services/`
- `wallet_api.dart` — add stubbed endpoints (`getHomeFeed`, `listContacts`, `addContact`,
  `createRequest`, `createSplit`, `getSplit`) returning `Result`, with `docs/backend_handoff.md`
  TODO markers.
- `mock_services.dart` — `MockWalletApi` returns the mock data from
  `docs/specs/mobile-ui-handoff-spec.md` §"Ringkasan permukaan data" (balance 4.250.000; 2 promos;
  contacts Ibu/Ayu/Slamet; 3 recent tx; 1 request; 1 split with 3 participants). In-memory mutation
  so split/request status and balance feel live.

## 6. Screens — `lib/screens/` (replaces all; designer's target filenames)

Each screen renders on `AppScaffold`, pulls copy/data from controllers, and uses only the new kit.
Copy below is verbatim from the design deck (Indonesian UI strings kept where the deck used them;
the deck itself mixes EN labels in mockups — **final UI copy is Indonesian** per the product's
"Bahasa-first, no crypto" north star, matching existing screens).

**Re-skin only (not in deck):** `splash_screen.dart`, `onboarding_screen.dart`.

| Flow | File | Key components | Primary action / nav |
|---|---|---|---|
| Home | `home_screen.dart` | greeting + avatar, `BalanceHero` (hide toggle, `•••• 4821 · Main account`), `PromoCarousel` (gradient spotlight), `QuickActionsRow` (Kirim/Minta/Split/Terima), `FamilyShortcuts` (favorites + Add → Contacts, Manage), `RecentTransactions` (+ See all) | quick actions → flows; row tap → Transaction Detail; promo → Promo Detail |
| Send | `send_amount_screen.dart` | RecipientHeader (avatar, acct, Change), `money_text` amount, "No admin fee" hint, `amount_keypad` | Review |
| Send | `send_review_screen.dart` | RecipientCard, fee breakdown (You send / Fee Rp 0 / They receive / Total), Note row, biometric "Hold to confirm" | confirm → success |
| Send | `send_success_screen.dart` | success check, "Money's on its way", receipt (Amount, Reference `KRM-…`), Done / Share receipt | Done → Home |
| Receive | `receive_screen.dart` | receive card/QR + share affordance | share / Done |
| Request | `request_amount_screen.dart` | ContactPicker, AmountField, NoteField | Continue |
| Request | `request_confirm_screen.dart` | RequestSummaryCard, no-biometric hint | Send request |
| Request | `request_sent_screen.dart` | PendingBadge, status timeline ("Waiting to be paid") | Done |
| Split | `split_create_screen.dart` | TotalAmountField, TitleField, ParticipantPicker (+Add) | Next |
| Split | `split_shares_screen.dart` | "Split evenly" toggle, per-person ShareRow, **BalanceValidator** ("… of Rp 450.000. All balanced!") | Continue |
| Split | `split_confirm_screen.dart` | SplitSummaryCard (per-person shares) | Send requests |
| Split | `split_detail_screen.dart` | CollectionProgress ("Collected X of Y"), per-participant status rows, Nudge | Nudge / back |
| Contacts | `family_contacts_screen.dart` | Favorites + All-contacts sections, favorite toggle, Add contact | Add / tap → prefill Send |
| Detail | `transaction_detail_screen.dart` | AmountHeader, StatusChip, detail rows (To, Date, Fee, Reference, Note), Send again / Share | Send again → Send |
| Promo | `promo_detail_screen.dart` | PromoHero, FeatureList, CTA | CTA → deep-link (e.g. Split) |
| History | `history_screen.dart` | grouped Today / This week `TransactionGroup` → `transaction_row`; `EmptyView` when empty | row → Transaction Detail |

## 7. Fee reconciliation (design vs. code)

The deck shows **"No admin fee" / "Fee Rp 0"** (send 995.000 → receive 995.000). Current
`SendQuote` applies `Env.feeRate = 0.005`. Resolution: set **`Env.feeRate = 0`** for the demo so the
transparency card renders `Fee Rp 0` and `They receive == You send`, matching the deck. The
`SendQuote` plumbing (fee row, percent label) is retained unchanged so a real fee can return by
flipping one constant.

## 8. Routing — extend `lib/app/router.dart`

Keep `initialLocation`, `refreshListenable`, and the splash→onboarding→home auth `redirect`
untouched. Add `Routes` names + `GoRoute`s (push navigation, path-based so they're deep-linkable and
testable):

```
/home
  /send → /send/review → /send/success        (existing, kept)
  /receive                                     (existing)
  /request → /request/confirm → /request/sent  (new)
  /split → /split/shares → /split/confirm      (new)
  /split/detail/:id                            (new)
  /contacts                                    (new)
  /tx/:id           (Transaction Detail)       (new)
  /promo/:id        (Promo Detail)             (new)
  /history                                     (existing)
```

Biometric confirm stays a modal sheet (not a route). Flow state (request/split in progress) lives in
its controller, so intermediate routes read controller state rather than passing heavy args.

## 9. Theme mode (light + dark)

`ThemeMode.system`. `GlowBackground` and `AppScaffold` choose palette + status-bar overlay from
`MediaQuery.platformBrightnessOf` / `Theme.of(context).brightness`. Both `theme` and `darkTheme`
supplied; never hardcode one palette in a widget — always read tokens through the active
`ColorScheme`/`TextTheme` or a `context`-aware `KColors.of(brightness)` helper.

## 10. Verification & testing

- **`flutter analyze` clean** on every touched file (standing rule: const hoisting, arg order,
  library dirs, import collisions) — completion gate.
- **Unit test:** `split_controller` even-split + custom-override + balance validator (pure logic:
  3-way 450.000 → 150.000×3; custom override keeps Σ == total; unbalanced flagged).
- **Smoke:** `flutter run` (mock mode) — navigate every flow end-to-end; light + dark both render.
- Widget smoke test that Home builds and each route pushes without throwing.

## 11. Build order (phases)

1. **Theme layer** (`lib/theme/*`) + `main.dart` wiring + `GlowBackground`/`AppScaffold` → app boots
   on new tokens in both modes.
2. **Widget kit** (§4) with a temporary gallery route to eyeball components.
3. **Data layer** (§5): models → mock data → controllers.
4. **Screens flow-by-flow** (§6): Home → Send → Receive → Request → Split → Contacts/Details/History,
   wiring routes (§8) as each lands.
5. **Verification** (§10): analyze clean, split-math test, run smoke in light + dark.

## 12. Decisions resolved
- Scope: **all 6 flows** (~16 screens) + re-skinned splash/onboarding.
- Theme: **system light + dark**.
- New flows: **interactive against in-memory mock data**.
- Detail/flow screens use **push routes**, not modal sheets (navigable + testable).
- Spec location: `docs/superpowers/specs/`.
- Demo fee: **Rp 0** to match the deck's "No admin fee".
