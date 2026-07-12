# Sprint 2 — Send Flow

## Tujuan Sprint

Mengimplementasikan alur kirim uang end-to-end: user input nominal → review biaya transparan → Face ID → backend build & submit tx via Launchtube → settle di Stellar Testnet dalam ~5 detik → saldo terupdate.

Sprint ini selesai bila **satu transaksi transfer berhasil settle di Stellar Testnet dan Flutter menampilkan `SendSuccessScreen` dengan data real.**

## Definition of Done

- [ ] `POST /tx/build` mengembalikan `{txId, challenge, credentialIds[]}` yang valid
- [ ] `POST /tx/submit` menerima assertion, merakit auth entry via Passkey Kit, submit via Launchtube, tx settle di testnet
- [ ] `GET /wallet/:userId/balance` mengembalikan saldo USDC terkini
- [ ] Flutter: input nominal → `FeeBreakdownCard` real → Face ID → `SendSuccessScreen` dengan nama & nominal
- [ ] Saldo pengirim berkurang setelah kirim (verifikasi di HomeScreen setelah `sendSuccess`)
- [ ] `challenge` encoding base64url konsisten antara Flutter client dan backend

## Prasyarat

Sprint 1 harus **DONE**: passkey onboarding jalan end-to-end, user store berisi setidaknya 1 registered wallet.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S2-01](#s2-01--implement-post-txbuild) | Implement `POST /tx/build` | `TODO` | P0 |
| [S2-02](#s2-02--implement-post-txsubmit) | Implement `POST /tx/submit` via Launchtube | `TODO` | P0 |
| [S2-03](#s2-03--implement-get-walletuseridbalance) | Implement `GET /wallet/:userId/balance` | `TODO` | P0 |
| [S2-04](#s2-04--verifikasi-challenge-encoding-base64url) | Verifikasi challenge encoding base64url | `TODO` | P0 |
| [S2-05](#s2-05--e2e-test-kirim-uang-di-ios-device-fisik) | E2E test kirim uang di iOS device fisik | `TODO` | P0 |
| [S2-06](#s2-06--e2e-test-kirim-uang-di-android-device-fisik) | E2E test kirim uang di Android device fisik | `TODO` | P0 |
| [S2-07](#s2-07--verifikasi-transaksi-di-stellar-expert) | Verifikasi transaksi di Stellar Expert | `TODO` | P1 |
| [S2-08](#s2-08--verifikasi-update-saldo-setelah-kirim) | Verifikasi update saldo setelah kirim | `TODO` | P1 |
| [S2-09](#s2-09--test-error-states-send-flow) | Test error states send flow | `TODO` | P1 |
| [S2-10](#s2-10--setup-penerima-demo-hardcoded) | Setup penerima demo hardcoded | `TODO` | P2 |

---

## S2-01 — Implement `POST /tx/build`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03 (store)

**Konteks:**  
Endpoint ini membangun transaksi Soroban (invoke SAC transfer antara dua smart wallet) dan mengembalikan **signature payload (challenge)** yang perlu ditandatangani via passkey. Challenge inilah yang dikirim ke `passkeys.authenticate()` di Flutter — harus dalam format base64url yang identik dengan yang diverifikasi `__check_auth` contract.

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
POST /tx/build
Body: { userId: string, recipient: string, amountUsd: number }
Response: { txId: string, challenge: string (base64url), credentialIds: string[] }
```

**Alur internal:**
```
1. Cari sender wallet dari store (userId → contractAddress)
2. Resolve recipient: recipientName → contractAddress penerima
   (untuk MVP: hardcode demo receiver atau lookup by name dari store)
3. Hitung amountUSD → amountStroops (Stellar: 1 USDC = 10_000_000 stroops)
4. Bangun Soroban tx: invoke SAC transfer sender→receiver
5. Hitung signature payload (hash auth entry) via Passkey Kit
6. Simpan tx di txStore: { txId, xdr, challenge, userId }
7. Return { txId, challenge (base64url), credentialIds }
```

**Implementasi:**

```typescript
import crypto from 'crypto';
import { passkeyServer } from './passkey';
import { store, txStore } from './store';

app.post('/tx/build', async (req: Request, res: Response) => {
  const { userId, recipient, amountUsd } = req.body as {
    userId: string;
    recipient: string;
    amountUsd: number;
  };

  if (!userId || !recipient || !amountUsd || amountUsd <= 0) {
    return res.status(400).json({ error: 'userId, recipient, and amountUsd required' });
  }

  const senderRecord = store.get(userId);
  if (!senderRecord) {
    return res.status(404).json({ error: 'Wallet not found' });
  }

  // MVP: resolve penerima
  // Opsi A: cari dari store by userId/name (bila penerima juga terdaftar)
  // Opsi B: hardcode demo receiver contract address
  // Opsi C: user input contract address (tapi jangan tampilkan ke UI)
  const receiverRecord = [...store.all()].find(u => u.userId !== userId);
  const receiverContractAddress = receiverRecord?.contractAddress
    ?? process.env.DEMO_RECEIVER_CONTRACT ?? '';

  if (!receiverContractAddress) {
    return res.status(400).json({ error: 'Receiver not found' });
  }

  try {
    // Passkey Kit: bangun tx transfer + hitung signature payload
    // NOTE: sesuaikan method name & params dengan API aktual package
    const { txId, xdr, challenge } = await passkeyServer.buildTransferTx({
      senderContractAddress: senderRecord.contractAddress,
      receiverContractAddress,
      assetCode: 'USDC',
      assetIssuer: process.env.USDC_ISSUER ?? 'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5',
      amount: BigInt(Math.round(amountUsd * 10_000_000)), // stroops
    });

    // Simpan pending tx
    txStore.set(txId, { xdr, challenge, userId });

    return res.json({
      txId,
      challenge, // HARUS base64url — sama persis dengan payload yang diverifikasi contract
      credentialIds: senderRecord.credentialIds,
    });
  } catch (err) {
    console.error('[tx/build] error:', err);
    return res.status(500).json({ error: 'Failed to build transaction' });
  }
});
```

> **PENTING:** Method `passkeyServer.buildTransferTx(...)` adalah pseudocode. Sesuaikan dengan API aktual. Passkey Kit mungkin menyebut ini `buildTx`, `createTransfer`, atau lainnya. Lihat TypeScript types package.

**File yang diubah/dibuat:**
- `backend/src/index.ts` — tambah endpoint
- `backend/.env.example` — tambah `USDC_ISSUER` dan `DEMO_RECEIVER_CONTRACT`

**Acceptance criteria:**
- [ ] Endpoint mengembalikan `{txId, challenge, credentialIds}` dengan format benar
- [ ] `challenge` adalah string base64url (verifikasi: tidak ada `=` padding, hanya chars `A-Za-z0-9-_`)
- [ ] `credentialIds` adalah array dari credential ID passkey sender
- [ ] Tx tersimpan di `txStore` dengan `xdr` dan `challenge`
- [ ] Request dengan `userId` tidak dikenal mengembalikan HTTP 404

---

## S2-02 — Implement `POST /tx/submit`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S2-01

**Konteks:**  
Endpoint ini menerima assertion WebAuthn dari Flutter, merakit auth entry Soroban (signature + public key + authenticatorData + clientDataJSON), menempelkannya ke tx XDR yang sudah dibangun di S2-01, lalu submit via Launchtube. Ini adalah titik paling teknis dalam seluruh codebase.

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
POST /tx/submit
Body: { txId: string, assertion: { credentialId, clientDataJSON, authenticatorData, signature } }
Response: { txId: string }  (settle ~5 detik)
```

**Alur internal:**
```
1. Ambil pending tx dari txStore (txId → { xdr, challenge, userId })
2. Verifikasi bahwa credentialId dalam assertion sesuai dengan user
3. Passkey Kit: rakit auth entry dari assertion + pasang ke tx XDR
4. Submit tx yang sudah ter-sign via Launchtube (fee di-sponsor)
5. Tunggu konfirmasi (atau fire-and-forget dengan polling)
6. Hapus tx dari txStore
7. Return { txId }
```

**Implementasi:**

```typescript
import { passkeyServer } from './passkey';
import { store, txStore } from './store';

app.post('/tx/submit', async (req: Request, res: Response) => {
  const { txId, assertion } = req.body as {
    txId: string;
    assertion: {
      credentialId: string;
      clientDataJSON: string;
      authenticatorData: string;
      signature: string;
    };
  };

  if (!txId || !assertion) {
    return res.status(400).json({ error: 'txId and assertion required' });
  }

  const pending = txStore.get(txId);
  if (!pending) {
    return res.status(404).json({ error: 'Transaction not found or expired' });
  }

  try {
    // Passkey Kit: tempel signature ke tx, submit via Launchtube
    // NOTE: sesuaikan dengan API aktual package
    await passkeyServer.submitSignedTx({
      xdr: pending.xdr,
      assertion: {
        id: assertion.credentialId,
        clientDataJSON: assertion.clientDataJSON,
        authenticatorData: assertion.authenticatorData,
        signature: assertion.signature,
      },
      // Launchtube otomatis handle fee & sequence
    });

    txStore.delete(txId);

    return res.json({ txId });
  } catch (err) {
    console.error('[tx/submit] error:', err);
    return res.status(500).json({ error: 'Transaction submission failed' });
  }
});
```

**File yang diubah/dibuat:**
- `backend/src/index.ts` — tambah endpoint

**Acceptance criteria:**
- [ ] Setelah POST ke endpoint ini, transaksi bisa dilihat di Stellar Testnet Explorer
- [ ] Endpoint mengembalikan `{txId}` dengan HTTP 200
- [ ] Tx dihapus dari `txStore` setelah submit
- [ ] Error Launchtube (token expired, rate limit) ditangani dengan HTTP 500 + pesan

**Catatan risiko:**
- **Encoding mismatch** adalah bug paling umum di tahap ini. Verifikasi bahwa `assertion.signature`, `authenticatorData`, dan `clientDataJSON` diteruskan ke Passkey Kit tanpa manipulasi encoding tambahan.
- Bila tx gagal dengan error "auth entry invalid" → kemungkinan `challenge` di S2-01 tidak sesuai format yang diverifikasi `__check_auth`. Lihat S2-04.

---

## S2-03 — Implement `GET /wallet/:userId/balance`

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-03 (store), S1-05 (wallet created)

**Konteks:**  
Flutter memanggil endpoint ini setelah `SendSuccessScreen` untuk memperbarui saldo di HomeScreen. Saldo diambil langsung dari Stellar (Soroban RPC / Horizon) agar real-time, bukan dari cache.

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
GET /wallet/:userId/balance
Response: { balanceUsd: number }
```

**Implementasi:**

```typescript
import { Horizon } from '@stellar/stellar-sdk'; // atau dari passkey-kit

const horizon = new Horizon.Server(process.env.HORIZON_URL!);

// USDC testnet issuer
const USDC_ISSUER = process.env.USDC_ISSUER ?? 'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5';

app.get('/wallet/:userId/balance', async (req: Request, res: Response) => {
  const { userId } = req.params;
  const userRecord = store.get(userId);

  if (!userRecord) {
    return res.status(404).json({ error: 'Wallet not found' });
  }

  try {
    // Untuk smart wallet (contract account), gunakan Soroban RPC untuk query SAC balance
    // NOTE: smart wallet adalah contract address, bukan classic Stellar account
    // Mungkin perlu Passkey Kit / SorobanRpc.Server untuk query contract storage
    
    // Alternatif MVP: gunakan Horizon untuk classic trustline balance
    // (hanya works kalau smart wallet punya classic account backing)
    
    // Implementasi sesuai dengan cara Passkey Kit expose balance:
    const balanceUsd = await passkeyServer.getBalance({
      contractAddress: userRecord.contractAddress,
      assetCode: 'USDC',
      assetIssuer: USDC_ISSUER,
    });

    // Update cache di store
    store.set(userId, { ...userRecord, balanceUsd });

    return res.json({ balanceUsd });
  } catch (err) {
    // Fallback ke cached value bila RPC gagal
    console.error('[balance] error, using cached:', err);
    return res.json({ balanceUsd: userRecord.balanceUsd });
  }
});
```

> **Catatan:** Query balance untuk smart wallet (contract account) berbeda dari classic Stellar account. Mungkin butuh `SorobanRpc.Server` untuk invoke SAC `balance(address)` function. Sesuaikan dengan cara Passkey Kit expose ini.

**File yang diubah/dibuat:**
- `backend/src/index.ts` — tambah endpoint
- `backend/package.json` — tambah `@stellar/stellar-sdk` bila belum ada

**Acceptance criteria:**
- [ ] `GET /wallet/<userId>/balance` mengembalikan `{balanceUsd: <number>}`
- [ ] Nilai berubah setelah transaksi kirim berhasil
- [ ] Error RPC menggunakan cached balance (tidak crash)

---

## S2-04 — Verifikasi challenge encoding base64url

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S2-01, S2-02

**Konteks:**  
Ini adalah **titik paling rawan bug** dalam seluruh alur. `challenge` yang dihasilkan `/tx/build` harus identik (byte-untuk-byte, encoding-untuk-encoding) dengan signature payload yang diverifikasi `__check_auth` di contract. Satu perbedaan encoding = verifikasi gagal tanpa pesan error yang jelas.

**Checklist verifikasi:**

1. **Di backend (`/tx/build`):**
   - Challenge dikembalikan sebagai `base64url` (bukan `base64` biasa, bukan hex)
   - Tidak ada karakter `+`, `/`, atau `=` di challenge string
   - Contoh valid: `dGVzdC1jaGFsbGVuZ2U` (no padding)
   - Test: `Buffer.from(challenge, 'base64url')` harus berhasil

2. **Di Flutter (`passkey_service.dart`):**
   - `challengeB64Url` diteruskan langsung ke `passkeys.authenticate(challenge: challengeB64Url)` tanpa transformasi
   - Pastikan tidak ada `base64.encode/decode` tambahan di Dart sebelum passing

3. **Di Passkey Kit server (`/tx/submit`):**
   - `clientDataJSON` dari assertion berisi field `challenge` — verifikasi bahwa nilai ini sama dengan yang dikirim
   - Decode: `JSON.parse(Buffer.from(assertion.clientDataJSON, 'base64url').toString()).challenge`
   - Nilai ini harus sama dengan `challenge` dari `/tx/build`

4. **Di contract `__check_auth`:**
   - Verifikasi bahwa format yang diverifikasi contract sesuai dengan apa yang Passkey Kit generate
   - Biasanya Passkey Kit handle ini otomatis — tapi tetap verifikasi di log bila tx gagal

**Test script (run di terminal backend):**

```typescript
// test-challenge.ts — jalankan: tsx test-challenge.ts
import crypto from 'crypto';

const raw = crypto.randomBytes(32);
const b64url = raw.toString('base64url');
const b64 = raw.toString('base64');

console.log('base64url (BENAR):', b64url);
console.log('base64 (SALAH untuk passkey):', b64);
console.log('has padding:', b64url.includes('='));     // harus false
console.log('has +:', b64url.includes('+'));           // harus false
console.log('has /:', b64url.includes('/'));           // harus false
console.log('roundtrip OK:', Buffer.from(b64url, 'base64url').equals(raw)); // harus true
```

**Acceptance criteria:**
- [ ] Script test challenge menunjukkan semua assertion `true`
- [ ] Challenge dari `/tx/build` tidak mengandung `+`, `/`, atau `=`
- [ ] `clientDataJSON.challenge` dalam assertion identik dengan challenge yang dikirim (setelah decode JSON)
- [ ] Tx submit tidak gagal dengan error "invalid signature" atau "auth failed"

---

## S2-05 — E2E test kirim uang di iOS device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S2-01, S2-02, S2-03, S2-04

**Konteks:**  
Test end-to-end penuh alur kirim uang dari device iOS. Ini adalah **demo money-shot #2**.

**Langkah:**
1. Pastikan user sudah terdaftar (Sprint 1 sukses) dan punya saldo USDC > 0 di wallet.
2. Di HomeScreen → tap **Kirim**
3. Input: nama penerima + nominal (misal Rp 1.000.000)
4. Verifikasi: `FeeBreakdownCard` muncul real-time ("Keluarga terima Rp 995.000")
5. Tap **Lanjut** → `SendReviewScreen` dengan `FeeBreakdownCard` lengkap
6. Tap **Kirim sekarang** → bottom sheet biometrik muncul
7. Tap "Konfirmasi dengan Face ID" → Face ID prompt muncul → sukses
8. Tunggu ~5 detik → `SendSuccessScreen`: "Uang terkirim. [Nama] menerima Rp 995.000."
9. Tap **Selesai** → HomeScreen dengan saldo berkurang

**Acceptance criteria:**
- [ ] `FeeBreakdownCard` menampilkan nilai yang benar (amountIdr, feeIdr, receiveIdr)
- [ ] Face ID muncul saat tap "Konfirmasi"
- [ ] `SendSuccessScreen` menampilkan nama dan nominal yang benar
- [ ] HomeScreen saldo berkurang sesuai nominal kirim
- [ ] Transaksi bisa dilihat di Stellar Expert testnet

---

## S2-06 — E2E test kirim uang di Android device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S2-01, S2-02, S2-03, S2-04

**Konteks:**  
Test yang sama di Android.

**Langkah:**
Sama dengan S2-05, di Android device fisik.

**Acceptance criteria:**
- [ ] Fingerprint/biometrik Android muncul saat konfirmasi
- [ ] `SendSuccessScreen` menampilkan data benar
- [ ] Transaksi settle di Stellar Testnet

---

## S2-07 — Verifikasi transaksi di Stellar Expert

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore  
**Dependencies:** S2-05 atau S2-06

**Konteks:**  
Bukti bahwa uang benar-benar bergerak di blockchain, bukan hanya state lokal.

**Langkah:**
1. Dari log Railway `/tx/submit`, ambil transaction hash.
2. Buka: `https://stellar.expert/explorer/testnet/tx/<txHash>`
3. Verifikasi:
   - Operation type: `invoke_contract` (SAC transfer)
   - Amount: sesuai dengan yang dikirim
   - Sender contract address: sesuai wallet pengirim
   - Receiver contract address: sesuai wallet penerima
   - Fee: 0 atau sangat kecil (di-sponsor Launchtube)

**Acceptance criteria:**
- [ ] Tx muncul di Stellar Expert testnet
- [ ] Amount dan addresses sesuai
- [ ] Fee di-sponsor (user tidak keluar XLM)

---

## S2-08 — Verifikasi update saldo setelah kirim

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test  
**Dependencies:** S2-03, S2-05

**Konteks:**  
Setelah kirim berhasil, `AuthController.updateBalance()` dipanggil oleh `SendController`. HomeScreen harus menampilkan saldo terbaru.

**Langkah:**
1. Catat saldo di HomeScreen sebelum kirim.
2. Kirim Rp 100.000 (~$6,12).
3. Kembali ke HomeScreen → catat saldo baru.
4. Verifikasi: selisih sesuai (amountIdr / rate ≈ amountUsd).

**Acceptance criteria:**
- [ ] Saldo HomeScreen berkurang setelah transaksi berhasil
- [ ] Selisih sesuai dengan nominal yang dikirim (±1 Rp karena pembulatan)

---

## S2-09 — Test error states send flow

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test  
**Dependencies:** S2-05

**Skenario yang diuji:**

| Skenario | Cara memicu | Expected UI |
|----------|------------|-------------|
| User cancel biometrik saat konfirmasi | Tap cancel di Face ID prompt | Kembali ke `SendReviewScreen`, Snackbar error |
| Network error saat `/tx/build` | Matikan internet sebelum tap "Kirim" | Snackbar: "Gagal memproses. Coba lagi." |
| Network error saat `/tx/submit` | Matikan internet setelah Face ID | Snackbar: pesan error |
| Saldo tidak cukup | Kirim nominal > saldo | Backend error 4xx → Snackbar pesan |

**Acceptance criteria:**
- [ ] Semua skenario menghasilkan Snackbar, bukan crash
- [ ] Setelah error, user bisa kembali ke HomeScreen atau coba lagi
- [ ] `SendPhase` kembali ke `error` → UI tidak stuck di "Mengirim…"

---

## S2-10 — Setup penerima demo hardcoded

**Status:** `TODO` | **Prioritas:** P2 | **Tipe:** feat  
**Dependencies:** S1-05

**Konteks:**  
Untuk demo panggung, penerima bisa hardcoded sebagai "BCA ****1234" (mock off-ramp yang sudah ada di `ReceiveScreen`). Backend perlu tahu contract address penerima demo tanpa user harus input address panjang.

**Langkah:**
1. Di `backend/.env.example` tambahkan:
   ```
   DEMO_RECEIVER_CONTRACT=<contract-address-penerima-demo>
   ```
2. Di Railway dashboard, set `DEMO_RECEIVER_CONTRACT` ke contract address dari demo-receiver wallet (S0-12).
3. Di `/tx/build`, bila `recipient` tidak ditemukan di store, fallback ke `DEMO_RECEIVER_CONTRACT`.
4. Opsional: tambahkan endpoint `POST /wallet/register-demo` untuk mendaftarkan demo receiver ke store.

**File yang diubah/dibuat:**
- `backend/.env.example` — tambah `DEMO_RECEIVER_CONTRACT`
- `backend/src/index.ts` — update logika resolve recipient di `/tx/build`

**Acceptance criteria:**
- [ ] Kirim ke nama apapun → tx diroute ke demo receiver contract
- [ ] `ReceiveScreen` menampilkan mock off-ramp yang sesuai

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| | | |

## Blockers & Catatan

> _Bug paling umum sprint ini:_
> _1. `challenge` encoding mismatch — lihat S2-04_
> _2. Passkey Kit API berbeda dari pseudocode — tulis resolusi di sini_
> _3. Launchtube rate limit di testnet — cek kapasitas token yang didapat_
