# ECX migration

The CLI and the network upgrade action use the same daemon migration.
The daemon uses unchanged Core binaries.
The daemon keeps the common BTC blocks, undo data, block index, chainstate, XOR key, and Core wallets.

Start `drivechaind` on the node host.
Use these commands from a terminal:

```sh
drivechain-cli ecash migrate --from alphanet --to betanet --preview
drivechain-cli ecash migrate --from alphanet --to betanet --yes
drivechain-cli ecash migration-status --json
```

Use `--yes --json` for scripts.
The CLI writes one JSON object per status update.
It returns a nonzero exit code on failure.
The standard RPC address and local authentication options also apply to these commands.
The daemon owns the data files, so the CLI can run on another host.
Core must run on the daemon host.
No GUI or Flutter process is necessary.

## Catalog

Keep both network entries in `/config`.
Each entry must include its `id`, `family: "ecash"`, `fork_height`, and `network_magic`.
Use eight hexadecimal digits for `network_magic`, in byte order.
The source entry must also include `fork_parent_hash`, the BTC hash at `fork_height - 1`.
The target must fork BTC at a higher height than the source.
The existing binary configuration must resolve both ECX release binaries.

For alphanet, the first different block has height 963648.
The common block has height 963647.
Publish its exact BTC hash before a release migration.
Do not substitute the betanet fork height for this rollback boundary.

## Sequence

1. Get both Core binaries and save their SHA256 values.
2. Stop the sidechains, enforcer, and Core.
3. Start source Core with P2P activity and wallet broadcast off.
4. Check the common block hash and the prune limit.
5. Invalidate each active source branch above the common block.
6. Make sure the active tip equals the common block.
7. Stop Core through RPC and wait for its exit.
8. Check all block records and wallet files.
9. Change the four magic bytes in each block and undo record.
10. Change the SQLite wallet network identity.
11. Keep the old peer, anchor, and mempool files in the migration backup directory.
12. Select the target configuration.
13. Start target Core with P2P activity off.
14. Check the common block and a raw block read.
15. Enable target P2P activity.

The converter uses each record length to skip its payload.
It applies the existing XOR key at each file offset.
It keeps record sizes, payloads, checksums, and file positions unchanged.
Wallet conversion keeps all wallet rows and checks their hashes.
Legacy BDB wallets stop the migration with an error.

The daemon preserves old sidechain and enforcer state in adjacent archive directories.
Start compatible betanet services after the migration.
The target configuration keeps `walletbroadcast=0` across restarts.
This prevents old unconfirmed wallet transactions from automatic broadcast.
Core wallet RPCs such as `sendtoaddress` create transactions without broadcast under this setting.
The app can still submit signed transactions through `sendrawtransaction`.
Review old unconfirmed transactions before you enable automatic wallet broadcast.
Old alphanet transactions and balances do not become betanet transactions and balances.

## Resume

Use the same migration command after an interruption.
The daemon keeps its stage in `ecash-migration.json` in the BitWindow data directory.
It keeps conversion journals and original wallet files under `ecash-migrations/<job-id>` in the Core data directory.
Do not remove these files during a migration.
Normal node starts remain blocked until the migration completes.
A client disconnect does not stop the daemon job.

The preview reads metadata and available RPC data without node file changes.
The complete file check occurs after Core stops.
Pruned nodes must retain the common block and the full rollback interval.
The migration returns an error if those blocks are absent.
It does not delete retained blocks or start a full reindex as a recovery step.

`complete` means that the target Core process passed the local checks.
`sync_state: "syncing"` means that the target chain can still be behind its peers.
Use the normal Core status to check later sync progress.

## Release test

Run the real Core test with two unchanged release binaries:

```sh
BITCOIND_MIGRATION_SOURCE=/path/to/alphanet/bitcoind \
BITCOIND_MIGRATION_TARGET=/path/to/target/bitcoind \
go test -tags integration ./blockfile -run TestCoreMagicMigration -v
```

The test uses temporary regtest data directories.
Set `BITCOIND_MIGRATION_SOURCE_MAGIC` and `BITCOIND_MIGRATION_TARGET_MAGIC` if the binaries use other regtest magic values.
It checks XOR, undo data, wallet keys, UTXO state, indexes, restart, interruption, resume, and full reindex.
Stock Core exercises the target disk reader before the betanet release exists.
Test the exact betanet release and its consensus rules before a public migration.
Measure a representative data directory before a speed claim.
