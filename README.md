# Alki GUI Bag

A separated React + Python stack with a tiny JSON database and a self-processing pending queue.

**What you get**
- React client (Vite + Tailwind)
- Python server (stdlib only)
- `db.json` with `nextId` auto-increment
- `pending.json` queue that auto-flushes into the DB

## Quick Start

1. Install client deps and build
```bash
cd client
npm install
npm run build
```

2. Start the Python server
```bash
cd ..
python3 server/server.py
```

3. Open the app
```bash
http://localhost:4177
```

## Dev Mode (optional)
Run the API server in one terminal:
```bash
python3 server/server.py
```

Run the client dev server in another terminal:
```bash
cd client
npm install
npm run dev
```

The client proxies `/api` to the Python server on port `4177`.

## Data Files
- `server/data/db.json`
  - Holds `schemaVersion`, `items`, `nextId`, and `updatedAt`
- `server/data/pending.json`
  - New items are queued here
  - A background thread in the Python server flushes them into the DB

## API Contract (local for now)
Base: `/api`

`GET /api/items`
- Response: `{ schemaVersion, items, updatedAt }`

`POST /api/items`
- Body: `{ name, type, html, css, js }`
- Response: `{ item }`
- Behavior: creates an item in `pending.json`, which auto-flushes into `db.json`

`PUT /api/items/:id`
- Body: any subset of `{ name, type, html, css, js }`
- Response: `{ item }`
- Behavior: updates the item in `db.json` immediately

`DELETE /api/items/:id`
- Response: `204 No Content`
- Behavior: removes the item from `db.json`

## Schema Versioning
`db.json` includes `schemaVersion` to support lightweight upgrades before we introduce real web requests.

Current schema: `1`
- `schemaVersion`: number
- `nextId`: number
- `updatedAt`: ISO8601 UTC string
- `items`: array of items

Future upgrade path (planned)
1. Add `migrations` and apply transformations in `server/server.py` when `schemaVersion` is lower than current.
2. Keep migrations idempotent and fast since this is local JSON.
3. Bump `SCHEMA_VERSION` and update `db.json` defaults in one place.

## Notes
- Additions are persisted via `/api/items`.
- Code edits are currently local-only and not persisted yet (by design for now).
