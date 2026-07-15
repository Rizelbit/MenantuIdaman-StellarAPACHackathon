import cors from "cors";
import crypto from "crypto";
import dotenv from "dotenv";
import express, { type Request, type Response } from "express";

dotenv.config();

import {
  bridge,
  getKit,
  getServer,
  USDC_ISSUER,
  waitForBridge,
} from "./passkey.js";
import { store, registrationStore, txStore } from "./store.js";

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// SAC USDC address di testnet (derived dari issuer)
const USDC_SAC_ADDRESS = process.env.USDC_SAC_ADDRESS || "CBQHFCBIFPYBMV7CCMB3Y3I3IDP3UMP3XKZZGQZ2EVTESNQ6H7GNCNC";

// ---------------------------------------------------------------------------
// Static: .well-known files untuk passkey native (iOS & Android)
// `apple-app-site-association` tidak punya extension, jadi express.static
// tidak bisa infer MIME type-nya dan default ke application/octet-stream.
// iOS mensyaratkan Content-Type: application/json untuk file ini.
// ---------------------------------------------------------------------------
app.use(
  "/.well-known",
  express.static("public/.well-known", {
    setHeaders: (res, path) => {
      if (path.endsWith("apple-app-site-association") || path.endsWith(".json")) {
        res.setHeader("Content-Type", "application/json");
      }
    },
  })
);

// ---------------------------------------------------------------------------
// Health check
// ---------------------------------------------------------------------------
app.get("/health", (_req: Request, res: Response) => {
  res.json({ ok: true, service: "kirimin-backend", env: process.env.NODE_ENV });
});

// ---------------------------------------------------------------------------
// 1) GET /passkey/register-options
// ---------------------------------------------------------------------------
app.get("/passkey/register-options", async (req: Request, res: Response) => {
  const userName = (req.query.userName as string)?.trim();
  if (!userName) {
    return res.status(400).json({ error: "userName required" });
  }

  const userId = crypto.randomUUID();

  try {
    const kit = await getKit();

    // Mulai createWallet di background — ini akan memanggil
    // bridge.startRegistration() yang menyimpan options dan menunggu.
    const createPromise = kit.createWallet("Kirimin", userName);

    // Tunggu sampai bridge punya registration options (max 15 detik)
    await waitForBridge(() => bridge.hasPendingRegistration(), 15000);

    const options = bridge.getRegistrationOptions()!;
    // Konversi challenge ke base64url (tanpa padding)
    const challenge = Buffer.from(options.challenge, "base64")
      .toString("base64url")
      .replace(/=+$/, "");

    // Simpan promise untuk dipakai di /wallet/create
    registrationStore.set(userId, { createPromise });

    return res.json({ challenge, userId });
  } catch (err) {
    console.error("[register-options] error:", err);
    bridge.completeRegistration({} as any);
    return res.status(500).json({ error: "Gagal membuat opsi registrasi" });
  }
});

// ---------------------------------------------------------------------------
// 2) POST /wallet/create
// ---------------------------------------------------------------------------
app.post("/wallet/create", async (req: Request, res: Response) => {
  const { userId, attestation } = req.body as {
    userId: string;
    attestation: {
      credentialId: string;
      clientDataJSON: string;
      attestationObject: string;
    };
  };

  if (!userId || !attestation) {
    return res.status(400).json({ error: "userId and attestation required" });
  }

  const pending = registrationStore.get(userId);
  if (!pending) {
    return res.status(400).json({ error: "No pending registration for this userId" });
  }

  try {
    // Selesaikan ceremony WebAuthn di bridge
    bridge.completeRegistration({
      id: attestation.credentialId,
      rawId: attestation.credentialId,
      response: {
        clientDataJSON: attestation.clientDataJSON,
        attestationObject: attestation.attestationObject,
      },
      type: "public-key",
    });

    // Tunggu kit.createWallet() selesai
    const result = await pending.createPromise;

    // Submit deploy tx via relayer (fee-sponsored)
    const srv = await getServer();
    const submitResult = await srv.send(result.signedTx);
    if (!submitResult.success) {
      const err = (submitResult as any).error;
      console.error("[wallet/create] deploy failed:", err);
    } else {
      console.log(`[wallet/create] deploy tx: ${submitResult.hash}`);
    }

    console.log(`[wallet/create] wallet: ${result.contractId}`);

    // Simpan mapping user ↔ wallet
    store.set(userId, {
      userId,
      contractAddress: result.contractId,
      credentialIds: [result.keyIdBase64],
      balanceUsd: 0,
      userName: "",
    });

    registrationStore.delete(userId);

    return res.json({
      userId,
      contractAddress: result.contractId,
      balanceUsd: 0,
    });
  } catch (err) {
    console.error("[wallet/create] error:", err);
    registrationStore.delete(userId);
    return res.status(500).json({ error: "Gagal membuat wallet" });
  }
});

