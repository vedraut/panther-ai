import React, { useEffect, useState } from 'react';
import { Pie, Bar, Doughnut } from 'react-chartjs-2';
import {
  Chart as ChartJS, ArcElement, Tooltip, Legend,
  CategoryScale, LinearScale, BarElement, Title
} from 'chart.js';
import { api } from '../services/api';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title);

const COLORS = ['#00d4aa', '#4a6fa5', '#ff6b6b', '#ffd93d', '#6bcb77', '#4d96ff', '#ff922b', '#da77f2'];

const styles = {
  panel: { display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px', overflowY: 'auto' },
  chartGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' },
  chartCard: {
    background: '#0d1221', border: '1px solid #1e3a5f',
    borderRadius: '6px', padding: '16px'
  },
  chartTitle: { fontSize: '11px', color: '#4a6fa5', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: '12px' },
  table: { width: '100%', borderCollapse: 'collapse', fontSize: '12px' },
  th: { color: '#4a6fa5', fontWeight: 'normal', padding: '6px 8px', textAlign: 'left', borderBottom: '1px solid #1e3a5f', fontSize: '10px', textTransform: 'uppercase' },
  td: { padding: '7px 8px', borderBottom: '1px solid #0d1221', color: '#e0e0e0' }
};

const chartOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: { labels: { color: '#e0e0e0', font: { size: 11 } } }
  }
};

const barOptions = {
  ...chartOptions,
  scales: {
    x: { ticks: { color: '#4a6fa5', font: { size: 10 } }, grid: { color: '#1e3a5f33' } },
    y: { ticks: { color: '#4a6fa5', font: { size: 10 } }, grid: { color: '#1e3a5f33' } }
  }
};

function fmt(n) {
  if (!n) return '$0';
  const num = parseFloat(n);
  if (Math.abs(num) >= 1e9) return `$${(num / 1e9).toFixed(1)}B`;
  if (Math.abs(num) >= 1e6) return `$${(num / 1e6).toFixed(1)}M`;
  return `$${(num / 1e3).toFixed(0)}K`;
}

export default function ChartsPanel() {
  const [sectors, setSectors] = useState([]);
  const [assetClass, setAssetClass] = useState([]);
  const [esg, setEsg] = useState([]);
  const [pnl, setPnl] = useState({ gainers: [], losers: [] });
  const [portfolios, setPortfolios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([
      api.sectors().catch(() => []),
      api.sectorAssetClass().catch(() => []),
      api.sectorEsg().catch(() => []),
      api.holdingsPnl().catch(() => ({ gainers: [], losers: [] })),
      api.kpiByPortfolio().catch(() => [])
    ]).then(([s, a, e, p, port]) => {
      setSectors(s || []);
      setAssetClass(a || []);
      setEsg(e || []);
      setPnl(p || { gainers: [], losers: [] });
      setPortfolios(port || []);
      setLoading(false);
    }).catch(err => {
      setError(err.message);
      setLoading(false);
    });
  }, []);

  if (loading) return <div style={{ padding: '40px', textAlign: 'center', color: '#4a6fa5' }}>Loading charts...</div>;
  if (error) return <div style={{ padding: '40px', textAlign: 'center', color: '#ff4757' }}>{error}</div>;

  const sectorPieData = {
    labels: sectors.map(s => s.sector),
    datasets: [{ data: sectors.map(s => parseFloat(s.market_value)), backgroundColor: COLORS, borderWidth: 0 }]
  };

  const assetClassData = {
    labels: assetClass.map(a => a.asset_class),
    datasets: [{ data: assetClass.map(a => parseFloat(a.market_value)), backgroundColor: COLORS.slice(2), borderWidth: 0 }]
  };

  const esgBarData = {
    labels: esg.map(e => e.sector),
    datasets: [
      { label: 'Environmental', data: esg.map(e => parseFloat(e.avg_env)), backgroundColor: '#6bcb77' },
      { label: 'Social', data: esg.map(e => parseFloat(e.avg_social)), backgroundColor: '#4d96ff' },
      { label: 'Governance', data: esg.map(e => parseFloat(e.avg_gov)), backgroundColor: '#da77f2' }
    ]
  };

  const portfolioBarData = {
    labels: portfolios.map(p => p.portfolio_name),
    datasets: [{
      label: 'AUM',
      data: portfolios.map(p => parseFloat(p.aum || 0)),
      backgroundColor: '#00d4aa88',
      borderColor: '#00d4aa',
      borderWidth: 1
    }]
  };

  return (
    <div style={styles.panel}>
      <div style={styles.chartGrid}>
        <div style={styles.chartCard}>
          <div style={styles.chartTitle}>Sector Allocation</div>
          <Pie data={sectorPieData} options={chartOptions} />
        </div>
        <div style={styles.chartCard}>
          <div style={styles.chartTitle}>Asset Class Mix</div>
          <Doughnut data={assetClassData} options={chartOptions} />
        </div>
        <div style={{ ...styles.chartCard, gridColumn: '1 / -1' }}>
          <div style={styles.chartTitle}>ESG Scores by Sector</div>
          <Bar data={esgBarData} options={barOptions} />
        </div>
        <div style={{ ...styles.chartCard, gridColumn: '1 / -1' }}>
          <div style={styles.chartTitle}>AUM by Portfolio</div>
          <Bar data={portfolioBarData} options={barOptions} />
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
        <div style={styles.chartCard}>
          <div style={styles.chartTitle}>Top Gainers</div>
          <table style={styles.table}>
            <thead><tr>
              <th style={styles.th}>Ticker</th>
              <th style={styles.th}>Company</th>
              <th style={styles.th}>PnL</th>
            </tr></thead>
            <tbody>
              {pnl.gainers.slice(0, 5).map(h => (
                <tr key={h.ticker}>
                  <td style={styles.td}>{h.ticker}</td>
                  <td style={{ ...styles.td, color: '#4a6fa5' }}>{h.company_name}</td>
                  <td style={{ ...styles.td, color: '#00d4aa' }}>{fmt(h.total_pnl)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div style={styles.chartCard}>
          <div style={styles.chartTitle}>Top Losers</div>
          <table style={styles.table}>
            <thead><tr>
              <th style={styles.th}>Ticker</th>
              <th style={styles.th}>Company</th>
              <th style={styles.th}>PnL</th>
            </tr></thead>
            <tbody>
              {pnl.losers.slice(0, 5).map(h => (
                <tr key={h.ticker}>
                  <td style={styles.td}>{h.ticker}</td>
                  <td style={{ ...styles.td, color: '#4a6fa5' }}>{h.company_name}</td>
                  <td style={{ ...styles.td, color: '#ff4757' }}>{fmt(h.total_pnl)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
