import type { MiddlewareHandler } from "hono";

import { ApiError } from "../utils/http";

import type { AppEnv } from "../types";

export const requireAdmin: MiddlewareHandler<AppEnv> = async (context, next) => {
  const auth = context.get("auth");

  if (!auth || auth.role !== "admin") {
    throw new ApiError(403, "FORBIDDEN", "Admin access is required.");
  }

  await next();
};
