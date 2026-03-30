# OAuth Setup Guide

## Current Public URLs

- Staging web: `https://main.monster7-member-dfm.pages.dev`
- Staging API: `https://monster7-member-api.cosima-monster7.workers.dev`
- Production web: `https://monster7-member-dfm.pages.dev`
- Production API: `https://monster7-member-api-production.cosima-monster7.workers.dev`

## Callback URLs

Use the API URLs below in the provider console. Do not use `/auth/callback` from the frontend in Google or GitHub settings.

### Google

Recommended: create 2 separate Web application OAuth clients.

- Staging redirect URI:
  `https://monster7-member-api.cosima-monster7.workers.dev/api/auth/oauth/google/callback`
- Production redirect URI:
  `https://monster7-member-api-production.cosima-monster7.workers.dev/api/auth/oauth/google/callback`

You can also use one Google OAuth client if you register both redirect URIs on the same client, but separate clients are easier to manage.

Suggested app URLs:

- Staging homepage: `https://main.monster7-member-dfm.pages.dev`
- Production homepage: `https://monster7-member-dfm.pages.dev`

Scopes used by this project:

- `openid`
- `profile`
- `email`

### GitHub

This project currently uses GitHub OAuth Apps.

GitHub OAuth Apps only support one callback URL per app, so create 2 apps:

- Staging callback URL:
  `https://monster7-member-api.cosima-monster7.workers.dev/api/auth/oauth/github/callback`
- Production callback URL:
  `https://monster7-member-api-production.cosima-monster7.workers.dev/api/auth/oauth/github/callback`

Suggested app URLs:

- Staging homepage: `https://main.monster7-member-dfm.pages.dev`
- Production homepage: `https://monster7-member-dfm.pages.dev`

Scopes used by this project:

- `read:user`
- `user:email`

## Wrangler Secrets

After you create the provider apps, set the secrets in Cloudflare Workers:

```bash
cd /Users/a01-0225-0624/CodeMonster/monster7-member/api

printf '%s' 'YOUR_STAGING_GOOGLE_CLIENT_ID' | npx wrangler secret put GOOGLE_CLIENT_ID
printf '%s' 'YOUR_STAGING_GOOGLE_CLIENT_SECRET' | npx wrangler secret put GOOGLE_CLIENT_SECRET
printf '%s' 'YOUR_STAGING_GITHUB_CLIENT_ID' | npx wrangler secret put GITHUB_CLIENT_ID
printf '%s' 'YOUR_STAGING_GITHUB_CLIENT_SECRET' | npx wrangler secret put GITHUB_CLIENT_SECRET

printf '%s' 'YOUR_PRODUCTION_GOOGLE_CLIENT_ID' | npx wrangler secret put GOOGLE_CLIENT_ID -e production
printf '%s' 'YOUR_PRODUCTION_GOOGLE_CLIENT_SECRET' | npx wrangler secret put GOOGLE_CLIENT_SECRET -e production
printf '%s' 'YOUR_PRODUCTION_GITHUB_CLIENT_ID' | npx wrangler secret put GITHUB_CLIENT_ID -e production
printf '%s' 'YOUR_PRODUCTION_GITHUB_CLIENT_SECRET' | npx wrangler secret put GITHUB_CLIENT_SECRET -e production
```

Then redeploy both environments:

```bash
cd /Users/a01-0225-0624/CodeMonster/monster7-member/api
npm run deploy:staging
npm run deploy:production
```

## Verification

1. Open the staging login page.
2. Click `使用 Google 登入`.
3. Confirm you are redirected to Google and then back to:
   `https://main.monster7-member-dfm.pages.dev/auth/callback`
4. Repeat for GitHub.
5. Repeat the same flow on production.
