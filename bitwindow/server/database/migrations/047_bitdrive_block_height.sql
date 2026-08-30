-- Records the block a stored file's OP_RETURN was mined in. Without it a fork
-- purge cannot tell which files came from a branch that went away, and they
-- keep listing as if the chain still carried them.
ALTER TABLE bitdrive_files ADD COLUMN block_height INTEGER;
