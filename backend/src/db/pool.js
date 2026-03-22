const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'findata_db',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'finai_data',
  user: process.env.DB_USER || 'finai',
  password: process.env.DB_PASSWORD || 'FinAI2026Demo',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Unexpected pg pool error', err);
});

module.exports = pool;
