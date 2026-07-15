# AGENTS.md — Panduan untuk AI Coding Agents

Dokumen ini berisi aturan dan konteks khusus untuk agen/AI yang membantu mengembangkan proyek **Kirimin**.

---

## 1. Visi Produk

Kirimin adalah aplikasi remitansi lintas-batas berbasis Stellar yang **tidak terasa seperti crypto**. North star:

> _"User cukup pakai Face ID. Saldo tampil dalam Rupiah. Keluarga terima Rupiah. Kata 'crypto', 'wallet', 'seed phrase', 'gas' tidak pernah muncul di layar."_

Setiap keputusan teknis harus menguatkan north star. Kalau sebuah fitur membuat produk terasa lebih "crypto", tolak atau sembunyikan.

---

## 2. Struktur Repositori

```
APACStellar/
├── backend/      # Node/Express + Passkey Kit server
├── contracts/    # Soroban smart contract (reuse Passkey Kit, jangan tulis dari nol)
├── docs/         # Dokumen perencanaan
├── frontend/     # Flutter app (Riverpod + go_router)
├── .github/      # CI/CD
├── docker-compose.yml
├── README.md
└── AGENTS.md     # File ini
```

---

## 3. Aturan per Komponen

### Frontend (Flutter)

- Ikuti kontrak screen di `frontend/lib/screens/`. Lihat `docs/Flutter-Boilerplate-README.md` §4.
- Screen hanya membaca state & memanggil aksi. **Jangan panggil `WalletApi`/`PasskeyService` langsung dari screen.**
- Warna, teks, spacing **hanya** dari `app/theme.dart`.
- Uang selalu lewat `formatMoney(...)` / `SendQuote`.
- Navigasi via `context.goNamed(Routes.x)`.
- Copy Bahasa Indonesia, active voice, dari sisi user.
- Dilarang keras muncul kata: crypto, wallet, seed phrase, gas, XLM, USDC, blockchain, token, contract address, private/public key.

### Backend (Node/Express)

- Terima assertion/attestation WebAuthn dari Flutter, lalu rakit auth entry Soroban via Passkey Kit.
- Submit tx via Launchtube (fee sponsorship).
- Endpoint kontrak: `docs/Flutter-Boilerplate-README.md` §8.
- **Jangan commit secret key / `.env`.**

### Contracts

- **Jangan tulis smart wallet dari nol.** Reuse factory + wallet dari Passkey Kit.
- Nol modifikasi Rust `__check_auth` untuk MVP.

---

## 4. Risiko Build Utama

1. **`.well-known` harus benar** — passkey native tidak muncul kalau iOS Associated Domains atau Android Asset Links salah.
2. **RP_ID konsisten** — frontend, backend, dan `.well-known` harus pakai domain yang sama.
3. **Challenge/payload sinkron** — `challenge` ke `passkeys.authenticate()` harus sama persis dengan signature payload yang diverifikasi contract (`base64url`).
4. **Device fisik** — emulator/simulator dukungan passkey terbatas. Selalu uji di HP fisik.
5. **Testnet flaky** — siapkan fallback/rekaman demo.

---

## 5. Workflow untuk Agen

1. **Baca dulu** dokumen relevan di `docs/` sebelum ubah kode.
2. **Minimal change** — ubah seperlunya, jangan over-engineer.
3. **Test** setelah mengubah kode (backend: `npm run lint && npm run test`; frontend: `flutter analyze`). **Untuk frontend, selesaikan SEMUA temuan di file yang disentuh** — bukan cuma error compile, juga info/lint seperti const yang harus di-hoist ke widget terluar, urutan argumen `child`/`bottom` (letakkan `child` terakhir), dan `library;` setelah dangling doc comment. `flutter_lints` sudah aktif di `analysis_options.yaml`; jangan tinggalkan temuan bersih-bersih untuk manusia.
4. **Jangan commit** atau push kecuali diminta eksplisit.
5. **Jangan install package global** — gunakan `npm` lokal di `backend/` atau `pubspec.yaml` di `frontend/`.

---

## 6. Prompt Cepat untuk Generate Screen

Untuk membuat screen Flutter baru, gunakan template di `docs/Flutter-Boilerplate-README.md` §5.

---

## 7. Stack & Versi

- Flutter stable 3.22+
- Node.js 20+
- `passkeys` package (pin versi saat integrasi)
- Passkey Kit (pin versi)
- Stellar Testnet
- Riverpod + go_router
