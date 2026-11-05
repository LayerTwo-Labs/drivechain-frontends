CREATE TABLE IF NOT EXISTS denial_pending (
    denial_id INTEGER PRIMARY KEY REFERENCES denials(id) ON DELETE CASCADE,
    from_txid TEXT NOT NULL,
    from_vout INTEGER NOT NULL,
    to_txid TEXT NOT NULL,
    destinations TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);
