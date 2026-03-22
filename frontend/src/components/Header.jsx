import React from 'react';
import { api } from '../services/api';

const styles = {
  header: {
    background: '#0d1221', borderBottom: '1px solid #00d4aa22',
    padding: '0 24px', height: '52px', display: 'flex',
    alignItems: 'center', justifyContent: 'space-between', flexShrink: 0
  },
  left: { display: 'flex', alignItems: 'center', gap: '16px' },
  logo: { fontSize: '18px', fontWeight: 'bold', color: '#00d4aa', letterSpacing: '3px' },
  separator: { color: '#1e3a5f' },
  title: { fontSize: '12px', color: '#4a6fa5', letterSpacing: '1px' },
  right: { display: 'flex', alignItems: 'center', gap: '20px' },
  userInfo: { textAlign: 'right' },
  userName: { fontSize: '13px', color: '#e0e0e0' },
  userRole: { fontSize: '11px', color: '#4a6fa5' },
  logoutBtn: {
    background: 'none', border: '1px solid #1e3a5f', color: '#4a6fa5',
    padding: '5px 12px', borderRadius: '3px', cursor: 'pointer',
    fontSize: '11px', fontFamily: 'Courier New, monospace', letterSpacing: '1px',
    transition: 'all 0.2s'
  },
  exportBtns: { display: 'flex', gap: '8px' },
  exportBtn: {
    background: 'none', border: '1px solid #00d4aa44', color: '#00d4aa',
    padding: '5px 10px', borderRadius: '3px', cursor: 'pointer',
    fontSize: '11px', fontFamily: 'Courier New, monospace', letterSpacing: '1px',
    textDecoration: 'none', display: 'inline-block'
  }
};

export default function Header({ user, onLogout }) {
  return (
    <header style={styles.header}>
      <div style={styles.left}>
        <span style={styles.logo}>PANTHER</span>
        <span style={styles.separator}>|</span>
        <span style={styles.title}>FINANCIAL INTELLIGENCE PLATFORM</span>
      </div>
      <div style={styles.right}>
        <div style={styles.exportBtns}>
          <a
            href={api.exportHoldingsCsv()}
            style={styles.exportBtn}
            download
          >
            CSV
          </a>
          <a
            href={api.exportReportPdf()}
            style={styles.exportBtn}
            download
          >
            PDF
          </a>
        </div>
        <div style={styles.userInfo}>
          <div style={styles.userName}>{user.full_name}</div>
          <div style={styles.userRole}>{user.role} | {user.department}</div>
        </div>
        <button style={styles.logoutBtn} onClick={onLogout}>LOGOUT</button>
      </div>
    </header>
  );
}
