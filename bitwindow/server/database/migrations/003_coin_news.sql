CREATE TABLE coin_news_topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic TEXT NOT NULL UNIQUE, -- 4 bytes (8 hex characters)
    name TEXT NOT NULL,
    txid TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO coin_news_topics (topic, name) VALUES ('a1a1a1a1', 'US Weekly');
INSERT INTO coin_news_topics (topic, name) VALUES ('a2a2a2a2', 'Japan Weekly');
