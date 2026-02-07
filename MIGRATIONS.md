# Migrations

Lightweight migration notes for `server/data/db.json`.

## Current Schema
- `schemaVersion`: `1`
- `nextId`: number
- `updatedAt`: ISO8601 UTC string
- `items`: array of items

## How Migrations Will Work
- `server/server.py` will read `schemaVersion`.
- If it is lower than the current `SCHEMA_VERSION`, it will apply in-order transforms.
- Each migration should be idempotent and safe for local JSON.

## Planned Migrations
- `v2`: add `deletedAt` for soft deletes
- `v3`: add `tags` to items
