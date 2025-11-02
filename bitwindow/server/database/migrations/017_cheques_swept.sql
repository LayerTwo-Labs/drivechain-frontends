-- Add swept tracking to cheques
ALTER TABLE cheques ADD COLUMN swept_txid TEXT;
ALTER TABLE cheques ADD COLUMN swept_at TIMESTAMP;

CREATE INDEX idx_cheques_swept ON cheques(swept_txid);