// ---------------------------------------------------------------------------
// 3) POST /tx/build
// ---------------------------------------------------------------------------
app.post("/tx/build", async (req: Request, res: Response) => {
  const { userId, recipient, amountUsd } = req.body as {
    userId: string;
    recipient: string;
    amountUsd: number;
  };

  if (!userId || !recipient || !amountUsd || amountUsd <= 0) {
    return res.status(400).json({ error: "userId, recipient, and amountUsd required" });
  }

  const senderRecord = store.get(userId);
  if (!senderRecord) {
    return res.status(404).json({ error: "Wallet not found" });
  }

  // Resolve penerima
  const allUsers = store.all();
  const receiverRecord = allUsers.find((u) => u.userId !== userId);
  const receiverContractAddress =
    receiverRecord?.contractAddress ||
    process.env.DEMO_RECEIVER_CONTRACT ||
    "";

  if (!receiverContractAddress) {
    return res.status(400).json({ error: "Penerima tidak ditemukan" });
  }

  try {
    const kit = await getKit();

    // Pastikan wallet ter-connect
    if (!kit.contractId || kit.contractId !== senderRecord.contractAddress) {
      const keyId = senderRecord.credentialIds[0];
      if (keyId) {
        await kit.connectWallet({ keyId });
      }
    }

    // Hitung amount dalam stroops (1 USDC = 10_000_000 stroops)
    const amountStroops = BigInt(Math.round(amountUsd * 10_000_000));

    // Build transfer tx via SACClient
    const { SACClient } = await import("passkey-kit");
    const sacClient = new SACClient({
      rpcUrl: process.env.SOROBAN_RPC_URL || "https://soroban-testnet.stellar.org",
      networkPassphrase: "Test SDF Network ; September 2015",
    });
    const token = sacClient.getSACClient(USDC_SAC_ADDRESS);

    const tx = await token.transfer({
      from: senderRecord.contractAddress,
      to: receiverContractAddress,
      amount: amountStroops,
    });

    // Sign tx dengan passkey — ini memicu bridge.startAuthentication()
    const signPromise = kit.sign(tx as any);

    // Tunggu bridge punya authentication options
    await waitForBridge(() => bridge.hasPendingAuthentication(), 15000);

    const authOptions = bridge.getAuthenticationOptions()!;
    const challenge = Buffer.from(authOptions.challenge, "base64")
      .toString("base64url")
      .replace(/=+$/, "");

    const txId = crypto.randomUUID();

    // Simpan pending tx
    txStore.set(txId, { signPromise, userId });

    return res.json({
      txId,
      challenge,
      credentialIds: senderRecord.credentialIds,
    });
  } catch (err) {
    console.error("[tx/build] error:", err);
    return res.status(500).json({ error: "Gagal membangun transaksi" });
  }
});

// ---------------------------------------------------------------------------
// 4) POST /tx/submit
// ---------------------------------------------------------------------------
app.post("/tx/submit", async (req: Request, res: Response) => {
  const { txId, assertion } = req.body as {
    txId: string;
    assertion: {
      credentialId: string;
      clientDataJSON: string;
      authenticatorData: string;
      signature: string;
    };
  };

  if (!txId || !assertion) {
    return res.status(400).json({ error: "txId and assertion required" });
  }

  const pending = txStore.get(txId);
  if (!pending) {
    return res.status(404).json({ error: "Transaction not found or expired" });
  }

  try {
    // Selesaikan ceremony authentication di bridge
    bridge.completeAuthentication({
      id: assertion.credentialId,
      rawId: assertion.credentialId,
      response: {
        clientDataJSON: assertion.clientDataJSON,
        authenticatorData: assertion.authenticatorData,
        signature: assertion.signature,
      },
      type: "public-key",
    });

    // Tunggu kit.sign() selesai
    const signedTx = await pending.signPromise;

    // Submit via relayer
    const srv = await getServer();
    const submitResult = await srv.send(signedTx as any);
    if (!submitResult.success) {
      const err = (submitResult as any).error;
      console.error("[tx/submit] submit failed:", err);
      return res.status(500).json({ error: "Gagal mengirim transaksi" });
    }

    console.log(`[tx/submit] settled: ${submitResult.hash}`);
    txStore.delete(txId);

    return res.json({ txId, txHash: submitResult.hash });
  } catch (err) {
    console.error("[tx/submit] error:", err);
    return res.status(500).json({ error: "Gagal mengirim transaksi" });
  }
});

// ---------------------------------------------------------------------------
// 5) GET /wallet/:userId/balance
// ---------------------------------------------------------------------------
app.get("/wallet/:userId/balance", async (req: Request, res: Response) => {
  const { userId } = req.params;
  const userRecord = store.get(userId);

  if (!userRecord) {
    return res.status(404).json({ error: "Wallet not found" });
  }

  try {
    // TODO: query actual balance dari chain
    return res.json({ balanceUsd: userRecord.balanceUsd });
  } catch (err) {
    console.error("[balance] error:", err);
    return res.json({ balanceUsd: userRecord.balanceUsd });
  }
});

// ---------------------------------------------------------------------------
// 6) GET /home/:userId/feed
// ---------------------------------------------------------------------------
// Stub minimal — cukup untuk HomeScreen lolos dari homeFeedProvider tanpa error.
// promos/favoriteContacts/recentTransactions sengaja kosong (belum ada
// endpoint /contacts, /requests, /splits di backend; itu di luar scope MVP
// "onboarding -> kirim uang -> SendSuccessScreen").
const USD_TO_IDR = 16350; // sama dengan Env.usdToIdr statis di Flutter (frontend/lib/app/env.dart)

app.get("/home/:userId/feed", (req: Request, res: Response) => {
  const { userId } = req.params;
  const userRecord = store.get(userId);

  if (!userRecord) {
    return res.status(404).json({ error: "Wallet not found" });
  }

  return res.json({
    balanceIdr: userRecord.balanceUsd * USD_TO_IDR,
    greetingName: userRecord.userName || "Kamu",
    accountRef: userRecord.contractAddress,
    promos: [],
    favoriteContacts: [],
    recentTransactions: [],
  });
});

// ---------------------------------------------------------------------------
// Start server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`Kirimin backend listening on port ${PORT}`);
  console.log(`RP_ID: ${process.env.RP_ID || "localhost"}`);
  console.log(`Network: ${process.env.STELLAR_NETWORK || "testnet"}`);
});
