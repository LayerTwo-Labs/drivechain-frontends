-- Move unique constraint on address to address and direction
CREATE TABLE address_book_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL,
    address TEXT NOT NULL,
    direction TEXT CHECK (direction IN ('send', 'receive')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(address, direction)
);

INSERT INTO address_book_new SELECT * FROM address_book;
DROP TABLE address_book;
ALTER TABLE address_book_new RENAME TO address_book;