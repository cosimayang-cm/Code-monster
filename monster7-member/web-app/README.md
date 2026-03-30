# Monster7 Member Web App

React 18 + TypeScript + Tailwind CSS frontend for the Monster7 member system.

## Commands

```bash
npm install
npm run dev
npm run build:staging
npm run build:production
```

## Cloudflare Pages

- Production branch: `staging`
- Preview / staging branch: `main`
- Build command: `npm ci && npm run build:pages`
- Output directory: `dist`

The branch-aware build script maps:

- `main` -> staging mode
- `staging` -> production mode
