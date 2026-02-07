package demo

import (
	"context"
	"database/sql"
	"fmt"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
)

// DemoSidechain represents a sidechain in demo mode
type DemoSidechain struct {
	Slot           uint32
	Title          string
	Description    string
	BalanceSatoshi int64
	HashID1        string
	HashID2        string
	LastDepositAt  int64
}

// GetDemoSidechains returns all demo sidechains from the database
func GetDemoSidechains(ctx context.Context, db *sql.DB) ([]*pb.ListSidechainsResponse_Sidechain, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT slot, title, description, balance_satoshi, hashid1, hashid2, last_deposit_at
		FROM demo_sidechains
		ORDER BY slot
	`)
	if err != nil {
		return nil, fmt.Errorf("query demo sidechains: %w", err)
	}
	defer rows.Close()

	var sidechains []*pb.ListSidechainsResponse_Sidechain
	for rows.Next() {
		var sc DemoSidechain
		if err := rows.Scan(&sc.Slot, &sc.Title, &sc.Description, &sc.BalanceSatoshi, &sc.HashID1, &sc.HashID2, &sc.LastDepositAt); err != nil {
			return nil, fmt.Errorf("scan demo sidechain: %w", err)
		}

		sidechains = append(sidechains, &pb.ListSidechainsResponse_Sidechain{
			Title:          sc.Title,
			Description:    sc.Description,
			Slot:           sc.Slot,
			BalanceSatoshi: sc.BalanceSatoshi,
			Hashid1:        sc.HashID1,
			Hashid2:        sc.HashID2,
			// Demo sidechains are always "active" with mock data
			VoteCount:        13140, // Enough votes to be activated
			ProposalHeight:   100000,
			ActivationHeight: 100144,
			Nversion:         0,
			ChaintipTxid:     fmt.Sprintf("demo%02d00000000000000000000000000000000000000000000000000000000", sc.Slot),
			ChaintipVout:     0,
		})
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate demo sidechains: %w", err)
	}

	return sidechains, nil
}

// UpdateDemoBalance updates the balance of a demo sidechain
func UpdateDemoBalance(ctx context.Context, db *sql.DB, slot uint32, additionalSats int64) error {
	_, err := db.ExecContext(ctx, `
		UPDATE demo_sidechains
		SET balance_satoshi = balance_satoshi + ?,
		    last_deposit_at = strftime('%s', 'now')
		WHERE slot = ?
	`, additionalSats, slot)
	if err != nil {
		return fmt.Errorf("update demo balance: %w", err)
	}
	return nil
}

// GetDemoSidechainSlots returns the slot numbers of all demo sidechains
func GetDemoSidechainSlots(ctx context.Context, db *sql.DB) ([]uint32, error) {
	rows, err := db.QueryContext(ctx, `SELECT slot FROM demo_sidechains ORDER BY slot`)
	if err != nil {
		return nil, fmt.Errorf("query demo slots: %w", err)
	}
	defer rows.Close()

	var slots []uint32
	for rows.Next() {
		var slot uint32
		if err := rows.Scan(&slot); err != nil {
			return nil, fmt.Errorf("scan slot: %w", err)
		}
		slots = append(slots, slot)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate demo slots: %w", err)
	}

	return slots, nil
}
