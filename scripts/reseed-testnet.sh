#!/bin/bash
# Re-seed script — jalankan setelah testnet reset atau untuk reset demo state.
# Prasyarat: Stellar CLI terinstall (`stellar --version`), keypair `deployer`,
# `demo-sender`, `demo-receiver` sudah pernah di-generate secara lokal
# (`stellar keys generate <nama> --network testnet --global`) sesuai
# sprint/CONFIG.md & sprint/SECRETS.md.
#
# CATATAN ARSITEKTUR: passkey-kit yang dipakai project ini adalah v1 — TIDAK
# ada factory contract untuk di-deploy ulang (lihat sprint/sprint-0-foundation.md
# S0-10). Wallet smart contract dibuat per-user lewat ceremony passkey asli di
# app (kit.createWallet()), jadi TIDAK BISA di-reseed lewat script — kalau
# testnet reset, wallet demo-sender/demo-receiver di app harus dibuat ulang
# dengan re-onboarding lewat app (bukan lewat script ini).
#
# Script ini HANYA meng-handle sisi akun Stellar mentah (funding + trustline),
# bukan wallet contract Passkey Kit.

set -e

echo "Funding accounts via Friendbot..."
stellar account fund deployer --network testnet
stellar account fund demo-sender --network testnet
stellar account fund demo-receiver --network testnet

echo "Adding USDC trustlines..."
USDC_ISSUER="GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5"

stellar tx new change-trust \
  --source demo-sender --network testnet \
  --asset "USDC:$USDC_ISSUER" --limit 10000

stellar tx new change-trust \
  --source demo-receiver --network testnet \
  --asset "USDC:$USDC_ISSUER" --limit 10000

echo "Funding demo-sender with USDC testnet..."
# TODO: mint test-USD atau gunakan faucet/AMM testnet (tanya di Discord Stellar #usdc)
# jika belum ada cara otomatis, isi manual sesuai S0-12.

echo ""
echo "Re-seed akun Stellar selesai."
echo "INGAT: wallet Passkey Kit (kit.createWallet) TIDAK ter-reseed oleh script ini."
echo "Kalau testnet reset & wallet demo hilang, buka app dan re-onboarding manual"
echo "untuk demo-sender & demo-receiver, lalu update DEMO_RECEIVER_CONTRACT di"
echo "Railway env vars dengan contract address wallet demo-receiver yang baru."
