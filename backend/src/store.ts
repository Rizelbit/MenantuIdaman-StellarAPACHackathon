/**
 * In-memory store untuk MVP hackathon.
 * Data hilang saat server restart — OK untuk demo.
 */

export interface UserRecord {
  userId: string;
  contractAddress: string;
  credentialIds: string[];
  balanceUsd: number;
  userName: string;
}

const users = new Map<string, UserRecord>();

export const store = {
  get: (userId: string) => users.get(userId),
  set: (userId: string, record: UserRecord) => users.set(userId, record),
  getByCredentialId: (credentialId: string) =>
    [...users.values()].find((u) => u.credentialIds.includes(credentialId)),
  all: () => [...users.values()],
};

export interface PendingRegistration {
  userName: string;
  createPromise: Promise<{
    keyIdBase64: string;
    contractId: string;
    signedTx: string;
  }>;
}

const pendingRegistrations = new Map<string, PendingRegistration>();

export const registrationStore = {
  set: (userId: string, pending: PendingRegistration) =>
    pendingRegistrations.set(userId, pending),
  get: (userId: string) => pendingRegistrations.get(userId),
  delete: (userId: string) => pendingRegistrations.delete(userId),
};

export interface Contact {
  id: string;
  userId: string;
  name: string;
  relation: string;
  initials: string;
  accountRef: string;
  isFavorite: boolean;
  lastSentAt?: Date;
}

const contacts = new Map<string, Contact>();

export const contactStore = {
  listByUser: (userId: string) =>
    [...contacts.values()].filter((c) => c.userId === userId),
  add: (contact: Contact) => {
    contacts.set(contact.id, contact);
    return contact;
  },
  get: (id: string) => contacts.get(id),
  getByAccountRef: (userId: string, accountRef: string) =>
    [...contacts.values()].find(
      (c) => c.userId === userId && c.accountRef === accountRef
    ),
  toggleFavorite: (id: string) => {
    const c = contacts.get(id);
    if (c) {
      c.isFavorite = !c.isFavorite;
    }
    return c;
  },
};

export interface MoneyRequest {
  id: string;
  userId: string;
  fromContactId: string;
  amountIdr: number;
  note?: string;
  status: "pending" | "paid" | "declined" | "expired";
  createdAt: Date;
}

const requests = new Map<string, MoneyRequest>();

export const requestStore = {
  add: (req: MoneyRequest) => {
    requests.set(req.id, req);
    return req;
  },
  listByUser: (userId: string) =>
    [...requests.values()].filter((r) => r.userId === userId),
};

export interface SplitParticipant {
  contactId: string;
  name: string;
  shareIdr: number;
  isSelf: boolean;
  status: "pending" | "paid";
}

export interface SplitBill {
  id: string;
  userId: string;
  title: string;
  totalIdr: number;
  participants: SplitParticipant[];
  createdAt: Date;
}

const splits = new Map<string, SplitBill>();

export const splitStore = {
  add: (split: SplitBill) => {
    splits.set(split.id, split);
    return split;
  },
  get: (id: string) => splits.get(id),
  listByUser: (userId: string) =>
    [...splits.values()].filter((s) => s.userId === userId),
};

export interface AppTransaction {
  id: string;
  userId: string;
  counterpartyName: string;
  amountIdr: number;
  createdAt: Date;
  status: "pending" | "settled" | "failed";
  direction: "send" | "receive" | "split";
  reference?: string;
  note?: string;
}

const transactions = new Map<string, AppTransaction>();

export const transactionStore = {
  add: (tx: AppTransaction) => {
    transactions.set(tx.id, tx);
    return tx;
  },
  listByUser: (userId: string) =>
    [...transactions.values()]
      .filter((t) => t.userId === userId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()),
};

export interface PendingTransaction {
  signPromise: Promise<unknown>;
  userId: string;
  amountIdr: number;
  counterpartyName: string;
}

const pendingTx = new Map<string, PendingTransaction>();

export const txStore = {
  set: (txId: string, data: PendingTransaction) => pendingTx.set(txId, data),
  get: (txId: string) => pendingTx.get(txId),
  delete: (txId: string) => pendingTx.delete(txId),
};
