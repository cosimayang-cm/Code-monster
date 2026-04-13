import { Hono } from "hono";
import { cors } from "hono/cors";

import { resolveActor } from "./lib/auth";
import { settleMostRecentRound } from "./lib/db";
import { fail, ok } from "./lib/json";
import bingoRoutes from "./routes/bingo";
import sportsRoutes from "./routes/sports";
import walletRoutes from "./routes/wallet";
import type { AppVariables, EnvBindings } from "./types/env";

const app = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

app.use(
  "*",
  cors({
    origin: (origin, c) => {
      const configuredOrigins = (c.env.WEB_APP_ORIGIN ?? "http://localhost:5173")
        .split(",")
        .map((item: string) => item.trim())
        .filter(Boolean);
      const fallbackOrigin = configuredOrigins[0] ?? "http://localhost:5173";
      const allowed = new Set([
        ...configuredOrigins,
        "http://localhost:5173",
        "http://127.0.0.1:5173"
      ]);
      return allowed.has(origin) ? origin : fallbackOrigin;
    },
    allowHeaders: ["Content-Type", "x-user-id", "x-guest-id"],
    allowMethods: ["GET", "POST", "OPTIONS"],
    credentials: true
  })
);

app.onError((error) => fail("INTERNAL_ERROR", error.message, 500));

app.get("/health", (c) =>
  ok({
    service: "monster8-sports-bingo-api",
    timestamp: new Date().toISOString()
  })
);

app.get("/api/viewer", async (c) => {
  const actor = resolveActor(c);
  return ok({ actor });
});

app.route("/api", sportsRoutes);
app.route("/api/bingo", bingoRoutes);
app.route("/api/wallet", walletRoutes);

app.notFound(() => fail("NOT_FOUND", "Route not found", 404));

export default {
  fetch: app.fetch,
  scheduled: async (_event: ScheduledEvent, env: EnvBindings): Promise<void> => {
    await settleMostRecentRound(
      env.DB,
      new Date(),
      Number.parseFloat(env.SUPER_NUMBER_MULTIPLIER ?? "2") || 2
    );
  }
};
