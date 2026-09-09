# Remote enforcer support

All five octobocto forks can run a local sidechain daemon against a remote enforcer.
The daemon keeps its sidechain wallet, chain data, mempool, and P2P connections locally.
The remote validator supplies mainchain data. The local daemon trusts that data.

| Daemon | Release / commit | Enforcer flags |
| --- | --- | --- |
| Thunder | 0.17.10 / `1b5edc5` | `--mainchain-grpc-url=http://HOST:50051` |
| BitNames | 0.17.6 / `3770fd1` | `--mainchain-grpc-host=HOST --mainchain-grpc-port=50051` |
| BitAssets | 0.16.7 / `f66c1f1` | `--mainchain-grpc-host=HOST --mainchain-grpc-port=50051` |
| Photon | 0.17.5 / `586cb24` | `--mainchain-grpc-url=http://HOST:50051` |
| CoinShift | 0.14.1 / `a832212` | `--mainchain-grpc-url=http://HOST:50051` |

The validator and health services are necessary. The enforcer wallet service is optional.
Sidechain transfers and withdrawal requests use local keys.
P2P sync accepts blocks and withdrawal events without an enforcer wallet.
Another node must submit withdrawal bundles to the mainchain when the local node has no enforcer wallet.

Sources: [Thunder startup](https://github.com/octobocto/thunder-rust/blob/1b5edc5ebe5c290e2efb2815fa81bb5e4f0f78f6/app/app.rs#L168), [BitNames flags](https://github.com/octobocto/plain-bitnames/blob/3770fd1/app/cli.rs#L154), [BitAssets flags](https://github.com/octobocto/plain-bitassets/blob/f66c1f1/app/cli.rs#L130), [Photon flags](https://github.com/octobocto/photon/blob/586cb24/app/cli.rs#L128), [CoinShift flags](https://github.com/octobocto/coinshift-rs/blob/a832212/app/cli.rs#L146).

Thunder accepts `connect_block` without an enforcer wallet.
The other four forks return `NoCusfMainchainWalletClient` through `Node::submit_block`.
This blocks the Go BMM engine on those forks. It does not block P2P sync.
Daemon helpers for mainchain deposits and BMM bids use the enforcer wallet.
BitWindow provides its own L1 wallet through Electrum for those payments.

CoinShift also uses parent-chain RPC for swaps.
Its configuration accepts only predefined endpoints. Signet uses `localhost:38332`; a custom remote address returns `UnsupportedL1Config`.
Sources: [BitNames block submission](https://github.com/octobocto/plain-bitnames/blob/3770fd1/lib/node/mod.rs#L680), [CoinShift configuration](https://github.com/octobocto/coinshift-rs/blob/a832212/lib/parent_chain_rpc.rs#L447).

Both modes start local sidechain daemons and use their wallet RPCs.
Full mode also starts local Core and enforcer.
Light mode uses `services.enforcer.url` from the network catalog.
The alphanet endpoint is `https://seed.alpha.ecash.eu.com/enforcer`.
The orchestrator supplies each daemon with a loopback HTTP/2 bridge to that HTTPS endpoint.
It checks validator health before daemon startup.

A mode change restarts active daemons with the selected enforcer.
A same-network endpoint update keeps the local bridge address. New requests use the updated endpoint.
After an orchestrator restart, light mode restarts adopted backends from the same install with the new bridge address.

Sidechain startup returns an error when the network has no remote validator or the daemon lacks compatible flags.
The BitWindow L1 wallet can still use Electrum on networks without a remote validator.
Core-derived sidechains and ZSide remain outside remote-enforcer support.
Truthcoin accepts the split host/port flags on signet, but its current binary has no alphanet network.
Sources: [startup](../sidechain-orchestrator/remote_enforcer.go), [daemon flags](../sidechain-orchestrator/config/sidechain_conf.go), [frontend mode](../sidechain_core/lib/config/backend_boot.dart).

The raw enforcer listener has no TLS or caller authentication.
ValidatorService includes `Stop`. WalletService includes fund transfers.
The public Caddy route permits validator reads, subscriptions, and health checks.
It blocks wallet calls and daemon control.
The raw listener stays on loopback.
See [the server configuration](../scripts/remote-enforcer/README.md).
Sources: [listener](https://github.com/octobocto/bip300301_enforcer/blob/039c8b9/app/main.rs#L444), [Stop](https://github.com/octobocto/bip300301_enforcer/blob/039c8b9/lib/server/validator/grpc.rs#L476).

BitWindow's current BMM engine reads Core mempool data for bids and replacement fees.
The remote validator does not supply those reads, so light mode disables BMM.
Automatic targets pause in light mode. Their settings and paid rounds remain intact.
Full mode resumes those targets. Stop and history remain available in both modes.

The public endpoint passed 13 checks on 2026-09-09.
These covered JSON and native gRPC reads, health, subscriptions, and seven blocked method paths.
The header sync subscription returned the same status as the local backend after header sync completed.

A fresh Thunder 0.17.10 node synced all 216 alphanet sidechain blocks through the public validator on 2026-09-09.
Both chain tips matched the seed after approximately five minutes.
This probe used an explicit IPv4 peer and no enforcer wallet.
Thunder's default DNS path rejects an IPv6 seed address on its IPv4 socket before it tries IPv4.
The [Thunder fork fix](https://github.com/octobocto/thunder-rust/pull/12) tries the next compatible seed address.
The other four forks use a literal IPv4 seed and do not share this DNS fault.

The final launch test used the patched Thunder build through `drivechaind` in light mode.
It used the normal IPv4 bind, default DNS peers, and a copy of the test chain with no saved peers.
The local daemon connected and returned 216 blocks and a zero balance through typed RPCs.
The remote enforcer reported connected; no local Core or enforcer process started.
All test processes stopped and released their ports.
