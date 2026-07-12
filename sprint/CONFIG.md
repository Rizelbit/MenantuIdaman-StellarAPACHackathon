# Kirimin — Config Reference

File ini menyimpan nilai konfigurasi non-sensitif yang perlu diketahui seluruh tim.  
**Nilai sensitif (private key, token) ada di `SECRETS.md` yang tidak di-commit.**

---

## Domain & RP_ID

| Key | Value |
|-----|-------|
| **RP_ID** | _(isi setelah S0-01 selesai)_ |
| **Backend URL** | _(isi setelah S0-01 selesai, format: `https://...`)_ |

> ⚠️ **RP_ID TIDAK BOLEH BERUBAH** setelah passkey pertama dibuat. Ganti domain = semua passkey test hangus.

### Flutter dart-define (salin & isi)
```bash
flutter run \
  --dart-define=BACKEND_URL=https://<isi-railway-domain> \
  --dart-define=RP_ID=<isi-railway-domain-tanpa-https>
```

---

## iOS

| Key | Value |
|-----|-------|
| **Team ID** | _(isi dari developer.apple.com)_ |
| **Bundle ID** | _(isi dari Xcode → Signing & Capabilities)_ |
| **Associated Domains** | `webcredentials:<RP_ID>` |

---

## Android

| Key | Value |
|-----|-------|
| **Application ID** | _(isi dari `android/app/build.gradle` → `applicationId`)_ |
| **Debug SHA-256** | _(isi dari `keytool -list -v -keystore ~/.android/debug.keystore ...`)_ |

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
| **Service URL** | _(sama dengan Backend URL di atas)_ |
| **Root Directory** | `backend` |
| **Build** | Dockerfile |

---

## Launchtube

| Key | Value |
|-----|-------|
| **URL** | `https://launchtube.xyz` _(atau URL yang diberikan)_ |
| **Token** | Di `SECRETS.md` |
