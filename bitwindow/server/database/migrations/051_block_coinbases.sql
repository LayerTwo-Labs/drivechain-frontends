-- Coinbase facts per processed block, for mining pool attribution.
CREATE TABLE block_coinbases (
    height INTEGER PRIMARY KEY,
    hash TEXT NOT NULL,
    block_time INTEGER NOT NULL,
    bits INTEGER NOT NULL,
    tx_count INTEGER NOT NULL,
    coinbase_script TEXT NOT NULL,
    coinbase_addresses TEXT NOT NULL
);
CREATE INDEX idx_block_coinbases_time ON block_coinbases(block_time);
