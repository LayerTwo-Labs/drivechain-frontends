-- Add wallet_id to cheques table for per-wallet cheque tracking
ALTER TABLE cheques ADD COLUMN wallet_id TEXT NOT NULL DEFAULT '';
