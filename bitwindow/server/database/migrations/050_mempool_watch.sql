-- A row lives while its tx sits in the mempool.
CREATE TABLE mempool_transactions (
    txid TEXT PRIMARY KEY,
    fee_sats INTEGER NOT NULL,
    vsize INTEGER NOT NULL,
    fee_rate REAL NOT NULL,
    first_seen_at INTEGER NOT NULL,
    first_seen_height INTEGER NOT NULL
);
CREATE INDEX idx_mempool_tx_height ON mempool_transactions(first_seen_height);
CREATE INDEX idx_mempool_tx_first_seen ON mempool_transactions(first_seen_at, txid);

-- Per connected block: the lowest included fee rate in sat/vB and the fees
-- it collected, for the reference fee rate F*.
CREATE TABLE block_stats (
    height INTEGER PRIMARY KEY,
    min_fee_rate REAL NOT NULL,
    total_fee_sats INTEGER NOT NULL DEFAULT 0
);
