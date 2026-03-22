const express = require('express');
const PDFDocument = require('pdfkit');
const pool = require('../db/pool');
const { requireAuth, requireTable } = require('../middleware/auth');

const router = express.Router();

// GET /api/export/holdings/csv
router.get('/holdings/csv', requireAuth, requireTable(['holdings']), async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT h.ticker, h.company_name, h.sector, h.asset_class,
             h.quantity, h.avg_cost, h.current_price, h.market_value,
             h.unrealized_pnl, h.realized_pnl, h.weight_pct, p.portfolio_name
      FROM holdings h
      JOIN portfolios p ON h.portfolio_id = p.portfolio_id
      ORDER BY h.market_value DESC
    `);

    const headers = Object.keys(result.rows[0] || {});
    const csv = [
      headers.join(','),
      ...result.rows.map(row =>
        headers.map(h => {
          const val = row[h];
          if (val === null || val === undefined) return '';
          const str = String(val);
          return str.includes(',') || str.includes('"') ? `"${str.replace(/"/g, '""')}"` : str;
        }).join(',')
      )
    ].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="panther_holdings.csv"');
    res.send(csv);
  } catch (err) {
    console.error('CSV export error:', err);
    res.status(500).json({ error: 'Failed to export CSV' });
  }
});

// GET /api/export/report/pdf
router.get('/report/pdf', requireAuth, requireTable(['holdings', 'portfolios']), async (req, res) => {
  try {
    const kpi = await pool.query(`
      SELECT
        COUNT(DISTINCT h.ticker) AS total_positions,
        SUM(h.market_value) AS total_aum,
        SUM(h.unrealized_pnl + h.realized_pnl) AS total_pnl,
        COUNT(DISTINCT h.portfolio_id) AS active_portfolios
      FROM holdings h
      JOIN portfolios p ON h.portfolio_id = p.portfolio_id
      WHERE p.is_active = true
    `);

    const sectors = await pool.query(`
      SELECT sector, SUM(market_value) AS market_value
      FROM holdings GROUP BY sector ORDER BY market_value DESC LIMIT 5
    `);

    const topHoldings = await pool.query(`
      SELECT ticker, company_name, market_value, weight_pct,
             (unrealized_pnl + realized_pnl) AS total_pnl
      FROM holdings ORDER BY market_value DESC LIMIT 10
    `);

    const doc = new PDFDocument({ margin: 50 });
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="panther_report.pdf"');
    doc.pipe(res);

    // Header
    doc.fontSize(20).fillColor('#00d4aa').text('PANTHER AI — Portfolio Report', { align: 'center' });
    doc.fontSize(10).fillColor('#666').text(`Generated: ${new Date().toUTCString()}`, { align: 'center' });
    doc.moveDown(1.5);

    // KPIs
    doc.fontSize(14).fillColor('#333').text('Portfolio Summary', { underline: true });
    doc.moveDown(0.5);
    const k = kpi.rows[0];
    const fmt = (n) => n ? parseFloat(n).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00';
    doc.fontSize(11).fillColor('#000');
    doc.text(`Total AUM: $${fmt(k.total_aum)}`);
    doc.text(`Total PnL: $${fmt(k.total_pnl)}`);
    doc.text(`Active Positions: ${k.total_positions}`);
    doc.text(`Active Portfolios: ${k.active_portfolios}`);
    doc.moveDown(1);

    // Sectors
    doc.fontSize(14).fillColor('#333').text('Top Sectors by Market Value', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(10).fillColor('#000');
    sectors.rows.forEach(s => {
      doc.text(`${s.sector}: $${fmt(s.market_value)}`);
    });
    doc.moveDown(1);

    // Top Holdings
    doc.fontSize(14).fillColor('#333').text('Top 10 Holdings', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(9).fillColor('#000');
    topHoldings.rows.forEach((h, i) => {
      doc.text(`${i + 1}. ${h.ticker} — ${h.company_name} | MV: $${fmt(h.market_value)} | PnL: $${fmt(h.total_pnl)}`);
    });

    doc.end();
  } catch (err) {
    console.error('PDF export error:', err);
    res.status(500).json({ error: 'Failed to generate PDF' });
  }
});

module.exports = router;
