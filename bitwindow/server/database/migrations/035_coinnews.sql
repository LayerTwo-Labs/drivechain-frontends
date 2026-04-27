-- CoinNews v2 (BIP-coinnews) tables.
--
-- The legacy `coin_news_topics` + `op_returns` tables continue to serve
-- the v1 (pre-BIP) wire format. v2 lives in its own `cn_*` namespace so
-- the two indexers don't fight over rows; queries that want a unified
-- view UNION across both.
--
-- All `BLOB(N)` columns store raw bytes — ItemIDs are 12 B truncated
-- SHA-256 (spec §4), topic IDs 4 B, x-only pubkeys 32 B, media hashes
-- 32 B, schnorr sigs 64 B. SQLite ignores the size hint but it is
-- documentation against schema drift.

-- Universal index of every accepted CoinNews v2 Item, addressed by
-- ItemID. Anything keyed by ItemID elsewhere has a foreign key here.
-- The `(block_height, tx_index, vout_index)` triple matches the
-- canonical scan order in spec §4.2.
CREATE TABLE cn_items (
    item_id      BLOB(12) PRIMARY KEY,
    txid         TEXT     NOT NULL,
    vout         INTEGER  NOT NULL,
    block_height INTEGER  NOT NULL,
    tx_index     INTEGER  NOT NULL,
    vout_index   INTEGER  NOT NULL,
    type_tag     INTEGER  NOT NULL,
    block_time   TIMESTAMP NOT NULL,
    UNIQUE (txid, vout)
);
CREATE INDEX idx_cn_items_order ON cn_items (block_height, tx_index, vout_index);
CREATE INDEX idx_cn_items_type  ON cn_items (type_tag, block_height DESC);

-- Topic registry. Earliest confirmed creation per topic_id wins; we
-- enforce that with the PRIMARY KEY (later inserts hit the conflict
-- and the indexer ignores them).
CREATE TABLE cn_topics (
    topic          BLOB(4) PRIMARY KEY,
    name           TEXT     NOT NULL,
    retention_days INTEGER  NOT NULL DEFAULT 0,
    created_height INTEGER  NOT NULL,
    txid           TEXT     NOT NULL
);

-- One row per Story. Common fields hoisted to columns for fast feed
-- queries; the full TLV blob is preserved in `raw_tlv` so an indexer
-- upgrade can re-derive new metadata without re-scanning chain.
CREATE TABLE cn_stories (
    item_id    BLOB(12) PRIMARY KEY REFERENCES cn_items(item_id),
    topic      BLOB(4)  NOT NULL,
    headline   TEXT     NOT NULL,
    subtype    INTEGER  NOT NULL DEFAULT 0,
    url        TEXT,
    body       TEXT,
    lang       TEXT,
    nsfw       BOOLEAN  NOT NULL DEFAULT FALSE,
    media_hash BLOB(32),
    raw_tlv    BLOB
);
CREATE INDEX idx_cn_stories_topic   ON cn_stories (topic);
CREATE INDEX idx_cn_stories_subtype ON cn_stories (subtype);

-- One row per Comment. Signature has already been verified at insert
-- time; rows here are by definition from the claimed `author_xpk`.
CREATE TABLE cn_comments (
    item_id     BLOB(12) PRIMARY KEY REFERENCES cn_items(item_id),
    parent_id   BLOB(12) NOT NULL,
    author_xpk  BLOB(32) NOT NULL,
    body        TEXT,
    url         TEXT,
    lang        TEXT,
    reply_quote TEXT,
    raw_tlv     BLOB
);
CREATE INDEX idx_cn_comments_parent ON cn_comments (parent_id);
CREATE INDEX idx_cn_comments_author ON cn_comments (author_xpk);

-- Vote tally. The PRIMARY KEY enforces spec §8 dedup: a given
-- (target_id, author_xpk) is at most one row. Inserts that race
-- against an existing row on the same key MUST be ignored by the
-- caller (engine uses INSERT OR IGNORE).
CREATE TABLE cn_votes (
    target_id    BLOB(12) NOT NULL,
    author_xpk   BLOB(32) NOT NULL,
    kind         INTEGER  NOT NULL,           -- 4 = up, 5 = down
    block_height INTEGER  NOT NULL,
    tx_index     INTEGER  NOT NULL,
    vout_index   INTEGER  NOT NULL,
    block_time   TIMESTAMP NOT NULL,
    PRIMARY KEY (target_id, author_xpk)
);
CREATE INDEX idx_cn_votes_target ON cn_votes (target_id);

-- Continuation chunks for a head Item. `(head_id, seq)` is unique;
-- gaps or out-of-order inserts are caught at scan time per spec §9.
CREATE TABLE cn_continuations (
    head_id      BLOB(12) NOT NULL,
    seq          INTEGER  NOT NULL,
    chunk        BLOB     NOT NULL,
    block_height INTEGER  NOT NULL,
    PRIMARY KEY (head_id, seq)
);
