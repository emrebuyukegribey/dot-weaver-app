const path = require('path');
const express = require('express');
const { pool, initDb } = require('./db');

const app = express();
app.use(express.json({ limit: '64kb' }));

const PORT = parseInt(process.env.PORT || '8080', 10);
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || '';
// Qovya panel poller credential — separate from ADMIN_TOKEN so the panel
// never holds the admin credential. Empty = panel endpoint disabled.
const PANEL_KEY = process.env.PANEL_KEY || '';

// ---- helpers ----------------------------------------------------------------

function randomUsername() {
  return `Weaver${Math.floor(1000 + Math.random() * 9000)}`;
}

/** Upsert a device row, generating a unique username on first insert. */
async function upsertDevice({ deviceId, platform, appVersion, totalStars, levelsPlayed }) {
  for (let attempt = 0; attempt < 6; attempt++) {
    try {
      const res = await pool.query(
        `INSERT INTO devices (device_id, platform, app_version, username, total_stars, levels_played, last_seen)
         VALUES ($1, $2, $3, $4, $5, $6, now())
         ON CONFLICT (device_id) DO UPDATE SET
           platform      = COALESCE(EXCLUDED.platform, devices.platform),
           app_version   = COALESCE(EXCLUDED.app_version, devices.app_version),
           total_stars   = GREATEST(devices.total_stars, EXCLUDED.total_stars),
           levels_played = GREATEST(devices.levels_played, EXCLUDED.levels_played),
           last_seen     = now()
         RETURNING username`,
        [deviceId, platform || null, appVersion || null, randomUsername(),
         Number(totalStars) || 0, Number(levelsPlayed) || 0]
      );
      return res.rows[0].username;
    } catch (e) {
      if (e.code === '23505') continue; // username collision on insert -> retry
      throw e;
    }
  }
  throw new Error('could not generate a unique username');
}

async function getPremium(deviceId) {
  const r = await pool.query('SELECT premium FROM entitlements WHERE device_id = $1', [deviceId]);
  return r.rows[0]?.premium === true;
}

function requireAdmin(req, res, next) {
  const header = req.get('x-admin-token') || (req.get('authorization') || '').replace(/^Bearer\s+/i, '');
  if (!ADMIN_TOKEN || header !== ADMIN_TOKEN) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  next();
}

function requirePanel(req, res, next) {
  if (!PANEL_KEY || req.get('x-panel-key') !== PANEL_KEY) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  next();
}

// ---- public API -------------------------------------------------------------

app.get('/health', (_req, res) => res.json({ ok: true }));

