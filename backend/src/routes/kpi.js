const express = require('express');
const pool = require('../db/pool');
const { requireAuth, requireTable } = require('../middleware/auth');

const router = express.Router();

// GET /api/kpi — portfolio-level KPIs
router.get('/', requireAuth, requireTable(['holdings', 'portfolios']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(DISTINCT h.ticker) AS total_positions,
        SUM(h.market_value_usd) AS total_aum,
        SUM(h.unrealized_pnl) AS total_unrealized_pnl,
        0 AS total_realized_pnl,
        SUM(h.unrealized_pnl) AS total_pnl,
        ROUND(AVG(h.weight_pct)::numeric, 4) AS avg_weight,
        SUM(h.market_value_usd) FILTER (WHERE h.asset_class = 'Equity') AS equity_aum,
        SUM(h.market_value_usd) FILTER (WHERE h.asset_class = 'Fixed Income') AS fi_aum,
        SUM(h.market_value_usd) FILTER (WHERE h.asset_class = 'Alternatives') AS alt_aum,
        COUNT(DISTINCT h.portfolio_id) AS active_portfolios
      FROM holdings h
      JOIN portfolios p ON h.portfolio_id = p.portfolio_id
      WHERE p.status = 'Active'
    `);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('KPI error:', err);
    res.status(500).json({ error: 'Failed to fetch KPIs' });
  }
});

// GET /api/kpi/by-portfolio — KPIs grouped by portfolio
router.get('/by-portfolio', requireAuth, requireTable(['holdings', 'portfolios']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        p.portfolio_id,
        p.portfolio_name,
        p.portfolio_type,
        'USD' AS base_currency,
        COUNT(h.holding_id) AS position_count,
        SUM(h.market_value_usd) AS aum,
        SUM(h.unrealized_pnl) AS total_pnl,
        ROUND((SUM(h.unrealized_pnl) / NULLIF(SUM(h.avg_cost_basis * h.quantity), 0) * 100)::numeric, 2) AS return_pct
      FROM portfolios p
      LEFT JOIN holdings h ON p.portfolio_id = h.portfolio_id
      WHERE p.status = 'Active'
      GROUP BY p.portfolio_id, p.portfolio_name, p.portfolio_type
      ORDER BY aum DESC NULLS LAST
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('KPI by-portfolio error:', err);
    res.status(500).json({ error: 'Failed to fetch portfolio KPIs' });
  }
});

module.exports = router;
