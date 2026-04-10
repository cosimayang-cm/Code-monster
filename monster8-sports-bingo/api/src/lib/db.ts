import type { Actor, BetRow, DrawRoundRow, WalletRow } from "../types/env";
import { evaluateBet, generateDraw } from "./bingo";
import {
  formatDateTime,
  getCountdownSeconds,
  getCutoffTime,
  getRecentScheduledDrawTimes,
  getRoundId,
  getUpcomingDrawTime
} from "./schedule";

const TRIAL_CREDIT = 10_000;

function nowSql(now = new Date()): string {
  return formatDateTime(now);
}

async function first<T>(statement: D1PreparedStatement): Promise<T | null> {
  return statement.first<T>();
}

async function cleanupBrokenDrawRows(db: D1Database): Promise<void> {
  await db
    .prepare("DELETE FROM draw_rounds WHERE round_id LIKE 'NaN%' OR draw_time LIKE 'NaN%'")
    .run();
}

export async function ensureWallet(db: D1Database, actor: Actor): Promise<WalletRow> {
  const existing = await first<WalletRow>(
    db
      .prepare(
        "SELECT id, owner_type, owner_id, balance, trial_credit_awarded, created_at, updated_at FROM user_wallets WHERE owner_type = ? AND owner_id = ?"
      )
      .bind(actor.type, actor.id)
  );

  if (existing) {
    return existing;
  }

  const timestamp = nowSql();
  await db.batch([
    db
      .prepare(
        "INSERT INTO user_wallets (owner_type, owner_id, balance, trial_credit_awarded, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)"
      )
      .bind(actor.type, actor.id, TRIAL_CREDIT, TRIAL_CREDIT, timestamp, timestamp),
    db
      .prepare(
        "INSERT INTO wallet_transactions (owner_type, owner_id, type, amount, reference_id, description, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
      )
      .bind(actor.type, actor.id, "trial_credit", TRIAL_CREDIT, actor.id, "Initial trial credit", timestamp)
  ]);

  return first<WalletRow>(
    db
      .prepare(
        "SELECT id, owner_type, owner_id, balance, trial_credit_awarded, created_at, updated_at FROM user_wallets WHERE owner_type = ? AND owner_id = ?"
      )
      .bind(actor.type, actor.id)
  ) as Promise<WalletRow>;
}

export async function depositWallet(
  db: D1Database,
  actor: Actor,
  amount: number
): Promise<WalletRow> {
  const wallet = await ensureWallet(db, actor);
  const timestamp = nowSql();

  await db.batch([
    db
      .prepare("UPDATE user_wallets SET balance = balance + ?, updated_at = ? WHERE id = ?")
      .bind(amount, timestamp, wallet.id),
    db
      .prepare(
        "INSERT INTO wallet_transactions (owner_type, owner_id, type, amount, reference_id, description, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
      )
      .bind(actor.type, actor.id, "deposit", amount, actor.id, "Manual trial deposit", timestamp)
  ]);

  return ensureWallet(db, actor);
}

export async function listWalletTransactions(
  db: D1Database,
  actor: Actor,
  page: number,
  pageSize: number
): Promise<unknown[]> {
  const offset = (page - 1) * pageSize;
  const result = await db
    .prepare(
      "SELECT id, type, amount, reference_id, description, created_at FROM wallet_transactions WHERE owner_type = ? AND owner_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?"
    )
    .bind(actor.type, actor.id, pageSize, offset)
    .all<unknown>();

  return result.results ?? [];
}

export async function ensureUpcomingRound(db: D1Database, now: Date): Promise<DrawRoundRow> {
  const drawTime = getUpcomingDrawTime(now);
  const roundId = getRoundId(drawTime);
  const timestamp = nowSql(now);
  await db
    .prepare(
      "INSERT OR IGNORE INTO draw_rounds (round_id, draw_time, status, created_at, updated_at) VALUES (?, ?, 'pending', ?, ?)"
    )
    .bind(roundId, formatDateTime(drawTime), timestamp, timestamp)
    .run();

  return first<DrawRoundRow>(
    db
      .prepare(
        "SELECT id, round_id, draw_time, numbers, super_number, status, created_at, updated_at FROM draw_rounds WHERE round_id = ?"
      )
      .bind(roundId)
  ) as Promise<DrawRoundRow>;
}

