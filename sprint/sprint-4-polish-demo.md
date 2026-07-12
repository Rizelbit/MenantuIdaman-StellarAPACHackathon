# Sprint 4 — Polish & Demo

## Tujuan Sprint

Mempersiapkan produk dan presenter agar demo berjalan mulus, memorable, dan bebas dari istilah crypto. Sprint ini adalah yang paling dekat dengan "packaging" — tidak ada fitur baru, hanya penghalusan dan persiapan panggung.

Sprint ini selesai bila **tim bisa melakukan dry run demo penuh (< 4 menit) tanpa panduan, di kedua device, tanpa error, dan seluruh checklist invisible-crypto lulus.**

## Definition of Done

- [ ] Semua 10 item invisible-crypto checklist ✓
- [ ] Splash screen dan icon terasa seperti aplikasi keuangan
- [ ] Demo script selesai dry run ≤ 4 menit di kedua device
- [ ] Video backup demo sudah direkam
- [ ] Script re-seed testnet tersedia bila testnet reset
- [ ] `.well-known` final verification lulus di kedua platform
- [ ] Slide deck final sudah di-align dengan demo script
- [ ] Setidaknya 1 anggota bisa bawakan demo tanpa melihat catatan

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S4-01](#s4-01--invisible-crypto-checklist-final) | Invisible-crypto checklist final | `TODO` | P0 |
| [S4-02](#s4-02--polish-splashscreen--icon-app) | Polish `SplashScreen` & icon app | `TODO` | P0 |
| [S4-03](#s4-03--verifikasi-semua-copy-bahasa-indonesia) | Verifikasi semua copy Bahasa Indonesia | `TODO` | P0 |
| [S4-04](#s4-04--well-known-final-verification) | `.well-known` final verification | `TODO` | P0 |
| [S4-05](#s4-05--demo-script-final--dry-run) | Demo script final + dry run | `TODO` | P0 |
| [S4-06](#s4-06--rekam-video-backup-demo) | Rekam video backup demo | `TODO` | P0 |
| [S4-07](#s4-07--siapkan-testnet-re-seed-script) | Siapkan testnet re-seed script | `TODO` | P0 |
| [S4-08](#s4-08--polish-loading--error-states) | Polish loading & error states | `TODO` | P1 |
| [S4-09](#s4-09--final-e2e-test-di-kedua-device) | Final E2E test di kedua device | `TODO` | P0 |
| [S4-10](#s4-10--slide-deck-alignment) | Slide deck alignment | `TODO` | P1 |
| [S4-11](#s4-11--warmup-backend-sebelum-demo) | Warmup backend sebelum demo | `TODO` | P1 |
| [S4-12](#s4-12--opsional-tambah-google-fonts-plus-jakarta-sans) | (Opsional) Tambah Google Fonts Plus Jakarta Sans | `TODO` | P2 |

---

## S4-01 — Invisible-crypto checklist final

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S3-10 (audit awal)

**Konteks:**  
Checklist definitif sebelum demo. Setiap item diverifikasi secara manual di device fisik, bukan hanya di kode.

**Checklist — verifikasi di device fisik:**

### Kata-kata terlarang (cari di seluruh codebase)
Jalankan di root repo:
```bash
grep -r "crypto\|wallet\|seed phrase\|seed-phrase\|gas\|XLM\|USDC\|blockchain\|token\|contract address\|private key\|public key\|RP_ID\|secp256r1" \
  frontend/lib/screens/ frontend/lib/widgets/ \
  --include="*.dart" -i
```
**Expected:** tidak ada match.

### Alur onboarding
- [ ] Splash screen tidak ada kata crypto
- [ ] OnboardingScreen: tidak ada "wallet", hanya "akun", "Face ID"
- [ ] Biometrik muncul dengan label "Kirimin" sebagai relying party name
- [ ] HomeScreen setelah daftar: "Saldo kamu" → Rupiah, bukan USD mentah

### Alur kirim
- [ ] SendAmountScreen: "Nominal kiriman", "Untuk siapa?" — tidak ada crypto
- [ ] Preview real-time: "Keluarga terima Rp X" — tidak ada "USDC", tidak ada "token"
- [ ] SendReviewScreen: FeeBreakdownCard → "Biaya layanan", bukan "network fee" atau "gas"
- [ ] Bottom sheet: "Konfirmasi dengan Face ID" — tidak ada "sign transaction"
- [ ] SendSuccessScreen: "Uang terkirim" — tidak ada "transaction hash"

### Sisi penerima
- [ ] ReceiveScreen: "Rp X masuk ke rekening" — tidak ada crypto
- [ ] Tidak ada QR code blockchain

### Checklist from build plan §4
- [ ] Tidak ada input/tampilan seed phrase di mana pun ✓
- [ ] Tidak ada private/public key / RP ID / contract address yang ditampilkan ✓
- [ ] Tidak ada kata "gas" / "XLM" ✓
- [ ] Saldo & nominal selalu dalam Rp ✓
- [ ] Sign transaksi = biometrik native (Face ID/fingerprint) ✓
- [ ] Onboarding < 30 detik, < 3 tap sampai wallet siap ✓
- [ ] Penerima tidak pernah lihat istilah crypto ✓
- [ ] Rincian biaya muncul SEBELUM konfirmasi ✓
- [ ] Copy familiar: "kirim uang", "saldo", "biaya" ✓
- [ ] Icon app / splash terasa aplikasi keuangan, bukan crypto ✓

**Acceptance criteria:**
- [ ] `grep` tidak menemukan kata-kata terlarang di `screens/` dan `widgets/`
- [ ] Semua 10 item checklist ✓

---

## S4-02 — Polish `SplashScreen` & icon app

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat

**Konteks:**  
Icon dan splash adalah kesan pertama. Saat ini SplashScreen menggunakan `Icons.send_rounded` — cukup, tapi bisa lebih "banking app". Icon app (launcher icon) belum di-customize.

**Opsi splash yang lebih banking:**
- Icon: burung origami kertas terbang (seperti transfer), atau simbol mata uang Rp, atau bulan sabit (motif lokal)
- Warna: `AppColors.primary` (teal pine) dengan background `AppColors.background`
- Nama "Kirimin" dengan tagline singkat

**Langkah — SplashScreen (minimal polish):**
1. Buka `frontend/lib/screens/splash_screen.dart`
2. Update ikon dari `Icons.send_rounded` ke `Icons.currency_exchange` atau ikon yang lebih banking
3. Tambahkan tagline: "Kirim uang ke keluarga"
4. Pastikan warna dari `AppColors`

**Langkah — Launcher icon (penting untuk demo):**
1. Siapkan icon PNG 1024x1024: teal (#0B6E63) background + simbol putih
2. Gunakan package `flutter_launcher_icons`:
   ```yaml
   # tambah ke pubspec.yaml dev_dependencies:
   flutter_launcher_icons: ^0.13.1
   ```
   ```yaml
   # tambah ke pubspec.yaml:
   flutter_icons:
     android: true
     ios: true
     image_path: "assets/icon/app_icon.png"
   ```
3. Taruh icon di `frontend/assets/icon/app_icon.png`
4. Jalankan: `dart run flutter_launcher_icons`

**File yang diubah/dibuat:**
- `frontend/lib/screens/splash_screen.dart` — update icon dan tagline
- `frontend/pubspec.yaml` — tambah `flutter_launcher_icons` di dev_dependencies + asset path
- `frontend/assets/icon/app_icon.png` (baru)

**Acceptance criteria:**
- [ ] Splash screen tidak terasa seperti crypto app
- [ ] Launcher icon custom muncul di home screen device (bukan icon Flutter default)
- [ ] Icon iOS dan Android sudah ter-generate

---

## S4-03 — Verifikasi semua copy Bahasa Indonesia

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Semua text di UI harus dalam Bahasa Indonesia, active voice, dari sisi user. Ini termasuk: label tombol, placeholder input, pesan error, empty state, label navigasi.

**Scan manual per screen:**

| Screen | Item | Current | Expected | OK? |
|--------|------|---------|----------|-----|
| OnboardingScreen | Button | "Buat akun dengan Face ID" | ✓ | — |
| OnboardingScreen | Assurance | "Aman dengan sidik jari / wajahmu" | ✓ | — |
| HomeScreen | Balance label | "Saldo kamu" | ✓ | — |
| HomeScreen | Empty state | "Belum ada transaksi" | ✓ | — |
| SendAmountScreen | Recipient label | "Untuk siapa?" | ✓ | — |
| SendAmountScreen | Amount label | "Nominal kiriman" | ✓ | — |
| SendAmountScreen | Hint | "Nama keluarga" | ✓ | — |
| SendReviewScreen | Title | "Periksa kiriman" | ✓ | — |
| SendReviewScreen | Speed label | "Sampai dalam beberapa detik" | ✓ | — |
| SendReviewScreen | Button | "Kirim sekarang" | ✓ | — |
| SendReviewScreen (busy) | Button | "Mengirim…" | ✓ | — |
| SendSuccessScreen | Heading | "Uang terkirim" | ✓ | — |
| SendSuccessScreen | Button | "Selesai" | ✓ | — |
| ReceiveScreen | Heading | "Rp X masuk" | ✓ | — |
| HistoryScreen | Empty state | "Belum ada transaksi" | ✓ | — |
| Biometric sheet | Headline | varies (dari `_confirm`) | — | — |
| Biometric sheet | Button | "Konfirmasi dengan Face ID" | ✓ | — |
| Biometric sheet | Cancel | "Batal" | ✓ | — |
| Error messages | Snackbar | Bahasa Indonesia ramah user | — | — |

**Acceptance criteria:**
- [ ] Semua text di atas sudah diperiksa
- [ ] Tidak ada text bahasa Inggris yang terlihat user (kecuali nama brand "Face ID", "Kirimin")
- [ ] Error messages tidak mengandung technical jargon

---

## S4-04 — `.well-known` final verification

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Final check bahwa semua `.well-known` file masih accessible dan valid. Krusial karena passkey tidak akan muncul tanpa ini.

**Langkah:**
```bash
# 1. Health check
curl -s https://<railway-url>/health | python3 -m json.tool

# 2. iOS AASA
curl -sv https://<railway-url>/.well-known/apple-app-site-association 2>&1 | \
  grep -E "HTTP|Content-Type|webcredentials"

# 3. Android Asset Links
curl -sv https://<railway-url>/.well-known/assetlinks.json 2>&1 | \
  grep -E "HTTP|Content-Type|package_name|sha256"

# 4. Verifikasi isi JSON
curl -s https://<railway-url>/.well-known/assetlinks.json | python3 -m json.tool
curl -s https://<railway-url>/.well-known/apple-app-site-association | python3 -m json.tool
```

**Test di device fisik:**
1. Uninstall + reinstall app di iOS device
2. Coba onboarding → verifikasi biometrik muncul (bukan error diam)
3. Uninstall + reinstall app di Android device
4. Coba onboarding → verifikasi Credential Manager muncul

**Acceptance criteria:**
- [ ] Semua 3 curl command mengembalikan HTTP 200
- [ ] JSON valid di kedua file
- [ ] iOS: biometrik muncul setelah fresh install
- [ ] Android: Credential Manager muncul setelah fresh install

---

## S4-05 — Demo script final + dry run

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Demo yang baik bercerita, bukan hanya menampilkan fitur. Script ini mengikuti pola dari `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §8.

**Script Demo (~3-4 menit):**

---

### Babak 1 — Masalah (15 detik)
> "Pekerja migran Indonesia mengirim pulang miliaran rupiah setiap tahun. Tapi mereka masih membayar 5–8% biaya dan menunggu 3–5 hari. Solusi crypto ada, tapi 90% orang kabur begitu lihat seed phrase."

### Babak 2 — Onboarding live (30 detik)
*[HP pengirim di tangan kiri presenter]*
> "Ini Kirimin. Daftar..."

*[Tap 'Buat akun dengan Face ID']*
> "...cukup pakai Face ID."

*[Face ID muncul → sukses → HomeScreen]*
> "Tidak ada seed phrase. Tidak ada kata sandi. Cukup wajah kamu. Di aplikasi biasa, bukan browser."

### Babak 3 — Kirim uang live (45 detik)
*[Tap 'Kirim' → SendAmountScreen]*
> "Kirim ke keluarga..."

*[Isi nama "Mama" dan nominal Rp 1.000.000]*
> "...Rp 1.000.000."

*[Preview 'Keluarga terima Rp 995.000' muncul live]*
> "Langsung keliatan biayanya — Rp 5.000. Transparan sebelum konfirmasi."

*[Tap 'Lanjut' → SendReviewScreen dengan FeeBreakdownCard]*
> "Rincian lengkap."

*[Tap 'Kirim sekarang' → bottom sheet → Face ID]*
> "Konfirmasi Face ID..."

*[Hitung: 1, 2, 3, 4, 5... → SendSuccessScreen]*
> "...5 detik. Uang terkirim."
> "Tidak ada gas. Tidak ada XLM. Tidak ada 'approve transaction'."

### Babak 4 — Sisi penerima (20 detik)
*[HP kedua di tangan kanan, atau minta seseorang pegang]*
> "Di sisi keluarga..."

*[Tunjukkan ReceiveScreen — 'Rp 995.000 masuk ke rekening BCA ****1234']*
> "Rp 995.000 masuk ke rekening. Mereka tidak pernah tahu ini jalan di atas blockchain."

### Babak 5 — Reveal teknis (30 detik)
> "Di balik layar: passkey secp256r1 native — Protocol 21 Stellar. USDC. Fee di-sponsor via Launchtube. Settlement 5 detik, sub-sen. HP hanya pegang biometrik. Backend yang rakit transaksinya."

### Babak 6 — Tutup (20 detik)
> "Koridor pekerja migran Indonesia — $15 miliar per tahun — yang paling under-served di Asia Tenggara. Roadmap: anchor real, KYC SEP-12, kurs live SEP-38, publish ke App Store. Terima kasih."

---

**Dry run checklist:**
- [ ] Dry run 1: presenter baca script sambil demo — ukur waktu
- [ ] Dry run 2: presenter hafal poin utama, tanpa baca script
- [ ] Dry run 3: demo dengan audience 1 orang, tanya Q&A

**Acceptance criteria:**
- [ ] Total demo ≤ 4 menit
- [ ] Presenter tidak menyebut kata crypto/wallet/seed phrase/gas
- [ ] Transisi antar screen mulus, tidak ada loading aneh
- [ ] Q&A setidaknya 3 pertanyaan bisa dijawab (lihat build plan §8)

---

## S4-06 — Rekam video backup demo

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Stellar Testnet bisa flaky saat demo. Video backup adalah asuransi. **Wajib ada sebelum hari demo.**

**Langkah:**
1. Record video di iPhone/Android (kamera ke layar HP demo, atau screen recording)
2. Tampilkan screen recording device + audio presenter narasi
3. Rekam satu run penuh mengikuti demo script (§ S4-05)
4. Verifikasi kualitas: resolusi cukup, audio jelas, semua teks terbaca
5. Simpan di Google Drive / iCloud yang bisa diakses seluruh tim

**Alternatif:** Screen recording via `flutter run` → mirror di Mac/PC → QuickTime recording.

**Acceptance criteria:**
- [ ] Video tersimpan minimal di 2 tempat (local + cloud)
- [ ] Video memperlihatkan alur lengkap dari onboarding sampai receive
- [ ] Durasi ≤ 4 menit, kualitas jelas

---

## S4-07 — Siapkan testnet re-seed script

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Stellar Testnet bisa reset tanpa pemberitahuan. Bila ini terjadi saat demo, seluruh wallet dan USDC testnet hilang. Script re-seed memungkinkan setup ulang dalam < 5 menit.

**Langkah:**
1. Buat file `scripts/reseed-testnet.sh`:

```bash
#!/bin/bash
# Re-seed script — jalankan setelah testnet reset atau untuk reset demo state
# Prasyarat: stellar CLI terinstall, keypair deployer & demo-* sudah ada

set -e

echo "Funding accounts via Friendbot..."
stellar account fund deployer --network testnet
stellar account fund demo-sender --network testnet
stellar account fund demo-receiver --network testnet

echo "Adding USDC trustlines..."
USDC_ISSUER="GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5"

stellar tx new change-trust \
  --source demo-sender --network testnet \
  --asset "USDC:$USDC_ISSUER" --limit 10000

stellar tx new change-trust \
  --source demo-receiver --network testnet \
  --asset "USDC:$USDC_ISSUER" --limit 10000

echo "Funding demo-sender with USDC testnet..."
# TODO: mint test-USD atau gunakan faucet
# Opsional: stellar tx new payment --source <usdc-faucet> ...

echo "Deploy Passkey Kit factory..."
# stellar contract deploy --wasm ... --source deployer --network testnet
# Update FACTORY_CONTRACT_ID di Railway env vars

echo "Re-seed complete!"
echo "Ingat: update FACTORY_CONTRACT_ID di Railway dashboard"
```

2. `chmod +x scripts/reseed-testnet.sh`

**File yang diubah/dibuat:**
- `scripts/reseed-testnet.sh` (baru)
- `.gitignore` — pastikan file secrets tidak di-include

**Acceptance criteria:**
- [ ] Script tersedia dan executable
- [ ] Ditest minimal sekali: jalankan reseed dan verifikasi akun terfund
- [ ] Seluruh tim tahu cara menjalankan script ini

---

## S4-08 — Polish loading & error states

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** feat

**Konteks:**  
Selama operasi async (onboarding, kirim), UI harus menampilkan state yang jelas. Verifikasi dan polish semua loading & error states.

**Checklist loading states:**
- [ ] OnboardingScreen: loading = spinner di tombol ("Buat akun dengan Face ID" disabled)
- [ ] SendReviewScreen: signing → "Mengirim…" di tombol
- [ ] SendReviewScreen: submitting → "Mengirim…" di tombol (tetap)
- [ ] HomeScreen: saldo sedang di-fetch → tidak crash atau menampilkan 0 tanpa sebab

**Checklist error states:**
- [ ] Semua Snackbar error dalam Bahasa Indonesia
- [ ] Setelah error, user bisa retry (button tidak stuck disabled)
- [ ] `AuthController._fail()` mengembalikan state yang benar agar UI tidak freeze
- [ ] `SendController._error()` set `phase = SendPhase.error` dengan `errorMessage`

**Acceptance criteria:**
- [ ] Tidak ada loading state yang "frozen" (spinner abadi tanpa timeout)
- [ ] Semua error menampilkan pesan Bahasa Indonesia
- [ ] User bisa retry setelah setiap jenis error

---

## S4-09 — Final E2E test di kedua device

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S4-01, S4-02, S4-04

**Konteks:**  
Test final lengkap sebelum demo. Lakukan dengan setting seperti hari-H: no USB debug, HP dalam kondisi demo, tidak ada notifikasi gangguan.

**Setup:**
1. iOS: flight mode → airplane off (koneksi WiFi stabil)
2. Android: DND on, brightness max, tidak ada notifikasi
3. Backend: Railway sudah running (lakukan warmup request dulu)

**Skenario test:**
1. Uninstall app di kedua device
2. Install ulang (via `flutter install` atau drag IPA/APK)
3. iOS: full demo script (onboarding → kirim → receive)
4. Android: full demo script

**Acceptance criteria:**
- [ ] Demo selesai penuh di iOS tanpa intervensi teknis
- [ ] Demo selesai penuh di Android tanpa intervensi teknis
- [ ] Waktu onboarding: < 30 detik
- [ ] Waktu settlement: < 10 detik (testnet)
- [ ] Tidak ada istilah crypto yang muncul di layar mana pun

---

## S4-10 — Slide deck alignment

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore

**Konteks:**  
Slide harus align dengan demo live — terutama saat Babak 5 ("reveal teknis"). Beberapa poin kunci yang harus ada di slide:

**Checklist slide:**
- [ ] Slide masalah: data kuantitatif ($15B IDR remittances, 5–8% fee, 90% drop-off at seed phrase)
- [ ] Slide solusi: "terasa seperti transfer bank" — bukan "crypto wallet"
- [ ] Slide arsitektur (optional, tapi kuat): 3-layer (Flutter → Node/Passkey Kit → Stellar)
- [ ] Slide tech stack: Protocol 21, Passkey Kit, Launchtube, USDC, SAC — framing sebagai "mesin di balik layar"
- [ ] Slide positioning: koridor Indonesia, under-served vs Filipina
- [ ] Slide future work: anchor real, KYC SEP-12, kurs SEP-38, store publish
- [ ] Slide regulasi: remitansi lintas-batas + off-ramp via VASP berlisensi (bukan stablecoin domestik)

**Acceptance criteria:**
- [ ] Slide dapat dipresentasikan oleh semua anggota tim
- [ ] Tidak ada klaim yang tidak bisa dibuktikan di demo
- [ ] Slide regulasi ada (untuk antisipasi pertanyaan juri)

---

## S4-11 — Warmup backend sebelum demo

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore

**Konteks:**  
Railway free tier menggunakan container yang mungkin "tidur" bila tidak ada traffic. Cold start bisa 30–60 detik. Lakukan warmup 5 menit sebelum demo agar request pertama tidak lambat.

**Langkah:**
1. Setup cron job simple atau request manual:
   ```bash
   # Jalankan 5 menit sebelum demo
   curl https://<railway-url>/health
   ```
2. Atau tambahkan uptime monitor: [UptimeRobot](https://uptimerobot.com) (gratis) → ping `/health` setiap 5 menit → backend tidak pernah tidur.

**Acceptance criteria:**
- [ ] `curl /health` merespons dalam < 2 detik saat demo dimulai
- [ ] Ada prosedur warmup yang terdokumentasi untuk hari-H

---

## S4-12 — (Opsional) Tambah Google Fonts Plus Jakarta Sans

**Status:** `TODO` | **Prioritas:** P2 | **Tipe:** feat

**Konteks:**  
`app/theme.dart` sudah menyiapkan `AppText._family = null` dengan TODO untuk Plus Jakarta Sans. Font ini dirancang di Indonesia — memperkuat narasi "aplikasi keuangan lokal" sekaligus terlihat premium.

**Langkah (bila ada waktu):**
1. Tambah ke `pubspec.yaml`:
   ```yaml
   google_fonts: ^6.2.1
   ```
2. Di `frontend/lib/app/theme.dart`, update `AppText`:
   ```dart
   import 'package:google_fonts/google_fonts.dart';
   
   // Ganti semua TextStyle di AppText agar pakai Plus Jakarta Sans:
   static final displayMoney = GoogleFonts.plusJakartaSans(
     fontSize: 40,
     fontWeight: FontWeight.w700,
     // ... rest of properties
   );
   ```
3. Atau gunakan cara global: di `buildAppTheme()`:
   ```dart
   return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(...);
   ```

**Acceptance criteria:**
- [ ] Font muncul di semua screen
- [ ] `flutter analyze` tidak error
- [ ] UI tidak ada overflow karena perubahan font metrics

---

## Antisipasi Pertanyaan Juri

Dari `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §8:

| Pertanyaan | Jawaban singkat |
|-----------|----------------|
| "Bedanya sama MoneyGram/Coins.ph?" | UX passkey native tanpa seed phrase + fokus koridor Indonesia under-served + transparansi biaya |
| "Legal di Indonesia?" | Remitansi lintas-batas + off-ramp ke IDR via VASP/MTO berlisensi. Crypto tidak dipakai sebagai alat bayar domestik. |
| "Recovery kalau HP hilang?" | Passkey bisa sync via iCloud Keychain / Google Password Manager. Roadmap: social recovery via multi-signer. Di luar scope MVP. |
| "Kenapa native, bukan web?" | Face ID di dalam app terasa seperti aplikasi bank. Passkey terikat aman via Associated Domains. Distribusi via store. |
| "Skalabilitas?" | Soroban sub-sen per tx + Launchtube fee abstraction. Throughput Stellar 1000+ TPS. |

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| | | |

## Blockers & Catatan

> _Sprint ini paling sering terhambat oleh testnet yang flaky menjelang akhir. Bila testnet reset di menit-menit terakhir: gunakan re-seed script (S4-07) + video backup (S4-06)._
