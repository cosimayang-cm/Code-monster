import { Hono } from "hono";
import { z } from "zod";

import { authenticateRequest } from "../middleware/auth";
import {
  createPasswordReset,
  loginAfterOAuth,
  loginWithPassword,
  refreshAccessToken,
  registerWithPassword,
  resetPasswordWithToken,
} from "../services/auth";
import {
  createOAuthAuthorization,
  getOAuthErrorRedirectUrl,
  getOAuthRedirectUrl,
  handleOAuthCallback,
} from "../services/oauth";
import { jsonSuccess, parseJsonBody, ApiError, getClientIp, getUserAgent } from "../utils/http";
import { getOAuthProvider } from "../utils/validation";

import type { AppEnv } from "../types";

const registerSchema = z.object({
  email: z.string().trim().email(),
  password: z.string(),
});

const loginSchema = registerSchema;

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

const forgotPasswordSchema = z.object({
  email: z.string().trim().email(),
});

const resetPasswordSchema = z.object({
  token: z.string().min(1),
  password: z.string(),
});

export const authRoutes = new Hono<AppEnv>();

authRoutes.post("/register", async (context) => {
  const payload = registerSchema.parse(await parseJsonBody(context));
  const session = await registerWithPassword(context.env, payload);
  return jsonSuccess(context, session, 201);
});

authRoutes.post("/login", async (context) => {
  const payload = loginSchema.parse(await parseJsonBody(context));
  const session = await loginWithPassword(context.env, {
    ...payload,
    ipAddress: getClientIp(context),
    userAgent: getUserAgent(context),
  });
  return jsonSuccess(context, session);
});

authRoutes.post("/refresh", async (context) => {
  const payload = refreshSchema.parse(await parseJsonBody(context));
  const accessToken = await refreshAccessToken(context.env, payload.refreshToken);
  return jsonSuccess(context, { accessToken });
});

authRoutes.post("/forgot-password", async (context) => {
  const payload = forgotPasswordSchema.parse(await parseJsonBody(context));
  const result = await createPasswordReset(context.env, payload.email);
  return jsonSuccess(context, result);
});

authRoutes.post("/reset-password", async (context) => {
  const payload = resetPasswordSchema.parse(await parseJsonBody(context));
  await resetPasswordWithToken(context.env, payload);
  return jsonSuccess(context, {
    message: "Password has been reset successfully.",
  });
});

authRoutes.get("/oauth/:provider", async (context) => {
  const provider = getOAuthProvider(context.req.param("provider"));
  const mode = context.req.query("mode") === "link" ? "link" : "login";
  try {
    const auth = mode === "link" ? await authenticateRequest(context) : null;
    const { url } = await createOAuthAuthorization(context.env, {
      provider,
      mode,
      userId: auth?.userId ?? null,
    });

    if (mode === "link") {
      return jsonSuccess(context, { authorizationUrl: url });
    }

    return context.redirect(url, 302);
  } catch (error) {
    if (mode === "login") {
      const code = error instanceof ApiError ? error.code : "OAUTH_FAILED";
      return context.redirect(getOAuthErrorRedirectUrl(context.env, code), 302);
    }

    throw error;
  }
});

authRoutes.get("/oauth/:provider/callback", async (context) => {
  const provider = getOAuthProvider(context.req.param("provider"));
  const code = context.req.query("code");
  const state = context.req.query("state");

  if (!code || !state) {
    throw new ApiError(400, "INVALID_TOKEN", "OAuth callback is missing code or state.");
  }

  try {
    const result = await handleOAuthCallback(context.env, {
      provider,
      code,
      state,
    });

    if (result.mode === "link") {
      return context.redirect(
        getOAuthRedirectUrl(context.env, {
          mode: "link",
          provider: result.provider,
        }),
        302,
      );
    }

    const tokens = await loginAfterOAuth(context.env, {
      user: result.user,
      method: provider,
      ipAddress: getClientIp(context),
      userAgent: getUserAgent(context),
    });

    return context.redirect(
      getOAuthRedirectUrl(context.env, {
        mode: "login",
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      }),
      302,
    );
  } catch (error) {
    console.error(error);
    return context.redirect(getOAuthErrorRedirectUrl(context.env, "OAUTH_FAILED"), 302);
  }
});
