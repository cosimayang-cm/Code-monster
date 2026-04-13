const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8787";
const GUEST_STORAGE_KEY = "monster8.guest-actor-id";
const AUTH_STORAGE_KEY = "monster8.auth-tokens";

export type Actor = {
  type: "guest" | "user";
  id: string;
};

export type AuthProvider = "google" | "github";

export type AuthTokens = {
  accessToken: string;
  refreshToken: string;
};

export type AuthUser = {
  id: string;
  email: string;
  name: string | null;
  role: "user" | "admin";
  is_active: boolean;
  created_at: string;
  updated_at: string;
};

type GuestActorPayload = {
  actor?: {
    type?: string;
    id?: string;
  };
};

type ApiEnvelope<T> = {
  ok: boolean;
  data?: T;
  error?: {
    code?: string;
    message?: string;
    details?: unknown;
  };
};

type AuthResponse = {
  user: AuthUser;
  accessToken: string;
  refreshToken: string;
};

type AuthProviderResponse = {
  providers: Record<AuthProvider, boolean>;
};

let refreshPromise: Promise<string | null> | null = null;

function readGuestActorId(): string | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    return window.localStorage.getItem(GUEST_STORAGE_KEY);
  } catch {
    return null;
  }
}

function persistGuestActorId(payload: unknown): void {
  if (typeof window === "undefined" || !payload || typeof payload !== "object") {
    return;
  }

  const candidate = payload as GuestActorPayload;
  const actor = candidate.actor;
  if (!actor || actor.type !== "guest" || typeof actor.id !== "string" || actor.id.length === 0) {
    return;
  }

  try {
    window.localStorage.setItem(GUEST_STORAGE_KEY, actor.id);
  } catch {
    // Ignore local storage persistence issues and continue using response data.
  }
}

function readAuthTokens(): AuthTokens | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    const raw = window.localStorage.getItem(AUTH_STORAGE_KEY);
    if (!raw) {
      return null;
    }

    return JSON.parse(raw) as AuthTokens;
  } catch {
    window.localStorage.removeItem(AUTH_STORAGE_KEY);
    return null;
  }
}

function persistAuthTokens(tokens: AuthTokens | null): void {
  if (typeof window === "undefined") {
    return;
  }

  if (!tokens) {
    window.localStorage.removeItem(AUTH_STORAGE_KEY);
    return;
  }

  window.localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(tokens));
}

function clearGuestActorId(): void {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(GUEST_STORAGE_KEY);
}

function getAuthTokens(): AuthTokens | null {
  return readAuthTokens();
}

async function doRefreshAccessToken(): Promise<string | null> {
  const tokens = getAuthTokens();
  if (!tokens?.refreshToken) {
    return null;
  }

  const response = await fetch(`${API_BASE_URL}/api/auth/refresh`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken: tokens.refreshToken })
  });

  const payload = (await response.json().catch(() => null)) as ApiEnvelope<{ accessToken: string }> | null;

  if (!response.ok || !payload?.data?.accessToken) {
    persistAuthTokens(null);
    return null;
  }

  persistAuthTokens({
    accessToken: payload.data.accessToken,
    refreshToken: tokens.refreshToken
  });

  return payload.data.accessToken;
}

async function refreshAccessToken(): Promise<string | null> {
  if (!refreshPromise) {
    refreshPromise = doRefreshAccessToken().finally(() => {
      refreshPromise = null;
    });
  }

  return refreshPromise;
}