async function settleRoundAtTime(
  db: D1Database,
  drawTime: Date,
  now: Date,
  superNumberMultiplier: number
): Promise<{ settledRoundId: string; processedBets: number }> {
  const roundId = getRoundId(drawTime);
  const timestamp = nowSql(now);

  await db
    .prepare(
      "INSERT OR IGNORE INTO draw_rounds (round_id, draw_time, status, created_at, updated_at) VALUES (?, ?, 'pending', ?, ?)"
    )
    .bind(roundId, formatDateTime(drawTime), timestamp, timestamp)
    .run();

  let round = await getRoundById(db, roundId);
  if (!round) {
    return { settledRoundId: roundId, processedBets: 0 };
  }

  if (round.status === "pending") {
    const draw = generateDraw();
    await db
      .prepare(
        "UPDATE draw_rounds SET numbers = ?, super_number = ?, status = 'drawn', updated_at = ? WHERE round_id = ?"
      )
      .bind(JSON.stringify(draw.numbers), draw.superNumber, timestamp, roundId)
      .run();
    round = await getRoundById(db, roundId);
  }

  if (!round || !round.numbers || round.super_number === null || round.status === "settled") {
    return { settledRoundId: roundId, processedBets: 0 };
  }

  const bets = await db
    .prepare(
      "SELECT id, owner_type, owner_id, round_id, bet_type, selected_numbers, selected_option, amount, status, matched_count, multiplier, payout, has_super_number, created_at FROM bets WHERE round_id = ? AND status = 'pending'"
    )
    .bind(roundId)
    .all<BetRow>();

  const results = bets.results ?? [];
  const drawNumbers: number[] = JSON.parse(round.numbers);
  const statements: D1PreparedStatement[] = [];

  for (const bet of results) {
    const evaluation = evaluateBet({
      betType: bet.bet_type,
      amount: bet.amount,
      selectedNumbers: bet.selected_numbers ? JSON.parse(bet.selected_numbers) : undefined,
      selectedOption: bet.selected_option ?? undefined,
      drawNumbers,
      superNumber: round.super_number,
      superNumberMultiplier
    });

    statements.push(
      db
        .prepare(
          "UPDATE bets SET status = ?, matched_count = ?, multiplier = ?, payout = ?, has_super_number = ? WHERE id = ?"
        )
        .bind(
          evaluation.status,
          evaluation.matchedCount,
          evaluation.multiplier,
          evaluation.payout,
          evaluation.hasSuperNumber ? 1 : 0,
          bet.id
        )
    );

    if (evaluation.status === "won" || evaluation.status === "refunded") {
      statements.push(
        db
          .prepare(
            "UPDATE user_wallets SET balance = balance + ?, updated_at = ? WHERE owner_type = ? AND owner_id = ?"
          )
          .bind(evaluation.payout, timestamp, bet.owner_type, bet.owner_id),
        db
          .prepare(
            "INSERT INTO wallet_transactions (owner_type, owner_id, type, amount, reference_id, description, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
          )
          .bind(
            bet.owner_type,
            bet.owner_id,
            evaluation.status === "refunded" ? "refund" : "win",
            evaluation.payout,
            `bet:${bet.id}`,
            evaluation.status === "refunded" ? `Refund for ${roundId}` : `Winnings for ${roundId}`,
            timestamp
          )
      );
    }
  }

  statements.push(
    db
      .prepare("UPDATE draw_rounds SET status = 'settled', updated_at = ? WHERE round_id = ?")
      .bind(timestamp, roundId)
  );

  if (statements.length > 0) {
    await db.batch(statements);
  }

  return { settledRoundId: roundId, processedBets: results.length };
}

