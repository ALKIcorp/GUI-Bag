# Alki GUI Bag

A separated React + Python stack with a tiny JSON database and a self-processing pending queue.

**What you get**
- React client (Vite + Tailwind)
- Python server (stdlib only)
- `db.json` with `nextId` auto-increment
- `pending.json` queue that auto-flushes into the DB

## Quick Start with Script (Recommended)

This script automates starting both the Python backend server and the Vite frontend development server, then automatically opens the application in your browser.

**Prerequisites:**
*   Node.js and npm installed (for `npm install` and `npm run build/dev`)
*   Python 3 installed

**Steps:**

1.  **Ensure client dependencies are installed and built:**
    If you haven't already, run these commands once from the project root:
    ```bash
    cd client
    npm install
    npm run build
    cd ..
    ```
2.  **Run the start script:**
    From the project's root directory, make the script executable and run it:
    ```bash
    chmod +x start.sh
    ./start.sh
    ```
    This will launch both servers and open your browser to `http://localhost:5173`. Press `Ctrl+C` in the terminal running the script to stop both servers.

## Manual Setup (Advanced/Debugging)

If you prefer to run the client and server processes separately, or for debugging purposes, follow these steps from the project's root directory:

1.  **Set up the client:**
    ```bash
    cd client
    npm install
    npm run build # Or npm run dev for development server
    cd ..
    ```
2.  **Start the Python server:**
    ```bash
    python3 server/server.py
    ```
    (Leave this running in a separate terminal)

3.  **Start the client (if not using `npm run dev`):**
    If you built the client (`npm run build`), the Python server at `http://localhost:4177` will serve the static files.

    If you're using the Vite development server (`npm run dev`), run it in *another* separate terminal:
    ```bash
    cd client
    npm run dev
    ```
    (The client will typically be accessible at `http://localhost:5173` and will proxy `/api` calls to the Python server running on port `4177`.)

4.  **Open in browser:**
    If using `npm run build` and `python3 server/server.py`: Go to `http://localhost:4177`
    If using `npm run dev`: Go to the URL provided by Vite (typically `http://localhost:5173`)

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
