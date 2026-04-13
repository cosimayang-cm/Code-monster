export type ActorType = "guest" | "user";
export type UserRole = "user" | "admin";
export type TokenType = "access" | "refresh";
export type OAuthProvider = "google" | "github";
export type LoginMethod = "email" | OAuthProvider;

export interface Actor {
  type: ActorType;
  id: string;
}

export interface AuthState {
  userId: string;
  email: string;
  role: UserRole;
}

export interface EnvBindings {
  DB: D1Database;
  SPORTS_CACHE: KVNamespace;
  SPORTSGAMEODDS_API_KEY?: string;
  SPORTS_API_BASE_URL?: string;
  WEB_APP_ORIGIN?: string;
  SUPER_NUMBER_MULTIPLIER?: string;
  JWT_SECRET?: string;
  APP_URL?: string;
  API_URL?: string;
  GOOGLE_CLIENT_ID?: string;
  GOOGLE_CLIENT_SECRET?: string;
  GITHUB_CLIENT_ID?: string;
  GITHUB_CLIENT_SECRET?: string;
}

export interface AppVariables {
  actor?: Actor;
  auth?: AuthState;
}

export interface WalletRow {
  id: number;
  owner_type: ActorType;
  owner_id: string;
  balance: number;
  trial_credit_awarded: number;
  created_at: string;
  updated_at: string;
}

export interface DrawRoundRow {
  id: number;
  round_id: string;
  draw_time: string;
  numbers: string | null;
  super_number: number | null;
  status: "pending" | "drawn" | "settled";
  created_at: string;
  updated_at: string;
}

export interface BetRow {
  id: number;
  owner_type: ActorType;
  owner_id: string;
  round_id: string;
  bet_type: string;
  selected_numbers: string | null;
  selected_option: string | null;
  amount: number;
  status: "pending" | "won" | "lost" | "refunded";
  matched_count: number | null;
  multiplier: number | null;
  payout: number;
  has_super_number: number;
  created_at: string;
}

export interface UserRow {
  id: string;
  email: string;
  password_hash: string | null;
  name: string | null;
  role: UserRole;
  is_active: number | boolean;
  created_at: string;
  updated_at: string;
}

export interface PublicUser {
  id: string;
  email: string;
  name: string | null;
  role: UserRole;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface OAuthAccountRow {
  id: string;
  user_id: string;
  provider: OAuthProvider;
  provider_id: string;
  provider_email: string | null;
  created_at: string;
}

export interface LoginHistoryRow {
  id: string;
  user_id: string;
  method: LoginMethod;
  ip_address: string;
  user_agent: string;
  created_at: string;
}
