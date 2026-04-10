export type ActorType = "guest" | "user";

export interface Actor {
  type: ActorType;
  id: string;
}

export interface EnvBindings {
  DB: D1Database;
  SPORTS_CACHE: KVNamespace;
  SPORTSGAMEODDS_API_KEY?: string;
  SPORTS_API_BASE_URL?: string;
  WEB_APP_ORIGIN?: string;
  SUPER_NUMBER_MULTIPLIER?: string;
}

export interface AppVariables {
  actor?: Actor;
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