export async function syncDrawTimeline(
  db: D1Database,
  now: Date,
  superNumberMultiplier: number,
  lookbackRounds = 120
): Promise<void> {
  await cleanupBrokenDrawRows(db);
  const recentDrawTimes = getRecentScheduledDrawTimes(now, lookbackRounds);

  for (const drawTime of recentDrawTimes) {
    await settleRoundAtTime(db, drawTime, now, superNumberMultiplier);
  }

  await ensureUpcomingRound(db, now);
}

export async function getLatestDraws(
  db: D1Database,
  limit: number,
  now: Date,
  superNumberMultiplier: number
): Promise<DrawRoundRow[]> {
  await syncDrawTimeline(db, now, superNumberMultiplier, Math.max(limit, 120));
  const result = await db
    .prepare(
      "SELECT id, round_id, draw_time, numbers, super_number, status, created_at, updated_at FROM draw_rounds WHERE status IN ('drawn', 'settled') AND round_id NOT LIKE 'NaN%' ORDER BY draw_time DESC LIMIT ?"
    )
    .bind(limit)
    .all<DrawRoundRow>();

  return result.results ?? [];
}

export async function getRoundById(db: D1Database, roundId: string): Promise<DrawRoundRow | null> {
  return first<DrawRoundRow>(
    db
      .prepare(
        "SELECT id, round_id, draw_time, numbers, super_number, status, created_at, updated_at FROM draw_rounds WHERE round_id = ?"
      )
      .bind(roundId)
  );
}

export async function getCurrentState(db: D1Database, now: Date): Promise<{
  activeRound: DrawRoundRow;
  latestDraw: DrawRoundRow | null;
  countdownSeconds: number;
  cutoffAt: string;
}> {
  const activeRound = await ensureUpcomingRound(db, now);
  const latestDraws = await getLatestDraws(db, 1, now, 2);
  const drawTime = new Date(activeRound.draw_time.replace(" ", "T"));

  return {
    activeRound,
    latestDraw: latestDraws[0] ?? null,
    countdownSeconds: getCountdownSeconds(now, drawTime),
    cutoffAt: formatDateTime(getCutoffTime(drawTime))
  };
}

export async function listDrawHistory(
  db: D1Database,
  page: number,
  pageSize: number,
  now: Date,
  superNumberMultiplier: number
): Promise<DrawRoundRow[]> {
  await syncDrawTimeline(db, now, superNumberMultiplier, Math.max(page * pageSize, 120));
  const offset = (page - 1) * pageSize;
  const result = await db
    .prepare(
      "SELECT id, round_id, draw_time, numbers, super_number, status, created_at, updated_at FROM draw_rounds WHERE status IN ('drawn', 'settled') AND round_id NOT LIKE 'NaN%' ORDER BY draw_time DESC LIMIT ? OFFSET ?"
    )
    .bind(pageSize, offset)
    .all<DrawRoundRow>();

  return result.results ?? [];
}

export async function listActorBets(
  db: D1Database,
  actor: Actor,
  page: number,
  pageSize: number
): Promise<BetRow[]> {
  const offset = (page - 1) * pageSize;
  const result = await db
    .prepare(
      "SELECT id, owner_type, owner_id, round_id, bet_type, selected_numbers, selected_option, amount, status, matched_count, multiplier, payout, has_super_number, created_at FROM bets WHERE owner_type = ? AND owner_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?"
    )
    .bind(actor.type, actor.id, pageSize, offset)
    .all<BetRow>();

  return result.results ?? [];
}

export async function listActorBetsForRound(
  db: D1Database,
  actor: Actor,
  roundId: string
): Promise<BetRow[]> {
  const result = await db
    .prepare(
      "SELECT id, owner_type, owner_id, round_id, bet_type, selected_numbers, selected_option, amount, status, matched_count, multiplier, payout, has_super_number, created_at FROM bets WHERE owner_type = ? AND owner_id = ? AND round_id = ? ORDER BY created_at DESC"
    )
    .bind(actor.type, actor.id, roundId)
    .all<BetRow>();

  return result.results ?? [];
}

