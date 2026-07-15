# Sprint 3 — Integration Testing

## Tujuan Sprint

Memastikan Flutter frontend terhubung dengan benar ke backend real (bukan mock), semua screen menampilkan data dari API yang sesungguhnya, dan seluruh alur bisa dijalankan end-to-end di kedua device fisik (iOS + Android) tanpa panduan teknis.

Sprint ini selesai bila **seseorang yang belum tahu teknis bisa menjalankan demo sendiri** dari awal (onboarding) sampai akhir (receive screen) di kedua platform.

## Definition of Done

- [ ] `OnboardingScreen` → `HomeScreen` dengan saldo real dari API — kode benar (lihat S1/S2), belum pernah dites live di device
- [ ] `SendAmountScreen` → `FeeBreakdownCard` dengan nilai akurat real-time — kode benar, TAPI formula fee di dokumen ini **sudah tidak sesuai** (`Env.feeRate = 0.0`, bukan 0.5%), lihat S3-06
- [ ] `SendReviewScreen` → Face ID → `SendSuccessScreen` dengan nama & nominal real — belum dites live
- [x] `HomeScreen` saldo terupdate setelah kirim — kode di kedua sisi terverifikasi benar (lihat `sprint/sprint-2-send-flow.md` S2-08), live test masih pending
- [ ] `ReceiveScreen` (mock) berjalan lancar sebagai layar demo penerima — **gap ditemukan**: screen yang ada sekarang bukan screen "Rp X masuk" yang dideskripsikan di S3-08, lihat catatan di S3-08
- [x] Semua contract API mismatches (field name, tipe data, encoding) sudah diperbaiki — **audit selesai, hasilnya nol mismatch**, lihat S3-01
- [x] Tidak ada istilah crypto, contract address, atau jargon teknis yang bocor ke UI — audit grep `screens/`+`widgets/` sudah dijalankan, hasil bersih, lihat S3-10
- [ ] Error states menampilkan pesan Bahasa Indonesia yang ramah user — sebagian besar sudah ada di kode (`_guard()` di `wallet_api.dart`), belum dites live
- [ ] Demo bisa dijalankan berulang kali tanpa perlu restart backend — kode `reset()` ada, tapi `txStore` tidak punya TTL/expiry (lihat S3-09), belum masalah untuk skala demo

