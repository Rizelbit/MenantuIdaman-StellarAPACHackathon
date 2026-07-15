# Sprint Malam Ini — MVP Target

## Target
**MVP demo-ready**: Onboarding passkey → Kirim uang → SendSuccessScreen  
**Deadline**: Malam ini (beberapa jam)  
**Prinsip**: Kejar end-to-end tipis dulu, polish belakangan

---

## Status Saat Ini

| Komponen | Status | Keterangan |
|----------|--------|------------|
| Frontend Flutter | ✅ Boilerplate lengkap | 8 screen, services, state management siap |
| Backend Node | ⚠️ Skeleton saja | Health check + .well-known, endpoint kosong |
| .well-known | ✅ Ada | apple-app-site-association + assetlinks.json |
| PasskeyKit package | ✅ Terinstall | `passkey-kit@^0.14.0` |
| Stellar SDK | ✅ Terinstall | `@stellar/stellar-sdk@^16.0.1` |

---

## Sprint Tasks — Prioritas P0 (Wajib Malam Ini)

### Phase 1: Backend Core (Target: 2-3 jam)

| # | Task | Status | Priority |
|---|------|--------|----------|
| 1.1 | Buat `backend/src/passkey.ts` — PasskeyKit server singleton | `TODO` | P0 |
| 1.2 | Buat `backend/src/store.ts` — In-memory user/tx store | `TODO` | P0 |
| 1.3 | Implement `GET /passkey/register-options` | `TODO` | P0 |
| 1.4 | Implement `POST /wallet/create` | `TODO` | P0 |
| 1.5 | Implement `POST /tx/build` | `TODO` | P0 |
| 1.6 | Implement `POST /tx/submit` | `TODO` | P0 |
| 1.7 | Implement `GET /wallet/:userId/balance` | `TODO` | P0 |

### Phase 2: Integration & Testing (Target: 1-2 jam)

| # | Task | Status | Priority |
|---|------|--------|----------|
| 2.1 | Verifikasi PasskeyKit API — cek method names yang benar | `TODO` | P0 |
| 2.2 | Test endpoint dengan curl/mock | `TODO` | P0 |
| 2.3 | Verifikasi Flutter `WalletApi` match dengan backend response | `TODO` | P0 |

### Phase 3: E2E Testing (Target: 1 jam)

| # | Task | Status | Priority |
|---|------|--------|----------|
| 3.1 | Run backend locally (`npm run dev`) | `TODO` | P0 |
| 3.2 | Run Flutter di device fisik | `TODO` | P0 |
| 3.3 | Test onboarding flow | `TODO` | P0 |
| 3.4 | Test send flow | `TODO` | P0 |

---

## Sprint Tasks — Prioritas P1 (Jika Ada Waktu)

| # | Task | Status | Priority |
|---|------|--------|----------|
| P1-1 | Polish error messages (Bahasa Indonesia) | `TODO` | P1 |
| P1-2 | Verify invisible-crypto checklist | `TODO` | P1 |
| P1-3 | Rekam video backup demo | `TODO` | P1 |

---

## Blockers & Dependencies

### Blocker Utama
1. **PasskeyKit API belum diverifikasi** — Method names di pseudocode mungkin berbeda dengan actual package
2. **Launchtube token belum ada** — Diperlukan untuk fee sponsorship
3. **Factory Contract ID belum ada** — Diperlukan untuk deploy wallet

### Workaround untuk Malam Ini
- **Tanpa Launchtube**: Simulasi fee sponsorship di backend (mock response)
- **Tanpa Factory Contract**: Gunakan mock wallet creation untuk testing UI flow
- **Tanpa device fisik**: Test UI flow dengan mock data dulu

---

## Quick Start Commands

### Backend
```bash
cd backend
cp .env.example .env
# Edit .env dengan nilai yang sesuai
npm run dev
```

### Frontend
```bash
cd frontend
flutter run --dart-define=BACKEND_URL=http://localhost:3000 --dart-define=RP_ID=localhost
```

---

## Catatan Penting

1. **Jangan over-engineer** — Fokus ke happy path saja
2. **Mock jika perlu** — Lebih baik ada demo mock daripada tidak ada demo sama sekali
3. **Test di device fisik** — Passkey hanya jalan di device fisik
4. **Backup plan** — Siapkan video recording jika E2E gagal

---

## Next Steps

1. ✅ Environment setup (DONE)
2. 🔄 Implement backend endpoints
3. ⏳ Integration testing
4. ⏳ E2E testing di device fisik
