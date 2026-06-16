-- Bootstrap the two well-known default topics so a fresh install has
-- something to browse/post to before any topic is created on chain.
-- created_height 0 keeps them earliest-wins and reorg-proof; empty txid
-- marks them as local bootstrap rows rather than a real creation tx.
INSERT OR IGNORE INTO cn_topics (topic, name, retention_days, created_height, txid) VALUES
    (x'a1a1a1a1', 'US Weekly', 7, 0, ''),
    (x'a2a2a2a2', 'Japan Weekly', 7, 0, '');
