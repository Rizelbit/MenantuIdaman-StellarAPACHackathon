# MVP Architecture & Build Plan — PS A: "Invisible Crypto Remittance"
### Panduan Teknis & Rencana Build untuk Hackathon Stellar — **Edisi Mobile (Flutter)**

> **Companion dokumen dari:** `PS-A_Remitansi-Tanpa-Paham-Crypto_Deep-Dive.md`
> **Status:** Draft rencana build v2 — **migrasi web → mobile native (Flutter)**
> **Perubahan utama dari v1:** Layer frontend berpindah dari **React/PWA** ke **Flutter (iOS + Android native)**. Konsekuensi terbesar ada di **mekanisme passkey** — dibahas tuntas di §2 & §9.
> **Keputusan tim (sudah difiksasi):**
> - **Diferensiasi utama:** UX "invisible crypto" — passkey, no seed phrase ⭐ (north star)
> - **Scope:** MVP inti (passkey onboarding + transfer USDC + mock off-ramp)
> - **Koridor:** default **Malaysia/Taiwan/HK → Indonesia** (gampang diganti, tidak mengubah arsitektur)
> - **Platform:** Flutter, **iOS + Android** (demo di dua-duanya)
> - **Passkey di Flutter:** **passkey native** (package `passkeys`) → assertion diteruskan ke backend Node yang tetap memakai Passkey Kit untuk merakit & submit tx. **Reuse wallet contract, nol Rust.**
> - **Arsitektur frontend:** **Riverpod + go_router**

---

## 0. North Star — satu kalimat yang mengikat semua keputusan

> **"User cukup pakai Face ID. Saldo tampil dalam dolar/rupiah. Keluarga terima rupiah. Kata 'crypto', 'wallet', 'seed phrase', 'gas' tidak pernah muncul di layar."**

Uji tiap keputusan: *"Apakah ini membuat produk lebih terasa seperti transfer bank, atau lebih terasa seperti crypto?"* Kalau "lebih crypto" → buang atau sembunyikan.

**Bonus dari pindah ke native:** app di App Store/Play look-and-feel = langsung terasa "aplikasi keuangan beneran", bukan "situs web crypto". Ini memperkuat north star secara gratis.

---

## 1. Definisi MVP — apa yang dibangun, di-mock, dan dibuang

Batas scope tegas = kunci selesai tepat waktu. **Jangan geser garis ini tanpa diskusi tim.**

### ✅ BUILD (yang benar-benar jalan)
| Fitur | Kenapa wajib |
|---|---|
| **Onboarding passkey** → smart wallet dibuat di background (biometrik native, no seed phrase) | Demo money-shot. Inti diferensiasi. |
| **Kirim "uang" (USDC/test-USD) antar wallet di Stellar Testnet** ~5 detik | Bukti settlement cepat |
| **Fee di-sponsor (Launchtube)** → user tak perlu XLM/gas | Bukti "no gas" — bagian invisible crypto |
| **UI transparansi biaya** ("Kirim Rp X → Terima Rp Y → Biaya Z") sebelum konfirmasi | Diferensiasi + jawab pain "user tak tahu biaya" |

### 🟡 MOCK (disimulasikan, tidak real)
| Bagian | Cara mock |
|---|---|
| **Off-ramp ke IDR** | Layar penerima "Rp X berhasil masuk ke rekening/e-wallet" — nilai dari kurs statik. Tidak ada anchor real. |
| **On-ramp / funding** | Fund wallet via Friendbot (testnet) atau saldo awal statik; UI seolah top-up kartu/bank |
| **KYC** | Layar KYC "sukses" instan (sebutkan SEP-12 sebagai jalur real di slide) |
| **Kurs FX** | Statik/hardcoded (sebutkan SEP-38 sebagai jalur real) |

### ❌ OUT OF SCOPE (sebut "future work" di pitch, jangan bangun)
Anchor production, likuiditas IDR real, lisensi VASP/MTO, KYC/AML penuh, social recovery penuh (boleh disinggung), multi-currency.

> **Catatan perubahan scope:** di v1, "aplikasi native mobile" tercatat *out of scope*. **Di v2 justru itu yang kita bangun** — jadi coret baris itu. Yang tetap out of scope adalah publish ke store; untuk demo cukup **install lokal / TestFlight / APK internal** di device presenter.

---

## 2. Arsitektur Sistem

