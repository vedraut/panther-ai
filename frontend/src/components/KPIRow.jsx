import React from 'react';

const styles = {
  row: {
    display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '1px',
    background: '#1e3a5f22', borderBottom: '1px solid #00d4aa22', flexShrink: 0
  },
  card: {
    background: '#0d1221', padding: '14px 20px', textAlign: 'center'
  },
  label: { fontSize: '10px', color: '#4a6fa5', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: '6px' },
  value: { fontSize: '20px', fontWeight: 'bold', color: '#00d4aa', fontFamily: 'Courier New, monospace' },
  sub: { fontSize: '11px', color: '#4a6fa5', marginTop: '2px' }
};

function fmt(n, prefix = '$') {
  if (!n && n !== 0) return '—';
  const num = parseFloat(n);
  if (Math.abs(num) >= 1e9) return `${prefix}${(num / 1e9).toFixed(2)}B`;
  if (Math.abs(num) >= 1e6) return `${prefix}${(num / 1e6).toFixed(2)}M`;
  if (Math.abs(num) >= 1e3) return `${prefix}${(num / 1e3).toFixed(2)}K`;
  return `${prefix}${num.toFixed(2)}`;
}

function pnlColor(n) {
  if (!n) return '#e0e0e0';
  return parseFloat(n) >= 0 ? '#00d4aa' : '#ff4757';
}

export default function KPIRow({ kpi, loading }) {
  if (loading) {
    return (
      <div style={styles.row}>
        {[...Array(5)].map((_, i) => (
          <div key={i} style={styles.card}>
            <div style={styles.label}>Loading...</div>
            <div style={{ ...styles.value, color: '#1e3a5f' }}>——</div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div style={styles.row}>
      <div style={styles.card}>
        <div style={styles.label}>Total AUM</div>
        <div style={styles.value}>{fmt(kpi?.total_aum)}</div>
        <div style={styles.sub}>{kpi?.active_portfolios || 0} portfolios</div>
      </div>
      <div style={styles.card}>
        <div style={styles.label}>Unrealized PnL</div>
        <div style={{ ...styles.value, color: pnlColor(kpi?.total_unrealized_pnl) }}>
          {fmt(kpi?.total_unrealized_pnl)}
        </div>
        <div style={styles.sub}>Open positions</div>
      </div>
      <div style={styles.card}>
        <div style={styles.label}>Realized PnL</div>
        <div style={{ ...styles.value, color: pnlColor(kpi?.total_realized_pnl) }}>
          {fmt(kpi?.total_realized_pnl)}
        </div>
        <div style={styles.sub}>Closed trades</div>
      </div>
      <div style={styles.card}>
        <div style={styles.label}>Total PnL</div>
        <div style={{ ...styles.value, color: pnlColor(kpi?.total_pnl) }}>
          {fmt(kpi?.total_pnl)}
        </div>
        <div style={styles.sub}>Combined</div>
      </div>
      <div style={styles.card}>
        <div style={styles.label}>Positions</div>
        <div style={styles.value}>{kpi?.total_positions || '—'}</div>
        <div style={styles.sub}>Active tickers</div>
      </div>
    </div>
  );
}
