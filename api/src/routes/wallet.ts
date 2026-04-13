import { Hono } from "hono";

import { resolveActor } from "../lib/auth";
import { debitWallet, depositWallet, ensureWallet, listWalletTransactions } from "../lib/db";
import { fail, ok } from "../lib/json";
import type { AppVariables, EnvBindings } from "../types/env";

const wallet = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

wallet.get("/balance", async (c) => {
  const actor = await resolveActor(c);
  const current = await ensureWallet(c.env.DB, actor);
  return ok({
    actor,
    balance: current.balance,
    trialCreditAwarded: current.trial_credit_awarded
  });
});

wallet.get("/transactions", async (c) => {
  const actor = await resolveActor(c);
  const page = Number.parseInt(c.req.query("page") ?? "1", 10);
  const pageSize = Number.parseInt(c.req.query("pageSize") ?? "20", 10);
  const transactions = await listWalletTransactions(c.env.DB, actor, Math.max(1, page), Math.min(100, Math.max(1, pageSize)));
  return ok({ actor, transactions, page, pageSize });
});

wallet.post("/deposit", async (c) => {
  const actor = await resolveActor(c);
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

wallet.post("/sports-bet", async (c) => {
  const actor = await resolveActor(c);
  let body: {
    amount?: number;
    eventId?: string;
    matchup?: string;
    marketLabel?: string;
    pickLabel?: string;
  } = {};

  try {
    body = await c.req.json<{
      amount?: number;
      eventId?: string;
      matchup?: string;
      marketLabel?: string;
      pickLabel?: string;
    }>();
  } catch {
    return fail("INVALID_JSON", "Request body must be valid JSON");
  }

  const amount = Number(body.amount);
  if (!Number.isInteger(amount) || amount <= 0) {
    return fail("INVALID_AMOUNT", "Bet amount must be a positive integer");
  }

  const eventId = body.eventId?.trim();
  const matchup = body.matchup?.trim() || "Sports event";
  const marketLabel = body.marketLabel?.trim() || "熱門";
  const pickLabel = body.pickLabel?.trim() || "選項";
  const current = await ensureWallet(c.env.DB, actor);

  if (current.balance < amount) {
    return fail("INSUFFICIENT_BALANCE", "Insufficient balance");
  }

  const description = `${matchup} / ${marketLabel} / ${pickLabel}`.slice(0, 180);
  const updated = await debitWallet(
    c.env.DB,
    actor,
    amount,
    "sports_bet",
    eventId ? `sports:${eventId}` : `sports:${actor.id}`,
    description
  );

  return ok({
    actor,
    balance: updated.balance,
    debited: amount
  });
});

export default wallet;
