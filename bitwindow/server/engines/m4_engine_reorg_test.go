package engines

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
)

// TestM4Engine_PurgeReorgedState_DropsOrphanedBundles verifies that a
// withdrawal-bundle proposal seen only in an orphaned block does not survive a
// same-height reorg replay: PurgeReorgedState drops the bundle first seen at or
// above the replay height, while a bundle first seen below it is untouched.
// Without the purge the orphan lingers as 'pending' and GenerateM4Bytes votes
// on it.
func TestM4Engine_PurgeReorgedState_DropsOrphanedBundles(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	e := NewM4Engine(database.Test(t))

	blockTime := time.Date(2026, 6, 16, 4, 30, 0, 0, time.UTC)

	// Bundle first seen below the reorg window — must survive.
	require.NoError(t, e.persistM3Message(ctx, &m4.M3Message{
		BlockHeight:   90,
		BlockHash:     "old",
		BlockTime:     blockTime,
		SidechainSlot: 0,
		BundleHash:    "aaaa",
	}))

	// Orphaned bundle first seen only in the block we're about to replay.
	require.NoError(t, e.persistM3Message(ctx, &m4.M3Message{
		BlockHeight:   100,
		BlockHash:     "orphan",
		BlockTime:     blockTime,
		SidechainSlot: 0,
		BundleHash:    "bbbb",
	}))

	before, err := e.GetWithdrawalBundles(ctx, nil)
	require.NoError(t, err)
	require.Len(t, before, 2)

	// Reorg replays from height 100 downward through the rewind window.
	require.NoError(t, e.PurgeReorgedState(ctx, 100))

	after, err := e.GetWithdrawalBundles(ctx, nil)
	require.NoError(t, err)
	require.Len(t, after, 1)
	require.Equal(t, "aaaa", after[0].BundleHash)
}
