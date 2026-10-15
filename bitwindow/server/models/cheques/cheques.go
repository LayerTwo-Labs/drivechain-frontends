package cheques

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"maps"
	"slices"
	"time"

	sq "github.com/Masterminds/squirrel"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Cheque struct {
	ID                 int64  `db:"id"`
	WalletID           string `db:"wallet_id"`
	DerivationIndex    uint32 `db:"derivation_index"`
	ExpectedAmountSats uint64 `db:"expected_amount_sats"`
	Address            string `db:"address"`
	FundedTxids        []string
	ActualAmountSats   *uint64    `db:"actual_amount_sats"`
	CreatedAt          time.Time  `db:"created_at"`
	FundedAt           *time.Time `db:"funded_at"`
	SweptTxid          *string    `db:"swept_txid"`
	SweptAt            *time.Time `db:"swept_at"`
}

// IsFunded returns true if actual funds meet or exceed the expected amount
func (c *Cheque) IsFunded() bool {
	return c.ActualAmountSats != nil && *c.ActualAmountSats >= c.ExpectedAmountSats
}

// IsPartiallyFunded returns true if some funds arrived but less than expected
func (c *Cheque) IsPartiallyFunded() bool {
	return len(c.FundedTxids) > 0 && !c.IsFunded()
}

func Create(ctx context.Context, db *sql.DB, walletID string, index uint32, expectedAmount uint64, address string) (int64, error) {
	if walletID == "" {
		return 0, errors.New("wallet_id cannot be empty")
	}
	if address == "" {
		return 0, errors.New("address cannot be empty")
	}

	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return 0, fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	result, err := tx.ExecContext(ctx, `
		INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address)
		VALUES (?, ?, ?, ?)
	`, walletID, index, expectedAmount, address)
	if err != nil {
		return 0, fmt.Errorf("create cheque: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("get last insert id: %w", err)
	}

	if err := bumpIndexCounter(ctx, tx, walletID, index); err != nil {
		return 0, err
	}

	if err := tx.Commit(); err != nil {
		return 0, fmt.Errorf("commit cheque: %w", err)
	}

	return id, nil
}

// bumpIndexCounter raises the wallet's next cheque index past index. It never lowers it.
func bumpIndexCounter(ctx context.Context, tx *sql.Tx, walletID string, index uint32) error {
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO cheque_index_counters (wallet_id, next_index)
		VALUES (?, ?)
		ON CONFLICT (wallet_id) DO UPDATE
		SET next_index = MAX(cheque_index_counters.next_index, excluded.next_index)
	`, walletID, uint64(index)+1); err != nil {
		return fmt.Errorf("bump cheque index counter: %w", err)
	}
	return nil
}

// Get retrieves a cheque by ID for a specific wallet
func Get(ctx context.Context, db *sql.DB, walletID string, id int64) (*Cheque, error) {
	cheque, err := database.Get[Cheque](ctx, db, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND id = ?
	`, walletID, id)
	if err != nil {
		return nil, fmt.Errorf("get cheque: %w", err)
	}
	if err := attachFundingOutputs(ctx, db, []*Cheque{&cheque}); err != nil {
		return nil, err
	}

	return &cheque, nil
}

// GetByAddress retrieves a cheque by address for a specific wallet
func GetByAddress(ctx context.Context, db *sql.DB, walletID string, address string) (*Cheque, error) {
	cheque, err := database.Get[Cheque](ctx, db, `
		SELECT id, wallet_id, derivation_index, expected_amount_sats, address,
		       actual_amount_sats, created_at, funded_at,
		       swept_txid, swept_at
		FROM cheques
		WHERE wallet_id = ? AND address = ?
	`, walletID, address)
	if err != nil {
		return nil, fmt.Errorf("get cheque by address: %w", err)
	}
	if err := attachFundingOutputs(ctx, db, []*Cheque{&cheque}); err != nil {
		return nil, err
	}

	return &cheque, nil
}

