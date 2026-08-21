CREATE TABLE wallet_psbt_drafts (
    id TEXT PRIMARY KEY,
    wallet_id TEXT NOT NULL,
    label TEXT NOT NULL DEFAULT '',
    psbt_base64 TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    txid TEXT NOT NULL DEFAULT ''
);

CREATE INDEX idx_wallet_psbt_drafts_wallet_id ON wallet_psbt_drafts (wallet_id);
