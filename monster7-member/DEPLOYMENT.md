# Deployment Guide

## Target Environments

This project uses two public environments:

- `staging`: smoke test / acceptance environment
- `production`: public release environment

Recommended public URLs:

- Staging web: `https://main.<pages-project>.pages.dev`
- Staging API: `https://monster7-member-api.<workers-subdomain>.workers.dev`
- Production web: `https://monster7-member.pages.dev`
- Production API: `https://monster7-member-api-production.<workers-subdomain>.workers.dev`

## Current Branch Strategy

- `main` branch: staging
- `staging` branch: production

For Pages, set the production branch to `staging`. The `main` branch will then stay on the preview/staging URL.

## Prerequisites

1. Install Node.js 20
2. Login to Cloudflare:

```bash
cd api
npx wrangler login
```

3. Prepare Worker secrets for both environments:

```bash
cd api
npx wrangler secret put JWT_SECRET
npx wrangler secret put GOOGLE_CLIENT_ID
npx wrangler secret put GOOGLE_CLIENT_SECRET
npx wrangler secret put GITHUB_CLIENT_ID
npx wrangler secret put GITHUB_CLIENT_SECRET

npx wrangler secret put JWT_SECRET --env production
npx wrangler secret put GOOGLE_CLIENT_ID --env production
npx wrangler secret put GOOGLE_CLIENT_SECRET --env production
npx wrangler secret put GITHUB_CLIENT_ID --env production
npx wrangler secret put GITHUB_CLIENT_SECRET --env production
```

## Worker Deployment

Wrangler 4.45+ can auto-provision D1 / KV / R2 bindings from `wrangler.toml`, so the repo does not need committed resource IDs.

Deploy staging:

```bash
cd api
npm ci
npm run deploy:staging
npm run db:migrate:staging
export ADMIN_SEED_PASSWORD='your-staging-admin-password'
npm run seed:staging
```

Deploy production:

```bash
cd api
npm ci
npm run deploy:production
npm run db:migrate:production
export ADMIN_SEED_PASSWORD='your-production-admin-password'
npm run seed:production
```

## Pages Deployment

Create a Pages project with:

- Root directory: `monster7-member/web-app`
- Build command: `npm ci && npm run build:pages`
- Build output directory: `dist`
- Production branch: `staging`

The branch-aware build script behaves like this:

- `CF_PAGES_BRANCH=main` -> `npm run build:staging`
- `CF_PAGES_BRANCH=staging` -> `npm run build:production`

## Frontend Environment Values

Update these tracked non-secret files before the first real deployment:

- `web-app/.env.staging`
- `web-app/.env.production`

Set `VITE_API_BASE_URL` to the actual Worker URLs created in your account.

## Verification Checklist

After staging deploy:

1. Open the staging web URL
2. Register a test user
3. Login and load `/profile`
4. Verify forgot-password returns a staging reset link
5. Login as seeded admin and verify `/admin/dashboard`
6. Confirm staging data is isolated from production
