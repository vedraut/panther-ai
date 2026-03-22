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

echo "=== Panther AI — Transactions Top-Up ==="

CURRENT=$(docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM transactions;" | tr -d ' \n')
echo "Current transaction count: $CURRENT"

if [ "$CURRENT" -ge 300 ]; then
  echo "Already at 300+ transactions ($CURRENT rows). Nothing to do."
  exit 0
fi

echo "Inserting top-up transactions..."

docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" << 'EOSQL'

INSERT INTO transactions (portfolio_id, ticker, company_name, trade_type, quantity, price, total_value, commission, trade_date, settlement_date, currency, broker, notes) VALUES
-- Portfolio 1 (Growth Equity)
(1, 'AAPL',  'Apple Inc.',                   'BUY',  500,   182.50, 91250.00,   45.00, '2025-10-01', '2025-10-03', 'USD', 'Goldman Sachs',  'Q4 accumulation'),
(1, 'MSFT',  'Microsoft Corp.',              'BUY',  300,   415.20, 124560.00,  55.00, '2025-10-02', '2025-10-06', 'USD', 'Morgan Stanley', 'AI tailwind play'),
(1, 'NVDA',  'NVIDIA Corp.',                 'BUY',  200,   498.75, 99750.00,   50.00, '2025-10-03', '2025-10-07', 'USD', 'JPMorgan',       'Data center demand'),
(1, 'GOOGL', 'Alphabet Inc.',                'BUY',  150,   172.30, 25845.00,   25.00, '2025-10-06', '2025-10-08', 'USD', 'Goldman Sachs',  'Search + cloud'),
(1, 'META',  'Meta Platforms Inc.',          'BUY',  250,   558.10, 139525.00,  60.00, '2025-10-07', '2025-10-09', 'USD', 'Barclays',       'Ad revenue recovery'),
(1, 'AMZN',  'Amazon.com Inc.',              'BUY',  180,   198.40, 35712.00,   30.00, '2025-10-08', '2025-10-10', 'USD', 'Citi',           'AWS growth'),
(1, 'TSLA',  'Tesla Inc.',                   'SELL', 100,   265.80, 26580.00,   20.00, '2025-10-09', '2025-10-13', 'USD', 'Morgan Stanley', 'Trim on valuation'),
(1, 'CRM',   'Salesforce Inc.',              'BUY',  120,   322.50, 38700.00,   35.00, '2025-10-10', '2025-10-14', 'USD', 'Goldman Sachs',  'Enterprise SaaS'),
(1, 'AMD',   'Advanced Micro Devices',       'BUY',  400,   168.20, 67280.00,   40.00, '2025-10-13', '2025-10-15', 'USD', 'JPMorgan',       'GPU market share'),
(1, 'ADBE',  'Adobe Inc.',                   'SELL', 80,    580.30, 46424.00,   35.00, '2025-10-14', '2025-10-16', 'USD', 'Barclays',       'Rebalance'),

-- Portfolio 1 continued
(1, 'NFLX',  'Netflix Inc.',                 'BUY',  90,    685.40, 61686.00,   40.00, '2025-10-15', '2025-10-17', 'USD', 'Goldman Sachs',  'Content slate'),
(1, 'ORCL',  'Oracle Corp.',                 'BUY',  220,   178.60, 39292.00,   30.00, '2025-10-16', '2025-10-20', 'USD', 'Citi',           'Cloud migration'),
(1, 'NOW',   'ServiceNow Inc.',              'BUY',  60,    890.20, 53412.00,   40.00, '2025-10-17', '2025-10-21', 'USD', 'Morgan Stanley', 'AI workflow'),
(1, 'PANW',  'Palo Alto Networks',           'BUY',  110,   388.75, 42762.50,   35.00, '2025-10-20', '2025-10-22', 'USD', 'Barclays',       'Cybersecurity'),
(1, 'SNOW',  'Snowflake Inc.',               'SELL', 150,   178.90, 26835.00,   25.00, '2025-10-21', '2025-10-23', 'USD', 'Goldman Sachs',  'Reduce position'),

-- Portfolio 2 (Value / Income)
(2, 'JPM',   'JPMorgan Chase & Co.',         'BUY',  400,   225.80, 90320.00,   50.00, '2025-10-01', '2025-10-03', 'USD', 'Morgan Stanley', 'Rate environment'),
(2, 'BAC',   'Bank of America Corp.',        'BUY',  800,    42.30, 33840.00,   30.00, '2025-10-02', '2025-10-06', 'USD', 'Citi',           'Loan growth'),
(2, 'WFC',   'Wells Fargo & Co.',            'BUY',  600,    60.20, 36120.00,   35.00, '2025-10-03', '2025-10-07', 'USD', 'JPMorgan',       'Cost restructuring'),
(2, 'GS',    'Goldman Sachs Group',          'BUY',  100,   548.30, 54830.00,   45.00, '2025-10-06', '2025-10-08', 'USD', 'Barclays',       'IB recovery'),
(2, 'BRK.B', 'Berkshire Hathaway B',        'BUY',  150,   444.10, 66615.00,   40.00, '2025-10-07', '2025-10-09', 'USD', 'Goldman Sachs',  'Defensive core'),
(2, 'JNJ',   'Johnson & Johnson',            'BUY',  300,   155.40, 46620.00,   35.00, '2025-10-08', '2025-10-10', 'USD', 'Citi',           'Pharma pipeline'),
(2, 'PFE',   'Pfizer Inc.',                  'BUY',  900,    27.80, 25020.00,   25.00, '2025-10-09', '2025-10-13', 'USD', 'Morgan Stanley', 'Dividend yield'),
(2, 'MRK',   'Merck & Co.',                  'BUY',  200,   118.60, 23720.00,   25.00, '2025-10-10', '2025-10-14', 'USD', 'JPMorgan',       'Keytruda growth'),
(2, 'ABT',   'Abbott Laboratories',          'SELL', 180,   115.20, 20736.00,   20.00, '2025-10-13', '2025-10-15', 'USD', 'Barclays',       'Trim on target'),
(2, 'UNH',   'UnitedHealth Group',           'BUY',  80,    582.30, 46584.00,   40.00, '2025-10-14', '2025-10-16', 'USD', 'Goldman Sachs',  'Medicare Advantage'),

-- Portfolio 2 continued
(2, 'CVX',   'Chevron Corp.',                'BUY',  250,   162.40, 40600.00,   35.00, '2025-10-15', '2025-10-17', 'USD', 'Citi',           'Energy transition'),
(2, 'XOM',   'Exxon Mobil Corp.',            'BUY',  300,   118.80, 35640.00,   35.00, '2025-10-16', '2025-10-20', 'USD', 'Morgan Stanley', 'Cash flow'),
(2, 'COP',   'ConocoPhillips',               'SELL', 200,    128.50, 25700.00,  25.00, '2025-10-17', '2025-10-21', 'USD', 'Barclays',       'Rebalance energy'),
(2, 'LIN',   'Linde plc',                    'BUY',  100,   458.20, 45820.00,   35.00, '2025-10-20', '2025-10-22', 'USD', 'Goldman Sachs',  'Industrial gases'),
(2, 'CAT',   'Caterpillar Inc.',             'BUY',  120,   388.60, 46632.00,   35.00, '2025-10-21', '2025-10-23', 'USD', 'JPMorgan',       'Infrastructure'),

-- Portfolio 3 (ESG / Sustainable)
(3, 'TSLA',  'Tesla Inc.',                   'BUY',  300,   258.40, 77520.00,   45.00, '2025-10-01', '2025-10-03', 'USD', 'Morgan Stanley', 'EV growth'),
(3, 'ENPH',  'Enphase Energy',               'BUY',  200,   108.30, 21660.00,   25.00, '2025-10-02', '2025-10-06', 'USD', 'Goldman Sachs',  'Solar adoption'),
(3, 'NEE',   'NextEra Energy',               'BUY',  400,    78.20, 31280.00,   30.00, '2025-10-03', '2025-10-07', 'USD', 'Citi',           'Renewables leader'),
(3, 'FSLR',  'First Solar Inc.',             'BUY',  150,   218.50, 32775.00,   30.00, '2025-10-06', '2025-10-08', 'USD', 'Barclays',       'Panel efficiency'),
(3, 'SEDG',  'SolarEdge Technologies',       'SELL', 100,    62.10,  6210.00,   15.00, '2025-10-07', '2025-10-09', 'USD', 'Morgan Stanley', 'Guidance cut'),
(3, 'BE',    'Bloom Energy',                 'BUY',  500,    14.80,  7400.00,   15.00, '2025-10-08', '2025-10-10', 'USD', 'Goldman Sachs',  'Hydrogen play'),
(3, 'PLUG',  'Plug Power Inc.',              'BUY',  800,     3.20,  2560.00,   10.00, '2025-10-09', '2025-10-13', 'USD', 'JPMorgan',       'Speculative green'),
(3, 'RUN',   'Sunrun Inc.',                  'BUY',  600,    14.40,  8640.00,   15.00, '2025-10-10', '2025-10-14', 'USD', 'Citi',           'Residential solar'),
(3, 'CSIQ',  'Canadian Solar Inc.',          'BUY',  300,    18.60,  5580.00,   15.00, '2025-10-13', '2025-10-15', 'USD', 'Barclays',       'Module pricing'),
(3, 'HASI',  'HA Sustainable Infra',         'BUY',  400,    27.30, 10920.00,   20.00, '2025-10-14', '2025-10-16', 'USD', 'Goldman Sachs',  'ESG infrastructure'),

-- Q4 2025 — mixed portfolios
(1, 'AAPL',  'Apple Inc.',                   'BUY',  200,   228.10, 45620.00,   35.00, '2025-11-04', '2025-11-06', 'USD', 'Morgan Stanley', 'Post-earnings add'),
(1, 'MSFT',  'Microsoft Corp.',              'SELL', 100,   432.80, 43280.00,   35.00, '2025-11-05', '2025-11-07', 'USD', 'Goldman Sachs',  'Partial profit'),
(2, 'JPM',   'JPMorgan Chase & Co.',         'BUY',  200,   242.60, 48520.00,   35.00, '2025-11-06', '2025-11-10', 'USD', 'Citi',           'Rate cut hedge'),
(1, 'NVDA',  'NVIDIA Corp.',                 'SELL', 100,   548.30, 54830.00,   40.00, '2025-11-07', '2025-11-11', 'USD', 'Barclays',       'Trim after run'),
(3, 'NEE',   'NextEra Energy',               'BUY',  300,    72.40, 21720.00,   25.00, '2025-11-10', '2025-11-12', 'USD', 'Morgan Stanley', 'Utility yield'),
(2, 'GS',    'Goldman Sachs Group',          'SELL', 50,    568.40, 28420.00,   30.00, '2025-11-11', '2025-11-13', 'USD', 'JPMorgan',       'Rebalance'),
(1, 'CRM',   'Salesforce Inc.',              'BUY',  80,    348.20, 27856.00,   25.00, '2025-11-12', '2025-11-14', 'USD', 'Goldman Sachs',  'AI Agentforce'),
(1, 'GOOGL', 'Alphabet Inc.',                'BUY',  100,   182.50, 18250.00,   20.00, '2025-11-13', '2025-11-17', 'USD', 'Morgan Stanley', 'Waymo optionality'),
(2, 'CVX',   'Chevron Corp.',                'BUY',  150,   158.30, 23745.00,   25.00, '2025-11-14', '2025-11-18', 'USD', 'Citi',           'Oil dip buy'),
(3, 'ENPH',  'Enphase Energy',               'SELL', 100,    98.40,  9840.00,   15.00, '2025-11-17', '2025-11-19', 'USD', 'Barclays',       'Guidance miss'),

-- December 2025
(1, 'AMD',   'Advanced Micro Devices',       'BUY',  300,   142.80, 42840.00,   35.00, '2025-12-02', '2025-12-04', 'USD', 'Goldman Sachs',  'EPYC momentum'),
(2, 'UNH',   'UnitedHealth Group',           'SELL', 40,    598.20, 23928.00,   25.00, '2025-12-03', '2025-12-05', 'USD', 'JPMorgan',       'Year-end trim'),
(1, 'META',  'Meta Platforms Inc.',          'BUY',  100,   598.40, 59840.00,   40.00, '2025-12-04', '2025-12-08', 'USD', 'Morgan Stanley', 'Llama 4 catalyst'),
(3, 'FSLR',  'First Solar Inc.',             'BUY',  100,   228.60, 22860.00,   25.00, '2025-12-05', '2025-12-09', 'USD', 'Goldman Sachs',  'IRA tailwind'),
(2, 'WFC',   'Wells Fargo & Co.',            'BUY',  400,    68.30, 27320.00,   30.00, '2025-12-08', '2025-12-10', 'USD', 'Citi',           'Asset cap lifted'),
(1, 'NFLX',  'Netflix Inc.',                 'SELL', 50,    898.30, 44915.00,   35.00, '2025-12-09', '2025-12-11', 'USD', 'Barclays',       'Year-end lock in'),
(1, 'NOW',   'ServiceNow Inc.',              'BUY',  40,    948.60, 37944.00,   30.00, '2025-12-10', '2025-12-12', 'USD', 'Morgan Stanley', 'AI platform'),
(2, 'LIN',   'Linde plc',                    'BUY',  80,    478.20, 38256.00,   30.00, '2025-12-11', '2025-12-15', 'USD', 'Goldman Sachs',  'Defensive growth'),
(1, 'PANW',  'Palo Alto Networks',           'BUY',  90,    398.40, 35856.00,   30.00, '2025-12-12', '2025-12-16', 'USD', 'JPMorgan',       'Security budget'),
(3, 'BE',    'Bloom Energy',                 'SELL', 250,    18.40,  4600.00,   10.00, '2025-12-15', '2025-12-17', 'USD', 'Citi',           'Partial exit'),

-- January 2026
(1, 'AAPL',  'Apple Inc.',                   'BUY',  300,   242.80, 72840.00,   40.00, '2026-01-06', '2026-01-08', 'USD', 'Goldman Sachs',  'iPhone 17 cycle'),
(2, 'BAC',   'Bank of America Corp.',        'BUY',  600,    46.80, 28080.00,   25.00, '2026-01-07', '2026-01-09', 'USD', 'Morgan Stanley', 'NIM expansion'),
(1, 'NVDA',  'NVIDIA Corp.',                 'BUY',  150,   578.30, 86745.00,   50.00, '2026-01-08', '2026-01-12', 'USD', 'JPMorgan',       'CES AI announcements'),
(3, 'TSLA',  'Tesla Inc.',                   'BUY',  200,   398.40, 79680.00,   45.00, '2026-01-09', '2026-01-13', 'USD', 'Barclays',       'FSD milestone'),
(2, 'XOM',   'Exxon Mobil Corp.',            'SELL', 150,   124.30, 18645.00,   20.00, '2026-01-13', '2026-01-15', 'USD', 'Goldman Sachs',  'Oil price softness'),
(1, 'AMZN',  'Amazon.com Inc.',              'BUY',  120,   228.40, 27408.00,   25.00, '2026-01-14', '2026-01-16', 'USD', 'Citi',           'AWS AI services'),
(2, 'JNJ',   'Johnson & Johnson',            'BUY',  200,   162.30, 32460.00,   30.00, '2026-01-15', '2026-01-19', 'USD', 'Morgan Stanley', 'Medtech spin'),
(1, 'GOOGL', 'Alphabet Inc.',                'SELL', 80,    198.40, 15872.00,   20.00, '2026-01-16', '2026-01-20', 'USD', 'JPMorgan',       'Antitrust concerns'),
(3, 'NEE',   'NextEra Energy',               'BUY',  200,    76.20, 15240.00,   20.00, '2026-01-20', '2026-01-22', 'USD', 'Barclays',       'Grid demand surge'),
(1, 'CRM',   'Salesforce Inc.',              'SELL', 60,    368.40, 22104.00,   20.00, '2026-01-21', '2026-01-23', 'USD', 'Goldman Sachs',  'Rebalance growth'),

-- February–March 2026
(1, 'MSFT',  'Microsoft Corp.',              'BUY',  150,   448.30, 67245.00,   40.00, '2026-02-03', '2026-02-05', 'USD', 'Morgan Stanley', 'Copilot adoption'),
(2, 'GS',    'Goldman Sachs Group',          'BUY',  75,    578.20, 43365.00,   35.00, '2026-02-04', '2026-02-06', 'USD', 'Citi',           'M&A pipeline'),
(3, 'ENPH',  'Enphase Energy',               'BUY',  300,   118.40, 35520.00,   30.00, '2026-02-05', '2026-02-07', 'USD', 'Goldman Sachs',  'Residential demand'),
(1, 'NVDA',  'NVIDIA Corp.',                 'BUY',  100,   628.40, 62840.00,   45.00, '2026-02-10', '2026-02-12', 'USD', 'JPMorgan',       'Blackwell ramp'),
(2, 'MRK',   'Merck & Co.',                  'BUY',  150,   108.40, 16260.00,   20.00, '2026-02-11', '2026-02-13', 'USD', 'Barclays',       'Pipeline catalyst'),
(1, 'AMD',   'Advanced Micro Devices',       'SELL', 200,   178.40, 35680.00,   30.00, '2026-02-18', '2026-02-20', 'USD', 'Goldman Sachs',  'Trim on strength'),
(2, 'CAT',   'Caterpillar Inc.',             'BUY',  80,    408.30, 32664.00,   30.00, '2026-02-19', '2026-02-23', 'USD', 'Morgan Stanley', 'Infrastructure bill'),
(3, 'FSLR',  'First Solar Inc.',             'SELL', 80,    248.40, 19872.00,   20.00, '2026-02-24', '2026-02-26', 'USD', 'Citi',           'Capacity constraints'),
(1, 'META',  'Meta Platforms Inc.',          'SELL', 80,    648.30, 51864.00,   40.00, '2026-03-03', '2026-03-05', 'USD', 'Barclays',       'Rebalance after run'),
(1, 'AAPL',  'Apple Inc.',                   'BUY',  250,   238.40, 59600.00,   40.00, '2026-03-10', '2026-03-12', 'USD', 'Goldman Sachs',  'Services growth'),
(2, 'JPM',   'JPMorgan Chase & Co.',         'SELL', 100,   258.40, 25840.00,   25.00, '2026-03-11', '2026-03-13', 'USD', 'Morgan Stanley', 'Rate sensitivity'),
(1, 'NOW',   'ServiceNow Inc.',              'BUY',  30,    998.40, 29952.00,   25.00, '2026-03-17', '2026-03-19', 'USD', 'Goldman Sachs',  'Enterprise AI'),
(3, 'NEE',   'NextEra Energy',               'BUY',  250,    74.30, 18575.00,   20.00, '2026-03-18', '2026-03-20', 'USD', 'JPMorgan',       'Data center power'),
(2, 'BRK.B', 'Berkshire Hathaway B',        'BUY',  100,   468.40, 46840.00,   35.00, '2026-03-19', '2026-03-23', 'USD', 'Barclays',       'Defensive position'),
(1, 'ORCL',  'Oracle Corp.',                 'BUY',  150,   198.30, 29745.00,   25.00, '2026-03-20', '2026-03-24', 'USD', 'Goldman Sachs',  'Cloud AI database');

EOSQL

AFTER=$(docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM transactions;" | tr -d ' \n')
echo "Transaction count after top-up: $AFTER"
echo "=== Done ==="
