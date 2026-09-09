-- The sidechain credits a deposit hours after the broadcast. This stamp is the
-- only permanent record of that moment, so a spent deposit coin never reads
-- back as an unconfirmed balance.
ALTER TABLE sidechain_deposits ADD COLUMN credited_at INTEGER NOT NULL DEFAULT 0;
