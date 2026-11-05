DROP INDEX IF EXISTS denials_active_unique;

CREATE INDEX IF NOT EXISTS denials_active_outpoints
    ON denials (initial_txid, initial_vout)
    WHERE cancelled_at IS NULL;

CREATE TRIGGER IF NOT EXISTS denials_active_insert
BEFORE INSERT ON denials
WHEN NEW.cancelled_at IS NULL AND EXISTS (
    SELECT 1 FROM denials
    WHERE initial_txid = NEW.initial_txid
      AND initial_vout = NEW.initial_vout
      AND cancelled_at IS NULL
)
BEGIN
    SELECT RAISE(ABORT, 'an active denial already uses this outpoint');
END;

CREATE TRIGGER IF NOT EXISTS denials_active_update
BEFORE UPDATE OF initial_txid, initial_vout, cancelled_at ON denials
WHEN NEW.cancelled_at IS NULL AND EXISTS (
    SELECT 1 FROM denials
    WHERE initial_txid = NEW.initial_txid
      AND initial_vout = NEW.initial_vout
      AND cancelled_at IS NULL
      AND id != NEW.id
)
BEGIN
    SELECT RAISE(ABORT, 'an active denial already uses this outpoint');
END;
