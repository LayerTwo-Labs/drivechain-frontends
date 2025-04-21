CREATE TABLE address_book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL,
    address TEXT NOT NULL UNIQUE,
    direction TEXT CHECK (direction IN ('send', 'receive')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELETE FROM op_returns;
DELETE FROM processed_blocks;