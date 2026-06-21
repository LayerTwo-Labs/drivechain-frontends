# How to add a new sidechain

This is the practical checklist for wiring a new sidechain into BitWindow + the
orchestrator, plus the conventions that keep it from going sideways. It's
distilled from real review feedback (PR #1830, the Liquid/Elements slot-24 work).

> **Ground-truth trick:** a sidechain touches ~20 files. Instead of trusting any
> list (including this one) to stay current, pick the most recently added
> sidechain and grep for it:
> ```
> grep -rli coinshift sail_ui sidechain-orchestrator bitwindow \
>   | grep -viE '/gen/|\.pb\.dart|/build/|\.dart_tool/'
> ```
> Mirror every hit for your new chain. The sections below explain *what* each
> hit is for and *why*.

---

## Mental model (read this first)

- **The orchestrator (`sidechain-orchestrator/`, Go) is the single source of
  truth** for every binary's lifecycle. It downloads, starts, stops, and
  health-checks each daemon and reports a `BinaryStatusMsg` per binary.
- **The frontend only dials the orchestrator.** `BackendStateProvider` polls the
  orchestrator once per second and *mirrors* each binary's status onto the
  matching Dart `RPCConnection`. So `RPCConnection.connected` is a copy of the
  orchestrator's view — the frontend does not run its own health probe, and it
  does **not** open sockets to sidechain daemons directly.
- **`chains_config.json` is app-owned config**, shipped in three byte-identical
  copies and versioned with migration files.

Keep these in mind and most of the "why" below is obvious.

---

## The checklist

### 1. Config — `chains_config.json` (×3, byte-identical)

Add your binary entry to **all three** copies; CI (`.github/workflows/go.yml`,
job "chains_config.json sync") fails if they differ by a single byte:

- `sail_ui/assets/chains_config.json`
- `sidechain-orchestrator/chains_config.json`
- `sidechain-orchestrator/config/chains_config.json`

In the same change you **must**:

- Bump the top-level `version`.
- Add a matching migration file `sail_ui/assets/migrations/NNN_chains_config.json`
  (next number). A migration is either a full config or a compact
  `"migration": "patch"` that deep-merges. **Skipping this freezes existing
  installs on stale config** — it has caused a real runtime crash.

Entry fields to set: `type: "sidechain"`, `slot`, `name`, `version`,
`repo_url`, `port`, `chain_layer`, `health_check` (see step 5), `dependencies`
(usually `["bitcoind", "enforcer"]`), `startup_log_patterns`, `directories`,
`download` (per-platform URLs), and `hashes` (see step 6).

### 2. Proto + regenerate

- Add `BINARY_TYPE_<NAME>` to the enum in
  `sidechain-orchestrator/proto/orchestrator/v1/orchestrator.proto`.
- **Regenerate with `just gen`.** Never hand-edit the generated files
  (`sidechain-orchestrator/gen/**`, `sail_ui/lib/gen/**`). If `just gen` is
  broken, fix the justfile — don't shell out to `buf` manually and don't patch
  generated code by hand. Generated Go and Dart must both pick up the new value.

### 3. Orchestrator backend (Go)

- `sidechain-orchestrator/config/sidechain_conf.go` — add a `KnownSidechainSpecs`
  entry (name, conf filename, base port, port style, dir key). This is what
  builds the per-sidechain conf manager and drives start/stop.
- `sidechain-orchestrator/api/orchestrator_handler.go`:
  - `binaryTypeFromName` — map your name → enum, or download/run status is
    dropped before it reaches the UI.
  - `sidechainBalanceTarget` and `fetchSidechainBalance` — add cases so balance
    works.
- `sidechain-orchestrator/sidechain/<name>/client.go` — a JSON-RPC client for
  the node (copy the shape of `thunder/client.go`). Add a `client_test.go` with
  an `httptest` server. The orchestrator handler and the CLI proxy
  (`SIDECHAIN_PROXY.md`) call this client.

### 4. Frontend wiring (`sail_ui` + `bitwindow`)

- `sail_ui/lib/config/sidechains.dart` — add the `Sidechain` subclass (override
  `slot`, `type`, `color`, `copyWith`) and add cases to `Sidechain.fromString`
  and `Sidechain.fromBinary`.
- `sail_ui/lib/config/binaries.dart` — add cases to `defaultBinaryFor`, both
  `BinaryPaths` switches, `_binaryTypeFromJsonKey`, `binaryTypeToJsonKey`, and
  `binaryFromJson`.
- `sail_ui/lib/config/sidechain_main.dart` — add to `sidechainBinaries`.
- `sail_ui/lib/providers/backend_state_provider.dart` — add to
  `_binaryTypeFromName` and `_rpcForBinaryName` (the latter is how orchestrator
  status gets mirrored onto your RPC client).
- `sail_ui/lib/providers/binaries/binary_provider.dart` — add to
  `orchestratorName` (drives start/stop/download dispatch) and `_rpcFor`.
- `sail_ui/lib/rpcs/<name>_rpc.dart` — the Dart RPC client, extending
  `SidechainRPC` (`rpc_sidechain.dart`). Implement `getDepositAddress`,
  `getBlockCount`, balance, etc. Register it in `bitwindow/lib/main.dart`
  (`GetIt.I.registerSingleton<...RPC>(...)`).

### 5. Health check

Set `health_check` in the config. `NewHealthChecker`
(`sidechain-orchestrator/health.go`) maps it to a checker: `jsonrpc`,
`connectrpc`, or `tcp` (default). The orchestrator starts a 1-second monitor for
every started target, and that monitor's result becomes the `connected` status
the whole UI reads. **If status is wrong, fix the health check here — do not
patch it in the frontend.**

### 6. Download hashes

Populate real `hashes` and per-platform download URLs. **Empty `hashes` means no
integrity verification** of a downloaded binary. Hashes are checked against both
`hashes.json` and the GitHub release artifacts.

### 7. Third-party? Mark it untrusted

If Layer Two Labs does not develop/vet the chain, override
`developedByLayerTwoLabs => false` on the `Sidechain` subclass
(`sail_ui/lib/config/binaries.dart` defines the flag, default `true`). The
Download button shows a risk warning before downloading untrusted chains.

---

## Conventions & pitfalls (the part that gets PRs sent back)

- **Keep the three `chains_config.json` byte-identical.** Same key order, same
  whitespace. Copy one onto the others; don't hand-edit each.
- **Always bump `version` + add a migration file** when config content changes.
- **Never hand-edit generated code.** `just gen` only.
- **No migration / back-compat code.** This project is pre-1.0; every change is
  the new source of truth. Don't write "if old layout exists, move it." Users
  wipe and reinstall.
- **Status comes from the orchestrator — don't re-derive it.** The orchestrator
  is the source of truth; the frontend mirror is enough. Don't build a second
  status path in the frontend.
- **Never special-case a type inside a generic accessor.** A line like
  `if (binary is FooChain) return orch.running` inside `isConnected` is the
  anti-pattern that triggered this whole doc. If one chain's status is wrong,
  the bug is in its health check (the source), not in a frontend type check.
- **Fix at the source, not the call site.** Same principle: a wrong value gets
  fixed where it's produced.
- **Frontend dials only the local orchestrator.** Never `Process.run` a CLI
  (e.g. `elements-cli`) from Flutter, and never open a direct socket to a
  sidechain daemon. Route through an orchestrator RPC.
- **Surgical changes.** Adding a sidechain should not refactor shared
  infrastructure (the migration engine, generic providers). If you're rewriting
  a shared system to land one chain, stop.
- **Comments state current behavior only** — max two lines, no references to the
  previous design or what it "doesn't" do.

---

## Non-CUSF sidechains (e.g. Elements / Liquid)

The steps above assume a CUSF-style sidechain (unauthenticated JSON-RPC, BMM
deposits/withdrawals). A Bitcoin Core derivative like Elements is different:
authenticated RPC (rpcuser/rpcpassword or `.cookie`), multi-asset
`getbalance`, and a peg model that doesn't match `SidechainRPC`'s
withdrawal-bundle/mine surface. See `liquid-signet-integration.md` for a worked
example of the deltas and the open design decisions.

---

## Verify before you push

- `cd sidechain-orchestrator && go build ./... && go test ./...`
- `cd sail_ui && dart analyze` and `cd bitwindow && dart analyze`
- The three `chains_config.json` copies are byte-identical:
  `diff sidechain-orchestrator/chains_config.json sail_ui/assets/chains_config.json`
- Launch the app, confirm the new slot appears, downloads (warning if
  untrusted), starts, shows `connected`, and can produce a deposit address.
