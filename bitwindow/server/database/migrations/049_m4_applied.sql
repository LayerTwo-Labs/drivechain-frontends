-- An M4 now waits for the enforcer before its votes apply. The old votes put
-- vote i on slot i, so every stored M4 applies again from fresh bundle scores.
ALTER TABLE m4_messages ADD COLUMN applied INTEGER NOT NULL DEFAULT 0;
DELETE FROM m4_votes;
UPDATE withdrawal_bundles
SET work_score = 1,
    blocks_left = max_age,
    last_updated_height = first_seen_height,
    status = 'pending',
    status_stamped = 0;
