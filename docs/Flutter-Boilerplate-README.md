# Kirimin — Frontend (Flutter)

Boilerplate frontend untuk **PS A: Invisible Crypto Remittance** (edisi mobile).
Dirancang supaya **screen hasil generate agent bisa langsung ditempel** ke dalam
kode dengan konvensi yang konsisten — **tanpa Figma**.

North star: *"User cukup pakai Face ID. Saldo tampil dalam Rupiah. Keluarga
terima Rupiah. Kata 'crypto', 'wallet', 'seed phrase', 'gas' tidak pernah muncul
di layar."*

---

## 1. Jalankan

```bash
flutter pub get

# dev (backend lokal / tunnel). RP_ID HARUS = domain yang meng-host /.well-known/
flutter run \
  --dart-define=BACKEND_URL=https://<domain-backend> \
  --dart-define=RP_ID=<domain-backend>
```

> Passkey native **butuh device fisik** + `.well-known` terpasang benar. Emulator/
> simulator dukungannya terbatas. Lihat §6.

---

## 2. Struktur folder

```
lib/
├── main.dart              # entry: ProviderScope + MaterialApp.router
├── app/
│   ├── router.dart        # go_router + Routes (nama rute) + redirect auth
│   ├── theme.dart         # ⭐ DESIGN TOKENS (warna, spacing, tipografi) + ThemeData
│   └── env.dart           # BACKEND_URL, RP_ID, kurs & biaya statik
├── core/
│   ├── money.dart         # format Rp/$, SendQuote (perhitungan biaya)
│   └── result.dart        # Result/AppFailure (pesan error dari sisi user)
├── models/models.dart     # Wallet, AppTransaction, Passkey Attestation/Assertion
├── services/
│   ├── passkey_service.dart  # ⭐ bungkus package `passkeys` (register/authenticate)
│   ├── wallet_api.dart       # ⭐ kontrak HTTP ke backend Node
│   └── fx_service.dart       # kurs statik (mock)
├── state/
│   ├── providers.dart        # DI service
│   ├── auth_controller.dart  # onboarding passkey → wallet
│   └── send_controller.dart  # state machine: input→review→sign→sukses
├── widgets/                  # ⭐ KIT UI reusable (dipakai semua screen)
│   ├── app_scaffold.dart     #   AppScaffold + showBiometricConfirmSheet
│   ├── buttons.dart          #   PrimaryButton, GhostButton
│   ├── money_widgets.dart    #   MoneyInput, AmountDisplay, FeeBreakdownCard ⭐
│   ├── states.dart           #   LoadingView, ErrorView, EmptyView
│   ├── transaction_tile.dart
│   └── widgets.dart          #   barrel export
└── screens/                  # ⬅️ SCREEN HASIL AGENT DITARUH DI SINI
    ├── onboarding_screen.dart  (ter-wire penuh — pola)
    ├── home_screen.dart        (ter-wire penuh — pola)
    ├── send_amount_screen.dart (ter-wire penuh — pola)
    ├── send_review_screen.dart (ter-wire penuh — pola)
    ├── send_success_screen.dart
    ├── receive_screen.dart
    ├── history_screen.dart
    └── splash_screen.dart
```

**Aturan emas:** logika (jaringan, crypto, perhitungan) hidup di `services/` +
`state/`. Screen hanya **membaca state & memanggil aksi**. Ini yang membuat
screen hasil agent aman ditempel: mereka cukup ikut kontrak di §4.

---

## 3. Alur data (siapa ngapain)

- **Onboarding:** `OnboardingScreen` → `authControllerProvider.registerWithPasskey()`
  → `PasskeyService.register()` (biometrik) → `WalletApi.createWallet()` (backend
  deploy wallet, fee di-sponsor Launchtube).
- **Kirim:** `SendAmountScreen` (isi nominal, `SendQuote` live) → `SendReviewScreen`
  (`FeeBreakdownCard` + `showBiometricConfirmSheet`) → `sendController.confirmAndSend()`
  → `WalletApi.buildSendTx()` → `PasskeyService.authenticate()` (Face ID) →
  `WalletApi.submitSignedTx()` → `SendSuccessScreen`.
- **HP tidak pernah menyentuh Soroban.** Ia hanya menghasilkan envelope WebAuthn
  dan mengoper ke backend. Semua perakitan tx ada di backend (Passkey Kit).

---

## 4. 📌 Kontrak Screen (WAJIB diikuti screen hasil agent)

Setiap screen baru harus:

1. `class XScreen extends ConsumerWidget` (atau `ConsumerStatefulWidget` bila
   perlu controller lokal). **Selalu `const` constructor.**
2. Bungkus isi dengan **`AppScaffold`** (`title`, `child`, `bottom`).
3. **Ambil warna/teks/spacing HANYA dari `app/theme.dart`** (`AppColors`,
   `AppText`, `AppSpacing`, `AppRadii`). **Dilarang hardcode hex atau `TextStyle`
   mentah.**
4. **Komposisi dari `widgets/`** — jangan bikin tombol/kartu baru dari nol kalau
   sudah ada padanannya (`PrimaryButton`, `FeeBreakdownCard`, dst).
