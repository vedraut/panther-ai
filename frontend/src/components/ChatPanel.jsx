import React, { useState, useRef, useEffect } from 'react';
import { api } from '../services/api';

const styles = {
  panel: {
    display: 'flex', flexDirection: 'column', height: '100%',
    background: '#0a0e1a', borderLeft: '1px solid #1e3a5f'
  },
  header: {
    padding: '12px 16px', borderBottom: '1px solid #1e3a5f',
    display: 'flex', alignItems: 'center', gap: '8px', flexShrink: 0
  },
  headerDot: { width: '8px', height: '8px', background: '#00d4aa', borderRadius: '50%' },
  headerText: { fontSize: '12px', color: '#4a6fa5', letterSpacing: '1px', textTransform: 'uppercase' },
  messages: {
    flex: 1, overflowY: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: '12px'
  },
  msgUser: {
    alignSelf: 'flex-end', background: '#1e3a5f', borderRadius: '8px 8px 2px 8px',
    padding: '8px 12px', maxWidth: '80%', fontSize: '13px', color: '#e0e0e0'
  },
  msgBot: {
    alignSelf: 'flex-start', background: '#0d1221', border: '1px solid #00d4aa22',
    borderRadius: '8px 8px 8px 2px', padding: '10px 14px', maxWidth: '85%',
    fontSize: '13px', color: '#e0e0e0', lineHeight: '1.6'
  },
  msgLabel: { fontSize: '10px', color: '#4a6fa5', marginBottom: '4px', letterSpacing: '1px' },
  inputArea: {
    padding: '12px', borderTop: '1px solid #1e3a5f', display: 'flex', gap: '8px', flexShrink: 0
  },
  input: {
    flex: 1, background: '#0d1221', border: '1px solid #1e3a5f',
    borderRadius: '4px', padding: '8px 12px', color: '#e0e0e0',
    fontSize: '13px', fontFamily: 'Courier New, monospace', outline: 'none', resize: 'none'
  },
  sendBtn: {
    background: '#00d4aa', border: 'none', borderRadius: '4px',
    padding: '8px 16px', color: '#0a0e1a', fontWeight: 'bold',
    cursor: 'pointer', fontSize: '12px', fontFamily: 'Courier New, monospace',
    letterSpacing: '1px', transition: 'opacity 0.2s'
  },
  typing: { color: '#4a6fa5', fontSize: '12px', fontStyle: 'italic' },
  welcome: { textAlign: 'center', padding: '20px', color: '#4a6fa5', fontSize: '13px' }
};

const WELCOME = `Panther AI is ready. Ask me about portfolios, holdings, PnL, ESG scores, sector performance, or market catalysts.`;

export default function ChatPanel({ user }) {
  const [messages, setMessages] = useState([
    { role: 'bot', text: WELCOME }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [sessionId] = useState(`session_${user.user_id}_${Date.now()}`);
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = async () => {
    const msg = input.trim();
    if (!msg || loading) return;
    setInput('');
    setMessages(prev => [...prev, { role: 'user', text: msg }]);
    setLoading(true);
    try {
      const res = await api.chat(msg, sessionId);
      setMessages(prev => [...prev, { role: 'bot', text: res.reply }]);
    } catch (err) {
      setMessages(prev => [...prev, {
        role: 'bot',
        text: `Error: ${err.message}`,
        isError: true
      }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  };

  const suggestions = [
    "What's the total AUM?",
    "Show me top losers",
    "ESG scores for Tech sector",
    "Upcoming catalysts for AAPL"
  ];

  return (
    <div style={styles.panel}>
      <div style={styles.header}>
        <div style={styles.headerDot} />
        <span style={styles.headerText}>Panther AI Chat</span>
      </div>
      <div style={styles.messages}>
        {messages.map((m, i) => (
          <div key={i}>
            <div style={styles.msgLabel}>{m.role === 'user' ? user.full_name : 'PANTHER'}</div>
            <div style={m.role === 'user' ? styles.msgUser : {
              ...styles.msgBot,
              ...(m.isError ? { borderColor: '#ff475733', color: '#ff4757' } : {})
            }}>
              {m.text}
            </div>
          </div>
        ))}
        {loading && (
          <div>
            <div style={styles.msgLabel}>PANTHER</div>
            <div style={styles.msgBot}>
              <span style={styles.typing}>Thinking...</span>
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      {messages.length <= 1 && (
        <div style={{ padding: '0 12px 8px', display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
          {suggestions.map(s => (
            <button key={s} onClick={() => setInput(s)} style={{
              background: 'none', border: '1px solid #1e3a5f', color: '#4a6fa5',
              padding: '4px 10px', borderRadius: '12px', cursor: 'pointer',
              fontSize: '11px', fontFamily: 'Courier New, monospace'
            }}>{s}</button>
          ))}
        </div>
      )}

      <div style={styles.inputArea}>
        <textarea
          style={styles.input}
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Ask Panther anything..."
          rows={2}
        />
        <button
          style={{ ...styles.sendBtn, opacity: loading ? 0.5 : 1 }}
          onClick={sendMessage}
          disabled={loading}
        >
          SEND
        </button>
      </div>
    </div>
  );
}