### 2.1 Tiga layer

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1 — FRONTEND (Flutter, iOS + Android native)          │
│  • UI "invisible crypto": onboarding, kirim, riwayat, terima │
│  • package `passkeys` → registrasi & assertion passkey native │
│    (Face ID / Touch ID / Android biometric)                  │
│  • Riverpod (state) + go_router (navigasi)                    │
│  • Tampilkan saldo dalam $ / Rp, biaya transparan            │
└───────────────┬─────────────────────────────────────────────┘
                │ HTTPS (REST/JSON)
┌───────────────▼─────────────────────────────────────────────┐
│  LAYER 2 — BACKEND / RELAY (Node/Express + Passkey Kit)      │
│  • Terima attestation (registrasi) & assertion (sign) dari HP │
│  • Passkey Kit (server): rakit auth entry dari assertion      │
│    WebAuthn → tempel ke tx Soroban                           │
│  • PasskeyServer → orkestrasi + submit via Launchtube         │
│  • Simpan mapping user↔wallet, data mock off-ramp/KYC/FX      │
└───────────────┬─────────────────────────────────────────────┘
                │ Soroban RPC / Horizon
┌───────────────▼─────────────────────────────────────────────┐
│  LAYER 3 — ON-CHAIN (Stellar Testnet)                        │
│  • Smart wallet = contract account (dari Passkey Kit factory) │
│  • Verifikasi passkey (secp256r1) di __check_auth             │
│  • Transfer USDC/test-USD via SAC (Stellar Asset Contract)    │
└─────────────────────────────────────────────────────────────┘
```

> **Yang berubah dari v1 hanya Layer 1 + "jahitan" antara Layer 1↔2.** Layer 2 (Node + Passkey Kit + Launchtube) dan Layer 3 (contract + SAC) **identik dengan rencana web**. Inilah alasan pindah ke Flutter tidak membuang kerja backend/contract.

### 2.2 Kenapa "passkey native + backend rakit tx" (bukan WebView, bukan Secure Enclave)

Passkey Kit adalah SDK **TypeScript** yang di web menjalankan *seluruh* upacara WebAuthn di browser lalu merakit tx. Di Flutter native, kita **pecah tanggung jawabnya**:

- **HP (Flutter)** hanya bertugas memunculkan biometrik dan menghasilkan **assertion/attestation WebAuthn mentah** (via package `passkeys`). Private key **tidak pernah** keluar dari Secure Enclave / TEE device.
- **Backend (Node)** menerima assertion itu dan memakai **Passkey Kit server-side** untuk mem-parsing `secp256r1` public key (saat registrasi) dan menempel signature ke **auth entry** tx Soroban (saat sign), lalu submit via **Launchtube**.

Konsekuensi penting: **wallet contract dari Passkey Kit dipakai apa adanya** karena assertion kita adalah envelope WebAuthn asli (`authenticatorData` + `clientDataJSON` + signature) — persis yang diverifikasi `__check_auth`. **Nol baris Rust ditulis/diubah.** Ini menjaga de-risk terpenting dari v1.

> **Kenapa bukan Secure Enclave + raw secp256r1?** Lebih simpel di klien, tapi bukan envelope WebAuthn → kemungkinan besar harus **memodifikasi `__check_auth` (nyentuh Rust)**. Melanggar prinsip de-risk. Ditolak.
> **Kenapa bukan WebView?** Reuse maksimal tapi UX kurang native + upacara passkey di dalam WebView punya kuirk per-platform. Disimpan sebagai *fallback darurat* kalau integrasi native macet (lihat §9).

### 2.3 Flow A — Onboarding (buat wallet dengan passkey native)

```
User tap "Daftar"
  → Flutter panggil passkeys.register(challenge dari backend)
  → OS munculkan Face ID / biometrik → device buat passkey secp256r1
     terikat ke RP ID (domain kalian). Private key TIDAK keluar device.
  → Flutter kirim attestation (rawId, clientDataJSON, attestationObject) ke backend
  → Backend (Passkey Kit) ekstrak public key secp256r1 dari attestation
  → factory contract deploy smart wallet, register public key sebagai signer
  → fee deploy di-sponsor via Launchtube (user tak bayar apa-apa)
  → backend simpan mapping user ↔ contract address, balikin ke HP
  ✓ User punya wallet. Dia cuma merasa "sudah daftar pakai Face ID".
