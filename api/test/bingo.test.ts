import { describe, expect, it } from "vitest";

import { evaluateBet, generateDraw } from "../src/lib/bingo";

describe("bingo payout rules", () => {
  it("applies star payouts with super number multiplier", () => {
    const result = evaluateBet({
      betType: "star_3",
      amount: 25,
      selectedNumbers: [3, 8, 11],
      drawNumbers: [1, 2, 3, 8, 11, 12, 14, 15, 18, 21, 22, 24, 25, 31, 33, 36, 41, 45, 50, 60],
      superNumber: 8,
      superNumberMultiplier: 2
    });

    expect(result.status).toBe("won");
    expect(result.matchedCount).toBe(3);
    expect(result.multiplier).toBe(120);
    expect(result.payout).toBe(3000);
    expect(result.hasSuperNumber).toBe(true);
  });

  it("refunds tie for big small", () => {
    const result = evaluateBet({
      betType: "big_small",
      amount: 25,
      selectedOption: "big",
      drawNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50],
      superNumber: 10,
      superNumberMultiplier: 2
    });

    expect(result.status).toBe("refunded");
    expect(result.payout).toBe(25);
  });

  it("generates unique draw numbers plus super number", () => {
    const draw = generateDraw();
    expect(draw.numbers).toHaveLength(20);
    expect(new Set(draw.numbers).size).toBe(20);
    expect(draw.superNumber).toBeGreaterThanOrEqual(1);
    expect(draw.superNumber).toBeLessThanOrEqual(80);
  });
});
