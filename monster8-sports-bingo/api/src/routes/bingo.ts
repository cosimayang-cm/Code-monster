import { Hono } from "hono";

import { resolveActor } from "../lib/auth";
import {
  ensureUpcomingRound,
  ensureWallet,
  getCurrentState,
  getLatestDraws,
  getRoundById,
  getStats,
  listActorBets,
  listActorBetsForRound,
  listDrawHistory,
  placeBet
} from "../lib/db";
import { fail, ok } from "../lib/json";
import { getCutoffTime } from "../lib/schedule";
import type { AppVariables, EnvBindings } from "../types/env";

const bingo = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

function parseNumbers(values: unknown): number[] | undefined {
  if (!Array.isArray(values)) {
    return undefined;
  }

  return values.map((value) => Number(value));
}

function validateBetPayload(body: {
  roundId?: string;
  betType?: string;
  amount?: number;
  selectedNumbers?: number[];
  selectedOption?: string;
}): { valid: true } | { valid: false; response: Response } {
  const { betType, amount } = body;
  if (!betType) {
    return { valid: false, response: fail("BET_TYPE_REQUIRED", "betType is required") };
  }

  if (amount !== 25) {
    return { valid: false, response: fail("INVALID_AMOUNT", "Each bet must be exactly 25") };
  }

  if (betType.startsWith("star_")) {
    const starCount = Number.parseInt(betType.replace("star_", ""), 10);
    if (!Number.isInteger(starCount) || starCount < 1 || starCount > 10) {
      return { valid: false, response: fail("INVALID_BET_TYPE", "Unsupported star bet type") };
    }

    if (!body.selectedNumbers || body.selectedNumbers.length !== starCount) {
      return {
        valid: false,
        response: fail("INVALID_SELECTION_COUNT", `Bet type ${betType} requires exactly ${starCount} numbers`)
      };
    }

    const unique = new Set(body.selectedNumbers);
    if (unique.size !== body.selectedNumbers.length || body.selectedNumbers.some((value) => !Number.isInteger(value) || value < 1 || value > 80)) {
      return {
        valid: false,
        response: fail("INVALID_NUMBERS", "Selected numbers must be unique integers between 1 and 80")
      };
    }

    return { valid: true };
  }

  if (betType === "big_small") {
    if (body.selectedOption !== "big" && body.selectedOption !== "small") {
      return { valid: false, response: fail("INVALID_OPTION", "big_small requires selectedOption of big or small") };
    }
    return { valid: true };
  }

  if (betType === "odd_even") {
    if (body.selectedOption !== "odd" && body.selectedOption !== "even") {
      return { valid: false, response: fail("INVALID_OPTION", "odd_even requires selectedOption of odd or even") };
    }
    return { valid: true };
  }

  return { valid: false, response: fail("INVALID_BET_TYPE", "Unsupported bet type") };
}

bingo.get("/current", async (c) => {
  const state = await getCurrentState(c.env.DB, new Date());
  return ok({
    currentRound: state.activeRound,
    latestDraw: state.latestDraw,
    countdownSeconds: state.countdownSeconds,
    cutoffAt: state.cutoffAt
  });
});

bingo.get("/draws/latest", async (c) => {
  const limit = Math.min(20, Math.max(1, Number.parseInt(c.req.query("limit") ?? "5", 10)));
  const draws = await getLatestDraws(
    c.env.DB,
    limit,
    new Date(),
    Number.parseFloat(c.env.SUPER_NUMBER_MULTIPLIER ?? "2") || 2
  );
  return ok({ draws, limit });
});

bingo.get("/draws/history", async (c) => {
  const page = Math.max(1, Number.parseInt(c.req.query("page") ?? "1", 10));
  const pageSize = Math.min(100, Math.max(1, Number.parseInt(c.req.query("pageSize") ?? "20", 10)));
  const draws = await listDrawHistory(
    c.env.DB,
    page,
    pageSize,
    new Date(),
    Number.parseFloat(c.env.SUPER_NUMBER_MULTIPLIER ?? "2") || 2
  );
  return ok({ draws, page, pageSize });
});

