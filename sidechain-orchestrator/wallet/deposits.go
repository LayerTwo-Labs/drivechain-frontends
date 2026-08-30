package wallet

import (
	"context"
	"fmt"
	"time"
)

// SidechainDeposit is one deposit this install made to a sidechain treasury.
// Network is the chain the deposit was broadcast to; empty means the one the
// service is on now.
type SidechainDeposit struct {
	Network     string
	Txid        string
	WalletID    string
	Slot        uint32
	Destination string
	AmountSats  int64
	FeeSats     int64
	CreatedAt   time.Time
}

// RecordSidechainDeposit remembers a deposit the wallet just broadcast. An M5
// is a normal transaction on the wire, so nothing later can tell it apart from
// an ordinary send without this record.
func (s *Service) RecordSidechainDeposit(ctx context.Context, d SidechainDeposit) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("record sidechain deposit: database not open")
	}
	// A network swap racing this insert would otherwise file the row under the
	// chain we swapped to, hiding it from the one it was broadcast to.
	network := d.Network
	if network == "" {
		network = s.Network()
	}
	_, err := db.ExecContext(ctx, `
		INSERT INTO sidechain_deposits (network, txid, wallet_id, slot, destination, amount_sats, fee_sats, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT (network, txid) DO NOTHING`,
		network, d.Txid, d.WalletID, d.Slot, d.Destination, d.AmountSats, d.FeeSats, time.Now().Unix())
	if err != nil {
		return fmt.Errorf("insert sidechain deposit: %w", err)
	}
	return nil
}

// SidechainDeposits lists the deposits made to a slot, newest first. An empty
// walletID lists every wallet's.
func (s *Service) SidechainDeposits(ctx context.Context, slot uint32, walletID string) ([]SidechainDeposit, error) {
	db := s.db()
	if db == nil {
		return nil, fmt.Errorf("list sidechain deposits: database not open")
	}
	rows, err := db.QueryContext(ctx, `
		SELECT txid, wallet_id, slot, destination, amount_sats, fee_sats, created_at
		FROM sidechain_deposits
		WHERE network = ? AND slot = ? AND (? = '' OR wallet_id = ?)
		ORDER BY created_at DESC`, s.Network(), slot, walletID, walletID)
	if err != nil {
		return nil, fmt.Errorf("query sidechain deposits: %w", err)
	}
	defer func() { _ = rows.Close() }()

	var out []SidechainDeposit
	for rows.Next() {
		var d SidechainDeposit
		var createdAt int64
		if err := rows.Scan(&d.Txid, &d.WalletID, &d.Slot, &d.Destination, &d.AmountSats, &d.FeeSats, &createdAt); err != nil {
			return nil, fmt.Errorf("scan sidechain deposit: %w", err)
		}
		d.CreatedAt = time.Unix(createdAt, 0)
		out = append(out, d)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read sidechain deposits: %w", err)
	}
	return out, nil
}

// SidechainDepositTotals sums what this install deposited: all time, and since
// `since`. Both in sats. An empty walletID sums every wallet's.
func (s *Service) SidechainDepositTotals(ctx context.Context, since time.Time, walletID string) (int64, int64, error) {
	db := s.db()
	if db == nil {
		return 0, 0, fmt.Errorf("sum sidechain deposits: database not open")
	}
	var total, recent int64
	err := db.QueryRowContext(ctx, `
		SELECT
			COALESCE(SUM(amount_sats), 0),
			COALESCE(SUM(CASE WHEN created_at >= ? THEN amount_sats ELSE 0 END), 0)
		FROM sidechain_deposits
		WHERE network = ? AND (? = '' OR wallet_id = ?)`, since.Unix(), s.Network(), walletID, walletID).Scan(&total, &recent)
	if err != nil {
		return 0, 0, fmt.Errorf("sum sidechain deposits: %w", err)
	}
	return total, recent, nil
}
