# Sprint 3 — Integration Testing

## Tujuan Sprint

Memastikan Flutter frontend terhubung dengan benar ke backend real (bukan mock), semua screen menampilkan data dari API yang sesungguhnya, dan seluruh alur bisa dijalankan end-to-end di kedua device fisik (iOS + Android) tanpa panduan teknis.

Sprint ini selesai bila **seseorang yang belum tahu teknis bisa menjalankan demo sendiri** dari awal (onboarding) sampai akhir (receive screen) di kedua platform.

## Definition of Done

- [ ] `OnboardingScreen` → `HomeScreen` dengan saldo real dari API
- [ ] `SendAmountScreen` → `FeeBreakdownCard` dengan nilai akurat real-time
- [ ] `SendReviewScreen` → Face ID → `SendSuccessScreen` dengan nama & nominal real
- [ ] `HomeScreen` saldo terupdate setelah kirim
- [ ] `ReceiveScreen` (mock) berjalan lancar sebagai layar demo penerima
- [ ] Semua contract API mismatches (field name, tipe data, encoding) sudah diperbaiki
- [ ] Tidak ada istilah crypto, contract address, atau jargon teknis yang bocor ke UI
- [ ] Error states menampilkan pesan Bahasa Indonesia yang ramah user
- [ ] Demo bisa dijalankan berulang kali tanpa perlu restart backend

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S3-01](#s3-01--audit-api-contract-flutter-vs-backend) | Audit API contract Flutter vs backend | `TODO` | P0 |
| [S3-02](#s3-02--fix-field-name-mismatches) | Fix field name/type mismatches | `TODO` | P0 |
| [S3-03](#s3-03--test-full-flow-onboarding--kirim-di-ios) | Test full flow (onboarding + kirim) di iOS | `TODO` | P0 |
| [S3-04](#s3-04--test-full-flow-onboarding--kirim-di-android) | Test full flow (onboarding + kirim) di Android | `TODO` | P0 |
| [S3-05](#s3-05--verifikasi-homescreen-saldo-tampil-rupiah) | Verifikasi HomeScreen saldo tampil Rupiah | `TODO` | P0 |
| [S3-06](#s3-06--verifikasi-feebreakdowncard-dengan-data-real) | Verifikasi `FeeBreakdownCard` dengan data real | `TODO` | P0 |
| [S3-07](#s3-07--verifikasi-sendsuccess-dengan-data-real) | Verifikasi `SendSuccessScreen` dengan data real | `TODO` | P0 |
| [S3-08](#s3-08--test-demo-penerima-receive-screen) | Test demo penerima (ReceiveScreen) | `TODO` | P1 |
| [S3-09](#s3-09--test-repeat-send-tanpa-restart-backend) | Test repeat send tanpa restart backend | `TODO` | P1 |
| [S3-10](#s3-10--audit-invisible-crypto-checklist-awal) | Audit invisible-crypto checklist awal | `TODO` | P1 |
| [S3-11](#s3-11--test-skenario-testnet-flaky) | Test skenario testnet flaky | `TODO` | P2 |

---

## S3-01 — Audit API contract Flutter vs backend

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Konteks:**  
Frontend (Flutter) dan backend dibangun bersama tapi mungkin punya perbedaan kecil di nama field, tipe data, atau format. Issue ini memetakan semua potensi mismatch sebelum testing agar debugging lebih cepat.

**Checklist audit per endpoint:**

### `GET /passkey/register-options`
| Field | Flutter expects | Backend returns | Match? |
|-------|----------------|-----------------|--------|
| `challenge` | `String` (base64url) | `string` | — |
| `userId` | `String` | `string` | — |

### `POST /wallet/create`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `userId` | `String` | `string` | — |
| `attestation.credentialId` | `String` | `string` | — |
| `attestation.clientDataJSON` | `String` (base64url) | `string` | — |
| `attestation.attestationObject` | `String` (base64url) | `string` | — |

Cek `PasskeyAttestation.toJson()` di `frontend/lib/models/models.dart` → field `'credentialId'`, `'clientDataJSON'`, `'attestationObject'`. Backend harus menggunakan nama field yang sama persis (case-sensitive).

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `userId` | `string` | `json['userId'] as String` | — |
| `contractAddress` | `string` | `json['contractAddress'] as String` | — |
| `balanceUsd` | `number` | `(json['balanceUsd'] as num).toDouble()` | — |

### `POST /tx/build`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `userId` | `String` | `string` | — |
| `recipient` | `String` (nama) | `string` | — |
| `amountUsd` | `double` | `number` | — |

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `txId` | `string` | `r.data['txId'] as String` | — |
| `challenge` | `string` (base64url) | `r.data['challenge'] as String` | — |
| `credentialIds` | `string[]` | `(r.data['credentialIds'] as List).cast<String>()` | — |

### `POST /tx/submit`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `txId` | `String` | `string` | — |
| `assertion.credentialId` | `String` | `string` | — |
| `assertion.clientDataJSON` | `String` | `string` | — |
| `assertion.authenticatorData` | `String` | `string` | — |
| `assertion.signature` | `String` | `string` | — |

Cek `PasskeyAssertion.toJson()` di models.dart → field `'credentialId'`, `'clientDataJSON'`, `'authenticatorData'`, `'signature'`.

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `txId` | `string` | `r.data['txId'] as String?` (nullable, dengan fallback) | — |

### `GET /wallet/:userId/balance`
| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `balanceUsd` | `number` | `(r.data['balanceUsd'] as num).toDouble()` | — |

**File yang diubah/dibuat:**
- Audit ini menghasilkan daftar mismatch yang menjadi input untuk S3-02

**Acceptance criteria:**
- [ ] Tabel audit di atas terisi semua (Match: ✓ atau ✗)
- [ ] Semua mismatch terdokumentasi di Sprint Log sebelum S3-02 dimulai

---

## S3-02 — Fix field name/type mismatches

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** fix  
**Dependencies:** S3-01

**Konteks:**  
Perbaiki semua mismatch yang ditemukan di S3-01. Preferensi: sesuaikan backend ke kontrak yang sudah ada di Flutter (karena Flutter sudah punya kontrak yang didokumentasikan di `docs/Flutter-Boilerplate-README.md` §8).

**Langkah:**
1. Untuk setiap mismatch di S3-01:
   - Jika nama field berbeda: update backend untuk menggunakan nama field yang sama dengan yang di-expect Flutter
   - Jika tipe data berbeda: update parser di backend atau Flutter
   - Jika encoding berbeda: align ke base64url di kedua sisi

2. Khusus untuk `PasskeyAttestation.toJson()` dan `PasskeyAssertion.toJson()` di Flutter:
   - Verifikasi nama field JSON key sesuai dengan yang di-expect backend
   - Jika tidak: update `toJson()` di `frontend/lib/models/models.dart`

3. Setelah fix, jalankan `flutter analyze` untuk memastikan tidak ada error compile.

**File yang mungkin diubah:**
- `backend/src/index.ts` — update field names di request parsing atau response
- `frontend/lib/models/models.dart` — update `toJson()` key names bila perlu

**Acceptance criteria:**
- [ ] `flutter analyze` di `frontend/` tidak ada error
- [ ] Backend `npm run build` tidak ada TypeScript error
- [ ] Tidak ada mismatch tersisa di tabel S3-01

---

## S3-03 — Test full flow (onboarding + kirim) di iOS

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S3-01, S3-02

**Konteks:**  
Test end-to-end satu sesi penuh dari fresh install (hapus app dulu) di iOS.

**Skenario test:**
1. **Fresh install:** Hapus app dari iOS device → install ulang
2. **Onboarding:** Splash → OnboardingScreen → tap "Buat akun dengan Face ID" → Face ID muncul → sukses → HomeScreen
3. **Cek saldo:** Saldo muncul dalam Rupiah (Rp X,XXX,XXX)
4. **Kirim:** Tap "Kirim" → input nama "BCA 1234" + nominal Rp 100.000 → "Keluarga terima Rp 99.500" live
5. **Review:** Tap "Lanjut" → SendReviewScreen dengan FeeBreakdownCard lengkap
6. **Konfirmasi:** Tap "Kirim sekarang" → bottom sheet → "Konfirmasi dengan Face ID" → Face ID → ~5 detik tunggu → SendSuccessScreen
7. **Sukses:** "Uang terkirim. BCA 1234 menerima Rp 99.500."
8. **Kembali:** Tap "Selesai" → HomeScreen dengan saldo berkurang

**Acceptance criteria:**
- [ ] Semua 8 langkah selesai tanpa error/crash
- [ ] Tidak ada istilah crypto yang muncul di layar manapun
- [ ] Waktu dari tap "Kirim sekarang" ke SendSuccessScreen ≤ 10 detik (testnet boleh lebih lambat dari 5 detik mainnet)
- [ ] Saldo berkurang sesuai nominal

---

## S3-04 — Test full flow (onboarding + kirim) di Android

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S3-01, S3-02

**Konteks:**  
Test yang sama di Android device fisik.

**Acceptance criteria:**
Sama dengan S3-03, di Android.

---

## S3-05 — Verifikasi HomeScreen saldo tampil Rupiah

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test

**Konteks:**  
Saldo dari backend dalam USD. Flutter mengkonversi ke Rupiah via `usdToIdr()`. Verifikasi konversi benar dan format tampil benar.

**Langkah:**
1. Cek `HomeScreen.build()` di `frontend/lib/screens/home_screen.dart`
2. `balanceIdr = usdToIdr(wallet?.balanceUsd ?? 0)` → harus menggunakan `Env.usdToIdr = 16350.0`
3. `formatMoney(balanceIdr, Currency.idr)` → harus menampilkan format "Rp 1.000.000" (titik sebagai pemisah ribuan)

**Test cases:**
| `balanceUsd` dari backend | Expected di HomeScreen |
|--------------------------|----------------------|
| 0.0 | Rp 0 |
| 1.0 | Rp 16.350 |
| 61.16 | Rp 999.972 |
| 100.0 | Rp 1.635.000 |

**Acceptance criteria:**
- [ ] Format Rupiah benar (pemisah ribuan, tidak ada "USDC", tidak ada desimal)
- [ ] Nilai konsisten dengan kurs `Env.usdToIdr`

---

## S3-06 — Verifikasi `FeeBreakdownCard` dengan data real

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test

**Konteks:**  
`FeeBreakdownCard` adalah signature element produk — muncul SEBELUM konfirmasi dan menampilkan transparansi biaya. Pastikan nilai yang ditampilkan akurat.

**Langkah:**
1. Di `SendAmountScreen`: input Rp 1.000.000
2. Verifikasi preview real-time: "Keluarga terima Rp 995.000"
3. Tap "Lanjut" → `SendReviewScreen`
4. Verifikasi `FeeBreakdownCard` menampilkan:
   - "Kamu kirim: Rp 1.000.000"
   - "Biaya layanan (0,5%): - Rp 5.000"
   - "Keluarga terima: Rp 995.000" (highlighted green)

**Formula yang diverifikasi:**
```
fee = floor(amountIdr * 0.005) = floor(1.000.000 * 0.005) = 5.000
receiveIdr = amountIdr - fee = 1.000.000 - 5.000 = 995.000
```

**Acceptance criteria:**
- [ ] Semua 3 baris `FeeBreakdownCard` akurat dengan formula di atas
- [ ] Baris "Keluarga terima" berwarna hijau (`AppColors.success`)
- [ ] Tidak ada nilai "0" yang ter-display sebelum user input nominal

---

## S3-07 — Verifikasi `SendSuccessScreen` dengan data real

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test

**Konteks:**  
`SendSuccessScreen` menampilkan data dari `AppTransaction` yang dikembalikan backend. Verifikasi bahwa nama penerima dan nominal `receiveIdr` tampil benar (bukan nilai mock atau kosong).

**Langkah:**
1. Kirim Rp 500.000 ke nama "Mama Sunarsih"
2. Di `SendSuccessScreen` verifikasi:
   - Heading: "Uang terkirim"
   - Body: "Mama Sunarsih menerima Rp 497.500."
   - Icon centang hijau

**Acceptance criteria:**
- [ ] Nama penerima tampil sesuai yang diinput
- [ ] Nominal tampil adalah `receiveIdr` (setelah dipotong biaya), bukan `amountIdr`
- [ ] Format Rupiah benar

---

## S3-08 — Test demo penerima (ReceiveScreen)

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test

**Konteks:**  
`ReceiveScreen` adalah layar mock off-ramp untuk demo — "sisi penerima" yang ditampilkan di HP kedua saat demo panggung. Pastikan layar ini accessible dan tampil benar.

**Cara mengakses `ReceiveScreen`:**
- Di `HomeScreen` → tap **Terima**

**Langkah:**
1. Akses ReceiveScreen dari HomeScreen
2. Verifikasi:
   - Icon "Rp 995.000 masuk" tampil
   - "ke rekening BCA ****1234"
   - Card "Dana tersedia untuk ditarik sekarang."
   - Button "Kembali ke beranda"
3. Tap "Kembali ke beranda" → kembali ke HomeScreen

**Catatan untuk demo:** Untuk demo panggung, ini ditampilkan di HP kedua (device Android sebagai penerima, iOS sebagai pengirim atau sebaliknya). Pastikan nilai mock (`receivedIdr = 995000.0`) cocok dengan nilai yang dikirim dari HP pengirim.

**Acceptance criteria:**
- [ ] `ReceiveScreen` accessible dari HomeScreen
- [ ] Semua elemen tampil tanpa overflow atau clip
- [ ] Tidak ada istilah crypto
- [ ] Back button berfungsi

---

## S3-09 — Test repeat send tanpa restart backend

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** test

**Konteks:**  
Selama demo, mungkin perlu kirim uang lebih dari sekali (demo ulang, error recovery). Verifikasi bahwa alur bisa diulang tanpa perlu restart backend atau reinstall app.

**Langkah:**
1. Kirim uang pertama → sukses
2. Dari HomeScreen → kirim uang kedua → sukses
3. Kirim uang ketiga → sukses
4. Verifikasi: tidak ada state yang "stuck" dari transaksi sebelumnya

**Acceptance criteria:**
- [ ] 3 transaksi berturut-turut berhasil tanpa restart
- [ ] `SendController.reset()` dipanggil dengan benar setelah setiap transaksi (cek `sendSuccess` → tap "Selesai")
- [ ] `txStore` tidak accumulate pending tx yang expired

---

## S3-10 — Audit invisible-crypto checklist awal

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore

**Konteks:**  
Lakukan audit awal checklist "Invisible Crypto" dari `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §4 sebelum sprint polish. Temuan di sini menjadi input untuk Sprint 4.

**Checklist (dari build plan §4):**

| Item | Status | Catatan |
|------|--------|---------|
| Tidak ada input/tampilan seed phrase | — | |
| Tidak ada private/public key / RP ID / contract address | — | |
| Tidak ada kata "gas" / "XLM" | — | |
| Saldo & nominal selalu dalam $ atau Rp | — | |
| Sign transaksi = biometrik native | — | |
| Onboarding < 30 detik, < 3 tap | — | |
| Penerima tidak pernah lihat istilah crypto | — | |
| Rincian biaya transparan SEBELUM konfirmasi | — | |
| Copy familiar: "kirim uang", "saldo", "biaya" | — | |
| Icon app / splash terasa aplikasi keuangan | — | |

**Acceptance criteria:**
- [ ] Semua 10 item di atas sudah diperiksa dan diisi statusnya
- [ ] Item yang belum ✓ menjadi issue di Sprint 4

---

## S3-11 — Test skenario testnet flaky

**Status:** `TODO` | **Prioritas:** P2 | **Tipe:** test

**Konteks:**  
Stellar Testnet kadang slow atau unreachable. Verifikasi bahwa UI tetap responsif dan tidak freeze saat RPC lambat.

**Skenario:**
1. Kurangi koneksi internet ke lambat (throttle di dev tools / hotspot)
2. Lakukan transaksi → verifikasi loading state tampil
3. Matikan internet di tengah `submitting` → verifikasi error state (bukan freeze)

**Acceptance criteria:**
- [ ] Saat `submitting`, spinner muncul di tombol ("Mengirim…")
- [ ] Saat network timeout, Snackbar error muncul (bukan freeze abadi)
- [ ] User bisa coba ulang setelah error

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| | | |

## Blockers & Catatan

> _Dokumentasikan semua API mismatch yang ditemukan di S3-01 beserta resolusinya._
> 
> _Contoh format:_
> _- `credentialId` di Flutter → backend perlu `id` — FIX: update backend parse `req.body.assertion.credentialId`_
