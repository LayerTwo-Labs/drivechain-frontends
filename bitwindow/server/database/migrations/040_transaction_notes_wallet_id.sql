-- Scope transaction notes by wallet so a note written while viewing one wallet
-- does not surface in another wallet's transaction list. The old table keyed
-- notes on txid alone, which is shared across wallets. SQLite cannot change a
-- table's primary key in place, so recreate it with a composite
-- (wallet_id, txid) primary key.

CREATE TABLE IF NOT EXISTS transaction_notes_new (
    wallet_id TEXT NOT NULL,
    txid TEXT NOT NULL,
    note TEXT NOT NULL,
    set_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wallet_id, txid)
);

DROP TABLE IF EXISTS transaction_notes;
ALTER TABLE transaction_notes_new RENAME TO transaction_notes;
