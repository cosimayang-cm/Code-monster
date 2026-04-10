# Monster8 Deployment Guide

所有 Cloudflare 資源以 `wrangler` CLI 建立與管理。

## 1. 建立 D1

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/api

npx wrangler d1 create monster8-db-staging
npx wrangler d1 create monster8-db-production
```

把回傳的 `database_id` 填回 [wrangler.toml](/Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/api/wrangler.toml)。

## 2. 建立 KV

```bash
npx wrangler kv namespace create SPORTS_CACHE
npx wrangler kv namespace create SPORTS_CACHE --env production
```

把回傳的 namespace id 填回 [wrangler.toml](/Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/api/wrangler.toml)。

## 3. 設定 secrets

```bash
npx wrangler secret put SPORTSGAMEODDS_API_KEY
npx wrangler secret put SPORTSGAMEODDS_API_KEY --env production
```

## 4. 套 migration

```bash
npm run db:migrate:local
npm run db:migrate:remote
npx wrangler d1 migrations apply DB --env production --remote
```

## 5. 部署 API

```bash
npm run deploy
npx wrangler deploy --env production
```

## 6. 建置前端

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/web-app
cp .env.example .env.local
npm run build
```

若要串 Cloudflare Pages，可將 `VITE_API_BASE_URL` 分別設成 staging / production Worker URL。

## 7. 本地 smoke test

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/api
cp .dev.vars.example .dev.vars
npm run dev
```

另開終端機：

```bash
curl http://localhost:8787/health
curl http://localhost:8787/api/bingo/current
curl -c /tmp/m8.cookies http://localhost:8787/api/wallet/balance
```
