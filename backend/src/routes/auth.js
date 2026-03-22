const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const { JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password required' });
  }
  try {
    const result = await pool.query(
      'SELECT * FROM users_rbac WHERE username = $1 AND is_active = true',
      [username]
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const user = result.rows[0];
    // Simple password check (passwords stored as plain for demo, or bcrypt)
    const valid = user.password_hash === password ||
                  user.password_hash === require('crypto').createHash('sha256').update(password).digest('hex');
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const tableAccess = user.table_access || [];
    const token = jwt.sign(
      {
        user_id: user.user_id,
        username: user.username,
        full_name: user.full_name,
        role: user.role,
        department: user.department,
        table_access: tableAccess
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    res.json({
      token,
      user: {
        user_id: user.user_id,
        username: user.username,
        full_name: user.full_name,
        role: user.role,
        department: user.department,
        table_access: tableAccess
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/auth/me
router.get('/me', require('../middleware/auth').requireAuth, (req, res) => {
  res.json({ user: req.user });
});

module.exports = router;
