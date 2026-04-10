import { describe, expect, it } from "vitest";

import { getCutoffTime, getRoundId, getUpcomingDrawTime } from "../src/lib/schedule";

describe("schedule helpers", () => {
  it("computes the next draw time on 5-minute cadence", () => {
    const next = getUpcomingDrawTime(new Date("2026-04-10T10:02:30"));
    expect(next.getHours()).toBe(10);
    expect(next.getMinutes()).toBe(5);
    expect(next.getSeconds()).toBe(0);
  });

  it("uses a one-second cutoff window", () => {
    const drawTime = new Date("2026-04-10T10:05:00");
    const cutoff = getCutoffTime(drawTime);
    expect(cutoff.getHours()).toBe(10);
    expect(cutoff.getMinutes()).toBe(4);
    expect(cutoff.getSeconds()).toBe(59);
  });

  it("creates round ids from daily sequence", () => {
    const roundId = getRoundId(new Date("2026-04-10T07:05:00"));
    expect(roundId).toBe("20260410-001");
  });
});
