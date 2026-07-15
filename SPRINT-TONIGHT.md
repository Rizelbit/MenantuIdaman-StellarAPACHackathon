# Sprint Malam Ini — MVP Target

## Target
**MVP demo-ready**: Onboarding passkey → Kirim uang → SendSuccessScreen  
**Deadline**: Malam ini (beberapa jam)  
**Prinsip**: Kejar end-to-end tipis dulu, polish belakangan

> **Update (2026-07-15):** File ini sudah usang — Phase 1 (backend core) ternyata **sudah selesai semua** sejak commit sebelumnya, bukan `TODO`. Jangan implement ulang. Sisa kerja malam ini murni **testing di device fisik**, lihat `NEXT_STEPS.md` di root repo untuk langkah detailnya. Detail audit lengkap ada di `sprint/sprint-0-foundation.md` s/d `sprint-3-integration.md`.

---

## Status Saat Ini

| Komponen | Status | Keterangan |
|----------|--------|------------|
| Frontend Flutter | ✅ Boilerplate lengkap | 19 screen, services, state management siap |
| Backend Node | ✅ **Sudah lengkap** | Semua 5 endpoint kontrak (`docs/frontend/backend_handoff.md` §3) + `/home/:userId/feed` stub sudah diimplementasi |
| .well-known | ✅ Live di Railway | Content-Type sudah benar, package name `com.kirimin.app` |
| PasskeyKit package | ✅ Terinstall | `passkey-kit@^0.14.0`, arsitektur v1 (no factory contract) |
| Stellar SDK | ✅ Terinstall | `@stellar/stellar-sdk@^16.0.1` |
| Launchtube | ❌ **Di-skip permanen** | Deprecated, tidak dipakai — backend self-relay via `SIGNER_SECRET_KEY`. Lihat S0-11. |

---

## Sprint Tasks — Prioritas P0 (Wajib Malam Ini)

### Phase 1: Backend Core — **SUDAH SELESAI, jangan kerjakan ulang**

| # | Task | Status | Priority |
|---|------|--------|----------|
| 1.1 | Buat `backend/src/passkey.ts` — PasskeyKit server singleton | `FINISHED` | P0 |
| 1.2 | Buat `backend/src/store.ts` — In-memory user/tx store | `FINISHED` | P0 |
| 1.3 | Implement `GET /passkey/register-options` | `FINISHED` | P0 |
| 1.4 | Implement `POST /wallet/create` | `FINISHED` | P0 |
| 1.5 | Implement `POST /tx/build` | `FINISHED` | P0 |
| 1.6 | Implement `POST /tx/submit` | `FINISHED` | P0 |
| 1.7 | Implement `GET /wallet/:userId/balance` | `FINISHED` | P0 |
| 1.8 | Implement `GET /home/:userId/feed` (stub minimal) | `FINISHED` | P0 |

### Phase 2: Integration & Testing

| # | Task | Status | Priority | Catatan |
|---|------|--------|----------|---------|
| 2.1 | Verifikasi PasskeyKit API — cek method names yang benar | `FINISHED` | P0 | Kode sudah pakai `kit.createWallet`, `kit.connectWallet`, `kit.sign` sesuai `passkey-kit@^0.14.0` |
| 2.2 | Test endpoint dengan curl/mock | `TODO` | P0 | Belum dites live dengan curl manual, tapi contract audit manual (lihat di bawah) sudah cocok |
| 2.3 | Verifikasi Flutter `WalletApi` match dengan backend response | `FINISHED` | P0 | Diaudit manual field-per-field terhadap `sprint/sprint-3-integration.md` §S3-01 — **semua 5 endpoint match, tidak ada mismatch** |

**PENTING — jebakan yang mudah kelewat:** `frontend/lib/app/env.dart` punya flag `USE_MOCK` yang **default `true`**. Kalau flag ini tidak di-set `false`, app SELALU pakai `MockWalletApi`/`MockPasskeyService` — tidak pernah menyentuh backend asli sama sekali, walau `BACKEND_URL` sudah diisi benar! `frontend/run-dev.sh` **sudah diperbaiki** untuk selalu pass `--dart-define=USE_MOCK=false`. Kalau menjalankan `flutter run` manual (bukan lewat `run-dev.sh`), WAJIB tambahkan flag ini juga, contoh:
```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=BACKEND_URL=https://menantuidaman-stellarapachackathon-production.up.railway.app \
  --dart-define=RP_ID=menantuidaman-stellarapachackathon-production.up.railway.app
```

