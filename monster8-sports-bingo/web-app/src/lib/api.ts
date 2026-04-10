const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8787";

export async function apiRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers ?? {})
    },
    ...init
  });

  const payload = (await response.json()) as {
    ok: boolean;
    data?: T;
    error?: { message?: string };
  };

  if (!response.ok || !payload.ok || !payload.data) {
    throw new Error(payload.error?.message ?? `Request failed: ${response.status}`);
  }

  return payload.data;
}

export { API_BASE_URL };
