import { Hono } from "hono";
import type { ContentfulStatusCode } from "hono/utils/http-status";

import { corsMiddleware } from "./middleware/cors";
import { adminRoutes } from "./routes/admin";
import { authRoutes } from "./routes/auth";
import { usersRoutes } from "./routes/users";
import { jsonSuccess, normalizeErrorResponse } from "./utils/http";

import type { AppEnv } from "./types";

const app = new Hono<AppEnv>();

app.use("/api/*", corsMiddleware);

app.get("/", (context) =>
  jsonSuccess(context, {
    name: "Monster7 Member API",
    version: "0.1.0",
  }),
);

app.get("/health", async (context) => {
  await context.env.DB.prepare("SELECT 1 AS ok").first<{ ok: number }>();

  return jsonSuccess(context, {
    status: "ok",
    database: "connected",
    environment: context.env.ENVIRONMENT ?? "local",
  });
});

app.route("/api/auth", authRoutes);
app.route("/api/users", usersRoutes);
app.route("/api/admin", adminRoutes);

app.notFound((context) =>
  context.json(
    {
      error: {
        code: "NOT_FOUND",
        message: "Route not found.",
      },
    },
    404,
  ),
);

app.onError((error, context) => {
  const response = normalizeErrorResponse(error);
  return context.json(response.body, response.status as ContentfulStatusCode);
});

export default app;
