package wallet

import (
	"context"
	"fmt"
	"time"
)

// SidechainDeposit is one deposit this install made to a sidechain treasury.
type SidechainDeposit struct {
	Txid        string
	WalletID    string
	Slot        uint32
	Destination string
	AmountSats  int64
	FeeSats     int64
	CreatedAt   time.Time
	// CreditedAt is when the sidechain first held the coin. It is the zero
	// time while the sidechain still knows nothing of the deposit.
	CreditedAt time.Time
	// DroppedAt is when the network last held no copy of the deposit. It is
	// the zero time while the deposit can still confirm.
	DroppedAt time.Time
}

// RecordSidechainDeposit remembers a deposit the wallet just broadcast. An M5
// is a normal transaction on the wire, so nothing later can tell it apart from
// an ordinary send without this record.
func (s *Service) RecordSidechainDeposit(ctx context.Context, d SidechainDeposit) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("record sidechain deposit: database not open")
	}
	_, err := db.ExecContext(ctx, `
		INSERT INTO sidechain_deposits (network, txid, wallet_id, slot, destination, amount_sats, fee_sats, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT (network, txid) DO NOTHING`,
		s.Network(), d.Txid, d.WalletID, d.Slot, d.Destination, d.AmountSats, d.FeeSats, time.Now().Unix())
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
		SELECT txid, wallet_id, slot, destination, amount_sats, fee_sats, created_at, credited_at, dropped_at
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
		var createdAt, creditedAt, droppedAt int64
		if err := rows.Scan(&d.Txid, &d.WalletID, &d.Slot, &d.Destination, &d.AmountSats, &d.FeeSats, &createdAt, &creditedAt, &droppedAt); err != nil {
			return nil, fmt.Errorf("scan sidechain deposit: %w", err)
		}
		d.CreatedAt = time.Unix(createdAt, 0)
		if creditedAt > 0 {
			d.CreditedAt = time.Unix(creditedAt, 0)
		}
		if droppedAt > 0 {
			d.DroppedAt = time.Unix(droppedAt, 0)
		}
		out = append(out, d)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read sidechain deposits: %w", err)
	}
	return out, nil
}

// MarkSidechainDepositCredited stamps the deposit the sidechain now holds a
// coin for. The stamp never clears, so a later spend of that coin cannot read
// the deposit back as an unconfirmed balance.
func (s *Service) MarkSidechainDepositCredited(ctx context.Context, txid string) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("credit sidechain deposit: database not open")
	}
	// The drop watch and the credit read race, so a deposit can carry a stamp
	// the sidechain just disproved. The coin arrived, so the stamp goes.
	_, err := db.ExecContext(ctx, `
		UPDATE sidechain_deposits SET credited_at = ?, dropped_at = 0
		WHERE network = ? AND txid = ? AND credited_at = 0`,
		time.Now().Unix(), s.Network(), txid)
	if err != nil {
		return fmt.Errorf("credit sidechain deposit: %w", err)
	}
	return nil
}

// MarkSidechainDepositDropped stamps a deposit the network no longer holds.
// A credited deposit is never dropped: the sidechain already took the coin.
func (s *Service) MarkSidechainDepositDropped(ctx context.Context, txid string) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("drop sidechain deposit: database not open")
	}
	_, err := db.ExecContext(ctx, `
		UPDATE sidechain_deposits SET dropped_at = ?
		WHERE network = ? AND txid = ? AND dropped_at = 0 AND credited_at = 0`,
		time.Now().Unix(), s.Network(), txid)
	if err != nil {
		return fmt.Errorf("drop sidechain deposit: %w", err)
	}
	return nil
}

// ClearSidechainDepositDrop lifts the stamp when the deposit turns up again,
// so a source that was briefly wrong cannot bury a live deposit.
func (s *Service) ClearSidechainDepositDrop(ctx context.Context, txid string) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("clear the drop of a sidechain deposit: database not open")
	}
	_, err := db.ExecContext(ctx, `
		UPDATE sidechain_deposits SET dropped_at = 0
		WHERE network = ? AND txid = ? AND dropped_at != 0`, s.Network(), txid)
	if err != nil {
		return fmt.Errorf("clear the drop of a sidechain deposit: %w", err)
	}
	return nil
}

// SidechainDepositTotals sums what this install deposited: all time, and since
// the given moment. A dropped attempt moved no coin, and the retry that
// replaces it carries its own row, so it counts for neither.
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
		WHERE network = ? AND (? = '' OR wallet_id = ?) AND dropped_at = 0`,
		since.Unix(), s.Network(), walletID, walletID).Scan(&total, &recent)
	if err != nil {
		return 0, 0, fmt.Errorf("sum sidechain deposits: %w", err)
	}
	return total, recent, nil
}

// RepointSidechainDeposit moves a deposit record onto the transaction that
// replaced it. A fee bump makes a new txid and a new fee, and without this the
// old row reads as a deposit the network lost while the coin is still on its
// way, under a fee the user no longer pays.
func (s *Service) RepointSidechainDeposit(ctx context.Context, oldTxid, newTxid string, feeSats int64) error {
	db := s.db()
	if db == nil {
		return fmt.Errorf("repoint sidechain deposit: database not open")
	}
	_, err := db.ExecContext(ctx, `
		UPDATE sidechain_deposits SET txid = ?, fee_sats = ?, dropped_at = 0
		WHERE network = ? AND txid = ?`, newTxid, feeSats, s.Network(), oldTxid)
	if err != nil {
		return fmt.Errorf("repoint sidechain deposit: %w", err)
	}
	return nil
}

// SidechainDepositSlots lists the slots this install deposited to. The deposit
// watch reads it rather than the local binary list: a slot the enforcer holds
// takes a deposit even with no binary configured here.
func (s *Service) SidechainDepositSlots(ctx context.Context) ([]uint32, error) {
	db := s.db()
	if db == nil {
		return nil, fmt.Errorf("list sidechain deposit slots: database not open")
	}
	rows, err := db.QueryContext(ctx, `
		SELECT DISTINCT slot FROM sidechain_deposits
		WHERE network = ? AND credited_at = 0`, s.Network())
	if err != nil {
		return nil, fmt.Errorf("query sidechain deposit slots: %w", err)
	}
	defer func() { _ = rows.Close() }()

	var slots []uint32
	for rows.Next() {
		var slot uint32
		if err := rows.Scan(&slot); err != nil {
			return nil, fmt.Errorf("scan sidechain deposit slot: %w", err)
		}
		slots = append(slots, slot)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read sidechain deposit slots: %w", err)
	}
	return slots, nil
}
