:Well-Known Files for Passkey Native

Folder ini berisi file-file yang wajib di-host di domain backend agar passkey native berfungsi di iOS dan Android.

## File yang Diperlukan

- `apple-app-site-association` — untuk iOS Associated Domains (`webcredentials:<domain>`).
- `assetlinks.json` — untuk Android Digital Asset Links (berisi SHA-256 fingerprint signing key aplikasi).

## Catatan

- Domain yang meng-host file ini harus sama dengan `RP_ID` di frontend dan backend.
- File ini harus bisa diakses publik via HTTPS.
- Lihat `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §9 untuk detail risiko & setup.
