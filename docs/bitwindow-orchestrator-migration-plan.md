# BitWindow orchestrator migration plan

## Goal

Make orchestrator the direct shared boundary for wallet and shared runtime flows across BitWindow and sidechain apps, while keeping BitWindow-only product APIs on `bitwindowd`.

This document does three things:
- maps the current split
- records API parity findings from code research
- defines the execution plan and sequencing for the refactor

## Decision

Use this rule:
- shared wallet + shared runtime truth -> orchestrator
- BitWindow-only product features -> `bitwindowd`

That means BitWindow should register orchestrator directly in `main.dart`, and backend-managed wallet providers should depend on an explicit orchestrator wallet client, not on hidden raw transport setup and not on `BitwindowRPC`.

## Architecture boundary

### Orchestrator owns

Shared system concerns used across BitWindow and sidechain frontends:
- binary lifecycle
- runtime state and shared status
- wallet lifecycle
- wallet encryption and lock state
- shared Bitcoin wallet operations
- shared wallet metadata and switching

### Bitwindowd owns

BitWindow product concerns:
- checks / cheques
- address book
- notifications
- BitDrive
- M4
- timestamps
- local DB-backed product state
- BitWindow-specific aggregations not yet promoted into shared infra

## Current code map

### Already orchestrator-backed

These are already conceptually on the right side of the boundary:
- `sail_ui/lib/providers/backend_state_provider.dart`
- `sail_ui/lib/providers/backend_wallet_reader_provider.dart`
- `sail_ui/lib/providers/backend_wallet_writer_provider.dart`
- `bitwindow/lib/main.dart` already registers `OrchestratorRPC`

But the boundary is blurry because the wallet providers directly construct `WalletManagerServiceClient` and some BitWindow shared wallet flows still call `bitwindowd.wallet`.

### Current BitWindow registration

`bitwindow/lib/main.dart` currently registers:
- `OrchestratorRPC(host: 'localhost', port: 30400)`
- `BackendStateProvider(orchestrator)`
- `BitwindowRPC`
- backend-managed `WalletReaderProvider` and `WalletWriterProvider`

This is close, but not explicit enough.

## Research findings

## 1. Orchestrator wallet API parity is broader than first assumed

`sidechain-orchestrator/proto/walletmanager/v1/walletmanager.proto` already exposes these wallet lifecycle methods:
- `GetWalletStatus`
- `GenerateWallet`
- `UnlockWallet`
- `LockWallet`
- `EncryptWallet`
- `ChangePassword`
- `RemoveEncryption`
- `ListWallets`
- `SwitchWallet`
- `UpdateWalletMetadata`
- `DeleteWallet`
- `DeleteAllWallets`
- `CreateWatchOnlyWallet`
- `CreateBitcoinCoreWallet`
- `EnsureCoreWallets`

It also already exposes shared Bitcoin wallet operations:
- `GetBalance`
- `GetNewAddress`
- `SendTransaction`
- `ListTransactions`
- `ListUnspent`
- `ListReceiveAddresses`
- `GetTransactionDetails`
- `BumpFee`
- `DeriveAddresses`
- `GetWalletSeed`

This changes the migration scope materially. It means we can move more shared wallet flows directly to orchestrator now.

## 2. Missing parity still matters

I did not find orchestrator wallet RPC support for these BitWindow wallet endpoints:
- `SignMessage`
- `VerifyMessage`
- `ListSidechainDeposits`
- `CreateSidechainDeposit`
- `SetCoinSelectionStrategy`

Those remain blockers for fully removing `bitwindowd.wallet` from some UI paths.

## 3. BitwindowRPC still mixes two categories today

In `sail_ui/lib/rpcs/bitwindow_api.dart`, the wallet surface includes both:
- shared wallet primitives that now exist in orchestrator
- BitWindow-specific wallet/product behavior that still only exists in `bitwindowd`

So the refactor should narrow `BitwindowRPC.wallet` usage, not delete it outright.

## Shared flows that should move to orchestrator now

These have real orchestrator support today and should use it directly in backend-managed mode.

