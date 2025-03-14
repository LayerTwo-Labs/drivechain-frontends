DROP TABLE IF EXISTS denials;
DROP TABLE IF EXISTS executed_denials;

CREATE TABLE denials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    initial_txid TEXT NOT NULL,  -- First UTXO in chain
    initial_vout INTEGER NOT NULL,
    delay_duration INTEGER NOT NULL,
    num_hops INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    cancelled_at TIMESTAMP,
    UNIQUE(initial_txid, initial_vout)
);

CREATE TABLE executed_denials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    denial_id INTEGER NOT NULL,
    from_txid TEXT NOT NULL,
    from_vout INTEGER NOT NULL,
    to_txid TEXT NOT NULL,
    to_vout INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (denial_id) REFERENCES denials(id)
); 