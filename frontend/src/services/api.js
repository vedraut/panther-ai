const BASE_URL = import.meta.env.VITE_API_URL || '/api';

function getToken() {
  return localStorage.getItem('panther_token');
}

async function request(path, options = {}) {
  const token = getToken();
  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {})
    }
  });
  if (res.status === 401) {
    localStorage.removeItem('panther_token');
    localStorage.removeItem('panther_user');
    window.location.reload();
    return;
  }
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || data.message || 'Request failed');
  return data;
}

export const api = {
  login: (username, password) =>
    request('/auth/login', { method: 'POST', body: JSON.stringify({ username, password }) }),

  me: () => request('/auth/me'),

  kpi: () => request('/kpi'),
  kpiByPortfolio: () => request('/kpi/by-portfolio'),

  sectors: () => request('/sectors'),
  sectorAssetClass: () => request('/sectors/asset-class'),
  sectorEsg: () => request('/sectors/esg'),

  holdings: (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return request(`/holdings${qs ? '?' + qs : ''}`);
  },
  holdingsPnl: () => request('/holdings/pnl'),

  chat: (message, session_id) =>
    request('/chat', { method: 'POST', body: JSON.stringify({ message, session_id }) }),

  exportHoldingsCsv: () => `${BASE_URL}/export/holdings/csv`,
  exportReportPdf: () => `${BASE_URL}/export/report/pdf`
};
