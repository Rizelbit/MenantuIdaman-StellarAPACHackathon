# Kirimin — Checklist Final Sebelum Demo

Dokumen ini adalah **titik kumpul terakhir** dari seluruh backlog Sprint 0–4 (`sprint/sprint-0-foundation.md` s/d `sprint/sprint-4-polish-demo.md`). Semua yang bisa dikerjakan lewat kode/config sudah selesai dan sudah di-commit ke `main`. Yang tersisa di sini **semuanya butuh akses yang tidak tersedia di environment kerja Claude** — Railway dashboard, device fisik Android, atau eksekusi manual oleh manusia (rekam video, latihan presenter).

**Cara pakai:** kerjakan berurutan dari Prioritas 0 ke bawah — tiap prioritas adalah prasyarat untuk prioritas setelahnya. Jangan loncat ke Prioritas 3 kalau Prioritas 0 belum beres; hasilnya akan gagal dengan cara yang membingungkan (misal: HTTP 200 tapi wallet tidak pernah ter-deploy on-chain).

Setiap poin mencantumkan **[Referensi]** ke bagian sprint doc yang relevan — buka file itu kalau butuh konteks lebih dalam soal *kenapa* langkah itu diperlukan.

---

## Ringkasan: apa yang sudah pasti selesai

Supaya tidak dikerjakan ulang — ini semua **sudah diverifikasi** (lewat `tsc`, test otomatis, atau curl live terhadap Railway production):

| Area | Status |
|------|--------|
| Backend: 5 endpoint inti (`register-options`, `wallet/create`, `tx/build`, `tx/submit`, `wallet/:id/balance`) | ✓ Diimplementasikan, kontrak data Flutter↔backend nol mismatch (S3-01) |
| Backend: endpoint tambahan (`home/feed`, `contacts`, `requests`, `splits`, `wallet/:id/fund`) | ✓ Diimplementasikan, field cocok dengan model Flutter |
| `.well-known` (AASA + assetlinks.json) | ✓ Live di Railway, Content-Type benar, JSON valid (dicek live 2026-07-16) |
| Bug `USDC_SAC_ADDRESS` (contract ID tidak valid) | ✓ Fixed — sekarang dihitung dari `USDC_ISSUER`, bukan hardcode |
| Bug `USE_MOCK` (app selalu pakai data palsu) | ✓ Fixed — `run-dev.sh` selalu pass `USE_MOCK=false` |
| Dockerfile (npm ci vs pnpm) | ✓ Fixed — deploy Railway tidak lagi dijamin gagal |
| Balance pre-check di `/tx/build` ("Saldo tidak cukup") | ✓ Ditambahkan |
| Android package rename, entitlements, launcher icon, font | ✓ Selesai (S0-08, S4-02, S4-12) |
| Dokumentasi Sprint 0–4 | ✓ Direkonsiliasi penuh dengan kode aktual |

**Yang TIDAK bisa saya verifikasi otomatis** (alasan di setiap prioritas di bawah): status live `RELAYER_API_KEY`/`SIGNER_SECRET_KEY` di Railway, dan **semua yang butuh device fisik** — belum ada satupun wallet yang benar-benar ter-deploy on-chain dari device sungguhan sampai dokumen ini ditulis.

---

## 🔴 PRIORITAS 0 — Blocker mutlak (tanpa ini, aplikasi tidak berfungsi sama sekali)

### 0.1 Verifikasi `RELAYER_API_KEY` benar-benar aktif di Railway

**[Referensi: `sprint/sprint-0-foundation.md` § S0-11, `sprint/sprint-1-passkey-onboarding.md` § S1-05, `sprint/sprint-2-send-flow.md` § S2-02]**

**Kenapa ini prioritas #1 mutlak:** `PasskeyServer.send()` (dipanggil di `/wallet/create` dan `/tx/submit`) **selalu** butuh relayer terkonfigurasi. Tanpa `RELAYER_BASE_URL`/`RELAYER_API_KEY` yang valid, setiap panggilan gagal dengan `RELAYER_NOT_CONFIGURED` — dan yang lebih berbahaya, `/wallet/create` **tidak mengecek keberhasilan submit sebelum lanjut**, jadi API akan balas `200 OK` dengan `contractAddress` yang terlihat valid padahal wallet-nya **tidak pernah benar-benar ter-deploy on-chain**. Ini ditemukan dengan cara paling meyakinkan yang bisa dilakukan tanpa device — install `node_modules` beneran dan baca `node_modules/passkey-kit/dist/server.js` langsung.