### Wallet lifecycle and metadata
- create wallet
- watch-only wallet create
- list wallets
- switch wallet
- update wallet metadata
- delete wallet
- delete all wallets
- encrypt / unlock / lock / change password / remove encryption

Primary code:
- `sail_ui/lib/providers/backend_wallet_reader_provider.dart`
- `sail_ui/lib/providers/backend_wallet_writer_provider.dart`
- `bitwindow/lib/main.dart`

### Shared Bitcoin wallet operations
- get balance
- get new address
- send transaction
- list transactions
- list unspent
- list receive addresses
- get transaction details
- bump fee

Primary BitWindow call sites currently still on `bitwindowd.wallet`:
- `bitwindow/lib/providers/transactions_provider.dart`
- `bitwindow/lib/pages/wallet/wallet_send.dart`
- `bitwindow/lib/widgets/proof_of_funds_modal.dart`
- `bitwindow/lib/pages/wallet/wallet_receive.dart`
- `bitwindow/lib/pages/wallet/wallet_overview.dart`
- `bitwindow/lib/pages/wallet/wallet_utxos.dart`

These are now valid migration candidates.

### Shared runtime state
- backend status and binary lifecycle via `OrchestratorRPC`

Primary code:
- `sail_ui/lib/providers/backend_state_provider.dart`

## Flows that should stay on bitwindowd for now

### No orchestrator parity yet
- sign message
- verify message
- sidechain deposits
- coin selection strategy

Primary code:
- `bitwindow/lib/pages/message_signer.dart`
- `bitwindow/lib/providers/sidechain_provider.dart`
- `bitwindow/lib/pages/wallet/wallet_send.dart`
- `bitwindow/lib/providers/coin_selection_provider.dart`

### BitWindow-only product features
- address book
- checks / cheques
- notifications
- BitDrive
- M4
- timestamps
- news and topics

Primary code stays unchanged.

## Refactor strategy

## Phase 1. Establish the explicit orchestrator wallet boundary

### Deliverables
- add `OrchestratorWalletRPC` wrapper in `sail_ui`
- register it in `bitwindow/lib/main.dart`
- refactor backend wallet reader/writer providers to depend on it

### Why first
This is the lowest-risk cleanup. It makes the architecture honest before touching UI call sites.

## Phase 2. Migrate shared BitWindow wallet call sites with confirmed parity

### Candidate migrations now
- `transactions_provider.dart`
  - list transactions
  - get new address
  - list unspent
  - list receive addresses
- send flow paths that call `sendTransaction`
- views that read shared transaction / address / UTXO data from wallet service
- proof-of-funds and wallet overview paths that use list-unspent or transaction-detail primitives

### Constraint
Only move paths whose methods are present in orchestrator today. Do not create fake abstractions or best-effort fallbacks.

## Phase 3. Keep non-parity paths on bitwindowd and document the gap

Needed future backend work if the goal is to fully unify shared wallet access under orchestrator:
- add `SignMessage`
- add `VerifyMessage`
- decide whether sidechain deposit APIs belong in orchestrator or remain BitWindow-specific
- decide whether coin selection belongs in shared wallet infra or BitWindow product behavior

## Concrete execution plan

## Step 1. Research and save the map

Done in this document.

Saved facts:
- orchestrator wallet proto has much broader parity than initially assumed
- full lifecycle + many shared Bitcoin wallet operations already exist
- some wallet operations still only exist on `bitwindowd`

## Step 2. Refactor shared provider wiring

Change:
- add `sail_ui/lib/rpcs/orchestrator_wallet_rpc.dart`
- inject it from `bitwindow/lib/main.dart`
- use it from backend wallet providers

Expected result:
- backend wallet providers no longer construct raw `WalletManagerServiceClient`
- BitWindow has an explicit shared orchestrator wallet dependency

## Step 3. Migrate direct shared-wallet BitWindow call sites

Start with these, in this order:
1. `bitwindow/lib/providers/transactions_provider.dart`
2. `bitwindow/lib/pages/wallet/wallet_send.dart`
3. `bitwindow/lib/widgets/proof_of_funds_modal.dart`
4. `bitwindow/lib/pages/wallet/wallet_receive.dart`
5. `bitwindow/lib/pages/wallet/wallet_overview.dart`
6. `bitwindow/lib/pages/wallet/wallet_utxos.dart`

