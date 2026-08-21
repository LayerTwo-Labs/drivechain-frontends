-- BTC-mainnet spend status per outpoint, one lookup each. The answer is
-- network-independent, so no network column.
CREATE TABLE split_utxos (
    outpoint   TEXT PRIMARY KEY,
    splittable INTEGER NOT NULL,
    checked_at INTEGER NOT NULL
);
