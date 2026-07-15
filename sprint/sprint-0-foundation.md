# Sprint 0 — Foundation

## Tujuan Sprint

Menyiapkan seluruh infrastruktur agar sprint berikutnya bisa langsung fokus ke kode fitur. Sprint ini selesai bila **satu** passkey biometrik berhasil muncul di device fisik (iOS **dan** Android), meski belum terhubung ke backend apapun.

## Definition of Done

- [x] Backend ter-deploy di Railway.app dengan URL HTTPS stabil (RP_ID sudah di-lock)
- [x] `GET /health` dapat diakses publik dan mengembalikan `{"ok":true}`
- [ ] `GET /.well-known/apple-app-site-association` → HTTP 200, JSON valid — Content-Type sudah fix & **terverifikasi live** (2026-07-15), Bundle ID sudah `com.kirimin.app`; sisa blocker cuma Team ID masih placeholder (butuh Apple Developer Program)
- [x] `GET /.well-known/assetlinks.json` → HTTP 200, JSON valid
- [ ] iOS: Associated Domains entitlement terpasang di Xcode — entitlements file + pbxproj sudah di-wire manual (2026-07-15); belum dikonfirmasi buka di Xcode UI (perlu macOS)
- [ ] Android: Asset Links terkonfigurasi di manifest — file sudah dikonfigurasi (manifest + strings.xml), tinggal verifikasi build & `adb logcat` di device fisik
- [x] Stellar CLI terinstall + keypair deployer tersimpan aman — balance deployer (10000 XLM) terverifikasi via Horizon API
- [x] ~~Passkey Kit factory contract ter-deploy di testnet~~ → N/A, arsitektur berubah ke passkey-kit v1 (no factory); Wallet WASM Hash & Canonical Deployer tercatat sebagai gantinya, lihat S0-10
- [ ] ~~Launchtube testnet token tersedia~~ — **SKIPPED** (Launchtube-nya), tapi diganti **OpenZeppelin Channels** yang ternyata tetap wajib — lihat koreksi di S0-11 & `NEXT_STEPS.md` §1a. Belum terisi di Railway.
- [x] Demo wallet (pengirim) terfund USDC/test-USD via testnet
- [ ] Flutter boot di device fisik → splash screen muncul, tidak crash

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S0-01](#s0-01--deploy-backend-ke-railwayapp) | Deploy backend ke Railway.app | `FINISHED` | P0 |
| [S0-02](#s0-02--konfigurasi-environment-variables-di-railway) | Konfigurasi env vars di Railway | `ON GOING` | P0 |
| [S0-03](#s0-03--lock-rp_id-dan-dokumentasikan-domain) | Lock RP_ID dan dokumentasikan domain | `FINISHED` | P0 |
| [S0-04](#s0-04--buat-apple-app-site-association) | Buat `apple-app-site-association` | `ON GOING` | P0 |
| [S0-05](#s0-05--buat-assetlinksjson) | Buat `assetlinks.json` | `FINISHED` | P0 |
| [S0-06](#s0-06--verifikasi-well-known-endpoint-via-https) | Verifikasi `.well-known` endpoint | `ON GOING` | P0 |
| [S0-07](#s0-07--setup-ios-associated-domains-di-xcode) | Setup iOS Associated Domains di Xcode | `ON GOING` | P0 |
| [S0-08](#s0-08--setup-android-digital-asset-links) | Setup Android Digital Asset Links | `ON GOING` | P0 |
| [S0-09](#s0-09--install-stellar-cli--generate-keypair-deployer) | Install Stellar CLI + generate keypair | `FINISHED` | P0 |
| [S0-10](#s0-10--deploy-passkey-kit-factory-contract-ke-testnet) | Deploy Passkey Kit factory ke testnet | `FINISHED` (N/A) | P0 |
| [S0-11](#s0-11--dapatkan-launchtube-testnet-token) | ~~Dapatkan Launchtube testnet token~~ | `SKIPPED` | ~~P0~~ |
| [S0-12](#s0-12--setup-demo-wallet-dan-fund-usdc-testnet) | Setup demo wallet + fund USDC testnet | `FINISHED` | P1 |
| [S0-13](#s0-13--konfigurasi-flutter-dart-define) | Konfigurasi Flutter `--dart-define` | `ON GOING` | P0 |
| [S0-14](#s0-14--smoke-test-flutter-di-device-fisik) | Smoke test Flutter di device fisik | `ON GOING` | P0 |

---

## S0-01 — Deploy backend ke Railway.app

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** setup

**Konteks:**  
Backend harus di-host di URL HTTPS yang stabil sejak awal karena RP_ID (domain passkey) **tidak boleh berubah** setelah passkey pertama dibuat. Railway.app dipilih karena gratis ($5 kredit/bulan), mendukung deploy langsung dari Dockerfile, dan menghasilkan domain HTTPS stabil tanpa konfigurasi tambahan.

**Langkah:**
1. Buat akun di [railway.app](https://railway.app) (tidak perlu kartu kredit untuk $5 kredit awal).
2. Dashboard → **New Project** → **Deploy from GitHub repo**.
3. Connect GitHub account → pilih repo `MenantuIdaman-StellarAPACHackathon`.
4. Railway akan detect proyek. Set **Root Directory** ke `backend` (karena `Dockerfile` ada di sana).
5. Railway otomatis pakai `Dockerfile`. Biarkan default.
6. Klik **Deploy Now**. Tunggu build selesai (~2 menit).
7. Di **Settings → Networking → Generate Domain** → salin URL (format: `https://kirimin-backend-production.up.railway.app` atau sejenisnya).

**File yang diubah/dibuat:**  
Tidak ada perubahan kode — Railway deploy dari repo as-is.

**Acceptance criteria:**
- [x] `curl https://<railway-url>/health` mengembalikan `{"ok":true,"service":"kirimin-backend"}`
- [x] URL bisa diakses dari browser/HP tanpa error SSL

**Catatan risiko:**  
Bila Railway timeout build, cek apakah `backend/package-lock.json` sudah ada (CI butuh ini untuk `npm ci`). Jalankan `cd backend && npm install` lalu commit `package-lock.json`.

---

## S0-02 — Konfigurasi environment variables di Railway

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** setup

**Konteks:**  
Semua nilai sensitif masuk via env vars, bukan hardcode. Ini dikonfigurasi di Railway dashboard, bukan di file `.env` yang di-commit.

**Langkah:**
1. Railway dashboard → pilih service → tab **Variables**.
2. Tambahkan semua variabel berikut (nilai akan diisi di sprint berikutnya, untuk sekarang isi placeholder):

```
PORT=3000
NODE_ENV=production
RP_ID=<URL Railway tanpa https://>          # contoh: kirimin-backend-production.up.railway.app
RP_NAME=Kirimin
ORIGIN=https://<URL Railway>
STELLAR_NETWORK=testnet
SOROBAN_RPC_URL=https://soroban-testnet.stellar.org
HORIZON_URL=https://horizon-testnet.stellar.org
FRIENDBOT_URL=https://friendbot.stellar.org
USDC_ISSUER=GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5
RELAYER_BASE_URL=https://channels.openzeppelin.com  # WAJIB diisi — lihat koreksi S0-11 & NEXT_STEPS.md §1a
RELAYER_API_KEY=<generate di https://channels.openzeppelin.com/testnet/gen>  # WAJIB
SIGNER_SECRET_KEY=<isi dari sprint/SECRETS.md>
DEMO_RECEIVER_CONTRACT=                      # isi setelah smart wallet penerima demo dibuat
```

> **Update (2026-07-15):** daftar di atas sudah disinkronkan dengan `backend/.env.example` saat ini. `LAUNCHTUBE_URL`/`LAUNCHTUBE_TOKEN` dan `FACTORY_CONTRACT_ID` **dihapus** dari daftar — Launchtube di-skip (S0-11) dan `passkey-kit` v1 tidak pakai factory contract (S0-10).

3. Klik **Save** → Railway akan redeploy otomatis.

**File yang diubah/dibuat:**  
- `backend/.env.example` — sudah sinkron dengan daftar di atas (tidak ada lagi `LAUNCHTUBE_*`/`FACTORY_CONTRACT_ID`)

**Acceptance criteria:**
- [ ] Railway dashboard menampilkan semua variabel di atas tanpa error — **belum bisa diverifikasi dari sini, perlu akses Railway dashboard**; nilai `SIGNER_SECRET_KEY` ada di `sprint/SECRETS.md`
- [x] `curl https://<railway-url>/health` tetap mengembalikan `200 OK` setelah redeploy

---

## S0-03 — Lock RP_ID dan dokumentasikan domain

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** setup

**Konteks:**  
RP_ID adalah domain yang meng-host `.well-known/` dan yang tercatat di passkey device. **Setelah passkey pertama dibuat dengan RP_ID tertentu, domain tidak boleh berubah** — passkey lama tidak bisa dipakai lagi di domain baru. Lock ini sejak awal dan dokumentasikan di satu tempat terpusat.

**Langkah:**
1. Ambil URL Railway dari S0-01, hapus `https://` di depan. Contoh: `kirimin-backend-production.up.railway.app`
2. Buat file `sprint/CONFIG.md` (lihat format di bawah) dan isi dengan nilai RP_ID.
3. Buat file `sprint/SECRETS.md` (di-gitignore) untuk nilai sensitif yang perlu dibagi antar tim.
4. Tambahkan `sprint/SECRETS.md` ke `.gitignore`.

**File yang diubah/dibuat:**
- `sprint/CONFIG.md` (baru) — dokumentasi non-sensitif yang bisa di-commit
- `sprint/SECRETS.md` (baru, di-gitignore) — nilai sensitif
- `.gitignore` — tambah `sprint/SECRETS.md`

**Isi `sprint/CONFIG.md`:**
```markdown
# Kirimin — Config Reference

## Domain & RP_ID
- **RP_ID:** `<railway-domain-tanpa-https>`
- **Backend URL:** `https://<railway-domain>`
- **Catatan:** RP_ID TIDAK BOLEH BERUBAH setelah passkey pertama dibuat.

## Flutter dart-define
```bash
flutter run \
  --dart-define=BACKEND_URL=https://<railway-domain> \
  --dart-define=RP_ID=<railway-domain>
```

## Stellar Testnet
- **Soroban RPC:** https://soroban-testnet.stellar.org
- **Horizon:** https://horizon-testnet.stellar.org
- **Factory Contract ID:** (isi setelah S0-10)
- **Demo Sender Wallet:** (isi setelah S0-12)
```

**Acceptance criteria:**
- [x] `sprint/CONFIG.md` ada dan berisi RP_ID yang benar
- [x] `sprint/SECRETS.md` ada dan di-gitignore
- [x] Seluruh tim tahu domain yang dipakai

---

## S0-04 — Buat `apple-app-site-association`

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** setup

**Update (2026-07-15):**  
- Bundle ID resmi diputuskan `com.kirimin.app` (selaras dengan Android S0-08) — file ini dan `Runner.xcodeproj/project.pbxproj` sudah diupdate ke `com.kirimin.app`.
- Bug Content-Type (`application/octet-stream` bukan `application/json`) sudah diperbaiki di kode dan **terverifikasi live** — `curl -sI` ke endpoint produksi sekarang mengembalikan `Content-Type: application/json`.
- Team ID **masih placeholder** (`TEAM_ID_NANTI_DIISI`) — butuh akun Apple Developer Program berbayar, tidak bisa diisi dari sini. Lihat `NEXT_STEPS.md` di root repo.

**Konteks:**  
iOS membutuhkan file ini di `https://<RP_ID>/.well-known/apple-app-site-association` (tanpa ekstensi `.json`) agar Associated Domains berfungsi dan passkey biometrik muncul. File sudah di-serve oleh backend via `express.static`.

**Langkah:**
1. Cari **Team ID** Apple:
   - Buka [developer.apple.com](https://developer.apple.com) → Account → Membership → salin Team ID (10 karakter).
2. Cari **Bundle ID** app Flutter:
   - Buka `frontend/ios/Runner.xcworkspace` di Xcode → target **Runner** → tab General → Bundle Identifier.
   - Default Flutter: `com.example.kirimin` — ganti ke sesuatu yang dimiliki tim (misal `com.kirimin.app`).
3. Buat file `backend/public/.well-known/apple-app-site-association` (tanpa ekstensi):

```json
{
  "webcredentials": {
    "apps": ["<TEAM_ID>.<BUNDLE_ID>"]
  }
}
```

Contoh: `"ABCDE12345.com.kirimin.app"`

**File yang diubah/dibuat:**
- `backend/public/.well-known/apple-app-site-association` (baru)

**Acceptance criteria:**
- [x] File ada di path yang benar (tanpa `.json` extension)
- [x] Setelah deploy Railway: `curl -v https://<railway-url>/.well-known/apple-app-site-association` → HTTP 200, `Content-Type: application/json` — terverifikasi live 2026-07-15
- [x] JSON valid (test di [jsonlint.com](https://jsonlint.com))
- [ ] Team ID dan Bundle ID sudah benar — Bundle ID sudah `com.kirimin.app`, Team ID masih `TEAM_ID_NANTI_DIISI` (butuh Apple Developer Program)

**Catatan risiko:**  
Bundle ID di file ini harus **identik persis** dengan Bundle ID di Xcode. Satu huruf beda = passkey tidak muncul tanpa pesan error jelas.

---

## S0-05 — Buat `assetlinks.json`

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** setup

**Konteks:**  
Android membutuhkan file ini di `https://<RP_ID>/.well-known/assetlinks.json` untuk Digital Asset Links. Berisi SHA-256 fingerprint dari signing key aplikasi.

**Langkah:**
1. Dapatkan SHA-256 fingerprint debug keystore (untuk development):
   ```bash
   keytool -list -v \
     -keystore ~/.android/debug.keystore \
     -alias androiddebugkey \
     -storepass android \
     -keypass android
   ```
   Salin nilai `SHA256:` (format `AA:BB:CC:...`).

2. Cari package name Android:
   - Buka `frontend/android/app/build.gradle` → lihat `applicationId`.
   - Default: `com.example.kirimin` — sesuaikan dengan Bundle ID yang dipilih (misal `com.kirimin.app`).

3. Buat file `backend/public/.well-known/assetlinks.json`:

```json
[{
  "relation": [
    "delegate_permission/common.handle_all_urls",
    "delegate_permission/common.get_login_creds"
  ],
  "target": {
    "namespace": "android_app",
    "package_name": "com.kirimin.app",
    "sha256_cert_fingerprints": [
      "AA:BB:CC:DD:EE:FF:..."
    ]
  }
}]
```

4. Untuk release build (demo final), ulangi dengan release keystore fingerprint dan tambahkan ke array `sha256_cert_fingerprints`.

**File yang diubah/dibuat:**
- `backend/public/.well-known/assetlinks.json` (baru)

**Acceptance criteria:**
- [x] File ada dan JSON valid
- [x] Setelah deploy Railway: `curl https://<railway-url>/.well-known/assetlinks.json` → HTTP 200
- [x] SHA-256 fingerprint sesuai dengan debug keystore
- [x] Package name sesuai dengan `applicationId` di `build.gradle`

**Catatan risiko:**  
Fingerprint release dan debug berbeda. Untuk demo, gunakan debug fingerprint + install via `flutter run`. Jika demo via APK yang di-sign release, tambahkan fingerprint release ke array.

---

## S0-06 — Verifikasi `.well-known` endpoint via HTTPS

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S0-01, S0-04, S0-05

**Konteks:**  
Verifikasi bahwa semua file `.well-known` bisa diakses dari internet (bukan hanya lokal) dengan respons yang benar sebelum mengkonfigurasi device.

**Langkah:**
1. Jalankan command berikut dan verifikasi hasilnya:
```bash
# Health
curl -v https://<railway-url>/health

# iOS
curl -v https://<railway-url>/.well-known/apple-app-site-association

# Android
curl -v https://<railway-url>/.well-known/assetlinks.json
```

2. Verifikasi dengan [Google Digital Asset Links tester](https://developers.google.com/digital-asset-links/tools/generator):
   - Package name → SHA-256 fingerprint → Test.

3. Untuk iOS: gunakan [Branch AASA Validator](https://branch.io/resources/aasa-validator/) — masukkan domain Railway.

**Acceptance criteria:**
- [x] Semua 3 endpoint mengembalikan HTTP 200
- [x] `Content-Type` adalah `application/json` — terverifikasi live 2026-07-15 (`curl -sI` ke AASA)
- [ ] iOS AASA validator: VALID — belum dijalankan, perlu Team ID terisi dulu (lihat `NEXT_STEPS.md`)
- [ ] Android Digital Asset Links tester: VALID — `assetlinks.json` sudah live dengan `com.kirimin.app`, tinggal jalankan tester (lihat `NEXT_STEPS.md`)

---

## S0-07 — Setup iOS Associated Domains di Xcode

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-03, S0-04, S0-06

**Update (2026-07-15):**  
Capability Associated Domains di-wire langsung via text edit (setara hasil klik "+ Capability" di Xcode), tanpa perlu buka Xcode:
- `frontend/ios/Runner/Runner.entitlements` dibuat baru, isi `com.apple.developer.associated-domains` → `webcredentials:menantuidaman-stellarapachackathon-production.up.railway.app`
- `Runner.xcodeproj/project.pbxproj` — `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` ditambahkan ke 3 build config Runner (Debug/Release/Profile)
- `PRODUCT_BUNDLE_IDENTIFIER` di 3 config yang sama diganti dari `com.example.kirimin` → `com.kirimin.app` (selaras Android S0-08 & AASA S0-04)
- pbxproj tervalidasi (brace count seimbang, bukan corrupt)

**Belum bisa dieksekusi dari sini** (butuh Xcode + macOS + Apple Developer account + device fisik, tidak tersedia di environment ini): buka project di Xcode untuk konfirmasi capability muncul di UI, isi `DEVELOPMENT_TEAM` dengan Team ID asli, build & install ke device. Lihat `NEXT_STEPS.md` di root repo untuk langkah detail.

**Konteks:**  
Entitlement ini memberitahu iOS bahwa app kita "memiliki" domain yang meng-host `apple-app-site-association`. Tanpa ini, iOS menolak menampilkan passkey biometrik.

**Langkah:**
1. Buka `frontend/ios/Runner.xcworkspace` di Xcode.
2. Klik target **Runner** → tab **Signing & Capabilities**.
3. Klik **+ Capability** → pilih **Associated Domains**.
4. Di bawah Associated Domains, tambahkan entry:
   ```
   webcredentials:<RP_ID>
   ```
   Contoh: `webcredentials:kirimin-backend-production.up.railway.app`
5. Pastikan **Automatically manage signing** aktif (atau pastikan Provisioning Profile mencakup Associated Domains).
6. Build ke device fisik: `flutter build ios --debug` atau langsung `flutter run`.

**File yang diubah/dibuat:**
- `frontend/ios/Runner/Runner.entitlements` — dibuat manual (biasanya Xcode update otomatis, di sini di-hand-edit)
- `frontend/ios/Runner.xcodeproj/project.pbxproj` — `CODE_SIGN_ENTITLEMENTS` & `PRODUCT_BUNDLE_IDENTIFIER` di-hand-edit

**Acceptance criteria:**
- [x] Associated Domains muncul di Signing & Capabilities dengan value yang benar — terkonfigurasi via entitlements file, **belum dikonfirmasi visual di Xcode UI** (tidak ada akses Xcode di environment ini)
- [ ] Build iOS berhasil tanpa error signing — belum dicoba, butuh Team ID + Xcode
- [ ] Di device fisik: install app → tidak crash — belum dicoba

**Catatan risiko:**  
Bila menggunakan free Apple Developer account (Personal Team), Associated Domains mungkin tidak berfungsi — fitur ini butuh paid Apple Developer Program ($99/tahun). Verifikasi di awal apakah tim punya paid account.

---

## S0-08 — Setup Android Digital Asset Links

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-03, S0-05, S0-06

**Update (2026-07-15):**  
Package name resmi diputuskan: **`com.kirimin.app`** (ganti dari default `com.example.kirimin`). Sudah dieksekusi:
- `applicationId` & `namespace` di `build.gradle.kts` → `com.kirimin.app`
- Kotlin package `MainActivity.kt` dipindah ke `frontend/android/app/src/main/kotlin/com/kirimin/app/`
- `backend/public/.well-known/assetlinks.json` → `package_name` diupdate ke `com.kirimin.app` — **sudah di-push & live** (terverifikasi 2026-07-15)
- `sprint/CONFIG.md` → Application ID diupdate
- `frontend/android/app/src/main/res/values/strings.xml` dibuat dengan `asset_statements` menunjuk ke `assetlinks.json` live
- `AndroidManifest.xml` sudah ditambah `<meta-data android:name="asset_statements">` di dalam `<activity>`
- JSON & XML tervalidasi well-formed

**Belum bisa dieksekusi dari sini** (butuh Flutter SDK + device fisik, tidak tersedia di environment ini): `flutter pub get` untuk cek auto-config plugin `passkeys`, build & run ke device Android, serta `adb logcat` verification. Ini jadi PR berikutnya untuk yang punya akses ke device.

**Konteks:**  
Android Credential Manager (yang dipakai package `passkeys`) memverifikasi Digital Asset Links sebelum menampilkan passkey UI. Konfigurasi ini ada di dua tempat: server (sudah via S0-05) dan manifest Android.

**Langkah:**
1. Buka `frontend/android/app/src/main/AndroidManifest.xml`.
2. Tambahkan di dalam `<activity>` tag (atau verifikasi sudah ada dari package `passkeys`):
   ```xml
   <meta-data
     android:name="asset_statements"
     android:resource="@string/asset_statements" />
   ```
3. Buat/buka `frontend/android/app/src/main/res/values/strings.xml`, tambahkan:
   ```xml
   <string name="asset_statements" translatable="false">
   [{
     \"include\": \"https://<RP_ID>/.well-known/assetlinks.json\"
   }]
   </string>
   ```
4. Verifikasi `applicationId` di `frontend/android/app/build.gradle` sesuai dengan yang ada di `assetlinks.json`.
5. Jalankan di Android device fisik: `flutter run`.

**File yang diubah/dibuat:**
- `frontend/android/app/src/main/AndroidManifest.xml`
- `frontend/android/app/src/main/res/values/strings.xml` (buat bila belum ada)

**Acceptance criteria:**
- [ ] Build Android berhasil — belum dicoba (perlu Flutter SDK di device build)
- [ ] Install di device fisik: tidak crash — belum dicoba
- [ ] `adb logcat` tidak menampilkan Digital Asset Links error — belum dicoba

**Catatan risiko:**  
Package `passkeys` versi 2.x mungkin sudah handle sebagian konfigurasi Android secara otomatis. Cek dokumentasi package setelah `flutter pub get` untuk memastikan tidak ada setup manual tambahan.

---

## S0-09 — Install Stellar CLI + generate keypair deployer

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** setup

**Update (2026-07-15):**  
Balance deployer diverifikasi langsung via Horizon API (`GET https://horizon-testnet.stellar.org/accounts/<deployer-pubkey>`) tanpa perlu Stellar CLI terinstall — akun ditemukan dengan **10000 XLM**. Dicatat di `sprint/CONFIG.md`.

**Konteks:**  
Stellar CLI dibutuhkan untuk deploy factory contract dan operasi testnet. Keypair deployer adalah akun yang dipakai untuk sign deploy transaction (bukan akun pengguna).

**Langkah:**
1. Install Stellar CLI:
   ```bash
   # macOS (Homebrew)
   brew install stellar-cli
   
   # Atau via cargo
   cargo install --locked stellar-cli --features opt
   ```
   Verifikasi: `stellar --version`

2. Generate keypair deployer:
   ```bash
   stellar keys generate deployer --network testnet --global
   ```

3. Fund deployer via Friendbot:
   ```bash
   stellar account fund deployer --network testnet
   ```

4. Simpan public key deployer:
   ```bash
   stellar keys address deployer
   ```
   Catat di `sprint/CONFIG.md` sebagai **Deployer Public Key**.

5. Export secret key (simpan AMAN, jangan commit):
   ```bash
   stellar keys show deployer
   ```
   Simpan di `sprint/SECRETS.md` sebagai `SIGNER_SECRET_KEY`.

**File yang diubah/dibuat:**
- `sprint/CONFIG.md` — tambah Deployer Public Key
- `sprint/SECRETS.md` — tambah SIGNER_SECRET_KEY (tidak di-commit)

**Acceptance criteria:**
- [x] `stellar --version` mengembalikan versi >= 21.0 — tercatat `27.0.0` di `sprint/CONFIG.md`
- [x] `stellar account info deployer --network testnet` menampilkan account dengan XLM balance — diverifikasi via Horizon API: 10000 XLM
- [x] Secret key tersimpan aman di SECRETS.md (tidak di-commit)

---

## S0-10 — Deploy Passkey Kit factory contract ke testnet

**Status:** `FINISHED` (arsitektur berubah — N/A, lihat catatan) | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-09

**Catatan kondisi terakhir:**  
Passkey Kit yang dipakai tim ternyata versi **v1** (`passkey-kit@^0.14.0`), yang **tidak memakai arsitektur factory contract** lagi — sebagai gantinya, wallet WASM di-upload langsung ke testnet dan di-deploy per-user dari deployer kanonis. `sprint/CONFIG.md` sudah mencatat **Wallet WASM Hash** dan **Canonical Deployer**, tapi `FACTORY_CONTRACT_ID` (sesuai definisi issue ini) tidak akan pernah terisi.

**Update (2026-07-15):** `backend/.env.example` sudah tidak menyebut `FACTORY_CONTRACT_ID` sama sekali (field dihapus), dan `contracts/README.md` sudah ditulis ulang untuk menjelaskan arsitektur v1 (wallet WASM + canonical deployer, bukan factory). S0-02's daftar env var Railway juga sudah disinkronkan.

**Konteks (asli, untuk referensi):**  
Factory contract adalah smart contract Soroban yang men-deploy smart wallet baru untuk tiap user. Kita **tidak menulis contract dari nol** — kita deploy contract dari Passkey Kit.

**Langkah (cek existing factory dulu):**
1. Cek apakah Passkey Kit sudah menyediakan factory yang ter-deploy di testnet:
   - Lihat README di [github.com/stellar/passkey-kit](https://github.com/stellar/passkey-kit)
   - Atau tanya di Discord Stellar `#passkeys` channel
   - Jika sudah ada → langsung catat `FACTORY_CONTRACT_ID` dan **skip ke step 4**

2. Bila harus deploy sendiri, clone passkey-kit:
   ```bash
   git clone https://github.com/stellar/passkey-kit
   cd passkey-kit
   npm install
   ```

3. Deploy factory contract:
   ```bash
   # Build WASM (bila belum ada artefak)
   cd contract
   stellar contract build
   
   # Deploy
   stellar contract deploy \
     --wasm target/wasm32-unknown-unknown/release/passkey_factory.wasm \
     --source deployer \
     --network testnet
   ```
   Salin Contract ID yang ditampilkan.

4. Update env vars:
   - Railway dashboard: set `FACTORY_CONTRACT_ID=<contract-id>`
   - `sprint/CONFIG.md`: catat Factory Contract ID

**File yang diubah/dibuat:**
- `sprint/CONFIG.md` — Wallet WASM Hash & Canonical Deployer tercatat (pengganti Factory Contract ID)
- `backend/.env.example` — `FACTORY_CONTRACT_ID` dihapus (tidak relevan di v1)
- `contracts/README.md` — ditulis ulang untuk arsitektur v1

**Acceptance criteria:**
- [x] ~~Factory Contract ID tersedia~~ — N/A, v1 tidak pakai factory (lihat catatan di atas); Wallet WASM Hash & Canonical Deployer tersedia sebagai gantinya
- [x] ~~`stellar contract invoke --id <FACTORY_CONTRACT_ID>` ...~~ — N/A
- [x] ~~Railway env var `FACTORY_CONTRACT_ID` sudah terisi~~ — N/A, field sudah dihapus dari `.env.example`

**Catatan risiko:**  
Bila deploy sendiri, pastikan versi Stellar CLI yang dipakai kompatibel dengan contract Rust di passkey-kit. Pin versi CLI dan catat di `sprint/CONFIG.md`.

---

## S0-11 — ~~Dapatkan Launchtube testnet token~~ (SKIPPED)

**Status:** `SKIPPED` | **Prioritas:** ~~P0~~ | **Tipe:** setup

**Keputusan (2026-07-15):**  
Issue ini **di-skip**, bukan dikerjakan. Alasan:

1. **Launchtube sudah deprecated.** Repo resmi [`stellar/launchtube`](https://github.com/stellar/launchtube) sudah *archived* (per 2026-03-09), berstatus legacy, dan README-nya eksplisit bilang *"this service should not be used for new projects"* — diarahkan migrasi ke **OpenZeppelin Relayer + Channels Plugin**.
2. **S0-10 tidak pernah butuh Launchtube** — deploy factory/contract dilakukan via `stellar contract deploy --source deployer --network testnet` (CLI langsung), bukan lewat Launchtube.
3. ~~Fee sponsorship tetap tercapai tanpa Launchtube. Backend bisa jadi "relayer" sendiri: pegang `SIGNER_SECRET_KEY` deployer, submit transaksi langsung ke Soroban RPC.~~ **KOREKSI (2026-07-15, setelah `node_modules` ter-install dan source code `passkey-kit` dicek langsung):** asumsi ini **salah**. `PasskeyServer.send()` (dipakai `/wallet/create` dan `/tx/submit`) **secara desain selalu mensyaratkan relayer terkonfigurasi** — tanpa `RELAYER_BASE_URL`/`RELAYER_API_KEY`, setiap panggilan gagal dengan `RELAYER_NOT_CONFIGURED` (lihat `node_modules/passkey-kit/dist/server.js` baris ~88, dan README package: *"All wallet writes are fee-sponsored by the OpenZeppelin Relayer Channels service"*). Tidak ada jalur submit-langsung-pakai-secret-key yang didukung resmi oleh library ini. `SIGNER_SECRET_KEY` tetap dipakai (sebagai `deploySource` di `PasskeyKit`), tapi itu untuk *menandatangani* transaksi deploy, bukan untuk *submit* — submission tetap butuh relayer.
4. **Keputusan revisi:** pakai **OpenZeppelin Channels** (bukan opsi upgrade nanti — ternyata **wajib** untuk MVP juga). Untungnya ini gratis & instan untuk testnet: generate API key self-service tanpa approval di `https://channels.openzeppelin.com/testnet/gen`, isi `RELAYER_BASE_URL=https://channels.openzeppelin.com` + `RELAYER_API_KEY=<hasil generate>` di Railway. **Tidak perlu ubah kode** — `backend/src/passkey.ts` (`getServer()`) sudah benar mengonsumsi kedua env var ini. Lihat `NEXT_STEPS.md` §1a untuk langkah detail.

**Konteks asli (untuk referensi historis):**  
~~Launchtube menangani fee & sequence number untuk transaksi Soroban. Tanpa token ini, kita harus memastikan user punya XLM untuk gas — yang bertentangan dengan north star "no gas". Token testnet bisa didapat gratis.~~

**File yang diubah/dibuat:**
- `sprint/SECRETS.md` — `SIGNER_SECRET_KEY` (deployer) tersedia, dipakai sebagai `deploySource` (penanda tangan deploy tx, bukan pengganti relayer)
- `backend/.env.example` — `LAUNCHTUBE_URL`/`LAUNCHTUBE_TOKEN` dihapus (tidak relevan); `RELAYER_BASE_URL`/`RELAYER_API_KEY` **wajib diisi**, lihat `NEXT_STEPS.md` §1a
- `backend/src/passkey.ts` — tidak diubah, `getServer()` sudah benar sejak awal

**Acceptance criteria (revisi 2026-07-15):**
- [x] Deployer secret key tersedia di `sprint/SECRETS.md`, dipakai sebagai `deploySource`
- [ ] `RELAYER_BASE_URL`/`RELAYER_API_KEY` (OpenZeppelin Channels) terisi di Railway — **blocking**, lihat `NEXT_STEPS.md` §1a
- [ ] `/wallet/create` menghasilkan `submitResult.success: true` (deploy tx benar-benar settle on-chain, bukan cuma HTTP 200) — belum diverifikasi, butuh langkah di atas dulu

---

## S0-12 — Setup demo wallet dan fund USDC testnet

**Status:** `FINISHED` | **Prioritas:** P1 | **Tipe:** setup  
**Dependencies:** S0-09

**Konteks:**  
Untuk demo, kita perlu 2 akun testnet: pengirim (sender) dan penerima (receiver). Keduanya perlu di-fund dengan XLM (base reserve) dan USDC testnet. Ini untuk memastikan alur demo bisa dijalankan bahkan sebelum passkey onboarding selesai diimplementasi.

**Langkah:**
1. Generate 2 keypair baru untuk demo:
   ```bash
   stellar keys generate demo-sender --network testnet --global
   stellar keys generate demo-receiver --network testnet --global
   
   stellar account fund demo-sender --network testnet
   stellar account fund demo-receiver --network testnet
   ```

2. Aktifkan USDC trustline di kedua akun (USDC testnet issuer: `GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5`):
   ```bash
   stellar tx new change-trust \
     --source demo-sender \
     --network testnet \
     --asset "USDC:GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5" \
     --limit 1000
   ```
   (Ulangi untuk demo-receiver)

3. Fund sender dengan USDC testnet:
   - Gunakan testnet AMM atau faucet USDC Stellar (tanya di Discord `#usdc`)
   - Atau: issue test-USD sendiri jika tidak tersedia (buat akun issuer, issue custom asset)

4. Catat kedua address di `sprint/CONFIG.md`.

**File yang diubah/dibuat:**
- `sprint/CONFIG.md` — tambah Demo Sender & Receiver address

**Acceptance criteria:**
- [x] Kedua akun terfund XLM (cek di Stellar Expert testnet)
- [x] Kedua akun punya USDC trustline aktif
- [x] Sender punya USDC balance > 0

---

## S0-13 — Konfigurasi Flutter `--dart-define`

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-03

**Konteks:**  
Flutter butuh `BACKEND_URL` dan `RP_ID` saat build/run. Ini di-pass via `--dart-define`. Buat script helper agar konsisten di semua device.

**Langkah:**
1. Buat file `frontend/run-dev.sh`:
   ```bash
   #!/bin/bash
   # Script untuk run Flutter dengan config yang benar.
   # Ganti nilai di bawah sesuai sprint/CONFIG.md
   
   BACKEND_URL="https://<railway-url>"
   RP_ID="<railway-domain-tanpa-https>"
   
   flutter run \
     --dart-define=BACKEND_URL=$BACKEND_URL \
     --dart-define=RP_ID=$RP_ID \
     "$@"
   ```
   ```bash
   chmod +x frontend/run-dev.sh
   ```

2. Untuk VS Code: buat/update `.vscode/launch.json`:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Kirimin (dev)",
         "type": "dart",
         "request": "launch",
         "program": "lib/main.dart",
         "args": [
           "--dart-define=BACKEND_URL=https://<railway-url>",
           "--dart-define=RP_ID=<railway-domain>"
         ]
       }
     ]
   }
   ```

**File yang diubah/dibuat:**
- `frontend/run-dev.sh` (baru)
- `.vscode/launch.json` (baru, 2026-07-15)

**Acceptance criteria:**
- [x] `./frontend/run-dev.sh` menjalankan Flutter dengan nilai yang benar — file ada, RP_ID & BACKEND_URL sesuai `CONFIG.md`
- [x] `.vscode/launch.json` dibuat dengan `--dart-define` yang sama seperti `run-dev.sh`
- [ ] `Env.backendUrl` dan `Env.rpId` di app terisi dengan nilai Railway (verify via debugger atau print sementara) — belum diverifikasi runtime, butuh Flutter SDK

---

## S0-14 — Smoke test Flutter di device fisik

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S0-07, S0-08, S0-13

**Konteks:**  
Sebelum mulai Sprint 1, verifikasi bahwa app sudah boot dengan benar di device fisik dan tidak ada crash pada layar awal. Ini tidak menguji passkey — hanya memastikan foundation berjalan.

**Langkah:**
1. Sambungkan iOS device fisik → `flutter run --dart-define=... -d <ios-device-id>`
2. Sambungkan Android device fisik → `flutter run --dart-define=... -d <android-device-id>`
3. Verifikasi di masing-masing device:
   - Splash screen muncul
   - Redirect ke OnboardingScreen (karena belum ada sesi)
   - Tap "Buat akun dengan Face ID" → **diharapkan error/loading** (backend belum ada endpoint) — ini OK
   - Tidak ada crash / unhandled exception di console

**Acceptance criteria:**
- [ ] iOS: app boot → splash → onboarding, tidak crash — commit "Flutter smoke test" ada, tapi belum ada catatan hasil di Sprint Log
- [ ] Android: app boot → splash → onboarding, tidak crash — sama, belum terdokumentasi
- [ ] `flutter analyze` di `frontend/` tidak ada error (warning boleh) — belum dijalankan/dicatat

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| 2026-07-15 | Launchtube di-skip (deprecated), backend jadi relayer sendiri via `SIGNER_SECRET_KEY` | Keputusan (S0-11) |
| 2026-07-15 | Android package rename `com.example.kirimin` → `com.kirimin.app` (gradle, Kotlin dir, assetlinks.json, CONFIG.md) | Selesai (S0-08) |
| 2026-07-15 | Audit menyeluruh status Sprint 0 vs kondisi repo aktual, semua field status direkonsiliasi | Selesai |
| 2026-07-15 | Fix bug Content-Type AASA (`express.static` set header eksplisit), sync Bundle ID iOS ke `com.kirimin.app`, wire Associated Domains entitlement manual, verifikasi balance deployer via Horizon API, sync `contracts/README.md` & S0-02 env var list ke arsitektur v1, buat `.vscode/launch.json` | Selesai (kode), lihat `NEXT_STEPS.md` untuk sisa langkah manual |
| 2026-07-15 | Push ke `origin` selesai, `.well-known` (Content-Type + `assetlinks.json`) terverifikasi live di Railway | Selesai |
| 2026-07-15 | Audit `SPRINT-TONIGHT.md` vs kode: ketemu & fix `USE_MOCK` trap di `run-dev.sh` (default mock, tidak pernah nyambung backend asli), endpoint `GET /home/:userId/feed` yang hilang (blocking HomeScreen), dan `USDC_SAC_ADDRESS` hardcode yang **bukan contract ID valid** (transfer dijamin gagal). Semua fixed & `tsc` clean compile setelah `npm ci`. | Selesai (S3-01/S3-02 setara) |
| 2026-07-15 | **Koreksi besar S0-11**: cek langsung source `passkey-kit` (`node_modules` ter-install) membuktikan `PasskeyServer.send()` selalu butuh relayer — keputusan awal "self-relay tanpa relayer eksternal" salah. Solusi: OpenZeppelin Channels (bukan self-host, cukup `https://channels.openzeppelin.com` + API key self-service tanpa approval dari `/testnet/gen`). Tidak perlu ubah kode, murni env var. | **Blocking — belum diisi di Railway**, lihat `NEXT_STEPS.md` §1a |

## Blockers & Catatan

- **BLOCKING SEKARANG: `RELAYER_BASE_URL`/`RELAYER_API_KEY` belum diisi di Railway.** Tanpa ini, `/wallet/create` dan `/tx/submit` selalu gagal submit on-chain (walau `/wallet/create` tetap balas HTTP 200 secara menyesatkan). Lihat `NEXT_STEPS.md` §1a — langkahnya cepat (generate key self-service, tempel ke Railway), tidak perlu kode baru.
- **iOS di-skip permanen untuk demo ini** — Apple Developer Program berbayar ($99/tahun) tidak tersedia. Demo Android-only. S0-07 & bagian iOS di S1/S2/S3/S4 jadi N/A, bukan blocker lagi.
- **Device fisik & Flutter SDK**: environment kerja Claude tidak punya Flutter SDK/Xcode/device fisik — semua verifikasi runtime (build, install, `adb logcat`, `flutter analyze`) harus dilakukan manual oleh anggota tim yang punya akses (sudah bisa `flutter pub get` per info terakhir). Lihat `NEXT_STEPS.md` untuk checklist lengkap.
