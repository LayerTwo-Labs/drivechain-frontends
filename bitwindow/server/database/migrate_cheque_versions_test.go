package database

import (
	"database/sql"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
)

func TestChequeVersionMigration(t *testing.T) {
	for _, hasReceipt := range []bool{false, true} {
		for _, empty := range []bool{false, true} {
			name := "without receipt column"
			if hasReceipt {
				name = "with receipt column"
			}
			if empty {
				name += "/all rows deleted"
			}
			t.Run(name, func(t *testing.T) {
				db, err := sql.Open("sqlite3", filepath.Join(t.TempDir(), "cheques.db")+"?_foreign_keys=on")
				require.NoError(t, err)
				db.SetMaxOpenConns(1)
				t.Cleanup(func() { require.NoError(t, db.Close()) })
				_, err = sqlitemigrate.Run(t.Context(), db, migrations, "migrations")
				require.NoError(t, err)
				_, err = db.ExecContext(t.Context(), `
					INSERT INTO cheques (id, wallet_id, derivation_index, expected_amount_sats, address,
						funded_txid, actual_amount_sats, created_at, funded_at, swept_txid, swept_at)
					VALUES (1, 'wallet', 0, 1000, 'old-address', 'receipt-a,receipt-b', 1200,
						'2026-01-01 00:00:00', '2026-01-02 00:00:00', 'sweep', '2026-01-03 00:00:00'),
						(40, 'wallet', 25, 2000, 'deleted-address', NULL, NULL, '2026-01-01 00:00:00', NULL, NULL, NULL);
					INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats, block_height)
					VALUES (1, 'receipt-a', 2, 700, 42), (1, 'receipt-b', 3, 500, NULL);
					INSERT INTO cheque_index_counters (wallet_id, next_index) VALUES ('wallet', 26);
					DELETE FROM cheques WHERE id = 40;
				`)
				require.NoError(t, err)
				if !hasReceipt {
					_, err = db.ExecContext(t.Context(), `ALTER TABLE cheques DROP COLUMN funded_txid`)
					require.NoError(t, err)
				}
				if empty {
					_, err = db.ExecContext(t.Context(), `DELETE FROM cheques`)
					require.NoError(t, err)
				}

				require.NoError(t, runMigrations(t.Context(), db))
				first := chequeSnapshot(t, db)
				require.NoError(t, runMigrations(t.Context(), db))
				require.Equal(t, first, chequeSnapshot(t, db))
				var next uint32
				require.NoError(t, db.QueryRowContext(t.Context(), `SELECT next_index FROM cheque_index_counters WHERE wallet_id = 'wallet'`).Scan(&next))
				require.Equal(t, uint32(26), next)

				if !empty {
					var receipt sql.NullString
					var row string
					require.NoError(t, db.QueryRowContext(t.Context(), `
						SELECT funded_txid, json_array(id, wallet_id, derivation_index, key_version, key_domain, key_scope,
							expected_amount_sats, address, actual_amount_sats, created_at, funded_at, swept_txid, swept_at)
						FROM cheques WHERE id = 1
					`).Scan(&receipt, &row))
					require.JSONEq(t, `[1,"wallet",0,0,"","",1000,"old-address",1200,"2026-01-01 00:00:00","2026-01-02 00:00:00","sweep","2026-01-03 00:00:00"]`, row)
					require.Equal(t, hasReceipt, receipt.Valid)
					if hasReceipt {
						require.Equal(t, "receipt-a,receipt-b", receipt.String)
					}
					var outputs string
					require.NoError(t, db.QueryRowContext(t.Context(), `
						SELECT json_group_array(json_array(cheque_id, txid, vout, value_sats, block_height))
						FROM (SELECT * FROM cheque_funding_outputs ORDER BY txid)
					`).Scan(&outputs))
					require.JSONEq(t, `[[1,"receipt-a",2,700,42],[1,"receipt-b",3,500,null]]`, outputs)
				}

				result, err := db.ExecContext(t.Context(), `
					INSERT INTO cheques (wallet_id, derivation_index, key_version, key_domain, key_scope, expected_amount_sats, address)
					VALUES ('wallet', 0, 1, 'domain', 'network', 1000, 'new-address')
				`)
				require.NoError(t, err)
				id, err := result.LastInsertId()
				require.NoError(t, err)
				require.Equal(t, int64(41), id)
				beforeRerun := chequeSnapshot(t, db)
				require.NoError(t, runMigrations(t.Context(), db))
				require.Equal(t, beforeRerun, chequeSnapshot(t, db))
				_, err = db.ExecContext(t.Context(), `DELETE FROM cheques WHERE id = 1`)
				require.NoError(t, err)
				var count int
				require.NoError(t, db.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM cheque_funding_outputs`).Scan(&count))
				require.Zero(t, count)
				require.NoError(t, db.QueryRowContext(t.Context(), `SELECT COUNT(*) FROM pragma_foreign_key_check`).Scan(&count))
				require.Zero(t, count)
				_, err = db.ExecContext(t.Context(), `INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats) VALUES (999, 'invalid', 0, 1)`)
				require.ErrorContains(t, err, "FOREIGN KEY constraint failed")
			})
		}
	}
}

func chequeSnapshot(t *testing.T, db *sql.DB) string {
	t.Helper()
	var snapshot string
	require.NoError(t, db.QueryRowContext(t.Context(), `
		SELECT json_array(
			(SELECT json_group_array(json_array(id, wallet_id, derivation_index, key_version, key_domain, key_scope,
				expected_amount_sats, address, funded_txid, actual_amount_sats, created_at, funded_at, swept_txid, swept_at))
			 FROM (SELECT * FROM cheques ORDER BY id)),
			(SELECT json_group_array(json_array(cheque_id, txid, vout, value_sats, block_height))
			 FROM (SELECT * FROM cheque_funding_outputs ORDER BY cheque_id, txid, vout)),
			(SELECT json_group_array(json_array(wallet_id, next_index))
			 FROM (SELECT * FROM cheque_index_counters ORDER BY wallet_id)),
			(SELECT json_group_array(json_array(domain, next_index))
			 FROM (SELECT * FROM cheque_domain_counters ORDER BY domain)),
			(SELECT seq FROM sqlite_sequence WHERE name = 'cheques'))
	`).Scan(&snapshot))
	return snapshot
}
