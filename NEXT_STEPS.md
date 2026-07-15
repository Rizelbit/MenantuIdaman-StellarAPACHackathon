# Sprint 0 — Langkah Manual yang Tersisa

Dokumen ini berisi **semua yang tidak bisa dikerjakan otomatis** dari environment coding — karena butuh Railway dashboard, akun Apple Developer, Xcode di macOS, atau device fisik. Semua yang bisa dikerjakan dari kode sudah selesai (lihat `sprint/sprint-0-foundation.md` untuk detail lengkap per issue).

Ikuti urutan di bawah — tiap langkah punya dependency ke langkah sebelumnya.

> **Update (2026-07-15):** Dua bug tambahan ditemukan & diperbaiki saat audit `SPRINT-TONIGHT.md` vs kode aktual:
> 1. `frontend/lib/app/env.dart` punya flag `USE_MOCK` default `true` — tanpa `--dart-define=USE_MOCK=false`, app SELALU pakai data mock, tidak pernah menyentuh backend asli. `frontend/run-dev.sh` sekarang sudah otomatis pass flag ini.
> 2. `HomeScreen` butuh `GET /home/:userId/feed` yang sebelumnya **tidak ada** di backend (padahal `docs/frontend/backend_handoff.md` bilang cuma butuh 5 endpoint) — tanpa ini, app **stuck di HomeScreen dengan tombol retry setelah onboarding berhasil**, tidak bisa lanjut ke Send. Sudah ditambahkan sebagai stub minimal di `backend/src/index.ts`.
>
> Detail lengkap ada di `SPRINT-TONIGHT.md`.

---

## 0. Push & deploy (WAJIB PALING AWAL)

Semua fix di bawah ini ada di commit lokal, **belum live** di Railway:
- Fix Content-Type `apple-app-site-association` (`application/octet-stream` → `application/json`)
- `assetlinks.json` dengan package name baru `com.kirimin.app`

```bash
git push origin main
```

Railway auto-deploy dari `main` (asumsi sudah dikonfigurasi begitu di S0-01). Tunggu ~1-2 menit, lalu verifikasi:

```bash
curl -sI https://menantuidaman-stellarapachackathon-production.up.railway.app/.well-known/apple-app-site-association
# Harus: HTTP 200, content-type: application/json (versi HTTP/1.1 vs HTTP/2 tidak masalah, itu cuma protokol edge server Railway)

curl -s https://menantuidaman-stellarapachackathon-production.up.railway.app/.well-known/assetlinks.json
# Harus mengandung "package_name": "com.kirimin.app"
```

Kalau `Content-Type` masih salah setelah deploy, cek Railway build log — kemungkinan build gagal atau masih pakai image lama.

**Menyelesaikan:** S0-04 (Content-Type check), S0-06 (Content-Type check), S0-08 (assetlinks.json live).

---

## 1. Railway dashboard — isi environment variables

