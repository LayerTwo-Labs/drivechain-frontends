# Elements Alpha installation

## Current status

One-click native installation is enabled for Apple Silicon with a local eCash
Alphanet parent and an initialized BitWindow wallet. The tested Apple Silicon package
is published as `elements-alpha-cad1fc1fb-macos-arm64`; all three JSON metadata
copies pin archive SHA256 `fa3b818bd24485f370067ba1d1b8266605fb61d6333b726eb1da5affe5aa15d9`
and the executable digest below. Public retrieval reproduced both hashes. The old July
`elements-bf8e9e1e` package is not Alpha and must not be reused. Other platforms
remain unavailable rather than falling back to that package.

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
8. Validation-only Elements startup depends on the parent, not the enforcer.
   Reconnecting to an already-running managed node also initializes its wallet.

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

Flutter 3.44.8 with pinned Dart 3.12.2 was bootstrapped from the official tag.
Dependency resolution and focused analysis pass. All 17 sidechain table tests
pass, including third-party consent followed by the managed start call. This
widget test mocks the backend; it does not prove full-stack installation.

The opt-in `TestElementsNativeWalletIntegration` also ran against the real
portable daemon in an isolated temporary directory. It authenticated the local
parent bridge, created/reopened an unfunded test wallet, returned an explicit
address and zero balance, and synchronized through Alpha block 86 through the
public bootstrap relay. A second run used the actual managed configuration
installer with a temporary cookie-authenticated, read-only relay to the real
parent, then restarted the same data directory and reopened its wallet with
the rotated child cookie (42.41 seconds). The relay translates authentication,
not chain data; it is test-only, not an installed service. Initial relay tests
failed because its allowlist omitted startup RPCs; the corrected run passed.
The existing live daemon, parent credentials and wallet were not changed.

`TestElementsNativeDownloadExtraction` passed using a local HTTP ZIP containing
the real candidate: archive verification, extraction, executable verification
and execution of `-version`. This does not qualify a public release URL or the
full BitWindow UI/StartWithL1 path by itself.

`TestElementsPublishedOneClickInstall` passed in 24.259 seconds with the public
release URL and an empty install directory: `StartWithL1` downloaded and verified
the archive/executable, started the actual native daemon with managed parent
cookie configuration, verified Alpha genesis, created an unfunded explicit-address
wallet, adopted the running connection, and preserved address ownership across
`RestartDaemon`. No enforcer was configured. The parent was already running and
accessed through an ephemeral read-only authentication relay; fresh parent
download/IBD and a full graphical end-to-end session are not covered by this test.
The Flutter metadata test verifies that fallback and bundled registry entries
select the same native release and parent-only dependency.

Test environment variables:

- `ELEMENTS_ALPHA_TEST_BINARY`: absolute path to the candidate daemon.
- `ELEMENTS_ALPHA_TEST_PARENT_PORT`: authenticated loopback parent RPC port.
- `ELEMENTS_ALPHA_TEST_PARENT_CREDENTIAL_FILE`: private parent bridge file.
- Alternatively `ELEMENTS_ALPHA_TEST_PARENT_COOKIE`: real parent cookie path.
- Optional `ELEMENTS_ALPHA_TEST_COOKIE_PROXY=1` uses the credential file through
  an ephemeral read-only cookie relay to exercise managed cookie configuration.
- Optional `ELEMENTS_ALPHA_TEST_PEER` and `ELEMENTS_ALPHA_TEST_MIN_HEIGHT` enable
  actual synchronization qualification. Otherwise child peers are disabled.
- `ELEMENTS_ALPHA_TEST_INSTALL=1` enables the public-download orchestration test
  in the root Go package, using the parent port and credential-file variables.

The test uses a public test-vector mnemonic, never a funded wallet, and does
not bid, sign spend transactions, broadcast, or provision servers.

## Scope and limitations

The qualified path is a fresh Apple Silicon Elements installation. Existing
custom metadata selecting the obsolete binary is refused; it is not silently
migrated, and existing chain/wallet directories must not be deleted. Release
publication does not establish clean-source reproducibility, notarization,
cross-platform support, or successful testing on every macOS version.

Validation-only startup and synchronization work without enabling enforcer
spending. BMM/withdrawal operations require authenticated mTLS integration
described in the node's `doc/drivechain-rpc-security.md`; this installer does
not downgrade it to plaintext or authorize bidding. No live routing,
existing-node settings, or reward address is changed.