**Update (2026-07-16):** Audit S3-01 (yang paling penting di sprint ini) **sudah selesai dengan hasil nol mismatch** — kontrak data antara Flutter dan backend sudah cocok sejak awal. Yang jadi temuan justru dua hal di luar cakupan S3-01: formula fee di dokumen ini basi (S3-06/S3-07), dan `ReceiveScreen` bukan screen yang dideskripsikan sprint ini (S3-08) — keduanya butuh keputusan, bukan cuma eksekusi.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S3-01](#s3-01--audit-api-contract-flutter-vs-backend) | Audit API contract Flutter vs backend | `FINISHED` | P0 |
| [S3-02](#s3-02--fix-field-name-mismatches) | Fix field name/type mismatches | `FINISHED` (N/A — nol mismatch) | P0 |
| [S3-03](#s3-03--test-full-flow-onboarding--kirim-di-ios) | ~~Test full flow (onboarding + kirim) di iOS~~ | `SKIPPED` | ~~P0~~ |
| [S3-04](#s3-04--test-full-flow-onboarding--kirim-di-android) | Test full flow (onboarding + kirim) di Android | `TODO` | P0 |
| [S3-05](#s3-05--verifikasi-homescreen-saldo-tampil-rupiah) | Verifikasi HomeScreen saldo tampil Rupiah | `ON GOING` | P0 |
| [S3-06](#s3-06--verifikasi-feebreakdowncard-dengan-data-real) | Verifikasi `FeeBreakdownCard` dengan data real | `ON GOING` — formula doc basi | P0 |
| [S3-07](#s3-07--verifikasi-sendsuccess-dengan-data-real) | Verifikasi `SendSuccessScreen` dengan data real | `ON GOING` — formula doc basi | P0 |
| [S3-08](#s3-08--test-demo-penerima-receive-screen) | Test demo penerima (ReceiveScreen) | `BLOCKED` — screen belum sesuai spec | P1 |
| [S3-09](#s3-09--test-repeat-send-tanpa-restart-backend) | Test repeat send tanpa restart backend | `ON GOING` | P1 |
| [S3-10](#s3-10--audit-invisible-crypto-checklist-awal) | Audit invisible-crypto checklist awal | `ON GOING` | P1 |
| [S3-11](#s3-11--test-skenario-testnet-flaky) | Test skenario testnet flaky | `TODO` | P2 |

---

## S3-01 — Audit API contract Flutter vs backend

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16):** Audit sudah dijalankan langsung terhadap kode aktual (`backend/src/index.ts` vs `frontend/lib/services/wallet_api.dart` + `frontend/lib/models/models.dart`), bukan cuma dari dokumentasi. **Hasil: nol mismatch** di 5 endpoint inti — semua tabel di bawah diisi ✓. Endpoint tambahan yang tidak direncanakan sprint manapun (`/home/:userId/feed`, `/contacts`, `/requests`, `/splits`, `/wallet/:userId/fund`) juga sudah diverifikasi cocok field-per-field terhadap model Flutter yang bersangkutan (`HomeFeed`, `Contact`, `MoneyRequest`, `SplitBill`) di audit terpisah — lihat `sprint/sprint-0-foundation.md` dan `sprint/sprint-2-send-flow.md` untuk detailnya.

**Konteks:**  
Frontend (Flutter) dan backend dibangun bersama tapi mungkin punya perbedaan kecil di nama field, tipe data, atau format. Issue ini memetakan semua potensi mismatch sebelum testing agar debugging lebih cepat.

**Checklist audit per endpoint:**

### `GET /passkey/register-options`
| Field | Flutter expects | Backend returns | Match? |
|-------|----------------|-----------------|--------|
| `challenge` | `String` (base64url) | `string` | ✓ |
| `userId` | `String` | `string` | ✓ |

### `POST /wallet/create`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `userId` | `String` | `string` | ✓ |
| `attestation.credentialId` | `String` | `string` | ✓ |
| `attestation.clientDataJSON` | `String` (base64url) | `string` | ✓ |
| `attestation.attestationObject` | `String` (base64url) | `string` | ✓ |

Cek `PasskeyAttestation.toJson()` di `frontend/lib/models/models.dart` → field `'credentialId'`, `'clientDataJSON'`, `'attestationObject'`. Backend harus menggunakan nama field yang sama persis (case-sensitive).

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `userId` | `string` | `json['userId'] as String` | ✓ |
| `contractAddress` | `string` | `json['contractAddress'] as String` | ✓ |
| `balanceUsd` | `number` | `(json['balanceUsd'] as num).toDouble()` | ✓ |

### `POST /tx/build`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `userId` | `String` | `string` | ✓ |
| `recipient` | `String` (nama) | `string` | ✓ |
| `amountUsd` | `double` | `number` | ✓ |

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `txId` | `string` | `r.data['txId'] as String` | ✓ |
| `challenge` | `string` (base64url) | `r.data['challenge'] as String` | ✓ |
| `credentialIds` | `string[]` | `(r.data['credentialIds'] as List).cast<String>()` | ✓ |

### `POST /tx/submit`
| Field (Request) | Flutter sends | Backend expects | Match? |
|-----------------|--------------|-----------------|--------|
| `txId` | `String` | `string` | ✓ |
| `assertion.credentialId` | `String` | `string` | ✓ |
| `assertion.clientDataJSON` | `String` | `string` | ✓ |
| `assertion.authenticatorData` | `String` | `string` | ✓ |
| `assertion.signature` | `String` | `string` | ✓ |

Cek `PasskeyAssertion.toJson()` di models.dart → field `'credentialId'`, `'clientDataJSON'`, `'authenticatorData'`, `'signature'`.

| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `txId` | `string` (plus `txHash` ekstra, tidak masalah) | `r.data['txId'] as String?` (nullable, dengan fallback) | ✓ |

### `GET /wallet/:userId/balance`
| Field (Response) | Backend returns | Flutter expects | Match? |
|-----------------|-----------------|----------------|--------|
| `balanceUsd` | `number` | `(r.data['balanceUsd'] as num).toDouble()` | ✓ |

**File yang diubah/dibuat:**
- Audit ini menghasilkan daftar mismatch yang menjadi input untuk S3-02 — **daftarnya kosong, tidak ada mismatch ditemukan**

**Acceptance criteria:**
- [x] Tabel audit di atas terisi semua (Match: ✓ atau ✗) — semua ✓
- [x] Semua mismatch terdokumentasi di Sprint Log sebelum S3-02 dimulai — tidak ada mismatch untuk didokumentasikan

---

## S3-02 — Fix field name/type mismatches

**Status:** `FINISHED` (N/A) | **Prioritas:** P0 | **Tipe:** fix  
**Dependencies:** S3-01

**Update (2026-07-16):** N/A — S3-01 tidak menemukan satupun mismatch untuk diperbaiki. Tidak ada kerjaan di issue ini.

**Konteks (asli, untuk referensi historis):**  
~~Perbaiki semua mismatch yang ditemukan di S3-01. Preferensi: sesuaikan backend ke kontrak yang sudah ada di Flutter (karena Flutter sudah punya kontrak yang didokumentasikan di `docs/Flutter-Boilerplate-README.md` §8).~~

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
- [ ] `flutter analyze` di `frontend/` tidak ada error — belum bisa dijalankan dari environment ini (tidak ada Flutter SDK)
- [x] Backend ~~`npm run build`~~ `pnpm run build` tidak ada TypeScript error — `tsc` clean, diverifikasi berulang kali di setiap perubahan
- [x] Tidak ada mismatch tersisa di tabel S3-01 — memang tidak pernah ada

---

## S3-03 — ~~Test full flow (onboarding + kirim) di iOS~~ (SKIPPED)

**Status:** `SKIPPED` | **Prioritas:** ~~P0~~ | **Tipe:** test  
**Dependencies:** S3-01, S3-02

**Keputusan (2026-07-16):** iOS di-skip permanen, konsisten dengan S1-06/S2-05 — kendala biaya Apple Developer Program. Demo Android-only.

**Konteks (asli, untuk referensi historis):**  
~~Test end-to-end satu sesi penuh dari fresh install (hapus app dulu) di iOS.~~

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
- [x] ~~Semua 8 langkah selesai tanpa error/crash~~ — N/A, di-skip
- [x] ~~Tidak ada istilah crypto yang muncul di layar manapun~~ — N/A, di-skip
- [x] ~~Waktu dari tap "Kirim sekarang" ke SendSuccessScreen ≤ 10 detik~~ — N/A, di-skip
- [x] ~~Saldo berkurang sesuai nominal~~ — N/A, di-skip

---

## S3-04 — Test full flow (onboarding + kirim) di Android

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S3-01, S3-02, S1-07, S2-06

**Update (2026-07-16):** Sama seperti S1-07/S2-06 — butuh device fisik, tidak bisa dijalankan dari sini. Ini pada dasarnya tes gabungan S1-07 (onboarding) + S2-06 (kirim) dalam satu sesi berurutan, jadi blocker-nya identik: `RELAYER_API_KEY` di Railway, `USE_MOCK=false`, dan `assetlinks.json` live (semua sudah beres kecuali `RELAYER_API_KEY`).

**Konteks (asli):**  
~~Test yang sama di Android device fisik.~~ (masih berlaku)

**Acceptance criteria:**
Sama dengan S3-03, di Android.

---

## S3-05 — Verifikasi HomeScreen saldo tampil Rupiah

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** test

**Update (2026-07-16):** Arsitekturnya **beda dari dugaan konteks asli**, tapi hasilnya tetap benar. Konteks asli mengasumsikan Flutter yang konversi USD→IDR sendiri (`usdToIdr(wallet?.balanceUsd)`). Implementasi aktual: **konversi terjadi di backend**, di dalam `/home/:userId/feed` (`balanceIdr: userRecord.balanceUsd * USD_TO_IDR`) — `HomeScreen` cuma baca `feed.balanceIdr` langsung dan lempar ke `MoneyText` widget, tidak ada konversi USD→IDR di sisi Flutter untuk saldo Home sama sekali.

**Verifikasi lewat code review:**
- `MoneyText` pakai `formatMoney(amountIdr, Currency.idr)` → `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)` — format benar (pemisah ribuan titik, tanpa desimal), cocok dengan test case di bawah.
- Rate `16350` **di-duplikasi di 2 tempat** (`backend/src/index.ts USD_TO_IDR` dan `frontend/lib/app/env.dart Env.usdToIdr`) — saat ini sama persis, tapi ini titik rawan drift kalau salah satu diubah tanpa yang lain. Tidak diperbaiki sekarang (butuh keputusan arsitektur: single source of truth di backend vs frontend), cukup dicatat sebagai risiko.

Yang masih `TODO`: verifikasi **live** bahwa angka yang benar-benar tampil di layar sesuai, karena code review tidak bisa membuktikan rendering.

**Konteks (asli, untuk referensi historis — asumsi "Flutter konversi sendiri" TIDAK akurat):**  
~~Saldo dari backend dalam USD. Flutter mengkonversi ke Rupiah via `usdToIdr()`. Verifikasi konversi benar dan format tampil benar.~~

**Langkah (asli — lihat catatan di atas, `balanceIdr` sekarang datang langsung dari backend):**
1. Cek `HomeScreen.build()` di `frontend/lib/screens/home_screen.dart`
2. ~~`balanceIdr = usdToIdr(wallet?.balanceUsd ?? 0)`~~ → sekarang `balanceIdr: feed.balanceIdr` langsung dari `/home/:userId/feed`
3. `formatMoney(balanceIdr, Currency.idr)` → harus menampilkan format "Rp 1.000.000" (titik sebagai pemisah ribuan) — **dikonfirmasi benar**

**Test cases:**
| `balanceUsd` dari backend | Expected di HomeScreen |
|--------------------------|----------------------|
| 0.0 | Rp 0 |
| 1.0 | Rp 16.350 |
| 61.16 | Rp 999.972 |
| 100.0 | Rp 1.635.000 |

**Acceptance criteria:**
- [x] Format Rupiah benar (pemisah ribuan, tidak ada "USDC", tidak ada desimal) — dikonfirmasi via code review `formatMoney()`
- [x] Nilai konsisten dengan kurs `Env.usdToIdr` — konsisten, walau rate-nya dihitung backend sekarang (lihat catatan duplikasi rate di atas)

---

## S3-06 — Verifikasi `FeeBreakdownCard` dengan data real

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** test

**Update (2026-07-16):** **Formula & contoh angka di dokumen ini sudah tidak sesuai kode aktual.** `frontend/lib/app/env.dart`: `feeRate = 0.0` — bukan 0,5% seperti diasumsikan di sini. Ini keputusan produk yang sudah didokumentasikan di komentar kode itu sendiri: *"Demo: nol biaya, jadi 'mereka terima' == 'kamu kirim' di seluruh alur kirim."* Jadi untuk kirim Rp 1.000.000, yang benar ditampilkan adalah:
- "Kamu kirim: Rp 1.000.000"
- "Biaya layanan (0%): - Rp 0" (atau baris biaya tidak ditampilkan sama sekali, tergantung UI — perlu dicek langsung ke `FeeBreakdownCard` widget)
- "Keluarga terima: Rp 1.000.000" — **sama persis dengan yang dikirim**, bukan Rp 995.000

Ini bukan bug untuk diperbaiki — murni dokumen sprint yang perlu disesuaikan ke keputusan produk yang sudah ada. **Belum diverifikasi** apakah `FeeBreakdownCard` widget-nya sendiri menangani kasus fee 0% dengan baik (misal: apakah baris "Biaya layanan" tetap muncul dengan angka 0, atau disembunyikan) — ini genuinely butuh baca widget-nya + lihat live di device.

**Konteks (asli, untuk referensi historis):**  
~~`FeeBreakdownCard` adalah signature element produk — muncul SEBELUM konfirmasi dan menampilkan transparansi biaya. Pastikan nilai yang ditampilkan akurat.~~ (masih berlaku sebagai tujuan, cuma formula konkretnya yang berubah)

**Langkah (asli — angka di sini SALAH, lihat koreksi di atas):**
1. Di `SendAmountScreen`: input Rp 1.000.000
2. ~~Verifikasi preview real-time: "Keluarga terima Rp 995.000"~~ → seharusnya "Rp 1.000.000"
3. Tap "Lanjut" → `SendReviewScreen`
4. Verifikasi `FeeBreakdownCard` menampilkan (dengan angka terkoreksi):
   - "Kamu kirim: Rp 1.000.000"
   - "Biaya layanan (0%): - Rp 0"
   - "Keluarga terima: Rp 1.000.000" (highlighted green)

**Formula aktual (`SendQuote.fromAmount()` di `frontend/lib/core/money.dart`):**
```
fee = (amountIdr * Env.feeRate).roundToDouble() = (1.000.000 * 0.0) = 0
receiveIdr = amountIdr - fee = 1.000.000 - 0 = 1.000.000
```

**Acceptance criteria:**
- [ ] Semua 3 baris `FeeBreakdownCard` akurat dengan formula **terkoreksi** di atas (fee 0%, bukan 0,5%) — belum dites live
- [ ] Baris "Keluarga terima" berwarna hijau (`AppColors.success`) — belum diverifikasi
- [ ] Tidak ada nilai "0" yang ter-display sebelum user input nominal — masih relevan, tidak terpengaruh koreksi fee rate

---

## S3-07 — Verifikasi `SendSuccessScreen` dengan data real

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** test

**Update (2026-07-16):** Sama seperti S3-06 — contoh angka di dokumen ini pakai asumsi fee 0,5% yang **sudah tidak berlaku** (`Env.feeRate = 0.0`). Karena `receiveIdr = amountIdr - fee` dan `fee` selalu 0, "nominal setelah dipotong biaya" **secara numerik sama dengan nominal kirim** — pengecekan "bukan `amountIdr`" di acceptance criteria tetap valid secara kode (field yang dipakai memang `receiveIdr`, bukan `amountIdr`), tapi kedua angka itu kebetulan selalu identik sekarang, jadi tidak bisa dipakai untuk membedakan bug "salah pakai field" dari kondisi normal hanya dengan melihat angka akhir.

**Konteks (asli, untuk referensi historis):**  
~~`SendSuccessScreen` menampilkan data dari `AppTransaction` yang dikembalikan backend. Verifikasi bahwa nama penerima dan nominal `receiveIdr` tampil benar (bukan nilai mock atau kosong).~~ (masih akurat)

**Langkah (asli — angka SALAH, lihat koreksi di atas):**
1. Kirim Rp 500.000 ke nama "Mama Sunarsih"
2. Di `SendSuccessScreen` verifikasi:
   - Heading: "Uang terkirim"
   - Body: ~~"Mama Sunarsih menerima Rp 497.500."~~ → seharusnya **"Mama Sunarsih menerima Rp 500.000."** (fee 0%)
   - Icon centang hijau

**Acceptance criteria:**
- [ ] Nama penerima tampil sesuai yang diinput — belum dites live
- [ ] Nominal tampil adalah `receiveIdr` (setelah dipotong biaya, saat ini = `amountIdr` karena fee 0%), bukan hardcode/nilai mock — belum dites live
- [ ] Format Rupiah benar — belum dites live

---

## S3-08 — Test demo penerima (ReceiveScreen)

**Status:** `BLOCKED` — screen belum sesuai spec, butuh keputusan | **Prioritas:** P1 | **Tipe:** test

**Update (2026-07-16) — TEMUAN PENTING, bukan cuma "belum dites":**  
`ReceiveScreen` yang ada di kode (`frontend/lib/screens/receive_screen.dart`) **bukan screen yang dideskripsikan issue ini**. Sudah dicari di seluruh codebase (`grep` untuk "masuk", "Dana tersedia", "ditarik", "receivedIdr") — **tidak ada satupun match**. Yang ada sekarang adalah screen statis "bagikan QR/ID saya untuk menerima uang" (kartu kontak dengan QR code + Kirimin ID + nomor rekening), bukan screen konfirmasi "Rp X masuk" yang dideskripsikan di sini dan di `sprint/sprint-2-send-flow.md` S2-10.

Sesi lalu saya sempat memperbaiki `ReceiveScreen` yang ADA (translasi ke Bahasa Indonesia + ubah label jadi "Rekening tujuan BCA •••• 4821") — itu perbaikan yang valid untuk screen yang ada, TAPI tidak menyelesaikan gap sesungguhnya: screen "Rp 995.000 masuk ke rekening BCA ****1234" + card "Dana tersedia untuk ditarik sekarang" + button "Kembali ke beranda" **tidak pernah dibangun**.

**Ini butuh keputusan, bukan eksekusi murni** — dua opsi:
1. **Bangun screen baru** sesuai spec di bawah (butuh amount dinamis dari transaksi terakhir, kemungkinan state/route baru) — kerjaan UI Flutter yang lebih besar, dan saya tidak punya cara verifikasi `flutter analyze`/render dari environment ini, jadi risikonya lebih tinggi untuk saya kerjakan blind.
2. **Sesuaikan demo script** untuk pakai `ReceiveScreen` yang sudah ada (kartu "bagikan untuk menerima") sebagai pengganti — device kedua cukup menunjukkan detail rekening penerima sebelum kirim, bukan konfirmasi setelah uang masuk. Lebih murah, tapi mengubah narasi demo dari yang direncanakan sprint ini.

**Konteks (asli, untuk referensi historis):**  
~~`ReceiveScreen` adalah layar mock off-ramp untuk demo — "sisi penerima" yang ditampilkan di HP kedua saat demo panggung. Pastikan layar ini accessible dan tampil benar.~~

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
- [x] `ReceiveScreen` accessible dari HomeScreen — sudah, via tombol "Terima" (`Routes.receive`)
- [ ] Semua elemen tampil tanpa overflow atau clip — screen yang ada beda dari spec, belum relevan sampai keputusan di atas diambil
- [x] Tidak ada istilah crypto — screen yang ada (setelah perbaikan sesi lalu) bersih dari istilah crypto
- [ ] Back button berfungsi — screen yang ada tidak punya "Kembali ke beranda" eksplisit seperti spec (pakai back navigation standar app bar), belum relevan sampai keputusan di atas

---

## S3-09 — Test repeat send tanpa restart backend

**Status:** `ON GOING` | **Prioritas:** P1 | **Tipe:** test

**Update (2026-07-16):** Diverifikasi via code review:
- `SendSuccessScreen`'s `done()` (dipanggil saat tap "Selesai") memanggil `sendControllerProvider.notifier.reset()` — state `SendController` benar-benar direset ke `SendState()` awal, sesuai acceptance criteria.
- `txStore` (`backend/src/store.ts`) **tidak punya mekanisme expiry/TTL** — kalau user cancel Face ID di tengah `/tx/build` (sudah dapat `txId` tapi tidak pernah lanjut ke `/tx/submit`), entry itu akan **nyangkut selamanya di memory** sampai server restart. Untuk skala demo (beberapa transaksi saja) ini tidak akan jadi masalah fungsional, tapi secara teknis literally "accumulate" seperti yang dikhawatirkan acceptance criteria asli — bukan bug yang blocking, tapi juga belum benar-benar "tidak accumulate".

**Konteks (asli, untuk referensi historis):**  
Selama demo, mungkin perlu kirim uang lebih dari sekali (demo ulang, error recovery). Verifikasi bahwa alur bisa diulang tanpa perlu restart backend atau reinstall app.

**Langkah:**
1. Kirim uang pertama → sukses
2. Dari HomeScreen → kirim uang kedua → sukses
3. Kirim uang ketiga → sukses
4. Verifikasi: tidak ada state yang "stuck" dari transaksi sebelumnya

**Acceptance criteria:**
- [ ] 3 transaksi berturut-turut berhasil tanpa restart — belum dites live (butuh device + `RELAYER_API_KEY`)
- [x] `SendController.reset()` dipanggil dengan benar setelah setiap transaksi (cek `sendSuccess` → tap "Selesai") — dikonfirmasi ada di `send_success_screen.dart`
- [ ] `txStore` tidak accumulate pending tx yang expired — **tidak terpenuhi secara ketat**: tidak ada TTL, tx yang di-cancel di tengah jalan tetap nyangkut di memory (low-risk untuk skala demo, tapi criteria ini secara literal belum terpenuhi)

---

## S3-10 — Audit invisible-crypto checklist awal

**Status:** `ON GOING` | **Prioritas:** P1 | **Tipe:** chore

**Update (2026-07-16):** Grep forbidden-words sudah dijalankan (sesi sebelumnya) terhadap `frontend/lib/screens/` dan `frontend/lib/widgets/`:
```bash
grep -r "crypto\|wallet\|seed phrase\|gas\|XLM\|USDC\|blockchain\|token\|contract address\|private key\|public key\|RP_ID\|secp256r1" \
  frontend/lib/screens/ frontend/lib/widgets/ --include="*.dart" -i
```
**Hasil: bersih.** Semua match yang muncul adalah false positive (`theme/tokens.dart` di import path, `walletApiProvider` nama variabel, `toStringAsFixed`) — tidak ada satupun string UI yang benar-benar bocor istilah crypto.

**Checklist (dari build plan §4) — diisi sejauh bisa diverifikasi dari kode, tanpa device:**

| Item | Status | Catatan |
|------|--------|---------|
| Tidak ada input/tampilan seed phrase | ✓ | Tidak ada di codebase manapun — arsitektur passkey tidak pernah expose seed phrase sama sekali |
| Tidak ada private/public key / RP ID / contract address | ✓ | Grep forbidden-words bersih; `contractAddress`/`RP_ID` cuma ada di kode backend & internal state, tidak pernah di-render ke widget |
| Tidak ada kata "gas" / "XLM" | ✓ | Sama, grep bersih |
| Saldo & nominal selalu dalam $ atau Rp | ✓ | `formatMoney()` satu-satunya jalur format uang (lihat S3-05), semua screen pakai ini |
| Sign transaksi = biometrik native | ✓ | Benar by design — seluruh alur `kit.sign()`/`PasskeyKit` berbasis WebAuthn/passkey native, tidak ada jalur signing manual |
| Onboarding < 30 detik, < 3 tap | ⚠️ tap-count OK, timing belum bisa dipastikan | Alur navigasi cuma 1 tap eksplisit ("Buat akun dengan Face ID") sebelum biometrik native — jauh di bawah 3 tap. Durasi 30 detik **butuh device fisik** untuk diukur beneran (network + biometrik + deploy tx) |
| Penerima tidak pernah lihat istilah crypto | ⚠️ blocked oleh S3-08 | `ReceiveScreen` yang ada sudah bersih dari istilah crypto (setelah perbaikan sesi lalu), tapi screen ini bukan yang dideskripsikan sprint — lihat S3-08 |
| Rincian biaya transparan SEBELUM konfirmasi | ✓ | `FeeBreakdownCard` muncul di `SendReviewScreen`, sebelum tombol "Kirim sekarang" — tapi lihat S3-06 soal formula fee yang sudah beda (0% bukan 0,5%) |
| Copy familiar: "kirim uang", "saldo", "biaya" | ✓ (screens utama), ✗ (ReceiveScreen sebelum diperbaiki) | Screen alur kirim/onboarding sudah pakai bahasa ini. `ReceiveScreen` sempat 100% bahasa Inggris — sudah diperbaiki sesi lalu |
| Icon app / splash terasa aplikasi keuangan | — | Belum diaudit — ini soal aset visual (icon, splash screen), di luar cakupan code-review teks. Lihat `sprint/sprint-4-polish-demo.md` S4-02 |

**Acceptance criteria:**
- [ ] Semua 10 item di atas sudah diperiksa dan diisi statusnya — 8/10 terisi dari code review, 2 butuh device/aset visual
- [ ] Item yang belum ✓ menjadi issue di Sprint 4 — **S3-08 (ReceiveScreen) dan S4-02 (icon/splash) sudah relevan untuk Sprint 4**, dicatat di sini sebagai carry-over

---

## S3-11 — Test skenario testnet flaky

**Status:** `TODO` | **Prioritas:** P2 | **Tipe:** test

**Update (2026-07-16):** Belum bisa dites dari sini — butuh device fisik + kontrol jaringan (throttle/matikan koneksi di tengah request). Catatan tambahan: `_guard()` di `wallet_api.dart` sudah menangani `DioExceptionType.connectionTimeout`/`connectionError` secara eksplisit dengan `AppFailure.network` — jadi secara kode ada penanganan dasarnya, tapi perilaku UI (spinner, snackbar) tetap perlu diverifikasi live.

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
| 2026-07-16 | Audit S3-01 dijalankan terhadap kode aktual — hasil nol mismatch di 5 endpoint inti. S3-02 jadi N/A. | Selesai |
| 2026-07-16 | Ditemukan: `sprint/sprint-3-integration.md` (S3-06/S3-07) pakai contoh fee 0,5% yang sudah tidak sesuai — `Env.feeRate` aktual `0.0`. Dokumen dikoreksi, bukan kode (kode sudah benar sesuai keputusan produk). | Koreksi dokumentasi |
| 2026-07-16 | **Ditemukan gap signifikan (S3-08)**: screen "Rp X masuk" yang dideskripsikan sprint ini & S2-10 tidak pernah dibangun. `ReceiveScreen` yang ada adalah screen berbeda (bagikan QR untuk menerima), sudah diperbaiki copy-nya sesi lalu tapi tidak menyelesaikan gap ini. Butuh keputusan tim: bangun screen baru atau sesuaikan demo script. | **Belum diputuskan** |
| 2026-07-16 | Audit invisible-crypto (S3-10) dijalankan — grep forbidden-words bersih, 8/10 item checklist terisi dari code review. | Sebagian selesai |

## Blockers & Catatan

**API mismatch dari S3-01:** tidak ada. Audit lengkap (bukan sampling) terhadap kelima endpoint inti menghasilkan nol mismatch — kontrak data Flutter↔backend sudah konsisten sejak dikerjakan bareng di commit gabungan Sprint 1/2.

**Temuan lain yang lebih signifikan dari mismatch field name:**
1. **Formula fee di dokumen sprint basi** (S3-06/S3-07) — `Env.feeRate = 0.0`, bukan 0,5%. Ini keputusan produk yang sudah ada di kode (komentar eksplisit: "Demo: nol biaya"), dokumen yang perlu menyesuaikan, bukan kode.
2. **`ReceiveScreen` tidak sesuai spec sprint ini** (S3-08) — gap paling signifikan di seluruh Sprint 3, butuh keputusan tim (bangun screen baru vs sesuaikan demo script), bukan sesuatu yang bisa saya putuskan/kerjakan sepihak karena berisiko dan butuh verifikasi Flutter yang tidak tersedia di environment ini.
3. **`txStore` tanpa TTL** (S3-09) — bukan blocker fungsional untuk skala demo, tapi secara teknis tx yang di-cancel tetap nyangkut di memory.

**Blocker aktif yang sama dengan Sprint 1/2:** `RELAYER_API_KEY` dan akses device fisik tetap jadi penghalang utama untuk semua item testing live (S3-03 di-skip, S3-04/S3-06/S3-07/S3-09/S3-11 semua butuh device).
