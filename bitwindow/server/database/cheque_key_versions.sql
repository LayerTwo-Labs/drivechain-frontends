CREATE TEMP TABLE cheque_outputs_copy AS
SELECT cheque_id, txid, vout, value_sats, block_height FROM cheque_funding_outputs;

DROP TABLE cheque_funding_outputs;
ALTER TABLE cheques RENAME TO old_cheques;

CREATE TABLE cheques (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    wallet_id TEXT NOT NULL,
    derivation_index INTEGER NOT NULL,
    key_version INTEGER NOT NULL DEFAULT 0,
    key_domain TEXT NOT NULL DEFAULT '',
    key_scope TEXT NOT NULL DEFAULT '',
    expected_amount_sats INTEGER NOT NULL,
    address TEXT NOT NULL UNIQUE,
    funded_txid TEXT,
    actual_amount_sats INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    funded_at TIMESTAMP,
    swept_txid TEXT,
    swept_at TIMESTAMP,
    UNIQUE (wallet_id, key_version, key_domain, derivation_index)
);

INSERT INTO cheques (
    id, wallet_id, derivation_index, expected_amount_sats, address, funded_txid,
    actual_amount_sats, created_at, funded_at, swept_txid, swept_at
)
SELECT id, wallet_id, derivation_index, expected_amount_sats, address, funded_txid,
       actual_amount_sats, created_at, funded_at, swept_txid, swept_at
FROM old_cheques;

UPDATE sqlite_sequence
SET seq = MAX(seq, COALESCE((SELECT seq FROM sqlite_sequence WHERE name = 'old_cheques'), 0))
WHERE name = 'cheques';

UPDATE sqlite_sequence SET name = 'cheques'
WHERE name = 'old_cheques' AND NOT EXISTS (SELECT 1 FROM sqlite_sequence WHERE name = 'cheques');

DROP TABLE old_cheques;

CREATE TABLE cheque_funding_outputs (
    cheque_id INTEGER NOT NULL REFERENCES cheques(id) ON DELETE CASCADE,
    txid TEXT NOT NULL,
    vout INTEGER NOT NULL,
    value_sats INTEGER NOT NULL,
    block_height INTEGER,
    PRIMARY KEY (cheque_id, txid, vout)
);

INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats, block_height)
SELECT cheque_id, txid, vout, value_sats, block_height FROM cheque_outputs_copy;

DROP TABLE cheque_outputs_copy;

CREATE TABLE cheque_domain_counters (
    domain TEXT PRIMARY KEY,
    next_index INTEGER NOT NULL
);
