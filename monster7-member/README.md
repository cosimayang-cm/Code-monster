# Monster7 Member

Cloudflare 全端會員系統實作，採 mono repo 結構：

- `web-app/`: React 18 + TypeScript + Tailwind CSS
- `api/`: Cloudflare Workers + Hono + D1/R2/KV

## Local Development

### Web App

```bash
cd web-app
npm install
npm run dev
```

### API

```bash
cd api
npm install
cp .dev.vars.example .dev.vars
# edit .dev.vars and set ADMIN_SEED_PASSWORD
npm run db:migrate:local
npm run seed:local
npm run dev
```

Local admin seed:

- email: `admin@monster7.dev`
- password: read from `api/.dev.vars` via `ADMIN_SEED_PASSWORD`

## Environment Files

- `web-app/.env.staging`: staging 非機密前端設定
- `web-app/.env.production`: production 非機密前端設定
- `web-app/.env.local`: 本機覆寫，不進 git
- `api/.dev.vars`: 本機 Worker secrets，不進 git
- `api/.wrangler/`: 本機 D1 / KV / R2 狀態與暫存，不進 git

## Deployment

- `main` branch: staging deployment
- `staging` branch: production deployment
