import { describe, expect, it } from "vitest";
import {
  contactStore,
  requestStore,
  splitStore,
  store,
  transactionStore,
} from "./store.js";

describe("store", () => {
  it("stores and retrieves a user record", () => {
    store.set("u1", {
      userId: "u1",
      contractAddress: "C123",
      credentialIds: ["cred1"],
      balanceUsd: 10,
      userName: "Rani",
    });
    expect(store.get("u1")?.userName).toBe("Rani");
  });

  it("lists contacts by user", () => {
    contactStore.add({
      id: "c1",
      userId: "u1",
      name: "Ibu",
      relation: "Mother",
      initials: "IB",
      accountRef: "1234",
      isFavorite: true,
    });
    expect(contactStore.listByUser("u1")).toHaveLength(1);
    expect(contactStore.listByUser("u2")).toHaveLength(0);
  });

  it("toggles contact favorite", () => {
    const c = contactStore.toggleFavorite("c1")!;
    expect(c.isFavorite).toBe(false);
  });

  it("stores and lists requests", () => {
    requestStore.add({
      id: "r1",
      userId: "u1",
      fromContactId: "c1",
      amountIdr: 100_000,
      status: "pending",
      createdAt: new Date(),
    });
    expect(requestStore.listByUser("u1")).toHaveLength(1);
  });

  it("stores and retrieves split bills", () => {
    splitStore.add({
      id: "s1",
      userId: "u1",
      title: "Makan",
      totalIdr: 50_000,
      participants: [],
      createdAt: new Date(),
    });
    expect(splitStore.get("s1")?.title).toBe("Makan");
  });

  it("lists transactions newest first", () => {
    const now = new Date();
    transactionStore.add({
      id: "t1",
      userId: "u1",
      counterpartyName: "Ibu",
      amountIdr: 100_000,
      createdAt: new Date(now.getTime() - 1000),
      status: "settled",
      direction: "send",
    });
    transactionStore.add({
      id: "t2",
      userId: "u1",
      counterpartyName: "Ayah",
      amountIdr: 200_000,
      createdAt: now,
      status: "settled",
      direction: "send",
    });
    const list = transactionStore.listByUser("u1");
    expect(list[0].id).toBe("t2");
  });
});
