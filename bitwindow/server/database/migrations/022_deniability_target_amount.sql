-- Add target_utxo_sizes to denials table for user-controlled UTXO sizes
-- Stored as JSON array of integers, one per hop

ALTER TABLE denials ADD COLUMN target_utxo_sizes TEXT;
