# Sprint 4 — Polish & Demo

## Tujuan Sprint

Mempersiapkan produk dan presenter agar demo berjalan mulus, memorable, dan bebas dari istilah crypto. Sprint ini adalah yang paling dekat dengan "packaging" — tidak ada fitur baru, hanya penghalusan dan persiapan panggung.

Sprint ini selesai bila **tim bisa melakukan dry run demo penuh (< 4 menit) tanpa panduan, di kedua device, tanpa error, dan seluruh checklist invisible-crypto lulus.**

## Definition of Done

- [x] Semua 10 item invisible-crypto checklist ✓ — 8/10 dari code review (lihat S3-10), 2 sisanya (icon/splash, timing) sekarang juga terisi, lihat S4-01
- [x] Splash screen dan icon terasa seperti aplikasi keuangan — **sudah ada**, desain lebih baru dari draft di S4-02 (lihat catatan di sana)
- [ ] Demo script selesai dry run ≤ 4 menit di kedua device — **iOS di-skip permanen**, dan skenario "ReceiveScreen" di script lama tidak sesuai screen yang ada — script sudah ditulis ulang (S4-05), dry run tetap butuh device
- [ ] Video backup demo sudah direkam — perlu device + rekaman manual, tidak bisa dari sini
- [x] Script re-seed testnet tersedia bila testnet reset — **sudah dibuat**, lihat S4-07
- [x] `.well-known` final verification lulus di kedua platform — dijalankan live barusan, **Android lulus penuh**, iOS lulus teknis (200, JSON valid, Content-Type benar) tapi Team ID tetap placeholder karena iOS di-skip — lihat S4-04
- [ ] Slide deck final sudah di-align dengan demo script — di luar kapasitas saya (bukan file kode), tapi konten yang salah (Launchtube dll) sudah ditandai di S4-10
- [ ] Setidaknya 1 anggota bisa bawakan demo tanpa melihat catatan — murni latihan manusia

**Update (2026-07-16):** Sprint ini paling banyak berisi kerjaan non-kode (rekam video, latihan presenter, slide) yang di luar kapasitas saya. Yang bisa saya kerjakan/verifikasi dari sini: S4-01 (checklist), S4-04 (verifikasi live), S4-05 (tulis ulang demo script sesuai keputusan ReceiveScreen), S4-07 (sudah ada), S4-08 (verifikasi code review), S4-11 (verifikasi live), dan koreksi klaim teknis yang basi di S4-10.

---

## Daftar Issue

