CREATE TABLE op_returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    txid TEXT NOT NULL,
    vout INTEGER NOT NULL,
    op_return_data TEXT NOT NULL,
    fee_satoshi INTEGER NOT NULL,
    height INTEGER, -- can be null if picked up directly from the mempool

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(txid, vout)
);