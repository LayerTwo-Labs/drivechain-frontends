CREATE TABLE cheques (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    derivation_index INTEGER NOT NULL UNIQUE,
    expected_amount_sats INTEGER NOT NULL,
    address TEXT NOT NULL UNIQUE,
    funded_txid TEXT,
    actual_amount_sats INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    funded_at TIMESTAMP,
    swept_txid TEXT,
    swept_at TIMESTAMP
);
