#!/bin/bash
# =============================================
# Panther AI — Initial VPS Setup Script
# Run once on fresh VPS / clean rebuild
# Usage: bash setup-vps.sh
# =============================================
set -e

REPO_URL="https://github.com/vedraut/panther-ai.git"
REPO_DIR="/opt/panther-ai"
ENV_FILE="$REPO_DIR/deploy/.env"

echo "=== Panther AI VPS Setup ==="

# Stop and remove old panther containers
echo "Removing old panther containers..."
docker stop panther-frontend panther-api 2>/dev/null || true
docker rm panther-frontend panther-api 2>/dev/null || true
# Keep findata_db running if it has data, or remove if clean rebuild
# docker stop findata_db && docker rm findata_db 2>/dev/null || true

# Clone or update repo
if [ -d "$REPO_DIR/.git" ]; then
  echo "Repo exists, pulling..."
  cd "$REPO_DIR" && git pull origin main
else
  echo "Cloning repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Create .env from example if not exists
if [ ! -f "$ENV_FILE" ]; then
  cp "$REPO_DIR/deploy/.env.example" "$ENV_FILE"
  echo ""
  echo "=== ACTION REQUIRED ==="
  echo "Edit $ENV_FILE and set your actual values, then re-run:"
  echo "  bash $REPO_DIR/deploy/scripts/deploy.sh"
  echo "========================"
  exit 0
fi

# Create ssl dir (placeholder)
mkdir -p "$REPO_DIR/deploy/nginx/ssl"

# Build and start all services
cd "$REPO_DIR"
docker compose -f deploy/docker-compose.yml --env-file deploy/.env up --build -d

echo ""
echo "=== Setup complete ==="
echo "Frontend: http://panther.ved-raut.tech"
echo "API:      http://api.ved-raut.tech"
echo "N8N:      http://api.ved-raut.tech:5678"
echo ""
docker compose -f deploy/docker-compose.yml ps
