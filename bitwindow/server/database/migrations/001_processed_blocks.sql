CREATE TABLE processed_blocks (
    height INTEGER PRIMARY KEY,
    block_hash TEXT NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
