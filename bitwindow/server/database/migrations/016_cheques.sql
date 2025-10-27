CREATE TABLE cheques (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    derivation_index INTEGER NOT NULL UNIQUE,
    expected_amount_sats INTEGER NOT NULL,
    address TEXT NOT NULL UNIQUE,
    funded BOOLEAN DEFAULT 0,
    funded_txid TEXT,
    actual_amount_sats INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    funded_at TIMESTAMP
);

CREATE INDEX idx_cheques_funded ON cheques(funded);
CREATE INDEX idx_cheques_address ON cheques(address);
CREATE INDEX idx_cheques_derivation_index ON cheques(derivation_index);
