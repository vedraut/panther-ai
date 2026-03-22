#!/bin/bash
# =============================================
# Panther AI — Database Schema + Seed Script
# Run after fresh DB or to re-seed
# Usage: bash seed-db.sh
# =============================================
set -e

DB_CONTAINER="findata_db"
DB_NAME="${DB_NAME:-finai_data}"
DB_USER="${DB_USER:-finai}"

echo "=== Panther AI DB Seed ==="

exec_sql() {
  docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "$1"
}

exec_sql_file() {
  docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" < "$1"
}

echo "Creating schema..."

docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" << 'EOSQL'

-- ── users_rbac ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users_rbac (
  user_id       SERIAL PRIMARY KEY,
  username      VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(100),
  email         VARCHAR(100),
  role          VARCHAR(50),
  department    VARCHAR(100),
  table_access  TEXT[] DEFAULT '{}',
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMP DEFAULT NOW()
);

-- ── portfolios ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS portfolios (
  portfolio_id    SERIAL PRIMARY KEY,
  portfolio_name  VARCHAR(100) NOT NULL,
  portfolio_type  VARCHAR(50),
  base_currency   VARCHAR(10) DEFAULT 'USD',
  inception_date  DATE,
  benchmark       VARCHAR(100),
  manager_name    VARCHAR(100),
  target_return   DECIMAL(8,4),
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMP DEFAULT NOW()
);

-- ── holdings ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS holdings (
  holding_id      SERIAL PRIMARY KEY,
  portfolio_id    INTEGER REFERENCES portfolios(portfolio_id),
  ticker          VARCHAR(20) NOT NULL,
  company_name    VARCHAR(200),
  sector          VARCHAR(100),
  industry        VARCHAR(100),
  asset_class     VARCHAR(50),
  country         VARCHAR(50),
  currency        VARCHAR(10),
  quantity        DECIMAL(18,4),
  avg_cost        DECIMAL(18,4),
  current_price   DECIMAL(18,4),
  market_value    DECIMAL(18,2),
  cost_basis      DECIMAL(18,4),
  unrealized_pnl  DECIMAL(18,2),
  realized_pnl    DECIMAL(18,2),
  weight_pct      DECIMAL(8,4),
  beta            DECIMAL(8,4),
  pe_ratio        DECIMAL(10,2),
  dividend_yield  DECIMAL(8,4),
  market_cap_b    DECIMAL(18,2),
  52w_high        DECIMAL(18,4),
  52w_low         DECIMAL(18,4),
  analyst_rating  VARCHAR(20),
  last_updated    TIMESTAMP DEFAULT NOW()
);

-- ── esg_scores ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS esg_scores (
  esg_id              SERIAL PRIMARY KEY,
  ticker              VARCHAR(20) NOT NULL,
  company_name        VARCHAR(200),
  esg_total_score     DECIMAL(6,2),
  environmental_score DECIMAL(6,2),
  social_score        DECIMAL(6,2),
  governance_score    DECIMAL(6,2),
  esg_rating          VARCHAR(10),
  carbon_intensity    DECIMAL(10,2),
  water_usage_score   DECIMAL(6,2),
  board_diversity_pct DECIMAL(6,2),
  controversy_level   VARCHAR(20),
  last_review_date    DATE,
  data_provider       VARCHAR(50),
  notes               TEXT
);

-- ── catalysts ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS catalysts (
  catalyst_id     SERIAL PRIMARY KEY,
  ticker          VARCHAR(20),
  company_name    VARCHAR(200),
  catalyst_type   VARCHAR(50),
  event_date      DATE,
  title           VARCHAR(300),
  description     TEXT,
  expected_impact VARCHAR(20),
  confidence_pct  DECIMAL(5,2),
  source          VARCHAR(100),
  is_confirmed    BOOLEAN DEFAULT false,
  created_at      TIMESTAMP DEFAULT NOW()
);

-- ── transactions ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
  transaction_id  SERIAL PRIMARY KEY,
  portfolio_id    INTEGER REFERENCES portfolios(portfolio_id),
  ticker          VARCHAR(20),
  company_name    VARCHAR(200),
  trade_type      VARCHAR(20),
  quantity        DECIMAL(18,4),
  price           DECIMAL(18,4),
  total_value     DECIMAL(18,2),
  commission      DECIMAL(10,2),
  trade_date      DATE,
  settlement_date DATE,
  currency        VARCHAR(10),
  broker          VARCHAR(100),
  notes           TEXT
);

EOSQL

echo "Schema created."

# Seed demo users
docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" << 'EOSQL'

INSERT INTO users_rbac (username, password_hash, full_name, email, role, department, table_access) VALUES
  ('admin',       'admin123',     'System Admin',        'admin@ved-raut.tech',       'Admin',         'IT',                    ARRAY['holdings','portfolios','esg_scores','catalysts','transactions','users_rbac']),
  ('jsmith',      'demo123',      'James Smith',         'j.smith@ved-raut.tech',     'Portfolio Mgr', 'Portfolio Management',  ARRAY['holdings','portfolios','transactions']),
  ('alee',        'demo123',      'Alice Lee',           'a.lee@ved-raut.tech',       'Analyst',       'Research',              ARRAY['holdings','esg_scores','catalysts']),
  ('mchen',       'demo123',      'Michael Chen',        'm.chen@ved-raut.tech',      'Risk Analyst',  'Risk Management',       ARRAY['holdings','portfolios']),
  ('esg_viewer',  'demo123',      'ESG Team User',       'esg@ved-raut.tech',         'ESG Analyst',   'Sustainability',        ARRAY['esg_scores','holdings']),
  ('trader1',     'demo123',      'David Park',          'd.park@ved-raut.tech',      'Trader',        'Trading',               ARRAY['holdings','transactions']),
  ('compliance',  'demo123',      'Sarah Johnson',       's.johnson@ved-raut.tech',   'Compliance',    'Compliance',            ARRAY['holdings','transactions','portfolios']),
  ('readonly',    'demo123',      'Read Only User',      'readonly@ved-raut.tech',    'Viewer',        'Operations',            ARRAY['holdings']),
  ('cfo',         'demo123',      'Robert Williams',     'r.williams@ved-raut.tech',  'CFO',           'Finance',               ARRAY['holdings','portfolios','transactions','esg_scores']),
  ('research',    'demo123',      'Emma Davis',          'e.davis@ved-raut.tech',     'Researcher',    'Research',              ARRAY['holdings','esg_scores','catalysts']),
  ('ops',         'demo123',      'Tom Wilson',          't.wilson@ved-raut.tech',    'Operations',    'Operations',            ARRAY['holdings']),
  ('restricted',  'demo123',      'Restricted User',     'restricted@ved-raut.tech',  'Intern',        'Operations',            ARRAY[])
ON CONFLICT (username) DO NOTHING;

EOSQL

echo "Users seeded."
echo ""
echo "=== DB seed complete ==="
echo "Run the full data seed separately if needed (holdings, ESG, catalysts, transactions)."