### Phase 3: E2E Testing di Device Fisik — **INI SISA KERJA UTAMA MALAM INI**

| # | Task | Status | Priority |
|---|------|--------|----------|
| 3.1 | Isi env vars Railway (terutama `SIGNER_SECRET_KEY` — jangan pakai placeholder) | Cek `NEXT_STEPS.md` §1 | P0 |
| 3.2 | Run Flutter di device fisik dengan `USE_MOCK=false` | `TODO` | P0 |
| 3.3 | Test onboarding flow (passkey biometrik harus benar-benar muncul) | `TODO` | P0 |
| 3.4 | Test send flow (perlu 2 device/2 akun demo, atau isi `DEMO_RECEIVER_CONTRACT`) | `TODO` | P0 |

---

## Sprint Tasks — Prioritas P1 (Jika Ada Waktu)

| # | Task | Status | Priority |
|---|------|--------|----------|
| P1-1 | Polish error messages (Bahasa Indonesia) | `TODO` | P1 |
| P1-2 | Verify invisible-crypto checklist | `TODO` | P1 |
| P1-3 | Rekam video backup demo | `TODO` | P1 |

---

## Blockers & Dependencies

### Blocker Utama (update 2026-07-15 — daftar lama sudah tidak berlaku)
1. ~~PasskeyKit API belum diverifikasi~~ — sudah diverifikasi, kode backend sudah pakai method yang benar.
2. ~~Launchtube token belum ada~~ — **tidak relevan**, Launchtube di-skip permanen (S0-11), jangan cari token ini.
3. ~~Factory Contract ID belum ada~~ — **tidak relevan**, `passkey-kit` v1 tidak pakai factory contract (S0-10).
4. **Blocker sekarang**: `SIGNER_SECRET_KEY` di Railway env vars masih placeholder pada satu titik — pastikan sudah diisi value asli dari `sprint/SECRETS.md` sebelum testing (lihat percakapan/`NEXT_STEPS.md` §1). Tanpa ini, `/wallet/create` gagal total.
5. **Blocker iOS**: Team ID Apple Developer masih placeholder — butuh akun berbayar ($99/thn). Kalau tidak ada, demo Android-only saja (lihat `NEXT_STEPS.md` §2).
6. Belum ada satupun test end-to-end di device fisik sungguhan — semua yang "selesai" di atas baru diverifikasi lewat audit kode/API, bukan run aktual di HP.

### Workaround untuk Malam Ini
- **Tanpa device fisik**: Test UI flow dengan mock data dulu (`USE_MOCK=true`, default) — tapi ingat ini TIDAK menguji passkey/backend asli sama sekali, cuma UI/navigasi.
- **Tanpa iOS**: Demo Android saja kalau Team ID belum ada.

---

## Quick Start Commands

### Backend
```bash
cd backend
cp .env.example .env
# Edit .env dengan nilai yang sesuai (lihat sprint/CONFIG.md dan sprint/SECRETS.md)
npm run dev
```

### Frontend — TEST MELAWAN BACKEND ASLI (bukan mock)
```bash
cd frontend
./run-dev.sh -d <device-id>
# atau manual, WAJIB include USE_MOCK=false:
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=BACKEND_URL=http://localhost:3000 \
  --dart-define=RP_ID=localhost
```

---

## Catatan Penting

1. **Jangan over-engineer** — Fokus ke happy path saja
2. **Backend sudah lengkap, jangan reimplement** — kerjaan malam ini adalah testing, bukan coding backend dari nol
3. **Selalu pakai `USE_MOCK=false` saat test backend asli** — kalau lupa, kamu cuma testing UI mock dan mengira sudah selesai padahal belum
4. **Test di device fisik** — Passkey hanya jalan di device fisik
5. **Backup plan** — Siapkan video recording jika E2E gagal

---

## Next Steps

1. ✅ Environment setup (DONE)
2. ✅ Implement backend endpoints (DONE)
3. ✅ Integration testing / API contract audit (DONE — lihat Phase 2 di atas)
4. ⏳ E2E testing di device fisik — lihat `NEXT_STEPS.md` untuk langkah lengkap
