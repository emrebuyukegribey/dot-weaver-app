-- Dot Weaver schema. Applied automatically on server start (idempotent).

CREATE TABLE IF NOT EXISTS devices (
  device_id     TEXT PRIMARY KEY,
  platform      TEXT,
  app_version   TEXT,
  username      TEXT UNIQUE,
  total_stars   INTEGER NOT NULL DEFAULT 0,
  levels_played INTEGER NOT NULL DEFAULT 0,
  first_seen    TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS entitlements (
  device_id  TEXT PRIMARY KEY,
  premium    BOOLEAN NOT NULL DEFAULT false,
  source     TEXT NOT NULL DEFAULT 'admin',
  note       TEXT,
  granted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_devices_total_stars ON devices (total_stars DESC);
