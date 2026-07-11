# Kirimin — Invisible Crypto Remittance

Aplikasi remitansi lintas-batas berbasis **Stellar blockchain** yang terasa seperti aplikasi bank biasa. Pengirim cukup pakai **Face ID / fingerprint**, penerima terima rupiah — tanpa seed phrase, tanpa gas, tanpa istilah crypto di layar.

> **North star:** _"User cukup pakai Face ID. Saldo tampil dalam Rupiah. Keluarga terima Rupiah. Kata 'crypto', 'wallet', 'seed phrase', 'gas' tidak pernah muncul di layar."_

---

## Masalah yang Diangkat

- **Biaya remitansi tinggi:** pekerja migran Indonesia/Filipina/Vietnam masih membayar 5–8% lewat jalur konvensional.
- **Settlement lambat:** bank tradisional butuh 3–5 hari kerja.
- **Barrier crypto:** ~60% calon user kabur ketika bertemu seed phrase; >90% tidak selesaikan transaksi pertama.
- **Koridor Indonesia under-served:** kompetitor stablecoin paling matang fokus ke Filipina.

## Solusi (MVP)

| Fitur | Cara Kerja |
|---|---|
| **Onboarding passkey** | Face ID / fingerprint native → smart wallet dibuat di background, no seed phrase. |
| **Kirim uang cepat** | Transfer USDC/test-USD di Stellar Testnet, settlement ~5 detik, fee sub-sen. |
| **Fee sponsorship** | Launchtube menangani gas/fee — user tak perlu pegang XLM. |
| **Transparansi biaya** | UI jelas: "Kamu kirim X → Keluarga terima Y → Biaya Z" sebelum konfirmasi. |
| **Off-ramp mock** | Penerima lihat "Rp X masuk ke rekening/e-wallet" (simulasi, anchor real = future work). |

---

## Struktur Repositori

```
APACStellar/
├── .github/workflows/         # CI/CD GitHub Actions
├── backend/                   # Node/Express + Passkey Kit server
│   ├── src/                   # Entry point & endpoint
│   ├── .env.example           # Template environment variables
│   ├── Dockerfile             # Container backend
│   ├── package.json           # Dependencies Node
│   └── tsconfig.json          # TypeScript config
├── contracts/                 # Soroban smart contract (reuse Passkey Kit)
├── docs/                      # Dokumen perencanaan & riset
│   ├── PS-A_Remitansi-Tanpa-Paham-Crypto_Deep-Dive.md
│   ├── PS-A_MVP-Architecture-Build-Plan_Flutter.md
│   └── Flutter-Boilerplate-README.md
├── frontend/                  # Flutter app (iOS + Android)
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md              # Panduan khusus frontend
├── AGENTS.md                  # Panduan untuk AI coding agents
├── docker-compose.yml         # Orkestrasi lokal
├── .gitignore
└── README.md                  # File ini
```

---

## Cara Menjalankan

### Prasyarat

- Flutter SDK stable (3.22+)
- Node.js 20+
- Docker & Docker Compose (opsional, untuk backend container)
- Stellar CLI (untuk deploy contract)

### 1. Backend

```bash
cd backend
cp .env.example .env
# Edit .env: isi RP_ID, STELLAR_NETWORK, LAUNCHTUBE_TOKEN, FACTORY_CONTRACT_ID, SIGNER_SECRET_KEY

npm install
npm run dev
```

Backend akan berjalan di `http://localhost:3000`.

### 2. Frontend

```bash
cd frontend
flutter pub get

# Pastikan device Android/iOS fisik (passkey native tidak jalan di emulator/simulator).
flutter run \
  --dart-define=BACKEND_URL=http://<ip-backend>:3000 \
  --dart-define=RP_ID=<domain-backend>
```

> **Penting:** RP_ID harus sama dengan domain yang meng-host `/.well-known/` (iOS Associated Domains & Android Asset Links). Lihat `docs/Flutter-Boilerplate-README.md` §6.

### 3. Docker (opsional)

```bash
# Pastikan backend/.env sudah diisi
docker-compose up --build
```

---

## Endpoint Backend (Kontrak)

| Method | Path | Deskripsi |
|---|---|---|
| GET | `/health` | Health check |
| GET | `/passkey/register-options` | Generate challenge untuk registrasi passkey |
| POST | `/wallet/create` | Deploy smart wallet dari attestation passkey |
| POST | `/tx/build` | Bangun tx Soroban & kembalikan challenge sign |
| POST | `/tx/submit` | Submit tx yang sudah di-sign via Launchtube |
| GET | `/wallet/:userId/balance` | Ambil saldo wallet |

Detail lengkap: `docs/Flutter-Boilerplate-README.md` §8.

---

## Alur Implementasi MVP

1. **Onboarding:** user tap daftar → Face ID → backend deploy smart wallet → siap pakai.
2. **Kirim:** user input nominal & penerima → UI rincian biaya → Face ID untuk sign → backend submit tx → settle ~5 detik.
3. **Terima:** mock layar "Rp X masuk ke rekening".

Arsitektur detail ada di `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md`.

---

## Batasan & Future Work

### Yang Di-Mock (bukan real production)

- Off-ramp ke IDR (anchor SEP-24/31 real = future work).
- KYC/AML (hanya layar simulasi).
- Kurs FX (statik, SEP-38 = future work).
- On-ramp / funding (via Friendbot/saldo awal statik).

### Out of Scope

- Lisensi VASP/MTO.
- Anchor production & likuiditas IDR real.
- Social recovery penuh (bisa ditambahkan nanti; smart wallet mendukung multi-signer).

---

## Kontribusi Tim

| Role | Folder Utama |
|---|---|
| Frontend / UX | `frontend/lib/` |
| Backend / Relay | `backend/src/` |
| Contract / Chain | `contracts/` |
| Demo / Narrative | `docs/` + slide terpisah |

Lihat `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §6 untuk pembagian tugas detail.

---

## Catatan Penting

- **Jangan commit private key / `.env`!** `.env` sudah di-ignore.
- **Passkey native wajib device fisik** dan `.well-known` yang benar. Emulator tidak bisa diandalkan.
- **Pin versi** `passkeys`, Passkey Kit, dan Stellar CLI — tooling masih berkembang.
- **Stellar Testnet** bisa reset; selalu siapkan rekam video cadangan untuk demo.

---

## Lisensi

Proyek hackathon — internal team use. Untuk go-to-market nyata, konsultasikan aspek lisensi VASP/MTO dengan ahli hukum.
