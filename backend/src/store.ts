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

export interface PendingTransaction {
  signPromise: Promise<unknown>;
  userId: string;
}

const pendingTx = new Map<string, PendingTransaction>();

export const txStore = {
  set: (txId: string, data: PendingTransaction) => pendingTx.set(txId, data),
  get: (txId: string) => pendingTx.get(txId),
  delete: (txId: string) => pendingTx.delete(txId),
};