async function rawRequest<T>(path: string, init?: RequestInit, retryOn401 = true): Promise<T> {
  const guestActorId = readGuestActorId();
  const authTokens = getAuthTokens();
  const headers = new Headers(init?.headers);
  headers.set("Content-Type", "application/json");

  if (guestActorId) {
    headers.set("x-guest-id", guestActorId);
  }

  if (authTokens?.accessToken) {
    headers.set("Authorization", `Bearer ${authTokens.accessToken}`);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    credentials: "include",
    ...init,
    headers
  });

  let payload = (await response.json().catch(() => null)) as ApiEnvelope<T> | null;

  if (response.status === 401 && authTokens?.refreshToken && retryOn401) {
    const nextAccessToken = await refreshAccessToken();
    if (nextAccessToken) {
      headers.set("Authorization", `Bearer ${nextAccessToken}`);
      const retryResponse = await fetch(`${API_BASE_URL}${path}`, {
        credentials: "include",
        ...init,
        headers
      });
      payload = (await retryResponse.json().catch(() => null)) as ApiEnvelope<T> | null;

      if (!retryResponse.ok || !payload?.ok || !payload.data) {
        throw new Error(payload?.error?.message ?? `Request failed: ${retryResponse.status}`);
      }

      persistGuestActorId(payload.data);
      return payload.data;
    }
  }

  if (!response.ok || !payload?.ok || !payload.data) {
    throw new Error(payload?.error?.message ?? `Request failed: ${response.status}`);
  }

  persistGuestActorId(payload.data);
  return payload.data;
}

export async function apiRequest<T>(path: string, init?: RequestInit): Promise<T> {
  return rawRequest<T>(path, init);
}

export async function login(input: { email: string; password: string }): Promise<AuthUser> {
  const session = await rawRequest<AuthResponse>("/api/auth/login", {
    method: "POST",
    body: JSON.stringify(input)
  });
  persistAuthTokens({
    accessToken: session.accessToken,
    refreshToken: session.refreshToken
  });
  clearGuestActorId();
  return session.user;
}

export async function register(input: { email: string; password: string }): Promise<AuthUser> {
  const session = await rawRequest<AuthResponse>("/api/auth/register", {
    method: "POST",
    body: JSON.stringify(input)
  });
  persistAuthTokens({
    accessToken: session.accessToken,
    refreshToken: session.refreshToken
  });
  clearGuestActorId();
  return session.user;
}

export async function getCurrentUser(): Promise<AuthUser> {
  const result = await rawRequest<{ user: AuthUser }>("/api/users/me");
  return result.user;
}

export async function getOAuthProviders(): Promise<Record<AuthProvider, boolean>> {
  const result = await rawRequest<AuthProviderResponse>("/api/auth/providers");
  return result.providers;
}

export function getOAuthLoginUrl(provider: AuthProvider): string {
  return `${API_BASE_URL}/api/auth/oauth/${provider}`;
}

export function hasStoredAuthTokens(): boolean {
  const tokens = readAuthTokens();
  return Boolean(tokens?.accessToken && tokens.refreshToken);
}

export function clearAuthSession(): void {
  persistAuthTokens(null);
  clearGuestActorId();
}

export function completeOAuthLogin(tokens: AuthTokens): void {
  persistAuthTokens(tokens);
  clearGuestActorId();
}

export function consumeOAuthCallback(): { tokens: AuthTokens | null; error: string | null } {
  if (typeof window === "undefined") {
    return { tokens: null, error: null };
  }

  const url = new URL(window.location.href);
  const error = url.searchParams.get("auth_error");
  const accessToken = url.searchParams.get("accessToken");
  const refreshToken = url.searchParams.get("refreshToken");
  const handled = url.searchParams.has("auth_callback") || Boolean(error);

  if (handled) {
    url.searchParams.delete("auth_callback");
    url.searchParams.delete("auth_error");
    url.searchParams.delete("accessToken");
    url.searchParams.delete("refreshToken");
    window.history.replaceState({}, document.title, `${url.pathname}${url.search}${url.hash}`);
  }

  if (error) {
    return { tokens: null, error };
  }

  if (accessToken && refreshToken) {
    return {
      tokens: {
        accessToken,
        refreshToken
      },
      error: null
    };
  }

  return { tokens: null, error: null };
}

export { API_BASE_URL };
