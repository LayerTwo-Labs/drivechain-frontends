package m4

import (
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
)

type WithdrawalBundle struct {
	ID                int64        `db:"id"`
	SidechainSlot     uint8        `db:"sidechain_slot"`
	BundleHash        string       `db:"bundle_hash"` // hex encoded
	WorkScore         uint16       `db:"work_score"`  // Current ACK count
	BlocksLeft        uint32       `db:"blocks_left"` // Until expiration
	MaxAge            uint32       `db:"max_age"`     // Total blocks allowed
	FirstSeenHeight   uint32       `db:"first_seen_height"`
	LastUpdatedHeight uint32       `db:"last_updated_height"`
	Status            BundleStatus `db:"status"`
	CreatedAt         time.Time    `db:"created_at"`
	UpdatedAt         time.Time    `db:"updated_at"`
}

type BundleStatus string

const (
	BundleStatusPending  BundleStatus = "pending"
	BundleStatusApproved BundleStatus = "approved" // more ACKs than the inclusion threshold
	BundleStatusFailed   BundleStatus = "failed"   // expired without payout
	BundleStatusExpired  BundleStatus = "expired"
)

// M4Message represents a parsed M4 message from a block
type M4Message struct {
	ID          int64     `db:"id"`
	BlockHeight uint32    `db:"block_height"`
	BlockHash   string    `db:"block_hash"`
	BlockTime   time.Time `db:"block_time"`
	RawBytes    []byte    `db:"raw_bytes"`
	Version     uint8     `db:"version"`
	OutputIndex uint32
	Votes       []M4Vote
	CreatedAt   time.Time `db:"created_at"`
}

// M4Vote represents a single sidechain vote within an M4
type M4Vote struct {
	ID            int64    `db:"id"`
	M4MessageID   int64    `db:"m4_message_id"`
	SidechainSlot uint8    `db:"sidechain_slot"`
	VoteType      VoteType `db:"vote_type"`
	BundleHash    *string  `db:"bundle_hash"`  // nil for abstain/alarm
	BundleIndex   *uint16  `db:"bundle_index"` // nil for abstain/alarm
}

type VoteType string

const (
	VoteTypeAbstain VoteType = "abstain"
	VoteTypeAlarm   VoteType = "alarm"
	VoteTypeUpvote  VoteType = "upvote"
)

// M3Message represents a withdrawal bundle proposal
type M3Message struct {
	ID            int64
	BlockHeight   uint32
	BlockHash     string
	BlockTime     time.Time
	SidechainSlot uint8
	BundleHash    string // hex encoded
	VoteHeight    uint32
	OutputIndex   uint32
	CreatedAt     time.Time
}

// Constants from BIP300
const (
	M3CommitmentHeader = 0xD45AA943 // M3 magic bytes (Propose Withdrawal)
	M4CommitmentHeader = 0xD77D1776 // M4 magic bytes (ACK Withdrawal)

	// Special vote values
	VoteAbstain = 0xFFFF
	VoteAlarm   = 0xFFFE
)

// WithdrawalMaxAge returns the number of blocks a withdrawal bundle has for its
// votes, with the values of the enforcer.
func WithdrawalMaxAge(network config.Network) uint32 {
	if network == config.NetworkMainnet || network == config.NetworkECash {
		return 26300
	}
	return 10
}

// WithdrawalInclusionThreshold returns the number of ACKs a withdrawal bundle
// must exceed for approval on network, with the values of the enforcer.
func WithdrawalInclusionThreshold(network config.Network) uint16 {
	if network == config.NetworkMainnet || network == config.NetworkECash {
		return 13150
	}
	return 5
}
