import { SignJWT, jwtVerify } from "jose";

import type { JwtClaims, TokenType, UserRole } from "../types/jwt";

const ACCESS_TOKEN_SECONDS = 60 * 15;
const REFRESH_TOKEN_SECONDS = 60 * 60 * 24 * 7;

const getSecretKey = (secret: string): Uint8Array => new TextEncoder().encode(secret);

const signToken = async (
  secret: string,
  payload: { sub: string; email: string; role: UserRole },
  type: TokenType,
  expiresInSeconds: number
): Promise<string> => {
  const issuedAt = Math.floor(Date.now() / 1000);

  return new SignJWT({
    email: payload.email,
    role: payload.role,
    type
  })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(payload.sub)
    .setIssuedAt(issuedAt)
    .setExpirationTime(issuedAt + expiresInSeconds)
    .sign(getSecretKey(secret));
};

export const signAccessToken = (
  secret: string,
  payload: { sub: string; email: string; role: UserRole }
): Promise<string> => signToken(secret, payload, "access", ACCESS_TOKEN_SECONDS);

export const signRefreshToken = (
  secret: string,
  payload: { sub: string; email: string; role: UserRole }
): Promise<string> => signToken(secret, payload, "refresh", REFRESH_TOKEN_SECONDS);

export const verifyToken = async (
  secret: string,
  token: string,
  expectedType: TokenType
): Promise<JwtClaims> => {
  const { payload } = await jwtVerify(token, getSecretKey(secret), {
    algorithms: ["HS256"]
  });

  if (payload.type !== expectedType) {
    throw new Error("Unexpected token type");
  }

  return {
    sub: String(payload.sub),
    email: String(payload.email),
    role: payload.role as UserRole,
    type: payload.type as TokenType,
    iat: Number(payload.iat),
    exp: Number(payload.exp)
  };
};
