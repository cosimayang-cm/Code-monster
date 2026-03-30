import type { MiddlewareHandler } from "hono";

import { ApiError } from "../utils/http";

import type { AppEnv } from "../types";

const LOCAL_ORIGINS = new Set([
  "http://localhost:5173",
  "http://127.0.0.1:5173",
]);

const buildAllowedOrigins = (env: AppEnv["Bindings"]): Set<string> => {
  const configured = env.ALLOWED_ORIGINS?.split(",")
    .map((item) => item.trim())
    .filter(Boolean);

  return new Set([env.APP_URL, ...(configured ?? []), ...LOCAL_ORIGINS]);
};

export const corsMiddleware: MiddlewareHandler<AppEnv> = async (context, next) => {
  const origin = context.req.header("Origin");

  if (origin) {
    const allowedOrigins = buildAllowedOrigins(context.env);

    if (!allowedOrigins.has(origin)) {
      throw new ApiError(403, "CORS_FORBIDDEN", "Origin is not allowed.");
    }

    context.header("Access-Control-Allow-Origin", origin);
    context.header("Vary", "Origin");
    context.header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
    context.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
    context.header("Access-Control-Max-Age", "86400");
  }

  if (context.req.method === "OPTIONS") {
    return context.body(null, 204);
  }

  await next();
};
