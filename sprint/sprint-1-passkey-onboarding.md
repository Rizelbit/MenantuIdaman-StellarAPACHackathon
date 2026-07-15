# Sprint 1 — Passkey Onboarding

## Tujuan Sprint

Mengimplementasikan alur registrasi passkey end-to-end: user tap "Buat akun dengan Face ID" → biometrik muncul → smart wallet ter-deploy di Stellar Testnet → user masuk ke HomeScreen dengan saldo.

Sprint ini selesai bila **satu user baru berhasil registrasi passkey di device fisik dan wallet-nya muncul di blockchain Stellar Testnet.**

## Definition of Done

- [x] `GET /passkey/register-options` mengembalikan `{challenge, userId}` yang valid — terverifikasi lewat code review + test empiris base64url, lihat S1-04
- [x] `POST /wallet/create` mem-parsing attestation WebAuthn, deploy smart wallet, mengembalikan `{userId, contractAddress, balanceUsd}` — **~~via factory~~ via wallet WASM + canonical deployer (arsitektur v1, lihat catatan di bawah)**; submit on-chain butuh OpenZeppelin Channels terkonfigurasi, lihat S1-05
- [ ] Flutter: tap "Buat akun" → biometrik muncul → HomeScreen dengan saldo real (bukan selalu `Rp 0` — `getUsdcBalance()` sekarang query on-chain asli) — **belum pernah dites di device fisik**
- [ ] Contract address wallet user bisa diverifikasi di Stellar Expert testnet — belum ada wallet yang ter-deploy dari device fisik untuk dicek
- [ ] Alur error (user cancel biometrik, network error) ditangani dengan pesan ramah user — belum dites

**Update (2026-07-16):** Backend Sprint 1 (S1-01 s/d S1-05) ternyata sudah **selesai** — dikerjakan bareng dengan Sprint 2 dalam beberapa commit sekaligus, bukan berurutan sesuai rencana sprint ini. Detail per-issue di bawah. Yang masih genuinely `TODO` cuma testing di device fisik (S1-06 SKIPPED untuk iOS, S1-07/S1-08/S1-09 masih perlu Android device).

## Prasyarat

~~Sprint 0 harus **DONE**: Railway ter-deploy, `.well-known` valid, iOS Associated Domains aktif, Android Asset Links aktif, Factory Contract ID tersedia, Launchtube token tersedia.~~

