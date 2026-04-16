-- Add missing FK on multisig_transactions.group_id -> multisig_groups(id)
-- SQLite does not support ALTER TABLE ADD FOREIGN KEY, so we recreate the table.

CREATE TABLE IF NOT EXISTS multisig_transactions_new (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
    initial_psbt TEXT NOT NULL DEFAULT '',
    combined_psbt TEXT,
    final_hex TEXT,
    txid TEXT,
    status INTEGER NOT NULL DEFAULT 1,
    type INTEGER NOT NULL DEFAULT 1,
    created INTEGER NOT NULL,
    broadcast_time INTEGER,
    amount REAL NOT NULL DEFAULT 0.0,
    destination TEXT NOT NULL DEFAULT '',
    fee REAL NOT NULL DEFAULT 0.0,
    confirmations INTEGER NOT NULL DEFAULT 0,
    required_signatures INTEGER NOT NULL DEFAULT 0
);

INSERT OR IGNORE INTO multisig_transactions_new
    SELECT id, group_id, initial_psbt, combined_psbt, final_hex, txid,
           status, type, created, broadcast_time, amount, destination,
           fee, confirmations, required_signatures
    FROM multisig_transactions;

DROP TABLE IF EXISTS multisig_transactions;
ALTER TABLE multisig_transactions_new RENAME TO multisig_transactions;
