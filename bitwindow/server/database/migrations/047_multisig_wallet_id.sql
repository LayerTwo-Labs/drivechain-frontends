-- Scope multisig groups to the wallet that created them, so one wallet cannot
-- list, read, mutate or delete another's groups and their transactions.
-- Existing groups keep a NULL wallet_id and stay visible to every wallet.
ALTER TABLE multisig_groups ADD COLUMN wallet_id TEXT;

CREATE INDEX idx_multisig_groups_wallet_id ON multisig_groups (wallet_id);
