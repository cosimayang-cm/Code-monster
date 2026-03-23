import {
  generateCodeVerifier,
  generateState,
  GitHub,
  Google,
} from "arctic";

import { ApiError } from "../utils/http";
import { validateEmail } from "../utils/validation";
import {
  createOAuthAccount,
  createUser,
  findOAuthAccountByProviderIdentity,
  findOAuthAccountByUserProvider,
  getPublicUser,
  getUserByEmail,
  getUserById,
} from "./user";

import type { EnvBindings, OAuthProvider, PublicUser } from "../types";

interface OAuthStateRecord {
  provider: OAuthProvider;
  mode: "login" | "link";
  userId: string | null;
  codeVerifier: string | null;
}

interface OAuthProfile {
  provider: OAuthProvider;
  providerId: string;
  email: string | null;
  name: string | null;
}

const getCallbackUrl = (env: EnvBindings, provider: OAuthProvider): string => {
  const url = new URL(env.API_URL);
  url.pathname = `/api/auth/oauth/${provider}/callback`;
  return url.toString();
};

const getFrontendCallbackUrl = (env: EnvBindings, query: Record<string, string>): string => {
  const url = new URL(env.APP_URL);
  url.pathname = "/auth/callback";

  for (const [key, value] of Object.entries(query)) {
    url.searchParams.set(key, value);
  }

  return url.toString();
};

const getProfileRedirectUrl = (env: EnvBindings, query: Record<string, string>): string => {
  const url = new URL(env.APP_URL);
  url.pathname = "/profile";

  for (const [key, value] of Object.entries(query)) {
    url.searchParams.set(key, value);
  }

  return url.toString();
};

const ensureProviderSecrets = (env: EnvBindings, provider: OAuthProvider) => {
  if (
    provider === "google" &&
    (!env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET)
  ) {
    throw new ApiError(400, "OAUTH_NOT_CONFIGURED", "Google OAuth is not configured.");
  }

  if (
    provider === "github" &&
    (!env.GITHUB_CLIENT_ID || !env.GITHUB_CLIENT_SECRET)
  ) {
    throw new ApiError(400, "OAUTH_NOT_CONFIGURED", "GitHub OAuth is not configured.");
  }
};

const getProviderClient = (env: EnvBindings, provider: OAuthProvider) => {
  ensureProviderSecrets(env, provider);

  if (provider === "google") {
    return new Google(
      env.GOOGLE_CLIENT_ID as string,
      env.GOOGLE_CLIENT_SECRET as string,
      getCallbackUrl(env, provider),
    );
  }

  return new GitHub(
    env.GITHUB_CLIENT_ID as string,
    env.GITHUB_CLIENT_SECRET as string,
    getCallbackUrl(env, provider),
  );
};

const fetchGoogleProfile = async (
  env: EnvBindings,
  code: string,
  codeVerifier: string,
): Promise<OAuthProfile> => {
  const google = getProviderClient(env, "google") as Google;
  const tokens = await google.validateAuthorizationCode(code, codeVerifier);
  const profileResponse = await fetch("https://openidconnect.googleapis.com/v1/userinfo", {
    headers: {
      Authorization: `Bearer ${tokens.accessToken()}`,
    },
  });

  if (!profileResponse.ok) {
    throw new ApiError(400, "OAUTH_FAILED", "Unable to fetch Google profile.");
  }

  const profile = (await profileResponse.json()) as {
    sub: string;
    email?: string;
    name?: string;
  };

  return {
    provider: "google",
    providerId: profile.sub,
    email: profile.email ?? null,
    name: profile.name ?? null,
  };
};

const fetchGitHubProfile = async (
  env: EnvBindings,
  code: string,
): Promise<OAuthProfile> => {
  const github = getProviderClient(env, "github") as GitHub;
  const tokens = await github.validateAuthorizationCode(code);
  const headers = {
    Authorization: `Bearer ${tokens.accessToken()}`,
    "User-Agent": "monster7-member-app",
    Accept: "application/vnd.github+json",
  };

  const [userResponse, emailResponse] = await Promise.all([
    fetch("https://api.github.com/user", { headers }),
    fetch("https://api.github.com/user/emails", { headers }),
  ]);

  if (!userResponse.ok || !emailResponse.ok) {
    throw new ApiError(400, "OAUTH_FAILED", "Unable to fetch GitHub profile.");
  }

  const user = (await userResponse.json()) as {
    id: number;
    name?: string;
    login?: string;
  };
  const emails = (await emailResponse.json()) as Array<{
    email: string;
    verified: boolean;
    primary: boolean;
  }>;
  const primary = emails.find((item) => item.primary && item.verified) ?? emails[0] ?? null;

  return {
    provider: "github",
    providerId: String(user.id),
    email: primary?.email ?? null,
    name: user.name ?? user.login ?? null,
  };
};

export const createOAuthAuthorization = async (
  env: EnvBindings,
  input: { provider: OAuthProvider; mode: "login" | "link"; userId: string | null },
): Promise<{ state: string; url: string }> => {
  const state = generateState();
  const providerClient = getProviderClient(env, input.provider);
  let codeVerifier: string | null = null;
  let url: URL;

  if (input.provider === "google") {
    codeVerifier = generateCodeVerifier();
    url = (providerClient as Google).createAuthorizationURL(state, codeVerifier, [
      "openid",
      "profile",
      "email",
    ]);
  } else {
    url = (providerClient as GitHub).createAuthorizationURL(state, ["read:user", "user:email"]);
  }

  const stateRecord: OAuthStateRecord = {
    provider: input.provider,
    mode: input.mode,
    userId: input.userId,
    codeVerifier,
  };

  await env.KV.put(`oauth_state:${state}`, JSON.stringify(stateRecord), {
    expirationTtl: 60 * 10,
  });

  return {
    state,
    url: url.toString(),
  };
};

