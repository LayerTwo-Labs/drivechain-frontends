# fulcrum-proxy

Serves an eCash node's JSON-RPC to Fulcrum. Fulcrum reads a node as Bitcoin
Core only when its user agent starts with `/Satoshi:`. The proxy changes
`/eCash Satoshi:` to `/Satoshi:` in the `getnetworkinfo` reply, and passes
every other call through unchanged.

```sh
just build
bin/fulcrum-proxy --listen 127.0.0.1:18312 --upstream http://127.0.0.1:18302
```

Set `bitcoind = 127.0.0.1:18312` in `fulcrum.conf`. Keep `rpccookie`; the proxy
forwards the auth header.
