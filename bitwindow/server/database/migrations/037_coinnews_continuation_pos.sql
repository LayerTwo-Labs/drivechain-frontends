-- Continuations carry their canonical scan position so the reader can
-- enforce spec §9: chunks must appear in the head's tx or a later tx in
-- the same block, in seq order. Without (tx_index, vout_index) the
-- reader can't reject physically out-of-order chunk sets.
ALTER TABLE cn_continuations ADD COLUMN tx_index   INTEGER NOT NULL DEFAULT 0;
ALTER TABLE cn_continuations ADD COLUMN vout_index INTEGER NOT NULL DEFAULT 0;