**Kenapa ini "verifikasi", bukan "kerjakan dari nol":** ada indikasi kuat ini sudah diisi — sesi sebelumnya kamu pernah membagikan env var lokal yang sudah berisi `RELAYER_BASE_URL=https://channels.openzeppelin.com` dan `RELAYER_API_KEY` dengan format UUID yang valid. Tapi saya tidak punya akses Railway dashboard untuk konfirmasi ini benar-benar ter-deploy di production (bukan cuma di `.env` lokal seseorang).

**Langkah verifikasi:**
1. Buka Railway dashboard → project → service → tab **Variables**. Konfirmasi `RELAYER_BASE_URL` dan `RELAYER_API_KEY` terisi (bukan kosong, bukan placeholder).
2. Kalau belum terisi: generate key baru — **gratis, instan, tanpa approval**:
   ```bash
   curl https://channels.openzeppelin.com/testnet/gen
   # Respons: {"apiKey":"<uuid>"}
   ```
   Isi `RELAYER_BASE_URL=https://channels.openzeppelin.com` dan `RELAYER_API_KEY=<apiKey di atas>` di Railway. Simpan juga di `sprint/SECRETS.md` (sudah gitignore) supaya tim lain tidak generate ulang.
3. Kalau sudah terisi: lanjut ke langkah verifikasi fungsional di 0.3 di bawah (baru bisa dites setelah ada wallet).

**File terkait (sudah benar, tidak perlu diubah):** `backend/src/passkey.ts` fungsi `getServer()` — sudah mengonsumsi kedua env var ini dengan benar.

### 0.2 Verifikasi `SIGNER_SECRET_KEY` bukan placeholder

**[Referensi: `sprint/sprint-1-passkey-onboarding.md` § S1-02]**

`SIGNER_SECRET_KEY` dipakai sebagai `deploySource` di `PasskeyKit` — menandatangani transaksi *deploy* wallet baru (beda dari `RELAYER_API_KEY` yang menangani *submission*, keduanya wajib, bukan pengganti satu sama lain). Kalau env ini masih string literal seperti `"PLACEHOLDER"`, `/wallet/create` akan gagal dengan error signing, bukan error relayer — gejalanya beda, jadi kalau sudah isi 0.1 tapi masih gagal, cek ini dulu.

**Langkah:** Railway dashboard → Variables → pastikan `SIGNER_SECRET_KEY` diisi secret key Stellar asli (format `S` + 55 karakter) dari `sprint/SECRETS.md`, bukan teks placeholder.

### 0.3 Verifikasi fungsional: buat 1 wallet, cek log Railway

Setelah 0.1 dan 0.2 terisi, verifikasi paling murah (tidak perlu device fisik dulu) adalah cek Railway **deploy log** setelah ada percobaan `/wallet/create` — tapi karena endpoint ini butuh attestation WebAuthn asli, verifikasi penuh baru bisa jalan bareng Prioritas 1 (device test) di bawah. Tandanya:
- **Sukses:** log `[wallet/create] deploy tx: <hash>` muncul.
- **Gagal relayer:** log `[wallet/create] deploy failed: ...RELAYER_NOT_CONFIGURED...` — berarti 0.1 belum benar.
- **Gagal signing:** error terkait secret key invalid — berarti 0.2 belum benar.

---

## 🟠 PRIORITAS 1 — Device test pertama: Onboarding (Android)

**[Referensi: `sprint/sprint-1-passkey-onboarding.md` § S1-07, `sprint/sprint-0-foundation.md` § S0-14]**

**Prasyarat:** Prioritas 0 selesai. **iOS di-skip permanen** (kendala biaya Apple Developer Program) — semua device test dari sini pakai **Android saja**.

### 1.1 Siapkan Flutter environment

```bash
cd frontend
flutter pub get
```

Cek dokumentasi package `passkeys` (`^2.4.0`) kalau ada langkah manual tambahan untuk Android — kemungkinan besar sudah cukup, karena `AndroidManifest.xml` + `strings.xml` sudah dikonfigurasi (S0-08).

### 1.2 Jalankan ke device fisik — **WAJIB pakai flag ini**

```bash
./run-dev.sh -d <android-device-id>
```

