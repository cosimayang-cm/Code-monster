# Monster8 Sports Bingo

Monster8 是延續 Monster #7 Cloudflare 架構模式的新專案，包含：

- `api/`: Cloudflare Worker + Hono + D1 + KV + Cron Trigger
- `web-app/`: React + Vite 前端

## 目標

- 公開 SportsGameOdds 資料頁
- 訪客 / 會員皆可使用的 Bingo Bingo 試玩系統
- 訪客以 guest session 辨識，登入後不合併舊試玩紀錄
- 所有 Cloudflare 資源以 `wrangler` CLI 建立與部署

## 快速開始

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo
npm install
```

### API

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/api
cp .dev.vars.example .dev.vars
npm run dev
```

### Web App

```bash
cd /Users/a01-0225-0624/CodeMonster/monster8-sports-bingo/web-app
cp .env.example .env.local
npm run dev
```

## 重點規則

- Sports Data 對訪客公開
- Bingo 訪客首次即有 10,000 試玩金
- 模擬儲值只接受整數，且無上限
- 開獎前 1 秒截止投注
- 超級獎號 bonus 預設為獎金乘以 2 倍
