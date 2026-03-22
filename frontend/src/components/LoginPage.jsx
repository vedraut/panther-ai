import React, { useState } from 'react';
import { api } from '../services/api';

const styles = {
  container: {
    minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
    background: 'linear-gradient(135deg, #0a0e1a 0%, #0d1530 50%, #0a0e1a 100%)'
  },
  card: {
    background: '#0d1221', border: '1px solid #00d4aa33',
    borderRadius: '8px', padding: '40px 48px', width: '420px',
    boxShadow: '0 0 40px #00d4aa15'
  },
  logo: { textAlign: 'center', marginBottom: '32px' },
  logoText: { fontSize: '28px', fontWeight: 'bold', color: '#00d4aa', letterSpacing: '4px' },
  logoSub: { fontSize: '11px', color: '#4a6fa5', letterSpacing: '2px', marginTop: '4px' },
  label: { display: 'block', fontSize: '11px', color: '#4a6fa5', letterSpacing: '1px', marginBottom: '6px', textTransform: 'uppercase' },
  input: {
    width: '100%', padding: '10px 14px', background: '#0a0e1a',
    border: '1px solid #1e3a5f', borderRadius: '4px', color: '#e0e0e0',
    fontSize: '14px', fontFamily: 'Courier New, monospace', outline: 'none',
    transition: 'border-color 0.2s'
  },
  fieldGroup: { marginBottom: '20px' },
  btn: {
    width: '100%', padding: '12px', background: '#00d4aa',
    border: 'none', borderRadius: '4px', color: '#0a0e1a',
    fontSize: '14px', fontWeight: 'bold', letterSpacing: '2px',
    cursor: 'pointer', fontFamily: 'Courier New, monospace', transition: 'background 0.2s'
  },
  error: { color: '#ff4757', fontSize: '12px', marginTop: '12px', textAlign: 'center' },
  divider: { borderColor: '#1e3a5f', margin: '24px 0' },
  hint: { fontSize: '11px', color: '#4a6fa5', textAlign: 'center' }
};

export default function LoginPage({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.login(username, password);
      onLogin(res.user, res.token);
    } catch (err) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.logo}>
          <div style={styles.logoText}>PANTHER</div>
          <div style={styles.logoSub}>AI FINANCIAL INTELLIGENCE</div>
        </div>
        <form onSubmit={handleSubmit}>
          <div style={styles.fieldGroup}>
            <label style={styles.label}>Username</label>
            <input
              style={styles.input}
              type="text"
              value={username}
              onChange={e => setUsername(e.target.value)}
              placeholder="Enter username"
              autoComplete="username"
              required
            />
          </div>
          <div style={styles.fieldGroup}>
            <label style={styles.label}>Password</label>
            <input
              style={styles.input}
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="Enter password"
              autoComplete="current-password"
              required
            />
          </div>
          {error && <div style={styles.error}>{error}</div>}
          <button
            style={{ ...styles.btn, opacity: loading ? 0.7 : 1 }}
            type="submit"
            disabled={loading}
          >
            {loading ? 'AUTHENTICATING...' : 'LOGIN'}
          </button>
        </form>
        <hr style={styles.divider} />
        <div style={styles.hint}>Authorized personnel only — ved-raut.tech</div>
      </div>
    </div>
  );
}
