import { ApiError, buildPagination } from "../utils/http";
import { generateUUID } from "../utils/uuid";

import type {
  EnvBindings,
  LoginHistoryRecord,
  LoginMethod,
  OAuthAccountRecord,
  OAuthProvider,
  PaginationMeta,
  PublicUser,
  UserRecord,
  UserRole,
} from "../types";

const USER_SELECT = `
  SELECT
    id,
    email,
    password_hash,
    name,
    bio,
    avatar_url,
    role,
    is_active,
    created_at,
    updated_at
  FROM users
`;

const mapUser = (row: UserRecord | null): PublicUser | null => {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    email: row.email,
    name: row.name,
    bio: row.bio,
    avatar_url: row.avatar_url,
    role: row.role,
    is_active: Boolean(row.is_active),
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
};

const getResults = async <T>(statement: D1PreparedStatement): Promise<T[]> => {
  const result = await statement.all<T>();
  return result.results ?? [];
};

export const getPublicUser = (row: UserRecord | null): PublicUser | null => mapUser(row);

export const getUserByEmail = async (
  env: EnvBindings,
  email: string,
): Promise<UserRecord | null> =>
  env.DB.prepare(`${USER_SELECT} WHERE email = ? LIMIT 1`)
    .bind(email.toLowerCase())
    .first<UserRecord>();

export const getUserById = async (
  env: EnvBindings,
  id: string,
): Promise<UserRecord | null> =>
  env.DB.prepare(`${USER_SELECT} WHERE id = ? LIMIT 1`).bind(id).first<UserRecord>();

export const createUser = async (
  env: EnvBindings,
  input: {
    email: string;
    passwordHash: string | null;
    name?: string | null;
    bio?: string | null;
    avatarUrl?: string | null;
    role?: UserRole;
  },
): Promise<PublicUser> => {
  const id = generateUUID();
  const timestamp = new Date().toISOString();
  const normalizedEmail = input.email.toLowerCase();

  await env.DB.prepare(
    `
      INSERT INTO users (
        id,
        email,
        password_hash,
        name,
        bio,
        avatar_url,
        role,
        is_active,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
    `,
  )
    .bind(
      id,
      normalizedEmail,
      input.passwordHash,
      input.name ?? null,
      input.bio ?? null,
      input.avatarUrl ?? null,
      input.role ?? "user",
      timestamp,
      timestamp,
    )
    .run();

  const created = await getUserById(env, id);

  if (!created) {
    throw new ApiError(500, "CREATE_USER_FAILED", "Failed to create user.");
  }

  return mapUser(created) as PublicUser;
};

export const updateUserProfile = async (
  env: EnvBindings,
  userId: string,
  input: { name: string | null; bio: string | null },
): Promise<PublicUser> => {
  const timestamp = new Date().toISOString();

  await env.DB.prepare(
    `
      UPDATE users
      SET name = ?, bio = ?, updated_at = ?
      WHERE id = ?
    `,
  )
    .bind(input.name, input.bio, timestamp, userId)
    .run();

  const updated = await getUserById(env, userId);

  if (!updated) {
    throw new ApiError(404, "NOT_FOUND", "User not found.");
  }

  return mapUser(updated) as PublicUser;
};

export const updateUserPasswordHash = async (
  env: EnvBindings,
  userId: string,
  passwordHash: string,
): Promise<void> => {
  await env.DB.prepare(
    `
      UPDATE users
      SET password_hash = ?, updated_at = ?
      WHERE id = ?
    `,
  )
    .bind(passwordHash, new Date().toISOString(), userId)
    .run();
};

export const updateUserAvatar = async (
  env: EnvBindings,
  userId: string,
  avatarUrl: string,
): Promise<string> => {
  await env.DB.prepare(
    `
      UPDATE users
      SET avatar_url = ?, updated_at = ?
      WHERE id = ?
    `,
  )
    .bind(avatarUrl, new Date().toISOString(), userId)
    .run();

  return avatarUrl;
};

