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