const resolveOAuthProfile = async (
  env: EnvBindings,
  stateRecord: OAuthStateRecord,
  code: string,
): Promise<OAuthProfile> => {
  if (stateRecord.provider === "google") {
    if (!stateRecord.codeVerifier) {
      throw new ApiError(400, "INVALID_TOKEN", "OAuth state is invalid.");
    }

    return fetchGoogleProfile(env, code, stateRecord.codeVerifier);
  }

  return fetchGitHubProfile(env, code);
};

const createOAuthUser = async (
  env: EnvBindings,
  profile: OAuthProfile,
): Promise<PublicUser> => {
  const fallbackEmail = profile.email;

  if (!fallbackEmail || !validateEmail(fallbackEmail)) {
    throw new ApiError(
      400,
      "OAUTH_EMAIL_REQUIRED",
      "OAuth provider did not return a usable email address.",
    );
  }

  return createUser(env, {
    email: fallbackEmail,
    passwordHash: null,
    name: profile.name ?? fallbackEmail.split("@")[0] ?? "Monster7 User",
  });
};

export const handleOAuthCallback = async (
  env: EnvBindings,
  input: {
    provider: OAuthProvider;
    state: string;
    code: string;
  },
): Promise<
  | { mode: "login"; user: PublicUser }
  | { mode: "link"; provider: OAuthProvider }
> => {
  const statePayload = await env.KV.get(`oauth_state:${input.state}`, "json");
  await env.KV.delete(`oauth_state:${input.state}`);

  if (!statePayload || typeof statePayload !== "object") {
    throw new ApiError(400, "INVALID_TOKEN", "OAuth state is invalid or expired.");
  }

  const stateRecord = statePayload as OAuthStateRecord;

  if (stateRecord.provider !== input.provider) {
    throw new ApiError(400, "INVALID_TOKEN", "OAuth provider mismatch.");
  }

  const profile = await resolveOAuthProfile(env, stateRecord, input.code);
  const linkedAccount = await findOAuthAccountByProviderIdentity(
    env,
    profile.provider,
    profile.providerId,
  );

  if (stateRecord.mode === "link") {
    if (!stateRecord.userId) {
      throw new ApiError(401, "UNAUTHORIZED", "Sign in before linking OAuth accounts.");
    }

    const currentUser = await getUserById(env, stateRecord.userId);

    if (!currentUser || !Boolean(currentUser.is_active)) {
      throw new ApiError(401, "UNAUTHORIZED", "User session is no longer valid.");
    }

    if (linkedAccount && linkedAccount.user_id !== currentUser.id) {
      throw new ApiError(
        409,
        "CONFLICT",
        "This OAuth account is already linked to another user.",
      );
    }

    const existingByUserProvider = await findOAuthAccountByUserProvider(
      env,
      currentUser.id,
      profile.provider,
    );

    if (!existingByUserProvider) {
      await createOAuthAccount(env, {
        userId: currentUser.id,
        provider: profile.provider,
        providerId: profile.providerId,
        providerEmail: profile.email,
      });
    }

    return {
      mode: "link",
      provider: profile.provider,
    };
  }

  if (linkedAccount) {
    const user = await getUserById(env, linkedAccount.user_id);

    if (!user || !Boolean(user.is_active)) {
      throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
    }

    return {
      mode: "login",
      user: getPublicUser(user) as PublicUser,
    };
  }

  let targetUser = null;

  if (profile.email) {
    targetUser = await getUserByEmail(env, profile.email);
  }

  if (!targetUser) {
    const createdUser = await createOAuthUser(env, profile);
    await createOAuthAccount(env, {
      userId: createdUser.id,
      provider: profile.provider,
      providerId: profile.providerId,
      providerEmail: profile.email,
    });

    return {
      mode: "login",
      user: createdUser,
    };
  }

  if (!Boolean(targetUser.is_active)) {
    throw new ApiError(401, "ACCOUNT_DISABLED", "This account has been disabled.");
  }

  const existingByProvider = await findOAuthAccountByUserProvider(
    env,
    targetUser.id,
    profile.provider,
  );

  if (!existingByProvider) {
    await createOAuthAccount(env, {
      userId: targetUser.id,
      provider: profile.provider,
      providerId: profile.providerId,
      providerEmail: profile.email,
    });
  }

  return {
    mode: "login",
    user: getPublicUser(targetUser) as PublicUser,
  };
};

export const getOAuthRedirectUrl = (
  env: EnvBindings,
  input:
    | {
        mode: "login";
        accessToken: string;
        refreshToken: string;
      }
    | {
        mode: "link";
        provider: OAuthProvider;
      },
): string => {
  if (input.mode === "login") {
    return getFrontendCallbackUrl(env, {
      accessToken: input.accessToken,
      refreshToken: input.refreshToken,
    });
  }

  return getProfileRedirectUrl(env, {
    oauthLinked: input.provider,
  });
};

export const getOAuthErrorRedirectUrl = (env: EnvBindings, code: string): string =>
  getFrontendCallbackUrl(env, { error: code });
