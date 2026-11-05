-- Scope transaction notes to a wallet, so a note written on one wallet does not
-- show up on another when both hold the same transaction.
-- The primary key changes, which SQLite cannot alter in place. Existing notes
-- are dropped rather than guessed at a wallet.
DROP TABLE transaction_notes;
CREATE TABLE transaction_notes (
    wallet_id TEXT NOT NULL,
    txid TEXT NOT NULL,
    note TEXT NOT NULL,
    set_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wallet_id, txid)
);

CREATE INDEX denials_active_outpoints
    ON denials (initial_txid, initial_vout)
    WHERE cancelled_at IS NULL;
