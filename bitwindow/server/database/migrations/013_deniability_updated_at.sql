-- Drop and recreate denials table with updated_at column
DROP TABLE IF EXISTS denials;

CREATE TABLE denials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    initial_txid TEXT NOT NULL,
    initial_vout INTEGER NOT NULL,
    delay_duration INTEGER NOT NULL,
    num_hops INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancelled_reason TEXT,
    UNIQUE(initial_txid, initial_vout, cancelled_at),
    CHECK ((cancelled_at IS NULL) = (cancelled_reason IS NULL))
);