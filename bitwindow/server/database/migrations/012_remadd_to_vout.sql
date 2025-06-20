-- Turns out we need to track to_vouts after all!
ALTER TABLE executed_denials ADD COLUMN to_vout INTEGER; 