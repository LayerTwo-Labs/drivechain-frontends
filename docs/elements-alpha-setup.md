# Elements Alpha installation

## Current status

One-click native installation supports Windows x86_64, Linux x86_64 with
glibc 2.39 or newer (for example Ubuntu 24.04), and Apple Silicon. A local
eCash Alphanet parent and an initialized BitWindow wallet are required.
Windows runs `elementsd.exe` directly; WSL is used only for Linux build/testing
and Windows cross-compilation, and is not an end-user dependency.

The desktop prerelease is `elements-alpha-cad1fc1fb-desktop`. All three JSON
metadata copies pin each archive and executable independently. The Apple Silicon
archive is byte-identical to the earlier macOS prerelease. Intel macOS, ARM Linux,
and ARM Windows remain unavailable. The July `elements-bf8e9e1e` package is not
Alpha and must not be reused.

[Download the desktop prerelease](https://github.com/ekulkisnek/liquid-drivechain-signet-adaptation/releases/tag/elements-alpha-cad1fc1fb-desktop).

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

Initial parent authentication can take several minutes on Windows. The startup
timeline includes `Authenticating drivechain parent state`; wait for readiness
before using the wallet. Managed startup keeps all paths as individual arguments,
including Windows paths with spaces, and uses the native platform executable.

## Windows and Linux qualification

The September 12 desktop candidates were built from source commit
`cad1fc1fb5695c14234c4e287cf9e47d958609e7` in Ubuntu 24.04 under WSL2.
Windows was cross-compiled with MinGW GCC 13.2 and executed on Windows.
Linux uses GCC 13.3, static libevent/SQLite/libstdc++, and system glibc/libm.
Windows imports only system DLLs; no MinGW DLL or WSL installation is needed.
The Linux build requires glibc 2.39+, not musl/Alpine or older glibc releases.

Both builds link the actual USDD and ECX verifier source closures used by the
Mac release. USDD's 26-file semantic source manifest is
`fa87d87b59f9aa58b6a9477ec74e664810f9a218cfa09b638280e710ab5d5f42`;
the native semantic-identity programs on Linux and Windows both report
`6b0292570fa120ae885743a391eba18a1e530455284648cfde30dc28bf3b64a9`.
The three frozen catalogue/profile definitions in the source build guide are
preserved. No dummy verifier or changed consensus identity is used.

| Platform | Archive SHA256 | Executable SHA256 |
| --- | --- | --- |
| Linux x86_64 | `f5125e66ad2a33d95e3b1da9226b88f6a8b43be04d194a1798b3467f12d9e224` | `4a0beb8a084a753f4a9f023db75d2e8801ebf48c16dcd8442e7ddf105d715205` |
| Windows x86_64 | `2a86bf6e0313455f2774b021fa2e02b7f5a90811283a006741b8b0c05e91b579` | `87d687f87d7ed54300ecde51ca0bf9253320ef13e24e950cd6704a2cfac17f75` |

`TestElementsCandidateOneClickInstall` passed on Linux in 120.23 seconds and on
native Windows in 216.95 seconds. It serves the candidate archive locally and
exercises the real downloader, both pin checks, `StartWithL1`, authenticated
Alpha genesis, unfunded descriptor-wallet setup, already-running adoption, and
restart preserving address ownership. The parent was already running and
accessed through an SSH tunnel plus an authenticated read-only relay. These
results do not establish cold parent download/IBD, a graphical end-to-end test,
or every OS version. Temporary test nodes/data are isolated from existing wallets.

After publication, `TestElementsPublishedOneClickInstall` passed against the
public GitHub URLs on Linux in 111.83 seconds and native Windows in 205.35
seconds. The published artifact hashes match the pins above. Focused backend
tests pass on both platforms, and all 18 Flutter table/metadata tests pass on
the Mac with the updated manifests and fallback configuration.

To qualify a candidate before publication, set `ELEMENTS_ALPHA_TEST_ARCHIVE`,
`ELEMENTS_ALPHA_TEST_EXECUTABLE_SHA256`, and the parent environment variables
below, then run `go test . -run '^TestElementsCandidateOneClickInstall$' -v
-timeout 20m` from `sidechain-orchestrator`. The candidate metadata exists only
inside that test; production pins are not overwritten. The published installer
test now selects the current platform and retains the same checks.

Packaging/cache/tamper tests pass on Linux and Windows with both ZIP and tar.gz.
Broader source-test qualification is **incomplete**: two test-only compilation
repairs were needed (explicit `Txid::ToUint256()` in a pair comparison and a
missing opt-in replay credential variable). No daemon source was changed for
these repairs. On Linux, 31/32 selected native tests pass; the existing
`native_candidate_parent_bound_script_cache` fixture fails four assertions.
The Windows C++ test runner aborts at the pre-test `g_used_g_prng` assertion.
These limitations are separate from the passing real installer tests and are
not represented as a green full consensus suite. Release provenance retains
the build inputs, commands, test-only patch, and qualification limits.

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
