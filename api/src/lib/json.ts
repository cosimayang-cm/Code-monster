export function ok<T>(data: T, init?: ResponseInit): Response {
  return json({ ok: true, data }, init);
}

export function fail(code: string, message: string, status = 400, details?: unknown): Response {
  return json({ ok: false, error: { code, message, details } }, { status });
}

export function json(payload: unknown, init?: ResponseInit): Response {
  const headers = new Headers(init?.headers);
  headers.set("content-type", "application/json; charset=utf-8");
  return new Response(JSON.stringify(payload, null, 2), { ...init, headers });
}
