# Kirimin — Sprint Index

Sprint plan untuk hackathon Stellar APAC. Seluruh sprint bersifat **feature/phase-based** (selesai bila milestone tercapai, bukan berbasis jam).

---

## Ringkasan Sprint

| Sprint | Nama | Goal Utama | Status |
|--------|------|-----------|--------|
| [Sprint 0](sprint-0-foundation.md) | Foundation | Environment, hosting, `.well-known`, testnet siap | `TODO` |
| [Sprint 1](sprint-1-passkey-onboarding.md) | Passkey Onboarding | Register passkey → smart wallet terdeploy end-to-end | `TODO` |
| [Sprint 2](sprint-2-send-flow.md) | Send Flow | Kirim uang → Face ID → settle testnet end-to-end | `TODO` |
| [Sprint 3](sprint-3-integration.md) | Integration Testing | Flutter terhubung ke backend real, uji di device fisik | `TODO` |
| [Sprint 4](sprint-4-polish-demo.md) | Polish & Demo | Invisible-crypto checklist, demo script, video backup | `TODO` |

---

## Urutan Eksekusi

```
Sprint 0 → Sprint 1 → Sprint 2 → Sprint 3 → Sprint 4
              ↑ tidak bisa mulai sebelum S0 selesai
```

Sprint 3 bisa mulai paralel dengan Sprint 2 (backend endpoint 3+4+5 belum selesai pun Flutter sudah bisa diuji dengan mock).

---

## Konvensi Issue ID

Format: `S<sprint>-<urutan>` — contoh `S0-03` = Sprint 0, issue ke-3.

## Konvensi Status

| Badge | Arti |
|-------|------|
| `TODO` | Belum dimulai |
| `IN_PROGRESS` | Sedang dikerjakan |
| `DONE` | Selesai & verified |
| `BLOCKED` | Tertahan, lihat catatan |
| `SKIPPED` | Diskip sadar, alasan dicatat |

## Konvensi Prioritas

| Level | Arti |
|-------|------|
| P0 | Blocker — sprint tidak bisa maju tanpa ini |
| P1 | Core — wajib selesai sebelum sprint done |
| P2 | Nice-to-have — bisa diskip bila waktu mepet |

---

## Risiko Global (baca sebelum mulai)

1. **RP_ID harus di-lock sejak Sprint 0.** Passkey terikat domain. Ganti domain = semua passkey test hangus.
2. **`.well-known` adalah gerbang.** Passkey biometrik tidak muncul kalau file ini salah atau tidak bisa diakses via HTTPS.
3. **Device fisik wajib.** Emulator/simulator tidak reliable untuk passkey native.
4. **Testnet bisa reset.** Simpan semua keypair & script re-seed. Siapkan video backup demo.
5. **`challenge` encoding.** `base64url` harus konsisten antara Flutter client, backend, dan contract `__check_auth`.
6. **Pin versi `passkeys` package & `@passkeykit/sdk`.** API keduanya masih berkembang.