Reason:
- these are high-signal shared wallet surfaces
- orchestrator parity exists
- migration impact is visible and testable

## Step 4. Explicitly leave non-parity paths untouched

Do not migrate yet:
- `bitwindow/lib/pages/message_signer.dart`
- sidechain deposit flows
- coin selection flows
- app-local product features

## Step 5. Validate

Minimum validation after refactor:
- `dart format`
- `flutter analyze` on touched files
- wallet creation still works
- wallet lock/unlock/encrypt/password flows still work
- shared transaction/address/UTXO views still load
- send transaction still works in backend-managed mode

## Risks

### Risk: false parity assumptions
Mitigation:
- migration is driven by proto and generated client inspection, not guesswork

### Risk: mixed response model mismatch
Mitigation:
- adapt per call site, one method at a time
- keep types explicit

### Risk: accidentally broadening BitWindow-only behavior into shared infra
Mitigation:
- keep non-parity and product-only APIs on `bitwindowd`
- document every exception

## Refactor status

### Done
- `OrchestratorWalletRPC` introduced
- BitWindow `main.dart` updated to register it
- backend wallet reader/writer providers moved onto it
- `transactions_provider.dart` migrated to orchestrator (listTransactions, getNewAddress, listUnspent, listReceiveAddresses)
- `proof_of_funds_modal.dart` migrated `listUnspent` to orchestrator
- migration plan saved here

### Blocked on orchestrator parity gaps

The following call sites were evaluated but cannot migrate today:

- **wallet_send.dart**: `sendTransaction` needs `fixedFeeSats` and `requiredInputs` params (orchestrator only has `feeRateSatPerVbyte`, no input selection)
- **wallet_send.dart**: `setCoinSelectionStrategy` has no orchestrator equivalent
- **wallet_send.dart**: `estimateFee` calls `bitwindowd.bitcoind` (not a wallet API)
- **wallet_overview.dart**: `getStats` is a BitWindow-only product aggregation
- **wallet_overview.dart**: `bumpFee` orchestrator response only has `newTxid` (missing `originalFee`/`newFee` fields the UI displays)
- **wallet_overview.dart**: `saveNote` calls `bitwindowd.bitwindowd.setTransactionNote` (BitWindow-only)
- **wallet_utxos.dart**: `setUTXOMetadata` (freeze/label) has no orchestrator equivalent
- **wallet_utxos.dart**: consolidate dialog `sendTransaction` needs `requiredInputs`
- **wallet_receive.dart**: already effectively migrated (data flows through TransactionProvider)

### Next active refactor target

To unblock more migrations, orchestrator proto needs:
1. `fixedFeeSats` param on `SendTransaction` (or equivalent absolute-fee support)
2. `requiredInputs` / coin selection support on `SendTransaction`
3. `SetUTXOMetadata` (freeze/label)
4. Richer `BumpFeeResponse` with `originalFee`/`newFee`
5. `SetCoinSelectionStrategy`

## File list for this migration

### Touched now
- `docs/bitwindow-orchestrator-migration-plan.md`
- `sail_ui/lib/rpcs/orchestrator_wallet_rpc.dart`
- `sail_ui/lib/providers/backend_wallet_reader_provider.dart`
- `sail_ui/lib/providers/backend_wallet_writer_provider.dart`
- `bitwindow/lib/main.dart`

### High-priority next
- `bitwindow/lib/providers/transactions_provider.dart`
- `bitwindow/lib/pages/wallet/wallet_send.dart`
- `bitwindow/lib/widgets/proof_of_funds_modal.dart`
- `bitwindow/lib/pages/wallet/wallet_receive.dart`
- `bitwindow/lib/pages/wallet/wallet_overview.dart`
- `bitwindow/lib/pages/wallet/wallet_utxos.dart`

### Explicitly deferred
- `bitwindow/lib/pages/message_signer.dart`
- `bitwindow/lib/providers/sidechain_provider.dart`
- `bitwindow/lib/providers/coin_selection_provider.dart`
- product-specific BitWindow providers
