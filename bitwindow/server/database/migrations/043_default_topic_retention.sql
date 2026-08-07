-- Seven days is thinner than the feed actually moves, so a week-old story
-- falls off while it is still the newest thing anyone posted.
UPDATE cn_topics SET retention_days = 30 WHERE txid = '' AND retention_days = 7;
