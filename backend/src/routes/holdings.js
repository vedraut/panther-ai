const express = require('express');
const pool = require('../db/pool');
const { requireAuth, requireTable } = require('../middleware/auth');

const router = express.Router();

// GET /api/holdings — paginated holdings table
router.get('/', requireAuth, requireTable(['holdings']), async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit || '50'), 200);
  const offset = parseInt(req.query.offset || '0');
  const portfolio_id = req.query.portfolio_id;
  const sector = req.query.sector;

  try {
    let where = [];
    let params = [];
    if (portfolio_id) { params.push(portfolio_id); where.push(`h.portfolio_id = $${params.length}`); }
    if (sector) { params.push(sector); where.push(`h.sector = $${params.length}`); }
    const whereClause = where.length ? 'WHERE ' + where.join(' AND ') : '';

    const result = await pool.query(`
      SELECT h.*, p.portfolio_name
      FROM holdings h
      JOIN portfolios p ON h.portfolio_id = p.portfolio_id
      ${whereClause}
      ORDER BY h.market_value DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `, [...params, limit, offset]);

    const countResult = await pool.query(
      `SELECT COUNT(*) FROM holdings h ${whereClause}`, params
    );

    res.json({
      data: result.rows,
      total: parseInt(countResult.rows[0].count),
      limit,
      offset
    });
  } catch (err) {
    console.error('Holdings error:', err);
    res.status(500).json({ error: 'Failed to fetch holdings' });
  }
});

// GET /api/holdings/pnl — top gainers/losers
router.get('/pnl', requireAuth, requireTable(['holdings']), async (req, res) => {
  try {
    const gainers = await pool.query(`
      SELECT ticker, company_name, sector, unrealized_pnl, realized_pnl,
             (unrealized_pnl + realized_pnl) AS total_pnl, market_value
      FROM holdings
      ORDER BY (unrealized_pnl + realized_pnl) DESC
      LIMIT 10
    `);
    const losers = await pool.query(`
      SELECT ticker, company_name, sector, unrealized_pnl, realized_pnl,
             (unrealized_pnl + realized_pnl) AS total_pnl, market_value
      FROM holdings
      ORDER BY (unrealized_pnl + realized_pnl) ASC
      LIMIT 10
    `);
    res.json({ gainers: gainers.rows, losers: losers.rows });
  } catch (err) {
    console.error('PnL error:', err);
    res.status(500).json({ error: 'Failed to fetch PnL data' });
  }
});

module.exports = router;
