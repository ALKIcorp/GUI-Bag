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
  - Holds `items`, `nextId`, and `updatedAt`
- `server/data/pending.json`
  - New items are queued here
  - A background thread in the Python server flushes them into the DB

## Notes
- Additions are persisted via `/api/items`.
- Code edits are currently local-only and not persisted yet (by design for now).
