const ITERATIONS = 100_000;
const SALT_BYTES = 16;
const HASH_LENGTH = 32;

const toBase64Url = (buffer: ArrayBuffer): string =>
  btoa(String.fromCharCode(...new Uint8Array(buffer)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");

const fromBase64Url = (value: string): Uint8Array => {
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");
  const raw = atob(padded);
  return Uint8Array.from(raw, (char) => char.charCodeAt(0));
};

const deriveKey = async (password: string, salt: Uint8Array, iterations: number): Promise<ArrayBuffer> => {
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(password),
    "PBKDF2",
    false,
    ["deriveBits"]
  );

  return crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      hash: "SHA-256",
      iterations,
      salt: salt as BufferSource
    },
    keyMaterial,
    HASH_LENGTH * 8
  );
};

export const hashPassword = async (password: string): Promise<string> => {
  const salt = new Uint8Array(SALT_BYTES);
  crypto.getRandomValues(salt);
  const hash = await deriveKey(password, salt, ITERATIONS);

  return ["pbkdf2_sha256", String(ITERATIONS), toBase64Url(salt.buffer), toBase64Url(hash)].join("$");
};

export const verifyPassword = async (password: string, storedHash: string): Promise<boolean> => {
  const [algorithm, iterationsValue, saltValue, expectedHash] = storedHash.split("$");

  if (algorithm !== "pbkdf2_sha256" || !iterationsValue || !saltValue || !expectedHash) {
    return false;
  }

  const iterations = Number(iterationsValue);
  if (!Number.isFinite(iterations) || iterations <= 0) {
    return false;
  }

  const derived = await deriveKey(password, fromBase64Url(saltValue), iterations);
  return toBase64Url(derived) === expectedHash;
};
