# Backend Handoff — Kirimin

How to connect a real Node backend to the Flutter screens that already exist. The
frontend is built and navigable today; it runs on mock data so the UI can be demoed
with no backend. This document is the contract the backend must satisfy to replace
that mock data with real Stellar transactions.

Read alongside: `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` (§2 flows, §3 stack,
§9 gotchas), `docs/Flutter-Boilerplate-README.md` (§3 data flow, §8 endpoint contract),
and `sprint/sprint-1-passkey-onboarding.md` / `sprint/sprint-2-send-flow.md` (the
intended `backend/src/{index,passkey,store}.ts` implementation).

---

## 1. Current state: the app runs on mock data

The whole app is navigable right now with no backend and no passkey device, because
of a prototype flag. See `frontend/lib/app/env.dart`:

```dart
static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);
```

When `useMock` is true, `frontend/lib/state/providers.dart` injects
`MockWalletApi` and `MockPasskeyService` (in `frontend/lib/services/mock_services.dart`)
instead of the real `WalletApi` (HTTP) and `PasskeyService` (native passkey). Every
mock method returns an `Ok(...)` with sample data, so onboarding and send complete
locally.

`mock_services.dart` is your specification by example: each mock method is labeled
with the real endpoint it stands in for, and the `Ok(...)` value shows the exact shape
the real endpoint must return.

## 2. How to switch to the real backend

The frontend needs no code change to talk to a real backend. Pass three build time
values:

```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=BACKEND_URL=https://<your-backend-domain> \
  --dart-define=RP_ID=<your-backend-domain>
```

- `USE_MOCK=false` swaps the mocks for the real `WalletApi` + `PasskeyService`.
- `BACKEND_URL` is the base URL the HTTP client (`dio`) calls.
- `RP_ID` is the passkey Relying Party ID. It MUST equal the domain that hosts
  `/.well-known/` (which is the backend domain). A wrong value means the biometric
  prompt never appears. See §7.

Passkey also needs a physical device and correct `.well-known` files (§7). The mock
lets you demo the UI on a simulator or desktop; the real passkey path needs a real
phone.

## 3. HTTP endpoint contract (authoritative)

The shapes below are exactly what `frontend/lib/services/wallet_api.dart` sends and
reads. The client is `dio`, connect timeout 15s, receive timeout 30s. Any connection
error surfaces to the user as "Koneksi terputus"; other errors as a generic message.
The backend does ALL Soroban work; the phone only produces raw WebAuthn envelopes.

### 3.1 GET /passkey/register-options

Ask for a registration challenge.

- Query: `?userName=<string>`
- Response the client reads:
```json
{ "challenge": "string (base64url)", "userId": "string" }
```
- `challenge` must be base64url (characters `A-Za-z0-9-_`, no padding). `userId` is
  server generated (a UUID is fine). Stash the challenge keyed by `userId` for one time
  use in `/wallet/create`.

### 3.2 POST /wallet/create

Deploy the smart wallet from the registration attestation.

- Request body:
```json
{
  "userId": "string",
  "attestation": {
    "credentialId": "string (base64url rawId)",
    "clientDataJSON": "string (base64url)",
    "attestationObject": "string (base64url)"
  }
}
```
- Response the client reads (parsed by `Wallet.fromJson`):
```json
{ "userId": "string", "contractAddress": "string", "balanceUsd": 0 }
```
- `contractAddress` is internal only and is never shown to the user. `balanceUsd` is a
  number. Backend work: parse the attestation, extract the secp256r1 public key, deploy
  the Passkey Kit factory wallet, register the key as signer, sponsor the fee via
  Launchtube, store `userId to contractAddress to credentialIds`.

### 3.3 POST /tx/build

Build a transfer and return the payload the phone must sign.

- Request body:
```json
{ "userId": "string", "recipient": "string", "amountUsd": 0 }
```
- Response the client reads:
```json
{ "txId": "string", "challenge": "string (base64url)", "credentialIds": ["string"] }
```
- `challenge` here is the transaction signature payload (the auth entry hash), base64url.
  The phone passes it unchanged into `passkeys.authenticate()`. `credentialIds` is the
  set of allowed credential IDs for that sender. Cache `txId to {xdr, challenge, userId}`.

### 3.4 POST /tx/submit

Attach the signature and submit.

- Request body:
```json
{
  "txId": "string",
  "assertion": {
    "credentialId": "string",
    "clientDataJSON": "string (base64url)",
    "authenticatorData": "string (base64url)",
    "signature": "string (base64url)"
  }
}
```
- Response the client reads:
```json
{ "txId": "string" }
```
- On HTTP 200 the client marks the transfer settled. Note: `recipientName` and
  `receiveIdr` in the Dart method are UI only; they are NOT sent to the backend, so the
  settled transaction display is built on the phone from what the user typed. Backend
  work: assemble the Soroban auth entry from the assertion, attach it to the cached XDR,
  submit via Launchtube, wait for settle (about 5 seconds).

### 3.5 GET /wallet/:userId/balance

Refresh the balance after a send.

- Path param: `userId`
- Response the client reads:
```json
{ "balanceUsd": 0 }
```
- Read as a number. Query the smart wallet USDC (SAC) balance via Soroban RPC; fall back
  to a cached value on RPC error.

## 4. Passkey envelope shapes

Field name detail that will bite you: the Dart property is `clientDataJson`, but the
JSON key on the wire is `clientDataJSON` (capital JSON). Read and write `clientDataJSON`.

