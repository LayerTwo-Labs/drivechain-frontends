-- Deleting a cheque lowered MAX(derivation_index), so the next cheque re-derived
-- the deleted one's index and address. This allocator only ever grows.
CREATE TABLE cheque_index_counters (
    wallet_id TEXT PRIMARY KEY,
    next_index INTEGER NOT NULL
);

INSERT INTO cheque_index_counters (wallet_id, next_index)
SELECT wallet_id, MAX(derivation_index) + 1 FROM cheques GROUP BY wallet_id;
