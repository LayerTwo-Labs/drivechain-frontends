# Elements Blue Current installation

Bitwindow installs one versioned bundle containing the Haskell wallet, Elements
node, CLI, graphics dependencies, fonts, and the node's Haskell runtime. Windows
uses native executables; WSL is not an end-user dependency.

Download and Start reject an unfinished production manifest before downloading
or starting any node. The catalog deliberately sets `native_wallet.ready` false.
The requested BTC to ECX fork is at Bitcoin block 973,728; the current custom
Elements daemon is Betanet-only. A reviewed production child genesis, native
asset, and matching qualified platform releases are still required. No guessed
production identity or release URL is used.

## Setup

- Check the archive and wallet/node/CLI hashes. Preserve libraries and assets.
- Verify a fresh staging tree before replacing an installed version. A failed
  update preserves the previous installation. Check cached executable hashes;
  automatically reinstall a bundle if a component is missing.
- Store binaries under `assets/bin/native-wallet/liquid-signet/<version>` and
  chain data under `blue-current/<production-genesis>` inside its configured
  data folder, preserving Alpha data and settings.
- Start the node with loopback RPC and the local parent node's cookie/port.
  Require matching genesis, native asset, and Bitcoin parent before wallet setup.
- Create or load the Elements wallet through its bundled CLI, then open Blue
  Current with an owner-only connection profile containing no password.
- Bitwindow owns the node. Closing the wallet leaves it running. Repeated Start
  reuses its window; Open window reopens a closed wallet. Headless Start creates
  or loads the wallet without opening a window.

Blue Current's Elements wallet is independent of the Bitwindow starter seed.
Back it up through Blue Current's Backup & recovery. The legacy Alpha wallet
interface in Bitwindow is disabled on the production network; use Blue Current
for its wallet operations. Explicit legacy Alphanet selection retains its old
behavior. Migration 028 adds only native-wallet metadata and preserves other
configuration values.

## Release assembly

In the Blue Current source, `scripts/bundle-node-macos.py` recursively bundles
prebuilt Mach-O executables/dependencies, removes build-machine library paths,
and signs the result. It changes no consensus code. Windows/Linux node inputs
must likewise be qualified portable builds.

`scripts/combine-release.py` combines portable wallet/node directories and a
reviewed identity file into an archive plus `native-wallet.json`. Merge platform
entries into the three catalog copies and a corresponding patch migration.

The metadata has OS-keyed `binary`, `daemon`, `cli`, `extract_subfolder` fields;
Windows executable entries omit `.exe`. `files`, `artifact_pins`,
`daemon_sha256`, and `cli_sha256` use platform keys such as `macos-arm64`.
`download_urls` supplies an HTTPS base URL. `version` identifies an immutable
bundle. `identity` binds the child genesis/native asset, Bitcoin parent genesis,
and fork height 973728. `node_args` permits reviewed networking arguments while
rejecting setup/credential overrides.

Set `ready` only when production node, wallet, artifact hashes, and the parent
catalog targeting fork 973728 have been qualified together. A directly launched
bundle displays setup status; Bitwindow supplies its completed connection
profile. Pending packages never silently select Demo, Alpha, or Betanet.
