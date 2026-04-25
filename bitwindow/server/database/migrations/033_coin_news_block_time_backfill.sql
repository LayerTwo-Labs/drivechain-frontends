-- Pre-fix, op_returns.created_at was stamped with time.Now() at sync, not the
-- block timestamp. Rewrite confirmed rows from processed_blocks.block_time so
-- existing CoinNews entries display the actual posting date. Mempool rows
-- (height IS NULL) keep their wall-clock timestamp.
UPDATE op_returns
SET created_at = (
    SELECT block_time
    FROM processed_blocks
    WHERE processed_blocks.height = op_returns.height
)
WHERE op_returns.height IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM processed_blocks
    WHERE processed_blocks.height = op_returns.height
  );
