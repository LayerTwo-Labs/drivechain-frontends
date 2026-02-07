package demo

import (
	"context"
	"database/sql"
	"fmt"
	"math/rand"
	"time"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
)

// ActionType represents the type of sidechain action
type ActionType string

const (
	ActionDeposit           ActionType = "deposit"
	ActionWithdrawal        ActionType = "withdrawal"
	ActionWithdrawalAck     ActionType = "withdrawal_ack"
	ActionSidechainProposal ActionType = "sidechain_proposal"
	ActionSidechainAck      ActionType = "sidechain_ack"
)

// DemoAction represents a recent action in demo mode
type DemoAction struct {
	ID            int64
	ActionType    ActionType
	SidechainSlot uint32
	SidechainName string
	AmountSatoshi int64
	AckCount      uint32
	AckTotal      uint32
	ExtraInfo     string
	CreatedAt     int64
}

// GetRecentActions returns recent demo actions from the database
func GetRecentActions(ctx context.Context, db *sql.DB, limit uint32) ([]*pb.RecentAction, error) {
	if limit == 0 {
		limit = 10
	}

	rows, err := db.QueryContext(ctx, `
		SELECT id, action_type, sidechain_slot, sidechain_name,
		       COALESCE(amount_satoshi, 0), COALESCE(ack_count, 0),
		       COALESCE(ack_total, 0), COALESCE(extra_info, ''), created_at
		FROM demo_recent_actions
		ORDER BY created_at DESC
		LIMIT ?
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("query demo actions: %w", err)
	}
	defer rows.Close()

	var actions []*pb.RecentAction
	for rows.Next() {
		var action DemoAction
		if err := rows.Scan(
			&action.ID, &action.ActionType, &action.SidechainSlot, &action.SidechainName,
			&action.AmountSatoshi, &action.AckCount, &action.AckTotal, &action.ExtraInfo, &action.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan demo action: %w", err)
		}

		actions = append(actions, &pb.RecentAction{
			ActionType:    string(action.ActionType),
			SidechainSlot: action.SidechainSlot,
			SidechainName: action.SidechainName,
			AmountSatoshi: action.AmountSatoshi,
			AckCount:      action.AckCount,
			AckTotal:      action.AckTotal,
			ExtraInfo:     action.ExtraInfo,
			CreatedAt:     action.CreatedAt,
		})
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate demo actions: %w", err)
	}

	return actions, nil
}

// GetActionStats returns summary statistics for demo actions
func GetActionStats(ctx context.Context, db *sql.DB) (string, error) {
	// Count actions in the last 30 days
	thirtyDaysAgo := time.Now().AddDate(0, 0, -30).Unix()

	var count int64
	err := db.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM demo_recent_actions WHERE created_at > ?
	`, thirtyDaysAgo).Scan(&count)
	if err != nil {
		return "", fmt.Errorf("count demo actions: %w", err)
	}

	// Format with thousands separator
	return fmt.Sprintf("Users have made %s transactions last month", formatWithCommas(count)), nil
}

// InsertDemoAction inserts a new demo action into the database
func InsertDemoAction(ctx context.Context, db *sql.DB, action *DemoAction) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO demo_recent_actions
		(action_type, sidechain_slot, sidechain_name, amount_satoshi, ack_count, ack_total, extra_info, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`, action.ActionType, action.SidechainSlot, action.SidechainName,
		action.AmountSatoshi, action.AckCount, action.AckTotal, action.ExtraInfo, action.CreatedAt)
	if err != nil {
		return fmt.Errorf("insert demo action: %w", err)
	}
	return nil
}

// CleanupOldActions removes actions older than 7 days to keep the table small
func CleanupOldActions(ctx context.Context, db *sql.DB) error {
	sevenDaysAgo := time.Now().AddDate(0, 0, -7).Unix()
	_, err := db.ExecContext(ctx, `
		DELETE FROM demo_recent_actions WHERE created_at < ?
	`, sevenDaysAgo)
	if err != nil {
		return fmt.Errorf("cleanup old actions: %w", err)
	}
	return nil
}

// GenerateRandomAction creates a random demo action
func GenerateRandomAction(sidechains []DemoSidechain) *DemoAction {
	if len(sidechains) == 0 {
		return nil
	}

	// Pick a random sidechain
	sc := sidechains[rand.Intn(len(sidechains))]

	// Pick a random action type with weighted probability
	// Deposits and withdrawals more common than proposals
	actionTypes := []ActionType{
		ActionDeposit, ActionDeposit, ActionDeposit,
		ActionWithdrawal, ActionWithdrawal,
		ActionWithdrawalAck, ActionWithdrawalAck,
		ActionSidechainAck,
		ActionSidechainProposal,
	}
	actionType := actionTypes[rand.Intn(len(actionTypes))]

	action := &DemoAction{
		ActionType:    actionType,
		SidechainSlot: sc.Slot,
		SidechainName: sc.Title,
		CreatedAt:     time.Now().Unix(),
	}

	switch actionType {
	case ActionDeposit:
		// Random deposit between 0.001 and 10 BTC
		action.AmountSatoshi = int64(rand.Intn(999900000) + 100000)

	case ActionWithdrawal:
		// Random withdrawal between 0.01 and 5 BTC
		action.AmountSatoshi = int64(rand.Intn(499000000) + 1000000)

	case ActionWithdrawalAck:
		// Random ack progress
		action.AckTotal = uint32(rand.Intn(10000) + 10000) // 10000-20000 total
		action.AckCount = uint32(rand.Intn(int(action.AckTotal)))

	case ActionSidechainProposal:
		// New sidechain proposal
		names := []string{"Ethereum L2", "Monero Bridge", "NFT Chain", "DeFi Hub", "Gaming Chain"}
		action.ExtraInfo = names[rand.Intn(len(names))]
		action.AckTotal = 256
		action.AckCount = uint32(rand.Intn(200))

	case ActionSidechainAck:
		// Sidechain activation ack
		action.ExtraInfo = fmt.Sprintf("%s at slot %d", sc.Title, sc.Slot)
	}

	return action
}

// GetDemoSidechainsForActions returns sidechain info needed for action generation
func GetDemoSidechainsForActions(ctx context.Context, db *sql.DB) ([]DemoSidechain, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT slot, title FROM demo_sidechains ORDER BY slot
	`)
	if err != nil {
		return nil, fmt.Errorf("query demo sidechains: %w", err)
	}
	defer rows.Close()

	var sidechains []DemoSidechain
	for rows.Next() {
		var sc DemoSidechain
		if err := rows.Scan(&sc.Slot, &sc.Title); err != nil {
			return nil, fmt.Errorf("scan sidechain: %w", err)
		}
		sidechains = append(sidechains, sc)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate sidechains: %w", err)
	}

	return sidechains, nil
}

// formatWithCommas formats a number with comma separators
func formatWithCommas(n int64) string {
	if n < 0 {
		return "-" + formatWithCommas(-n)
	}
	if n < 1000 {
		return fmt.Sprintf("%d", n)
	}
	return formatWithCommas(n/1000) + "," + fmt.Sprintf("%03d", n%1000)
}
