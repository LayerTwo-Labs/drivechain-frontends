-- A deposit the network never confirmed leaves the mempool without a trace.
-- This stamp separates it from one that is still pending, so the balance stops
-- counting it and the user learns to send it again.
ALTER TABLE sidechain_deposits ADD COLUMN dropped_at INTEGER NOT NULL DEFAULT 0;
