CREATE TABLE denials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    delay_duration INTEGER NOT NULL, -- stored in seconds
    num_hops INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    cancelled_at TIMESTAMP
);

CREATE TABLE executed_denials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    denial_id INTEGER NOT NULL,
    transaction_id TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (denial_id) REFERENCES denials(id)
);
