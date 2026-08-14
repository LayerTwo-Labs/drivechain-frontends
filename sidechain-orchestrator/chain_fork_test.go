package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// The node that stopped on drynet4: it holds its own 979028 and refuses the
// branch at the same height that every peer builds on.
func TestForkStateFromReportsARefusedBranch(t *testing.T) {
	state := forkStateFrom(
		[]coreChainTip{
			{Height: 979029, Status: "invalid", BranchLen: 2},
			{Height: 979028, Status: "active", BranchLen: 0},
			{Height: 979028, Status: "headers-only", BranchLen: 1},
		},
		[]corePeerTip{{SyncedHeaders: 979157}, {StartHeight: 979100}},
	)

	assert.True(t, state.RejectedBranch)
	assert.Equal(t, int64(979157), state.PeerBestHeight)
}

// Old forks sit below the tip on every long-running node. They say nothing
// about the chain the node follows today.
func TestForkStateFromIgnoresAnOldFork(t *testing.T) {
	state := forkStateFrom(
		[]coreChainTip{
			{Height: 500000, Status: "invalid", BranchLen: 1},
			{Height: 979028, Status: "active", BranchLen: 0},
		},
		[]corePeerTip{{SyncedHeaders: 979028}},
	)

	assert.False(t, state.RejectedBranch)
	assert.Equal(t, int64(979028), state.PeerBestHeight)
}

// A node with no peers knows no better tip. It must not claim a fork.
func TestForkStateFromWithoutPeers(t *testing.T) {
	state := forkStateFrom(
		[]coreChainTip{{Height: 979028, Status: "active", BranchLen: 0}},
		nil,
	)

	assert.False(t, state.RejectedBranch)
	assert.Zero(t, state.PeerBestHeight)
}