```

**Yang user LIHAT:** tombol daftar → prompt biometrik → "Akun kamu siap".
**Yang user TIDAK lihat:** contract deploy, public key, gas, sequence number, RP ID.

### 2.4 Flow B — Kirim uang → penerima terima "rupiah"

```
Pengirim masukkan nominal (Rp / $) + tujuan
  → UI tampilkan RINCIAN TRANSPARAN sebelum konfirmasi:
       "Kamu kirim Rp 1.000.000 | Keluarga terima Rp 995.000 | Biaya Rp 5.000 (0,5%)"
  → user tap "Kirim sekarang"
  → backend bangun tx Soroban (invoke SAC transfer wallet→wallet),
     hitung SIGNATURE PAYLOAD (hash auth entry)
  → Flutter panggil passkeys.authenticate(challenge = payload hash)
     → Face ID → device balikin assertion (authenticatorData, clientDataJSON, signature)
  → Flutter kirim assertion ke backend
  → backend (Passkey Kit) rakit auth entry dari assertion, tempel ke tx,
     submit via Launchtube (fee di-sponsor, user tak perlu XLM)
  → tx settle di Stellar (~5 detik)
  → [MOCK OFF-RAMP] sisi penerima: "Rp 995.000 masuk ke rekening BCA ****1234"
  ✓ Penerima tidak pernah lihat kata "USDC" atau "crypto".