Buka [railway.app](https://railway.app) dashboard → project → service → tab **Variables**. Isi/verifikasi (nilai lihat `sprint/CONFIG.md` untuk yang non-sensitif, `sprint/SECRETS.md` untuk yang sensitif):

```
PORT=3000
NODE_ENV=production
RP_ID=menantuidaman-stellarapachackathon-production.up.railway.app
RP_NAME=Kirimin
ORIGIN=https://menantuidaman-stellarapachackathon-production.up.railway.app
STELLAR_NETWORK=testnet
SOROBAN_RPC_URL=https://soroban-testnet.stellar.org
HORIZON_URL=https://horizon-testnet.stellar.org
FRIENDBOT_URL=https://friendbot.stellar.org
USDC_ISSUER=GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5
SIGNER_SECRET_KEY=<dari sprint/SECRETS.md>
RELAYER_BASE_URL=
RELAYER_API_KEY=
DEMO_RECEIVER_CONTRACT=
```

Catatan: `LAUNCHTUBE_URL`, `LAUNCHTUBE_TOKEN`, dan `FACTORY_CONTRACT_ID` **tidak perlu diisi** — sudah dihapus dari `.env.example` karena tidak relevan (lihat S0-11 dan S0-10 di sprint doc).

Setelah save, Railway redeploy otomatis. Verifikasi `/health` masih 200.

**Menyelesaikan:** S0-02.

---

## 2. Apple Developer Program (blocker biaya)

S0-07 (iOS Associated Domains) butuh **Team ID** asli. Free/Personal Team Apple ID kemungkinan besar **tidak mendukung** Associated Domains capability.

1. Cek apakah tim sudah punya akun Apple Developer Program berbayar ($99/tahun). Kalau belum, ini keputusan bisnis (bayar atau skip iOS untuk demo).
2. Kalau sudah punya: buka [developer.apple.com](https://developer.apple.com) → Account → Membership → salin **Team ID** (10 karakter).
3. Update dua file dengan Team ID asli:
   - `backend/public/.well-known/apple-app-site-association` — ganti `TEAM_ID_NANTI_DIISI` jadi Team ID asli, contoh: `"ABCDE12345.com.kirimin.app"`
   - `frontend/ios/Runner.xcodeproj/project.pbxproj` — tambahkan `DEVELOPMENT_TEAM = <TEAM_ID>;` di 3 build config Runner (Debug/Release/Profile), sejajar dengan `CODE_SIGN_ENTITLEMENTS` yang sudah ada di baris yang sama.
4. Commit & push (langkah 0 lagi) supaya AASA live dengan Team ID benar.

**Kalau tim memutuskan skip iOS untuk demo:** cukup demo di Android saja, dan catat itu di `sprint/sprint-0-foundation.md` § Blockers.

**Menyelesaikan:** sisa S0-04 (Team ID), prasyarat S0-07 build.

---

## 3. Buka project di Xcode (butuh macOS)

Setelah Team ID terisi (langkah 2):

1. Buka `frontend/ios/Runner.xcworkspace` (bukan `.xcodeproj`) di Xcode.
2. Klik target **Runner** → tab **Signing & Capabilities**.
3. Verifikasi **Associated Domains** sudah muncul dengan value `webcredentials:menantuidaman-stellarapachackathon-production.up.railway.app` (harusnya sudah otomatis terbaca dari `Runner.entitlements` yang sudah dibuat).
4. Pastikan **Automatically manage signing** aktif dan Team sudah terpilih (dari langkah 2).
5. Sambungkan iOS device fisik → **Run** (▶) atau:
   ```bash
   cd frontend
   ./run-dev.sh -d <ios-device-id>
   ```
6. Verifikasi di device: app boot, tidak crash, splash → onboarding.

**Menyelesaikan:** S0-07 acceptance criteria, bagian iOS dari S0-14.

---

## 4. Android: build & verifikasi di device fisik

Butuh Flutter SDK terinstall + Android device fisik (atau emulator dengan Google Play Services, karena Credential Manager/passkey butuh itu).

```bash
cd frontend
flutter pub get
```

Cek output/dokumentasi package `passkeys` (versi `^2.4.0`) — pastikan tidak ada langkah manual tambahan untuk Android yang belum dilakukan (kemungkinan sudah cukup dengan `AndroidManifest.xml` + `strings.xml` yang sudah dikonfigurasi).

```bash
./run-dev.sh -d <android-device-id>
```

Di device, jalankan flow "Buat akun dengan Face ID/sidik jari" (walau backend belum implementasi penuh, minimal Digital Asset Links tidak boleh error). Pantau log:

```bash
adb logcat | grep -iE "asset|credential|fido"
```

Tidak boleh ada error terkait Digital Asset Links / domain verification.

**Untuk test flow kirim uang (bukan cuma onboarding):** backend butuh 2 wallet — pengirim dan penerima. `POST /tx/build` cari penerima dari user lain yang sudah terdaftar di memory store, atau fallback ke env `DEMO_RECEIVER_CONTRACT` (lihat `backend/src/index.ts` `/tx/build`). Kalau cuma test dengan 1 device/1 akun, isi `DEMO_RECEIVER_CONTRACT` di Railway dengan contract address wallet demo (lihat `sprint/CONFIG.md` § Stellar Testnet — "Demo Receiver Contract Address"). Kalau belum ada, kirim akan gagal dengan error "Penerima tidak ditemukan".

Verifikasi eksternal (setelah langkah 0 — assetlinks.json harus sudah live):
- [Google Digital Asset Links tester](https://developers.google.com/digital-asset-links/tools/generator) — masukkan package `com.kirimin.app` dan SHA-256 `54:4E:87:DD:1E:1C:29:A5:D1:A0:2F:65:28:AF:91:67:AC:40:D0:E1:CC:35:61:18:8C:55:9A:16:BA:B4:12:D3` (dari `sprint/CONFIG.md`).
- [Branch AASA Validator](https://branch.io/resources/aasa-validator/) untuk domain Railway (setelah Team ID terisi, langkah 2).

**Menyelesaikan:** S0-08 acceptance criteria, bagian Android dari S0-14.

---

## 5. `flutter analyze`

```bash
cd frontend
flutter analyze
```

Tidak boleh ada **error** (warning boleh). Catat hasilnya.

**Menyelesaikan:** sisa acceptance criteria S0-14.

---

## 6. Update dokumentasi setelah semua di atas selesai

Setelah langkah 1-5 selesai dan lolos, update `sprint/sprint-0-foundation.md`:
- Checklist Definition of Done di bagian atas — centang yang sudah terverifikasi.
- Status tiap issue (S0-02, S0-04, S0-06, S0-07, S0-08, S0-13, S0-14) dari `ON GOING` → `FINISHED`.
- Tambah baris baru di tabel **Sprint Log** dengan tanggal & hasil verifikasi aktual (bukan asumsi).
- Kalau ada blocker baru yang ditemukan (misal Team ID free tier ternyata tidak jalan), catat di **Blockers & Catatan**.

Sprint 0 baru benar-benar selesai (`DoD` semua tercentang) setelah item terakhir ini — passkey biometrik biasa muncul di device fisik iOS **dan** Android.
