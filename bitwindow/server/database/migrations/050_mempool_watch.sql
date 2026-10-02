-- Fee details are fetched lazily, so they may be unknown for a pending row.
CREATE TABLE mempool_transactions (
    txid TEXT PRIMARY KEY,
    fee_sats INTEGER,
    vsize INTEGER,
    fee_rate REAL,
    first_seen_at INTEGER NOT NULL,
    first_seen_height INTEGER NOT NULL,
    status TEXT NOT NULL,
    resolved_at INTEGER,
    resolved_height INTEGER
);
CREATE INDEX idx_mempool_tx_status_fee_rate ON mempool_transactions(status, fee_rate);
CREATE INDEX idx_mempool_tx_status_height ON mempool_transactions(status, first_seen_height);

-- Per connected block: the lowest included fee rate in sat/vB and the fees
-- it collected, for the reference fee rate F*.
CREATE TABLE block_stats (
    height INTEGER PRIMARY KEY,
    min_fee_rate REAL NOT NULL,
    total_fee_sats INTEGER NOT NULL DEFAULT 0
);