`run-dev.sh` **sudah otomatis** pass `--dart-define=USE_MOCK=false`. Kalau menjalankan `flutter run` manual (bukan lewat script ini), **WAJIB tambahkan flag ini sendiri**:
```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=BACKEND_URL=https://menantuidaman-stellarapachackathon-production.up.railway.app \
  --dart-define=RP_ID=menantuidaman-stellarapachackathon-production.up.railway.app
```
**Kenapa ini kritis:** `Env.useMock` default `true` di `frontend/lib/app/env.dart`. Tanpa flag ini, app **selalu** pakai `MockPasskeyService`/`MockWalletApi` — kelihatan "berhasil" di layar padahal tidak pernah menyentuh backend asli sama sekali. Ini jebakan paling gampang bikin salah kesimpulan "sudah jalan".

### 1.3 Jalankan flow onboarding & verifikasi

1. Splash → OnboardingScreen → tap "Buat akun dengan Face ID"
2. **Verifikasi biometrik/Credential Manager Android muncul** (bukan alert biasa)
3. Setelah biometrik sukses → harus masuk HomeScreen
4. Pantau log device:
   ```bash
   adb logcat | grep -iE "asset|credential|fido"
   ```
   Tidak boleh ada error terkait Digital Asset Links / domain verification.
5. Cek Railway logs untuk `[wallet/create] deploy tx: <hash>` — **ini bukti wallet benar-benar ter-deploy on-chain**, bukan cuma HTTP 200.

### 1.4 Verifikasi on-chain di Stellar Expert

**[Referensi: `sprint/sprint-1-passkey-onboarding.md` § S1-08]**

Ambil `contractAddress` dari response `/wallet/create` (atau Railway log) → buka:
```
https://stellar.expert/explorer/testnet/contract/<contractAddress>
```
Verifikasi contract exists dan ada creation transaction.

**Setelah langkah ini berhasil:** catat `contractAddress` yang muncul — dibutuhkan untuk Prioritas 2.

---

## 🟠 PRIORITAS 2 — Setup penerima demo & funding USDC

**[Referensi: `sprint/sprint-2-send-flow.md` § S2-10, § S1b di dokumen ini]**

Ini **chicken-and-egg** yang cuma bisa diselesaikan setelah Prioritas 1 berhasil minimal sekali (perlu wallet asli untuk didapat contract address-nya).

### 2.1 Buat wallet kedua sebagai "penerima" (Rani Putri)

Ulangi Prioritas 1 sekali lagi dengan **user baru** (nama berbeda saat register) — device yang sama atau device kedua. Catat `contractAddress` wallet kedua ini.

**Kenapa namanya harus konsisten:** demo script (`sprint/sprint-4-polish-demo.md` § S4-05, sudah direvisi) pakai nama **"Rani Putri"** sebagai penerima — ini harus konsisten dengan nama yang **di-hardcode** di `frontend/lib/screens/receive_screen.dart` (frontend sudah di-lock, tidak bisa diubah lagi). Kalau saat demo presenter mengetik nama lain di kolom penerima, cerita "HP kedua nunjukin akun Rani Putri" jadi tidak nyambung secara logis (walau secara teknis tetap jalan lewat fallback `DEMO_RECEIVER_CONTRACT`).

### 2.2 Isi `DEMO_RECEIVER_CONTRACT` di Railway

```
DEMO_RECEIVER_CONTRACT=<contractAddress dari 2.1>
```

Simpan juga di `sprint/CONFIG.md` § Stellar Testnet baris "Demo Receiver Contract Address" (nilai ini **bukan** secret, aman di-commit).

**Kenapa ini penting:** `resolveRecipient()` di `backend/src/index.ts` mencoba 4 cara resolve penerima berurutan — userId langsung, contract address langsung, nama kontak terdaftar, baru fallback ke `DEMO_RECEIVER_CONTRACT`. Kalau env ini kosong dan penerima tidak match cara manapun, `/tx/build` balas error "Penerima tidak ditemukan".

### 2.3 Fund wallet pengirim dengan USDC testnet

**[Referensi: dokumen ini § 1b versi sebelumnya, `sprint/sprint-2-send-flow.md` § S2-03]**

**Kenapa `token.mint()` TIDAK dipakai:** `USDC_ISSUER` (`GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5`) adalah issuer testnet **resmi Circle** — kita tidak memegang secret key-nya, jadi `mint()` akan selalu gagal (butuh otoritas issuer). Solusi: transfer dari akun yang **sudah** punya saldo USDC.

