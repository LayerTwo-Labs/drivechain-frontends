-- BitDrive local file storage metadata
CREATE TABLE IF NOT EXISTS bitdrive_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    txid TEXT NOT NULL UNIQUE,
    filename TEXT NOT NULL,
    file_type TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    encrypted INTEGER NOT NULL DEFAULT 0,
    timestamp INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);
