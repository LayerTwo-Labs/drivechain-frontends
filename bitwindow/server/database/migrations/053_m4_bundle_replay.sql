UPDATE m4_messages SET applied = 0;
DELETE FROM m4_votes;
UPDATE withdrawal_bundles
SET work_score = 1,
    blocks_left = max_age,
    last_updated_height = first_seen_height - 1,
    status = 'pending',
    status_stamped = 0;
ALTER TABLE m3_messages ADD COLUMN vote_height INTEGER;
UPDATE m3_messages
SET vote_height = block_height
WHERE NOT EXISTS (
    SELECT 1 FROM m4_messages m4 WHERE m4.block_height = m3_messages.block_height
);
