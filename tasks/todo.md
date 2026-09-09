# Explorer: deposits, BMM detail, and a recent list that never runs empty

## What is wrong today

1. `explorer_handler.go:672` declares `Deposits []struct{ Outpoint string }`. The node
   returns a two-element array `[outpoint, output]`. The parse fails, so `nodeBlock`
   takes the fallback path and returns no rows and no size for every block that holds
   a deposit.
2. `blockListSize = 6` caps the activity walk at six blocks. A chain with no recent
   transaction lists nothing.
3. The block card writes "Fees unknown" and "Size unknown".
4. No deposit list exists.
5. The block screen shows no BMM bid and no outpoint.

## Design

Figma page `Explorer flow`, file `Uvj2xZiMJsOt3nDaSxDGLQ`:

- `1 · Explorer · overview` (`757:315`) — a deposit line on each block card, and a new
  full width `deposits` card.
- `2 · Explorer · block` (`763:371`) — the BMM card gains `Mainchain block` and
  `Bid outpoint`; the bottom row holds `transactions` and `deposits` side by side.

## Plan

- [x] Read the node and find the real deposit shape
- [x] Figma: deposit line on the block cards
- [x] Figma: deposit list on the overview
- [x] Figma: BMM outpoint and the two bottom tables on the block screen
- [x] Proto: `Activity.address`, `Block.deposit_count`, `Block.deposit_value_sats`,
      and a `Bid` message
- [x] Go: parse the deposit pair, and fill the address and the value
- [x] Go: walk down until the activity list holds 10 rows, with a per-block cache
- [x] Go: read the block time from the enforcer header
- [x] Go: read the winning bid out of the mainchain block
- [x] Dart: drop the unknown lines, add the deposit line to the block card
- [x] Dart: deposit list on the overview
- [x] Dart: BMM fields and the two tables on the block screen
- [x] Tests, lint, PR

## Result

The bid sits one mainchain block later than the header names. A header names
the parent the M8 was built on, and a miner takes that M8 in the next block.

A live thunder node reads back five deposits, from block 43 down to block 21.
Every one of those sits below the old six block window.

## Remote enforcer — 2026-09-09

Light mode starts local sidechain daemons through the public alphanet validator.
BitWindow keeps its Electrum L1 wallet. Full mode keeps local Core and enforcer.

- [x] Check remote validator support in all five Rust forks.
- [x] Add the HTTPS endpoint, method restrictions, and local HTTP/2 bridge.
- [x] Start local sidechain daemons and use local wallet RPCs in both modes.
- [x] Preserve active sidechains when the user cancels the full-mode directory choice.
- [x] Remove local controls from remote enforcer cards.
- [x] Keep each local bridge address after a same-network endpoint update.
- [x] Restart owned light-mode orphans with the current bridge address.
- [x] Prefer exact daemon names during orphan adoption.
- [x] Reject mode changes that would stop daemons from another launcher.
- [x] Disable BMM in light mode because the validator lacks mempool reads.
- [x] Show an unavailable state when a light-mode network has no remote validator.
- [x] Isolate daemon test configuration and wait for test process shutdown.
- [x] Run local tests, builds, lint, analysis, and the shared Flutter reload.
- [x] Test a local Thunder daemon through the public alphanet endpoint.
- [x] Open the frontend and Thunder fork PRs.

### Review

The complete Go test set passed across the protected suite and the native process tests.
All 33 focused race tests passed. Go lint found no issues.

The endpoint-update regression reproduced a refused connection at the old local port. The fixed client test and 60 race cases passed.
The real restart test reproduced a stale bridge and an incorrect Thunder/ZSide match.
Both fixes passed the default-configuration restart test, 29 focused cases, and 37 race cases.
BitWindow's enforcer start restored Thunder during a real restart test.
All 34 focused tests and 34 race cases passed.

The Flutter tests cover wallet startup, local RPC use, mode changes, status controls, and networks without a remote validator.
The latest unavailable-state regression failed before the fix. All 26 focused cases passed after the fix.
Dart analysis, format checks, both Go builds, and the shared Flutter reload passed.

The public alphanet endpoint passed 13 checks for reads, subscriptions, health, and blocked methods.
A fresh Thunder node synced all 216 sidechain blocks. Both chain tips matched the seed.
The final orchestrator launch used the patched Thunder binary and default DNS peers.
Typed RPCs returned 216 blocks and zero sats. No local Core or enforcer started.

BMM pauses in light mode and keeps saved targets and paid rounds. Its 122 tests and 122 race cases passed.
The BMM interface passed 40 Flutter tests. The ownership regression passed 20 tests and 20 race cases.
Thunder's default DNS path uses the separate Rust fix.
See [the support report](../docs/remote-enforcer.md) for daemon flags and limits.
See [frontend PR 2215](https://github.com/LayerTwo-Labs/drivechain-frontends/pull/2215) and [Thunder PR 12](https://github.com/octobocto/thunder-rust/pull/12) for current CI and review state.
