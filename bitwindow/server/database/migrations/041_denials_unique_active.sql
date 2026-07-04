-- Enforce at most one ACTIVE (cancelled_at IS NULL) denial per UTXO.
--
-- The table-level UNIQUE(initial_txid, initial_vout, cancelled_at) constraint
-- does not achieve this: SQLite treats NULL as distinct in UNIQUE indexes, so
-- multiple rows with cancelled_at IS NULL sharing the same (initial_txid,
-- initial_vout) are each considered unique and admitted. A partial unique index
-- over just the active rows closes the gap while still allowing a cancelled
-- plan for the same UTXO to be recreated.
CREATE UNIQUE INDEX IF NOT EXISTS uk_active_denial_utxo
    ON denials(initial_txid, initial_vout)
    WHERE cancelled_at IS NULL;