The envelopes are defined in `frontend/lib/models/models.dart` and produced in
`frontend/lib/services/passkey_service.dart` from the `passkeys` package:

- Registration (attestation), sent inside `/wallet/create`:
  `{ credentialId, clientDataJSON, attestationObject }` from `passkeys.register()`
  (`res.id`, `res.clientDataJSON`, `res.attestationObject`).
- Signing (assertion), sent inside `/tx/submit`:
  `{ credentialId, clientDataJSON, authenticatorData, signature }` from
  `passkeys.authenticate()` (`res.id`, `res.clientDataJSON`, `res.authenticatorData`,
  `res.signature`).

The registration ceremony the backend should mirror (see `passkey_service.dart`):
Relying Party `id = RP_ID`, name `Kirimin`; `pubKeyCredParams alg = -7` (ES256 /
secp256r1, which the Stellar smart wallet verifies); `residentKey` and `userVerification`
required; platform authenticator. The assertion uses `relyingPartyId = RP_ID` and
`allowCredentials` set to the `credentialIds` from `/tx/build`.

## 5. The two flows end to end

### A. Onboarding (screen action to wallet)
1. User taps "Buat akun dengan Face ID" on `OnboardingScreen`.
2. `GET /passkey/register-options?userName=...` returns `{challenge, userId}`.
3. `passkeys.register(...)` on the phone returns the attestation envelope.
4. `POST /wallet/create {userId, attestation}` deploys the wallet and returns
   `{userId, contractAddress, balanceUsd}`.
5. The app navigates to `HomeScreen` and shows the balance.

### B. Send (amount to settled)
1. `SendAmountScreen` to `SendReviewScreen`, then the user confirms with the Face ID
   sheet, which calls `sendController.confirmAndSend()`.
2. `POST /tx/build {userId, recipient, amountUsd}` returns `{txId, challenge, credentialIds}`.
3. `passkeys.authenticate(challenge, allowCredentials=credentialIds)` returns the
   assertion envelope.
4. `POST /tx/submit {txId, assertion}` submits via Launchtube and returns `{txId}`.
5. `SendSuccessScreen`, then `GET /wallet/:userId/balance` refreshes the Home balance.

## 6. Where each mock maps to a real call

In `frontend/lib/services/mock_services.dart`:

| Mock method | Real endpoint | What the real one must return |
|---|---|---|
| `MockWalletApi.registerOptions` | GET /passkey/register-options | `{challenge, userId}` |
| `MockWalletApi.createWallet` | POST /wallet/create | `{userId, contractAddress, balanceUsd}` |
| `MockWalletApi.buildSendTx` | POST /tx/build | `{txId, challenge, credentialIds}` |
| `MockWalletApi.submitSignedTx` | POST /tx/submit | `{txId}` |
| `MockWalletApi.getBalanceUsd` | GET /wallet/:userId/balance | `{balanceUsd}` |
| `MockPasskeyService.register` | native `passkeys.register()` | attestation envelope |
| `MockPasskeyService.authenticate` | native `passkeys.authenticate()` | assertion envelope |

Delete nothing in the frontend to go live. Just set `USE_MOCK=false`.

## 7. Backend responsibilities and config

Per the build plan and sprints:

- Passkey Kit server (`PasskeyServer`): on register, parse the attestation and extract
  the secp256r1 public key; on sign, assemble the Soroban auth entry from the assertion
  (`authenticatorData` + `clientDataJSON` + `signature`) and attach it to the transaction.
  Reuse the Passkey Kit factory and wallet contract as is. No Rust.
- Launchtube fee sponsorship: sponsor both the deploy fee and the submit fee and sequence,
  so the user never holds XLM.
- State (in memory is fine for the MVP): `userId to contractAddress to credentialIds to
  balanceUsd`; a pending challenge store (userId to challenge, one time use); a pending
  transaction store (txId to `{xdr, challenge, userId}`, cleared after submit).
- Mock on the backend for the demo (real path noted in the docs): the IDR off ramp (the
  receiver "Rp X masuk" screen uses a static rate), KYC (instant success, real path is
  SEP-12), and FX (static rate, real path is SEP-38).

Config the backend needs (from the sprint pseudocode): `FACTORY_CONTRACT_ID`,
`SIGNER_SECRET_KEY`, `LAUNCHTUBE_TOKEN`, `LAUNCHTUBE_URL`, `SOROBAN_RPC_URL`,
`HORIZON_URL`, `STELLAR_NETWORK`, `USDC_ISSUER` (testnet default
`GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5`), and a demo receiver contract.

Two correctness gates that cause most failures (build plan §9):

1. base64url everywhere. The `/tx/build` `challenge` must be byte identical to the payload
   the contract `__check_auth` verifies. Confirm the `clientDataJSON.challenge` inside the
   returned assertion matches. One wrong byte fails verification silently.
2. `.well-known` hosting. The backend domain must serve `apple-app-site-association` (iOS
   `webcredentials`) and `assetlinks.json` (Android SHA-256 signing fingerprint). `RP_ID`
   must equal that domain. Wrong or missing files mean the biometric prompt never shows.

## 8. Units and formatting (already handled on the phone)

The phone shows Rupiah and never raw tokens. `frontend/lib/core/money.dart` and
`frontend/lib/app/env.dart` hold the static FX rate (`usdToIdr = 16350`) and the service
fee (`feeRate = 0.005`). `amountUsd` on the wire is US dollars; the phone converts to and
from Rupiah for display. USDC on Stellar uses 7 decimals (1 USDC = 10,000,000 stroops).
