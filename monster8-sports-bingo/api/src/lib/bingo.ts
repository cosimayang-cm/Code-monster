const STAR_PAYOUTS: Record<number, Record<number, number>> = {
  1: { 1: 3 },
  2: { 2: 17 },
  3: { 3: 60, 2: 2 },
  4: { 4: 250, 3: 6, 2: 1 },
  5: { 5: 800, 4: 20, 3: 2 },
  6: { 6: 3000, 5: 60, 4: 8, 3: 1 },
  7: { 7: 8000, 6: 200, 5: 25, 4: 3, 0: 1 },
  8: { 8: 20000, 7: 800, 6: 60, 5: 8, 0: 2 },
  9: { 9: 50000, 8: 3000, 7: 200, 6: 20, 5: 3, 0: 4 },
  10: { 10: 200000, 9: 10000, 8: 1000, 7: 50, 6: 10, 5: 2, 0: 10 }
};

const SIDE_BET_MULTIPLIER = 6;

export interface BetEvaluationInput {
  betType: string;
  amount: number;
  selectedNumbers?: number[];
  selectedOption?: string;
  drawNumbers: number[];
  superNumber: number;
  superNumberMultiplier: number;
}

export interface BetEvaluationResult {
  status: "won" | "lost" | "refunded";
  matchedCount: number | null;
  multiplier: number;
  payout: number;
  hasSuperNumber: boolean;
}

function randomInt(maxExclusive: number): number {
  const maxUint32 = 0xffffffff;
  const threshold = maxUint32 - (maxUint32 % maxExclusive);
  const buffer = new Uint32Array(1);

  while (true) {
    crypto.getRandomValues(buffer);
    if (buffer[0] < threshold) {
      return buffer[0] % maxExclusive;
    }
  }
}

export function generateDraw(): { numbers: number[]; superNumber: number } {
  const pool = Array.from({ length: 80 }, (_, index) => index + 1);

  for (let index = pool.length - 1; index > 0; index -= 1) {
    const swapIndex = randomInt(index + 1);
    [pool[index], pool[swapIndex]] = [pool[swapIndex], pool[index]];
  }

  const numbers = pool.slice(0, 20).sort((left, right) => left - right);
  const superNumber = pool[20];
  return { numbers, superNumber };
}

export function evaluateBet(input: BetEvaluationInput): BetEvaluationResult {
  if (input.betType.startsWith("star_")) {
    return evaluateStarBet(input);
  }

  if (input.betType === "big_small") {
    return evaluateBigSmall(input);
  }

  if (input.betType === "odd_even") {
    return evaluateOddEven(input);
  }

  throw new Error(`Unsupported bet type: ${input.betType}`);
}

function evaluateStarBet(input: BetEvaluationInput): BetEvaluationResult {
  const selectedNumbers = input.selectedNumbers ?? [];
  const hitSet = new Set(input.drawNumbers);
  const matchedCount = selectedNumbers.filter((value) => hitSet.has(value)).length;
  const starCount = Number.parseInt(input.betType.replace("star_", ""), 10);
  const baseMultiplier = STAR_PAYOUTS[starCount]?.[matchedCount] ?? 0;
  const hasSuperNumber = selectedNumbers.includes(input.superNumber);
  const multiplier = baseMultiplier > 0 && hasSuperNumber
    ? baseMultiplier * input.superNumberMultiplier
    : baseMultiplier;
  const payout = Math.round(input.amount * multiplier);

  return {
    status: payout > 0 ? "won" : "lost",
    matchedCount,
    multiplier,
    payout,
    hasSuperNumber
  };
}

function evaluateBigSmall(input: BetEvaluationInput): BetEvaluationResult {
  const bigCount = input.drawNumbers.filter((value) => value >= 41).length;
  const smallCount = input.drawNumbers.length - bigCount;
  const selectedOption = input.selectedOption;

  if (bigCount >= 13) {
    return buildSideBetResult(selectedOption === "big", bigCount);
  }

  if (smallCount >= 13) {
    return buildSideBetResult(selectedOption === "small", smallCount);
  }

  return {
    status: "refunded",
    matchedCount: null,
    multiplier: 1,
    payout: input.amount,
    hasSuperNumber: false
  };
}

function evaluateOddEven(input: BetEvaluationInput): BetEvaluationResult {
  const oddCount = input.drawNumbers.filter((value) => value % 2 === 1).length;
  const evenCount = input.drawNumbers.length - oddCount;
  const selectedOption = input.selectedOption;

  if (oddCount > evenCount) {
    return buildSideBetResult(selectedOption === "odd", oddCount);
  }

  if (evenCount > oddCount) {
    return buildSideBetResult(selectedOption === "even", evenCount);
  }

  return {
    status: "refunded",
    matchedCount: null,
    multiplier: 1,
    payout: input.amount,
    hasSuperNumber: false
  };
}

function buildSideBetResult(didWin: boolean, matchedCount: number): BetEvaluationResult {
  return {
    status: didWin ? "won" : "lost",
    matchedCount,
    multiplier: didWin ? SIDE_BET_MULTIPLIER : 0,
    payout: didWin ? 25 * SIDE_BET_MULTIPLIER : 0,
    hasSuperNumber: false
  };
}
