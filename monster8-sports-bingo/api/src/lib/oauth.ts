import { generateCodeVerifier, generateState, GitHub, Google } from "arctic";

import { ApiError } from "./errors";
import {
  createOAuthAccount,
  createUser,
  findOAuthAccountByProviderIdentity,
  findOAuthAccountByUserProvider,
  getPublicUser,
  getUserByEmail,
  getUserById
} from "./users";

import type { EnvBindings, OAuthProvider, PublicUser, UserRow } from "../types/env";

interface OAuthStateRecord {
  provider: OAuthProvider;
  codeVerifier: string | null;
}

interface OAuthProfile {
  provider: OAuthProvider;
  providerId: string;
  email: string | null;
  name: string | null;
}

const OAUTH_STATE_KEY_PREFIX = "auth:oauth-state:";

const getApiUrl = (env: EnvBindings): string => {
  if (!env.API_URL) {
    throw new ApiError(500, "AUTH_NOT_CONFIGURED", "API URL is not configured.");
  }
  return env.API_URL;
};

const getAppUrl = (env: EnvBindings): string => {
  if (!env.APP_URL) {
    throw new ApiError(500, "AUTH_NOT_CONFIGURED", "App URL is not configured.");
  }
  return env.APP_URL;
};

const getCallbackUrl = (env: EnvBindings, provider: OAuthProvider): string => {
  const url = new URL(getApiUrl(env));
  url.pathname = `/api/auth/oauth/${provider}/callback`;
  return url.toString();
};

const getFrontendCallbackUrl = (env: EnvBindings, query: Record<string, string>): string => {
  const url = new URL(getAppUrl(env));
  for (const [key, value] of Object.entries(query)) {
    url.searchParams.set(key, value);
  }
  return url.toString();
};

const ensureProviderSecrets = (env: EnvBindings, provider: OAuthProvider): void => {
  if (provider === "google" && (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET)) {
    throw new ApiError(400, "OAUTH_NOT_CONFIGURED", "Google OAuth is not configured.");
  }

  if (provider === "github" && (!env.GITHUB_CLIENT_ID || !env.GITHUB_CLIENT_SECRET)) {
    throw new ApiError(400, "OAUTH_NOT_CONFIGURED", "GitHub OAuth is not configured.");
  }
};

const getProviderClient = (env: EnvBindings, provider: OAuthProvider): Google | GitHub => {
  ensureProviderSecrets(env, provider);

  if (provider === "google") {
    return new Google(env.GOOGLE_CLIENT_ID as string, env.GOOGLE_CLIENT_SECRET as string, getCallbackUrl(env, provider));
  }

  return new GitHub(env.GITHUB_CLIENT_ID as string, env.GITHUB_CLIENT_SECRET as string, getCallbackUrl(env, provider));
};

const fetchGoogleProfile = async (env: EnvBindings, code: string, codeVerifier: string): Promise<OAuthProfile> => {
  const google = getProviderClient(env, "google") as Google;
  const tokens = await google.validateAuthorizationCode(code, codeVerifier);
  const response = await fetch("https://openidconnect.googleapis.com/v1/userinfo", {
    headers: { Authorization: `Bearer ${tokens.accessToken()}` }
  });

  if (!response.ok) {
    throw new ApiError(400, "OAUTH_FAILED", "Unable to fetch Google profile.");
  }

  const profile = (await response.json()) as { sub: string; email?: string; name?: string };
  return {
    provider: "google",
    providerId: profile.sub,
    email: profile.email ?? null,
    name: profile.name ?? null
  };
};

const fetchGitHubProfile = async (env: EnvBindings, code: string): Promise<OAuthProfile> => {
  const github = getProviderClient(env, "github") as GitHub;
  const tokens = await github.validateAuthorizationCode(code);
  const headers = {
    Authorization: `Bearer ${tokens.accessToken()}`,
    "User-Agent": "velocabet",
    Accept: "application/vnd.github+json"
  };

  const [userResponse, emailsResponse] = await Promise.all([
    fetch("https://api.github.com/user", { headers }),
    fetch("https://api.github.com/user/emails", { headers })
  ]);

  if (!userResponse.ok || !emailsResponse.ok) {
    throw new ApiError(400, "OAUTH_FAILED", "Unable to fetch GitHub profile.");
  }

  const user = (await userResponse.json()) as { id: number; name?: string; login?: string };
  const emails = (await emailsResponse.json()) as Array<{ email: string; verified: boolean; primary: boolean }>;
  const primary = emails.find((item) => item.primary && item.verified) ?? emails[0] ?? null;

  return {
    provider: "github",
    providerId: String(user.id),
    email: primary?.email ?? null,
    name: user.name ?? user.login ?? null
  };
};

