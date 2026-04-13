CREATE TABLE IF NOT EXISTS draw_rounds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  round_id TEXT NOT NULL UNIQUE,
  draw_time TEXT NOT NULL,
  numbers TEXT,
  super_number INTEGER,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_draw_rounds_draw_time
ON draw_rounds(draw_time);

CREATE TABLE IF NOT EXISTS user_wallets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_type TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  balance INTEGER NOT NULL DEFAULT 0,
  trial_credit_awarded INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(owner_type, owner_id)
);

CREATE TABLE IF NOT EXISTS wallet_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_type TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  type TEXT NOT NULL,
  amount INTEGER NOT NULL,
  reference_id TEXT,
  description TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_owner
ON wallet_transactions(owner_type, owner_id, created_at DESC);

CREATE TABLE IF NOT EXISTS bets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_type TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  round_id TEXT NOT NULL,
  bet_type TEXT NOT NULL,
  selected_numbers TEXT,
  selected_option TEXT,
  amount INTEGER NOT NULL DEFAULT 25,
  status TEXT NOT NULL DEFAULT 'pending',
  matched_count INTEGER,
  multiplier REAL,
  payout INTEGER NOT NULL DEFAULT 0,
  has_super_number INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bets_owner
ON bets(owner_type, owner_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_bets_round
ON bets(round_id, status);
