# Sprint 0 — Foundation

## Tujuan Sprint

Menyiapkan seluruh infrastruktur agar sprint berikutnya bisa langsung fokus ke kode fitur. Sprint ini selesai bila **satu** passkey biometrik berhasil muncul di device fisik (iOS **dan** Android), meski belum terhubung ke backend apapun.

## Definition of Done

- [ ] Backend ter-deploy di Railway.app dengan URL HTTPS stabil (RP_ID sudah di-lock)
- [ ] `GET /health` dapat diakses publik dan mengembalikan `{"ok":true}`
- [ ] `GET /.well-known/apple-app-site-association` → HTTP 200, JSON valid
- [ ] `GET /.well-known/assetlinks.json` → HTTP 200, JSON valid
- [ ] iOS: Associated Domains entitlement terpasang di Xcode
- [ ] Android: Asset Links terkonfigurasi di manifest
- [ ] Stellar CLI terinstall + keypair deployer tersimpan aman
- [ ] Passkey Kit factory contract ter-deploy di testnet → `FACTORY_CONTRACT_ID` tercatat
- [ ] Launchtube testnet token tersedia → `LAUNCHTUBE_TOKEN` tercatat
- [ ] Demo wallet (pengirim) terfund USDC/test-USD via testnet
- [ ] Flutter boot di device fisik → splash screen muncul, tidak crash

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S0-01](#s0-01--deploy-backend-ke-railwayapp) | Deploy backend ke Railway.app | `TODO` | P0 |
| [S0-02](#s0-02--konfigurasi-environment-variables-di-railway) | Konfigurasi env vars di Railway | `TODO` | P0 |
| [S0-03](#s0-03--lock-rp_id-dan-dokumentasikan-domain) | Lock RP_ID dan dokumentasikan domain | `TODO` | P0 |
| [S0-04](#s0-04--buat-apple-app-site-association) | Buat `apple-app-site-association` | `TODO` | P0 |
| [S0-05](#s0-05--buat-assetlinksjson) | Buat `assetlinks.json` | `TODO` | P0 |
| [S0-06](#s0-06--verifikasi-well-known-endpoint-via-https) | Verifikasi `.well-known` endpoint | `TODO` | P0 |
| [S0-07](#s0-07--setup-ios-associated-domains-di-xcode) | Setup iOS Associated Domains di Xcode | `TODO` | P0 |
| [S0-08](#s0-08--setup-android-digital-asset-links) | Setup Android Digital Asset Links | `TODO` | P0 |
| [S0-09](#s0-09--install-stellar-cli--generate-keypair-deployer) | Install Stellar CLI + generate keypair | `TODO` | P0 |
| [S0-10](#s0-10--deploy-passkey-kit-factory-contract-ke-testnet) | Deploy Passkey Kit factory ke testnet | `TODO` | P0 |
| [S0-11](#s0-11--dapatkan-launchtube-testnet-token) | Dapatkan Launchtube testnet token | `TODO` | P0 |
| [S0-12](#s0-12--setup-demo-wallet-dan-fund-usdc-testnet) | Setup demo wallet + fund USDC testnet | `TODO` | P1 |
| [S0-13](#s0-13--konfigurasi-flutter-dart-define) | Konfigurasi Flutter `--dart-define` | `TODO` | P0 |
| [S0-14](#s0-14--smoke-test-flutter-di-device-fisik) | Smoke test Flutter di device fisik | `TODO` | P0 |

---

## S0-01 — Deploy backend ke Railway.app

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
- [ ] `curl https://<railway-url>/health` mengembalikan `{"ok":true,"service":"kirimin-backend"}`
- [ ] URL bisa diakses dari browser/HP tanpa error SSL

**Catatan risiko:**  
Bila Railway timeout build, cek apakah `backend/package-lock.json` sudah ada (CI butuh ini untuk `npm ci`). Jalankan `cd backend && npm install` lalu commit `package-lock.json`.

---

## S0-02 — Konfigurasi environment variables di Railway

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
LAUNCHTUBE_URL=https://launchtube.xyz
LAUNCHTUBE_TOKEN=PLACEHOLDER
FACTORY_CONTRACT_ID=PLACEHOLDER
SIGNER_SECRET_KEY=PLACEHOLDER
```

3. Klik **Save** → Railway akan redeploy otomatis.

**File yang diubah/dibuat:**  
- `backend/.env.example` — update jika ada field baru yang perlu didokumentasikan

**Acceptance criteria:**
- [ ] Railway dashboard menampilkan semua variabel di atas tanpa error
- [ ] `curl https://<railway-url>/health` tetap mengembalikan `200 OK` setelah redeploy

---

## S0-03 — Lock RP_ID dan dokumentasikan domain

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
- [ ] `sprint/CONFIG.md` ada dan berisi RP_ID yang benar
- [ ] `sprint/SECRETS.md` ada dan di-gitignore
- [ ] Seluruh tim tahu domain yang dipakai

---

## S0-04 — Buat `apple-app-site-association`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
- [ ] File ada di path yang benar (tanpa `.json` extension)
- [ ] Setelah deploy Railway: `curl -v https://<railway-url>/.well-known/apple-app-site-association` → HTTP 200, `Content-Type: application/json`
- [ ] JSON valid (test di [jsonlint.com](https://jsonlint.com))
- [ ] Team ID dan Bundle ID sudah benar

**Catatan risiko:**  
Bundle ID di file ini harus **identik persis** dengan Bundle ID di Xcode. Satu huruf beda = passkey tidak muncul tanpa pesan error jelas.

---

## S0-05 — Buat `assetlinks.json`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
- [ ] File ada dan JSON valid
- [ ] Setelah deploy Railway: `curl https://<railway-url>/.well-known/assetlinks.json` → HTTP 200
- [ ] SHA-256 fingerprint sesuai dengan debug keystore
- [ ] Package name sesuai dengan `applicationId` di `build.gradle`

**Catatan risiko:**  
Fingerprint release dan debug berbeda. Untuk demo, gunakan debug fingerprint + install via `flutter run`. Jika demo via APK yang di-sign release, tambahkan fingerprint release ke array.

---

## S0-06 — Verifikasi `.well-known` endpoint via HTTPS

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore  
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
- [ ] Semua 3 endpoint mengembalikan HTTP 200
- [ ] `Content-Type` adalah `application/json`
- [ ] iOS AASA validator: VALID
- [ ] Android Digital Asset Links tester: VALID

---

## S0-07 — Setup iOS Associated Domains di Xcode

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-03, S0-04, S0-06

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
- `frontend/ios/Runner/Runner.entitlements` — Xcode update otomatis
- `frontend/ios/Runner.xcworkspace/...` — Xcode update otomatis

**Acceptance criteria:**
- [ ] Associated Domains muncul di Signing & Capabilities dengan value yang benar
- [ ] Build iOS berhasil tanpa error signing
- [ ] Di device fisik: install app → tidak crash

**Catatan risiko:**  
Bila menggunakan free Apple Developer account (Personal Team), Associated Domains mungkin tidak berfungsi — fitur ini butuh paid Apple Developer Program ($99/tahun). Verifikasi di awal apakah tim punya paid account.

---

## S0-08 — Setup Android Digital Asset Links

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-03, S0-05, S0-06

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
- [ ] Build Android berhasil
- [ ] Install di device fisik: tidak crash
- [ ] `adb logcat` tidak menampilkan Digital Asset Links error

**Catatan risiko:**  
Package `passkeys` versi 2.x mungkin sudah handle sebagian konfigurasi Android secara otomatis. Cek dokumentasi package setelah `flutter pub get` untuk memastikan tidak ada setup manual tambahan.

---

## S0-09 — Install Stellar CLI + generate keypair deployer

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

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
- [ ] `stellar --version` mengembalikan versi >= 21.0
- [ ] `stellar account info deployer --network testnet` menampilkan account dengan XLM balance
- [ ] Secret key tersimpan aman di SECRETS.md (tidak di-commit)

---

## S0-10 — Deploy Passkey Kit factory contract ke testnet

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup  
**Dependencies:** S0-09

**Konteks:**  
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
- `sprint/CONFIG.md` — tambah Factory Contract ID
- `backend/.env.example` — pastikan `FACTORY_CONTRACT_ID` ada sebagai field

**Acceptance criteria:**
- [ ] Factory Contract ID tersedia (dari existing deploy atau deploy sendiri)
- [ ] `stellar contract invoke --id <FACTORY_CONTRACT_ID> --network testnet -- --help` tidak error
- [ ] Railway env var `FACTORY_CONTRACT_ID` sudah terisi

**Catatan risiko:**  
Bila deploy sendiri, pastikan versi Stellar CLI yang dipakai kompatibel dengan contract Rust di passkey-kit. Pin versi CLI dan catat di `sprint/CONFIG.md`.

---

## S0-11 — Dapatkan Launchtube testnet token

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup

**Konteks:**  
Launchtube menangani fee & sequence number untuk transaksi Soroban. Tanpa token ini, kita harus memastikan user punya XLM untuk gas — yang bertentangan dengan north star "no gas". Token testnet bisa didapat gratis.

**Langkah:**
1. Join Discord Stellar: [discord.gg/stellar](https://discord.gg/stellar)
2. Pergi ke channel `#launchtube`
3. Request testnet token (biasanya self-service via bot atau tanya di channel)
4. Alternatif: cek [launchtube.xyz](https://launchtube.xyz) untuk self-service testnet token
5. Setelah dapat token:
   - Railway dashboard: set `LAUNCHTUBE_TOKEN=<token>`
   - `LAUNCHTUBE_URL=https://launchtube.xyz` (atau URL yang diberikan)
   - `sprint/SECRETS.md`: simpan token

**File yang diubah/dibuat:**
- `sprint/SECRETS.md` — tambah LAUNCHTUBE_TOKEN

**Acceptance criteria:**
- [ ] Launchtube token tersedia
- [ ] Railway env var `LAUNCHTUBE_TOKEN` dan `LAUNCHTUBE_URL` sudah terisi
- [ ] Token di-test: bisa submit 1 dummy tx ke testnet via Launchtube (boleh gagal karena payload — yang penting tidak auth error)

---

## S0-12 — Setup demo wallet dan fund USDC testnet

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** setup  
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
- [ ] Kedua akun terfund XLM (cek di Stellar Expert testnet)
- [ ] Kedua akun punya USDC trustline aktif
- [ ] Sender punya USDC balance > 0

---

## S0-13 — Konfigurasi Flutter `--dart-define`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** setup  
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
- `.vscode/launch.json` (baru atau update)

**Acceptance criteria:**
- [ ] `./frontend/run-dev.sh` menjalankan Flutter dengan nilai yang benar
- [ ] `Env.backendUrl` dan `Env.rpId` di app terisi dengan nilai Railway (verify via debugger atau print sementara)

---

## S0-14 — Smoke test Flutter di device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore  
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
- [ ] iOS: app boot → splash → onboarding, tidak crash
- [ ] Android: app boot → splash → onboarding, tidak crash
- [ ] `flutter analyze` di `frontend/` tidak ada error (warning boleh)

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| | | |

## Blockers & Catatan

> _Tulis blocker, keputusan, atau temuan penting di sini. Contoh: "Apple Developer Account hanya free tier, coba workaround di S0-07."_
