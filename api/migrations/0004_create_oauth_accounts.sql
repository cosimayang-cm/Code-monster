CREATE TABLE IF NOT EXISTS oauth_accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  provider_id TEXT NOT NULL,
  provider_email TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(provider, provider_id)
);

CREATE INDEX IF NOT EXISTS idx_oauth_user_id ON oauth_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_oauth_provider_id ON oauth_accounts(provider, provider_id);
