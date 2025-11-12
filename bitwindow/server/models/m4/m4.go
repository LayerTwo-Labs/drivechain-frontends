package m4

import (
	"time"
)

// WithdrawalBundle represents a pending withdrawal from a sidechain
type WithdrawalBundle struct {
	ID                int64
	SidechainSlot     uint8
	BundleHash        string // hex encoded
	WorkScore         uint16 // Current ACK count
	BlocksLeft        uint32 // Until expiration
	MaxAge            uint32 // Total blocks allowed
	FirstSeenHeight   uint32
	LastUpdatedHeight uint32
	Status            BundleStatus
	CreatedAt         time.Time
	UpdatedAt         time.Time
}

type BundleStatus string

const (
	BundleStatusPending  BundleStatus = "pending"
	BundleStatusApproved BundleStatus = "approved" // >= 13,150 ACKs
	BundleStatusFailed   BundleStatus = "failed"   // < 13,150 and expired
	BundleStatusExpired  BundleStatus = "expired"
)

// M4Message represents a parsed M4 message from a block
type M4Message struct {
	ID          int64
	BlockHeight uint32
	BlockHash   string
	BlockTime   time.Time
	RawBytes    []byte
	Version     uint8
	Votes       []M4Vote
	CreatedAt   time.Time
}

// M4Vote represents a single sidechain vote within an M4
type M4Vote struct {
	ID            int64
	M4MessageID   int64
	SidechainSlot uint8
	VoteType      VoteType
	BundleHash    *string // nil for abstain/alarm
	BundleIndex   *uint16 // nil for abstain/alarm
}

type VoteType string

const (
	VoteTypeAbstain VoteType = "abstain"
	VoteTypeAlarm   VoteType = "alarm"
	VoteTypeUpvote  VoteType = "upvote"
)

// Sidechain represents an active sidechain
type Sidechain struct {
	Slot            uint8
	Name            string
	Description     string
	Version         string
	ActivatedHeight *uint32
	CreatedAt       time.Time
}

// VotePreference represents user's desired vote
type VotePreference struct {
	SidechainSlot uint8
	VoteType      VoteType
	BundleHash    *string
	UpdatedAt     time.Time
}

// M3Message represents a withdrawal bundle proposal
type M3Message struct {
	ID            int64
	BlockHeight   uint32
	BlockHash     string
	BlockTime     time.Time
	SidechainSlot uint8
	BundleHash    string // hex encoded
	CreatedAt     time.Time
}

// Constants from BIP300
const (
	M3CommitmentHeader = 0xD45AA943 // M3 magic bytes (Propose Withdrawal)
	M4CommitmentHeader = 0xD77D1776 // M4 magic bytes (ACK Withdrawal)
	MinWorkScore       = 13150      // Minimum ACKs for approval
	WithdrawalMaxAge   = 26300      // ~6 months in blocks

	// Special vote values
	VoteAbstain = 0xFFFF
	VoteAlarm   = 0xFFFE
)
