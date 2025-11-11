-- Add wallet_id column to address_book table
ALTER TABLE address_book ADD COLUMN wallet_id TEXT;

-- Set default wallet_id for existing entries (they'll need to be regenerated)
-- We can't know which wallet they belong to, so we'll leave them NULL
-- and the GetNewAddress logic will generate fresh addresses