bingo.get("/draws/:roundId/results", async (c) => {
  const round = await getRoundById(c.env.DB, c.req.param("roundId"));
  if (!round) {
    return fail("ROUND_NOT_FOUND", "Round was not found", 404);
  }

  const actor = resolveActor(c);
  const bets = await listActorBetsForRound(c.env.DB, actor, round.round_id);
  return ok({ round, actor, bets });
});

bingo.get("/draws/:roundId", async (c) => {
  const round = await getRoundById(c.env.DB, c.req.param("roundId"));
  if (!round) {
    return fail("ROUND_NOT_FOUND", "Round was not found", 404);
  }

  return ok({ round });
});

bingo.get("/stats/numbers", async (c) => {
  const limit = Math.min(500, Math.max(10, Number.parseInt(c.req.query("limit") ?? "100", 10)));
  const stats = await getStats(c.env.DB, limit);
  return ok({ draws: stats.draws, frequency: stats.frequency });
});

bingo.get("/stats/big-small", async (c) => {
  const limit = Math.min(500, Math.max(10, Number.parseInt(c.req.query("limit") ?? "100", 10)));
  const stats = await getStats(c.env.DB, limit);
  return ok({ draws: stats.draws, bigSmall: stats.bigSmall });
});

bingo.get("/stats/odd-even", async (c) => {
  const limit = Math.min(500, Math.max(10, Number.parseInt(c.req.query("limit") ?? "100", 10)));
  const stats = await getStats(c.env.DB, limit);
  return ok({ draws: stats.draws, oddEven: stats.oddEven });
});

bingo.get("/bets/me", async (c) => {
  const actor = resolveActor(c);
  const page = Math.max(1, Number.parseInt(c.req.query("page") ?? "1", 10));
  const pageSize = Math.min(100, Math.max(1, Number.parseInt(c.req.query("pageSize") ?? "20", 10)));
  const bets = await listActorBets(c.env.DB, actor, page, pageSize);
  return ok({ actor, bets, page, pageSize });
});

bingo.get("/bets/me/:roundId", async (c) => {
  const actor = resolveActor(c);
  const bets = await listActorBetsForRound(c.env.DB, actor, c.req.param("roundId"));
  return ok({ actor, bets });
});

bingo.post("/bet", async (c) => {
  const actor = resolveActor(c);
  let body: {
    roundId?: string;
    betType?: string;
    amount?: number;
    selectedNumbers?: unknown;
    selectedOption?: string;
  } = {};

  try {
    body = await c.req.json();
  } catch {
    return fail("INVALID_JSON", "Request body must be valid JSON");
  }

  const parsed = {
    roundId: body.roundId,
    betType: body.betType,
    amount: Number(body.amount),
    selectedNumbers: parseNumbers(body.selectedNumbers),
    selectedOption: body.selectedOption
  };

  const validation = validateBetPayload(parsed);
  if (!validation.valid) {
    return validation.response;
  }

  const currentRound = parsed.roundId
    ? await getRoundById(c.env.DB, parsed.roundId)
    : await ensureUpcomingRound(c.env.DB, new Date());

  if (!currentRound) {
    return fail("ROUND_NOT_FOUND", "Round was not found", 404);
  }

  if (currentRound.status !== "pending") {
    return fail("ROUND_CLOSED", "This round is no longer accepting bets");
  }

  const drawTime = new Date(currentRound.draw_time.replace(" ", "T"));
  const cutoff = getCutoffTime(drawTime);
  if (Date.now() >= cutoff.getTime()) {
    return fail("BETTING_CLOSED", "Betting is closed for this round");
  }

  const wallet = await ensureWallet(c.env.DB, actor);
  if (wallet.balance < parsed.amount) {
    return fail("INSUFFICIENT_BALANCE", "Insufficient balance");
  }

  const result = await placeBet(c.env.DB, actor, {
    roundId: currentRound.round_id,
    betType: parsed.betType!,
    amount: parsed.amount,
    selectedNumbers: parsed.selectedNumbers,
    selectedOption: parsed.selectedOption
  });

  return ok({
    actor,
    roundId: currentRound.round_id,
    balance: result.wallet.balance
  });
});

export default bingo;
