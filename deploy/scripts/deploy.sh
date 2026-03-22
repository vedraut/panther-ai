#!/bin/bash
# =============================================
# Panther AI — VPS Deployment Script
# Usage: bash deploy.sh [--clean]
# =============================================
set -e

REPO_DIR="/opt/panther-ai"
COMPOSE_FILE="$REPO_DIR/deploy/docker-compose.yml"
ENV_FILE="$REPO_DIR/deploy/.env"

echo "=== Panther AI Deploy ==="
echo "Time: $(date)"

# Pull latest code
cd "$REPO_DIR"
git pull origin main
echo "Code updated."

# Verify .env exists
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found. Copy deploy/.env.example to deploy/.env and configure it."
  exit 1
fi

# Clean rebuild if flag passed
if [ "$1" == "--clean" ]; then
  echo "Clean rebuild: stopping and removing old containers..."
  docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down --remove-orphans
fi

# Build and start
echo "Building and starting services..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up --build -d

# Wait for health
echo "Waiting for services to be healthy..."
sleep 15

# Health checks
check() {
  local name=$1
  local url=$2
  if curl -sf "$url" > /dev/null 2>&1; then
    echo "  [OK] $name"
  else
    echo "  [FAIL] $name — $url"
  fi
}

check "panther-api" "http://localhost:3001/health"
check "panther-frontend" "http://panther.ved-raut.tech"
check "api backend" "http://api.ved-raut.tech/health"

echo "=== Deploy complete ==="
docker compose -f "$COMPOSE_FILE" ps
