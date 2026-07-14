# Kirimin — Config Reference

File ini menyimpan nilai konfigurasi non-sensitif yang perlu diketahui seluruh tim.  
**Nilai sensitif (private key, token) ada di `SECRETS.md` yang tidak di-commit.**

---

## Domain & RP_ID

| Key | Value |
|-----|-------|
| **RP_ID** | menantuidaman-stellarapachackathon-production.up.railway.app |
| **Backend URL** | https://menantuidaman-stellarapachackathon-production.up.railway.app |

> ⚠️ **RP_ID TIDAK BOLEH BERUBAH** setelah passkey pertama dibuat. Ganti domain = semua passkey test hangus.

### Flutter dart-define (salin & isi)
```bash
flutter run \
  --dart-define=BACKEND_URL=https://menantuidaman-stellarapachackathon-production.up.railway.app \
  --dart-define=RP_ID=menantuidaman-stellarapachackathon-production.up.railway.app
```

---

## iOS

| Key | Value |
|-----|-------|
| **Team ID** | `PLACEHOLDER` — butuh Apple Developer Program ($99/thn) |
| **Bundle ID** | `com.example.kirimin` (default Flutter) |
| **Associated Domains** | `webcredentials:menantuidaman-stellarapachackathon-production.up.railway.app` |

---

## Android

| Key | Value |
|-----|-------|
| **Application ID** | `com.example.kirimin` (default Flutter, ganti kalau ubah Bundle ID) |
| **Debug SHA-256** | `54:4E:87:DD:1E:1C:29:A5:D1:A0:2F:65:28:AF:91:67:AC:40:D0:E1:CC:35:61:18:8C:55:9A:16:BA:B4:12:D3` |

---

## Stellar Testnet

| Key | Value |
|-----|-------|
| **Soroban RPC URL** | `https://soroban-testnet.stellar.org` |
| **Horizon URL** | `https://horizon-testnet.stellar.org` |
| **Friendbot URL** | `https://friendbot.stellar.org` |
| **USDC Testnet Issuer** | `GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5` |
| **Factory Contract ID** | _(isi setelah S0-10 selesai)_ |
| **Deployer Public Key** | _(isi setelah S0-09 selesai)_ |
| **Demo Sender Public Key** | _(isi setelah S0-12 selesai)_ |
| **Demo Receiver Public Key** | _(isi setelah S0-12 selesai)_ |
| **Demo Receiver Contract Address** | _(isi setelah smart wallet penerima dibuat)_ |

---

## Package Versions (pin setelah verify)

| Package | Version | Notes |
|---------|---------|-------|
| Stellar CLI | _(isi)_ | `stellar --version` |
| PasskeyKit npm package | _(isi nama & versi, hasil S1-01)_ | |
| `passkeys` Flutter package | `^2.4.0` | pin setelah S1-06 verified |

---

## Railway Deployment

| Key | Value |
|-----|-------|
| **Project Name** | _(isi)_ |
| **Service URL** | https://menantuidaman-stellarapachackathon-production.up.railway.app |
| **Port** | 8080 |
| **Root Directory** | `backend` |
| **Build** | Dockerfile |

---

## Launchtube

| Key | Value |
|-----|-------|
| **URL** | `https://launchtube.xyz` _(atau URL yang diberikan)_ |
| **Token** | Di `SECRETS.md` |
