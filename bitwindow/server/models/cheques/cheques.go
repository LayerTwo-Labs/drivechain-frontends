package cheques

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// Cheque represents a Bitcoin cheque in the database
type Cheque struct {
	ID                 int64
	DerivationIndex    uint32
	ExpectedAmountSats uint64
	Address            string
	Funded             bool
	FundedTxid         *string
	ActualAmountSats   *uint64
	CreatedAt          time.Time
	FundedAt           *time.Time
}

// Create creates a new cheque in the database
func Create(ctx context.Context, db *sql.DB, index uint32, expectedAmount uint64, address string) (int64, error) {
	if address == "" {
		return 0, fmt.Errorf("address cannot be empty")
	}

	result, err := db.ExecContext(ctx, `
		INSERT INTO cheques (derivation_index, expected_amount_sats, address)
		VALUES (?, ?, ?)
	`, index, expectedAmount, address)
	if err != nil {
		return 0, fmt.Errorf("failed to create cheque: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("failed to get last insert id: %w", err)
	}

	return id, nil
}

// Get retrieves a cheque by ID
func Get(ctx context.Context, db *sql.DB, id int64) (*Cheque, error) {
	var cheque Cheque
	var fundedTxid sql.NullString
	var actualAmountSats sql.NullInt64
	var fundedAt sql.NullTime

	err := db.QueryRowContext(ctx, `
		SELECT id, derivation_index, expected_amount_sats, address, funded,
		       funded_txid, actual_amount_sats, created_at, funded_at
		FROM cheques
		WHERE id = ?
	`, id).Scan(
		&cheque.ID,
		&cheque.DerivationIndex,
		&cheque.ExpectedAmountSats,
		&cheque.Address,
		&cheque.Funded,
		&fundedTxid,
		&actualAmountSats,
		&cheque.CreatedAt,
		&fundedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to get cheque: %w", err)
	}

	if fundedTxid.Valid {
		cheque.FundedTxid = &fundedTxid.String
	}
	if actualAmountSats.Valid {
		amt := uint64(actualAmountSats.Int64)
		cheque.ActualAmountSats = &amt
	}
	if fundedAt.Valid {
		cheque.FundedAt = &fundedAt.Time
	}

	return &cheque, nil
}

// GetByAddress retrieves a cheque by address
func GetByAddress(ctx context.Context, db *sql.DB, address string) (*Cheque, error) {
	var cheque Cheque
	var fundedTxid sql.NullString
	var actualAmountSats sql.NullInt64
	var fundedAt sql.NullTime

	err := db.QueryRowContext(ctx, `
		SELECT id, derivation_index, expected_amount_sats, address, funded,
		       funded_txid, actual_amount_sats, created_at, funded_at
		FROM cheques
		WHERE address = ?
	`, address).Scan(
		&cheque.ID,
		&cheque.DerivationIndex,
		&cheque.ExpectedAmountSats,
		&cheque.Address,
		&cheque.Funded,
		&fundedTxid,
		&actualAmountSats,
		&cheque.CreatedAt,
		&fundedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to get cheque by address: %w", err)
	}

	if fundedTxid.Valid {
		cheque.FundedTxid = &fundedTxid.String
	}
	if actualAmountSats.Valid {
		amt := uint64(actualAmountSats.Int64)
		cheque.ActualAmountSats = &amt
	}
	if fundedAt.Valid {
		cheque.FundedAt = &fundedAt.Time
	}

	return &cheque, nil
}

// List retrieves all cheques
func List(ctx context.Context, db *sql.DB) ([]Cheque, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, derivation_index, expected_amount_sats, address, funded,
		       funded_txid, actual_amount_sats, created_at, funded_at
		FROM cheques
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("failed to list cheques: %w", err)
	}
	defer rows.Close()

	var cheques []Cheque
	for rows.Next() {
		var cheque Cheque
		var fundedTxid sql.NullString
		var actualAmountSats sql.NullInt64
		var fundedAt sql.NullTime

		err := rows.Scan(
			&cheque.ID,
			&cheque.DerivationIndex,
			&cheque.ExpectedAmountSats,
			&cheque.Address,
			&cheque.Funded,
			&fundedTxid,
			&actualAmountSats,
			&cheque.CreatedAt,
			&fundedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan cheque: %w", err)
		}

		if fundedTxid.Valid {
			cheque.FundedTxid = &fundedTxid.String
		}
		if actualAmountSats.Valid {
			amt := uint64(actualAmountSats.Int64)
			cheque.ActualAmountSats = &amt
		}
		if fundedAt.Valid {
			cheque.FundedAt = &fundedAt.Time
		}

		cheques = append(cheques, cheque)
	}

	return cheques, rows.Err()
}

// UpdateFunding updates a cheque as funded
func UpdateFunding(ctx context.Context, db *sql.DB, id int64, txid string, actualAmount uint64) error {
	now := time.Now()

	_, err := db.ExecContext(ctx, `
		UPDATE cheques
		SET funded = 1, funded_txid = ?, actual_amount_sats = ?, funded_at = ?
		WHERE id = ?
	`, txid, actualAmount, now, id)

	if err != nil {
		return fmt.Errorf("failed to update funding: %w", err)
	}

	return nil
}

// GetNextIndex returns the next available cheque index
func GetNextIndex(ctx context.Context, db *sql.DB) (uint32, error) {
	var maxIndex sql.NullInt64

	err := db.QueryRowContext(ctx, `
		SELECT MAX(derivation_index) FROM cheques
	`).Scan(&maxIndex)

	if err != nil && err != sql.ErrNoRows {
		return 0, fmt.Errorf("failed to get max index: %w", err)
	}

	if !maxIndex.Valid {
		// No cheques yet, start at 0
		return 0, nil
	}

	return uint32(maxIndex.Int64) + 1, nil
}

// Delete deletes a cheque by ID
func Delete(ctx context.Context, db *sql.DB, id int64) error {
	result, err := db.ExecContext(ctx, `
		DELETE FROM cheques WHERE id = ?
	`, id)

	if err != nil {
		return fmt.Errorf("failed to delete cheque: %w", err)
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rows == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// CreateOrUpdateFromRecovery creates or updates a cheque from recovery scan
func CreateOrUpdateFromRecovery(ctx context.Context, db *sql.DB, index uint32, address string, txid string, amount uint64) error {
	// Check if cheque already exists
	existing, err := GetByAddress(ctx, db, address)
	if err != nil && err != sql.ErrNoRows {
		return fmt.Errorf("failed to check existing cheque: %w", err)
	}

	if existing != nil {
		// Update existing cheque
		return UpdateFunding(ctx, db, existing.ID, txid, amount)
	}

	// Create new cheque as already funded
	now := time.Now()
	_, err = db.ExecContext(ctx, `
		INSERT INTO cheques (derivation_index, expected_amount_sats, address, funded, funded_txid, actual_amount_sats, funded_at)
		VALUES (?, ?, ?, 1, ?, ?, ?)
	`, index, amount, address, txid, amount, now)

	if err != nil {
		return fmt.Errorf("failed to create recovered cheque: %w", err)
	}

	return nil
}
