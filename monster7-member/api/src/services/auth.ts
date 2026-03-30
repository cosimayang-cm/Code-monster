import { hashPassword, verifyPassword } from "../utils/password";
import { signAccessToken, signRefreshToken, verifyToken } from "../utils/jwt";
import { ApiError } from "../utils/http";
import { generateOpaqueToken } from "../utils/uuid";
import { validateEmail, validatePassword } from "../utils/validation";
import {
  createUser,
  getPublicUser,
  getUserByEmail,
  getUserById,
  safeRecordLoginHistory,
  updateUserPasswordHash,
} from "./user";

import type { EnvBindings, LoginMethod, PublicUser } from "../types";

const normalizeEmail = (value: string): string => value.trim().toLowerCase();

const getResetLink = (appUrl: string, token: string): string => {
  const url = new URL(appUrl);
  url.pathname = "/reset-password";
  url.searchParams.set("token", token);
  return url.toString();
};

export const issueTokens = async (
  env: EnvBindings,
  user: PublicUser,
): Promise<{ accessToken: string; refreshToken: string }> => {
  const payload = {
    sub: user.id,
    email: user.email,
    role: user.role,
  };

  const [accessToken, refreshToken] = await Promise.all([
    signAccessToken(env.JWT_SECRET, payload),
    signRefreshToken(env.JWT_SECRET, payload),
  ]);

  return {
    accessToken,
    refreshToken,
  };
};

export const registerWithPassword = async (
  env: EnvBindings,
  input: { email: string; password: string },
): Promise<{ user: PublicUser; accessToken: string; refreshToken: string }> => {
  const email = normalizeEmail(input.email);

  if (!validateEmail(email) || !validatePassword(input.password)) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Password must be at least 8 characters with uppercase, lowercase, and numbers.",
    );
  }

  const existing = await getUserByEmail(env, email);

  if (existing) {
    throw new ApiError(409, "CONFLICT", "Email is already registered.");
  }

  const passwordHash = await hashPassword(input.password);
  const user = await createUser(env, { email, passwordHash });
  const tokens = await issueTokens(env, user);

  return {
    user,
    ...tokens,
  };
};

export const loginWithPassword = async (
  env: EnvBindings,
  input: {
    email: string;
    password: string;
    ipAddress: string;
    userAgent: string;
  },
): Promise<{ user: PublicUser; accessToken: string; refreshToken: string }> => {
  const email = normalizeEmail(input.email);
  const existing = await getUserByEmail(env, email);

  if (!existing || !existing.password_hash) {
    throw new ApiError(401, "INVALID_CREDENTIALS", "Email or password is incorrect.");
  }

  if (!Boolean(existing.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  const valid = await verifyPassword(input.password, existing.password_hash);

  if (!valid) {
    throw new ApiError(401, "INVALID_CREDENTIALS", "Email or password is incorrect.");
  }

  const user = getPublicUser(existing) as PublicUser;
  const tokens = await issueTokens(env, user);

  await safeRecordLoginHistory(env, {
    userId: user.id,
    method: "email",
    ipAddress: input.ipAddress,
    userAgent: input.userAgent,
  });

  return {
    user,
    ...tokens,
  };
};

export const refreshAccessToken = async (
  env: EnvBindings,
  refreshToken: string,
): Promise<string> => {
  let claims;

  try {
    claims = await verifyToken(env.JWT_SECRET, refreshToken, "refresh");
  } catch (error) {
    throw new ApiError(400, "INVALID_TOKEN", "Refresh token is invalid or expired.", error);
  }

  const user = await getUserById(env, claims.sub);

  if (!user) {
    throw new ApiError(400, "INVALID_TOKEN", "Refresh token is invalid or expired.");
  }

  if (!Boolean(user.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  return signAccessToken(env.JWT_SECRET, {
    sub: user.id,
    email: user.email,
    role: user.role,
  });
};

export const createPasswordReset = async (
  env: EnvBindings,
  email: string,
): Promise<{ message: string; resetLink: string | null }> => {
  const normalizedEmail = normalizeEmail(email);
  const user = await getUserByEmail(env, normalizedEmail);

  if (!user) {
    return {
      message: "If the email exists, a reset link has been generated.",
      resetLink: null,
    };
  }

  const token = generateOpaqueToken(32);
  await env.KV.put(`reset:${token}`, JSON.stringify({ userId: user.id }), {
    expirationTtl: 60 * 30,
  });

  return {
    message: "If the email exists, a reset link has been generated.",
    resetLink: getResetLink(env.APP_URL, token),
  };
};

export const resetPasswordWithToken = async (
  env: EnvBindings,
  input: { token: string; password: string },
): Promise<void> => {
  if (!validatePassword(input.password)) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Password must be at least 8 characters with uppercase, lowercase, and numbers.",
    );
  }

  const payload = await env.KV.get(`reset:${input.token}`, "json");

  if (!payload || typeof payload !== "object" || !("userId" in payload)) {
    throw new ApiError(400, "INVALID_TOKEN", "Reset token is invalid or expired.");
  }

  const userId = String(payload.userId);
  const passwordHash = await hashPassword(input.password);

  await updateUserPasswordHash(env, userId, passwordHash);
  await env.KV.delete(`reset:${input.token}`);
};

export const changePassword = async (
  env: EnvBindings,
  input: {
    userId: string;
    currentPassword: string;
    newPassword: string;
  },
): Promise<void> => {
  const user = await getUserById(env, input.userId);

  if (!user || !user.password_hash) {
    throw new ApiError(400, "INVALID_CREDENTIALS", "Current password is incorrect.");
  }

  const valid = await verifyPassword(input.currentPassword, user.password_hash);

  if (!valid) {
    throw new ApiError(400, "INVALID_CREDENTIALS", "Current password is incorrect.");
  }

  if (!validatePassword(input.newPassword)) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Password must be at least 8 characters with uppercase, lowercase, and numbers.",
    );
  }

  const nextHash = await hashPassword(input.newPassword);
  await updateUserPasswordHash(env, input.userId, nextHash);
};

export const loginAfterOAuth = async (
  env: EnvBindings,
  input: {
    user: PublicUser;
    method: LoginMethod;
    ipAddress: string;
    userAgent: string;
  },
): Promise<{ accessToken: string; refreshToken: string }> => {
  const tokens = await issueTokens(env, input.user);

  await safeRecordLoginHistory(env, {
    userId: input.user.id,
    method: input.method,
    ipAddress: input.ipAddress,
    userAgent: input.userAgent,
  });

  return tokens;
};
