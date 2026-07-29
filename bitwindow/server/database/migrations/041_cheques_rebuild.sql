-- derivation_index was globally UNIQUE while GetNextIndex is per-wallet, so a
-- second wallet's first cheque could never be inserted.
DROP TABLE IF EXISTS cheques;

CREATE TABLE cheques (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    wallet_id TEXT NOT NULL,
    derivation_index INTEGER NOT NULL,
    expected_amount_sats INTEGER NOT NULL,
    address TEXT NOT NULL UNIQUE,
    actual_amount_sats INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    funded_at TIMESTAMP,
    swept_txid TEXT,
    swept_at TIMESTAMP,
    UNIQUE (wallet_id, derivation_index)
);

-- One row per funding output, replacing a comma-joined txid column.
CREATE TABLE cheque_funding_outputs (
    cheque_id INTEGER NOT NULL REFERENCES cheques(id) ON DELETE CASCADE,
    txid TEXT NOT NULL,
    vout INTEGER NOT NULL,
    value_sats INTEGER NOT NULL,
    PRIMARY KEY (cheque_id, txid, vout)
);
