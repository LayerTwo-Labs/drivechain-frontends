-- Add wallet_id to denials table for multi-wallet support

ALTER TABLE denials ADD COLUMN wallet_id TEXT;

-- Create index for efficient lookup by wallet
CREATE INDEX IF NOT EXISTS idx_denials_wallet_id ON denials(wallet_id);
