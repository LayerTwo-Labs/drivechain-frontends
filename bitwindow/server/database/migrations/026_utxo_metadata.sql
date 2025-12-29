CREATE TABLE IF NOT EXISTS utxo_metadata (
    outpoint TEXT PRIMARY KEY,
    is_frozen INTEGER DEFAULT 0,
    label TEXT DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
