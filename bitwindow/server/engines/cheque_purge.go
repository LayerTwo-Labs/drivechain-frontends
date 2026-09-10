package engines

import (
	"context"
	"database/sql"
)

// purgeChequesAtOrAboveTx drops the cheque fundings and sweeps confirmed in a
// block at or above height, so the next funding check reads them again. State
// from a lower block, or from no known block, stays.
func purgeChequesAtOrAboveTx(ctx context.Context, tx *sql.Tx, height uint32) error {
	const gone = `WITH gone(txid) AS (
		SELECT j.value FROM processed_blocks b, json_each(b.txids) j WHERE b.height >= ?1
	) `
	const dropped = `(COALESCE(block_height, -1) >= ?1 OR txid IN (SELECT txid FROM gone))`

	const kept = `(SELECT cheque_id FROM cheque_funding_outputs WHERE NOT ` + dropped + `)`

	stmts := []string{
		// A lost output makes the total unknown until the next funding check. A
		// cheque that loses every output also loses the external sweep read off it.
		gone + `UPDATE cheques
		SET actual_amount_sats = NULL,
		    funded_at = CASE WHEN id IN ` + kept + ` THEN funded_at ELSE NULL END,
		    swept_at = CASE WHEN swept_txid = 'swept_externally' AND id NOT IN ` + kept + ` THEN NULL ELSE swept_at END,
		    swept_txid = CASE WHEN swept_txid = 'swept_externally' AND id NOT IN ` + kept + ` THEN NULL ELSE swept_txid END
		WHERE id IN (SELECT cheque_id FROM cheque_funding_outputs WHERE ` + dropped + `)`,
		gone + `DELETE FROM cheque_funding_outputs WHERE ` + dropped,
		gone + `UPDATE cheques SET swept_txid = NULL, swept_at = NULL
		WHERE swept_txid IN (SELECT txid FROM gone)`,
	}
	for _, q := range stmts {
		if _, err := tx.ExecContext(ctx, q, height); err != nil {
			return err
		}
	}
	return nil
}
