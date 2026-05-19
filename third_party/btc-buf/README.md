# `btc-buf`

> The last goddamn time I'm coding up a RPC client for Bitcoin Core.

`btc-buf` is a lightweight wrapper that sits in front of a Bitcoin Core node,
and serves its API over [Connect](https://connectrpc.com/) and gRPC. It's
intended to follow best-practice Connect standards, and make it easy to consume
the Bitcoin Core API in any language.

This project was created so that I could scratch an itch I've been having for
some time, and finally get an opportunity to play with the
[Buf Schema Registry](https://docs.buf.build/bsr/introduction).

Currently only a very small set of RPCs are implemented, and it's very much
tailored to the needs of the author.

## Installing

Build from source. If you don't know how to do that, you probably shouldn't use
this.

Also available as a Docker image:  
[`barebitcoin/btc-buf`](https://hub.docker.com/repository/docker/barebitcoin/btc-buf/general).

## Running

```bash
$ btc-buf -h
Usage:
  btc-buf [OPTIONS]

Application Options:
      --listen=            interface:port for server (default: localhost:5080)
      --logging.json       log to JSON format (default human readable)

bitcoind:
      --bitcoind.user=
      --bitcoind.pass=
      --bitcoind.passfile= if set, reads password from this file
      --bitcoind.host=     host:port to connect to Bitcoin Core on. Inferred from network if not set.
      --bitcoind.cookie    Read cookie data from the data directory. Not compatible with user and pass options.
      --bitcoind.network=  Network Bitcoin Core is running on. Only used to infer other parameters if not set. (default: regtest)
```

## Consuming

The API is available on the
[Buf Schema Registry](https://buf.build/bitcoin/bitcoind/assets/main).

```bash
# ENDPOINT should be set to the place where you're running this.
$ buf curl --schema buf.build/bitcoin/bitcoind $ENDPOINT/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlockchainInfo
```

## Ideas

- Auth. Would macaroons make sense? Could expose access to certain parts of the
  API. Read-only, for example. Could even expose the node publicly, with that
  enabled?
- Only expose _some_ APIs over the Connect interface. Lower the attack surface
  for what can go wrong.
- Add metrics for increased insights into what's going on with your Bitcoin Core
  node.
- Transport layer security. Easily serve Bitcoin Core with SSL!