5. **Uang selalu lewat `formatMoney(...)` / `SendQuote`.** Tidak boleh ada angka
   token mentah, contract address, "USDC", "gas", "wallet", "seed phrase".
6. Navigasi via **`context.goNamed(Routes.x)`** — bukan string mentah, bukan
   `Navigator.push` manual.
7. State via **`ref.watch(...)`** (baca) & **`ref.read(...).method()`** (aksi).
   Screen **tidak** memanggil `WalletApi`/`PasskeyService` langsung.
8. Copy Bahasa Indonesia, **active voice**, dari sisi user ("Kirim sekarang",
   "Uang terkirim"). Error tidak minta maaf & tidak samar. Empty state = ajakan.

Contoh paling representatif untuk ditiru: `send_review_screen.dart`.

---

## 5. 🤖 Prompt template untuk generate screen dengan agent

Tempel ini ke agen kalian, isi bagian `[...]`. Output-nya akan patuh kontrak §4
sehingga langsung bisa ditaruh di `lib/screens/`.

```
Buatkan satu file Flutter screen untuk aplikasi remittance "Kirimin".

KONTEKS PRODUK:
- Aplikasi kirim uang untuk keluarga Indonesia. Terasa seperti aplikasi bank,
  BUKAN crypto. Dilarang keras muncul kata: crypto, wallet, seed phrase, gas,
  XLM, USDC, blockchain, token, contract address, private/public key.
- Bahasa Indonesia, active voice, dari sisi user.

ATURAN TEKNIS (WAJIB):
- `class [Nama]Screen extends ConsumerWidget` dengan const constructor.
- Bungkus dengan `AppScaffold(title:..., child:..., bottom:...)`
  dari '../widgets/widgets.dart'.
- Warna & teks HANYA dari '../app/theme.dart': AppColors, AppText, AppSpacing,
  AppRadii. DILARANG hardcode Color(0x...) atau TextStyle mentah.
- Pakai komponen siap pakai bila relevan: PrimaryButton, GhostButton,
  MoneyInput, AmountDisplay, FeeBreakdownCard, EmptyView, ErrorView, LoadingView.
- Uang diformat lewat formatMoney(...) dari '../core/money.dart'.
- Navigasi lewat context.goNamed(Routes.x) dari '../app/router.dart'.
- Baca state dgn ref.watch(...); aksi dgn ref.read(provider.notifier).method().
  JANGAN panggil WalletApi/PasskeyService langsung dari screen.
- Hanya SATU file, import lengkap, siap compile.

TUGAS SCREEN INI:
- Nama file: [nama_screen].dart, class: [Nama]Screen
- Tujuan: [jelaskan fungsi layar]
- Elemen: [daftar elemen UI]
- Aksi tombol: [tombol X → context.goNamed(Routes.Y) / panggil aksi Z]
```

Setelah dapat file: taruh di `lib/screens/`, lalu daftarkan rutenya (§7).

---

## 6. Passkey native — yang WAJIB benar (RISIKO #1)

Passkey tidak akan memunculkan biometrik kalau `.well-known` salah. Koordinasi
dengan backend:

- **iOS:** entitlement **Associated Domains** `webcredentials:<domain>` +
  file `https://<domain>/.well-known/apple-app-site-association`.
- **Android:** file `https://<domain>/.well-known/assetlinks.json` berisi
  SHA-256 fingerprint signing key app + setup Credential Manager.
- **RP_ID** (`env.dart` / `--dart-define`) **harus** = `<domain>` tsb.
- API package `passkeys` masih berkembang → **pin versi** di `pubspec.yaml`, lalu
  cek dua penanda `// MAP:` di `passkey_service.dart` bila nama field berubah.

Detail lengkap: `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §9.

---

## 7. Menambah screen baru (langkah wiring)

1. Taruh file di `lib/screens/xxx_screen.dart` (patuh §4).
2. Di `app/router.dart`: tambah konstanta di `Routes`, lalu `GoRoute` baru.
3. Kalau butuh data baru: tambah method di `WalletApi` + (opsional) controller di
   `state/`. Screen tetap tidak memanggil service langsung.

---

## 8. Kontrak endpoint backend (disepakati dgn tim backend)

| Method | Path | Body / Query | Balikan |
|---|---|---|---|
| GET | `/passkey/register-options` | `?userName=` | `{ challenge, userId }` |
| POST | `/wallet/create` | `{ userId, attestation }` | `{ userId, contractAddress, balanceUsd }` |
| POST | `/tx/build` | `{ userId, recipient, amountUsd }` | `{ txId, challenge, credentialIds[] }` |
| POST | `/tx/submit` | `{ txId, assertion }` | `{ txId }` (settle ~5s) |
| GET | `/wallet/:userId/balance` | — | `{ balanceUsd }` |

`challenge` = base64url; sinkronkan dengan signature payload yang diverifikasi
`__check_auth` (build plan §9 poin 3).

---

## 9. Catatan

- Nama app "Kirimin" placeholder — ganti bebas.
- Untuk identitas lebih kuat, tambahkan `google_fonts` (mis. Plus Jakarta Sans)
  dan isi `AppText._family` di `theme.dart`.
- `local_auth` disertakan hanya sebagai fallback UX; **bukan** pengganti passkey/
  secp256r1.
```
