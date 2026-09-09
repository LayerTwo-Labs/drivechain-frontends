# Remote enforcer

Import [Caddyfile](Caddyfile) inside the `seed.alpha.ecash.eu.com` site block.
The enforcer must listen on `127.0.0.1:50051`.
The public endpoint is `https://seed.alpha.ecash.eu.com/enforcer`.

The proxy permits validator reads, subscriptions, and health checks.
It blocks daemon control, wallet methods, block production, mining, and reflection.
Keep its method list equal to `enforcerproxy.validatorPath`.

1. Save a copy of the server configuration.
2. Check the complete configuration with `caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile`.
3. Reload Caddy with `systemctl reload caddy`.
4. Test `GetChainTip` and validator health through HTTPS.

The local orchestrator supplies a loopback HTTP/2 endpoint to each sidechain daemon.
It checks the server TLS certificate and forwards gRPC trailers and subscriptions.
BitWindow supplies the L1 wallet through Electrum.
