package cheques

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Backup struct {
	Network        string
	Cheques        []Cheque
	Outputs        []BackupOutput
	Counters       []IndexCounter
	DomainCounters []DomainCounter
}

type BackupOutput struct {
	ChequeID    int64         `db:"cheque_id"`
	Txid        string        `db:"txid"`
	Vout        int32         `db:"vout"`
	ValueSats   int64         `db:"value_sats"`
	BlockHeight sql.NullInt64 `db:"block_height"`
}

type IndexCounter struct {
	WalletID  string `db:"wallet_id"`
	NextIndex uint64 `db:"next_index"`
}

type DomainCounter struct {
	Domain    string `db:"domain"`
	NextIndex uint64 `db:"next_index"`
}

func ExportBackup(ctx context.Context, db *sql.DB) (*Backup, error) {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("begin cheque export: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)
	query, args := selectCheque.OrderBy("id").MustSql()
	rows, err := database.Select[Cheque](ctx, tx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("export cheques: %w", err)
	}
	outputs, err := database.Select[BackupOutput](ctx, tx, `
		SELECT cheque_id, txid, vout, value_sats, block_height FROM cheque_funding_outputs
		ORDER BY cheque_id, txid, vout
	`)
	if err != nil {
		return nil, fmt.Errorf("export cheque outputs: %w", err)
	}
	counters, err := database.Select[IndexCounter](ctx, tx, `SELECT wallet_id, next_index FROM cheque_index_counters ORDER BY wallet_id`)
	if err != nil {
		return nil, fmt.Errorf("export cheque counters: %w", err)
	}
	domains, err := database.Select[DomainCounter](ctx, tx, `SELECT domain, next_index FROM cheque_domain_counters ORDER BY domain`)
	if err != nil {
		return nil, fmt.Errorf("export cheque domain counters: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit cheque export: %w", err)
	}
	return &Backup{Cheques: rows, Outputs: outputs, Counters: counters, DomainCounters: domains}, nil
}

func ImportBackupTx(ctx context.Context, tx *sql.Tx, backup Backup) error {
	ids := make(map[int64]int64, len(backup.Cheques))
	for _, cheque := range backup.Cheques {
		if err := checkKeyVersion(cheque.KeyVersion, cheque.KeyDomain, cheque.KeyScope); err != nil {
			return err
		}
		// Cheques from before migration 025 keep an empty wallet ID until a
		// recovery claims them. A backup with an owner claims such a row.
		if cheque.Address == "" {
			return fmt.Errorf("cheque %d has no address", cheque.ID)
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address,
				actual_amount_sats, created_at, funded_at, swept_txid, swept_at, key_version, key_domain, key_scope, funded_txid)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING
		`, cheque.WalletID, cheque.DerivationIndex, cheque.ExpectedAmountSats, cheque.Address,
			cheque.ActualAmountSats, cheque.CreatedAt, cheque.FundedAt, cheque.SweptTxid, cheque.SweptAt, cheque.KeyVersion, cheque.KeyDomain, cheque.KeyScope, cheque.LegacyFundedTxid); err != nil {
			return fmt.Errorf("import cheque %d: %w", cheque.ID, err)
		}
		if cheque.WalletID != "" {
			if _, err := tx.ExecContext(ctx, `
				UPDATE cheques SET wallet_id = ?,
					actual_amount_sats = COALESCE(actual_amount_sats, ?), funded_at = COALESCE(funded_at, ?),
					swept_txid = COALESCE(swept_txid, ?), swept_at = COALESCE(swept_at, ?)
				WHERE wallet_id = '' AND derivation_index = ? AND address = ? AND key_version = ? AND key_domain = ? AND key_scope = ?
			`, cheque.WalletID, cheque.ActualAmountSats, cheque.FundedAt, cheque.SweptTxid, cheque.SweptAt,
				cheque.DerivationIndex, cheque.Address, cheque.KeyVersion, cheque.KeyDomain, cheque.KeyScope); err != nil {
				return fmt.Errorf("claim restored cheque %d: %w", cheque.ID, err)
			}
		}
		id, err := database.Get[int64](ctx, tx, `
			SELECT id FROM cheques WHERE (wallet_id = ? OR ? = '') AND derivation_index = ? AND address = ? AND key_version = ? AND key_domain = ? AND key_scope = ?
		`, cheque.WalletID, cheque.WalletID, cheque.DerivationIndex, cheque.Address, cheque.KeyVersion, cheque.KeyDomain, cheque.KeyScope)
		if err != nil {
			return fmt.Errorf("match restored cheque %d: %w", cheque.ID, err)
		}
		ids[cheque.ID] = id
		if err := bumpKeyCounter(ctx, tx, cheque.WalletID, cheque.DerivationIndex, cheque.KeyVersion, cheque.KeyDomain); err != nil {
			return err
		}
	}
	for _, output := range backup.Outputs {
		id, ok := ids[output.ChequeID]
		if !ok {
			return fmt.Errorf("output refers to absent cheque %d", output.ChequeID)
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats, block_height)
			VALUES (?, ?, ?, ?, ?) ON CONFLICT DO NOTHING
		`, id, output.Txid, output.Vout, output.ValueSats, output.BlockHeight); err != nil {
			return fmt.Errorf("import cheque output: %w", err)
		}
	}
	for _, counter := range backup.Counters {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO cheque_index_counters (wallet_id, next_index) VALUES (?, ?)
			ON CONFLICT (wallet_id) DO UPDATE
			SET next_index = MAX(cheque_index_counters.next_index, excluded.next_index)
		`, counter.WalletID, counter.NextIndex); err != nil {
			return fmt.Errorf("import cheque counter: %w", err)
		}
	}
	for _, counter := range backup.DomainCounters {
		if counter.Domain == "" {
			return errors.New("cheque counter has no domain")
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO cheque_domain_counters (domain, next_index) VALUES (?, ?)
			ON CONFLICT (domain) DO UPDATE
			SET next_index = MAX(cheque_domain_counters.next_index, excluded.next_index)
		`, counter.Domain, counter.NextIndex); err != nil {
			return fmt.Errorf("import cheque domain counter: %w", err)
		}
	}
	return nil
}
