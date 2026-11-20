-- The block scan deletes the rows of a replayed range by height.
CREATE INDEX IF NOT EXISTS idx_op_returns_height ON op_returns(height);
