CREATE TABLE IF NOT EXISTS cheque_index_counters (
    wallet_id TEXT PRIMARY KEY,
    next_index INTEGER NOT NULL
);

INSERT OR IGNORE INTO cheque_index_counters (wallet_id, next_index)
SELECT wallet_id, MAX(derivation_index) + 1 FROM cheques GROUP BY wallet_id;
