# CoinNews

Hacker News for Bitcoin, indexed straight from the chain.

- `codec/` — protocol codec (Go module, shared with bitwindow)
- `server/` — read-only ConnectRPC indexer (Go)
- `app/`, `components/`, `lib/` — Next.js SSR frontend

## Local dev

```bash
just dev          # preflight Core, build coinnewsd, start scanner + Next.js
just gen          # regenerate proto bindings (TS + Go)
just test         # codec + server tests
```

`just dev` connects to whatever Bitcoin Core you're already running for bitwindow:

- Default: signet at `http://127.0.0.1:38332` with `user:password` (matches bitwindow's
  defaults — if your Core works for bitwindow it works for coinnews).
- Override with `COINNEWS_BITCOIND_URL`, `COINNEWS_BITCOIND_USER`,
  `COINNEWS_BITCOIND_PASS`, `COINNEWS_NETWORK`.

Ports:

| service        | port  | notes                                  |
| -------------- | ----- | -------------------------------------- |
| coinnewsd      | 8080  | ConnectRPC + `/healthz`                |
| Next.js dev    | 3004  | does **not** clash with bitwindow:30301 |
| Bitcoin Core   | 38332 | signet, shared with bitwindow          |

Open <http://localhost:3004> after `just dev`.
