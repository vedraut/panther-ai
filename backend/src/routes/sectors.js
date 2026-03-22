const express = require('express');
const pool = require('../db/pool');
const { requireAuth, requireTable } = require('../middleware/auth');

const router = express.Router();

// GET /api/sectors — sector breakdown for charts
router.get('/', requireAuth, requireTable(['holdings']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        sector,
        COUNT(DISTINCT ticker) AS ticker_count,
        SUM(market_value) AS market_value,
        ROUND(SUM(weight_pct)::numeric, 4) AS total_weight,
        SUM(unrealized_pnl + realized_pnl) AS total_pnl
      FROM holdings
      GROUP BY sector
      ORDER BY market_value DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Sectors error:', err);
    res.status(500).json({ error: 'Failed to fetch sector data' });
  }
});

// GET /api/sectors/asset-class
router.get('/asset-class', requireAuth, requireTable(['holdings']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        asset_class,
        COUNT(DISTINCT ticker) AS ticker_count,
        SUM(market_value) AS market_value,
        ROUND(SUM(weight_pct)::numeric, 4) AS total_weight
      FROM holdings
      GROUP BY asset_class
      ORDER BY market_value DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Asset class error:', err);
    res.status(500).json({ error: 'Failed to fetch asset class data' });
  }
});

// GET /api/sectors/esg
router.get('/esg', requireAuth, requireTable(['holdings', 'esg_scores']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        h.sector,
        ROUND(AVG(e.esg_total_score)::numeric, 2) AS avg_esg_score,
        ROUND(AVG(e.environmental_score)::numeric, 2) AS avg_env,
        ROUND(AVG(e.social_score)::numeric, 2) AS avg_social,
        ROUND(AVG(e.governance_score)::numeric, 2) AS avg_gov,
        COUNT(DISTINCT h.ticker) AS ticker_count
      FROM holdings h
      JOIN esg_scores e ON h.ticker = e.ticker
      GROUP BY h.sector
      ORDER BY avg_esg_score DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('ESG sectors error:', err);
    res.status(500).json({ error: 'Failed to fetch ESG sector data' });
  }
});

module.exports = router;
