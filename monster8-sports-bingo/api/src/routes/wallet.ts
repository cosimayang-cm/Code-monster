import { Hono } from "hono";

import { resolveActor } from "../lib/auth";
import { depositWallet, ensureWallet, listWalletTransactions } from "../lib/db";
import { fail, ok } from "../lib/json";
import type { AppVariables, EnvBindings } from "../types/env";

const wallet = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

wallet.get("/balance", async (c) => {
  const actor = resolveActor(c);
  const current = await ensureWallet(c.env.DB, actor);
  return ok({
    actor,
    balance: current.balance,
    trialCreditAwarded: current.trial_credit_awarded
  });
});

wallet.get("/transactions", async (c) => {
  const actor = resolveActor(c);
  const page = Number.parseInt(c.req.query("page") ?? "1", 10);
  const pageSize = Number.parseInt(c.req.query("pageSize") ?? "20", 10);
  const transactions = await listWalletTransactions(c.env.DB, actor, Math.max(1, page), Math.min(100, Math.max(1, pageSize)));
  return ok({ actor, transactions, page, pageSize });
});

wallet.post("/deposit", async (c) => {
  const actor = resolveActor(c);
  let body: { amount?: number } = {};
  try {
    body = await c.req.json<{ amount?: number }>();
  } catch {
    return fail("INVALID_JSON", "Request body must be valid JSON");
  }

  const amount = Number(body.amount);
  if (!Number.isInteger(amount) || amount <= 0) {
    return fail("INVALID_AMOUNT", "Deposit amount must be a positive integer");
  }

  const current = await depositWallet(c.env.DB, actor, amount);
  return ok({
    actor,
    balance: current.balance,
    deposited: amount
  });
});

export default wallet;
