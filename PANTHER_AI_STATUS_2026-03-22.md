# Panther AI - Project Status

**Date:** March 22, 2026
**Project:** Panther AI Financial Bot
**Status:** In Progress

---

## GitHub Repository

**URL:** https://github.com/vedraut/panther-ai
**Branch:** main
**Commits:** ~8 commits

---

## VPS State (187.77.191.46)

| Container | Status | Port |
|-----------|--------|------|
| panther-api | Running (healthy) | 127.0.0.1:3001 |
| panther-frontend | Running (healthy) | 127.0.0.1:8081 |
| n8n | Running | 127.0.0.1:5678 |
| findata_db | Running (healthy) | 5432 internal |
| laracorp_api | Running | 5000 |

---

## Compose Command (on VPS)

```bash
cd /opt/panther-ai
docker compose -f deploy/docker-compose.yml --env-file deploy/.env up --build -d
```

> Note: The status file previously referenced `docker-compose.vps.yml` — the actual file is `docker-compose.yml`. No VPS-specific compose file exists.

---

## Caddy Routes (already added)

- **panther.ved-raut.tech** → localhost:8081 (frontend)
- **api.ved-raut.tech** → localhost:3001 (API) + /webhook/* → N8N

---

## Credentials

| Service | Username | Password | Port |
|---------|----------|----------|------|
| Main App | admin | admin123 | - |
| Alternative Users | jsmith, alee, mchen, trader1, etc. | demo123 | - |
| N8N | admin@ved-raut.tech | Panther2026Demo! | 5678 |

**N8N URL:** http://187.77.191.46:5678

---

## What's Working

- [x] Login + JWT auth
- [x] KPI endpoint (returns live $3B AUM data)
- [x] Sectors endpoint
- [x] Holdings endpoint (206 rows)
- [x] Frontend serving (HTTP 200)
- [x] N8N workflow JSON created (`deploy/n8n-workflow-panther-chat.json`)
- [x] Transactions top-up script created (`deploy/scripts/seed-transactions-topup.sh`) — 70+ rows ready

---

## What's NOT Done Yet

1. **Import N8N workflow on VPS** — file is ready locally at `deploy/n8n-workflow-panther-chat.json`, needs to be pushed to GitHub then pulled on VPS and imported
2. **Activate N8N workflow** — after import, toggle active via UI or API
3. **Transactions top-up** — run `bash deploy/scripts/seed-transactions-topup.sh` on VPS after git pull
4. **DNS/Caddy verification** — confirm `panther.ved-raut.tech` resolves to `187.77.191.46` and HTTPS works
5. **End-to-end chat test** — blocked on #1 and #2
6. **GitHub Actions** — secrets (VPS_HOST, VPS_USER, VPS_PASSWORD) already set; deploy workflow is ready

---

## How to Resume After Restart

### Step 1 — Push local changes to GitHub
```bash
cd C:\LaraCorp\PantherAI_Financial_Bot
git add deploy/n8n-workflow-panther-chat.json deploy/scripts/seed-transactions-topup.sh PANTHER_AI_STATUS_2026-03-22.md
git commit -m "Add N8N workflow JSON and transactions top-up script"
git push origin main
```

### Step 2 — SSH into VPS and pull
```bash
ssh root@187.77.191.46
cd /opt/panther-ai && git pull origin main
```

### Step 3 — Run transactions top-up
```bash
bash deploy/scripts/seed-transactions-topup.sh
```

### Step 4 — Import N8N workflow
```bash
# Via API:
curl -X POST http://localhost:5678/rest/workflows \
  -H "Content-Type: application/json" \
  -u "admin@ved-raut.tech:Panther2026Demo!" \
  -d @/opt/panther-ai/deploy/n8n-workflow-panther-chat.json

# Then activate (replace <ID> with returned workflow ID):
curl -X PATCH http://localhost:5678/rest/workflows/<ID> \
  -H "Content-Type: application/json" \
  -u "admin@ved-raut.tech:Panther2026Demo!" \
  -d '{"active": true}'

# OR: Go to http://187.77.191.46:5678 and activate via UI
```

### Step 5 — Test chat end-to-end
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{"message": "What is our total AUM?"}'
```

### Step 6 — Verify DNS + Caddy
```bash
dig panther.ved-raut.tech +short
curl -I https://panther.ved-raut.tech
curl -I https://api.ved-raut.tech/health
```

---

## N8N Workflow Details

**File:** `deploy/n8n-workflow-panther-chat.json`
**Webhook path:** `POST /webhook/panther/chat`
**Flow:** Webhook → Build Prompt (Code) → Call Moonshot API (HTTP Request) → Extract Reply (Code) → Respond to Webhook
**Model:** `moonshot-v1-8k` via `https://api.moonshot.cn/v1/chat/completions`
**API Key env var:** `MOONSHOT_API_KEY` (already in deploy/.env on VPS)
**Expected response shape:** `{ "reply": "..." }`

---

## Local Dev Folder

```
C:\LaraCorp\PantherAI_Financial_Bot
```
