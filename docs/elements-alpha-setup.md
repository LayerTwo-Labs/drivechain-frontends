# Elements Alpha download/setup

## Status

Automatic setup is **not available**. The previously advertised July
`elements-bf8e9e1e` release must not be installed as the current Alpha node.
The download and process-start paths reject it, including cached binaries,
forced downloads and restarts. This does not stop an already-running node or
delete its data. Other sidechains are unaffected.

`liquid-signet` remains the internal/protobuf identifier and directory key;
the displayed name is Elements Alpha. This is not a Signet network selection.
The retained version value identifies the withdrawn package, not a new release.

The current source candidate is
[`cad1fc1fb5695c14234c4e287cf9e47d958609e7`](https://github.com/ekulkisnek/liquid-drivechain-signet-adaptation/pull/4).
It is a source PR, not a qualified downloadable release. Do not manufacture an
asset URL or reuse an old archive hash for it.

## Native setup contract

The replacement installer must use the native Elements interface, not the
Rust sidechains' `--network`, `--rpc-addr` and `--mainchain-grpc-url` flags.
`config.ElementsAlphaOptions` now materializes the validation-only native
configuration, rejects non-Alphanet parents, non-loopback endpoints, malformed
paths and colliding ports. It does not write or overwrite existing configuration.
Startup orchestration and live parent qualification remain to be connected.
Changing a URL or setting `is_bitcoin_core` is insufficient.

For that source candidate, the network pins are:

- `-chain=elements`, chain directory `elements-v11`, slot 24.
- Genesis `672af009bd90bfc6527a5a9dda4c83aba0048c15cff3697d07e89a7f96fa5bcd`.
- Native defaults: RPC 7065, P2P 7066. Choose explicit non-conflicting ports;
  do not reuse the old metadata's 29443 as evidence of the Alpha default.
- Explicit-only transactions and 144-block withdrawals are node consensus
  rules, not settings to override in an installer.

An installer-generated configuration needs these native settings. Paths below
are placeholders, **not a ready-to-launch configuration**:

```ini
chain=elements
server=1
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcport=7065
port=7066
mainchainrpchost=127.0.0.1
mainchainrpcport=18302
mainchainrpccookiefile=/absolute/private/parent/.cookie
drivechainl1blocksync=0
drivechainbmmgrpcaddr=127.0.0.1:55051
drivechainbmmgrpcurl=/absolute/private/bin/grpcurl
drivechainbmmgrpcca=/absolute/private/tls/ca.pem
drivechainbmmgrpccert=/absolute/private/tls/elements-client.pem
drivechainbmmgrpckey=/absolute/private/tls/elements-client-key.pem
drivechainbmmgrpcauthority=enforcer.local
```

Derive the parent endpoint and cookie path from the selected, validated eCash
Alphanet node; 18302 is only a reference default. Check the parent network,
genesis/checkpoint and txindex before launching. Refuse other parent networks.
Use the native rotating cookie authentication, with owner-only files and the
node's no-symlink checks. Do not copy RPC passwords into command lines or logs.

The enforcer connection needs the authenticated local mTLS proxy, private
certificates, verified `grpcurl`, startup supervision and certificate renewal.
See the source candidate's `doc/drivechain-rpc-security.md` and
`contrib/drivechain-mtls/`. The current native authenticated subprocess path is
unsupported on Windows; leave Windows unavailable until implemented and tested.
Never silently fall back to plaintext or disable TLS verification.

The native `sidechain/elements.Node` is now selected by the generic node factory.
It reloads cookie credentials on every request, uses the `elements-v11/.cookie`
path, and resolves asset labels to the pinned Alpha policy asset before counting
balances in exact atoms. It does not expose the Rust BMM interface. Its
`VerifyAlpha` method checks the authenticated genesis; this is a building block,
not yet a startup-readiness hook. A listening TCP port alone is not readiness:
parent replay and synchronization must also be checked.

Source inspection distinguishes validation from bidding: `drivechainl1blocksync=0`
disables local block production, while parent-state revalidation continues.
The mTLS path above must be qualified for enforcer-dependent operations; a
validation-only clean-install test must establish which operations it needs.

Current release blockers independently checked:

- Candidate PR4 macOS CI fails at `ecx_exchange_state.cpp:1155` because the
  unfrozen build hits `-Werror,-Wunreachable-code`. Simply suppressing the warning
  would not compile in the frozen catalogue and verifier used by the live node.
- The existing Mac executable depends on Homebrew libevent dylibs at absolute
  paths. Copying that executable alone is not a portable release package.
- No current Alpha download release exists; July assets remain withdrawn.

Automated qualification added here covers configuration rejection, missing and
rotated RPC cookies, wrong genesis, label-aware ECX accounting, fractional-atom
rejection and malformed balance responses. These are local unit/HTTP tests,
not evidence of a completed native installation.

Downloading must not turn on BMM spending, install a reward address, expose RPC,
or change the machine's default route. A normal direct P2P connection exposes
the machine's IP to peers; downloading a node does not provide IP protection.

## Requirements before enabling the button

1. Publish reproducible Alpha packages from reviewed source. Pin each supported
   platform's immutable URL, executable layout, SHA-256 and size in all three
   current `chains_config.json` copies. Include/verify required helper binaries.
2. Implement the native configuration, parent cookie and supervised enforcer
   mTLS integration above. Connect the authenticated Elements RPC adapter.
3. Verify clean install and restart against Alpha, wrong-network refusal,
   corrupt archives, missing/expired credentials, occupied ports, cached old
   binaries and failed dependencies. Never mark a TCP-only listener ready.
4. Remove `checkElementsSetup` and its temporary refusal tests only with that
   tested integration. Updating release metadata alone must not enable startup.

This draft does not claim end-to-end setup, Windows support, live-node changes,
or a new Alpha binary release.
