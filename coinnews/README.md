# CoinNews

Hacker News for Bitcoin, indexed straight from the chain.

- `codec/` — protocol codec (Go module, shared with bitwindow)
- `server/` — read-only ConnectRPC indexer (Go)
- `app/`, `components/`, `lib/` — Next.js SSR frontend

## Local dev

```bash
just gen          # regenerate proto bindings (TS + Go)
just test         # server tests
just run          # build + run the server, then bun dev
```

The frontend points at `API_BASE_URL` (server-side) / `NEXT_PUBLIC_API_CLIENT_BASE_URL` (browser).
Default points at `http://localhost:8080` to match the server's default listen address.