export const recordLoginHistory = async (
  env: EnvBindings,
  input: {
    userId: string;
    method: LoginMethod;
    ipAddress: string;
    userAgent: string;
  },
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
    `,
  )
    .bind(
      generateUUID(),
      input.userId,
      input.method,
      input.ipAddress,
      input.userAgent,
      new Date().toISOString(),
    )
    .run();
};

export const safeRecordLoginHistory = async (
  env: EnvBindings,
  input: {
    userId: string;
    method: LoginMethod;
    ipAddress: string;
    userAgent: string;
  },
): Promise<void> => {
  try {
    await recordLoginHistory(env, input);
  } catch (error) {
    console.warn("Unable to record login history.", error);
  }
};

export const getLoginHistory = async (
  env: EnvBindings,
  userId: string,
  pagination: { page: number; pageSize: number; offset: number },
): Promise<{ rows: Omit<LoginHistoryRecord, "user_id">[]; pagination: PaginationMeta }> => {
  const [countRow, rows] = await Promise.all([
    env.DB.prepare(`SELECT COUNT(*) AS total FROM login_history WHERE user_id = ?`)
      .bind(userId)
      .first<{ total: number }>(),
    getResults<Omit<LoginHistoryRecord, "user_id">>(
      env.DB.prepare(
        `
          SELECT id, method, ip_address, user_agent, created_at
          FROM login_history
          WHERE user_id = ?
          ORDER BY created_at DESC
          LIMIT ? OFFSET ?
        `,
      ).bind(userId, pagination.pageSize, pagination.offset),
    ),
  ]);

  return {
    rows,
    pagination: buildPagination(Number(countRow?.total ?? 0), pagination.page, pagination.pageSize),
  };
};

export const getOAuthAccounts = async (
  env: EnvBindings,
  userId: string,
): Promise<Omit<OAuthAccountRecord, "user_id" | "provider_id">[]> =>
  getResults<Omit<OAuthAccountRecord, "user_id" | "provider_id">>(
    env.DB.prepare(
      `
        SELECT id, provider, provider_email, created_at
        FROM oauth_accounts
        WHERE user_id = ?
        ORDER BY created_at DESC
      `,
    ).bind(userId),
  );

export const findOAuthAccountByProviderIdentity = async (
  env: EnvBindings,
  provider: OAuthProvider,
  providerId: string,
): Promise<OAuthAccountRecord | null> =>
  env.DB.prepare(
    `
      SELECT id, user_id, provider, provider_id, provider_email, created_at
      FROM oauth_accounts
      WHERE provider = ? AND provider_id = ?
      LIMIT 1
    `,
  )
    .bind(provider, providerId)
    .first<OAuthAccountRecord>();

export const findOAuthAccountByUserProvider = async (
  env: EnvBindings,
  userId: string,
  provider: OAuthProvider,
): Promise<OAuthAccountRecord | null> =>
  env.DB.prepare(
    `
      SELECT id, user_id, provider, provider_id, provider_email, created_at
      FROM oauth_accounts
      WHERE user_id = ? AND provider = ?
      LIMIT 1
    `,
  )
    .bind(userId, provider)
    .first<OAuthAccountRecord>();

export const createOAuthAccount = async (
  env: EnvBindings,
  input: {
    userId: string;
    provider: OAuthProvider;
    providerId: string;
    providerEmail: string | null;
  },
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
    `,
  )
    .bind(
      generateUUID(),
      input.userId,
      input.provider,
      input.providerId,
      input.providerEmail,
      new Date().toISOString(),
    )
    .run();
};

export const unlinkOAuthAccount = async (
  env: EnvBindings,
  userId: string,
  provider: OAuthProvider,
): Promise<void> => {
  await env.DB.prepare(
    `
      DELETE FROM oauth_accounts
      WHERE user_id = ? AND provider = ?
    `,
  )
    .bind(userId, provider)
    .run();
};

