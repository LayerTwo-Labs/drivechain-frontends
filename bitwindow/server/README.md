Server application for providing APIs to a Drivechain frontend.

Dependencies:

1.  [`just`](https://just.systems/man/en/chapter_4.html?highlight=brew#packages)
1.  [Go](https://go.dev/doc/install)
1.  [Rust via `rustup`](https://rustup.rs/)
1.  [`buf`](https://buf.build/docs/installation)

Building and running:

```bash
$ just build

# This assumes you're running drivechaind in signet mode.
# A modified version of bitcoin core where the only change
# is 60 second blocktimes. You can also start this with:
# $ docker compose up mainchain
# Or download directly from https://github.com/barebitcoin/bitcoin-patched
#
$ drivechaind \
  -rpcuser=user \
  -rpcpassword=password \
  -server \
  -signet \
  -signetblocktime=60 \
  -signetchallenge=00141f61d57873d70d28bd28b3c9f9d6bf818b5a0d6a \
  -listen

#
# Then, start the bip300301-enforcer
$ ./enforcer/bin/bip300301-enforcer \
  --node-rpc-password=password \
  --node-rpc-user=user \
  --node-rpc-port=38332

# Finally, start the server.
# We're connecting to a public Electrum server, running
# /without/ SSL.
#
# The same Electrum server also powers the mempool instance
# at https://drivechain.ngu-tek.no.
$ ./bin/bitwindowd \
  --electrum.host=drivechain.live:50001 \
  --electrum.no-ssl \
  --bitcoincore.rpcuser=user \
  --bitcoincore.rpcpassword=password \
  --bitcoincore.host=localhost:8332
```

# Architecture

```mermaid
graph TD;
    A[Flutter-based Frontend] -->|Connect/gRPC| B[Go Server];
    B -->|Unspecified Protocol| C[CUSF Enforcer];
    C -->|`invalidateblock` RPC|D;
    B -->|Connect/gRPC via btc-buf proxy, \nZMQ via either raw conn or btc-buf| D[Bitcoin Core Node];
    B -.->|Shells out to| E[bdk-cli];
```

- All wallet functionality is handled by `bdk-cli`
- Bitcoin Core is strictly used for reading chain data. Wallet is entirely
  untouched

Pros:

- Devs are way more proficient in Go than Rust
- Availability of [Connect](https://github.com/connectrpc/connect-go/) for Go.
  Makes it _really_ simple to spin up a server that supports both gRPC and REST.
- Availability of strongly typed Bitcoin Core RPC-system through
  [`btc-buf`](https://github.com/barebitcoin/btc-buf)

Cons:

- Shelling out to BDK sounds brittle. Does it contain all the functionality we
  need? On the other hand, perhaps this is a nice barrier of sorts. BDK is a big
  beast...
- Have to pass in the raw descriptor (which contains the xpriv) for each
  command. Is this OK?

PoC: have been able to generate an address, receive funds to it, sync and print
the updated balance. This was on testnet, with a public Electrum node hosted by
Blockstream at `electrum.blockstream.info:60002`. Code for this is in
`server/main.go`.

Further validations that need to happen before we're confident that this works:

1. ~~Verify we're able to send. This shouldn't be too hard, just haven't gotten
   around to it.~~
1. Verify we're able to connect to our own signet network (this needs to be
   created!). Will `bdk-cli` crash if the signet network has other parameters?
1. ~~Verify we're able to modify `btc-buf` to run in-memory. Should be easy
   enough. If not, we'll just use `rpcclient` from `btcd`.~~

# Other alternatives considered

## Writing this in Rust

Pros:

- Raw access to BDK

Cons:

- Rust is really complex

```mermaid
graph TD;
    A[Flutter-based Frontend] -->|Connect/gRPC| B["Server (Rust with BDK)"];
    B -->|JSON-RPC + ZMQ| C[Bitcoin Core Node];
    B -->|Unspecified Protocol| D[CUSF Enforcer];
```

## Go-based BDK FFI

There's no official FFI bindings for Go. Can use
[3rd party Go bindings](https://github.com/NordSecurity/uniffi-bindgen-go) for
Uniffi (which is what powers the BDK FFI). Haven't looked into this. Might not
be needed at all.
