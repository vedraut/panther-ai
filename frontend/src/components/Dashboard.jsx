import React, { useState, useEffect } from 'react';
import Header from './Header';
import KPIRow from './KPIRow';
import ChartsPanel from './ChartsPanel';
import ChatPanel from './ChatPanel';
import { api } from '../services/api';

const styles = {
  app: { display: 'flex', flexDirection: 'column', height: '100vh', background: '#0a0e1a', color: '#e0e0e0' },
  tabs: {
    display: 'flex', gap: '0', background: '#0d1221',
    borderBottom: '1px solid #1e3a5f', padding: '0 24px', flexShrink: 0
  },
  tab: {
    padding: '10px 20px', cursor: 'pointer', fontSize: '11px',
    letterSpacing: '1px', textTransform: 'uppercase', fontFamily: 'Courier New, monospace',
    borderBottom: '2px solid transparent', transition: 'all 0.2s', color: '#4a6fa5'
  },
  tabActive: { color: '#00d4aa', borderBottom: '2px solid #00d4aa' },
  main: { display: 'flex', flex: 1, overflow: 'hidden' },
  content: { flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' },
  chat: { width: '380px', flexShrink: 0 },
  deniedBanner: {
    margin: '16px', padding: '12px 16px', background: '#ff475711',
    border: '1px solid #ff475744', borderRadius: '6px', fontSize: '12px', color: '#ff4757'
  }
};

const TABS = ['Overview', 'Charts', 'Holdings'];

export default function Dashboard({ user, onLogout }) {
  const [activeTab, setActiveTab] = useState('Overview');
  const [kpi, setKpi] = useState(null);
  const [kpiLoading, setKpiLoading] = useState(true);
  const [accessError, setAccessError] = useState('');

  useEffect(() => {
    api.kpi()
      .then(data => { setKpi(data); setKpiLoading(false); })
      .catch(err => {
        setKpiLoading(false);
        if (err.message?.includes('Access denied') || err.message?.includes('does not have access')) {
          setAccessError(err.message);
        }
      });
  }, []);

  return (
    <div style={styles.app}>
      <Header user={user} onLogout={onLogout} />
      <KPIRow kpi={kpi} loading={kpiLoading} />
      <div style={styles.tabs}>
        {TABS.map(tab => (
          <div
            key={tab}
            style={{ ...styles.tab, ...(activeTab === tab ? styles.tabActive : {}) }}
            onClick={() => setActiveTab(tab)}
          >
            {tab}
          </div>
        ))}
      </div>
      <div style={styles.main}>
        <div style={styles.content}>
          {accessError && (
            <div style={styles.deniedBanner}>
              Access Restricted: {accessError}
            </div>
          )}
          {activeTab === 'Overview' && <OverviewTab user={user} />}
          {activeTab === 'Charts' && <ChartsPanel />}
          {activeTab === 'Holdings' && <HoldingsTab user={user} />}
        </div>
        <div style={styles.chat}>
          <ChatPanel user={user} />
        </div>
      </div>
    </div>
  );
}

function OverviewTab({ user }) {
  const [portfolios, setPortfolios] = useState([]);
  useEffect(() => {
    api.kpiByPortfolio().then(setPortfolios).catch(() => {});
  }, []);

  const s = {
    container: { padding: '20px', overflowY: 'auto', height: '100%' },
    grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '12px' },
    card: { background: '#0d1221', border: '1px solid #1e3a5f', borderRadius: '6px', padding: '16px' },
    name: { fontSize: '13px', color: '#00d4aa', marginBottom: '4px' },
    type: { fontSize: '10px', color: '#4a6fa5', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '12px' },
    stat: { display: 'flex', justifyContent: 'space-between', marginBottom: '4px' },
    statLabel: { fontSize: '11px', color: '#4a6fa5' },
    statVal: { fontSize: '11px', color: '#e0e0e0' }
  };

  function fmtM(n) {
    if (!n) return '$0';
    const v = parseFloat(n);
    if (Math.abs(v) >= 1e9) return `$${(v / 1e9).toFixed(2)}B`;
    if (Math.abs(v) >= 1e6) return `$${(v / 1e6).toFixed(2)}M`;
    return `$${(v / 1e3).toFixed(0)}K`;
  }

  return (
    <div style={s.container}>
      <div style={{ fontSize: '11px', color: '#4a6fa5', letterSpacing: '1px', marginBottom: '16px', textTransform: 'uppercase' }}>
        Portfolio Overview — {user.full_name} ({user.role})
      </div>
      <div style={s.grid}>
        {portfolios.map(p => (
          <div key={p.portfolio_id} style={s.card}>
            <div style={s.name}>{p.portfolio_name}</div>
            <div style={s.type}>{p.portfolio_type} | {p.base_currency}</div>
            <div style={s.stat}><span style={s.statLabel}>AUM</span><span style={s.statVal}>{fmtM(p.aum)}</span></div>
            <div style={s.stat}><span style={s.statLabel}>Positions</span><span style={s.statVal}>{p.position_count}</span></div>
            <div style={s.stat}>
              <span style={s.statLabel}>Return</span>
              <span style={{ ...s.statVal, color: parseFloat(p.return_pct || 0) >= 0 ? '#00d4aa' : '#ff4757' }}>
                {p.return_pct ? `${p.return_pct}%` : '—'}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function HoldingsTab({ user }) {
  const [holdings, setHoldings] = useState([]);
  const [total, setTotal] = useState(0);
  const [offset, setOffset] = useState(0);
  const LIMIT = 50;

  useEffect(() => {
    api.holdings({ limit: LIMIT, offset }).then(data => {
      setHoldings(data.data || []);
      setTotal(data.total || 0);
    }).catch(() => {});
  }, [offset]);

  function fmtN(n) {
    if (!n && n !== 0) return '—';
    return parseFloat(n).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  const s = {
    container: { display: 'flex', flexDirection: 'column', height: '100%' },
    tableWrap: { overflowY: 'auto', flex: 1 },
    table: { width: '100%', borderCollapse: 'collapse', fontSize: '12px' },
    th: { position: 'sticky', top: 0, background: '#0a0e1a', color: '#4a6fa5', fontWeight: 'normal', padding: '8px 10px', textAlign: 'left', borderBottom: '1px solid #1e3a5f', fontSize: '10px', textTransform: 'uppercase', letterSpacing: '1px' },
    td: { padding: '7px 10px', borderBottom: '1px solid #0d1221', color: '#e0e0e0' },
    pagination: { padding: '10px 16px', borderTop: '1px solid #1e3a5f', display: 'flex', gap: '12px', alignItems: 'center', fontSize: '12px', color: '#4a6fa5', flexShrink: 0 },
    btn: { background: 'none', border: '1px solid #1e3a5f', color: '#4a6fa5', padding: '4px 10px', borderRadius: '3px', cursor: 'pointer', fontSize: '11px', fontFamily: 'Courier New, monospace' }
  };

  return (
    <div style={s.container}>
      <div style={s.tableWrap}>
        <table style={s.table}>
          <thead><tr>
            {['Ticker','Company','Sector','Qty','Avg Cost','Price','Mkt Value','Unreal. PnL','Real. PnL','Weight'].map(h => (
              <th key={h} style={s.th}>{h}</th>
            ))}
          </tr></thead>
          <tbody>
            {holdings.map(h => (
              <tr key={h.holding_id} style={{ ':hover': { background: '#0d1221' } }}>
                <td style={{ ...s.td, color: '#00d4aa' }}>{h.ticker}</td>
                <td style={s.td}>{h.company_name}</td>
                <td style={{ ...s.td, color: '#4a6fa5' }}>{h.sector}</td>
                <td style={s.td}>{fmtN(h.quantity)}</td>
                <td style={s.td}>${fmtN(h.avg_cost)}</td>
                <td style={s.td}>${fmtN(h.current_price)}</td>
                <td style={s.td}>${fmtN(h.market_value)}</td>
                <td style={{ ...s.td, color: parseFloat(h.unrealized_pnl || 0) >= 0 ? '#00d4aa' : '#ff4757' }}>
                  ${fmtN(h.unrealized_pnl)}
                </td>
                <td style={{ ...s.td, color: parseFloat(h.realized_pnl || 0) >= 0 ? '#00d4aa' : '#ff4757' }}>
                  ${fmtN(h.realized_pnl)}
                </td>
                <td style={s.td}>{h.weight_pct ? `${parseFloat(h.weight_pct).toFixed(2)}%` : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div style={s.pagination}>
        <button style={s.btn} onClick={() => setOffset(Math.max(0, offset - LIMIT))} disabled={offset === 0}>Prev</button>
        <span>Showing {offset + 1}–{Math.min(offset + LIMIT, total)} of {total}</span>
        <button style={s.btn} onClick={() => setOffset(offset + LIMIT)} disabled={offset + LIMIT >= total}>Next</button>
      </div>
    </div>
  );
}
