-- The OP_RETURN list reads the newest rows first.
CREATE INDEX IF NOT EXISTS idx_op_returns_created_at ON op_returns(created_at);
