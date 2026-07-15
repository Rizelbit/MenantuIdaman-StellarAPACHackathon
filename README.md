# Kirimin: Stellar-Based Digital Wallet for ASEAN Remittance

<img src="frontend/lib/assets/icon/Kirimin.svg" width=512 height=512 /> <br />

A cross-border remittance app built on the Stellar blockchain that feels like an ordinary banking app. Senders just use Face ID or a fingerprint, recipients get rupiah, and no seed phrase, gas fee, or crypto terminology ever shows up on screen.

This project was built for the Stellar Hackathon, under the Payment Consumer Applications (SEA) track.

## Project Description

Kirimin is a mobile app (Flutter, iOS and Android) for migrant workers sending money home to family in Indonesia. Under the hood, the transfer moves as USDC on the Stellar Testnet and settles in seconds. On the surface, the sender only sees Face ID, an amount in Rupiah, and a clear fee breakdown before confirming. The recipient just sees "Rp X has arrived in your account," with no blockchain terms anywhere.

Onboarding runs on a native passkey (secp256r1, supported since Stellar Protocol 21), so a smart wallet gets created behind the scenes without the user ever seeing a seed phrase or private key.

## Problem Statement

Migrant workers from Indonesia, the Philippines, and Vietnam send home more than $70 billion in combined remittances every year, but two problems keep eating into that money:

- **High fees.** The global average remittance fee is 6.36% (World Bank, Q3 2025), more than double the 3% target set by SDG 10.c. Conventional channels in Asia often charge 5-8%.
- **Slow settlement.** Traditional banks take 3-5 business days, routed through layers of correspondent banking.
- **Fee opacity.** An IOM survey of Indonesian migrant workers found that around 85% of respondents don't know the breakdown of fees they're paying, and 21% aren't even aware a service fee is being deducted at all.
- **The crypto barrier.** Stablecoin-based solutions already cut fees below 1.5% with settlement around 5 seconds, but the moment users have to understand seed phrases and wallets, roughly 60% of prospective users drop off right there, and more than 90% never complete their first transaction.
- **The Indonesia corridor is underserved.** Mature stablecoin players like MoneyGram on Stellar and Coins.ph focus on the Philippines corridor. The Malaysia/Taiwan/Hong Kong to Indonesia corridor is still wide open.

In Indonesia, crypto is legal to trade but illegal as a means of payment (the Currency Law makes rupiah the sole legal tender). That's why Kirimin is positioned as cross-border remittance with an off-ramp to IDR, not a stablecoin wallet for domestic transactions.

## Proposed Solution

Kirimin pairs Stellar's fast, cheap settlement with a UX that hides the entire crypto mechanism from the user:

| Feature | How it Works |
|---|---|
| Passkey onboarding | Native Face ID/fingerprint, smart wallet created in the background, no seed phrase |
| Fast money transfer | USDC/test-USD transfer on Stellar Testnet, settlement in about 5 seconds, sub-cent fees |
| Fee sponsorship | The backend acts as its own relayer via a signer key, so the user never needs to hold XLM |
| Fee transparency | The UI shows "You send X, family receives Y, fee is Z" before confirmation |
| Mock off-ramp | The recipient sees "Rp X has arrived in your account/e-wallet" (simulated; a real anchor integration is future work) |

The core flow:

1. **Onboarding:** user taps sign up, Face ID, backend deploys a smart wallet, ready to go.
2. **Send:** user enters an amount and recipient, the UI shows the fee breakdown, Face ID to sign, backend submits the transaction, settles within seconds.
3. **Receive:** the recipient's screen shows a simulated "Rp X has arrived" confirmation.

## Target Audience

- **Senders:** Indonesian migrant workers in Malaysia, Taiwan, Hong Kong, or similar corridors, who send money home regularly in small to mid-size amounts and aren't familiar with crypto wallet concepts.
- **Recipients:** family members in Indonesia who just need to see their bank or e-wallet balance go up in Rupiah, with no need to understand what happens behind it.

## Team and Roles

| Name | Role |
|---|---|
| Nicholas Andhika Lucas | Hipster |
| Stephanie Mae | Hustler |
| Samuelson Dharmawan | Hacker |
| Reinhard Alfonzo Hutabarat | Hacker |
| Edward David Rumahorbo | Hacker |

## Tech Stack

**Frontend**

| Technology | Purpose |
|---|---|
| Flutter (Dart), iOS and Android | Native mobile app |
| Riverpod | State management |
| go_router | Navigation |
| `passkeys` (Corbado) | Native passkey registration and authentication (Face ID/Touch ID/Android biometrics) |
| `dio` | HTTP client to the backend |

**Backend**

| Technology | Purpose |
|---|---|
| Node.js + Express + TypeScript | Relay server |
| `@stellar/stellar-sdk` | Interaction with the Stellar Testnet |
| `passkey-kit` | Parses WebAuthn attestation/assertion, assembles the Soroban auth entry |

**Chain**

