export type UserRole = "user" | "admin";
export type TokenType = "access" | "refresh";
export type OAuthProvider = "google" | "github";
export type LoginMethod = "email" | OAuthProvider;
export type EnvironmentName = "local" | "staging" | "production";

export interface EnvBindings {
  DB: D1Database;
  BUCKET?: R2Bucket;
  KV: KVNamespace;
  JWT_SECRET: string;
  APP_URL: string;
  API_URL: string;
  R2_PUBLIC_URL?: string;
  ALLOWED_ORIGINS?: string;
  ENVIRONMENT?: EnvironmentName;
  GOOGLE_CLIENT_ID?: string;
  GOOGLE_CLIENT_SECRET?: string;
  GITHUB_CLIENT_ID?: string;
  GITHUB_CLIENT_SECRET?: string;
}

export interface AuthState {
  userId: string;
  email: string;
  role: UserRole;
}

export interface AppVariables {
  auth: AuthState;
}

export interface AppEnv {
  Bindings: EnvBindings;
  Variables: AppVariables;
}

export interface JwtClaims {
  sub: string;
  email: string;
  role: UserRole;
  type: TokenType;
  iat: number;
  exp: number;
}

export interface UserRecord {
  id: string;
  email: string;
  password_hash: string | null;
  name: string | null;
  bio: string | null;
  avatar_url: string | null;
  role: UserRole;
  is_active: number | boolean;
  created_at: string;
  updated_at: string;
}

export interface PublicUser {
  id: string;
  email: string;
  name: string | null;
  bio: string | null;
  avatar_url: string | null;
  role: UserRole;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface OAuthAccountRecord {
  id: string;
  user_id: string;
  provider: OAuthProvider;
  provider_id: string;
  provider_email: string | null;
  created_at: string;
}

export interface LoginHistoryRecord {
  id: string;
  user_id: string;
  method: LoginMethod;
  ip_address: string;
  user_agent: string;
  created_at: string;
}

export interface PaginationInput {
  page: number;
  pageSize: number;
  offset: number;
}

export interface PaginationMeta {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}
