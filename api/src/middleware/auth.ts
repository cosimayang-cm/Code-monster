import type { Context, MiddlewareHandler } from "hono";

import { ApiError } from "../utils/http";
import { verifyToken } from "../utils/jwt";
import { getUserById } from "../services/user";

import type { AppEnv, AuthState } from "../types";

const getBearerToken = (value: string | undefined): string | null => {
  if (!value?.startsWith("Bearer ")) {
    return null;
  }

  return value.slice("Bearer ".length).trim();
};

export const authenticateRequest = async (
  context: Context<AppEnv>,
): Promise<AuthState> => {
  const token = getBearerToken(context.req.header("Authorization"));

  if (!token) {
    throw new ApiError(401, "UNAUTHORIZED", "Authorization token is required.");
  }

  let claims;

  try {
    claims = await verifyToken(context.env.JWT_SECRET, token, "access");
  } catch (error) {
    throw new ApiError(401, "UNAUTHORIZED", "Access token is invalid or expired.", error);
  }

  const user = await getUserById(context.env, claims.sub);

  if (!user) {
    throw new ApiError(401, "UNAUTHORIZED", "User session is invalid.");
  }

  if (!Boolean(user.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  return {
    userId: user.id,
    email: user.email,
    role: user.role,
  };
};

export const requireAuth: MiddlewareHandler<AppEnv> = async (context, next) => {
  const auth = await authenticateRequest(context);
  context.set("auth", auth);
  await next();
};