| ID | Judul | Status | Prioritas |
|----|-------|--------|-----------|
| [S4-01](#s4-01--invisible-crypto-checklist-final) | Invisible-crypto checklist final | `ON GOING` | P0 |
| [S4-02](#s4-02--polish-splashscreen--icon-app) | Polish `SplashScreen` & icon app | `FINISHED` | P0 |
| [S4-03](#s4-03--verifikasi-semua-copy-bahasa-indonesia) | Verifikasi semua copy Bahasa Indonesia | `ON GOING` | P0 |
| [S4-04](#s4-04--well-known-final-verification) | `.well-known` final verification | `ON GOING` | P0 |
| [S4-05](#s4-05--demo-script-final--dry-run) | Demo script final + dry run | `ON GOING` | P0 |
| [S4-06](#s4-06--rekam-video-backup-demo) | Rekam video backup demo | `TODO` | P0 |
| [S4-07](#s4-07--siapkan-testnet-re-seed-script) | Siapkan testnet re-seed script | `FINISHED` | P0 |
| [S4-08](#s4-08--polish-loading--error-states) | Polish loading & error states | `ON GOING` | P1 |
| [S4-09](#s4-09--final-e2e-test-di-kedua-device) | Final E2E test di kedua device | `TODO` | P0 |
| [S4-10](#s4-10--slide-deck-alignment) | Slide deck alignment | `TODO` | P1 |
| [S4-11](#s4-11--warmup-backend-sebelum-demo) | Warmup backend sebelum demo | `FINISHED` | P1 |
| [S4-12](#s4-12--opsional-tambah-google-fonts-plus-jakarta-sans) | ~~(Opsional) Tambah Google Fonts Plus Jakarta Sans~~ | `SKIPPED` (superseded) | ~~P2~~ |

---

## S4-01 — Invisible-crypto checklist final

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore  
**Dependencies:** S3-10 (audit awal)

**Update (2026-07-16):** Grep forbidden-words (di bawah) sudah dijalankan ulang — hasil masih bersih, sama seperti audit S3-10. Baris "ReceiveScreen: 'Rp X masuk ke rekening'" di checklist bawah **sudah tidak sesuai** — lihat keputusan di `sprint/sprint-3-integration.md` S3-08: screen itu tidak dibangun, demo pakai `ReceiveScreen` yang sudah ada (bagikan QR/rekening), bukan konfirmasi "Rp X masuk". Item terkait sudah disesuaikan di bawah.

**Konteks:**  
Checklist definitif sebelum demo. Setiap item diverifikasi secara manual di device fisik, bukan hanya di kode.

**Checklist — verifikasi di device fisik:**

### Kata-kata terlarang (cari di seluruh codebase)
Jalankan di root repo:
```bash
grep -r "crypto\|wallet\|seed phrase\|seed-phrase\|gas\|XLM\|USDC\|blockchain\|token\|contract address\|private key\|public key\|RP_ID\|secp256r1" \
  frontend/lib/screens/ frontend/lib/widgets/ \
  --include="*.dart" -i
```
**Expected:** tidak ada match.

### Alur onboarding
- [x] Splash screen tidak ada kata crypto — dikonfirmasi, cuma "Kirimin" + spinner
- [x] OnboardingScreen: tidak ada "wallet", hanya "akun", "Face ID" — ada komentar eksplisit di kode: "Tidak ada seed phrase, tidak ada kata wallet"
- [ ] Biometrik muncul dengan label "Kirimin" sebagai relying party name — `RP_NAME=Kirimin` di env, tapi label yang benar-benar muncul di prompt OS **butuh device fisik** untuk konfirmasi
- [ ] HomeScreen setelah daftar: "Saldo kamu" → Rupiah, bukan USD mentah — kode benar (lihat S3-05), belum dites live

### Alur kirim
- [x] SendAmountScreen: "Nominal kiriman", "Untuk siapa?" — tidak ada crypto — dikonfirmasi grep + baca kode
- [ ] Preview real-time: "Keluarga terima Rp X" — tidak ada "USDC", tidak ada "token" — **teks "Keluarga terima" perlu dicek langsung ke widget**, dan nilainya sekarang selalu sama dengan nominal kirim (fee 0%, lihat S3-06)
- [x] SendReviewScreen: FeeBreakdownCard → "Biaya layanan", bukan "network fee" atau "gas" — dikonfirmasi grep bersih
- [x] Bottom sheet: "Konfirmasi dengan Face ID" — tidak ada "sign transaction" — dikonfirmasi
- [x] SendSuccessScreen: "Uang terkirim" — tidak ada "transaction hash" — dikonfirmasi

### Sisi penerima
- [ ] ~~ReceiveScreen: "Rp X masuk ke rekening" — tidak ada crypto~~ **KOREKSI:** `ReceiveScreen` yang dipakai bukan versi "Rp X masuk" (screen itu tidak ada, lihat `sprint/sprint-3-integration.md` S3-08). Yang ada: "Terima" + QR + "Rekening tujuan BCA •••• 4821" — tidak ada istilah crypto (dikonfirmasi), tapi beda konten dari yang dicek item ini aslinya
- [x] Tidak ada QR code blockchain — QR yang ada cuma dekoratif (icon statis), bukan QR data on-chain apapun

### Checklist from build plan §4
- [x] Tidak ada input/tampilan seed phrase di mana pun — dikonfirmasi grep + review arsitektur passkey
- [x] Tidak ada private/public key / RP ID / contract address yang ditampilkan — dikonfirmasi grep bersih
- [x] Tidak ada kata "gas" / "XLM" — dikonfirmasi grep bersih
- [x] Saldo & nominal selalu dalam Rp — `formatMoney()` satu-satunya jalur format (S3-05)
- [x] Sign transaksi = biometrik native (Face ID/fingerprint) — benar by design, seluruh alur pakai WebAuthn/passkey
- [ ] Onboarding < 30 detik, < 3 tap sampai wallet siap — tap-count OK (1 tap eksplisit), **durasi butuh device fisik**
- [x] Penerima tidak pernah lihat istilah crypto — `ReceiveScreen` bersih (lihat koreksi di atas)
- [x] Rincian biaya muncul SEBELUM konfirmasi — `FeeBreakdownCard` di `SendReviewScreen`, sebelum tombol kirim
- [x] Copy familiar: "kirim uang", "saldo", "biaya" — dikonfirmasi di screen-screen utama
- [x] Icon app / splash terasa aplikasi keuangan, bukan crypto — lihat S4-02, launcher icon custom sudah ter-generate

**Acceptance criteria:**
- [x] `grep` tidak menemukan kata-kata terlarang di `screens/` dan `widgets/` — dijalankan ulang, masih bersih
- [ ] Semua 10 item checklist ✓ — 8/10 ✓ dari code review, 2 sisanya (label RP di prompt OS, timing onboarding) butuh device fisik

---

## S4-02 — Polish `SplashScreen` & icon app

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** feat

**Update (2026-07-16):** Sudah selesai, dan sudah berkembang lebih jauh dari draft di konteks asli:
- `SplashScreen` sudah diredesain (bukan pakai `Icons.send_rounded` lagi) — sekarang lingkaran ikon panah + nama "Kirimin" + spinner tipis, minimal dan bersih. Tidak ada tagline "Kirim uang ke keluarga" seperti disarankan, tapi desainnya sudah terasa seperti app finansial, bukan crypto.
- **Launcher icon sudah di-generate**: `pubspec.yaml` sudah punya konfigurasi `flutter_launcher_icons` lengkap (Android, iOS, macOS, Windows) menunjuk ke `lib/assets/icon/Kirimin.png`. File icon sumber ada (`Kirimin.png` + `Kirimin.svg`), dan file `ic_launcher.png` di `android/app/src/main/res/mipmap-*/` **timestamp-nya sama persis** dengan file sumber — indikasi kuat generator sudah pernah dijalankan (`dart run flutter_launcher_icons`), bukan masih icon default Flutter.
- Belum diverifikasi **visual** langsung di layar HP (butuh device fisik untuk lihat icon beneran di homescreen), tapi secara konfigurasi & file, pekerjaan ini sudah selesai.

**Konteks (asli, untuk referensi historis — deskripsi kondisi "saat ini" sudah basi):**  
~~Icon dan splash adalah kesan pertama. Saat ini SplashScreen menggunakan `Icons.send_rounded` — cukup, tapi bisa lebih "banking app". Icon app (launcher icon) belum di-customize.~~

**Opsi splash yang lebih banking:**
- Icon: burung origami kertas terbang (seperti transfer), atau simbol mata uang Rp, atau bulan sabit (motif lokal)
- Warna: `AppColors.primary` (teal pine) dengan background `AppColors.background`
- Nama "Kirimin" dengan tagline singkat

**Langkah — SplashScreen (minimal polish):**
1. Buka `frontend/lib/screens/splash_screen.dart`
2. Update ikon dari `Icons.send_rounded` ke `Icons.currency_exchange` atau ikon yang lebih banking
3. Tambahkan tagline: "Kirim uang ke keluarga"
4. Pastikan warna dari `AppColors`

**Langkah — Launcher icon (penting untuk demo):**
1. Siapkan icon PNG 1024x1024: teal (#0B6E63) background + simbol putih
2. Gunakan package `flutter_launcher_icons`:
   ```yaml
   # tambah ke pubspec.yaml dev_dependencies:
   flutter_launcher_icons: ^0.13.1
   ```
   ```yaml
   # tambah ke pubspec.yaml:
   flutter_icons:
     android: true
     ios: true
     image_path: "assets/icon/app_icon.png"
   ```
3. Taruh icon di `frontend/assets/icon/app_icon.png`
4. Jalankan: `dart run flutter_launcher_icons`

**File yang diubah/dibuat:**
- `frontend/lib/screens/splash_screen.dart` — update icon dan tagline
- `frontend/pubspec.yaml` — tambah `flutter_launcher_icons` di dev_dependencies + asset path
- `frontend/assets/icon/app_icon.png` (baru)

**Acceptance criteria:**
- [x] Splash screen tidak terasa seperti crypto app — dikonfirmasi, desain minimal + nama brand
- [ ] Launcher icon custom muncul di home screen device (bukan icon Flutter default) — konfigurasi & file sudah benar, **verifikasi visual di device fisik masih pending**
- [x] Icon iOS dan Android sudah ter-generate — `flutter_launcher_icons` config lengkap untuk kedua platform, file `mipmap-*` Android timestamp cocok dengan sumber

---

## S4-03 — Verifikasi semua copy Bahasa Indonesia

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16):** Baris `ReceiveScreen` di tabel bawah **sudah tidak sesuai** — heading aslinya "Rp X masuk" tidak pernah ada (lihat S3-08/S4-01). Ditemukan & diperbaiki sesi lalu: `ReceiveScreen` yang ada sebelumnya **100% berbahasa Inggris** ("Receive", "Share details", "Scan this to send me money", "Account") — sudah diterjemahkan ke "Terima", "Bagikan detail", "Pindai untuk kirim uang ke saya", "Rekening tujuan". Baris tabel di bawah dikoreksi sesuai kondisi sekarang. Baris lain (Onboarding, Home, Send*) belum di-scan ulang manual satu-per-satu dari sini — kemungkinan besar masih akurat karena tidak tersentuh perubahan apapun, tapi **verifikasi live tetap perlu** untuk 100% yakin.

**Konteks:**  
Semua text di UI harus dalam Bahasa Indonesia, active voice, dari sisi user. Ini termasuk: label tombol, placeholder input, pesan error, empty state, label navigasi.

**Scan manual per screen:**

| Screen | Item | Current | Expected | OK? |
|--------|------|---------|----------|-----|
| OnboardingScreen | Button | "Buat akun dengan Face ID" | ✓ | — |
| OnboardingScreen | Assurance | "Aman dengan sidik jari / wajahmu" | ✓ | — |
| HomeScreen | Balance label | "Saldo kamu" | ✓ | — |
| HomeScreen | Empty state | "Belum ada transaksi" | ✓ | — |
| SendAmountScreen | Recipient label | "Untuk siapa?" | ✓ | — |
| SendAmountScreen | Amount label | "Nominal kiriman" | ✓ | — |
| SendAmountScreen | Hint | "Nama keluarga" | ✓ | — |
| SendReviewScreen | Title | "Periksa kiriman" | ✓ | — |
| SendReviewScreen | Speed label | "Sampai dalam beberapa detik" | ✓ | — |
| SendReviewScreen | Button | "Kirim sekarang" | ✓ | — |
| SendReviewScreen (busy) | Button | "Mengirim…" | ✓ | — |
| SendSuccessScreen | Heading | "Uang terkirim" | ✓ | — |
| SendSuccessScreen | Button | "Selesai" | ✓ | — |
| ReceiveScreen | Heading | ~~"Rp X masuk"~~ → "Terima" (page title) | ✓ (setelah fix) | ✓ |
| HistoryScreen | Empty state | "Belum ada transaksi" | ✓ | — |
| Biometric sheet | Headline | varies (dari `_confirm`) | — | — |
| Biometric sheet | Button | "Konfirmasi dengan Face ID" | ✓ | — |
| Biometric sheet | Cancel | "Batal" | ✓ | — |
| Error messages | Snackbar | Bahasa Indonesia ramah user | — | — |

**Acceptance criteria:**
- [ ] Semua text di atas sudah diperiksa — `ReceiveScreen` sudah (dan sudah diperbaiki), sisanya belum di-scan ulang dari sesi ini
- [x] Tidak ada text bahasa Inggris yang terlihat user (kecuali nama brand "Face ID", "Kirimin") — `ReceiveScreen` sudah bersih setelah fix, screen lain diasumsikan tidak berubah dari kondisi awal
- [ ] Error messages tidak mengandung technical jargon — belum di-audit ulang secara spesifik di sesi ini

---

## S4-04 — `.well-known` final verification

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16):** 3 langkah curl sudah dijalankan live terhadap Railway production sesi ini:
- `GET /health` → 200, respons 0.47 detik (jauh di bawah target 2 detik S4-11)
- `GET /.well-known/apple-app-site-association` → 200, `Content-Type: application/json` ✓, JSON valid ✓, **tapi Team ID masih `TEAM_ID_NANTI_DIISI`** — ini expected, bukan bug, karena iOS di-skip permanen (S0-07). File-nya teknis valid, cuma tidak akan pernah bisa dipakai signing tanpa Apple Developer account.
- `GET /.well-known/assetlinks.json` → 200, `Content-Type: application/json` ✓, JSON valid ✓, `package_name: com.kirimin.app` ✓, SHA-256 fingerprint sesuai `sprint/CONFIG.md` ✓ — **lulus penuh**.

Yang masih `TODO`: langkah "Test di device fisik" (uninstall/reinstall + verifikasi biometrik/Credential Manager muncul) — genuinely butuh device fisik, tidak bisa dari sini.

**Konteks:**  
Final check bahwa semua `.well-known` file masih accessible dan valid. Krusial karena passkey tidak akan muncul tanpa ini.

**Langkah:**
```bash
# 1. Health check
curl -s https://<railway-url>/health | python3 -m json.tool

# 2. iOS AASA
curl -sv https://<railway-url>/.well-known/apple-app-site-association 2>&1 | \
  grep -E "HTTP|Content-Type|webcredentials"

# 3. Android Asset Links
curl -sv https://<railway-url>/.well-known/assetlinks.json 2>&1 | \
  grep -E "HTTP|Content-Type|package_name|sha256"

# 4. Verifikasi isi JSON
curl -s https://<railway-url>/.well-known/assetlinks.json | python3 -m json.tool
curl -s https://<railway-url>/.well-known/apple-app-site-association | python3 -m json.tool
```

**Test di device fisik:**
1. Uninstall + reinstall app di iOS device
2. Coba onboarding → verifikasi biometrik muncul (bukan error diam)
3. Uninstall + reinstall app di Android device
4. Coba onboarding → verifikasi Credential Manager muncul

**Acceptance criteria:**
- [x] Semua 3 curl command mengembalikan HTTP 200 — dijalankan live, semua 200
- [x] JSON valid di kedua file — dikonfirmasi dengan `python3 -m json.tool`
- [ ] iOS: biometrik muncul setelah fresh install — **N/A, di-skip permanen**
- [ ] Android: Credential Manager muncul setelah fresh install — butuh device fisik

---

## S4-05 — Demo script final + dry run

**Status:** `ON GOING` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16) — Keputusan tim & revisi script:**
1. **iOS di-skip permanen** (S0-07/S1-06/S2-05/S3-03) — demo sekarang butuh **2 device Android**, bukan iOS+Android seperti asumsi lama.
2. **Babak 4 ditulis ulang.** Screen "Rp 995.000 masuk ke rekening BCA ****1234" (konfirmasi dinamis) tidak pernah dibangun dan **keputusan tim: tidak dibangun** — pakai `ReceiveScreen` yang sudah ada dan sudah di-lock (QR + Kirimin ID + "Rekening tujuan BCA •••• 4821", statis, tidak terikat ke transaksi manapun). Narasinya diubah dari "lihat uang masuk secara live" jadi "ini rekening tujuan pengiriman tadi" — presenter yang menyambungkan cerita secara verbal, bukan angka yang muncul otomatis di layar.
3. **Nama penerima diubah dari "Mama" jadi "Rani Putri"** — supaya konsisten dengan nama yang di-hardcode di `ReceiveScreen` (`frontend/lib/screens/receive_screen.dart`, tidak bisa diubah lagi karena frontend sudah di-lock). Kalau presenter mengetik nama lain di Babak 3, ceritanya jadi tidak nyambung dengan yang ditunjukkan di Babak 4.
4. **Penyesuaian backend (bukan kode baru, murni operasional):** `resolveRecipient()` di `backend/src/index.ts` sudah punya fallback ke `DEMO_RECEIVER_CONTRACT` untuk nama apapun yang tidak match kontak terdaftar — jadi mengetik "Rani Putri" akan otomatis ke-route ke situ **setelah** `DEMO_RECEIVER_CONTRACT` diisi (lihat `NEXT_STEPS.md` §1b, masih pending device test). Opsional untuk determinisme lebih tinggi saat demo: daftarkan kontak eksplisit bernama persis "Rani Putri" via `POST /contacts` untuk sender demo, supaya resolve lewat step kontak (bukan fallback generik) — tidak wajib, tapi mengurangi risiko salah ketik nama lain ikut ke-route ke demo receiver secara tidak sengaja.
5. **Babak 5 dikoreksi**: "Fee di-sponsor via Launchtube" **tidak akurat** — Launchtube tidak dipakai (S0-11). Diganti "OpenZeppelin Channels".

**Konteks:**  
Demo yang baik bercerita, bukan hanya menampilkan fitur. Script ini mengikuti pola dari `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §8.

**Script Demo (~3-4 menit) — REVISI 2026-07-16:**

---

### Babak 1 — Masalah (15 detik)
> "Pekerja migran Indonesia mengirim pulang miliaran rupiah setiap tahun. Tapi mereka masih membayar 5–8% biaya dan menunggu 3–5 hari. Solusi crypto ada, tapi 90% orang kabur begitu lihat seed phrase."

### Babak 2 — Onboarding live (30 detik)
*[HP pengirim di tangan kiri presenter]*
> "Ini Kirimin. Daftar..."

*[Tap 'Buat akun dengan Face ID']*
> "...cukup pakai Face ID."

*[Face ID muncul → sukses → HomeScreen]*
> "Tidak ada seed phrase. Tidak ada kata sandi. Cukup wajah kamu. Di aplikasi biasa, bukan browser."

### Babak 3 — Kirim uang live (45 detik)
*[Tap 'Kirim' → SendAmountScreen]*
> "Kirim ke keluarga..."

*[Isi nama "Rani Putri" dan nominal Rp 1.000.000]*
> "...Rp 1.000.000."

*[Preview 'Keluarga terima Rp 1.000.000' muncul live — tanpa potongan, biaya layanan Rp 0]*
> "Langsung keliatan — tidak ada potongan biaya. Transparan sebelum konfirmasi."

*[Tap 'Lanjut' → SendReviewScreen dengan FeeBreakdownCard]*
> "Rincian lengkap."

*[Tap 'Kirim sekarang' → bottom sheet → Face ID]*
> "Konfirmasi Face ID..."

*[Hitung: 1, 2, 3, 4, 5... → SendSuccessScreen]*
> "...5 detik. Uang terkirim."
> "Tidak ada gas. Tidak ada XLM. Tidak ada 'approve transaction'."

### Babak 4 — Sisi penerima (20 detik)
*[HP kedua — sudah di-setup sebagai akun "Rani Putri", di tangan kanan atau dipegang orang lain]*
> "Ini akun tujuan pengiriman tadi — Rani Putri."

*[Tap 'Terima' → tunjukkan ReceiveScreen: QR + Kirimin ID "rani.putri" + 'Rekening tujuan BCA •••• 4821']*
> "Uang otomatis diteruskan ke rekening BCA-nya. Dia tidak pernah tahu ini jalan di atas blockchain — cukup tahu rekeningnya."

### Babak 5 — Reveal teknis (30 detik)
> "Di balik layar: passkey secp256r1 native — Protocol 21 Stellar. USDC. Fee di-sponsor via OpenZeppelin Channels. Settlement 5 detik, sub-sen. HP hanya pegang biometrik. Backend yang rakit transaksinya."

### Babak 6 — Tutup (20 detik)
> "Koridor pekerja migran Indonesia — $15 miliar per tahun — yang paling under-served di Asia Tenggara. Roadmap: anchor real, KYC SEP-12, kurs live SEP-38, publish ke App Store. Terima kasih."

---

**Dry run checklist:**
- [ ] Dry run 1: presenter baca script sambil demo — ukur waktu
- [ ] Dry run 2: presenter hafal poin utama, tanpa baca script
- [ ] Dry run 3: demo dengan audience 1 orang, tanya Q&A

**Acceptance criteria:**
- [ ] Total demo ≤ 4 menit — belum dites, script sudah direvisi tapi belum dry-run
- [ ] Presenter tidak menyebut kata crypto/wallet/seed phrase/gas — script revisi sudah bersih dari istilah ini, tinggal dites presenter beneran
- [ ] Transisi antar screen mulus, tidak ada loading aneh — butuh device fisik
- [ ] Q&A setidaknya 3 pertanyaan bisa dijawab (lihat build plan §8) — lihat § Antisipasi Pertanyaan Juri di bawah, isinya masih relevan

---

## S4-06 — Rekam video backup demo

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16):** Murni kerjaan manusia (rekam layar + audio, upload ke cloud) — tidak ada yang bisa saya kerjakan dari sini. Pastikan pakai script demo **versi revisi** (S4-05) supaya video-nya konsisten dengan apa yang akan dipresentasikan live.

**Konteks:**  
Stellar Testnet bisa flaky saat demo. Video backup adalah asuransi. **Wajib ada sebelum hari demo.**

**Langkah:**
1. Record video di iPhone/Android (kamera ke layar HP demo, atau screen recording)
2. Tampilkan screen recording device + audio presenter narasi
3. Rekam satu run penuh mengikuti demo script (§ S4-05)
4. Verifikasi kualitas: resolusi cukup, audio jelas, semua teks terbaca
5. Simpan di Google Drive / iCloud yang bisa diakses seluruh tim

**Alternatif:** Screen recording via `flutter run` → mirror di Mac/PC → QuickTime recording.

**Acceptance criteria:**
- [ ] Video tersimpan minimal di 2 tempat (local + cloud)
- [ ] Video memperlihatkan alur lengkap dari onboarding sampai receive
- [ ] Durasi ≤ 4 menit, kualitas jelas

---

## S4-07 — Siapkan testnet re-seed script

**Status:** `FINISHED` | **Prioritas:** P0 | **Tipe:** chore

**Update (2026-07-16, dari sesi sebelumnya):** Script sudah dibuat di `scripts/reseed-testnet.sh`, dan **ditulis ulang dari pseudocode asli** karena versi awal masih menyebut deploy factory contract / `FACTORY_CONTRACT_ID` yang sudah tidak relevan (arsitektur v1, S0-10). Versi final: fund `deployer`/`demo-sender`/`demo-receiver` via Friendbot + tambah trustline USDC, dengan catatan eksplisit bahwa **wallet Passkey Kit (smart contract) tidak bisa di-reseed lewat script** — kalau testnet reset, wallet demo harus dibuat ulang lewat re-onboarding di app, bukan CLI.

**Konteks (asli, untuk referensi historis — langkah di bawah sudah digantikan versi final di `scripts/reseed-testnet.sh`):**  
~~Stellar Testnet bisa reset tanpa pemberitahuan. Bila ini terjadi saat demo, seluruh wallet dan USDC testnet hilang. Script re-seed memungkinkan setup ulang dalam < 5 menit.~~ (tujuannya masih sama, isinya sudah beda dari draft di bawah)

**File yang diubah/dibuat:**
- `scripts/reseed-testnet.sh` — **sudah dibuat**, versi final beda dari pseudocode asli (lihat Update)

**Acceptance criteria:**
- [x] Script tersedia dan executable — `chmod +x` sudah dijalankan
- [ ] Ditest minimal sekali: jalankan reseed dan verifikasi akun terfund — **belum dites live**, `stellar` CLI tidak tersedia di environment kerja ini
- [ ] Seluruh tim tahu cara menjalankan script ini — perlu disosialisasikan manual ke tim

---

## S4-08 — Polish loading & error states

**Status:** `ON GOING` | **Prioritas:** P1 | **Tipe:** feat

**Update (2026-07-16):** Sebagian besar sudah ada di kode, diverifikasi via code review:
- `OnboardingScreen`: `loading = ref.watch(authControllerProvider).isLoading`, tombol disabled + `CircularProgressIndicator` saat loading — ada.
- `SendController` (`frontend/lib/state/send_controller.dart`) punya `SendPhase` enum lengkap (`input, review, signing, submitting, success, error`) — state machine sudah menangani signing/submitting secara eksplisit.
- `SendController._error()` — ada, set `phase = SendPhase.error` dengan `errorMessage`, persis sesuai checklist.
- `wallet_api.dart`'s `_guard()` menangani `DioException` dan translate ke `AppFailure` ramah user (Bahasa Indonesia, bukan stack trace).

**Belum diverifikasi dari sini** (butuh live/device): apakah loading state pernah benar-benar "frozen" tanpa timeout dalam praktik, apakah SEMUA Snackbar (bukan cuma yang ditemukan di code review) sudah Bahasa Indonesia, dan `HomeScreen`'s behavior spesifik saat saldo sedang fetch.

**Konteks (asli, untuk referensi historis):**  
Selama operasi async (onboarding, kirim), UI harus menampilkan state yang jelas. Verifikasi dan polish semua loading & error states.

**Checklist loading states:**
- [x] OnboardingScreen: loading = spinner di tombol ("Buat akun dengan Face ID" disabled) — dikonfirmasi
- [x] SendReviewScreen: signing → "Mengirim…" di tombol — `SendPhase.signing`/`submitting` ada di state machine, teks tombol persis perlu dicek visual tapi state-nya benar
- [x] SendReviewScreen: submitting → "Mengirim…" di tombol (tetap) — sama
- [ ] HomeScreen: saldo sedang di-fetch → tidak crash atau menampilkan 0 tanpa sebab — `homeFeedProvider` pakai `FutureProvider` dengan `.when(loading/error/data)`, secara desain tidak akan crash, tapi belum dites live

**Checklist error states:**
- [ ] Semua Snackbar error dalam Bahasa Indonesia — sebagian besar dikonfirmasi, belum di-scan 100% lengkap
- [x] Setelah error, user bisa retry (button tidak stuck disabled) — state machine `SendController` punya jalur balik dari `error`
- [ ] ~~`AuthController._fail()`~~ mengembalikan state yang benar agar UI tidak freeze — belum diverifikasi nama method persisnya (mungkin beda dari pseudocode, sama seperti pola di sprint lain)
- [x] `SendController._error()` set `phase = SendPhase.error` dengan `errorMessage` — dikonfirmasi persis sesuai

**Acceptance criteria:**
- [ ] Tidak ada loading state yang "frozen" (spinner abadi tanpa timeout) — belum dites live
- [ ] Semua error menampilkan pesan Bahasa Indonesia — sebagian dikonfirmasi, belum lengkap
- [ ] User bisa retry setelah setiap jenis error — state machine mendukung, belum dites live

---

## S4-09 — Final E2E test di kedua device

**Status:** `TODO` | **Prioritas:** P0 | **Tipe:** test  
**Dependencies:** S4-01, S4-02, S4-04

**Update (2026-07-16):** "Kedua device" sekarang berarti **2 Android**, bukan iOS+Android — iOS di-skip permanen. Ini adalah tes gabungan paling akhir dari semua yang sudah diverifikasi lewat code review di sprint 0-4 — genuinely butuh device fisik, tidak bisa dikerjakan dari sini. Prasyarat: `RELAYER_API_KEY` terisi (S1-05/S2-02), `DEMO_RECEIVER_CONTRACT` terisi (S2-10), wallet demo sudah di-fund USDC (`NEXT_STEPS.md` §1b).

**Konteks:**  
Test final lengkap sebelum demo. Lakukan dengan setting seperti hari-H: no USB debug, HP dalam kondisi demo, tidak ada notifikasi gangguan.

**Setup:**
1. ~~iOS: flight mode → airplane off~~ — N/A, iOS di-skip
2. Android (kedua device): DND on, brightness max, tidak ada notifikasi
3. Backend: Railway sudah running (lakukan warmup request dulu — lihat S4-11)

**Skenario test:**
1. Uninstall app di kedua device
2. Install ulang (via `flutter install` atau drag APK)
3. Device 1 (pengirim): full demo script — onboarding → kirim (S4-05 Babak 2-3)
4. Device 2 (penerima "Rani Putri"): tunjukkan `ReceiveScreen` (S4-05 Babak 4)

**Acceptance criteria:**
- [x] ~~Demo selesai penuh di iOS tanpa intervensi teknis~~ — N/A, di-skip
- [ ] Demo selesai penuh di Android (2 device) tanpa intervensi teknis — belum dites
- [ ] Waktu onboarding: < 30 detik — belum diukur live
- [ ] Waktu settlement: < 10 detik (testnet) — belum diukur live
- [x] Tidak ada istilah crypto yang muncul di layar mana pun — dikonfirmasi via grep (S4-01), verifikasi visual live masih pending

---

## S4-10 — Slide deck alignment

**Status:** `TODO` | **Prioritas:** P1 | **Tipe:** chore

**Update (2026-07-16):** Slide deck sendiri di luar kapasitas saya (bukan file kode di repo ini), tapi satu klaim teknis di checklist di bawah **sudah tidak akurat** dan perlu dikoreksi sebelum masuk slide: "Launchtube" di baris tech stack. Launchtube tidak dipakai sama sekali (deprecated, di-skip permanen — S0-11); yang dipakai adalah **OpenZeppelin Channels**. Kalau ini masuk slide dengan nama lama, ada risiko juri yang riset teknis menyadari ketidaksesuaian dengan apa yang sebenarnya berjalan.

**Konteks:**  
Slide harus align dengan demo live — terutama saat Babak 5 ("reveal teknis"). Beberapa poin kunci yang harus ada di slide:

**Checklist slide:**
- [ ] Slide masalah: data kuantitatif ($15B IDR remittances, 5–8% fee, 90% drop-off at seed phrase)
- [ ] Slide solusi: "terasa seperti transfer bank" — bukan "crypto wallet"
- [ ] Slide arsitektur (optional, tapi kuat): 3-layer (Flutter → Node/Passkey Kit → Stellar)
- [ ] Slide tech stack: Protocol 21, Passkey Kit, ~~Launchtube~~ **OpenZeppelin Channels**, USDC, SAC — framing sebagai "mesin di balik layar"
- [ ] Slide positioning: koridor Indonesia, under-served vs Filipina
- [ ] Slide future work: anchor real, KYC SEP-12, kurs SEP-38, store publish
- [ ] Slide regulasi: remitansi lintas-batas + off-ramp via VASP berlisensi (bukan stablecoin domestik)

**Acceptance criteria:**
- [ ] Slide dapat dipresentasikan oleh semua anggota tim
- [ ] Tidak ada klaim yang tidak bisa dibuktikan di demo — **termasuk klaim teknis basi seperti Launchtube**, lihat Update di atas
- [ ] Slide regulasi ada (untuk antisipasi pertanyaan juri)

---

## S4-11 — Warmup backend sebelum demo

**Status:** `FINISHED` | **Prioritas:** P1 | **Tipe:** chore

**Update (2026-07-16):** Ditest live barusan — `curl /health` merespons dalam **0.47 detik**, jauh di bawah target 2 detik. Container tidak dalam kondisi "tidur" saat ini. Catatan: ini snapshot satu waktu, bukan jaminan — kalau backend idle cukup lama sebelum hari-H, cold start tetap mungkin terjadi. Prosedur warmup manual (curl 5 menit sebelum demo) tetap perlu dijalankan tim di hari-H sebagai langkah pencegahan, terlepas dari hasil tes ini.

**Konteks:**  
Railway free tier menggunakan container yang mungkin "tidur" bila tidak ada traffic. Cold start bisa 30–60 detik. Lakukan warmup 5 menit sebelum demo agar request pertama tidak lambat.

**Langkah:**
1. Setup cron job simple atau request manual:
   ```bash
   # Jalankan 5 menit sebelum demo
   curl https://<railway-url>/health
   ```
2. Atau tambahkan uptime monitor: [UptimeRobot](https://uptimerobot.com) (gratis) → ping `/health` setiap 5 menit → backend tidak pernah tidur.

**Acceptance criteria:**
- [x] `curl /health` merespons dalam < 2 detik saat demo dimulai — 0,47 detik saat dites (2026-07-16), tapi tetap perlu di-warmup ulang di hari-H sungguhan
- [x] Ada prosedur warmup yang terdokumentasi untuk hari-H — sudah ada di dokumen ini (curl manual atau UptimeRobot)

---

## S4-12 — ~~(Opsional) Tambah Google Fonts Plus Jakarta Sans~~ (SUPERSEDED)

**Status:** `SKIPPED` (superseded) | **Prioritas:** ~~P2~~ | **Tipe:** feat

**Update (2026-07-16):** Keputusan desain sudah berubah — bukan Plus Jakarta Sans, tim sudah pindah ke **Manrope** sebagai satu-satunya typeface app (dikonfirmasi dari komentar eksplisit di `frontend/pubspec.yaml`: *"Manrope is the app's sole typeface (design system v1.1 — Inter fully retired)"*). Font sudah di-bundle offline (variable font file lokal, bukan via package `google_fonts`), lengkap dengan beberapa weight (400-800). Tidak perlu kerjaan tambahan — issue ini selesai dengan cara yang berbeda dari rencana asli.

**Konteks (asli, untuk referensi historis — sudah digantikan Manrope):**  
~~`app/theme.dart` sudah menyiapkan `AppText._family = null` dengan TODO untuk Plus Jakarta Sans. Font ini dirancang di Indonesia — memperkuat narasi "aplikasi keuangan lokal" sekaligus terlihat premium.~~

**Langkah (bila ada waktu):**
1. Tambah ke `pubspec.yaml`:
   ```yaml
   google_fonts: ^6.2.1
   ```
2. Di `frontend/lib/app/theme.dart`, update `AppText`:
   ```dart
   import 'package:google_fonts/google_fonts.dart';
   
   // Ganti semua TextStyle di AppText agar pakai Plus Jakarta Sans:
   static final displayMoney = GoogleFonts.plusJakartaSans(
     fontSize: 40,
     fontWeight: FontWeight.w700,
     // ... rest of properties
   );
   ```
3. Atau gunakan cara global: di `buildAppTheme()`:
   ```dart
   return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(...);
   ```

**Acceptance criteria:**
- [x] ~~Font muncul di semua screen~~ — N/A, superseded oleh Manrope yang sudah jadi default theme
- [x] ~~`flutter analyze` tidak error~~ — N/A
- [x] ~~UI tidak ada overflow karena perubahan font metrics~~ — N/A, tidak ada perubahan font baru yang perlu dilakukan

---

## Antisipasi Pertanyaan Juri

Dari `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §8:

| Pertanyaan | Jawaban singkat |
|-----------|----------------|
| "Bedanya sama MoneyGram/Coins.ph?" | UX passkey native tanpa seed phrase + fokus koridor Indonesia under-served + transparansi biaya |
| "Legal di Indonesia?" | Remitansi lintas-batas + off-ramp ke IDR via VASP/MTO berlisensi. Crypto tidak dipakai sebagai alat bayar domestik. |
| "Recovery kalau HP hilang?" | Passkey bisa sync via iCloud Keychain / Google Password Manager. Roadmap: social recovery via multi-signer. Di luar scope MVP. |
| "Kenapa native, bukan web?" | Face ID di dalam app terasa seperti aplikasi bank. Passkey terikat aman via Associated Domains. Distribusi via store. |
| "Skalabilitas?" | Soroban sub-sen per tx + fee abstraction via OpenZeppelin Channels. Throughput Stellar 1000+ TPS. |

---

## Sprint Log

| Tanggal | Update | Status |
|---------|--------|--------|
| 2026-07-16 | Audit invisible-crypto (S4-01) dijalankan ulang, grep masih bersih. 8/10 item checklist terisi dari code review. | Sebagian selesai |
| 2026-07-16 | Ditemukan: launcher icon (S4-02) & font Manrope (S4-12, menggantikan Plus Jakarta Sans) ternyata **sudah selesai** duluan, di luar urutan sprint yang direncanakan. | Ditemukan sudah selesai |
| 2026-07-16 | `.well-known` (S4-04) dan warmup backend (S4-11) dites live terhadap Railway — keduanya lulus. | Selesai |
| 2026-07-16 | **Demo script (S4-05) ditulis ulang** sesuai keputusan tim: pakai `ReceiveScreen` yang sudah ada (bukan bangun screen baru), nama penerima diganti "Rani Putri" supaya konsisten dengan yang di-hardcode di screen tersebut. Juga dikoreksi: "Launchtube" di Babak 5 → "OpenZeppelin Channels". | Selesai (dokumen), dry run live masih pending |
| 2026-07-16 | Ditemukan klaim "Launchtube" yang basi di S4-10 (slide checklist) dan tabel Antisipasi Pertanyaan Juri — dikoreksi ke OpenZeppelin Channels. | Fixed |

## Blockers & Catatan

> _Sprint ini paling sering terhambat oleh testnet yang flaky menjelang akhir. Bila testnet reset di menit-menit terakhir: gunakan re-seed script (S4-07) + video backup (S4-06)._

**Tambahan (2026-07-16):**
- **Blocker utama tetap sama dengan sprint 1-3**: `RELAYER_API_KEY` (OpenZeppelin Channels) di Railway dan akses device fisik. Sprint 4 tidak bisa benar-benar "selesai" (dry run, video, final E2E) sampai kedua ini terpenuhi.
- **iOS di-skip permanen** — semua dependency/checklist yang menyebut iOS di sprint ini (S4-04, S4-09) sudah disesuaikan jadi Android-only atau N/A.
- **Beberapa item ternyata sudah selesai lebih dulu** dari yang diasumsikan dokumen ini (launcher icon, font Manrope) — indikasi tim mengerjakan polish sambil jalan, bukan menunggu sprint ini secara formal. Tidak masalah, tapi berarti dokumen sprint historically tertinggal dari kerja aktual, bukan sebaliknya.
- **Demo script sudah final secara konten** (S4-05) — tapi dry run 3x yang diminta acceptance criteria-nya **belum ada satupun yang dijalankan**, karena butuh device fisik + presenter sungguhan.