// List retrieves all cheques for a specific wallet
func List(ctx context.Context, db *sql.DB, walletID string) ([]Cheque, error) {
	cheques, err := database.Select[Cheque](ctx, db, `
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

	pointers := make([]*Cheque, len(cheques))
	for i := range cheques {
		pointers[i] = &cheques[i]
	}
	if err := attachFundingOutputs(ctx, db, pointers); err != nil {
		return nil, err
	}

	return cheques, nil
}

// attachFundingOutputs fills in each cheque's funding txids with one flat
// query. The db is MaxOpenConns(1), so this must never run inside an open rows.
func attachFundingOutputs(ctx context.Context, db *sql.DB, cheques []*Cheque) error {
	byID := make(map[int64]*Cheque, len(cheques))
	for _, c := range cheques {
		if c != nil {
			byID[c.ID] = c
		}
	}
	if len(byID) == 0 {
		return nil
	}

	query, args := sq.
		Select("cheque_id", "txid").
		From("cheque_funding_outputs").
		Where(sq.Eq{"cheque_id": slices.Collect(maps.Keys(byID))}).
		PlaceholderFormat(sq.Question).
		MustSql()
	type fundingOutput struct {
		ChequeID int64  `db:"cheque_id"`
		Txid     string `db:"txid"`
	}
	outputs, err := database.Select[fundingOutput](ctx, db, query, args...)
	if err != nil {
		return fmt.Errorf("list funding outputs: %w", err)
	}
	for _, out := range outputs {
		if c, ok := byID[out.ChequeID]; ok && !slices.Contains(c.FundedTxids, out.Txid) {
			c.FundedTxids = append(c.FundedTxids, out.Txid)
		}
	}
	return nil
}

// FundingOutput is one transaction paying a cheque. BlockHeight is 0 while it
// is unconfirmed.
type FundingOutput struct {
	Txid        string
	BlockHeight uint32
}

// UpdateFunding updates a cheque's funding outputs and amount
func UpdateFunding(ctx context.Context, db *sql.DB, walletID string, id int64, outputs []FundingOutput, actualAmount uint64) error {
	now := time.Now()

	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	if err := database.CheckOne(tx.ExecContext(ctx, `
		UPDATE cheques
		SET actual_amount_sats = ?, funded_at = COALESCE(funded_at, ?)
		WHERE wallet_id = ? AND id = ?
	`, actualAmount, now, walletID, id)); err != nil {
		return fmt.Errorf("update funding: %w", err)
	}

	if err := recordFundingOutputs(ctx, tx, id, outputs); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit funding: %w", err)
	}
	return nil
}

func recordFundingOutputs(ctx context.Context, tx *sql.Tx, chequeID int64, outputs []FundingOutput) error {
	for _, out := range outputs {
		var height sql.NullInt64
		if out.BlockHeight > 0 {
			height = sql.NullInt64{Int64: int64(out.BlockHeight), Valid: true}
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO cheque_funding_outputs (cheque_id, txid, vout, value_sats, block_height)
			VALUES (?, ?, 0, 0, ?)
			ON CONFLICT (cheque_id, txid, vout) DO UPDATE
			SET block_height = COALESCE(excluded.block_height, block_height)
		`, chequeID, out.Txid, height); err != nil {
			return fmt.Errorf("record funding output: %w", err)
		}
	}
	return nil
}

// UpdateSwept marks a cheque as swept
func UpdateSwept(ctx context.Context, db *sql.DB, walletID string, id int64, txid string) error {
	now := time.Now()

	if err := database.CheckOne(db.ExecContext(ctx, `
		UPDATE cheques
		SET swept_txid = ?, swept_at = ?
		WHERE wallet_id = ? AND id = ?
	`, txid, now, walletID, id)); err != nil {
		return fmt.Errorf("update swept: %w", err)
	}
	return nil
}

// GetNextIndex returns the next unused cheque index for a specific wallet.
// A deleted cheque does not give its index back.
func GetNextIndex(ctx context.Context, db *sql.DB, walletID string) (uint32, error) {
	nextIndex, err := database.Get[uint32](ctx, db, `
		SELECT next_index FROM cheque_index_counters WHERE wallet_id = ?
	`, walletID)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return 0, nil
	case err != nil:
		return 0, fmt.Errorf("get next index: %w", err)
	}

	return nextIndex, nil
}

// Delete deletes a cheque by ID for a specific wallet
func Delete(ctx context.Context, db *sql.DB, walletID string, id int64) error {
	if err := database.CheckOne(db.ExecContext(ctx, `
		DELETE FROM cheques WHERE wallet_id = ? AND id = ?
	`, walletID, id)); err != nil {
		return fmt.Errorf("delete cheque: %w", err)
	}
	return nil
}

func CreateOrUpdateFromRecovery(ctx context.Context, db *sql.DB, walletID string, index uint32, address string, outputs []FundingOutput, amount uint64) error {
	// Check if cheque already exists
	existing, err := GetByAddress(ctx, db, walletID, address)
	if err != nil && !errors.Is(err, sql.ErrNoRows) {
		return fmt.Errorf("check existing cheque: %w", err)
	}

	if existing != nil {
		return UpdateFunding(ctx, db, walletID, existing.ID, outputs, amount)
	}

	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	// Create new cheque as already funded
	now := time.Now()
	result, err := tx.ExecContext(ctx, `
		INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address, actual_amount_sats, funded_at)
		VALUES (?, ?, ?, ?, ?, ?)
	`, walletID, index, amount, address, amount, now)
	if err != nil {
		return fmt.Errorf("create recovered cheque: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return fmt.Errorf("get last insert id: %w", err)
	}
	if err := recordFundingOutputs(ctx, tx, id, outputs); err != nil {
		return err
	}

	if err := bumpIndexCounter(ctx, tx, walletID, index); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit recovered cheque: %w", err)
	}

	return nil
}
