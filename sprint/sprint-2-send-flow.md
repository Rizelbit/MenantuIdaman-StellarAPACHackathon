# Sprint 2 — Send Flow

## Tujuan Sprint

Mengimplementasikan alur kirim uang end-to-end: user input nominal → review biaya transparan → Face ID → backend build & submit tx via Launchtube → settle di Stellar Testnet dalam ~5 detik → saldo terupdate.

Sprint ini selesai bila **satu transaksi transfer berhasil settle di Stellar Testnet dan Flutter menampilkan `SendSuccessScreen` dengan data real.**

## Definition of Done

- [x] `POST /tx/build` mengembalikan `{txId, challenge, credentialIds[]}` yang valid — kode benar, lihat S2-01
- [x] `POST /tx/submit` menerima assertion, merakit auth entry via Passkey Kit, submit **~~via Launchtube~~ via OpenZeppelin Channels (relayer)**, tx settle di testnet — kode benar, submit on-chain butuh `RELAYER_API_KEY` terkonfigurasi, lihat S2-02
- [x] `GET /wallet/:userId/balance` mengembalikan saldo USDC terkini — **real query on-chain** via Soroban RPC/SAC (`getUsdcBalance()`), bukan cache statis, lihat S2-03
- [ ] Flutter: input nominal → `FeeBreakdownCard` real → Face ID → `SendSuccessScreen` dengan nama & nominal — **belum pernah dites di device fisik**
- [x] Saldo pengirim berkurang setelah kirim (verifikasi di HomeScreen setelah `sendSuccess`) — kode di kedua sisi (backend `getUsdcBalance()` + `send_controller.dart` `api.getBalanceUsd()`) sudah benar, lihat S2-08. Live verification di device masih pending.
- [x] `challenge` encoding base64url konsisten antara Flutter client dan backend — diverifikasi lewat code review + test empiris, lihat S2-04

**Update (2026-07-16):** Sama seperti Sprint 1 — backend Sprint 2 (S2-01 s/d S2-04) ternyata sudah **selesai**, dikerjakan bareng dalam commit gabungan. S2-10 (demo receiver) juga sebagian besar sudah beres, malah lebih canggih dari rencana asli. Yang genuinely `TODO` cuma testing di device fisik (S2-05 SKIPPED untuk iOS) dan pengisian `RELAYER_API_KEY` di Railway (blocking S2-02, sama seperti S1-05).

## Prasyarat

Sprint 1 harus **DONE**: passkey onboarding jalan end-to-end, user store berisi setidaknya 1 registered wallet.

