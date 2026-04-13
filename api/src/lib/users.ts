import { ApiError } from "./errors";

import type {
  EnvBindings,
  LoginMethod,
  OAuthAccountRow,
  OAuthProvider,
  PublicUser,
  UserRow,
  UserRole
} from "../types/env";

const USER_SELECT = `
  SELECT
    id,
    email,
    password_hash,
    name,
    role,
    is_active,
    created_at,
    updated_at
  FROM users
`;

const mapUser = (row: UserRow | null): PublicUser | null => {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role,
    is_active: Boolean(row.is_active),
    created_at: row.created_at,
    updated_at: row.updated_at
  };
};

export const getPublicUser = (row: UserRow | null): PublicUser | null => mapUser(row);

export const getUserByEmail = async (env: EnvBindings, email: string): Promise<UserRow | null> =>
  env.DB.prepare(`${USER_SELECT} WHERE email = ? LIMIT 1`)
    .bind(email.toLowerCase())
    .first<UserRow>();

export const getUserById = async (env: EnvBindings, id: string): Promise<UserRow | null> =>
  env.DB.prepare(`${USER_SELECT} WHERE id = ? LIMIT 1`).bind(id).first<UserRow>();

export const createUser = async (
  env: EnvBindings,
  input: {
    email: string;
    passwordHash: string | null;
    name?: string | null;
    role?: UserRole;
  }
): Promise<PublicUser> => {
  const id = crypto.randomUUID();
  const timestamp = new Date().toISOString();

  await env.DB.prepare(
    `
      INSERT INTO users (
        id,
        email,
        password_hash,
        name,
        role,
        is_active,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, 1, ?, ?)
    `
  )
    .bind(id, input.email.toLowerCase(), input.passwordHash, input.name ?? null, input.role ?? "user", timestamp, timestamp)
    .run();

  const created = await getUserById(env, id);
  if (!created) {
    throw new ApiError(500, "CREATE_USER_FAILED", "Failed to create user");
  }

  return mapUser(created) as PublicUser;
};

export const recordLoginHistory = async (
  env: EnvBindings,
  input: { userId: string; method: LoginMethod; ipAddress: string; userAgent: string }
): Promise<void> => {
  await env.DB.prepare(
    `
      INSERT INTO login_history (
        id,
        user_id,
        method,
        ip_address,
        user_agent,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?)
    `
  )
    .bind(crypto.randomUUID(), input.userId, input.method, input.ipAddress, input.userAgent, new Date().toISOString())
    .run();
};

export const safeRecordLoginHistory = async (
  env: EnvBindings,
  input: { userId: string; method: LoginMethod; ipAddress: string; userAgent: string }
): Promise<void> => {
  try {
    await recordLoginHistory(env, input);
  } catch (error) {
    console.warn("Unable to record login history.", error);
  }
};

export const findOAuthAccountByProviderIdentity = async (
  env: EnvBindings,
  provider: OAuthProvider,
  providerId: string
): Promise<OAuthAccountRow | null> =>
  env.DB.prepare(
    `
      SELECT id, user_id, provider, provider_id, provider_email, created_at
      FROM oauth_accounts
      WHERE provider = ? AND provider_id = ?
      LIMIT 1
    `
  )
    .bind(provider, providerId)
    .first<OAuthAccountRow>();

export const findOAuthAccountByUserProvider = async (
  env: EnvBindings,
  userId: string,
  provider: OAuthProvider
): Promise<OAuthAccountRow | null> =>
  env.DB.prepare(
    `
      SELECT id, user_id, provider, provider_id, provider_email, created_at
      FROM oauth_accounts
      WHERE user_id = ? AND provider = ?
      LIMIT 1
    `
  )
    .bind(userId, provider)
    .first<OAuthAccountRow>();

export const createOAuthAccount = async (
  env: EnvBindings,
  input: { userId: string; provider: OAuthProvider; providerId: string; providerEmail: string | null }
): Promise<void> => {
  await env.DB.prepare(
    `
      INSERT INTO oauth_accounts (
        id,
        user_id,
        provider,
        provider_id,
        provider_email,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?)
    `
  )
    .bind(crypto.randomUUID(), input.userId, input.provider, input.providerId, input.providerEmail, new Date().toISOString())
    .run();
};