export interface PlaceBetInput {
  roundId: string;
  betType: string;
  amount: number;
  selectedNumbers?: number[];
  selectedOption?: string;
}

export async function placeBet(
  db: D1Database,
  actor: Actor,
  input: PlaceBetInput
): Promise<{ wallet: WalletRow }> {
  const wallet = await ensureWallet(db, actor);
  const timestamp = nowSql();
  const selectedNumbers = input.selectedNumbers ? JSON.stringify(input.selectedNumbers) : null;
  const betReference = `bet:${input.roundId}:${crypto.randomUUID()}`;

  await db.batch([
    db
      .prepare("UPDATE user_wallets SET balance = balance - ?, updated_at = ? WHERE id = ?")
      .bind(input.amount, timestamp, wallet.id),
    db
      .prepare(
        "INSERT INTO bets (owner_type, owner_id, round_id, bet_type, selected_numbers, selected_option, amount, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?)"
      )
      .bind(actor.type, actor.id, input.roundId, input.betType, selectedNumbers, input.selectedOption ?? null, input.amount, timestamp),
    db
      .prepare(
        "INSERT INTO wallet_transactions (owner_type, owner_id, type, amount, reference_id, description, created_at) VALUES (?, ?, 'bet', ?, ?, ?, ?)"
      )
      .bind(actor.type, actor.id, -input.amount, betReference, `Bet for round ${input.roundId}`, timestamp)
  ]);

  return { wallet: await ensureWallet(db, actor) };
}

export async function getStats(db: D1Database, limit: number): Promise<{
  draws: number;
  frequency: Array<{ number: number; count: number }>;
  bigSmall: { big: number; small: number; tie: number };
  oddEven: { odd: number; even: number; tie: number };
}> {
  const draws = await getLatestDraws(db, limit, new Date(), 2);
  const frequency = new Map<number, number>();
  let big = 0;
  let small = 0;
  let bigSmallTie = 0;
  let odd = 0;
  let even = 0;
  let oddEvenTie = 0;

  for (const row of draws) {
    const numbers: number[] = row.numbers ? JSON.parse(row.numbers) : [];
    let bigCount = 0;
    let oddCount = 0;
    for (const value of numbers) {
      frequency.set(value, (frequency.get(value) ?? 0) + 1);
      if (value >= 41) {
        bigCount += 1;
      }
      if (value % 2 === 1) {
        oddCount += 1;
      }
    }

    if (bigCount >= 13) {
      big += 1;
    } else if (numbers.length - bigCount >= 13) {
      small += 1;
    } else {
      bigSmallTie += 1;
    }

    if (oddCount > numbers.length - oddCount) {
      odd += 1;
    } else if (oddCount < numbers.length - oddCount) {
      even += 1;
    } else {
      oddEvenTie += 1;
    }
  }

  return {
    draws: draws.length,
    frequency: Array.from({ length: 80 }, (_, index) => ({
      number: index + 1,
      count: frequency.get(index + 1) ?? 0
    })).sort((left, right) => right.count - left.count || left.number - right.number),
    bigSmall: { big, small, tie: bigSmallTie },
    oddEven: { odd, even, tie: oddEvenTie }
  };
}

export async function settleMostRecentRound(
  db: D1Database,
  now: Date,
  superNumberMultiplier: number
): Promise<{ settledRoundId: string | null; processedBets: number }> {
  const latestSettledBeforeSync = await getLatestDraws(db, 1, now, superNumberMultiplier);
  const beforeRoundId = latestSettledBeforeSync[0]?.round_id ?? null;
  await syncDrawTimeline(db, now, superNumberMultiplier, 120);
  const latestSettledAfterSync = await getLatestDraws(db, 1, now, superNumberMultiplier);
  const latestRoundId = latestSettledAfterSync[0]?.round_id ?? null;
  return {
    settledRoundId: latestRoundId,
    processedBets: latestRoundId && latestRoundId !== beforeRoundId ? 1 : 0
  };
}
