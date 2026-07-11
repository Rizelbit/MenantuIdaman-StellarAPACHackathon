# Contracts

Folder ini berisi smart contract Soroban untuk **Kirimin**.

## Prinsip

Untuk MVP hackathon, **kita tidak menulis smart wallet dari nol**. Kita menggunakan factory + wallet dari [Passkey Kit](https://github.com/stellar/passkey-kit) apa adanya, karena Flutter menghasilkan envelope WebAuthn asli (authenticatorData + clientDataJSON + signature) yang langsung diverifikasi oleh `__check_auth` contract.

## Isi Folder

- `factory/` — deployment & referensi factory contract Passkey Kit (jika perlu disesuaikan)
- `wasm/` — artefak WASM hasil build (tidak di-commit, di-generate saat build)

## Langkah Setup

1. Install Stellar CLI.
2. Deploy factory Passkey Kit ke Stellar Testnet.
3. Catat `FACTORY_CONTRACT_ID` di `backend/.env`.
4. Fund contract deployer via Friendbot.

## Out of Scope MVP

- Modifikasi Rust `__check_auth`
- Deploy stablecoin sendiri (gunakan USDC testnet atau test-USD via SAC)
- Social recovery penuh (boleh dijadikan future work)

Lihat `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §3 untuk detail arsitektur contract.
