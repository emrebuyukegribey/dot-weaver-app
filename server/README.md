# Dot Weaver backend

Tiny Node/Express + PostgreSQL service for device heartbeats, premium entitlements,
a (future) leaderboard, and a token-protected admin web panel. Designed to run in
Docker next to the existing `predgo` deployment on DigitalOcean.

## Run locally

```bash
cd server
cp .env.example .env          # set ADMIN_TOKEN + a DB password
docker compose up --build
```

- API: http://127.0.0.1:8090
- Admin panel: http://127.0.0.1:8090/admin  (enter your ADMIN_TOKEN to connect)
- Health: http://127.0.0.1:8090/health

## Quick smoke test

```bash
# report a device + read its entitlement
curl -s localhost:8090/api/v1/devices/heartbeat \
  -H 'content-type: application/json' \
  -d '{"deviceId":"test-123","platform":"android","appVersion":"1.0.0","totalStars":42,"levelsPlayed":7}'

# grant premium (admin)
curl -s localhost:8090/api/v1/admin/entitlements \
  -H "x-admin-token: $ADMIN_TOKEN" -H 'content-type: application/json' \
  -d '{"deviceId":"test-123","premium":true,"note":"comp"}'

# heartbeat again -> {"premium":true,...}
```

## API

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/v1/devices/heartbeat` | – | Upsert device + stats; returns `{premium, username}` |
| GET  | `/api/v1/entitlements/:deviceId` | – | `{premium}` |
| GET  | `/api/v1/admin/stats` | admin | counts + top players |
| GET  | `/api/v1/admin/devices/:deviceId` | admin | device + entitlement |
| POST | `/api/v1/admin/entitlements` | admin | `{deviceId, premium, note}` grant/revoke |
| GET  | `/admin` | – (data calls need token) | admin web panel |

Admin auth: send the secret in the `x-admin-token` header (the panel does this for you).

## Deploy on the droplet

1. Copy the `server/` folder to the droplet, create `.env` with a strong `ADMIN_TOKEN`.
2. `docker compose up -d --build` (API listens on 127.0.0.1:8090).
3. Point nginx at it (see `nginx.sample.conf`) on a subdomain like `api.yourdomain.com`,
   then `certbot --nginx -d api.yourdomain.com` for HTTPS.
4. Set the app's `apiBaseUrl` (lib/config.dart) to `https://api.yourdomain.com`.