**Langkah:**
1. Buka [faucet.circle.com](https://faucet.circle.com/) (gratis, tanpa akun, instan) → pilih network **Stellar** → isi alamat G dari `demo-sender` (`sprint/CONFIG.md` § Stellar Testnet, "Demo Sender Public Key") → **Get Tokens**.
2. Isi env var baru di Railway:
   ```
   DEMO_FUNDER_SECRET_KEY=<secret key demo-sender, dari sprint/SECRETS.md>
   ```
3. Panggil endpoint fund untuk wallet pengirim (dari Prioritas 1, bukan wallet penerima):
   ```bash
   curl -X POST https://menantuidaman-stellarapachackathon-production.up.railway.app/wallet/<userId-pengirim>/fund \
     -H "Content-Type: application/json" \
     -d '{"amountUsd": 50}'
   ```
4. Verifikasi: `GET /wallet/<userId-pengirim>/balance` harus mengembalikan `balanceUsd` > 0.

**Catatan penting:** endpoint `/wallet/:userId/fund` **belum pernah dieksekusi live** — kodenya sudah `tsc`-clean dan logic-nya diverifikasi terhadap tipe SDK asli (`AssembledTransaction.signAndSend()`, `basicNodeSigner`), tapi saya tidak memegang secret key asli untuk mengetesnya sendiri. **Jalankan ini di luar jam demo dulu** untuk pastikan berfungsi sebelum diandalkan saat presentasi.

---

## 🟡 PRIORITAS 3 — Verifikasi alur kirim uang (Send Flow)

**[Referensi: `sprint/sprint-2-send-flow.md` § S2-06, S2-07, S2-08, `sprint/sprint-3-integration.md` § S3-04]**

**Prasyarat:** Prioritas 1 & 2 selesai (ada wallet pengirim berisi USDC, ada wallet/env penerima).

### 3.1 Test kirim uang end-to-end di device

Dari HomeScreen wallet pengirim:
1. Tap "Kirim" → isi nama **"Rani Putri"** (harus persis, lihat 2.1) + nominal (misal Rp 1.000.000)
2. Verifikasi preview real-time: **"Keluarga terima Rp 1.000.000"** — bukan Rp 995.000. **Fee di app ini 0% by design** (`Env.feeRate = 0.0` di `frontend/lib/app/env.dart`, komentar eksplisit: "Demo: nol biaya"). Kalau ada materi lama (slide, catatan) yang menyebut fee 0,5%/Rp 995.000, itu sudah basi — abaikan.
3. Tap "Lanjut" → `SendReviewScreen` dengan `FeeBreakdownCard`
4. Tap "Kirim sekarang" → Face ID/fingerprint → tunggu settle
5. Verifikasi `SendSuccessScreen`: "Uang terkirim. Rani Putri menerima Rp 1.000.000."
6. Kembali ke HomeScreen → **verifikasi saldo berkurang**

### 3.2 Verifikasi balance update

**[Referensi: `sprint/sprint-3-integration.md` § S3-05]**

Kode di kedua sisi sudah diverifikasi benar via code review:
- `send_controller.dart` `confirmAndSend()` memanggil `api.getBalanceUsd()` setelah submit sukses.
- Backend `/tx/submit` memanggil `getUsdcBalance()` (query on-chain asli lewat Soroban RPC) sebelum mencatat transaksi.

Yang perlu dites live: apakah angka yang **benar-benar tampil di layar** berubah sesuai — code review tidak bisa membuktikan rendering.

### 3.3 Verifikasi transaksi di Stellar Expert

Dari Railway log `/tx/submit`, ambil transaction hash → buka:
```
https://stellar.expert/explorer/testnet/tx/<txHash>
```
Verifikasi: operation type `invoke_contract`, amount sesuai, sender/receiver contract address sesuai, fee disponsori (bukan dari wallet user).

### 3.4 Test repeat send (tanpa restart backend)

**[Referensi: `sprint/sprint-3-integration.md` § S3-09]**

Kirim 3x berturut-turut tanpa restart Railway. `SendController.reset()` sudah dikonfirmasi terpanggil setelah tap "Selesai" (`send_success_screen.dart`). **Catatan teknis (bukan blocker):** `txStore` di backend tidak punya TTL/expiry — kalau ada percobaan kirim yang di-cancel di tengah jalan (bukan sukses/gagal, tapi ditinggal), entry-nya nyangkut di memory sampai server restart. Tidak masalah untuk skala demo (beberapa transaksi saja).

---

## 🟡 PRIORITAS 4 — Error states & code health

**[Referensi: `sprint/sprint-1-passkey-onboarding.md` § S1-09, `sprint/sprint-2-send-flow.md` § S2-09, `sprint/sprint-0-foundation.md` § S0-14]**

### 4.1 `flutter analyze`

```bash
cd frontend
flutter analyze
```
Tidak boleh ada **error** (warning boleh). Belum pernah dijalankan sama sekali — tidak ada Flutter SDK di environment kerja Claude.

### 4.2 Test skenario error onboarding

| Skenario | Cara memicu | Expected |
|----------|------------|----------|
| User cancel biometrik | Tap cancel di prompt | Snackbar: "Verifikasi dibatalkan. Coba lagi ketika siap." |
| Network error | Matikan internet saat tap "Buat akun" | Snackbar: "Koneksi terputus. Cek internet lalu coba lagi." |
| Backend error 500 | Matikan Railway sementara | Snackbar pesan generic, bukan stack trace |

### 4.3 Test skenario error send

| Skenario | Cara memicu | Expected |
|----------|------------|----------|
| Cancel biometrik saat konfirmasi kirim | Tap cancel di Face ID prompt | Kembali ke `SendReviewScreen`, Snackbar error |
| Network error saat build/submit tx | Matikan internet di titik itu | Snackbar error sesuai |
| **Saldo tidak cukup** | Kirim nominal > saldo | **Sudah diperbaiki** — backend sekarang balas `400 {"error": "Saldo tidak cukup"}` eksplisit sebelum sempat bangun tx (sebelumnya keluar sebagai error 500 generic) |

Untuk semua skenario: user harus bisa retry (tombol tidak stuck disabled), dan tidak ada istilah teknis ("Exception", "Error 500") yang tampil ke user.

---

## 🟢 PRIORITAS 5 — Persiapan demo panggung

**[Referensi: `sprint/sprint-4-polish-demo.md` — seluruh isi]**

**Prasyarat:** Prioritas 1–4 lolos minimal sekali.

### 5.1 Invisible-crypto checklist final (S4-01)

Grep forbidden-words sudah dijalankan berkali-kali dan **konsisten bersih**:
```bash
grep -r "crypto\|wallet\|seed phrase\|gas\|XLM\|USDC\|blockchain\|token\|contract address\|private key\|public key\|RP_ID\|secp256r1" \
  frontend/lib/screens/ frontend/lib/widgets/ --include="*.dart" -i
```
8/10 item checklist build-plan §4 sudah terverifikasi dari code review. 2 sisa yang **butuh device fisik**: label relying-party name yang benar-benar muncul di prompt biometrik OS, dan durasi onboarding aktual (target < 30 detik).

### 5.2 Scan copy Bahasa Indonesia lengkap (S4-03)

`ReceiveScreen` sudah di-scan & diperbaiki (sebelumnya 100% bahasa Inggris). Screen lain (Onboarding, Home, Send*) **belum di-scan ulang manual satu-per-satu** di sesi terakhir — kemungkinan besar masih akurat, tapi perlu dikonfirmasi visual di device.

### 5.3 Dry run demo script (S4-05) — **3x sesuai checklist asli**

Script sudah final (lihat `sprint/sprint-4-polish-demo.md` § S4-05 untuk teks lengkap per babak). Ringkasan alur: masalah (15s) → onboarding live (30s) → kirim uang live (45s) → sisi penerima (20s, tunjukkan `ReceiveScreen` Rani Putri) → reveal teknis (30s) → tutup (20s). Total target ≤ 4 menit.

1. Dry run 1: presenter baca script sambil demo — ukur waktu
2. Dry run 2: presenter hafal poin utama, tanpa baca script
3. Dry run 3: demo dengan audience 1 orang, tanya Q&A (lihat tabel "Antisipasi Pertanyaan Juri" di sprint doc)

### 5.4 Rekam video backup (S4-06)

**Wajib ada sebelum hari-H** — testnet bisa flaky. Rekam 1 run penuh mengikuti script final (5.3), simpan minimal di 2 tempat (lokal + cloud).

### 5.5 Final E2E test — 2 device Android

**[Referensi: `sprint/sprint-4-polish-demo.md` § S4-09]**

Bukan lagi iOS+Android — **2 Android**. Setup: DND on, brightness max, no notifikasi, backend sudah di-warmup (5.7). Uninstall+install ulang app di kedua device, jalankan script demo penuh.

### 5.6 Slide deck alignment (S4-10)

Di luar kapasitas teknis (bukan file kode) — tapi **koreksi wajib**: kalau ada slide yang menyebut "Launchtube" di bagian tech stack, ganti ke **"OpenZeppelin Channels"** (Launchtube deprecated & tidak dipakai sama sekali, S0-11).

### 5.7 Warmup backend hari-H (S4-11)

```bash
curl https://menantuidaman-stellarapachackathon-production.up.railway.app/health
```
Jalankan ~5 menit sebelum demo mulai (Railway container bisa "tidur" kalau idle lama, cold start 30-60 detik). Terakhir dites 2026-07-16: 0,47 detik — sehat, tapi itu snapshot satu waktu, tetap warmup ulang di hari-H.

---

## ⚪ OPSIONAL — iOS (di-skip permanen, tapi didokumentasikan kalau ingin direvisit)

**[Referensi: `sprint/sprint-0-foundation.md` § S0-07]**

Keputusan tim: skip karena Apple Developer Program berbayar ($99/tahun) tidak tersedia. Kalau suatu saat ingin dihidupkan lagi:

1. Daftar Apple Developer Program → dapat **Team ID** (10 karakter).
2. Update `backend/public/.well-known/apple-app-site-association` — ganti `TEAM_ID_NANTI_DIISI` jadi Team ID asli.
3. Update `frontend/ios/Runner.xcodeproj/project.pbxproj` — tambahkan `DEVELOPMENT_TEAM = <TEAM_ID>;` di 3 build config Runner (Debug/Release/Profile), sejajar `CODE_SIGN_ENTITLEMENTS` yang sudah ada.
4. Commit & push, verifikasi AASA live dengan Team ID benar.
5. Buka `frontend/ios/Runner.xcworkspace` (bukan `.xcodeproj`) di Xcode → Signing & Capabilities → verifikasi Associated Domains muncul (harusnya otomatis, `Runner.entitlements` sudah ada).
6. Build & run ke device iOS fisik.

Kalau dihidupkan, S0-07/S1-06/S2-05/S3-03 (semua ditandai `SKIPPED` di sprint doc) perlu diubah statusnya kembali dan dites ulang.

---

## Catatan teknis (bukan blocker, tapi baik untuk diketahui)

Temuan yang tidak mem-blok demo tapi berpotensi membingungkan kalau tidak diketahui sebelumnya:

1. **Fee rate 0%, bukan 0,5%** — `Env.feeRate = 0.0` di `frontend/lib/app/env.dart`, keputusan produk yang disengaja ("nol biaya" demo). Materi lama (dokumen sprint asli, mungkin slide) yang menyebut "Biaya layanan 0,5%" atau "Rp 995.000" sudah tidak akurat.
2. **Rate konversi USD→IDR (16350) di-duplikasi di 2 tempat** — `backend/src/index.ts` (`USD_TO_IDR`) dan `frontend/lib/app/env.dart` (`Env.usdToIdr`). Saat ini sama persis, tapi kalau salah satu diubah tanpa yang lain, akan drift. Tidak diperbaiki (butuh keputusan arsitektur: single source of truth di mana), cuma dicatat sebagai risiko.
3. **`txStore` tanpa TTL** — lihat Prioritas 3.4. Low-risk untuk skala demo.
4. **`ReceiveScreen` bukan screen dinamis** — tidak terikat ke data transaksi manapun (statis, "Rani Putri" / "BCA •••• 4821" hardcoded). Demo script sudah disesuaikan untuk ini (lihat Prioritas 5.3).
5. **`.env.example` sempat regresi** ke versi lama yang menyebut Launchtube — sudah diperbaiki lagi. Kalau suatu saat melihat file itu menyebut Launchtube/self-relay lagi, itu tandanya ke-overwrite oleh commit lama — cek `git log -- backend/.env.example`.

---

## Definisi "selesai"

Development Kirimin bisa dianggap **selesai** (siap demo) ketika:
- [ ] Prioritas 0-4 semua lolos minimal sekali di device fisik Android
- [ ] Dry run demo script (5.3) sudah 3x sesuai checklist, total waktu ≤ 4 menit
- [ ] Video backup (5.4) sudah direkam & tersimpan di 2 tempat
- [ ] Final E2E test 2 device (5.5) lolos tanpa intervensi teknis
- [ ] Minimal 1 anggota tim bisa bawakan demo tanpa melihat catatan

Setelah semua tercentang, update `sprint/sprint-0-foundation.md` s/d `sprint/sprint-4-polish-demo.md` — ganti status `ON GOING`/`TODO` yang relevan jadi `FINISHED`, dan isi baris baru di tiap **Sprint Log** dengan tanggal + hasil verifikasi aktual (bukan asumsi).
