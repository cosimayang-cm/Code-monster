import { ApiError } from "./errors";
import { signAccessToken, signRefreshToken, verifyToken } from "./jwt";
import { hashPassword, verifyPassword } from "./password";
import {
  createUser,
  getPublicUser,
  getUserByEmail,
  getUserById,
  safeRecordLoginHistory
} from "./users";

import type { EnvBindings, LoginMethod, PublicUser } from "../types/env";

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

const normalizeEmail = (value: string): string => value.trim().toLowerCase();
const inferDisplayName = (email: string): string => email.split("@")[0] ?? "Velocabet User";

const getJwtSecret = (env: EnvBindings): string => {
  if (!env.JWT_SECRET) {
    throw new ApiError(500, "AUTH_NOT_CONFIGURED", "JWT secret is not configured.");
  }

  return env.JWT_SECRET;
};

const validateEmail = (email: string): boolean => EMAIL_REGEX.test(email);
const validatePassword = (password: string): boolean => PASSWORD_REGEX.test(password);

export const issueTokens = async (
  env: EnvBindings,
  user: PublicUser
): Promise<{ accessToken: string; refreshToken: string }> => {
  const secret = getJwtSecret(env);
  const payload = { sub: user.id, email: user.email, role: user.role };
  const [accessToken, refreshToken] = await Promise.all([
    signAccessToken(secret, payload),
    signRefreshToken(secret, payload)
  ]);
  return { accessToken, refreshToken };
};

export const registerWithPassword = async (
  env: EnvBindings,
  input: { email: string; password: string }
): Promise<{ user: PublicUser; accessToken: string; refreshToken: string }> => {
  const email = normalizeEmail(input.email);

  if (!validateEmail(email) || !validatePassword(input.password)) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Password must be at least 8 characters and include uppercase, lowercase, and numbers."
    );
  }

  const existing = await getUserByEmail(env, email);
  if (existing) {
    throw new ApiError(409, "CONFLICT", "Email is already registered.");
  }

  const passwordHash = await hashPassword(input.password);
  const user = await createUser(env, {
    email,
    passwordHash,
    name: inferDisplayName(email)
  });
  const tokens = await issueTokens(env, user);
  return { user, ...tokens };
};

export const loginWithPassword = async (
  env: EnvBindings,
  input: { email: string; password: string; ipAddress: string; userAgent: string }
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
    userAgent: input.userAgent
  });

  return { user, ...tokens };
};

export const refreshAccessToken = async (env: EnvBindings, refreshToken: string): Promise<string> => {
  const claims = await verifyToken(getJwtSecret(env), refreshToken, "refresh");
  const user = await getUserById(env, claims.sub);

  if (!user || !Boolean(user.is_active)) {
    throw new ApiError(401, "UNAUTHORIZED", "Refresh token is invalid or expired.");
  }

  return signAccessToken(getJwtSecret(env), {
    sub: user.id,
    email: user.email,
    role: user.role
  });
};

export const loginAfterOAuth = async (
  env: EnvBindings,
  input: { user: PublicUser; method: LoginMethod; ipAddress: string; userAgent: string }
): Promise<{ accessToken: string; refreshToken: string }> => {
  const tokens = await issueTokens(env, input.user);
  await safeRecordLoginHistory(env, {
    userId: input.user.id,
    method: input.method,
    ipAddress: input.ipAddress,
    userAgent: input.userAgent
  });
  return tokens;
};
