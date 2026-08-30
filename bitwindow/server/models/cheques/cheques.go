package cheques

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"slices"
	"time"
)

// Cheque represents a Bitcoin cheque in the database
type Cheque struct {
	ID                 int64
	WalletID           string
	DerivationIndex    uint32
	ExpectedAmountSats uint64
	Address            string
	FundedTxids        []string
	ActualAmountSats   *uint64
	CreatedAt          time.Time
	FundedAt           *time.Time
	SweptTxid          *string
	SweptAt            *time.Time
}

// IsFunded returns true if actual funds meet or exceed the expected amount.
// Zero never counts: CheckChequeFunding records confirmed value only.
func (c *Cheque) IsFunded() bool {
	return c.ActualAmountSats != nil && *c.ActualAmountSats > 0 && *c.ActualAmountSats >= c.ExpectedAmountSats
}

// IsPartiallyFunded returns true if some funds arrived but less than expected
func (c *Cheque) IsPartiallyFunded() bool {
	return len(c.FundedTxids) > 0 && !c.IsFunded()
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
		&actualAmountSats,
		&cheque.CreatedAt,
		&fundedAt,
		&sweptTxid,
		&sweptAt,
	)
	if err != nil {
		return nil, err
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
		       actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND id = ?
	`, walletID, id)

	cheque, err := scanCheque(row)
	if err != nil {
		return nil, fmt.Errorf("get cheque: %w", err)
	}
	if err := attachFundingOutputs(ctx, db, walletID, []*Cheque{cheque}); err != nil {
		return nil, err
	}

	return cheque, nil
}

// GetByAddress retrieves a cheque by address for a specific wallet
func GetByAddress(ctx context.Context, db *sql.DB, walletID string, address string) (*Cheque, error) {
	row := db.QueryRowContext(ctx, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND address = ?
	`, walletID, address)

	cheque, err := scanCheque(row)
	if err != nil {
		return nil, fmt.Errorf("get cheque by address: %w", err)
	}
	if err := attachFundingOutputs(ctx, db, walletID, []*Cheque{cheque}); err != nil {
		return nil, err
	}

	return cheque, nil
}

// List retrieves all cheques for a specific wallet
func List(ctx context.Context, db *sql.DB, walletID string) ([]Cheque, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       actual_amount_sats, created_at, funded_at,
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
	if err := rows.Err(); err != nil {
		return nil, err
	}
	rows.Close()

	pointers := make([]*Cheque, len(cheques))
	for i := range cheques {
		pointers[i] = &cheques[i]
	}
	if err := attachFundingOutputs(ctx, db, walletID, pointers); err != nil {
		return nil, err
	}

	return cheques, nil
}

// attachFundingOutputs fills in each cheque's funding txids with one flat
// query. The db is MaxOpenConns(1), so this must never run inside an open rows.
func attachFundingOutputs(ctx context.Context, db *sql.DB, walletID string, cheques []*Cheque) error {
	byID := make(map[int64]*Cheque, len(cheques))
	for _, c := range cheques {
		if c != nil {
			byID[c.ID] = c
		}
	}
	if len(byID) == 0 {
		return nil
	}

	rows, err := db.QueryContext(ctx, `
		SELECT o.cheque_id, o.txid
		FROM cheque_funding_outputs o
		JOIN cheques c ON c.id = o.cheque_id
		WHERE c.wallet_id = ?
	`, walletID)
	if err != nil {
		return fmt.Errorf("list funding outputs: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var chequeID int64
		var txid string
		if err := rows.Scan(&chequeID, &txid); err != nil {
			return fmt.Errorf("scan funding output: %w", err)
		}
		if c, ok := byID[chequeID]; ok && !slices.Contains(c.FundedTxids, txid) {
			c.FundedTxids = append(c.FundedTxids, txid)
		}
	}
	return rows.Err()
}

// UpdateFunding updates a cheque's funding txids and amount
func UpdateFunding(ctx context.Context, db *sql.DB, walletID string, id int64, txids []string, actualAmount uint64) error {
	now := time.Now()

	result, err := db.ExecContext(ctx, `
		UPDATE cheques
		SET actual_amount_sats = ?, funded_at = COALESCE(funded_at, ?)
		WHERE wallet_id = ? AND id = ?
	`, actualAmount, now, walletID, id)
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

	for _, txid := range txids {
		if _, err := db.ExecContext(ctx, `
			INSERT OR IGNORE INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats)
			VALUES (?, ?, 0, 0)
		`, id, txid); err != nil {
			return fmt.Errorf("record funding output: %w", err)
		}
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
func CreateOrUpdateFromRecovery(ctx context.Context, db *sql.DB, walletID string, index uint32, address string, txids []string, amount uint64) error {
	// Check if cheque already exists
	existing, err := GetByAddress(ctx, db, walletID, address)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return fmt.Errorf("failed to check existing cheque: %w", err)
	}

	if existing != nil {
		// Update existing cheque
		return UpdateFunding(ctx, db, walletID, existing.ID, txids, amount)
	}

	// Create new cheque as already funded
	now := time.Now()
	result, err := db.ExecContext(ctx, `
		INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address, actual_amount_sats, funded_at)
		VALUES (?, ?, ?, ?, ?, ?)
	`, walletID, index, amount, address, amount, now)
	if err != nil {
		return fmt.Errorf("failed to create recovered cheque: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return fmt.Errorf("failed to get last insert id: %w", err)
	}
	for _, txid := range txids {
		if _, err := db.ExecContext(ctx, `
			INSERT OR IGNORE INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats)
			VALUES (?, ?, 0, 0)
		`, id, txid); err != nil {
			return fmt.Errorf("record recovered funding output: %w", err)
		}
	}

	return nil
}
