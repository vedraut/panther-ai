#!/bin/bash
# =============================================
# Panther AI — Transactions Top-Up Seed
# Adds rows until transactions table has 300+
# Usage: bash seed-transactions-topup.sh
# Run from VPS: cd /opt/panther-ai && bash deploy/scripts/seed-transactions-topup.sh
# =============================================
set -e

DB_CONTAINER="findata_db"
DB_NAME="${DB_NAME:-finai_data}"
DB_USER="${DB_USER:-finai}"

# Portfolio UUIDs (from live DB)
P1='f9c06678-c065-4b4f-810a-b20f73ef08a5'  # Tech Innovation Fund
P2='d4400555-2eeb-417e-bb34-2e8ab2deb197'  # Stable Income Fund
P3='ad5edb09-6625-42ca-8dd4-b81db2bbfbd2'  # ESG Leaders Fund

echo "=== Panther AI — Transactions Top-Up ==="

CURRENT=$(docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM transactions;" | tr -d ' \n')
echo "Current transaction count: $CURRENT"

if [ "$CURRENT" -ge 300 ]; then
  echo "Already at 300+ transactions ($CURRENT rows). Nothing to do."
  exit 0
fi

echo "Inserting top-up transactions..."

docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" << EOSQL

INSERT INTO transactions (portfolio_id, ticker, company_name, txn_type, quantity, price, total_value, currency, trade_date, settlement_date, broker, fiscal_period, department_owner) VALUES

-- Portfolio 1 (Tech Innovation Fund) — Oct 2025
('$P1', 'AAPL',  'Apple Inc.',                   'BUY',  500,   182.50, 91250.00,  'USD', '2025-10-01', '2025-10-03', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'MSFT',  'Microsoft Corp.',              'BUY',  300,   415.20, 124560.00, 'USD', '2025-10-02', '2025-10-06', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P1', 'NVDA',  'NVIDIA Corp.',                 'BUY',  200,   498.75, 99750.00,  'USD', '2025-10-03', '2025-10-07', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),
('$P1', 'GOOGL', 'Alphabet Inc.',                'BUY',  150,   172.30, 25845.00,  'USD', '2025-10-06', '2025-10-08', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'META',  'Meta Platforms Inc.',          'BUY',  250,   558.10, 139525.00, 'USD', '2025-10-07', '2025-10-09', 'Barclays',       'Q4 2025', 'Portfolio Management'),
('$P1', 'AMZN',  'Amazon.com Inc.',              'BUY',  180,   198.40, 35712.00,  'USD', '2025-10-08', '2025-10-10', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P1', 'TSLA',  'Tesla Inc.',                   'SELL', 100,   265.80, 26580.00,  'USD', '2025-10-09', '2025-10-13', 'Morgan Stanley', 'Q4 2025', 'Trading'),
('$P1', 'CRM',   'Salesforce Inc.',              'BUY',  120,   322.50, 38700.00,  'USD', '2025-10-10', '2025-10-14', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'AMD',   'Advanced Micro Devices',       'BUY',  400,   168.20, 67280.00,  'USD', '2025-10-13', '2025-10-15', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),
('$P1', 'ADBE',  'Adobe Inc.',                   'SELL', 80,    580.30, 46424.00,  'USD', '2025-10-14', '2025-10-16', 'Barclays',       'Q4 2025', 'Trading'),
('$P1', 'NFLX',  'Netflix Inc.',                 'BUY',  90,    685.40, 61686.00,  'USD', '2025-10-15', '2025-10-17', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'ORCL',  'Oracle Corp.',                 'BUY',  220,   178.60, 39292.00,  'USD', '2025-10-16', '2025-10-20', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P1', 'NOW',   'ServiceNow Inc.',              'BUY',  60,    890.20, 53412.00,  'USD', '2025-10-17', '2025-10-21', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P1', 'PANW',  'Palo Alto Networks',           'BUY',  110,   388.75, 42762.50,  'USD', '2025-10-20', '2025-10-22', 'Barclays',       'Q4 2025', 'Portfolio Management'),
('$P1', 'SNOW',  'Snowflake Inc.',               'SELL', 150,   178.90, 26835.00,  'USD', '2025-10-21', '2025-10-23', 'Goldman Sachs',  'Q4 2025', 'Trading'),

-- Portfolio 2 (Stable Income Fund) — Oct 2025
('$P2', 'JPM',   'JPMorgan Chase & Co.',         'BUY',  400,   225.80, 90320.00,  'USD', '2025-10-01', '2025-10-03', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P2', 'BAC',   'Bank of America Corp.',        'BUY',  800,    42.30, 33840.00,  'USD', '2025-10-02', '2025-10-06', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P2', 'WFC',   'Wells Fargo & Co.',            'BUY',  600,    60.20, 36120.00,  'USD', '2025-10-03', '2025-10-07', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),
('$P2', 'GS',    'Goldman Sachs Group',          'BUY',  100,   548.30, 54830.00,  'USD', '2025-10-06', '2025-10-08', 'Barclays',       'Q4 2025', 'Portfolio Management'),
('$P2', 'BRK.B', 'Berkshire Hathaway B',         'BUY',  150,   444.10, 66615.00,  'USD', '2025-10-07', '2025-10-09', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P2', 'JNJ',   'Johnson & Johnson',            'BUY',  300,   155.40, 46620.00,  'USD', '2025-10-08', '2025-10-10', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P2', 'PFE',   'Pfizer Inc.',                  'BUY',  900,    27.80, 25020.00,  'USD', '2025-10-09', '2025-10-13', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P2', 'MRK',   'Merck & Co.',                  'BUY',  200,   118.60, 23720.00,  'USD', '2025-10-10', '2025-10-14', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),
('$P2', 'ABT',   'Abbott Laboratories',          'SELL', 180,   115.20, 20736.00,  'USD', '2025-10-13', '2025-10-15', 'Barclays',       'Q4 2025', 'Trading'),
('$P2', 'UNH',   'UnitedHealth Group',           'BUY',  80,    582.30, 46584.00,  'USD', '2025-10-14', '2025-10-16', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P2', 'CVX',   'Chevron Corp.',                'BUY',  250,   162.40, 40600.00,  'USD', '2025-10-15', '2025-10-17', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P2', 'XOM',   'Exxon Mobil Corp.',            'BUY',  300,   118.80, 35640.00,  'USD', '2025-10-16', '2025-10-20', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P2', 'COP',   'ConocoPhillips',               'SELL', 200,   128.50, 25700.00,  'USD', '2025-10-17', '2025-10-21', 'Barclays',       'Q4 2025', 'Trading'),
('$P2', 'LIN',   'Linde plc',                    'BUY',  100,   458.20, 45820.00,  'USD', '2025-10-20', '2025-10-22', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P2', 'CAT',   'Caterpillar Inc.',             'BUY',  120,   388.60, 46632.00,  'USD', '2025-10-21', '2025-10-23', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),

-- Portfolio 3 (ESG Leaders Fund) — Oct 2025
('$P3', 'TSLA',  'Tesla Inc.',                   'BUY',  300,   258.40, 77520.00,  'USD', '2025-10-01', '2025-10-03', 'Morgan Stanley', 'Q4 2025', 'Sustainability'),
('$P3', 'ENPH',  'Enphase Energy',               'BUY',  200,   108.30, 21660.00,  'USD', '2025-10-02', '2025-10-06', 'Goldman Sachs',  'Q4 2025', 'Sustainability'),
('$P3', 'NEE',   'NextEra Energy',               'BUY',  400,    78.20, 31280.00,  'USD', '2025-10-03', '2025-10-07', 'Citi',           'Q4 2025', 'Sustainability'),
('$P3', 'FSLR',  'First Solar Inc.',             'BUY',  150,   218.50, 32775.00,  'USD', '2025-10-06', '2025-10-08', 'Barclays',       'Q4 2025', 'Sustainability'),
('$P3', 'SEDG',  'SolarEdge Technologies',       'SELL', 100,    62.10,  6210.00,  'USD', '2025-10-07', '2025-10-09', 'Morgan Stanley', 'Q4 2025', 'Sustainability'),
('$P3', 'BE',    'Bloom Energy',                 'BUY',  500,    14.80,  7400.00,  'USD', '2025-10-08', '2025-10-10', 'Goldman Sachs',  'Q4 2025', 'Sustainability'),
('$P3', 'PLUG',  'Plug Power Inc.',              'BUY',  800,     3.20,  2560.00,  'USD', '2025-10-09', '2025-10-13', 'JPMorgan',       'Q4 2025', 'Sustainability'),
('$P3', 'RUN',   'Sunrun Inc.',                  'BUY',  600,    14.40,  8640.00,  'USD', '2025-10-10', '2025-10-14', 'Citi',           'Q4 2025', 'Sustainability'),
('$P3', 'CSIQ',  'Canadian Solar Inc.',          'BUY',  300,    18.60,  5580.00,  'USD', '2025-10-13', '2025-10-15', 'Barclays',       'Q4 2025', 'Sustainability'),
('$P3', 'HASI',  'HA Sustainable Infra',         'BUY',  400,    27.30, 10920.00,  'USD', '2025-10-14', '2025-10-16', 'Goldman Sachs',  'Q4 2025', 'Sustainability'),

-- Mixed portfolios — Nov 2025
('$P1', 'AAPL',  'Apple Inc.',                   'BUY',  200,   228.10, 45620.00,  'USD', '2025-11-04', '2025-11-06', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P1', 'MSFT',  'Microsoft Corp.',              'SELL', 100,   432.80, 43280.00,  'USD', '2025-11-05', '2025-11-07', 'Goldman Sachs',  'Q4 2025', 'Trading'),
('$P2', 'JPM',   'JPMorgan Chase & Co.',         'BUY',  200,   242.60, 48520.00,  'USD', '2025-11-06', '2025-11-10', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P1', 'NVDA',  'NVIDIA Corp.',                 'SELL', 100,   548.30, 54830.00,  'USD', '2025-11-07', '2025-11-11', 'Barclays',       'Q4 2025', 'Trading'),
('$P3', 'NEE',   'NextEra Energy',               'BUY',  300,    72.40, 21720.00,  'USD', '2025-11-10', '2025-11-12', 'Morgan Stanley', 'Q4 2025', 'Sustainability'),
('$P2', 'GS',    'Goldman Sachs Group',          'SELL', 50,    568.40, 28420.00,  'USD', '2025-11-11', '2025-11-13', 'JPMorgan',       'Q4 2025', 'Trading'),
('$P1', 'CRM',   'Salesforce Inc.',              'BUY',  80,    348.20, 27856.00,  'USD', '2025-11-12', '2025-11-14', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'GOOGL', 'Alphabet Inc.',                'BUY',  100,   182.50, 18250.00,  'USD', '2025-11-13', '2025-11-17', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P2', 'CVX',   'Chevron Corp.',                'BUY',  150,   158.30, 23745.00,  'USD', '2025-11-14', '2025-11-18', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P3', 'ENPH',  'Enphase Energy',               'SELL', 100,    98.40,  9840.00,  'USD', '2025-11-17', '2025-11-19', 'Barclays',       'Q4 2025', 'Sustainability'),

-- Dec 2025
('$P1', 'AMD',   'Advanced Micro Devices',       'BUY',  300,   142.80, 42840.00,  'USD', '2025-12-02', '2025-12-04', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P2', 'UNH',   'UnitedHealth Group',           'SELL', 40,    598.20, 23928.00,  'USD', '2025-12-03', '2025-12-05', 'JPMorgan',       'Q4 2025', 'Trading'),
('$P1', 'META',  'Meta Platforms Inc.',          'BUY',  100,   598.40, 59840.00,  'USD', '2025-12-04', '2025-12-08', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P3', 'FSLR',  'First Solar Inc.',             'BUY',  100,   228.60, 22860.00,  'USD', '2025-12-05', '2025-12-09', 'Goldman Sachs',  'Q4 2025', 'Sustainability'),
('$P2', 'WFC',   'Wells Fargo & Co.',            'BUY',  400,    68.30, 27320.00,  'USD', '2025-12-08', '2025-12-10', 'Citi',           'Q4 2025', 'Portfolio Management'),
('$P1', 'NFLX',  'Netflix Inc.',                 'SELL', 50,    898.30, 44915.00,  'USD', '2025-12-09', '2025-12-11', 'Barclays',       'Q4 2025', 'Trading'),
('$P1', 'NOW',   'ServiceNow Inc.',              'BUY',  40,    948.60, 37944.00,  'USD', '2025-12-10', '2025-12-12', 'Morgan Stanley', 'Q4 2025', 'Portfolio Management'),
('$P2', 'LIN',   'Linde plc',                    'BUY',  80,    478.20, 38256.00,  'USD', '2025-12-11', '2025-12-15', 'Goldman Sachs',  'Q4 2025', 'Portfolio Management'),
('$P1', 'PANW',  'Palo Alto Networks',           'BUY',  90,    398.40, 35856.00,  'USD', '2025-12-12', '2025-12-16', 'JPMorgan',       'Q4 2025', 'Portfolio Management'),
('$P3', 'BE',    'Bloom Energy',                 'SELL', 250,    18.40,  4600.00,  'USD', '2025-12-15', '2025-12-17', 'Citi',           'Q4 2025', 'Sustainability'),

-- Jan 2026
('$P1', 'AAPL',  'Apple Inc.',                   'BUY',  300,   242.80, 72840.00,  'USD', '2026-01-06', '2026-01-08', 'Goldman Sachs',  'Q1 2026', 'Portfolio Management'),
('$P2', 'BAC',   'Bank of America Corp.',        'BUY',  600,    46.80, 28080.00,  'USD', '2026-01-07', '2026-01-09', 'Morgan Stanley', 'Q1 2026', 'Portfolio Management'),
('$P1', 'NVDA',  'NVIDIA Corp.',                 'BUY',  150,   578.30, 86745.00,  'USD', '2026-01-08', '2026-01-12', 'JPMorgan',       'Q1 2026', 'Portfolio Management'),
('$P3', 'TSLA',  'Tesla Inc.',                   'BUY',  200,   398.40, 79680.00,  'USD', '2026-01-09', '2026-01-13', 'Barclays',       'Q1 2026', 'Sustainability'),
('$P2', 'XOM',   'Exxon Mobil Corp.',            'SELL', 150,   124.30, 18645.00,  'USD', '2026-01-13', '2026-01-15', 'Goldman Sachs',  'Q1 2026', 'Trading'),
('$P1', 'AMZN',  'Amazon.com Inc.',              'BUY',  120,   228.40, 27408.00,  'USD', '2026-01-14', '2026-01-16', 'Citi',           'Q1 2026', 'Portfolio Management'),
('$P2', 'JNJ',   'Johnson & Johnson',            'BUY',  200,   162.30, 32460.00,  'USD', '2026-01-15', '2026-01-19', 'Morgan Stanley', 'Q1 2026', 'Portfolio Management'),
('$P1', 'GOOGL', 'Alphabet Inc.',                'SELL', 80,    198.40, 15872.00,  'USD', '2026-01-16', '2026-01-20', 'JPMorgan',       'Q1 2026', 'Trading'),
('$P3', 'NEE',   'NextEra Energy',               'BUY',  200,    76.20, 15240.00,  'USD', '2026-01-20', '2026-01-22', 'Barclays',       'Q1 2026', 'Sustainability'),
('$P1', 'CRM',   'Salesforce Inc.',              'SELL', 60,    368.40, 22104.00,  'USD', '2026-01-21', '2026-01-23', 'Goldman Sachs',  'Q1 2026', 'Trading'),

-- Feb-Mar 2026
('$P1', 'MSFT',  'Microsoft Corp.',              'BUY',  150,   448.30, 67245.00,  'USD', '2026-02-03', '2026-02-05', 'Morgan Stanley', 'Q1 2026', 'Portfolio Management'),
('$P2', 'GS',    'Goldman Sachs Group',          'BUY',  75,    578.20, 43365.00,  'USD', '2026-02-04', '2026-02-06', 'Citi',           'Q1 2026', 'Portfolio Management'),
('$P3', 'ENPH',  'Enphase Energy',               'BUY',  300,   118.40, 35520.00,  'USD', '2026-02-05', '2026-02-07', 'Goldman Sachs',  'Q1 2026', 'Sustainability'),
('$P1', 'NVDA',  'NVIDIA Corp.',                 'BUY',  100,   628.40, 62840.00,  'USD', '2026-02-10', '2026-02-12', 'JPMorgan',       'Q1 2026', 'Portfolio Management'),
('$P2', 'MRK',   'Merck & Co.',                  'BUY',  150,   108.40, 16260.00,  'USD', '2026-02-11', '2026-02-13', 'Barclays',       'Q1 2026', 'Portfolio Management'),
('$P1', 'AMD',   'Advanced Micro Devices',       'SELL', 200,   178.40, 35680.00,  'USD', '2026-02-18', '2026-02-20', 'Goldman Sachs',  'Q1 2026', 'Trading'),
('$P2', 'CAT',   'Caterpillar Inc.',             'BUY',  80,    408.30, 32664.00,  'USD', '2026-02-19', '2026-02-23', 'Morgan Stanley', 'Q1 2026', 'Portfolio Management'),
('$P3', 'FSLR',  'First Solar Inc.',             'SELL', 80,    248.40, 19872.00,  'USD', '2026-02-24', '2026-02-26', 'Citi',           'Q1 2026', 'Sustainability'),
('$P1', 'META',  'Meta Platforms Inc.',          'SELL', 80,    648.30, 51864.00,  'USD', '2026-03-03', '2026-03-05', 'Barclays',       'Q1 2026', 'Trading'),
('$P1', 'AAPL',  'Apple Inc.',                   'BUY',  250,   238.40, 59600.00,  'USD', '2026-03-10', '2026-03-12', 'Goldman Sachs',  'Q1 2026', 'Portfolio Management'),
('$P2', 'JPM',   'JPMorgan Chase & Co.',         'SELL', 100,   258.40, 25840.00,  'USD', '2026-03-11', '2026-03-13', 'Morgan Stanley', 'Q1 2026', 'Trading'),
('$P1', 'NOW',   'ServiceNow Inc.',              'BUY',  30,    998.40, 29952.00,  'USD', '2026-03-17', '2026-03-19', 'Goldman Sachs',  'Q1 2026', 'Portfolio Management'),
('$P3', 'NEE',   'NextEra Energy',               'BUY',  250,    74.30, 18575.00,  'USD', '2026-03-18', '2026-03-20', 'JPMorgan',       'Q1 2026', 'Sustainability'),
('$P2', 'BRK.B', 'Berkshire Hathaway B',         'BUY',  100,   468.40, 46840.00,  'USD', '2026-03-19', '2026-03-23', 'Barclays',       'Q1 2026', 'Portfolio Management'),
('$P1', 'ORCL',  'Oracle Corp.',                 'BUY',  150,   198.30, 29745.00,  'USD', '2026-03-20', '2026-03-24', 'Goldman Sachs',  'Q1 2026', 'Portfolio Management');

EOSQL

AFTER=$(docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM transactions;" | tr -d ' \n')
echo "Transaction count after top-up: $AFTER"
echo "=== Done ==="
