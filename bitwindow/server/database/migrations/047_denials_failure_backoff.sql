-- A denial whose execution failed was retried on every engine tick, forever.
-- These track the consecutive failures and when the next attempt is allowed,
-- so a persistent failure backs off and is eventually given up on.
ALTER TABLE denials ADD COLUMN failed_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE denials ADD COLUMN retry_after TIMESTAMP;
