-- A transaction can carry several BitDrive OP_RETURNs, but bitdrive_files was
-- unique on txid alone, so every payload after the first was dropped. Key on the
-- outpoint instead. SQLite cannot alter a UNIQUE constraint, so recreate the
-- table; existing rows keep their id and filename and take vout 0.

CREATE TABLE IF NOT EXISTS bitdrive_files_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    txid TEXT NOT NULL,
    vout INTEGER NOT NULL DEFAULT 0,
    filename TEXT NOT NULL,
    file_type TEXT NOT NULL,
    size_bytes INTEGER NOT NULL,
    encrypted INTEGER NOT NULL DEFAULT 0,
    timestamp INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    UNIQUE (txid, vout)
);

INSERT OR IGNORE INTO bitdrive_files_new
    SELECT id, txid, 0, filename, file_type, size_bytes, encrypted, timestamp, created_at
    FROM bitdrive_files;

DROP TABLE IF EXISTS bitdrive_files;
ALTER TABLE bitdrive_files_new RENAME TO bitdrive_files;