```

**Titik integrasi paling rawan:** `challenge` yang dikirim ke `passkeys.authenticate` **harus** = payload hash yang sama dengan yang diverifikasi contract. Sinkronkan format encoding (base64url) klien↔backend lebih awal (§9 poin 3).

---

## 3. Tech Stack per Komponen

| Komponen | Teknologi | Catatan |
|---|---|---|
| **Frontend** | **Flutter (Dart)** — iOS + Android | Ganti dari React. Butuh Flutter SDK stabil terbaru. |
| **State management** | **Riverpod** (`flutter_riverpod`) | AsyncNotifier untuk flow onboarding/kirim |
| **Navigasi** | **go_router** | Rute bernama, gampang tambah screen hasil agent |
| **Passkey (client)** | **`passkeys` package** (Corbado) | `register()` / `authenticate()` → assertion WebAuthn native. **Pin versi**, verifikasi API saat integrasi. |
| **HTTP client** | **`dio`** | Panggil backend; interceptor, error handling |
| **Format uang/tanggal** | **`intl`** | Format Rp / $ (locale `id_ID`) |
| **Biometrik fallback** | **`local_auth`** (opsional) | HANYA fallback UX, **bukan** pengganti passkey/secp256r1 |
| **Backend/relay** | **Node + Express + Passkey Kit (server)** | **Tidak berubah dari v1.** Host PasskeyServer; parse assertion; proxy Launchtube |
| **Fee sponsorship** | **Launchtube** | Testnet token (self-service / #launchtube Discord). Menangani fee + sequence |
| **Smart wallet contract** | **Soroban — factory + wallet dari Passkey Kit** | **Reuse apa adanya, nol Rust** |
| **Token "uang"** | **USDC testnet** atau **test-USD** issue sendiri via SAC | UI selalu tampil "$"/"Rp" |
| **Network** | **Stellar Testnet** (+ Friendbot) | Jangan mainnet |
| **Tooling** | **Stellar CLI**, Soroban RPC, Horizon | Deploy & debug |
| **Associated Domains / Asset Links** | file `.well-known` di domain backend | **Wajib untuk passkey native** di iOS & Android (§9 poin 1) |

> **De-risk terbesar (tetap berlaku):** smart wallet contract **tidak ditulis dari awal** — Passkey Kit menyertakan factory + wallet. Karena kita pilih **passkey native (envelope WebAuthn)**, contract dipakai apa adanya → beban Rust tetap **nol**. Fokus energi di **UX Flutter + jahitan assertion klien↔backend**.

---

## 4. Checklist "Invisible Crypto" (kontrak UX — cek tiap item sebelum demo)

- [ ] Tidak ada input/tampilan **seed phrase** di mana pun.
- [ ] Tidak ada **private key / public key / RP ID / contract address** yang ditampilkan ke user.
- [ ] Tidak ada kata **"gas" / "XLM"** — fee di-sponsor, atau ditampilkan sebagai "biaya layanan Rp X".
- [ ] Saldo & nominal selalu dalam **$ atau Rp**, bukan jumlah token mentah.
- [ ] Sign transaksi = **biometrik native** (Face ID/fingerprint), bukan "approve in wallet".
- [ ] Onboarding **< 30 detik**, < 3 tap sampai wallet siap.
- [ ] Penerima **tidak pernah** melihat istilah crypto — cukup "Rp X masuk".
- [ ] Rincian biaya **transparan & muncul sebelum konfirmasi** (bukan setelah).
- [ ] Copy/bahasa UI istilah familiar: "kirim uang", "saldo", "biaya" — bukan "transfer USDC", "network fee".
- [ ] **Icon app, splash, nama app** terasa seperti aplikasi keuangan, bukan crypto (manfaatkan keuntungan native).

---

## 5. Rencana Build Bertahap

> Asumsi hackathon ~48 jam. **Sesuaikan dengan durasi aktual.** Prinsip: kejar **end-to-end tipis dulu** (onboarding → kirim → terima jalan meski jelek), baru poles.

| Fase | Fokus | Output | ~Alokasi |
|---|---|---|---|
| **Fase 0 — Setup** | Repo, env, testnet account, Stellar CLI, Launchtube token, deploy factory/wallet dari Passkey Kit, fund via Friendbot. **Flutter project + boilerplate ini jalan. Setup Associated Domains (iOS) + Asset Links (Android) + `.well-known` di domain backend.** | "Hello wallet" via script **DAN** app Flutter boot + bisa panggil biometrik dummy | **~6–8 jam** (naik dari v1 karena setup passkey native 2 platform) |
| **Fase 1 — Passkey onboarding** | `passkeys.register()` di Flutter → attestation ke backend → Passkey Kit ekstrak pubkey → deploy wallet. Uji di device fisik iOS **dan** Android. | User "daftar pakai Face ID" → wallet jadi, address tersimpan | ~6–8 jam |
| **Fase 2 — Kirim + fee sponsorship** | Backend bangun tx + payload; `passkeys.authenticate()` di Flutter; backend rakit auth entry + submit Launchtube. | Kirim uang jalan end-to-end di testnet | ~8–10 jam |
| **Fase 3 — Off-ramp mock + transparansi** | Layar penerima "Rp X masuk", kartu rincian biaya sebelum konfirmasi, kurs statik. | Alur pengirim→penerima terasa seperti bank | ~5–7 jam |
| **Fase 4 — Poles + demo** | UI polish (copy invisible-crypto, empty/loading/error states), icon+splash native, fix bug, skrip demo + slide. | Demo siap panggung di iOS & Android | ~6–8 jam |
| **Buffer** | Testnet flaky, passkey device/`.well-known` issue, marshaling assertion meleset | — | ~5 jam (naik dari v1) |

**Milestone kritis (kalau tertinggal, potong scope):**
- **Akhir Fase 0:** `passkeys.register()` memunculkan biometrik & mengembalikan attestation di **satu** device fisik → membuktikan Associated Domains/Asset Links benar. **Ini gerbang paling berisiko di edisi mobile — kalau `.well-known` salah, passkey tidak akan muncul.**
- **Akhir Fase 1:** passkey onboarding jalan → non-negotiable, ini diferensiasi.
- **Akhir Fase 2:** kirim jalan end-to-end → kalau macet, sederhanakan (dua wallet hardcoded, satu arah kirim).

---

## 6. Pembagian Tugas

| Role | Tanggung jawab utama | Skill |
|---|---|---|
| **Frontend / UX lead (Flutter)** | Semua layar (isi dari screen hasil agent → boilerplate), copy "invisible crypto", integrasi `passkeys` client, UI transparansi biaya | **Dart/Flutter, Riverpod, WebAuthn dasar** |
| **Backend / integration** | Passkey Kit server (parse attestation/assertion → auth entry), relay Launchtube, mock off-ramp/KYC/FX endpoint, host `.well-known` | Node/Express, Soroban RPC |
| **Contract / chain** | Deploy factory+wallet (Passkey Kit), setup token/SAC, testnet ops, debug tx | Stellar CLI, Rust dasar (baca) |
| **Demo / narrative** (rangkap) | Skrip demo, slide, uji alur end-to-end sebagai "user beneran" di HP, Q&A juri | Storytelling + paham produk |

> Tim kecil (2–3): satu pegang **Flutter+UX**, satu **Backend+Contract**, satu (rangkap) **Demo+integration testing**. **Frontend/UX Flutter adalah bottleneck** untuk diferensiasi — beri orang terbaik. Boilerplate di repo ini + workflow "screen hasil agent" (lihat `frontend/README.md`) dirancang untuk memangkas waktu di sini.

---

## 7. Resource / Bacaan per Orang

**Semua (wajib):**
- Smart Wallets (passkey, secp256r1): https://developers.stellar.org/docs/build/guides/contract-accounts/smart-wallets
- Passkeys — pengantar UX: https://stellar.org/blog/developers/passkeys-a-light-introduction-to-improving-blockchain-s-ux

**Frontend / UX (Flutter):**
- Package `passkeys` (Corbado) — API `register()`/`authenticate()`, setup iOS Associated Domains & Android Asset Links: https://pub.dev/packages/passkeys
- Riverpod docs: https://riverpod.dev — go_router: https://pub.dev/packages/go_router
- Passkey Kit (repo `passkey-kit`) — pola sign→submit sebagai referensi konsep (walau kita jalankan bagiannya di backend)
- **Boilerplate ini:** `frontend/README.md` (cara masukin screen hasil agent + prompt template)

**Backend / integration:**
- Launchtube (fee sponsorship / relay) + cara dapat token testnet (#launchtube Discord)
- Passkey Kit **server-side** — parse attestation/assertion, rakit auth entry
- WebAuthn envelope (authenticatorData / clientDataJSON) — pahami struktur agar marshaling klien↔backend benar
- Anchor & SEP (jalur off-ramp real yang di-mock): https://developers.stellar.org/docs/learn/fundamentals/anchors

**Contract / chain:**
- Stellar CLI + Soroban quickstart
- PoC passkey smart wallet (arsitektur referensi): https://cheesecakelabs.com/blog/building-a-passkey-enabled-smart-wallet-on-the-stellar-network/
- Protocol 21 (secp256r1/passkey): https://stellar.org/blog/developers/protocol-21-is-live-on-stellar-mainnet

> ⚠️ Tooling smart wallet + passkey (termasuk package `passkeys`) masih berkembang. **Pin versi** yang jalan, catat, jangan upgrade di tengah hackathon. Pakai Discord Stellar (#passkeys, #launchtube) kalau macet.

---

## 8. Skrip Demo untuk Juri (money-shot)

~3–4 menit. Demo yang bercerita > demo fitur.

1. **Buka dengan masalah (15 dtk).** "Pekerja migran Indonesia kirim pulang miliaran dolar tapi bayar 5–8% dan nunggu berhari-hari. Solusi crypto ada, tapi 90% orang kabur begitu lihat seed phrase."
2. **Onboarding live (30 dtk).** Buka **app di HP** → tap daftar → **Face ID** → "akun siap". Tekankan: *"Tidak ada seed phrase. Tidak ada wallet. Cuma Face ID — di aplikasi biasa, bukan browser."*
3. **Kirim uang live (45 dtk).** Masukkan Rp 1.000.000 → **rincian transparan** ("keluarga terima Rp 995.000, biaya Rp 5.000") → konfirmasi Face ID → **~5 detik** → selesai. Tekankan: *"Tidak ada gas. Tidak ada XLM. Tidak ada 'approve transaction'."*
4. **Sisi penerima (20 dtk).** Tunjukkan layar keluarga (HP kedua / device Android): *"Rp 995.000 masuk ke rekening."* Tekankan: *"Penerima tidak pernah tahu ini jalan di atas blockchain."*
5. **Reveal teknis (30 dtk).** Buka "kap mesin": *"Di balik layar — passkey secp256r1 native (Protocol 21 Stellar), USDC, fee di-sponsor via Launchtube, settlement 5 detik sub-sen. HP hanya pegang biometrik; backend rakit transaksinya."*
6. **Tutup (20 dtk).** Positioning + regulasi (remitansi + off-ramp via operator berlisensi) + future work (anchor real, koridor lain, publish ke store).

**Antisipasi pertanyaan juri:**
- *"Bedanya sama MoneyGram/Coins.ph?"* → UX passkey native tanpa seed phrase + fokus koridor Indonesia under-served + transparansi biaya.
- *"Legal di Indonesia?"* → Ya, sebagai remitansi lintas-batas + off-ramp ke IDR via VASP/MTO berlisensi; crypto tidak dipakai sebagai alat bayar domestik.
- *"Recovery kalau HP hilang?"* → Passkey bisa sync (iCloud Keychain / Google Password Manager) + roadmap social recovery/backup signer (smart wallet mendukung multi-signer). Di luar scope MVP.
- *"Kenapa native, bukan web?"* → Face ID di dalam app terasa seperti aplikasi bank; passkey terikat aman ke app via Associated Domains/Asset Links; distribusi via store.

---

## 9. Gotchas & Risiko Build (baca sebelum mulai)

1. **`.well-known` = gerbang passkey native (RISIKO #1 edisi mobile).** iOS butuh **Associated Domains** entitlement + file `apple-app-site-association` (`webcredentials`) di `https://<domain>/.well-known/`. Android butuh **Digital Asset Links** `assetlinks.json` (SHA-256 fingerprint signing key app) di `https://<domain>/.well-known/`. **Kalau salah, biometrik passkey tidak akan muncul sama sekali** — dan errornya sering senyap. Setup & uji di **Fase 0**, di device fisik.
2. **RP ID harus konsisten.** RP ID = domain yang meng-host `.well-known` = domain backend. Passkey terikat ke RP ID; ganti domain = passkey lama tak kepakai. Kunci satu domain sejak Fase 0.
3. **Sinkronkan `challenge`/payload klien↔backend.** `challenge` ke `passkeys.authenticate` harus = signature payload yang diverifikasi contract, dengan encoding sama (base64url). Salah satu byte → verifikasi `__check_auth` gagal. Bangun 1 test end-to-end tipis lebih dulu.
4. **Simulator vs device fisik.** iOS Simulator/Android Emulator dukungan passkey terbatas/berbeda. **Uji di HP fisik sejak awal**, idealnya HP presenter.
5. **Base reserve 0,5 XLM per entry.** Tiap akun/trustline butuh cadangan; sponsor/fund via Friendbot & Launchtube saat funding wallet baru.
6. **Launchtube token testnet** di-generate/di-minta di **Fase 0**. Jangan ketahuan kurang di Fase 2.
7. **Testnet bisa reset/flaky.** Jangan simpan state penting hanya on-chain; punya cara re-seed cepat + **rekaman video cadangan** demo.
8. **Pin versi `passkeys` + Passkey Kit + Stellar CLI.** Tooling ini "🚧". Catat versi yang jalan, jangan upgrade di tengah.
9. **Fallback darurat (kalau native passkey macet total di kedua platform):** bungkus flow Passkey Kit web dalam **WebView** untuk demo, atau untuk satu platform saja. Siapkan ini sebagai plan B, jangan bangun kecuali perlu.
10. **Jangan overbuild off-ramp.** Di-mock. Tahan godaan bikin real.

