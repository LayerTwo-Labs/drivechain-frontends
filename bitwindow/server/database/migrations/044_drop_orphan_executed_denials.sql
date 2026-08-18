-- Migration 013 dropped and recreated `denials`, which reset its AUTOINCREMENT
-- counter. The executions of the dropped denials stayed behind, so a denial_id
-- can point at a new denial that reused the same id. An execution can never
-- predate the denial it belongs to, so that pair identifies a stale cross-link.
DELETE FROM executed_denials
WHERE NOT EXISTS (
        SELECT 1 FROM denials d WHERE d.id = executed_denials.denial_id
      )
   OR EXISTS (
        SELECT 1 FROM denials d
        WHERE d.id = executed_denials.denial_id
          AND julianday(executed_denials.created_at) < julianday(d.created_at)
      );
