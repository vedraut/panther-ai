const express = require('express');
const fetch = require('node-fetch');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

const N8N_WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || 'http://n8n:5678/webhook/panther/chat';

// POST /api/chat — forward to N8N which calls Moonshot
router.post('/', requireAuth, async (req, res) => {
  const { message, session_id } = req.body;
  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }

  try {
    const payload = {
      message,
      session_id: session_id || `session_${req.user.user_id}_${Date.now()}`,
      user: {
        user_id: req.user.user_id,
        username: req.user.username,
        full_name: req.user.full_name,
        role: req.user.role,
        department: req.user.department,
        table_access: req.user.table_access
      },
      timestamp: new Date().toISOString()
    };

    const response = await fetch(N8N_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
      timeout: 30000
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('N8N webhook error:', response.status, errText);
      return res.status(502).json({ error: 'Chat service unavailable', detail: errText });
    }

    const data = await response.json();
    res.json({
      reply: data.reply || data.output || data.message || data.text || JSON.stringify(data),
      session_id: payload.session_id
    });
  } catch (err) {
    console.error('Chat route error:', err);
    if (err.type === 'request-timeout' || err.code === 'ETIMEDOUT') {
      return res.status(504).json({ error: 'Chat service timeout' });
    }
    res.status(500).json({ error: 'Chat service error', detail: err.message });
  }
});

module.exports = router;
