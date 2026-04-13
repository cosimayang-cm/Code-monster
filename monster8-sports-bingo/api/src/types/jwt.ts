import type { TokenType, UserRole } from "./env";

export interface JwtClaims {
  sub: string;
  email: string;
  role: UserRole;
  type: TokenType;
  iat: number;
  exp: number;
}

export type { TokenType, UserRole } from "./env";
