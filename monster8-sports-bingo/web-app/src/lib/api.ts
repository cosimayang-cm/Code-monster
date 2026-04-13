const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8787";
const GUEST_STORAGE_KEY = "monster8.guest-actor-id";

type GuestActorPayload = {
  actor?: {
    type?: string;
    id?: string;
  };
};

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

export async function apiRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const guestActorId = readGuestActorId();
  const response = await fetch(`${API_BASE_URL}${path}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(guestActorId ? { "x-guest-id": guestActorId } : {}),
      ...(init?.headers ?? {})
    },
    ...init
  });

  const payload = (await response.json()) as {
    ok: boolean;
    data?: T;
    error?: { message?: string };
  };

  persistGuestActorId(payload.data);

  if (!response.ok || !payload.ok || !payload.data) {
    throw new Error(payload.error?.message ?? `Request failed: ${response.status}`);
  }

  return payload.data;
}

export { API_BASE_URL };