| Technology | Purpose |
|---|---|
| Stellar Testnet (Soroban + Horizon) | Settlement network |
| Smart wallet from Passkey Kit | On-chain passkey verification (secp256r1) via `__check_auth` |
| USDC testnet / test-USD via SAC | Asset moved between wallets |

Fee sponsorship currently runs as backend self-relay: the server holds `SIGNER_SECRET_KEY` and submits transactions directly to the Soroban RPC. Launchtube was the original plan for this, but its official repo has since been archived and is no longer recommended for new projects, so the team switched to self-relay (with OpenZeppelin Relayer/Channels as a future production upgrade path). See `sprint/sprint-0-foundation.md` §S0-11 for the full decision log.

## Dependencies

**Backend** (`backend/package.json`)

- `express` ^4.19.2, `cors` ^2.8.5, `dotenv` ^16.4.5
- `@stellar/stellar-sdk` ^16.0.1
- `passkey-kit` ^0.14.0
- Dev: `typescript`, `tsx`, `vitest`, `eslint`, `@types/*`

**Frontend** (`frontend/pubspec.yaml`)

- `flutter_riverpod` ^3.3.2, `go_router` ^17.3.0
- `passkeys` ^2.4.0
- `dio` ^5.5.0
- `intl` ^0.20.3 (formats Rp/$ and dates, `id_ID` locale)
- `local_auth` ^3.0.2 (biometric UX fallback only, not a substitute for passkey)
- `cupertino_icons` ^1.0.8
- Dev: `flutter_lints`, `flutter_launcher_icons`

`passkeys`, `passkey-kit`, and the Stellar CLI versions are pinned deliberately, since passkey tooling in the Stellar ecosystem is still evolving fast.

## Installation

### Prerequisites

- Flutter SDK stable (3.22+)
- Node.js 20+
- Docker & Docker Compose (optional, for running the backend in a container)
- Stellar CLI (for testnet operations)

### Clone the repo

```bash
git clone <this-repo-url>
cd MenantuIdaman-StellarAPACHackathon
```

### Install dependencies

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
flutter pub get
```

## How to Run

### 1. Backend

```bash
cd backend
cp .env.example .env
# Fill in .env: RP_ID, STELLAR_NETWORK, SIGNER_SECRET_KEY, and the rest per the file's comments

npm run dev
```

The backend runs at `http://localhost:3000`.

### 2. Frontend

```bash
cd frontend
flutter pub get

# Use a physical Android/iOS device (native passkey doesn't work on emulators/simulators)
flutter run \
  --dart-define=BACKEND_URL=http://<backend-ip>:3000 \
  --dart-define=RP_ID=<backend-domain>
```

To try the UI without a backend or a physical device, run with `USE_MOCK=true` (the default). See `docs/frontend/backend_handoff.md` for the full mock-vs-real-endpoint contract.

> **Important:** `RP_ID` must match the domain hosting `/.well-known/` (iOS Associated Domains and Android Asset Links). See `docs/Flutter-Boilerplate-README.md` §6.

### 3. Docker (optional)

```bash
# Make sure backend/.env is filled in
docker-compose up --build
```

---

## Repository Structure

```
APACStellar/
├── .github/workflows/         # CI/CD GitHub Actions
├── backend/                   # Node/Express + Passkey Kit server
│   ├── src/                   # Entry point & endpoints
│   ├── .env.example           # Environment variable template
│   ├── Dockerfile             # Backend container
│   ├── package.json           # Node dependencies
│   └── tsconfig.json          # TypeScript config
├── contracts/                 # Soroban smart contract (reuses Passkey Kit)
├── docs/                      # Planning & research documents
├── frontend/                  # Flutter app (iOS + Android)
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md              # Frontend-specific guide
├── sprint/                    # Sprint status & non-sensitive config
├── AGENTS.md                  # Guide for AI coding agents
├── docker-compose.yml         # Local orchestration
├── .gitignore
└── README.md                  # This file
```

## Backend Endpoints (Contract)

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Health check |
| GET | `/passkey/register-options` | Generate a registration challenge for a passkey |
| POST | `/wallet/create` | Deploy a smart wallet from the passkey attestation |
| POST | `/tx/build` | Build the Soroban tx & return the sign challenge |
| POST | `/tx/submit` | Submit the signed tx |
| GET | `/wallet/:userId/balance` | Fetch the wallet balance |

---

## Limitations & Future Work

### Mocked (not real production)

- IDR off-ramp (a real SEP-24/31 anchor is future work).
- KYC/AML (simulated screen only).
- FX rate (static; SEP-38 is future work).
- On-ramp/funding (via Friendbot or a static starting balance).

### Out of Scope

- VASP/MTO licensing.
- Production anchor and real IDR liquidity.
- Full social recovery (can be added later; the smart wallet already supports multi-signer).
- Migrating fee sponsorship to OpenZeppelin Relayer/Channels (self-relay via signer key is enough for the testnet MVP).
