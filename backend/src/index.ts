import cors from "cors";
import crypto from "crypto";
import dotenv from "dotenv";
import express, { type Request, type Response } from "express";

import {
  bridge,
  getKit,
  getServer,
  getUsdcBalance,
  waitForBridge,
} from "./passkey.js";
import {
  contactStore,
  requestStore,
  splitStore,
  store,
  transactionStore,
  registrationStore,
  txStore,
} from "./store.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

const NETWORK_PASSPHRASE = "Test SDF Network ; September 2015";
const USD_TO_IDR = 16350; // sinkron dengan frontend Env.usdToIdr

// ---------------------------------------------------------------------------
// Static: .well-known files untuk passkey native (iOS & Android)
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
// Helpers
// ---------------------------------------------------------------------------
function initialsOf(name: string): string {
  const trimmed = name.trim().toUpperCase();
  if (trimmed.length === 0) return "?";
  const parts = trimmed.split(/\s+/);
  if (parts.length === 1) {
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1);
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

function makeReference(): string {
  const hex = crypto.randomBytes(3).toString("hex").toUpperCase();
  return `KRM-${hex}`;
}

async function resolveRecipient(userId: string, recipient: string): Promise<string | null> {
  // 1) recipient itu userId langsung
  const byUserId = store.get(recipient);
  if (byUserId) return byUserId.contractAddress;

  // 2) recipient itu contract address
  const byContract = store.all().find((u) => u.contractAddress === recipient);
  if (byContract) return byContract.contractAddress;

  // 3) recipient adalah nama kontak; gunakan accountRef-nya sebagai alamat penerima
  const contact = contactStore.listByUser(userId).find((c) => c.name === recipient);
  if (contact?.accountRef) {
    const contactUser = store.get(contact.accountRef);
    if (contactUser) return contactUser.contractAddress;
    // accountRef bisa langsung contract address
    if (contact.accountRef.startsWith("C")) return contact.accountRef;
  }

  // 4) fallback demo receiver
  const demoReceiver = process.env.DEMO_RECEIVER_CONTRACT;
  return demoReceiver || null;
}

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
    const createPromise = kit.createWallet("Kirimin", userName);

    await waitForBridge(() => bridge.hasPendingRegistration(), 15000);

    const options = bridge.getRegistrationOptions()!;
    const challenge = Buffer.from(options.challenge, "base64")
      .toString("base64url")
      .replace(/=+$/, "");

    registrationStore.set(userId, { userName, createPromise });

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
    bridge.completeRegistration({
      id: attestation.credentialId,
      rawId: attestation.credentialId,
      response: {
        clientDataJSON: attestation.clientDataJSON,
        attestationObject: attestation.attestationObject,
      },
      type: "public-key",
    });

    const result = await pending.createPromise;

    const srv = await getServer();
    const submitResult = await srv.send(result.signedTx);
    if (!submitResult.success) {
      const err = (submitResult as any).error;
      console.error("[wallet/create] deploy failed:", err);
    } else {
      console.log(`[wallet/create] deploy tx: ${submitResult.hash}`);
    }

    console.log(`[wallet/create] wallet: ${result.contractId}`);

    store.set(userId, {
      userId,
      contractAddress: result.contractId,
      credentialIds: [result.keyIdBase64],
      balanceUsd: 0,
      userName: pending.userName,
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

  const receiverContractAddress = await resolveRecipient(userId, recipient);
  if (!receiverContractAddress) {
    return res.status(400).json({ error: "Penerima tidak ditemukan" });
  }

  try {
    const kit = await getKit();

    if (!kit.contractId || kit.contractId !== senderRecord.contractAddress) {
      const keyId = senderRecord.credentialIds[0];
      if (keyId) {
        await kit.connectWallet({ keyId });
      }
    }

    const amountStroops = BigInt(Math.round(amountUsd * 10_000_000));
    const amountIdr = Math.round(amountUsd * USD_TO_IDR);

    const { SACClient } = await import("passkey-kit");
    const { Asset } = await import("@stellar/stellar-sdk");
    const sacClient = new SACClient({
      rpcUrl: process.env.SOROBAN_RPC_URL || "https://soroban-testnet.stellar.org",
      networkPassphrase: NETWORK_PASSPHRASE,
    });
    const USDC_SAC_ADDRESS =
      process.env.USDC_SAC_ADDRESS ||
      new Asset("USDC", process.env.USDC_ISSUER || "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5").contractId(NETWORK_PASSPHRASE);
    const token = sacClient.getSACClient(USDC_SAC_ADDRESS);

    const tx = await token.transfer({
      from: senderRecord.contractAddress,
      to: receiverContractAddress,
      amount: amountStroops,
    });

    const signPromise = kit.sign(tx as any);

    await waitForBridge(() => bridge.hasPendingAuthentication(), 15000);

    const authOptions = bridge.getAuthenticationOptions()!;
    const challenge = Buffer.from(authOptions.challenge, "base64")
      .toString("base64url")
      .replace(/=+$/, "");

    const txId = crypto.randomUUID();
    txStore.set(txId, {
      signPromise,
      userId,
      amountIdr,
      counterpartyName: recipient,
    });

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

    const signedTx = await pending.signPromise;

    const srv = await getServer();
    const submitResult = await srv.send(signedTx as any);
    if (!submitResult.success) {
      const err = (submitResult as any).error;
      console.error("[tx/submit] submit failed:", err);
      return res.status(500).json({ error: "Gagal mengirim transaksi" });
    }

    console.log(`[tx/submit] settled: ${submitResult.hash}`);

    // Refresh balance & record transaction for the feed/history.
    const userRecord = store.get(pending.userId);
    if (userRecord) {
      try {
        const balanceUsd = await getUsdcBalance(userRecord.contractAddress);
        userRecord.balanceUsd = balanceUsd;
      } catch (balanceErr) {
        console.error("[tx/submit] balance refresh failed:", balanceErr);
      }

      transactionStore.add({
        id: txId,
        userId: pending.userId,
        counterpartyName: pending.counterpartyName || "Keluarga",
        amountIdr: pending.amountIdr || 0,
        createdAt: new Date(),
        status: "settled",
        direction: "send",
        reference: makeReference(),
      });
    }

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
    const balanceUsd = await getUsdcBalance(userRecord.contractAddress);
    userRecord.balanceUsd = balanceUsd;
    return res.json({ balanceUsd });
  } catch (err) {
    console.error("[balance] error:", err);
    return res.json({ balanceUsd: userRecord.balanceUsd });
  }
});

// ---------------------------------------------------------------------------
// 6) GET /home/:userId/feed
// ---------------------------------------------------------------------------
app.get("/home/:userId/feed", async (req: Request, res: Response) => {
  const { userId } = req.params;
  const userRecord = store.get(userId);

  if (!userRecord) {
    return res.status(404).json({ error: "Wallet not found" });
  }

  try {
    const balanceUsd = await getUsdcBalance(userRecord.contractAddress);
    userRecord.balanceUsd = balanceUsd;
  } catch (err) {
    console.error("[home/feed] balance refresh failed:", err);
  }

  const contacts = contactStore.listByUser(userId);
  const recentTx = transactionStore.listByUser(userId).slice(0, 20);

  return res.json({
    balanceIdr: userRecord.balanceUsd * USD_TO_IDR,
    greetingName: userRecord.userName || "Kamu",
    accountRef: userRecord.contractAddress,
    promos: [],
    favoriteContacts: contacts.filter((c) => c.isFavorite).map(toContactJson),
    recentTransactions: recentTx.map(toTransactionJson),
  });
});

// ---------------------------------------------------------------------------
// 7) Contacts
// ---------------------------------------------------------------------------
app.get("/contacts/:userId", (req: Request, res: Response) => {
  const { userId } = req.params;
  const contacts = contactStore.listByUser(userId);
  return res.json(contacts.map(toContactJson));
});

app.post("/contacts", (req: Request, res: Response) => {
  const { name, relation, accountRef } = req.body as {
    name?: string;
    relation?: string;
    accountRef?: string;
  };

  if (!name?.trim()) {
    return res.status(400).json({ error: "name required" });
  }

  // API tidak mensyaratkan userId di body; MVP berasumsi single-session demo
  // dan mengaitkan ke user pertama yang ada, atau 'me' bila belum ada wallet.
  const userId = store.all()[0]?.userId || "me";

  const contact = contactStore.add({
    id: crypto.randomUUID(),
    userId,
    name: name.trim(),
    relation: relation?.trim() || "",
    initials: initialsOf(name.trim()),
    accountRef: accountRef?.trim() || "",
    isFavorite: false,
  });

  return res.status(201).json(toContactJson(contact));
});

app.patch("/contacts/:id/favorite", (req: Request, res: Response) => {
  const { id } = req.params;
  const contact = contactStore.toggleFavorite(id);
  if (!contact) {
    return res.status(404).json({ error: "Contact not found" });
  }
  return res.json(toContactJson(contact));
});

// ---------------------------------------------------------------------------
// 8) Requests
// ---------------------------------------------------------------------------
app.post("/requests", (req: Request, res: Response) => {
  const { fromContactId, amountIdr, note } = req.body as {
    fromContactId?: string;
    amountIdr?: number;
    note?: string;
  };

  if (!fromContactId || amountIdr == null || amountIdr <= 0) {
    return res.status(400).json({ error: "fromContactId and amountIdr required" });
  }

  const userId = store.all()[0]?.userId || "me";

  const request = requestStore.add({
    id: crypto.randomUUID(),
    userId,
    fromContactId,
    amountIdr,
    note: note?.trim(),
    status: "pending",
    createdAt: new Date(),
  });

  return res.status(201).json(toRequestJson(request));
});

app.get("/requests/:userId", (req: Request, res: Response) => {
  const { userId } = req.params;
  return res.json(requestStore.listByUser(userId).map(toRequestJson));
});

// ---------------------------------------------------------------------------
// 9) Splits
// ---------------------------------------------------------------------------
app.post("/splits", (req: Request, res: Response) => {
  const { title, totalIdr, participants } = req.body as {
    title?: string;
    totalIdr?: number;
    participants?: Array<{
      contactId: string;
      name: string;
      shareIdr: number;
      isSelf?: boolean;
      status?: string;
    }>;
  };

  if (!title?.trim() || totalIdr == null || totalIdr <= 0 || !participants) {
    return res.status(400).json({ error: "title, totalIdr, and participants required" });
  }

  const userId = store.all()[0]?.userId || "me";

  const split = splitStore.add({
    id: crypto.randomUUID(),
    userId,
    title: title.trim(),
    totalIdr,
    participants: participants.map((p) => ({
      contactId: p.contactId,
      name: p.name,
      shareIdr: p.shareIdr,
      isSelf: p.isSelf ?? false,
      status: p.status === "paid" ? "paid" : "pending",
    })),
    createdAt: new Date(),
  });

  return res.status(201).json(toSplitJson(split));
});

app.get("/splits/:id", (req: Request, res: Response) => {
  const { id } = req.params;
  const split = splitStore.get(id);
  if (!split) {
    return res.status(404).json({ error: "Split bill not found" });
  }
  return res.json(toSplitJson(split));
});

app.get("/splits", (req: Request, res: Response) => {
  const userId = (req.query.userId as string) || store.all()[0]?.userId || "me";
  return res.json(splitStore.listByUser(userId).map(toSplitJson));
});

// ---------------------------------------------------------------------------
// JSON mappers (sinkron dengan frontend model)
// ---------------------------------------------------------------------------
function toContactJson(c: {
  id: string;
  name: string;
  relation: string;
  initials: string;
  accountRef: string;
  isFavorite: boolean;
  lastSentAt?: Date;
}) {
  return {
    id: c.id,
    name: c.name,
    relation: c.relation,
    initials: c.initials,
    accountRef: c.accountRef,
    isFavorite: c.isFavorite,
    lastSentAt: c.lastSentAt?.toISOString(),
  };
}

function toRequestJson(r: {
  id: string;
  fromContactId: string;
  amountIdr: number;
  note?: string;
  status: string;
  createdAt: Date;
}) {
  return {
    id: r.id,
    fromContactId: r.fromContactId,
    amountIdr: r.amountIdr,
    note: r.note,
    status: r.status,
    createdAt: r.createdAt.toISOString(),
  };
}

function toSplitJson(s: {
  id: string;
  title: string;
  totalIdr: number;
  createdAt: Date;
  participants: Array<{
    contactId: string;
    name: string;
    shareIdr: number;
    isSelf: boolean;
    status: string;
  }>;
}) {
  return {
    id: s.id,
    title: s.title,
    totalIdr: s.totalIdr,
    createdAt: s.createdAt.toISOString(),
    participants: s.participants.map((p) => ({
      contactId: p.contactId,
      name: p.name,
      shareIdr: p.shareIdr,
      isSelf: p.isSelf,
      status: p.status,
    })),
  };
}

function toTransactionJson(t: {
  id: string;
  counterpartyName: string;
  amountIdr: number;
  createdAt: Date;
  status: string;
  direction: string;
  reference?: string;
  note?: string;
}) {
  return {
    id: t.id,
    counterpartyName: t.counterpartyName,
    amountIdr: t.amountIdr,
    createdAt: t.createdAt.toISOString(),
    status: t.status,
    direction: t.direction,
    reference: t.reference,
    note: t.note,
  };
}

// ---------------------------------------------------------------------------
// Start server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`Kirimin backend listening on port ${PORT}`);
  console.log(`RP_ID: ${process.env.RP_ID || "localhost"}`);
  console.log(`Network: ${process.env.STELLAR_NETWORK || "testnet"}`);
});