**Catatan:** Sprint 1 statusnya `ON GOING`, bukan `DONE` — S1-05 (deploy wallet) masih menunggu `RELAYER_API_KEY` dikonfirmasi jalan on-chain, dan belum ada satupun wallet yang benar-benar ter-deploy dari device fisik. Sprint 2 secara kode sudah bisa dikerjakan (dan sudah dikerjakan) duluan tanpa menunggu Sprint 1 kelar, tapi **testing end-to-end Sprint 2 tetap terblokir** oleh prasyarat ini — tidak ada wallet asli untuk dites kirim uangnya. Lihat `sprint/sprint-1-passkey-onboarding.md`.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S2-01](#s2-01--implement-post-txbuild) | Implement `POST /tx/build` | `FINISHED` | P0 |
| [S2-02](#s2-02--implement-post-txsubmit) | ~~Implement `POST /tx/submit` via Launchtube~~ via OpenZeppelin Channels | `ON GOING` | P0 |
| [S2-03](#s2-03--implement-get-walletuseridbalance) | Implement `GET /wallet/:userId/balance` | `FINISHED` | P0 |
| [S2-04](#s2-04--verifikasi-challenge-encoding-base64url) | Verifikasi challenge encoding base64url | `FINISHED` | P0 |
| [S2-05](#s2-05--e2e-test-kirim-uang-di-ios-device-fisik) | ~~E2E test kirim uang di iOS device fisik~~ | `SKIPPED` | ~~P0~~ |
| [S2-06](#s2-06--e2e-test-kirim-uang-di-android-device-fisik) | E2E test kirim uang di Android device fisik | `TODO` | P0 |
| [S2-07](#s2-07--verifikasi-transaksi-di-stellar-expert) | Verifikasi transaksi di Stellar Expert | `TODO` | P1 |
| [S2-08](#s2-08--verifikasi-update-saldo-setelah-kirim) | Verifikasi update saldo setelah kirim | `ON GOING` | P1 |
| [S2-09](#s2-09--test-error-states-send-flow) | Test error states send flow | `TODO` | P1 |
| [S2-10](#s2-10--setup-penerima-demo-hardcoded) | Setup penerima demo hardcoded | `ON GOING` | P2 |

---

## S2-01 — Implement `POST /tx/build`

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-02, S1-03 (store)

**Update (2026-07-16):** Diimplementasikan di `backend/src/index.ts`, dan **resolve recipient-nya lebih canggih dari pseudocode**: bukan cuma "user lain pertama di store atau fallback demo receiver" (opsi A/B pseudocode), tapi `resolveRecipient()` coba 4 cara berurutan — (1) `recipient` adalah `userId` langsung, (2) `recipient` adalah contract address langsung, (3) `recipient` adalah nama kontak terdaftar (lookup via `contactStore` → `accountRef`), (4) fallback ke `DEMO_RECEIVER_CONTRACT`. Ini konsisten dengan fitur contacts yang juga ditambahkan di luar rencana sprint (lihat S1-03).

Pola transfer-nya: `SACClient.getSACClient(USDC_SAC_ADDRESS).transfer({from, to, amount})` menghasilkan `AssembledTransaction`, ditandatangani via `kit.sign(tx)` (bukan `passkeyServer.buildTransferTx()` seperti pseudocode — method itu tidak ada). Challenge diambil dari `bridge.getAuthenticationOptions()` setelah `waitForBridge()`, sama pola dua-request seperti S1-04.

`USDC_SAC_ADDRESS` sekarang **dihitung dari `USDC_ISSUER`** (`Asset.contractId()`), bukan hardcode — sempat ditemukan hardcode ke contract ID yang **terbukti tidak valid** (format ID salah, RPC menolak dengan "Invalid contract ID") sebelum diperbaiki. Diverifikasi ulang live exist di testnet.

**Konteks (asli, untuk referensi historis):**  
~~Endpoint ini membangun transaksi Soroban (invoke SAC transfer antara dua smart wallet) dan mengembalikan **signature payload (challenge)** yang perlu ditandatangani via passkey. Challenge inilah yang dikirim ke `passkeys.authenticate()` di Flutter — harus dalam format base64url yang identik dengan yang diverifikasi `__check_auth` contract.~~ (bagian soal base64url tetap berlaku, lihat S2-04)

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

**Implementasi (pseudocode asli — lihat catatan di atas untuk perbedaan dengan `backend/src/index.ts`):**

```typescript
// PSEUDOCODE LAMA — passkeyServer.buildTransferTx() tidak ada di API asli.
// Lihat backend/src/index.ts untuk kode asli (SACClient.transfer() + kit.sign()).
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
- [x] Endpoint mengembalikan `{txId, challenge, credentialIds}` dengan format benar — dikonfirmasi lewat code review, `tsc` clean
- [x] `challenge` adalah string base64url (verifikasi: tidak ada `=` padding, hanya chars `A-Za-z0-9-_`) — lihat S2-04
- [x] `credentialIds` adalah array dari credential ID passkey sender — `senderRecord.credentialIds` dikembalikan langsung
- [x] Tx tersimpan (di `txStore`, berisi `signPromise`/`userId`/`amountIdr`/`counterpartyName` — bukan raw `xdr`/`challenge` seperti pseudocode, karena `kit.sign()` mengembalikan Promise yang di-resolve via bridge, bukan XDR string langsung)
- [x] Request dengan `userId` tidak dikenal mengembalikan HTTP 404 — ada di kode

---

## S2-02 — Implement `POST /tx/submit`

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S2-01

**Update (2026-07-16):** Endpoint sudah diimplementasikan dengan benar secara struktur, tapi statusnya `ON GOING` — **blocker sama persis dengan S1-05**: `srv.send(signedTx)` (`PasskeyServer.send()`) selalu butuh `relayer` terkonfigurasi (OpenZeppelin Channels), bukan Launchtube. Tanpa `RELAYER_API_KEY` di Railway, endpoint ini **selalu** gagal submit — bedanya dengan `/wallet/create`, endpoint ini **sudah benar** mengecek `submitResult.success` dan return HTTP 500 kalau gagal (tidak seperti `/wallet/create` yang lanjut walau gagal). Jadi kalau relayer belum terkonfigurasi, error-nya setidaknya jujur di endpoint ini.

**Fitur tambahan di luar rencana sprint** (ditemukan saat audit, bukan sesuatu yang perlu dikerjakan lagi): setelah `submitResult.success`, kode sekarang juga (a) refresh `userRecord.balanceUsd` via `getUsdcBalance()` — query on-chain asli, bukan asumsi, dan (b) catat transaksi ke `transactionStore` (untuk riwayat/`recentTransactions` di `/home/:userId/feed`). Response juga mengembalikan `txHash` selain `txId` (field ekstra, tidak masalah — Flutter cuma baca `txId`).

**Konteks (asli, untuk referensi historis — "submit via Launchtube" TIDAK akurat):**  
~~Endpoint ini menerima assertion WebAuthn dari Flutter, merakit auth entry Soroban (signature + public key + authenticatorData + clientDataJSON), menempelkannya ke tx XDR yang sudah dibangun di S2-01, lalu submit via Launchtube. Ini adalah titik paling teknis dalam seluruh codebase.~~ (bagian "titik paling teknis" tetap relevan — cuma penyebabnya beda: bukan soal encoding auth entry, tapi soal relayer)

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

**Implementasi (pseudocode asli — lihat catatan di atas untuk perbedaan dengan `backend/src/index.ts`):**

```typescript
// PSEUDOCODE LAMA — passkeyServer.submitSignedTx() dan "Launchtube" tidak ada.
// Lihat backend/src/index.ts (bridge.completeAuthentication() + srv.send() via relayer).
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
- [ ] Setelah POST ke endpoint ini, transaksi bisa dilihat di Stellar Testnet Explorer — **blocking**: butuh `RELAYER_API_KEY` + device fisik untuk assertion asli
- [x] Endpoint mengembalikan `{txId, txHash}` dengan HTTP 200 — kode benar, field ekstra `txHash` tidak masalah
- [x] Tx dihapus dari `txStore` setelah submit — `txStore.delete(txId)` ada di kode
- [x] ~~Error Launchtube~~ Error relayer (`RELAYER_NOT_CONFIGURED`, dll — OpenZeppelin Channels) ditangani dengan HTTP 500 + pesan — kode sudah benar cek `submitResult.success` sebelum lanjut

**Catatan risiko (update 2026-07-16):**
- ~~Encoding mismatch~~ — sudah diverifikasi **bukan masalah** di titik ini, lihat S2-04. `assertion.signature`/`authenticatorData`/`clientDataJSON` diteruskan langsung ke `bridge.completeAuthentication()` tanpa transformasi tambahan di kode.
- Bila tx gagal, penyebab paling mungkin **bukan** "auth entry invalid" seperti dugaan asli, tapi `RELAYER_NOT_CONFIGURED` — cek `RELAYER_API_KEY` dulu sebelum curiga ke encoding.

---

## S2-03 — Implement `GET /wallet/:userId/balance`

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat  
**Dependencies:** S1-03 (store), S1-05 (wallet created)

**Update (2026-07-16):** Diimplementasikan dengan benar — dan menghindari jebakan yang pseudocode-nya sendiri sudah curigai ("Alternatif MVP: gunakan Horizon... hanya works kalau smart wallet punya classic account backing" — ini salah untuk smart contract wallet, Horizon **tidak bisa** query saldo SAC contract secara langsung). Implementasi asli (`getUsdcBalance()` di `backend/src/passkey.ts`) pakai jalur yang benar: `SACClient.getSACClient(...).balance({id: contractAddress})` lewat **Soroban RPC** (`AssembledTransaction.simulate()`), bukan Horizon sama sekali. Ini query on-chain asli tiap request, bukan cuma baca cache — konsisten dipakai juga di `/home/:userId/feed` dan setelah `/tx/submit` sukses (S2-08).

**Riwayat bug terkait (sudah diperbaiki, dicatat untuk konteks):** wallet baru sempat selalu menampilkan saldo `0` karena `/wallet/create` hardcode `balanceUsd: 0` dan tidak pernah diperbarui — bukan karena endpoint balance ini salah, tapi karena tidak ada mekanisme funding sama sekali (USDC_ISSUER adalah issuer testnet resmi Circle, bukan milik kita, jadi tidak bisa mint). Solusi: `POST /wallet/:userId/fund` (fitur baru, di luar rencana sprint manapun) transfer dari akun yang di-fund via `faucet.circle.com`. Lihat `NEXT_STEPS.md` §1b.

**Konteks (asli, untuk referensi historis):**  
~~Flutter memanggil endpoint ini setelah `SendSuccessScreen` untuk memperbarui saldo di HomeScreen. Saldo diambil langsung dari Stellar (Soroban RPC / Horizon) agar real-time, bukan dari cache.~~ (bagian "Soroban RPC" benar, "Horizon" salah — lihat koreksi di atas)

**Contract (dari `docs/Flutter-Boilerplate-README.md` §8):**
```
GET /wallet/:userId/balance
Response: { balanceUsd: number }
```

**Implementasi (pseudocode asli — Horizon-based, TIDAK dipakai di implementasi aktual, lihat catatan di atas):**

```typescript
// PSEUDOCODE LAMA — pakai Horizon, tidak works untuk smart contract wallet.
// Implementasi asli: backend/src/passkey.ts getUsdcBalance() via Soroban RPC.
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
- [x] `GET /wallet/<userId>/balance` mengembalikan `{balanceUsd: <number>}` — kode benar, `tsc` clean
- [x] Nilai berubah setelah transaksi kirim berhasil — `/tx/submit` panggil `getUsdcBalance()` ulang setelah settle, jadi angka berikutnya otomatis real
- [x] Error RPC menggunakan cached balance (tidak crash) — try/catch dengan fallback ke `userRecord.balanceUsd` ada di kode

---

## S2-04 — Verifikasi challenge encoding base64url

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S2-01, S2-02

**Update (2026-07-16):** Sudah diverifikasi — bukan cuma baca kode, tapi dites empiris. Temuan:
- `passkey-kit`'s `generateChallenge()` (dipakai internal oleh `kit.createWallet()`/`kit.sign()`) **sudah menghasilkan base64url** dari sononya (`base64url.encode(Buffer.from(bytes))`, dikonfirmasi dari `node_modules/passkey-kit/dist/utils.js`).
- Kode backend (`Buffer.from(challenge, "base64").toString("base64url")`) **terlihat redundan** (decode base64 lalu re-encode base64url dari sesuatu yang sudah base64url) — tapi dites lewat script Node dengan data acak: hasilnya **byte-identik**, round-trip aman. Node's base64 decoder ternyata toleran ke karakter `-`/`_` (base64url), jadi konversi ini secara fungsional no-op, bukan bug.
- Frontend (`passkey_service.dart`) meneruskan `challengeB64Url` apa adanya ke native `passkeys.register()`/`authenticate()`, tidak ada transformasi encoding tambahan — sesuai checklist item 2 di bawah.
- **Yang TIDAK bisa diverifikasi dari sini**: perilaku `clientDataJSON.challenge` di level native OS (iOS/Android Credential Manager) — ini genuinely butuh device fisik untuk generate assertion asli dan dibandingkan byte-per-byte (checklist item 3/4 di bawah).

**Konteks (asli, untuk referensi historis — masih berlaku sebagai deskripsi risiko, walau ternyata tidak termanifestasi jadi bug):**  
~~Ini adalah **titik paling rawan bug** dalam seluruh alur. `challenge` yang dihasilkan `/tx/build` harus identik (byte-untuk-byte, encoding-untuk-encoding) dengan signature payload yang diverifikasi `__check_auth` di contract. Satu perbedaan encoding = verifikasi gagal tanpa pesan error yang jelas.~~

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
- [x] Script test challenge menunjukkan semua assertion `true` — dijalankan dengan data acak, round-trip byte-identik
- [x] Challenge dari `/tx/build` tidak mengandung `+`, `/`, atau `=` — dikonfirmasi dari `generateChallenge()` source, sudah base64url murni
- [ ] `clientDataJSON.challenge` dalam assertion identik dengan challenge yang dikirim (setelah decode JSON) — **butuh device fisik**, tidak bisa dites dari sini (perlu assertion asli dari native WebAuthn ceremony)
- [ ] Tx submit tidak gagal dengan error "invalid signature" atau "auth failed" — sama, butuh device fisik + `RELAYER_API_KEY` terkonfigurasi (S2-02)

---

## S2-05 — ~~E2E test kirim uang di iOS device fisik~~ (SKIPPED)

**Status:** `SKIPPED` | **Prioritas:** ~~P0~~ | **Tipe:** test  
**Dependencies:** S2-01, S2-02, S2-03, S2-04

**Keputusan (2026-07-16):** iOS di-skip permanen, sama alasan dengan S1-06 — kendala biaya Apple Developer Program. Demo Android-only.

**Konteks (asli, untuk referensi historis):**  
~~Test end-to-end penuh alur kirim uang dari device iOS. Ini adalah **demo money-shot #2**.~~

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
- [x] ~~`FeeBreakdownCard` menampilkan nilai yang benar~~ — N/A, di-skip
- [x] ~~Face ID muncul saat tap "Konfirmasi"~~ — N/A, di-skip
- [x] ~~`SendSuccessScreen` menampilkan nama dan nominal yang benar~~ — N/A, di-skip
- [x] ~~HomeScreen saldo berkurang sesuai nominal kirim~~ — N/A, di-skip
- [x] ~~Transaksi bisa dilihat di Stellar Expert testnet~~ — N/A, di-skip

---

## S2-06 — E2E test kirim uang di Android device fisik

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S2-01, S2-02, S2-03, S2-04, dan S1-07 (harus ada wallet ter-deploy dulu sebelum bisa kirim uang darinya)

**Update (2026-07-16):** Belum bisa dijalankan dari environment kerja Claude — sama seperti S1-07, genuinely butuh device fisik. Prasyarat sebelum dites (selain yang sudah dicatat di S1-07):
1. Minimal 1 wallet sudah berhasil onboarding (S1-07 lolos duluan) — S2-06 tidak bisa dites berdiri sendiri tanpa wallet pengirim yang nyata.
2. Wallet pengirim itu punya saldo USDC > 0 — lihat `NEXT_STEPS.md` §1b (`POST /wallet/:userId/fund`), karena wallet baru selalu mulai dari 0.
3. Ada penerima: minimal 1 wallet lain terdaftar di store (device kedua/onboarding kedua), atau `DEMO_RECEIVER_CONTRACT` terisi di Railway (lihat S2-10).

**Konteks (asli):**  
~~Test yang sama di Android.~~ (masih berlaku)

**Langkah:**
Sama dengan S2-05, di Android device fisik.

**Acceptance criteria:**
- [ ] Fingerprint/biometrik Android muncul saat konfirmasi
- [ ] `SendSuccessScreen` menampilkan data benar
- [ ] Transaksi settle di Stellar Testnet

---

## S2-07 — Verifikasi transaksi di Stellar Expert

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore  
**Dependencies:** ~~S2-05 atau~~ S2-06 (S2-05/iOS di-skip permanen)

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

**Status:** `ON GOING` | **Prioritas:** P1 | **Tipe:** test  
**Dependencies:** S2-03, ~~S2-05~~ S2-06 (S2-05/iOS di-skip permanen)

**Update (2026-07-16):** Kode di kedua sisi sudah diverifikasi benar via code review:
- **Frontend** (`frontend/lib/state/send_controller.dart` `confirmAndSend()`): setelah `api.submitSignedTx()` sukses, memanggil `api.getBalanceUsd(wallet.userId)` lalu `ref.read(authControllerProvider.notifier).updateBalance(bal)` — persis seperti dugaan konteks asli.
- **Backend** (`backend/src/index.ts` `/tx/submit`): setelah `submitResult.success`, memanggil `getUsdcBalance()` (query Soroban RPC asli) dan update `userRecord.balanceUsd` sebelum tercatat di `transactionStore`.

Yang masih genuinely `TODO`: **verifikasi live di device** bahwa angka yang tampil di layar benar-benar berubah setelah kirim sungguhan — code review tidak bisa membuktikan UI benar-benar re-render dengan angka baru.

**Konteks (asli, untuk referensi historis — masih akurat, cuma statusnya "belum dites" bukan "belum diimplementasi"):**  
Setelah kirim berhasil, `AuthController.updateBalance()` dipanggil oleh `SendController`. HomeScreen harus menampilkan saldo terbaru.

**Langkah:**
1. Catat saldo di HomeScreen sebelum kirim.
2. Kirim Rp 100.000 (~$6,12).
3. Kembali ke HomeScreen → catat saldo baru.
4. Verifikasi: selisih sesuai (amountIdr / rate ≈ amountUsd).

**Acceptance criteria:**
- [ ] Saldo HomeScreen berkurang setelah transaksi berhasil — kode benar (lihat Update), belum dites live
- [ ] Selisih sesuai dengan nominal yang dikirim (±1 Rp karena pembulatan) — belum dites live

---

## S2-09 — Test error states send flow

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test  
**Dependencies:** ~~S2-05~~ S2-06 (S2-05/iOS di-skip permanen)

**Update (2026-07-16):** Ditemukan & diperbaiki 1 gap konkret lewat code review (baris "Saldo tidak cukup" di tabel bawah): `/tx/build` sebelumnya **tidak mengecek saldo sender sama sekali** sebelum bangun transaksi transfer. Kirim nominal > saldo akan gagal di simulasi Soroban di dalam try/catch dan keluar sebagai error generic `500 "Gagal membangun transaksi"` — bukan pesan jelas seperti yang diharapkan tabel skenario. **Sudah diperbaiki**: `/tx/build` sekarang cek `getUsdcBalance()` dulu, balas `400 {"error": "Saldo tidak cukup"}` kalau kurang, sebelum sempat bangun tx sama sekali. `tsc` clean, `pnpm test` 6/6 pass.

3 skenario lain (cancel biometrik, network error saat build/submit) sudah punya penanganan di level Flutter (`_guard()` di `wallet_api.dart` + `_error()` di `send_controller.dart`) — belum ada perubahan kode baru untuk ini, tapi juga tidak ditemukan gap seperti "Saldo tidak cukup" di atas. Semua 4 skenario tetap butuh **verifikasi live di device** untuk konfirmasi Snackbar benar-benar muncul dengan teks yang tepat.

**Skenario yang diuji:**

| Skenario | Cara memicu | Expected UI |
|----------|------------|-------------|
| User cancel biometrik saat konfirmasi | Tap cancel di Face ID prompt | Kembali ke `SendReviewScreen`, Snackbar error |
| Network error saat `/tx/build` | Matikan internet sebelum tap "Kirim" | Snackbar: "Gagal memproses. Coba lagi." |
| Network error saat `/tx/submit` | Matikan internet setelah Face ID | Snackbar: pesan error |
| Saldo tidak cukup | Kirim nominal > saldo | Backend error 4xx → Snackbar pesan — **sudah diperbaiki, backend sekarang balas 400 "Saldo tidak cukup" secara eksplisit** |

**Acceptance criteria:**
- [ ] Semua skenario menghasilkan Snackbar, bukan crash — belum dites live
- [ ] Setelah error, user bisa kembali ke HomeScreen atau coba lagi — belum dites live
- [ ] `SendPhase` kembali ke `error` → UI tidak stuck di "Mengirim…" — belum dites live

---

## S2-10 — Setup penerima demo hardcoded

**Status:** `ON GOING` | **Prioritas:** P2 | **Tipe:** feat  
**Dependencies:** S1-05

**Update (2026-07-16):**
- **Backend (langkah 1 & 3): sudah selesai**, malah lebih canggih dari rencana. `backend/.env.example` sudah punya `DEMO_RECEIVER_CONTRACT`, dan `/tx/build` sudah fallback ke situ via `resolveRecipient()` (lihat S2-01) — bahkan sebelum fallback demo receiver, dicoba dulu cari user lain yang cocok di store atau kontak by name, jadi tidak selalu "kirim ke nama apapun = demo receiver" seperti draft awal, tapi tetap fallback ke situ kalau tidak ketemu manapun.
- **Langkah 2 (isi `DEMO_RECEIVER_CONTRACT` di Railway dengan contract address asli): belum bisa dilakukan** — ini butuh wallet demo-receiver benar-benar sudah dibuat lewat app (passkey ceremony asli), yang belum pernah terjadi karena belum ada testing di device fisik sama sekali (S1-07 masih `TODO`). Chicken-and-egg: butuh device test dulu untuk dapat contract address, baru bisa isi env var ini.
- **Langkah 4 (opsional, `POST /wallet/register-demo`): tidak diimplementasikan** — memang ditandai opsional di rencana asli, dan skip aman karena `resolveRecipient()` sudah cukup fleksibel tanpa endpoint tambahan ini.
- **Acceptance criteria kedua ("ReceiveScreen menampilkan mock off-ramp yang sesuai"): ditemukan gap & diperbaiki.** `frontend/lib/screens/receive_screen.dart` ternyata **statis penuh dalam Bahasa Inggris** ("Receive", "Share details", "Scan this to send me money", "Account •••• 4821") — tidak menyebut Rupiah/rekening/off-ramp sama sekali, dan melanggar prinsip invisible-crypto copy Bahasa Indonesia (S4-01/S4-03). Sudah diperbaiki: "Terima", "Bagikan detail", "Pindai untuk kirim uang ke saya", label "Rekening tujuan" dengan value `BCA •••• 4821` (sesuai contoh "BCA ****1234" di konteks asli issue ini). Perubahan murni string literal, tidak ada perubahan struktur widget — **belum divalidasi `flutter analyze`/`dart analyze`** karena Flutter SDK tidak tersedia di environment ini, tapi risikonya rendah (bukan perubahan logic/tipe).

**Konteks (asli, untuk referensi historis):**  
~~Untuk demo panggung, penerima bisa hardcoded sebagai "BCA ****1234" (mock off-ramp yang sudah ada di `ReceiveScreen`). Backend perlu tahu contract address penerima demo tanpa user harus input address panjang.~~ (masih akurat sebagai tujuan, "sudah ada di ReceiveScreen" yang ternyata belum — baru ditambahkan sekarang)

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
- [ ] Kirim ke nama apapun → tx diroute ke demo receiver contract — kode benar, tapi `DEMO_RECEIVER_CONTRACT` belum terisi nilai asli di Railway (lihat Update di atas)
- [x] `ReceiveScreen` menampilkan mock off-ramp yang sesuai — diperbaiki (lihat Update), copy Indonesia + "Rekening tujuan BCA •••• 4821"

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| 2026-07-16 | Audit menyeluruh: S2-01 s/d S2-04 sudah diimplementasikan (bareng Sprint 1, commit gabungan). Status & pseudocode direkonsiliasi dengan kode aktual, sama pola dengan Sprint 1. | Selesai (audit) |
| 2026-07-16 | Ditemukan & diperbaiki: `/tx/build` tidak pernah cek saldo sender sebelum bangun tx — "Saldo tidak cukup" (S2-09) sebelumnya keluar sebagai error 500 generic, bukan pesan jelas. Ditambahkan pre-check eksplisit. | Fixed |
| 2026-07-16 | Ditemukan & diperbaiki: `ReceiveScreen` (S2-10) 100% berbahasa Inggris dan tidak pernah menyebut off-ramp/Rupiah — melanggar prinsip invisible-crypto copy. Diperbaiki jadi Bahasa Indonesia dengan narasi "Rekening tujuan BCA •••• 4821". | Fixed (belum divalidasi `flutter analyze`) |
| 2026-07-16 | S2-02 diturunkan ke `ON GOING` — blocker sama dengan S1-05 (`RELAYER_API_KEY`/OpenZeppelin Channels belum terkonfirmasi jalan). | Koreksi kritis |

## Blockers & Catatan

**Bug yang ditemukan (update dari placeholder asli):**
1. ~~`challenge` encoding mismatch~~ — **sudah diverifikasi bukan masalah** (S2-04), lihat kronologi lengkap di `sprint/sprint-1-passkey-onboarding.md` § Blockers & Catatan.
2. **Passkey Kit API beda dari pseudocode** — sama seperti Sprint 1: `passkeyServer.buildTransferTx()`/`submitSignedTx()`/`getBalance()` di pseudocode tidak pernah ada. API asli: `SACClient.transfer()` + `kit.sign()` (S2-01), `srv.send()` via relayer (S2-02), `getUsdcBalance()` via Soroban RPC langsung, bukan Horizon (S2-03).
3. ~~Launchtube rate limit~~ — **tidak relevan**, Launchtube tidak dipakai sama sekali (S0-11). Kapasitas yang perlu diperhatikan sekarang: rate limit/fee limit OpenZeppelin Channels testnet (belum pernah diuji volumenya, kemungkinan cukup untuk demo tapi belum diverifikasi).

**Blocker aktif:** sama seperti Sprint 1 — `RELAYER_API_KEY` (S2-02) dan wallet asli dari device fisik (S2-06 dst.) adalah dua prasyarat yang menghalangi hampir semua item testing di sprint ini. Kode backend sudah dianggap selesai secara struktur; sisanya murni menunggu akses eksternal (Railway dashboard, device fisik) yang tidak tersedia di environment kerja ini.
