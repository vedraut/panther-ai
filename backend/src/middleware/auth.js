const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'panther-secret-2026';

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

// tableAccess: array of table names user must have access to
function requireTable(tableNames) {
  return (req, res, next) => {
    const userTables = req.user.table_access || [];
    const denied = tableNames.filter(t => !userTables.includes(t));
    if (denied.length > 0) {
      return res.status(403).json({
        error: 'Access denied',
        message: `Your role does not have access to: ${denied.join(', ')}. Please raise a ServiceNow request for elevated access.`,
        denied_tables: denied,
        servicenow_url: 'https://servicenow.ved-raut.tech/request'
      });
    }
    next();
  };
}

module.exports = { requireAuth, requireTable, JWT_SECRET };
