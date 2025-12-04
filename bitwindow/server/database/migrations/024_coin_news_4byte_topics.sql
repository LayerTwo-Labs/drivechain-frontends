-- CoinNews topic IDs changed from 8 bytes to 4 bytes.
-- This migration resets topics and forces a resync to reparse with the new format.

DELETE FROM coin_news_topics;
DELETE FROM op_returns;


DELETE FROM processed_blocks;

-- Add confirmed field to track pending vs mined topics
ALTER TABLE coin_news_topics ADD COLUMN confirmed BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO coin_news_topics (topic, name, confirmed) VALUES ('a1a1a1a1', 'US Weekly', true);
INSERT INTO coin_news_topics (topic, name, confirmed) VALUES ('a2a2a2a2', 'Japan Weekly', true);