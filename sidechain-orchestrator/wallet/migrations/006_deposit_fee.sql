-- The fee is only knowable when the wallet builds the deposit. Nothing on the
-- wire tells an M5 apart from an ordinary send afterwards.
ALTER TABLE sidechain_deposits ADD COLUMN fee_sats INTEGER NOT NULL DEFAULT 0;