// Heartbeat: report stats + learn entitlement. The single call the app makes.
app.post('/api/v1/devices/heartbeat', async (req, res) => {
  try {
    const { deviceId } = req.body || {};
    if (!deviceId || typeof deviceId !== 'string') {
      return res.status(400).json({ error: 'deviceId required' });
    }
    const username = await upsertDevice(req.body);
    const premium = await getPremium(deviceId);
    res.json({ premium, username });
  } catch (e) {
    console.error('heartbeat error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

app.get('/api/v1/entitlements/:deviceId', async (req, res) => {
  try {
    res.json({ premium: await getPremium(req.params.deviceId) });
  } catch (e) {
    res.status(500).json({ error: 'server error' });
  }
});

// Global leaderboard by total stars. `deviceId` (optional) marks the caller's
// row and returns their rank. Device IDs of others are never exposed.
app.get('/api/v1/leaderboard', async (req, res) => {
  try {
    const limit = Math.min(parseInt(req.query.limit || '100', 10) || 100, 200);
    const deviceId = req.query.deviceId || null;

    const top = await pool.query(
      `SELECT username, total_stars, device_id
         FROM devices
        WHERE username IS NOT NULL
        ORDER BY total_stars DESC, first_seen ASC
        LIMIT $1`,
      [limit]
    );

    let you = null;
    if (deviceId) {
      const me = await pool.query(
        'SELECT username, total_stars FROM devices WHERE device_id = $1',
        [deviceId]
      );
      if (me.rowCount > 0) {
        const rank = await pool.query(
          'SELECT count(*) + 1 AS rank FROM devices WHERE total_stars > $1',
          [me.rows[0].total_stars]
        );
        you = {
          rank: Number(rank.rows[0].rank),
          username: me.rows[0].username,
          totalStars: me.rows[0].total_stars,
        };
      }
    }

    res.json({
      top: top.rows.map((r, i) => ({
        rank: i + 1,
        username: r.username,
        totalStars: r.total_stars,
        isYou: deviceId != null && r.device_id === deviceId,
      })),
      you,
    });
  } catch (e) {
    console.error('leaderboard error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

// Rename: 3-16 chars, letters/digits/underscore, unique.
app.put('/api/v1/devices/:deviceId/username', async (req, res) => {
  try {
    const name = (req.body?.username || '').trim();
    if (!/^[A-Za-z0-9_]{3,16}$/.test(name)) {
      return res.status(400).json({ error: 'invalid', message: '3-16 letters, digits or _' });
    }
    const r = await pool.query(
      'UPDATE devices SET username = $1 WHERE device_id = $2 RETURNING username',
      [name, req.params.deviceId]
    );
    if (r.rowCount === 0) return res.status(404).json({ error: 'not found' });
    res.json({ username: r.rows[0].username });
  } catch (e) {
    if (e.code === '23505') return res.status(409).json({ error: 'taken' });
    console.error('rename error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

// ---- admin API (token protected) --------------------------------------------

app.get('/api/v1/admin/stats', requireAdmin, async (_req, res) => {
  try {
    const [totals, active, plays, premium, top] = await Promise.all([
      pool.query('SELECT count(*)::int AS n FROM devices'),
      pool.query("SELECT count(*)::int AS n FROM devices WHERE last_seen > now() - interval '1 day'"),
      pool.query('SELECT COALESCE(sum(levels_played), 0)::int AS n FROM devices'),
      pool.query('SELECT count(*)::int AS n FROM entitlements WHERE premium'),
      pool.query(
        `SELECT d.username, d.total_stars, d.device_id,
                COALESCE(e.premium, false) AS premium
           FROM devices d
           LEFT JOIN entitlements e ON e.device_id = d.device_id
          ORDER BY d.total_stars DESC, d.last_seen DESC
          LIMIT 25`
      ),
    ]);
    res.json({
      totalDevices: totals.rows[0].n,
      activeToday: active.rows[0].n,
      totalPlays: plays.rows[0].n,
      premiumCount: premium.rows[0].n,
      topPlayers: top.rows,
    });
  } catch (e) {
    console.error('stats error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

// ---- Qovya panel summary (X-Panel-Key protected, read-only) ------------------

app.get('/api/v1/panel/summary', requirePanel, async (_req, res) => {
  try {
    // "Today" buckets use Istanbul local midnight, same as the other apps.
    const dayStart =
      "(date_trunc('day', now() AT TIME ZONE 'Europe/Istanbul') AT TIME ZONE 'Europe/Istanbul')";
    const [totals, newToday, dau, activeNow, premiumToday, premium, plays] = await Promise.all([
      pool.query('SELECT count(*)::int AS n FROM devices'),
      pool.query(`SELECT count(*)::int AS n FROM devices WHERE first_seen >= ${dayStart}`),
      pool.query(`SELECT count(*)::int AS n FROM devices WHERE last_seen >= ${dayStart}`),
      pool.query("SELECT count(*)::int AS n FROM devices WHERE last_seen > now() - interval '15 minutes'"),
      pool.query(`SELECT count(*)::int AS n FROM entitlements WHERE premium AND granted_at >= ${dayStart}`),
      pool.query('SELECT count(*)::int AS n FROM entitlements WHERE premium'),
      pool.query('SELECT COALESCE(sum(levels_played), 0)::int AS n FROM devices'),
    ]);
    res.json({
      app: 'dotweaver',
      users_total: totals.rows[0].n,
      users_today: newToday.rows[0].n,
      dau: dau.rows[0].n,
      active_now: activeNow.rows[0].n,
      purchases_today: premiumToday.rows[0].n,
      revenue_today: 0,
      extras: [
        { label: 'Premium toplam', value: premium.rows[0].n },
        { label: 'Toplam oynanış', value: plays.rows[0].n },
      ],
      alerts: [],
    });
  } catch (e) {
    console.error('panel summary error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

// Look up a single device + its entitlement (for the grant form).
app.get('/api/v1/admin/devices/:deviceId', requireAdmin, async (req, res) => {
  try {
    const r = await pool.query(
      `SELECT d.*, COALESCE(e.premium, false) AS premium, e.note, e.granted_at
         FROM devices d LEFT JOIN entitlements e ON e.device_id = d.device_id
        WHERE d.device_id = $1`,
      [req.params.deviceId]
    );
    if (r.rowCount === 0) return res.status(404).json({ error: 'not found' });
    res.json(r.rows[0]);
  } catch (e) {
    res.status(500).json({ error: 'server error' });
  }
});

// Grant / revoke premium for a device id.
app.post('/api/v1/admin/entitlements', requireAdmin, async (req, res) => {
  try {
    const { deviceId, premium, note } = req.body || {};
    if (!deviceId) return res.status(400).json({ error: 'deviceId required' });
    await pool.query(
      `INSERT INTO entitlements (device_id, premium, source, note)
       VALUES ($1, $2, 'admin', $3)
       ON CONFLICT (device_id) DO UPDATE SET
         premium = EXCLUDED.premium, source = 'admin',
         note = EXCLUDED.note, granted_at = now()`,
      [deviceId, premium === true, note || null]
    );
    res.json({ ok: true, deviceId, premium: premium === true });
  } catch (e) {
    console.error('grant error:', e.message);
    res.status(500).json({ error: 'server error' });
  }
});

// ---- admin web panel --------------------------------------------------------

app.use(express.static(path.join(__dirname, '..', 'public')));
app.get('/admin', (_req, res) => res.sendFile(path.join(__dirname, '..', 'public', 'admin.html')));

// ---- legal pages (public) ---------------------------------------------------
app.get('/privacy', (_req, res) => res.sendFile(path.join(__dirname, '..', 'public', 'privacy.html')));
app.get('/terms', (_req, res) => res.sendFile(path.join(__dirname, '..', 'public', 'terms.html')));
app.get('/support', (_req, res) => res.sendFile(path.join(__dirname, '..', 'public', 'support.html')));

// ---- start ------------------------------------------------------------------

initDb()
  .then(() => app.listen(PORT, '0.0.0.0', () => console.log(`[api] listening on 0.0.0.0:${PORT}`)))
  .catch((e) => {
    console.error('fatal: db init failed', e);
    process.exit(1);
  });
