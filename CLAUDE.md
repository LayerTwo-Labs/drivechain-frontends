# drivechain-frontends — engineering rules

## Always be concise

Be as concise as possible in everything: responses, code, and comments.

A comment says what the thing is or does, in one line, two at most. No
history, no "why not X", no cross-file spelunking, no product name-drops.
Most code needs no comment at all.

```
# Bad:
# Cross-building the Intel daemon on Apple Silicon needs Rosetta. This
# branch only runs in CI (dev builds the host arch only); the install is
# idempotent (no-op if already present).

# Good:
# Install Rosetta to cross-build the Intel daemon.
```

## Never write migration / backward-compat code

This project is pre-1.0. Treat every change as the new source of truth.
Do **not** write code that handles the previous version's on-disk layout,
config format, schema, binary path, or anything else. No "if old field
exists, copy to new field." No "if file in legacy location, move it." No
shimming, no backfilling, no auto-detection of historical state.

If a change breaks an existing user's install, that's fine — they wipe
and reinstall. Octo will tell you if a one-time migration is actually
needed; until then, **don't write one**. Just write the latest correct
behavior.

This rule applies to:
- Bitcoin Core binary layout / variant subfolders
- `bitwindow-bitcoin.conf` and per-network sidecar files
- `chains_config.json` keys / variant IDs
- Bitwindowd database schemas (the migration table is for *new* schema
  changes, not for compat with deleted features)
- gRPC proto field renames / removals
- BinaryProvider / SyncProvider / any frontend state shape

When tempted to write `if exists(legacyPath) { move(legacyPath, newPath) }`,
stop and just write the new code. The user is fine wiping.

## Leave unreachable edge cases alone

Review bots report a lot of races and edge cases that no real sequence of
events reaches. Those are fine as they are. Judge reachability first: how
wide is the window, and does anything actually act inside it?

If nothing does, skip it and say why. Do not buy a theoretical case with
real complexity — a native rewrite, another lock, one more state flag —
that machinery becomes the next bug.

Worth fixing: a user action, ordinary timing, or an error path reaches it.
Not worth fixing: "theoretically possible".

Prefer widening a test to prove a case never happens over rewriting code
to make it impossible.