const resolveOAuthProfile = async (
  env: EnvBindings,
  stateRecord: OAuthStateRecord,
  code: string
): Promise<OAuthProfile> => {
  if (stateRecord.provider === "google") {
    if (!stateRecord.codeVerifier) {
      throw new ApiError(400, "INVALID_TOKEN", "OAuth state is invalid.");
    }

    return fetchGoogleProfile(env, code, stateRecord.codeVerifier);
  }

  return fetchGitHubProfile(env, code);
};

const createOAuthUser = async (env: EnvBindings, profile: OAuthProfile): Promise<PublicUser> => {
  if (!profile.email) {
    throw new ApiError(400, "OAUTH_EMAIL_REQUIRED", "OAuth provider did not return a usable email.");
  }

  return createUser(env, {
    email: profile.email,
    passwordHash: null,
    name: profile.name ?? profile.email.split("@")[0] ?? "Velocabet User"
  });
};

export const getOAuthErrorRedirectUrl = (env: EnvBindings, code: string): string =>
  getFrontendCallbackUrl(env, { auth_error: code });

export const getOAuthRedirectUrl = (
  env: EnvBindings,
  query: { accessToken: string; refreshToken: string }
): string =>
  getFrontendCallbackUrl(env, {
    auth_callback: "1",
    accessToken: query.accessToken,
    refreshToken: query.refreshToken
  });

export const getOAuthProvider = (value: string): OAuthProvider => {
  if (value === "google" || value === "github") {
    return value;
  }

  throw new ApiError(404, "NOT_FOUND", "Unsupported OAuth provider.");
};

export const getConfiguredProviders = (env: EnvBindings): Record<OAuthProvider, boolean> => ({
  google: Boolean(env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_SECRET),
  github: Boolean(env.GITHUB_CLIENT_ID && env.GITHUB_CLIENT_SECRET)
});

export const createOAuthAuthorization = async (
  env: EnvBindings,
  provider: OAuthProvider
): Promise<{ state: string; url: string }> => {
  const state = generateState();
  const providerClient = getProviderClient(env, provider);
  let codeVerifier: string | null = null;
  let url: URL;

  if (provider === "google") {
    codeVerifier = generateCodeVerifier();
    url = (providerClient as Google).createAuthorizationURL(state, codeVerifier, ["openid", "profile", "email"]);
  } else {
    url = (providerClient as GitHub).createAuthorizationURL(state, ["read:user", "user:email"]);
  }

  await env.SPORTS_CACHE.put(
    `${OAUTH_STATE_KEY_PREFIX}${state}`,
    JSON.stringify({
      provider,
      codeVerifier
    } satisfies OAuthStateRecord),
    { expirationTtl: 60 * 10 }
  );

  return { state, url: url.toString() };
};

export const handleOAuthCallback = async (
  env: EnvBindings,
  input: { provider: OAuthProvider; state: string; code: string }
): Promise<PublicUser> => {
  const statePayload = await env.SPORTS_CACHE.get(`${OAUTH_STATE_KEY_PREFIX}${input.state}`, "json");
  await env.SPORTS_CACHE.delete(`${OAUTH_STATE_KEY_PREFIX}${input.state}`);

  if (!statePayload || typeof statePayload !== "object") {
    throw new ApiError(400, "INVALID_TOKEN", "OAuth state is invalid or expired.");
  }

  const stateRecord = statePayload as OAuthStateRecord;
  if (stateRecord.provider !== input.provider) {
    throw new ApiError(400, "INVALID_TOKEN", "OAuth provider mismatch.");
  }

  const profile = await resolveOAuthProfile(env, stateRecord, input.code);
  const linkedAccount = await findOAuthAccountByProviderIdentity(env, profile.provider, profile.providerId);

  if (linkedAccount) {
    const linkedUser = await getUserById(env, linkedAccount.user_id);
    if (!linkedUser || !Boolean(linkedUser.is_active)) {
      throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
    }
    return getPublicUser(linkedUser) as PublicUser;
  }

  let targetUser: UserRow | null = null;
  if (profile.email) {
    targetUser = await getUserByEmail(env, profile.email);
  }

  if (!targetUser) {
    const createdUser = await createOAuthUser(env, profile);
    await createOAuthAccount(env, {
      userId: createdUser.id,
      provider: profile.provider,
      providerId: profile.providerId,
      providerEmail: profile.email
    });
    return createdUser;
  }

  if (!Boolean(targetUser.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  const existingByUserProvider = await findOAuthAccountByUserProvider(env, targetUser.id, profile.provider);
  if (!existingByUserProvider) {
    await createOAuthAccount(env, {
      userId: targetUser.id,
      provider: profile.provider,
      providerId: profile.providerId,
      providerEmail: profile.email
    });
  }

  return getPublicUser(targetUser) as PublicUser;
};
