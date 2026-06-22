const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Connection comes from DATABASE_URL, or falls back to individual PG* vars.
const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL }
    : {
        host: process.env.PGHOST || 'db',
        port: parseInt(process.env.PGPORT || '5432', 10),
        user: process.env.PGUSER || 'dotweaver',
        password: process.env.PGPASSWORD || 'dotweaver',
        database: process.env.PGDATABASE || 'dotweaver',
      }
);

async function initDb() {
  const schema = fs.readFileSync(path.join(__dirname, '..', 'db', 'schema.sql'), 'utf8');
  // Retry a few times so the API can start before Postgres is fully ready.
  for (let attempt = 1; attempt <= 10; attempt++) {
    try {
      await pool.query(schema);
      console.log('[db] schema ready');
      return;
    } catch (err) {
      console.warn(`[db] init attempt ${attempt} failed: ${err.message}`);
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
  throw new Error('Could not initialise the database after several attempts');
}

module.exports = { pool, initDb };
