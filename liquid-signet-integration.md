# Liquid / Elements (slot 24) — integration handoff

This doc is for finishing the Liquid Signet sidechain so it behaves like the
other sidechains. It assumes the cleanup commit on this branch (see "What this
branch already does"). File references use `path:line` so an AI assistant can
jump straight to them.

## TL;DR of what's missing

1. A way for the frontend to get a Liquid **deposit address** and **balance**
   the conventional way (through orchestratord), instead of the removed
   `elements-cli` `Process.run` hack.
2. Connection **status** for Liquid in the UI (it has no RPC client today, so
   `_rpcFor` returns null and it never shows "connected").
3. Real download **hashes** + non-empty download URLs for the platforms you ship.

Everything else (config registration, binary type, orchestrator conf spec,
download) already works.

---

## What this branch already does

- Registers `liquid-signet` in all three `chains_config.json` copies (kept
  byte-identical — CI `chains_config.json sync` enforces this) and in
  `KnownSidechainSpecs` (`sidechain-orchestrator/config/sidechain_conf.go`).
- Adds `BinaryType.BINARY_TYPE_LIQUID_SIGNET` to the proto and **regenerated**
  Go + Dart (`just gen` equivalent — do not hand-edit generated files).
- Maps `liquid-signet` in `binaryTypeFromName`
  (`sidechain-orchestrator/api/orchestrator_handler.go`) so download/run status
  is reported to the frontend.
- Adds a Go Elements RPC client (see below).
- Adds a "not developed by Layer Two Labs" download warning
  (`developedByLayerTwoLabs` on `Binary`, overridden `false` on `LiquidSignet`;
  dialog in `bitwindow/lib/pages/sidechains_page.dart`).
- Removes the earlier `elements-cli` deposit hack and the `_orchestratorState`
  status rerouting (see "Architecture note").

---

## The Go Elements client (done — your backend building block)

`sidechain-orchestrator/sidechain/elements/client.go`

- Bitcoin Core-style JSON-RPC over HTTP **with basic auth** (Elements needs it;
  the CUSF clients don't).
- `NewClient(host, port, user, password)`, `GetNewAddress`, `GetBlockCount`,
  `GetBalance`.
- `GetBalance` decodes the Elements **per-asset map** and pulls the policy asset.
  Two TODOs in there you must close:
  - Confirm the policy-asset key on liquid-signet (`"bitcoin"` vs the asset hex).
  - It's not yet verified against a live node — run it and adjust.

This client is the thing your new orchestrator handler methods should call.

---

## Architecture note — read before writing a frontend client

In this repo the frontend does **not** open RPC sockets to daemons directly.
See `sail_ui/lib/rpcs/bitcoind_connection.dart`:

> No RPC client — orchestratord's BitcoinService is the canonical bitcoind proxy.
> All bitcoind RPCs go through OrchestratorRPC.

So Liquid should follow the same shape: **frontend → orchestratord → Elements
node**, not frontend → Elements. That keeps the "frontend only dials local
daemons (the orchestrator)" invariant and avoids putting Elements cookie auth in
the Flutter layer. Concretely:

- Direct Elements RPC lives in the Go client above (orchestrator side). ✅
- The frontend talks to **orchestratord**, which uses that client.

Do **not** resurrect a direct-from-Flutter Elements HTTP client.

---

## Task 1 — Balance through the orchestrator

`sidechain-orchestrator/api/orchestrator_handler.go`

1. `sidechainBalanceTarget` (~line 511): add
   `case pb.BinaryType_BINARY_TYPE_LIQUID_SIGNET: return "liquid-signet", "Liquid Signet", nil`.
2. `fetchSidechainBalance` (~line 532): add a
   `case pb.BinaryType_BINARY_TYPE_LIQUID_SIGNET:` that builds
   `elements.NewClient("localhost", port, user, pass)` and calls `GetBalance`.
   - Resolve `user`/`pass` from the generated `liquid-signet.conf` — the conf
     manager is in `orch.SidechainConfs["liquid-signet"]`
     (`config.SidechainConfManager`, built in `orchestrator.go:362`). Read
     `rpcuser`/`rpcpassword`, or the datadir `.cookie`.
   - Map `BalanceResponse` through `balanceFromTotalAvailable` like the others.

## Task 2 — Deposit address through the orchestrator

The deposit modal calls `sidechainRPC.getDepositAddress()`
(`bitwindow/lib/pages/sidechains_page.dart`, `_fetchDepositAddress`).

Add an orchestrator RPC (e.g. `GetSidechainDepositAddress`, or extend an existing
one) that, for Liquid, calls `elements.Client.GetNewAddress` and returns the
address. Wire the frontend deposit path to call it for slot 24. Apply
`formatDepositAddress(address, slot)` on the frontend as the other chains do.

> Note: a Liquid peg-in is **not** a CUSF-style sidechain deposit. Confirm
> whether `getnewaddress` is the correct peg-in destination for your
> liquid-drivechain-signet build, or whether it needs a peg-in/claim script.

## Task 3 — Connection status in the UI

Liquid has no Dart RPC client, so `_rpcFor(LiquidSignet)` is null and
`isConnected` is always false. Two options:

**Option A (matches today's architecture):** add a thin Dart connection-state
holder — model it on `bitcoind_connection.dart`, *not* on a CUSF client like
`thunder_rpc.dart`. It holds the `RPCConnection` flags and implements
`binaryArgs`/`stopRPC`; the orchestrator status gets mirrored onto it. Then wire
it into the three spots:

- `bitwindow/lib/main.dart` (~line 218): `GetIt.I.registerSingleton<LiquidSignetRPC>(...)`.
- `sail_ui/lib/providers/backend_state_provider.dart` `_rpcForBinaryName` (~line 147).
- `sail_ui/lib/providers/binaries/binary_provider.dart` `_rpcFor` (~line 587 area).

Because `LiquidSignetRPC` would extend `SidechainRPC`, you must implement its
abstract methods (`sail_ui/lib/rpcs/rpc_sidechain.dart`). The CUSF-specific ones
(`mine`, `withdraw`, `getPendingWithdrawalBundle`,
`getLatestFailedWithdrawalBundleHeight`) don't apply to a peg sidechain — decide
whether to `throw UnimplementedError` or split a smaller interface.

**Option B (cleaner long-term):** read status straight from the orchestrator
(`BackendStateProvider.binaries['liquid-signet']`) for all chains, since that's
the source of truth anyway. This is a deliberate, app-wide refactor — do it for
every sidechain with one consistent contract, not as a Liquid-only special case.
The orchestrator already creates a TCP health monitor for any started target
(`startTargetOnly` → `NewHealthChecker` → `TCPHealthCheck` for
`health_check: {type: tcp}`), so `connected` should be meaningful for Liquid
without a Dart client at all — verify this before adding one.

### Dart connection-holder template (Option A starting point)

```dart
// sail_ui/lib/rpcs/liquid_signet_rpc.dart
import 'package:sail_ui/sail_ui.dart';

/// Connection-state holder for Liquid Signet. No direct RPC — orchestratord
/// proxies Elements calls (mirrors BitcoindConnection). Status flags are
/// written by BackendStateProvider.
abstract class LiquidSignetRPC extends SidechainRPC {
  LiquidSignetRPC() : super(binaryType: BinaryType.BINARY_TYPE_LIQUID_SIGNET);
}

class LiquidSignetLive extends LiquidSignetRPC {
  // Implement RPCConnection: binaryArgs(), stopRPC(), balance(),
  //   getBlockchainInfo()  -> delegate to OrchestratorRPC.
  // Implement SidechainRPC: getDepositAddress(), getBlockCount() -> orchestrator.
  // CUSF-only methods (mine/withdraw/...) -> throw UnimplementedError or refactor.
}
```

## Task 4 — Download hashes + URLs

In all three `chains_config.json`, `liquid-signet.download.files` only has a
`macos-arm64` artifact and `hashes` is `{}`. Empty hashes = **no integrity
verification** of a binary pulled from a third-party release. Populate real
hashes (see the binary-hash verification flow) and fill the linux/windows URLs
for every platform you ship. Until then, the download warning is the only guard.

---

## Done checklist

- [ ] `sidechainBalanceTarget` + `fetchSidechainBalance` cases (creds resolved)
- [ ] `GetBalance` policy-asset key confirmed against a live node
- [ ] Orchestrator deposit-address RPC + frontend wiring
- [ ] Status: pick Option A or B and implement
- [ ] Real hashes + per-platform download URLs
- [ ] `go test ./...` in `sidechain-orchestrator`, `dart analyze` in `sail_ui` + `bitwindow`
- [ ] `chains_config.json` copies still byte-identical