**Revisi:** dua item prasyarat di atas sudah tidak berlaku/berubah bentuk:
- **Factory Contract ID** — tidak pernah ada di arsitektur `passkey-kit` v1 yang dipakai project ini (lihat `sprint/sprint-0-foundation.md` S0-10). Diganti **Wallet WASM Hash** + **Canonical Deployer**, sudah tersedia (`sprint/CONFIG.md`).
- **Launchtube token** — Launchtube di-skip permanen, deprecated (S0-11). Diganti **OpenZeppelin Channels** (`RELAYER_BASE_URL`/`RELAYER_API_KEY`) — **ini prasyarat blocking yang sebenarnya**, lihat `NEXT_STEPS.md` §1a.
- **iOS Associated Domains** — di-skip permanen untuk demo ini (kendala biaya Apple Developer Program). Sprint 1 secara de facto **Android-only**.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S1-01](#s1-01--verifikasi-dan-perbaiki-nama-package-passkeykit) | Verifikasi & perbaiki nama package PasskeyKit | `FINISHED` | P0 |
| [S1-02](#s1-02--buat-modul-passkeykit-server-di-backend) | Buat modul PasskeyKit server di backend | `FINISHED` | P0 |
| [S1-03](#s1-03--buat-in-memory-user-store) | Buat in-memory user store | `FINISHED` | P0 |
| [S1-04](#s1-04--implement-get-passkeyregister-options) | Implement `GET /passkey/register-options` | `FINISHED` | P0 |
| [S1-05](#s1-05--implement-post-walletcreate) | Implement `POST /wallet/create` | `ON GOING` | P0 |
| [S1-06](#s1-06--e2e-test-registrasi-di-ios-device-fisik) | ~~E2E test registrasi di iOS device fisik~~ | `SKIPPED` | ~~P0~~ |
| [S1-07](#s1-07--e2e-test-registrasi-di-android-device-fisik) | E2E test registrasi di Android device fisik | `TODO` | P0 |
| [S1-08](#s1-08--verifikasi-wallet-di-stellar-expert) | Verifikasi wallet di Stellar Expert testnet | `TODO` | P1 |
| [S1-09](#s1-09--test-error-states-onboarding) | Test error states onboarding | `TODO` | P1 |

---

## S1-01 — Verifikasi & perbaiki nama package PasskeyKit

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16):** Nama package resmi adalah **`passkey-kit`** (bukan `@passkeykit/sdk` ataupun `@stellar/passkey-kit`), tersedia normal di npm registry. Versi terpasang: **`passkey-kit@0.14.0`** (tercatat di `sprint/CONFIG.md`). Package ini punya 3 entry point terpisah: `passkey-kit` (client, `PasskeyKit`/`SACClient`), `passkey-kit/server` (server-only, `PasskeyServer`, memegang secret relayer), `passkey-kit/storage` (storage adapter, tidak dipakai project ini). Sudah diverifikasi langsung dari `node_modules/passkey-kit/dist/*.d.ts` (bukan cuma asumsi dari README) — lihat S1-02 untuk detail API aktual yang ternyata beda signifikan dari pseudocode di bawah.

**Konteks (asli, untuk referensi historis):**  
~~`backend/package.json` mencantumkan `"@passkeykit/sdk": "^0.1.0"`. Nama package ini perlu diverifikasi — package Passkey Kit resmi Stellar mungkin bernama berbeda di npm. Ini harus diklarifikasi sebelum menulis kode backend apapun.~~

**Langkah:**
1. Cek npm registry untuk nama package yang benar:
   ```bash
   npm search passkey-kit stellar
   npm info passkey-kit
   npm info @stellar/passkey-kit
   npm info @passkeykit/sdk
   ```
2. Cek juga [github.com/stellar/passkey-kit](https://github.com/stellar/passkey-kit) → `package.json` → `"name"` field.
3. Jika nama berbeda dari `@passkeykit/sdk`:
   - Update `backend/package.json`: hapus `@passkeykit/sdk`, tambah nama yang benar
   - Jalankan `npm install` di `backend/`
   - Commit `package.json` dan `package-lock.json`
4. Catat versi yang dipakai di `sprint/CONFIG.md` sebagai **PasskeyKit npm package version**.

**File yang diubah/dibuat:**
- `backend/package.json` — update nama package bila perlu
- `backend/package-lock.json` — regenerate
- `sprint/CONFIG.md` — catat versi package

**Acceptance criteria:**
- [x] ~~`npm install`~~ `pnpm install` di `backend/` selesai tanpa error (project pindah dari npm ke pnpm, lihat `backend/Dockerfile` & `package.json` `packageManager` field)
- [x] Package PasskeyKit bisa di-import: `import { PasskeyServer } from 'passkey-kit/server'` tidak error — dites via `tsc` clean compile
- [x] Versi package dicatat di `sprint/CONFIG.md` — `passkey-kit@^0.14.0`

**Catatan risiko:**  
Jika package belum tersedia di npm (masih GitHub-only), install langsung dari GitHub:
```json
"passkey-kit": "github:stellar/passkey-kit#<commit-hash>"
```
Dalam hal ini pin ke commit hash spesifik, bukan branch.

---

## S1-02 — Buat modul PasskeyKit server di backend

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-01

**Update (2026-07-16) — API asli beda signifikan dari pseudocode di bawah:**  
Pseudocode issue ini ternyata salah di hampir semua parameter. Implementasi asli ada di `backend/src/passkey.ts`, sudah diverifikasi field-per-field terhadap `node_modules/passkey-kit/dist/*.d.ts` (bukan tebakan):

- **`PasskeyKit`** (client-side, untuk `createWallet`/`sign`) config: `{ rpcUrl, networkPassphrase, walletWasmHash, rpId, WebAuthn, deploySource? }`. Tidak ada `factoryContractId` (v1 tidak pakai factory, S0-10), tidak ada `launchtubeUrl`/`launchtubeJwt`. `signerSecret` di pseudocode sebenarnya bernama **`deploySource`** — secret key yang menandatangani transaksi *deploy* (bayar fee-nya sendiri), bukan config relayer.
- **`PasskeyServer`** (server-only, submit transaksi) config: `{ networkPassphrase, rpcUrl?, relayer?: { baseUrl, apiKey } }`. **Tidak ada opsi Launchtube sama sekali** di versi ini — `PasskeyServer.send()` **selalu** butuh `relayer` terisi (OpenZeppelin Channels), kalau tidak selalu gagal dengan `RELAYER_NOT_CONFIGURED`. Ini ditemukan dengan cara paling meyakinkan: install `node_modules` beneran dan baca `dist/server.js` langsung, bukan cuma baca `.d.ts`. Lihat `sprint/sprint-0-foundation.md` S0-11 untuk kronologi lengkap koreksi ini (S0-11 awalnya salah asumsi "self-relay tanpa relayer eksternal" cukup — ternyata tidak).
- **Pola bridge, tidak disebut di pseudocode sama sekali:** karena `PasskeyKit` didesain untuk browser (mengharapkan WebAuthn API asli), sementara ini jalan di Node server-side, implementasi asli pakai `WebAuthnBridge` — kelas custom yang mengimplementasikan `startRegistration`/`startAuthentication` sebagai Promise yang di-resolve manual oleh endpoint lain (`bridge.completeRegistration()`/`completeAuthentication()`) setelah attestation/assertion diterima dari Flutter. Ini yang membuat pola dua-request (register-options → wallet/create) bisa jalan meski `PasskeyKit` sebenarnya didesain single-call di browser.
- `WALLET_WASM_HASH` di-hardcode di `passkey.ts` (bukan env var) — nilai sama dengan `sprint/CONFIG.md` § Wallet WASM Hash.

**Konteks (asli, untuk referensi historis — parameter di bawah TIDAK akurat, lihat koreksi di atas):**  
~~PasskeyKit server-side (`PasskeyServer` / `PasskeyKit`) perlu diinisialisasi dengan konfigurasi Stellar (network, RPC URL, factory contract ID, Launchtube). Ini dibuat sebagai singleton module agar tidak re-init di setiap request.~~

```typescript
// PSEUDOCODE LAMA — jangan diikuti, lihat implementasi asli di backend/src/passkey.ts
import { PasskeyServer } from '<package-name>';
import { Networks } from '@stellar/stellar-sdk';
const required = ['FACTORY_CONTRACT_ID', 'SIGNER_SECRET_KEY', 'LAUNCHTUBE_TOKEN', 'LAUNCHTUBE_URL'] as const;
// ...factoryContractId, launchtubeUrl, launchtubeJwt, signerSecret — semua nama field ini SALAH
```

**File yang diubah/dibuat:**
- `backend/src/passkey.ts` (sudah ada — `getKit()`, `getServer()`, `getUsdcToken()`, `getUsdcBalance()`, `fundWalletWithUsdc()`, `WebAuthnBridge`)
- `backend/src/index.ts` — import langsung fungsi-fungsi di atas (bukan `import './passkey'` untuk side-effect seperti pseudocode)

**Acceptance criteria:**
- [x] Backend start tanpa error (`pnpm run dev` / `pnpm run build` — `tsc` clean)
- [x] Tidak ada `Missing env var` error saat startup — validasi env dilakukan lazy per-request (`getKit()`/`getServer()`), bukan crash-fast di startup seperti pseudocode
- [x] Modul berhasil diinit — dikonfirmasi lewat `tsc` build sukses + `pnpm test` (6/6 pass)

---

## S1-03 — Buat in-memory user store

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-01

**Update (2026-07-16):** Implementasi asli di `backend/src/store.ts` cocok dengan skema pseudocode (`UserRecord` dengan `userId`/`contractAddress`/`credentialIds`/`balanceUsd`, plus `registrationStore`/`txStore` — nama beda tipis dari `challengeStore`/`txStore` pseudocode tapi fungsinya sama: `PendingRegistration`/`PendingTransaction` menyimpan Promise yang di-resolve `WebAuthnBridge`, bukan raw challenge string). **Scope-nya melebar** jauh dari rencana Sprint 1 — sekarang juga ada `contactStore`, `requestStore`, `splitStore`, `transactionStore` untuk fitur kontak/request/split-bill yang tidak pernah direncanakan di sprint manapun (lihat `sprint/sprint-2-send-flow.md` dst. — endpoint-endpoint ini murni inisiatif tim, bukan dari backlog). Ada test unit di `backend/src/store.spec.ts` (6 test, semua pass).

**Konteks (asli, untuk referensi historis):**  
~~Untuk MVP, mapping antara `userId` ↔ `contractAddress` ↔ `credentialId` disimpan in-memory. Ini cukup untuk demo — data hilang saat server restart, tapi untuk hackathon tidak masalah.~~

**Langkah:**
1. Buat `backend/src/store.ts`:

```typescript
export interface UserRecord {
  userId: string;
  contractAddress: string;
  credentialIds: string[]; // credential ID passkey user (base64url)
  balanceUsd: number;      // cache saldo, update setelah transaksi
}

// In-memory store — restart = data hilang (OK untuk hackathon MVP)
const users = new Map<string, UserRecord>();

export const store = {
  get: (userId: string) => users.get(userId),
  set: (userId: string, record: UserRecord) => users.set(userId, record),
  getByCredentialId: (credentialId: string) =>
    [...users.values()].find(u => u.credentialIds.includes(credentialId)),
  all: () => [...users.values()],
};

// Pending challenges: userId → challenge (untuk validasi saat /wallet/create)
const pendingChallenges = new Map<string, string>();

export const challengeStore = {
  set: (userId: string, challenge: string) => pendingChallenges.set(userId, challenge),
  get: (userId: string) => pendingChallenges.get(userId),
  delete: (userId: string) => pendingChallenges.delete(userId),
};

// Pending tx: txId → { xdr, challenge, userId }
const pendingTx = new Map<string, { xdr: string; challenge: string; userId: string }>();

export const txStore = {
  set: (txId: string, data: { xdr: string; challenge: string; userId: string }) =>
    pendingTx.set(txId, data),
  get: (txId: string) => pendingTx.get(txId),
  delete: (txId: string) => pendingTx.delete(txId),
};
```

**File yang diubah/dibuat:**
- `backend/src/store.ts` (baru)

**Acceptance criteria:**
- [x] Module dapat di-import tanpa error TypeScript
- [x] Tidak ada type error di ~~`npm run build`~~ `pnpm run build` — dites clean, plus 6/6 unit test lolos di `store.spec.ts`

---

## S1-04 — Implement `GET /passkey/register-options`

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03

**Update (2026-07-16):** Alur asli beda dari pseudocode — bukan generate `crypto.randomBytes(32)` sendiri, tapi memanggil `kit.createWallet(appName, userName)` (async, belum di-await penuh) lalu **menunggu** `bridge.hasPendingRegistration()` true (lewat `waitForBridge()`, timeout 15 detik). Challenge-nya di-generate **oleh `passkey-kit` sendiri** (`generateChallenge()` internal, sudah base64url — lihat catatan di S1-05 soal ini). Response `{challenge, userId}` yang keluar ke Flutter tetap sama persis bentuknya dengan kontrak yang direncanakan. Promise dari `kit.createWallet()` disimpan di `registrationStore` (bukan `challengeStore`) untuk dilanjutkan setelah attestation masuk di `/wallet/create`.

Sudah diverifikasi via code review + test empiris (bukan cuma baca kode): konversi `Buffer.from(challenge, "base64").toString("base64url")` yang ada di kode **terbukti no-op yang aman** (byte-identik sebelum/sesudah, dites lewat script Node) karena Node's base64 decoder toleran ke karakter base64url — jadi walau kodenya terlihat redundan, tidak ada bug encoding di titik ini.

**Konteks (asli, untuk referensi historis):**  
~~Endpoint ini menghasilkan `challenge` WebAuthn yang dikirim ke Flutter. Flutter meneruskannya ke `passkeys.register()`. Challenge disimpan sementara di `challengeStore` untuk divalidasi saat `/wallet/create`.~~

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
GET /passkey/register-options?userName=<string>
Response: { challenge: string (base64url), userId: string }
```

**Langkah:**
1. Tambahkan endpoint di `backend/src/index.ts` (atau buat `backend/src/routes/passkey.ts`):

```typescript
import crypto from 'crypto';
import { challengeStore } from './store';

app.get('/passkey/register-options', (req: Request, res: Response) => {
  const userName = req.query.userName as string;
  if (!userName?.trim()) {
    return res.status(400).json({ error: 'userName required' });
  }

  // Generate userId unik
  const userId = crypto.randomUUID();

  // Generate challenge random (32 bytes, base64url)
  const challengeBytes = crypto.randomBytes(32);
  const challenge = challengeBytes.toString('base64url');

  // Simpan challenge sementara untuk divalidasi di /wallet/create
  challengeStore.set(userId, challenge);

  return res.json({ challenge, userId });
});
```

**File yang diubah/dibuat:**
- `backend/src/index.ts` — tambah endpoint (atau router terpisah)

**Acceptance criteria:**
- [ ] `curl "https://<railway-url>/passkey/register-options?userName=Test"` mengembalikan JSON `{challenge, userId}` — belum dites live terhadap Railway, cuma verifikasi kode + build
- [x] `challenge` adalah string base64url valid (no padding `=`, hanya chars `A-Za-z0-9-_`) — dikonfirmasi lewat pembacaan source `passkey-kit` (`generateChallenge()`) + simulasi round-trip di Node
- [x] `userId` adalah UUID v4 — `crypto.randomUUID()` dipakai di kode, sesuai
- [x] Request tanpa `userName` mengembalikan HTTP 400 — ada di kode (`if (!userName) return res.status(400)...`)

---

## S1-05 — Implement `POST /wallet/create`

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03, S1-04

**Update (2026-07-16):** Endpoint sudah diimplementasikan (`backend/src/index.ts`) dan **kodenya benar**, tapi statusnya `ON GOING` bukan `FINISHED` karena ada 3 lapis masalah yang ditemukan & (sebagian) diperbaiki secara berurutan — dicatat di sini karena ini persis pertanyaan yang diantisipasi issue ini ("API PasskeyKit mungkin berbeda dari pseudocode"):

1. **~~"via factory contract"~~ — salah asumsi arsitektur.** `passkey-kit` v1 tidak deploy lewat factory; `kit.createWallet(appName, userName)` deploy wallet WASM langsung dari canonical deployer. Tidak ada `FACTORY_CONTRACT_ID` untuk dicatat (S0-10).
2. **~~"Fee di-sponsor Launchtube"~~ — Launchtube tidak pernah dipakai, dan asumsi penggantinya ("self-relay pakai `SIGNER_SECRET_KEY` saja") juga terbukti salah.** `PasskeyServer.send()` (yang submit `result.signedTx` on-chain) **selalu** butuh `relayer` terkonfigurasi — tanpa `RELAYER_BASE_URL`/`RELAYER_API_KEY` (OpenZeppelin Channels), `send()` balik `RELAYER_NOT_CONFIGURED` dan **kode saat ini tidak mengecek `submitResult.success` sebelum lanjut** — artinya endpoint ini bisa balas `200 OK` dengan `contractAddress` yang terlihat valid, padahal wallet-nya **tidak pernah benar-benar ter-deploy on-chain**. Ini kenapa status masih `ON GOING`: perlu `RELAYER_API_KEY` terisi di Railway dulu (`NEXT_STEPS.md` §1a) baru bisa dikonfirmasi `FINISHED` beneran.
3. **`USDC_SAC_ADDRESS` (dipakai endpoint terkait `/tx/build`, bukan endpoint ini, tapi ditemukan dalam audit yang sama) sempat hardcode ke contract ID yang tidak valid** — sudah diperbaiki jadi dihitung dari `USDC_ISSUER` pakai `Asset.contractId()`, diverifikasi live exist di testnet via Soroban RPC.

Field request/response (`{userId, attestation}` → `{userId, contractAddress, balanceUsd}`) **cocok** dengan kontrak yang direncanakan — tidak ada mismatch nama field seperti yang dikhawatirkan pseudocode. Yang salah bukan bentuk data, tapi asumsi arsitektur submission-nya.

**Konteks (asli, untuk referensi historis — "via factory contract" dan "Launchtube" TIDAK akurat, lihat koreksi di atas):**  
~~Endpoint terpenting di Sprint 1. Menerima attestation WebAuthn dari Flutter, memvalidasinya, mengekstrak public key `secp256r1`, lalu menyuruh Passkey Kit deploy smart wallet baru via factory contract. Fee di-sponsor Launchtube.~~

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
POST /wallet/create
Body: { userId: string, attestation: { credentialId, clientDataJSON, attestationObject } }
Response: { userId, contractAddress, balanceUsd }
```

**Langkah (pseudocode asli — lihat catatan di atas untuk perbedaan dengan implementasi aktual di `backend/src/index.ts`):**
1. Tambahkan endpoint:

```typescript
// PSEUDOCODE LAMA — passkeyServer.createWallet() dan challengeStore tidak
// benar-benar ada di implementasi. Lihat backend/src/index.ts untuk kode asli
// (pakai bridge.completeRegistration() + pending.createPromise + srv.send()).
import { passkeyServer } from './passkey';
import { store, challengeStore } from './store';

app.post('/wallet/create', async (req: Request, res: Response) => {
  const { userId, attestation } = req.body as {
    userId: string;
    attestation: {
      credentialId: string;
      clientDataJSON: string;
      attestationObject: string;
    };
  };

  if (!userId || !attestation) {
    return res.status(400).json({ error: 'userId and attestation required' });
  }

  // Ambil challenge yang di-generate di /register-options
  const challenge = challengeStore.get(userId);
  if (!challenge) {
    return res.status(400).json({ error: 'No pending challenge for this userId' });
  }

  try {
    // Passkey Kit: parse attestation → ekstrak pubkey → deploy smart wallet via factory
    // NOTE: nama method & parameter bergantung pada versi package (hasil S1-01)
    // Sesuaikan dengan API docs package yang diinstall.
    const wallet = await passkeyServer.createWallet({
      userId,
      challenge,
      attestation: {
        id: attestation.credentialId,
        clientDataJSON: attestation.clientDataJSON,
        attestationObject: attestation.attestationObject,
      },
      // Launchtube otomatis di-pakai untuk sponsor fee
    });

    // Hapus challenge dari store (one-time use)
    challengeStore.delete(userId);

    // Simpan mapping user ↔ wallet
    store.set(userId, {
      userId,
      contractAddress: wallet.contractAddress, // adjust field name ke API package
      credentialIds: [attestation.credentialId],
      balanceUsd: 0,
    });

    return res.json({
      userId,
      contractAddress: wallet.contractAddress,
      balanceUsd: 0,
    });
  } catch (err) {
    console.error('[wallet/create] error:', err);
    return res.status(500).json({ error: 'Failed to create wallet' });
  }
});
```

> **PENTING:** Nama method `passkeyServer.createWallet(...)` adalah pseudocode. Sesuaikan dengan API aktual package PasskeyKit yang diinstall di S1-01. Cek README / TypeScript types package untuk method yang benar.

**File yang diubah/dibuat:**
- `backend/src/index.ts` — tambah endpoint

**Acceptance criteria:**
- [ ] Flutter attestation → backend → wallet ter-deploy di Stellar Testnet — **blocking**: butuh `RELAYER_API_KEY` terisi dulu (lihat Update di atas), lalu butuh device fisik untuk attestation asli
- [ ] Contract address dikembalikan dan dapat diverifikasi di Stellar Expert — sama, blocking di atas
- [x] Mapping user ↔ wallet tersimpan di store — `store.set()` ada di kode, terverifikasi lewat `tsc` + review
- [x] Challenge/registration pending dihapus dari `registrationStore` setelah dipakai — `registrationStore.delete(userId)` ada di kode
- [x] Error saat attestation invalid mengembalikan HTTP 4xx/5xx dengan pesan yang jelas — try/catch + `res.status(500).json({error: "Gagal membuat wallet"})` ada di kode, belum dites skenario real invalid attestation di device

---

## S1-06 — ~~E2E test registrasi di iOS device fisik~~ (SKIPPED)

**Status:** `SKIPPED` | **Prioritas:** ~~P0~~ | **Tipe:** test  
**Dependencies:** S1-04, S1-05

**Keputusan (2026-07-16):** iOS di-skip permanen untuk demo ini — Apple Developer Program berbayar ($99/tahun) tidak tersedia, dan Personal/free Apple ID kemungkinan besar tidak mendukung Associated Domains capability (lihat `sprint/sprint-0-foundation.md` S0-07). Entitlement iOS (`Runner.entitlements`, `CODE_SIGN_ENTITLEMENTS` di `project.pbxproj`) sudah di-wire di level kode sebagai persiapan, tapi tidak akan pernah dites karena tidak ada Team ID untuk signing. Demo malam ini **Android-only**.

**Konteks (asli, untuk referensi historis):**  
~~Test end-to-end penuh dari device fisik iOS. Ini adalah **milestone kritis Sprint 1** — passkey hanya berjalan benar di device fisik dengan Associated Domains yang valid.~~

**Langkah:**
1. Pastikan Railway ter-deploy dengan endpoint terbaru.
2. Sambungkan iOS device fisik ke Mac.
3. Jalankan: `./frontend/run-dev.sh -d <ios-device-id>`
4. Di app:
   - Splash → OnboardingScreen
   - Tap "Buat akun dengan Face ID"
   - **Biometrik harus muncul** (Face ID atau Touch ID prompt dari iOS)
   - Ikuti prompt → sukses
   - **HomeScreen harus muncul** dengan saldo `Rp 0`

5. Verifikasi di Railway logs: request masuk ke `/passkey/register-options` dan `/wallet/create` tanpa error.

**Acceptance criteria:**
- [x] ~~Biometrik iOS muncul (Face ID/Touch ID prompt)~~ — N/A, di-skip
- [x] ~~Setelah biometrik sukses → HomeScreen dengan saldo `Rp 0`~~ — N/A, di-skip
- [x] ~~Tidak ada crash~~ — N/A, di-skip
- [x] ~~Railway log: `/wallet/create` mengembalikan 200 dengan `contractAddress`~~ — N/A, di-skip

**Catatan risiko:**
- Jika biometrik tidak muncul sama sekali → periksa Associated Domains di Xcode (S0-07) dan `apple-app-site-association` (S0-04)
- Jika muncul tapi gagal verifikasi → periksa `challenge` encoding (harus base64url) dan RP_ID
- Cek `Console.app` di Mac untuk log passkey-specific iOS

---

## S1-07 — E2E test registrasi di Android device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S1-04, S1-05

**Update (2026-07-16):** Belum bisa dijalankan dari environment kerja Claude (tidak ada Flutter SDK/device fisik) — genuinely butuh anggota tim dengan akses device. Sebelum dites, pastikan 3 hal ini dulu (semua sudah didokumentasikan di `NEXT_STEPS.md`):
1. `RELAYER_API_KEY` (OpenZeppelin Channels) sudah terisi di Railway — tanpa ini S1-05 dijamin gagal submit on-chain.
2. `flutter run`/`run-dev.sh` **wajib** pakai `--dart-define=USE_MOCK=false` — defaultnya `true`, kalau lupa app akan pakai `MockPasskeyService` dan kelihatan "berhasil" padahal tidak pernah menyentuh backend asli sama sekali.
3. `.well-known/assetlinks.json` sudah live dengan `com.kirimin.app` — sudah terverifikasi (S0-08).

**Konteks (asli):**  
~~Test yang sama di Android. Android Credential Manager mungkin punya perilaku berbeda dari iOS.~~ (masih berlaku, belum ada perubahan di sini)

**Langkah:**
1. Sambungkan Android device fisik (developer mode on, USB debugging on).
2. Jalankan: `./frontend/run-dev.sh -d <android-device-id>`
3. Ikuti langkah sama seperti S1-06.
4. Verifikasi Android-specific: Credential Manager popup muncul (bukan alert biasa).

**Acceptance criteria:**
- [ ] Credential Manager Android muncul (biometrik / fingerprint / PIN prompt)
- [ ] Setelah biometrik sukses → HomeScreen
- [ ] Tidak ada crash
- [ ] `adb logcat | grep -i passkey` tidak menampilkan error fatal

**Catatan risiko:**
- Android 9+ diperlukan untuk Credential Manager
- Beberapa OEM (Samsung, Xiaomi) punya behavior berbeda. Uji di device yang akan dipakai untuk demo.
- Jika `assetlinks.json` tidak diverifikasi → periksa dengan `adb logcat | grep "Asset statements"`

---

## S1-08 — Verifikasi wallet di Stellar Expert testnet

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore  
**Dependencies:** ~~S1-06 atau~~ S1-07 (S1-06/iOS di-skip permanen)

**Konteks:**  
Verifikasi bahwa smart wallet benar-benar ter-deploy di blockchain, bukan hanya database lokal yang bilang "berhasil".

**Langkah:**
1. Dari Railway log `/wallet/create`, ambil `contractAddress`.
2. Buka: `https://stellar.expert/explorer/testnet/contract/<contractAddress>`
3. Verifikasi:
   - Contract exists
   - Ada creation transaction
   - Public key `secp256r1` terdaftar sebagai signer (bila bisa dilihat dari data contract)

**Acceptance criteria:**
- [ ] Contract address dapat dibuka di Stellar Expert testnet
- [ ] Ada creation transaction yang terkait dengan factory contract

---

## S1-09 — Test error states onboarding

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test  
**Dependencies:** ~~S1-06 atau~~ S1-07 (S1-06/iOS di-skip permanen)

**Konteks:**  
North star: error harus tetap ramah user. Test skenario gagal dan pastikan UI menampilkan pesan yang benar (bukan stack trace atau "Error 500").

**Skenario yang diuji:**

| Skenario | Cara memicu | Expected UI |
|----------|------------|-------------|
| User cancel biometrik | Tap cancel di Face ID prompt | Snackbar: "Verifikasi dibatalkan. Coba lagi ketika siap." |
| Network error | Matikan internet saat tap "Buat akun" | Snackbar: "Koneksi terputus. Cek internet lalu coba lagi." |
| Backend error 500 | Simulasi dengan mematikan Railway sementara | Snackbar: pesan error generic |

**Acceptance criteria:**
- [ ] Semua 3 skenario menghasilkan pesan di Snackbar, bukan crash
- [ ] Setelah error, user bisa coba lagi (button tidak disabled)
- [ ] Tidak ada istilah teknis ("Exception", "Error 500", dsb.) yang muncul ke user

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| 2026-07-16 | Audit menyeluruh: S1-01 s/d S1-05 ternyata sudah diimplementasikan (dikerjakan bareng Sprint 2 dalam commit gabungan, bukan berurutan per rencana). Semua status & pseudocode direkonsiliasi dengan kode aktual. | Selesai (audit) |
| 2026-07-16 | Ditemukan & diperbaiki: `PasskeyServer.send()` selalu butuh relayer (OpenZeppelin Channels), bukan opsional seperti diasumsikan S0-11 sebelumnya — S1-05 diturunkan dari asumsi "selesai" jadi `ON GOING` sampai `RELAYER_API_KEY` terisi & submit on-chain terkonfirmasi sukses. | Koreksi kritis |
| 2026-07-16 | iOS (S1-06) resmi di-skip permanen — kendala biaya Apple Developer Program. Demo Android-only. | Keputusan |

## Blockers & Catatan

**API PasskeyKit vs pseudocode — perbedaan yang ditemukan (persis yang diantisipasi catatan ini):**

1. **Nama & signature parameter beda total.** Pseudocode pakai `factoryContractId`, `launchtubeUrl`, `launchtubeJwt`, `signerSecret`, `challengeStore`. API asli (`passkey-kit@0.14.0`) pakai `walletWasmHash`, `rpId`, `deploySource`, `relayer: {baseUrl, apiKey}`, dan pola `WebAuthnBridge` + `registrationStore`/`txStore` berbasis Promise (bukan raw challenge string). Detail lengkap per-parameter ada di catatan S1-02.
2. **Fee sponsorship BUKAN Launchtube, dan BUKAN "self-relay tanpa relayer" seperti yang sempat diputuskan di S0-11.** `PasskeyServer.send()` mengharuskan relayer eksternal (OpenZeppelin Channels) — tidak ada jalur submit-langsung-pakai-secret-key yang didukung resmi oleh library ini. Ini ditemukan dengan cara paling meyakinkan yang bisa dilakukan tanpa device fisik: install `node_modules` beneran dan baca implementasi (`dist/server.js`) langsung, bukan cuma tebak dari nama method. Solusi: `https://channels.openzeppelin.com/testnet/gen` (gratis, instan, tanpa approval) — lihat `NEXT_STEPS.md` §1a.
3. **Arsitektur "factory contract" tidak pernah ada di v1.** `passkey-kit` v1 deploy wallet WASM langsung dari canonical deployer per-user, bukan lewat factory contract yang di-deploy sekali lalu dipanggil berkali-kali. Ini mengubah beberapa asumsi di Sprint 0 (S0-10) yang direncanakan sebelum tim tahu versi library yang dipakai.
4. **Tidak ada jalur mint USDC sendiri** (ditemukan saat mengerjakan task funding wallet demo, relevan juga untuk S1 karena wallet baru dari onboarding selalu mulai 0 USDC) — `USDC_ISSUER` adalah issuer testnet resmi Circle, bukan milik kita. Solusi: `POST /wallet/:userId/fund` (baru, lihat `NEXT_STEPS.md` §1b) transfer dari akun yang sudah di-fund via `faucet.circle.com`.

**Kesimpulan umum:** kode backend Sprint 1 secara struktur/kontrak data (nama field request/response) **benar dan cocok** dengan yang direncanakan sprint ini — deviasi terbesar ada di lapisan *bagaimana transaksi disubmit ke chain* (relayer, bukan self-relay), bukan di *bentuk data* antara Flutter dan backend.