export const listUsers = async (
  env: EnvBindings,
  input: {
    page: number;
    pageSize: number;
    offset: number;
    search?: string;
  },
): Promise<{
  rows: Pick<PublicUser, "id" | "email" | "name" | "role" | "is_active" | "created_at">[];
  pagination: PaginationMeta;
}> => {
  const search = input.search?.trim();
  const hasSearch = Boolean(search);
  const whereClause = hasSearch ? "WHERE email LIKE ? OR name LIKE ?" : "";
  const likeValue = `%${search ?? ""}%`;

  const countStatement = hasSearch
    ? env.DB.prepare(`SELECT COUNT(*) AS total FROM users ${whereClause}`).bind(
        likeValue,
        likeValue,
      )
    : env.DB.prepare("SELECT COUNT(*) AS total FROM users");

  const listStatement = hasSearch
    ? env.DB.prepare(
        `
          SELECT id, email, name, role, is_active, created_at
          FROM users
          ${whereClause}
          ORDER BY created_at DESC
          LIMIT ? OFFSET ?
        `,
      ).bind(likeValue, likeValue, input.pageSize, input.offset)
    : env.DB.prepare(
        `
          SELECT id, email, name, role, is_active, created_at
          FROM users
          ORDER BY created_at DESC
          LIMIT ? OFFSET ?
        `,
      ).bind(input.pageSize, input.offset);

  const [countRow, rows] = await Promise.all([
    countStatement.first<{ total: number }>(),
    getResults<{
      id: string;
      email: string;
      name: string | null;
      role: UserRole;
      is_active: number | boolean;
      created_at: string;
    }>(listStatement),
  ]);

  return {
    rows: rows.map((row) => ({
      ...row,
      is_active: Boolean(row.is_active),
    })),
    pagination: buildPagination(Number(countRow?.total ?? 0), input.page, input.pageSize),
  };
};

export const getAdminUserDetail = async (
  env: EnvBindings,
  userId: string,
): Promise<
  | (PublicUser & {
      oauthAccounts: Omit<OAuthAccountRecord, "user_id" | "provider_id" | "id">[];
      recentLogins: Omit<LoginHistoryRecord, "user_id" | "id">[];
    })
  | null
> => {
  const user = await getUserById(env, userId);

  if (!user) {
    return null;
  }

  const [oauthAccounts, recentLogins] = await Promise.all([
    getResults<Omit<OAuthAccountRecord, "user_id" | "provider_id" | "id">>(
      env.DB.prepare(
        `
          SELECT provider, provider_email, created_at
          FROM oauth_accounts
          WHERE user_id = ?
          ORDER BY created_at DESC
        `,
      ).bind(userId),
    ),
    getResults<Omit<LoginHistoryRecord, "user_id" | "id">>(
      env.DB.prepare(
        `
          SELECT method, ip_address, user_agent, created_at
          FROM login_history
          WHERE user_id = ?
          ORDER BY created_at DESC
          LIMIT 10
        `,
      ).bind(userId),
    ),
  ]);

  return {
    ...(mapUser(user) as PublicUser),
    oauthAccounts,
    recentLogins,
  };
};

export const updateUserRole = async (
  env: EnvBindings,
  userId: string,
  role: UserRole,
): Promise<{ id: string; role: UserRole; updated_at: string }> => {
  const updatedAt = new Date().toISOString();
  const result = await env.DB.prepare(
    `
      UPDATE users
      SET role = ?, updated_at = ?
      WHERE id = ?
    `,
  )
    .bind(role, updatedAt, userId)
    .run();

  if (!result.success || result.meta.changes === 0) {
    throw new ApiError(404, "NOT_FOUND", "User not found.");
  }

  return { id: userId, role, updated_at: updatedAt };
};

export const updateUserStatus = async (
  env: EnvBindings,
  userId: string,
  isActive: boolean,
): Promise<{ id: string; is_active: boolean; updated_at: string }> => {
  const updatedAt = new Date().toISOString();
  const result = await env.DB.prepare(
    `
      UPDATE users
      SET is_active = ?, updated_at = ?
      WHERE id = ?
    `,
  )
    .bind(isActive ? 1 : 0, updatedAt, userId)
    .run();

  if (!result.success || result.meta.changes === 0) {
    throw new ApiError(404, "NOT_FOUND", "User not found.");
  }

  return { id: userId, is_active: isActive, updated_at: updatedAt };
};

