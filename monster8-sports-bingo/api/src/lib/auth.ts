import { getCookie, setCookie } from "hono/cookie";
import type { Context } from "hono";

import { ApiError } from "./errors";
import { verifyToken } from "./jwt";
import { getUserById } from "./users";

import type { Actor, AppVariables, AuthState, EnvBindings } from "../types/env";

const GUEST_COOKIE = "m8_guest";
const GUEST_HEADER = "x-guest-id";

function createGuestId(): string {
  return `guest_${crypto.randomUUID()}`;
}

export function resolveActor(
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>
): Promise<Actor>;
export async function resolveActor(
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>
): Promise<Actor> {
  const existing = c.get("actor");
  if (existing) {
    return existing;
  }

  const authHeader = c.req.header("Authorization");
  if (authHeader) {
    const auth = await authenticateRequest(c);
    const actor = { type: "user" as const, id: auth.userId };
    c.set("actor", actor);
    return actor;
  }

  const guestHeader = c.req.header(GUEST_HEADER)?.trim();
  let guestId = guestHeader?.startsWith("guest_") ? guestHeader : getCookie(c, GUEST_COOKIE);
  if (!guestId) {
    guestId = createGuestId();
    const requestUrl = new URL(c.req.url);
    const isLocal = requestUrl.hostname === "localhost" || requestUrl.protocol === "http:";
    setCookie(c, GUEST_COOKIE, guestId, {
      httpOnly: true,
      path: "/",
      sameSite: isLocal ? "Lax" : "None",
      secure: !isLocal,
      maxAge: 60 * 60 * 24 * 30
    });
  }

  const actor = { type: "guest" as const, id: guestId };
  c.set("actor", actor);
  return actor;
}

const getBearerToken = (value: string | undefined): string | null => {
  if (!value?.startsWith("Bearer ")) {
    return null;
  }

  return value.slice("Bearer ".length).trim();
};

export const authenticateRequest = async (
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>
): Promise<AuthState> => {
  const existing = c.get("auth");
  if (existing) {
    return existing;
  }

  if (!c.env.JWT_SECRET) {
    throw new ApiError(500, "AUTH_NOT_CONFIGURED", "JWT secret is not configured.");
  }

  const token = getBearerToken(c.req.header("Authorization"));
  if (!token) {
    throw new ApiError(401, "UNAUTHORIZED", "Authorization token is required.");
  }

  let claims;
  try {
    claims = await verifyToken(c.env.JWT_SECRET, token, "access");
  } catch (error) {
    throw new ApiError(401, "UNAUTHORIZED", "Access token is invalid or expired.", error);
  }

  const user = await getUserById(c.env, claims.sub);
  if (!user) {
    throw new ApiError(401, "UNAUTHORIZED", "User session is invalid.");
  }

  if (!Boolean(user.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  const auth = {
    userId: user.id,
    email: user.email,
    role: user.role
  } satisfies AuthState;

  c.set("auth", auth);
  return auth;
};
