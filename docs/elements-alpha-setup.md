# Elements Alpha installation

## Current status

Native installation components are implemented, but automatic download remains
gated until the tested package is published and pinned. The old July
`elements-bf8e9e1e` package is not Alpha and must not be reused. This PR remains
draft; it does not yet claim a completed one-click installation.

`liquid-signet` remains the internal/protobuf identifier and directory key.
The selected network is **Elements Alpha, slot 24**, not Signet.

## Implemented flow

1. **Install & Start** retains third-party-code consent and invokes
   `StartWithL1`, not download alone. Other sidechain buttons are unchanged.
2. Native configuration is created once with owner-only permissions. Identical
   restart configuration is accepted; conflicts and symlinks are rejected rather
   than overwritten. Existing chain and wallet data is retained.
3. Only a local eCash Alphanet parent is accepted. Its configured RPC port and
   rotating cookie path are used; passwords are not copied into arguments.
4. Elements uses native `-datadir`/`-conf` arguments, not Rust-sidechain flags.
   RPC remains loopback-only; local block production and bidding stay off.
5. Authenticated genesis verification replaces TCP-only health checks.
   Health means the correct daemon answers, **not** that synchronization is done.
6. The slot-derived mnemonic initializes a descriptor wallet through native RPC.
   Existing wallets are retained. Receiving addresses are explicit; balances
   select only the pinned ECX policy asset and use exact atom amounts.
7. Archive and executable SHA-256 pins are enforced separately. Cached binaries
   are checked before reuse and process launch. Downloaded bytes do not replace
   expected pins. Unsupported platforms remain unavailable.

Managed configuration uses `bitwindow-elements-alpha.conf` under the existing
Elements data directory, with native `elements-v11` chain subdirectory.
Bootstrap peer `163.192.123.236:39444` is an Oracle relay to the existing Alpha
node, not an independent validator. Direct P2P exposes the installing computer's
IP to peers; this installer does not provide a VPN.

## Network and release identity

- Genesis: `672af009bd90bfc6527a5a9dda4c83aba0048c15cff3697d07e89a7f96fa5bcd`.
- Policy asset: `62dce3bd80dc4b0503e7ccbb3fcfa4d7adfd64b4e0cc78fa5e1754b88f1d2da4`.
- Native defaults: RPC 7065, P2P 7066; BitWindow uses its explicitly configured
  RPC port. Explicit-only transactions and 144-block withdrawals are unchanged.
- Source candidate:
  [`cad1fc1fb5695c14234c4e287cf9e47d958609e7`](https://github.com/ekulkisnek/liquid-drivechain-signet-adaptation/pull/4).

The Apple Silicon candidate was relinked from preserved frozen native objects
and real verifier archives, using static libevent 2.1.13 built for macOS 11.
It has only system dynamic-library dependencies. A deployment target does not
establish testing every macOS version. No Windows or Intel/Linux artifact is
qualified by this result.

Tested executable SHA-256:
`a54a81bf7d149fd1c4c73964ea98e33cd0e41c5c7a9183402cac5219e89cb327`.
This is an executable digest, not a downloadable archive digest.

Source PR CI's unfrozen build still fails on an unreachable-code warning.
The installer candidate uses the frozen catalogue and activation profile;
do not replace those with placeholders to produce a release.

## Qualification

Focused race-enabled Go tests cover native configuration, idempotence and
conflict preservation, parent/network rejection, cookie rotation, wrong genesis,
asset accounting, explicit receiving addresses, and artifact integrity.

Flutter dependency validation currently fails because the installed Dart SDK is
3.13.1 while the application pins 3.12.2. The application constraint was not
relaxed; Flutter qualification remains pending with its pinned SDK.

The opt-in `TestElementsNativeWalletIntegration` also ran against the real
portable daemon in an isolated temporary directory. It authenticated the local
parent bridge, created/reopened an unfunded test wallet, returned an explicit
address and zero balance, and synchronized through Alpha block 86 through the
public bootstrap relay. The isolated daemon was stopped. This used the bridge
credential-file mode, not BitWindow's parent-cookie mode. The existing live
daemon and wallet were not changed.

Test environment variables:

- `ELEMENTS_ALPHA_TEST_BINARY`: absolute path to the candidate daemon.
- `ELEMENTS_ALPHA_TEST_PARENT_PORT`: authenticated loopback parent RPC port.
- `ELEMENTS_ALPHA_TEST_PARENT_CREDENTIAL_FILE`: private parent bridge file.
- Optional `ELEMENTS_ALPHA_TEST_PEER` and `ELEMENTS_ALPHA_TEST_MIN_HEIGHT` enable
  actual synchronization qualification. Otherwise child peers are disabled.

The test uses a public test-vector mnemonic, never a funded wallet, and does
not bid, sign spend transactions, broadcast, or provision servers.

## Remaining before enabling download

1. Publish the qualified prerelease with provenance/licenses; pin its actual
   archive and executable hashes in all three chain metadata copies.
2. Exercise download/install/restart with BitWindow's parent-cookie setup;
   test Flutter UI and dependency-failure handling.
3. Replace unconditional setup refusal with supported-release/platform checks
   only after those results pass.

Validation-only startup and synchronization work without enabling enforcer
spending. BMM/withdrawal operations require authenticated mTLS integration
described in the node's `doc/drivechain-rpc-security.md`; this installer does
not downgrade it to plaintext or authorize bidding. No live routing,
existing-node settings, or reward address is changed.