export const getDashboardStats = async (env: EnvBindings) => {
  const now = new Date();
  const startOfToday = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  ).toISOString();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

  const [
    totalUsers,
    todayRegistrations,
    activeUsers7d,
    disabledUsers,
    oauthLinkedUsers,
    logins24h,
  ] = await Promise.all([
    env.DB.prepare("SELECT COUNT(*) AS total FROM users").first<{ total: number }>(),
    env.DB.prepare("SELECT COUNT(*) AS total FROM users WHERE created_at >= ?")
      .bind(startOfToday)
      .first<{ total: number }>(),
    env.DB.prepare(
      `
        SELECT COUNT(DISTINCT user_id) AS total
        FROM login_history
        WHERE created_at >= ?
      `,
    )
      .bind(sevenDaysAgo)
      .first<{ total: number }>(),
    env.DB.prepare("SELECT COUNT(*) AS total FROM users WHERE is_active = 0").first<{
      total: number;
    }>(),
    env.DB.prepare("SELECT COUNT(DISTINCT user_id) AS total FROM oauth_accounts").first<{
      total: number;
    }>(),
    env.DB.prepare("SELECT COUNT(*) AS total FROM login_history WHERE created_at >= ?")
      .bind(twentyFourHoursAgo)
      .first<{ total: number }>(),
  ]);

  const total = Number(totalUsers?.total ?? 0);
  const oauthCount = Number(oauthLinkedUsers?.total ?? 0);

  return {
    totalUsers: total,
    todayRegistrations: Number(todayRegistrations?.total ?? 0),
    activeUsers7d: Number(activeUsers7d?.total ?? 0),
    disabledUsers: Number(disabledUsers?.total ?? 0),
    oauthLinkedRatio: total === 0 ? 0 : Number((oauthCount / total).toFixed(2)),
    logins24h: Number(logins24h?.total ?? 0),
  };
};

export const listActivity = async (
  env: EnvBindings,
  input: {
    page: number;
    pageSize: number;
    offset: number;
    method?: LoginMethod;
    from?: string;
    to?: string;
  },
): Promise<{
  rows: Array<
    Omit<LoginHistoryRecord, "user_id"> & {
      email: string;
      name: string | null;
    }
  >;
  pagination: PaginationMeta;
}> => {
  const conditions: string[] = [];
  const bindings: unknown[] = [];

  if (input.method) {
    conditions.push("lh.method = ?");
    bindings.push(input.method);
  }

  if (input.from) {
    conditions.push("lh.created_at >= ?");
    bindings.push(new Date(input.from).toISOString());
  }

  if (input.to) {
    const inclusiveEnd = new Date(`${input.to}T23:59:59.999Z`).toISOString();
    conditions.push("lh.created_at <= ?");
    bindings.push(inclusiveEnd);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const countStatement = env.DB.prepare(
    `
      SELECT COUNT(*) AS total
      FROM login_history lh
      INNER JOIN users u ON u.id = lh.user_id
      ${whereClause}
    `,
  ).bind(...bindings);

  const rowsStatement = env.DB.prepare(
    `
      SELECT
        lh.id,
        lh.method,
        lh.ip_address,
        lh.user_agent,
        lh.created_at,
        u.email,
        u.name
      FROM login_history lh
      INNER JOIN users u ON u.id = lh.user_id
      ${whereClause}
      ORDER BY lh.created_at DESC
      LIMIT ? OFFSET ?
    `,
  ).bind(...bindings, input.pageSize, input.offset);

  const [countRow, rows] = await Promise.all([
    countStatement.first<{ total: number }>(),
    getResults<
      Omit<LoginHistoryRecord, "user_id"> & {
        email: string;
        name: string | null;
      }
    >(rowsStatement),
  ]);

  return {
    rows,
    pagination: buildPagination(Number(countRow?.total ?? 0), input.page, input.pageSize),
  };
};
