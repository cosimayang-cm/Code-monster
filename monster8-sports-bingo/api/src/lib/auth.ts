import { getCookie, setCookie } from "hono/cookie";
import type { Context } from "hono";

import type { Actor, AppVariables, EnvBindings } from "../types/env";

const GUEST_COOKIE = "m8_guest";

function createGuestId(): string {
  return `guest_${crypto.randomUUID()}`;
}

export function resolveActor(
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>
): Actor {
  const existing = c.get("actor");
  if (existing) {
    return existing;
  }

  const userId = c.req.header("x-user-id")?.trim();
  if (userId) {
    const actor = { type: "user" as const, id: userId };
    c.set("actor", actor);
    return actor;
  }

  let guestId = getCookie(c, GUEST_COOKIE);
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
