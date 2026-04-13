import { Hono } from "hono";
import type { Context } from "hono";

import { ApiError } from "../lib/errors";
import { fail, ok } from "../lib/json";
import { getClientIp, getUserAgent } from "../lib/request";
import {
  loginAfterOAuth,
  loginWithPassword,
  refreshAccessToken,
  registerWithPassword
} from "../lib/member-auth";
import {
  createOAuthAuthorization,
  getConfiguredProviders,
  getOAuthErrorRedirectUrl,
  getOAuthProvider,
  getOAuthRedirectUrl,
  handleOAuthCallback
} from "../lib/oauth";
import type { AppVariables, EnvBindings } from "../types/env";

const authRoutes = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

authRoutes.get("/providers", (c) => ok({ providers: getConfiguredProviders(c.env) }));

authRoutes.post("/register", async (c) => {
  const body = await readJsonBody(c);
  const email = typeof body.email === "string" ? body.email : "";
  const password = typeof body.password === "string" ? body.password : "";
  const session = await registerWithPassword(c.env, { email, password });
  return ok(session, { status: 201 });
});

authRoutes.post("/login", async (c) => {
  const body = await readJsonBody(c);
  const email = typeof body.email === "string" ? body.email : "";
  const password = typeof body.password === "string" ? body.password : "";
  const session = await loginWithPassword(c.env, {
    email,
    password,
    ipAddress: getClientIp(c.req.header("cf-connecting-ip")),
    userAgent: getUserAgent(c.req.header("user-agent"))
  });
  return ok(session);
});

authRoutes.post("/refresh", async (c) => {
  const body = await readJsonBody(c);
  const refreshToken = typeof body.refreshToken === "string" ? body.refreshToken : "";
  if (!refreshToken) {
    return fail("INVALID_TOKEN", "Refresh token is required.");
  }
  const accessToken = await refreshAccessToken(c.env, refreshToken);
  return ok({ accessToken });
});

authRoutes.post("/logout", () => ok({ message: "Logged out" }));

authRoutes.get("/oauth/:provider", async (c) => {
  const provider = getOAuthProvider(c.req.param("provider"));
  const { url } = await createOAuthAuthorization(c.env, provider);
  return c.redirect(url, 302);
});

authRoutes.get("/oauth/:provider/callback", async (c) => {
  const provider = getOAuthProvider(c.req.param("provider"));
  const code = c.req.query("code");
  const state = c.req.query("state");

  if (!code || !state) {
    return c.redirect(getOAuthErrorRedirectUrl(c.env, "OAUTH_MISSING_CODE"), 302);
  }

  try {
    const user = await handleOAuthCallback(c.env, { provider, code, state });
    const tokens = await loginAfterOAuth(c.env, {
      user,
      method: provider,
      ipAddress: getClientIp(c.req.header("cf-connecting-ip")),
      userAgent: getUserAgent(c.req.header("user-agent"))
    });

    return c.redirect(getOAuthRedirectUrl(c.env, tokens), 302);
  } catch (error) {
    console.error(error);
    const code = error instanceof ApiError ? error.code : "OAUTH_FAILED";
    return c.redirect(getOAuthErrorRedirectUrl(c.env, code), 302);
  }
});

async function readJsonBody(
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>
): Promise<Record<string, unknown>> {
  try {
    const body = await c.req.json<Record<string, unknown>>();
    return body ?? {};
  } catch {
    return {};
  }
}

export default authRoutes;
