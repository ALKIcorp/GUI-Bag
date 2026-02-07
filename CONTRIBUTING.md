# Contributing

Thanks for helping improve Alki GUI Bag.

## Basics
- Keep changes focused and small when possible.
- Prefer plain JavaScript and stdlib Python for the server.
- Avoid adding heavy dependencies unless there is a clear need.

## Local Dev
```bash
cd client
npm install
npm run dev
```

```bash
cd ..
python3 server/server.py
```

## Code Style
- React: functional components + hooks.
- Python: keep it simple, stdlib only.
- Files: group by concern (components, hooks, data).

## Pull Requests
- Describe what changed and why.
- Include screenshots for UI changes when possible.
- If you touch the API contract, update `README.md`.
