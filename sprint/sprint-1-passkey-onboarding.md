# Sprint 1 — Passkey Onboarding

## Tujuan Sprint

Mengimplementasikan alur registrasi passkey end-to-end: user tap "Buat akun dengan Face ID" → biometrik muncul → smart wallet ter-deploy di Stellar Testnet → user masuk ke HomeScreen dengan saldo.

Sprint ini selesai bila **satu user baru berhasil registrasi passkey di device fisik dan wallet-nya muncul di blockchain Stellar Testnet.**

## Definition of Done

- [ ] `GET /passkey/register-options` mengembalikan `{challenge, userId}` yang valid
- [ ] `POST /wallet/create` mem-parsing attestation WebAuthn, deploy smart wallet via factory, mengembalikan `{userId, contractAddress, balanceUsd}`
- [ ] Flutter: tap "Buat akun" → biometrik muncul → HomeScreen dengan saldo `Rp 0` (atau saldo awal bila di-fund)
- [ ] Contract address wallet user bisa diverifikasi di Stellar Expert testnet
- [ ] Alur error (user cancel biometrik, network error) ditangani dengan pesan ramah user

## Prasyarat

Sprint 0 harus **DONE**: Railway ter-deploy, `.well-known` valid, iOS Associated Domains aktif, Android Asset Links aktif, Factory Contract ID tersedia, Launchtube token tersedia.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S1-01](#s1-01--verifikasi-dan-perbaiki-nama-package-passkeykit) | Verifikasi & perbaiki nama package PasskeyKit | `TODO` | P0 |
| [S1-02](#s1-02--buat-modul-passkeykit-server-di-backend) | Buat modul PasskeyKit server di backend | `TODO` | P0 |
| [S1-03](#s1-03--buat-in-memory-user-store) | Buat in-memory user store | `TODO` | P0 |
| [S1-04](#s1-04--implement-get-passkeyregister-options) | Implement `GET /passkey/register-options` | `TODO` | P0 |
| [S1-05](#s1-05--implement-post-walletcreate) | Implement `POST /wallet/create` | `TODO` | P0 |
| [S1-06](#s1-06--e2e-test-registrasi-di-ios-device-fisik) | E2E test registrasi di iOS device fisik | `TODO` | P0 |
| [S1-07](#s1-07--e2e-test-registrasi-di-android-device-fisik) | E2E test registrasi di Android device fisik | `TODO` | P0 |
| [S1-08](#s1-08--verifikasi-wallet-di-stellar-expert) | Verifikasi wallet di Stellar Expert testnet | `TODO` | P1 |
| [S1-09](#s1-09--test-error-states-onboarding) | Test error states onboarding | `TODO` | P1 |

---

## S1-01 — Verifikasi & perbaiki nama package PasskeyKit

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
`backend/package.json` mencantumkan `"@passkeykit/sdk": "^0.1.0"`. Nama package ini perlu diverifikasi — package Passkey Kit resmi Stellar mungkin bernama berbeda di npm. Ini harus diklarifikasi sebelum menulis kode backend apapun.

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
- [ ] `npm install` di `backend/` selesai tanpa error
- [ ] Package PasskeyKit bisa di-import: `import { PasskeyServer } from '<package-name>'` tidak error
- [ ] Versi package dicatat di `sprint/CONFIG.md`

**Catatan risiko:**  
Jika package belum tersedia di npm (masih GitHub-only), install langsung dari GitHub:
```json
"passkey-kit": "github:stellar/passkey-kit#<commit-hash>"
```
Dalam hal ini pin ke commit hash spesifik, bukan branch.

---

## S1-02 — Buat modul PasskeyKit server di backend

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-01

**Konteks:**  
PasskeyKit server-side (`PasskeyServer` / `PasskeyKit`) perlu diinisialisasi dengan konfigurasi Stellar (network, RPC URL, factory contract ID, Launchtube). Ini dibuat sebagai singleton module agar tidak re-init di setiap request.

**Langkah:**
1. Buat `backend/src/passkey.ts`:

```typescript
import { PasskeyServer } from '<package-name>'; // ganti dengan nama package hasil S1-01
import { Networks } from '@stellar/stellar-sdk'; // atau dari passkey-kit

// Validasi env vars wajib
const required = ['FACTORY_CONTRACT_ID', 'SIGNER_SECRET_KEY', 'LAUNCHTUBE_TOKEN', 'LAUNCHTUBE_URL'] as const;
for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing env var: ${key}`);
}

export const passkeyServer = new PasskeyServer({
  rpcUrl: process.env.SOROBAN_RPC_URL!,
  launchtubeUrl: process.env.LAUNCHTUBE_URL!,
  launchtubeJwt: process.env.LAUNCHTUBE_TOKEN!,
  factoryContractId: process.env.FACTORY_CONTRACT_ID!,
  network: process.env.STELLAR_NETWORK === 'mainnet' ? Networks.PUBLIC : Networks.TESTNET,
  // signerSecret dibutuhkan untuk fee sponsorship / deploy
  signerSecret: process.env.SIGNER_SECRET_KEY!,
});
```

> **Penting:** API `PasskeyServer` mungkin berbeda tergantung versi. Sesuaikan parameter dengan docs/README package yang diinstall. Periksa `PasskeyKit` class (client-side) vs `PasskeyServer` class (server-side).

2. Import dan test di `backend/src/index.ts`:
```typescript
import './passkey'; // early init — crash fast kalau config salah
```

**File yang diubah/dibuat:**
- `backend/src/passkey.ts` (baru)
- `backend/src/index.ts` — tambah import

**Acceptance criteria:**
- [ ] Backend start tanpa error (`npm run dev`)
- [ ] Tidak ada `Missing env var` error saat startup
- [ ] Log startup menunjukkan PasskeyServer berhasil diinit (atau tidak error)

---

## S1-03 — Buat in-memory user store

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-01

**Konteks:**  
Untuk MVP, mapping antara `userId` ↔ `contractAddress` ↔ `credentialId` disimpan in-memory. Ini cukup untuk demo — data hilang saat server restart, tapi untuk hackathon tidak masalah.

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
- [ ] Module dapat di-import tanpa error TypeScript
- [ ] Tidak ada type error di `npm run build`

---

## S1-04 — Implement `GET /passkey/register-options`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03

**Konteks:**  
Endpoint ini menghasilkan `challenge` WebAuthn yang dikirim ke Flutter. Flutter meneruskannya ke `passkeys.register()`. Challenge disimpan sementara di `challengeStore` untuk divalidasi saat `/wallet/create`.

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
- [ ] `curl "https://<railway-url>/passkey/register-options?userName=Test"` mengembalikan JSON `{challenge, userId}`
- [ ] `challenge` adalah string base64url valid (no padding `=`, hanya chars `A-Za-z0-9-_`)
- [ ] `userId` adalah UUID v4
- [ ] Request tanpa `userName` mengembalikan HTTP 400

---

## S1-05 — Implement `POST /wallet/create`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03, S1-04

**Konteks:**  
Endpoint terpenting di Sprint 1. Menerima attestation WebAuthn dari Flutter, memvalidasinya, mengekstrak public key `secp256r1`, lalu menyuruh Passkey Kit deploy smart wallet baru via factory contract. Fee di-sponsor Launchtube.

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
POST /wallet/create
Body: { userId: string, attestation: { credentialId, clientDataJSON, attestationObject } }
Response: { userId, contractAddress, balanceUsd }
```

**Langkah:**
1. Tambahkan endpoint:

```typescript
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
- [ ] Flutter attestation → backend → wallet ter-deploy di Stellar Testnet
- [ ] Contract address dikembalikan dan dapat diverifikasi di Stellar Expert
- [ ] Mapping user ↔ wallet tersimpan di store
- [ ] Challenge dihapus dari `challengeStore` setelah dipakai
- [ ] Error saat attestation invalid mengembalikan HTTP 4xx/5xx dengan pesan yang jelas

---

## S1-06 — E2E test registrasi di iOS device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S1-04, S1-05

**Konteks:**  
Test end-to-end penuh dari device fisik iOS. Ini adalah **milestone kritis Sprint 1** — passkey hanya berjalan benar di device fisik dengan Associated Domains yang valid.

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
- [ ] Biometrik iOS muncul (Face ID/Touch ID prompt)
- [ ] Setelah biometrik sukses → HomeScreen dengan saldo `Rp 0`
- [ ] Tidak ada crash
- [ ] Railway log: `/wallet/create` mengembalikan 200 dengan `contractAddress`

**Catatan risiko:**
- Jika biometrik tidak muncul sama sekali → periksa Associated Domains di Xcode (S0-07) dan `apple-app-site-association` (S0-04)
- Jika muncul tapi gagal verifikasi → periksa `challenge` encoding (harus base64url) dan RP_ID
- Cek `Console.app` di Mac untuk log passkey-specific iOS

---

## S1-07 — E2E test registrasi di Android device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S1-04, S1-05

**Konteks:**  
Test yang sama di Android. Android Credential Manager mungkin punya perilaku berbeda dari iOS.

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
**Dependencies:** S1-06 atau S1-07

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
**Dependencies:** S1-06 atau S1-07

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
| | | |

## Blockers & Catatan

> _Paling sering: API PasskeyKit tidak sesuai pseudocode di S1-05. Tulis di sini perbedaan yang ditemukan dan solusinya._
