-- We need txids and block_time to be filled, so we wipe all data and let the code resync
DELETE FROM processed_blocks;

ALTER TABLE processed_blocks ADD COLUMN txids TEXT NOT NULL;
ALTER TABLE processed_blocks ADD COLUMN block_time TIMESTAMP NOT NULL;