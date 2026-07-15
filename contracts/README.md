# Contracts

Folder ini berisi smart contract Soroban untuk **Kirimin**.

## Prinsip

Untuk MVP hackathon, **kita tidak menulis smart wallet dari nol**. Kita menggunakan wallet dari [Passkey Kit](https://github.com/stellar/passkey-kit) apa adanya, karena Flutter menghasilkan envelope WebAuthn asli (authenticatorData + clientDataJSON + signature) yang langsung diverifikasi oleh `__check_auth` contract.

> **Update arsitektur:** Passkey Kit yang dipakai adalah **v1** (`passkey-kit@^0.14.0`), yang **tidak memakai factory contract**. Sebagai gantinya, wallet WASM di-upload sekali ke testnet lalu di-deploy per-user langsung dari canonical deployer Passkey Kit — tidak ada `FACTORY_CONTRACT_ID` untuk dicatat. Lihat `sprint/CONFIG.md` § Stellar Testnet untuk **Wallet WASM Hash** dan **Canonical Deployer**, dan `sprint/sprint-0-foundation.md` § S0-10 untuk detail keputusan.

## Isi Folder

- `wasm/` — artefak WASM hasil build (tidak di-commit, di-generate saat build)

## Langkah Setup

1. Install Stellar CLI.
2. Upload wallet WASM Passkey Kit ke Stellar Testnet (bila belum ada — biasanya sudah tersedia dari canonical deployer, lihat `sprint/CONFIG.md`).
3. Backend deploy wallet per-user saat registrasi via `kit.createWallet()` (`PasskeyKit` di-init di `backend/src/passkey.ts` dengan `walletWasmHash`, dipanggil dari `backend/src/index.ts`), bukan lewat factory contract.
4. Fund contract deployer via Friendbot.

## Out of Scope MVP

- Modifikasi Rust `__check_auth`
- Deploy stablecoin sendiri (gunakan USDC testnet atau test-USD via SAC)
- Social recovery penuh (boleh dijadikan future work)

Lihat `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §3 untuk detail arsitektur contract.
