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
	WalletID           string
	DerivationIndex    uint32
	ExpectedAmountSats uint64
	Address            string
	FundedTxid         *string
	ActualAmountSats   *uint64
	CreatedAt          time.Time
	FundedAt           *time.Time
	SweptTxid          *string
	SweptAt            *time.Time
}

// Create creates a new cheque in the database
func Create(ctx context.Context, db *sql.DB, walletID string, index uint32, expectedAmount uint64, address string) (int64, error) {
	if walletID == "" {
		return 0, fmt.Errorf("wallet_id cannot be empty")
	}
	if address == "" {
		return 0, fmt.Errorf("address cannot be empty")
	}

	result, err := db.ExecContext(ctx, `
		INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address)
		VALUES (?, ?, ?, ?)
	`, walletID, index, expectedAmount, address)
	if err != nil {
		return 0, fmt.Errorf("failed to create cheque: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("failed to get last insert id: %w", err)
	}

	return id, nil
}

// scanCheque scans a cheque row from the database
func scanCheque(scanner interface {
	Scan(dest ...interface{}) error
}) (*Cheque, error) {
	var cheque Cheque
	var fundedTxid sql.NullString
	var actualAmountSats sql.NullInt64
	var fundedAt sql.NullTime
	var sweptTxid sql.NullString
	var sweptAt sql.NullTime

	err := scanner.Scan(
		&cheque.ID,
		&cheque.WalletID,
		&cheque.DerivationIndex,
		&cheque.ExpectedAmountSats,
		&cheque.Address,
		&fundedTxid,
		&actualAmountSats,
		&cheque.CreatedAt,
		&fundedAt,
		&sweptTxid,
		&sweptAt,
	)
	if err != nil {
		return nil, err
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
	if sweptTxid.Valid {
		cheque.SweptTxid = &sweptTxid.String
	}
	if sweptAt.Valid {
		cheque.SweptAt = &sweptAt.Time
	}

	return &cheque, nil
}

// Get retrieves a cheque by ID for a specific wallet
func Get(ctx context.Context, db *sql.DB, walletID string, id int64) (*Cheque, error) {
	row := db.QueryRowContext(ctx, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       funded_txid, actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND id = ?
	`, walletID, id)

	cheque, err := scanCheque(row)
	if err != nil {
		return nil, fmt.Errorf("get cheque: %w", err)
	}

	return cheque, nil
}

// GetByAddress retrieves a cheque by address for a specific wallet
func GetByAddress(ctx context.Context, db *sql.DB, walletID string, address string) (*Cheque, error) {
	row := db.QueryRowContext(ctx, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       funded_txid, actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND address = ?
	`, walletID, address)

	cheque, err := scanCheque(row)
	if err != nil {
		return nil, fmt.Errorf("get cheque by address: %w", err)
	}

	return cheque, nil
}

// List retrieves all cheques for a specific wallet
func List(ctx context.Context, db *sql.DB, walletID string) ([]Cheque, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       funded_txid, actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ?
		ORDER BY created_at DESC
	`, walletID)
	if err != nil {
		return nil, fmt.Errorf("list cheques: %w", err)
	}
	defer rows.Close()

	var cheques []Cheque
	for rows.Next() {
		cheque, err := scanCheque(rows)
		if err != nil {
			return nil, fmt.Errorf("scan cheque: %w", err)
		}

		cheques = append(cheques, *cheque)
	}

	return cheques, rows.Err()
}

// UpdateFunding updates a cheque as funded
func UpdateFunding(ctx context.Context, db *sql.DB, walletID string, id int64, txid string, actualAmount uint64) error {
	now := time.Now()

	result, err := db.ExecContext(ctx, `
		UPDATE cheques
		SET funded_txid = ?, actual_amount_sats = ?, funded_at = ?
		WHERE wallet_id = ? AND id = ?
	`, txid, actualAmount, now, walletID, id)

	if err != nil {
		return fmt.Errorf("failed to update funding: %w", err)
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

// UpdateSwept marks a cheque as swept
func UpdateSwept(ctx context.Context, db *sql.DB, walletID string, id int64, txid string) error {
	now := time.Now()

	result, err := db.ExecContext(ctx, `
		UPDATE cheques
		SET swept_txid = ?, swept_at = ?
		WHERE wallet_id = ? AND id = ?
	`, txid, now, walletID, id)

	if err != nil {
		return fmt.Errorf("failed to update swept: %w", err)
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

// GetNextIndex returns the next available cheque index for a specific wallet
func GetNextIndex(ctx context.Context, db *sql.DB, walletID string) (uint32, error) {
	var maxIndex sql.NullInt64

	err := db.QueryRowContext(ctx, `
		SELECT MAX(derivation_index) FROM cheques WHERE wallet_id = ?
	`, walletID).Scan(&maxIndex)

	if err != nil && err != sql.ErrNoRows {
		return 0, fmt.Errorf("failed to get max index: %w", err)
	}

	if !maxIndex.Valid {
		// No cheques yet for this wallet, start at 0
		return 0, nil
	}

	return uint32(maxIndex.Int64) + 1, nil
}

// Delete deletes a cheque by ID for a specific wallet
func Delete(ctx context.Context, db *sql.DB, walletID string, id int64) error {
	result, err := db.ExecContext(ctx, `
		DELETE FROM cheques WHERE wallet_id = ? AND id = ?
	`, walletID, id)

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
func CreateOrUpdateFromRecovery(ctx context.Context, db *sql.DB, walletID string, index uint32, address string, txid string, amount uint64) error {
	// Check if cheque already exists
	existing, err := GetByAddress(ctx, db, walletID, address)
	if err != nil && err != sql.ErrNoRows {
		return fmt.Errorf("failed to check existing cheque: %w", err)
	}

	if existing != nil {
		// Update existing cheque
		return UpdateFunding(ctx, db, walletID, existing.ID, txid, amount)
	}

	// Create new cheque as already funded
	now := time.Now()
	_, err = db.ExecContext(ctx, `
		INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address, funded_txid, actual_amount_sats, funded_at)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`, walletID, index, amount, address, txid, amount, now)

	if err != nil {
		return fmt.Errorf("failed to create recovered cheque: %w", err)
	}

	return nil
}
