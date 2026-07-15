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
| **Bundle ID** | `com.kirimin.app` |
| **Associated Domains** | `webcredentials:menantuidaman-stellarapachackathon-production.up.railway.app` — sudah di `Runner.entitlements`, tinggal isi Team ID untuk signing |

---

## Android

| Key | Value |
|-----|-------|
| **Application ID** | `com.kirimin.app` |
| **Debug SHA-256** | `54:4E:87:DD:1E:1C:29:A5:D1:A0:2F:65:28:AF:91:67:AC:40:D0:E1:CC:35:61:18:8C:55:9A:16:BA:B4:12:D3` |

---

## Stellar Testnet

| Key | Value |
|-----|-------|
| **Soroban RPC URL** | `https://soroban-testnet.stellar.org` |
| **Horizon URL** | `https://horizon-testnet.stellar.org` |
| **Friendbot URL** | `https://friendbot.stellar.org` |
| **USDC Testnet Issuer** | `GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5` |
| **Wallet WASM Hash** (testnet) | `fdefad64b96837147e1c333e51f537b696eab925e9f147e63d597c04e3c903f0` |
| **Wallet WASM Size** | 34.105 bytes (sudah terupload di testnet, tx: `3507c407…`) |
| **Canonical Deployer** (passkey-kit v1) | `GC2C7AWLS2FMFTQAHW3IBUB4ZXVP4E37XNLEF2IK7IVXBB6CMEPCSXFO` |
| **Canonical Deployer Seed** | `sha256("kalepail")` — jangan diubah |
| **Deployer Public Key** (kita) | `GCLC34ARATQ6OATCJLEOAGTAFTKD45H5VSKNO2EPJQHHNEYNZGJ4OAQ7` |
| **Deployer Balance** | 10000 XLM (terverifikasi via Horizon API 2026-07-15) |
| **Demo Sender Public Key** | `GCUA7JMJ7MAWFV2SNFIHGN6XCNEZGIMUMDHSB6QVAPZJEPE666OFID6R` |
| **Demo Receiver Public Key** | `GCWFVMEWRVLMU7ON4Y7W5UNJUFEWOMEEHJGRZJHEBUWNZNB3A3HCJ2H4` |
| **Demo Sender Balance** | 1000 testUSD + 10000 XLM (testnet) |
| **Test USD Issuer** | `GBSE5FGT3TIWD6AUAR2B47FAZWJNI7GSZIGTDFJLLGYQUP5653GCQANS` |
| **Demo Receiver Contract Address** | _(isi setelah smart wallet penerima dibuat)_ |

---

## Package Versions (pin setelah verify)

| Package | Version | Notes |
|---------|---------|-------|
| Stellar CLI | `27.0.0` | `stellar --version` |
| PasskeyKit npm package | `passkey-kit@^0.14.0` | v1 arsitektur (no factory contract) |
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

## Fee Sponsorship

| Key | Value |
|-----|-------|
| **Approach** | Backend relayer pakai deployer's XLM (MVP). Upgrade ke OpenZeppelin Channels untuk production. |
| **Relayer API Key** | _(isi nanti — dari https://channels.openzeppelin.com/testnet/gen)_ |