---

## 10. Definition of Done (MVP)

MVP "selesai & demo-ready" kalau:
- ✅ User bisa buat akun dengan **passkey native** (biometrik, no seed phrase) di **HP demo (iOS & Android)**.
- ✅ User bisa kirim "uang" ke penerima, sign dengan Face ID/biometrik, tanpa menyentuh XLM/gas.
- ✅ Transaksi settle di Stellar Testnet dalam ~detik dan terlihat di UI.
- ✅ Rincian biaya transparan muncul sebelum konfirmasi.
- ✅ Layar penerima menampilkan "Rp X masuk" (mock off-ramp).
- ✅ Seluruh alur bisa didemokan end-to-end tanpa menampilkan satu pun istilah crypto ke "user".
- ✅ App terinstall & jalan di device presenter (TestFlight/APK), icon+splash terasa "aplikasi keuangan".
- ✅ Skrip demo + slide siap, minimal 1 anggota bisa membawakannya lancar.

---

## Appendix — Link cepat

- Smart Wallets (docs): https://developers.stellar.org/docs/build/guides/contract-accounts/smart-wallets
- Passkeys intro: https://stellar.org/blog/developers/passkeys-a-light-introduction-to-improving-blockchain-s-ux
- Protocol 21: https://stellar.org/blog/developers/protocol-21-is-live-on-stellar-mainnet
- Anchors & SEP (off-ramp real): https://developers.stellar.org/docs/learn/fundamentals/anchors
- PoC passkey smart wallet: https://cheesecakelabs.com/blog/building-a-passkey-enabled-smart-wallet-on-the-stellar-network/
- `passkeys` (Flutter): https://pub.dev/packages/passkeys — Riverpod: https://riverpod.dev — go_router: https://pub.dev/packages/go_router
- Discord Stellar: #passkeys & #launchtube

---
*Rencana v2 mengasumsikan: (a) reuse Passkey Kit factory+wallet (nol Rust), dan (b) passkey native dengan backend merakit tx dari envelope WebAuthn. Langkah berikutnya yang bisa dibantu: draft endpoint backend (`/passkey/register-options`, `/wallet/create`, `/tx/build`, `/tx/submit`), draft slide pitch, atau breakdown milestone per jam sesuai durasi aktual.*
