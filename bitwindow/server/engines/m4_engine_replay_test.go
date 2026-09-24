package engines

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/stretchr/testify/require"
)

// seedBundle inserts a pending bundle on slot 0.
func seedBundle(t *testing.T, ctx context.Context, e *M4Engine, hash string, firstSeen uint32) {
	t.Helper()
	_, err := e.db.ExecContext(ctx, `INSERT OR IGNORE INTO sidechains (slot, name) VALUES (0, 'test')`)
	require.NoError(t, err)
	_, err = e.db.ExecContext(ctx, `
		INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, work_score, blocks_left,
			first_seen_height, last_updated_height, status)
		VALUES (0, ?, 1, ?, ?, ?, 'pending')`,
		hash, m4.WithdrawalMaxAge, firstSeen, firstSeen)
	require.NoError(t, err)
}

func bundleState(t *testing.T, ctx context.Context, e *M4Engine, hash string) (workScore, blocksLeft int, status string) {
	t.Helper()
	require.NoError(t, e.db.QueryRowContext(ctx,
		`SELECT work_score, blocks_left, status FROM withdrawal_bundles WHERE bundle_hash = ?`, hash,
	).Scan(&workScore, &blocksLeft, &status))
	return
}

// Replaying the same height after a reorg must not age a bundle twice.
func TestUpdateBundleStates_ReplayIsIdempotent(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	e := NewM4Engine(db)

	seedBundle(t, ctx, e, "bundle-a", 100)

	require.NoError(t, e.updateBundleStates(ctx, 120))
	_, afterFirst, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, m4.WithdrawalMaxAge-20, afterFirst, "blocks_left tracks height minus first seen")

	// Same height again, as a reorg replay would.
	require.NoError(t, e.updateBundleStates(ctx, 120))
	_, afterReplay, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, afterFirst, afterReplay, "replaying a height must not age the bundle twice")
}

// An upvote replayed at a height already counted must not score twice.
func TestApplyM4Votes_ReplayDoesNotDoubleCount(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	e := NewM4Engine(db)

	seedBundle(t, ctx, e, "bundle-a", 100)

	idx := uint16(0)
	msg := &m4.M4Message{Votes: []m4.M4Vote{{
		SidechainSlot: 0,
		VoteType:      m4.VoteTypeUpvote,
		BundleIndex:   &idx,
	}}}

	require.NoError(t, e.applyM4Votes(ctx, 150, msg))
	first, _, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, 2, first, "one upvote on top of the initial score")

	// Replay the same height.
	require.NoError(t, e.applyM4Votes(ctx, 150, msg))
	replayed, _, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, first, replayed, "replaying a height must not score the bundle twice")

	// A later height still counts.
	require.NoError(t, e.applyM4Votes(ctx, 151, msg))
	later, _, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, first+1, later, "a new height must still score")
}

// A bundle that died can be proposed again, and the new M3 restarts it.
func TestPersistM3Message_ReproposalRevivesDeadBundle(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	e := NewM4Engine(db)

	propose := func(height uint32) {
		t.Helper()
		require.NoError(t, e.persistM3Message(ctx, &m4.M3Message{
			BlockHeight:   height,
			BlockHash:     fmt.Sprintf("block-%d", height),
			BlockTime:     time.Now(),
			SidechainSlot: 0,
			BundleHash:    "bundle-a",
		}))
	}
	firstSeen := func() (height uint32) {
		t.Helper()
		require.NoError(t, db.QueryRowContext(ctx,
			`SELECT first_seen_height FROM withdrawal_bundles WHERE bundle_hash = ?`, "bundle-a").Scan(&height))
		return
	}

	propose(100)

	// Age it out without the votes to approve it.
	require.NoError(t, e.updateBundleStates(ctx, 100+m4.WithdrawalMaxAge))
	_, _, status := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, "failed", status)

	const reproposed = 100 + m4.WithdrawalMaxAge + 10
	propose(reproposed)

	score, blocksLeft, status := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, "pending", status, "a re-proposed bundle takes votes again")
	require.Equal(t, 1, score, "the score starts over")
	require.Equal(t, m4.WithdrawalMaxAge, blocksLeft, "so does the clock")
	require.Equal(t, uint32(reproposed), firstSeen())

	// A bundle still in play keeps what it has.
	idx := uint16(0)
	require.NoError(t, e.applyM4Votes(ctx, reproposed+1, &m4.M4Message{Votes: []m4.M4Vote{{
		SidechainSlot: 0,
		VoteType:      m4.VoteTypeUpvote,
		BundleIndex:   &idx,
	}}}))
	propose(reproposed + 5)

	score, _, _ = bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, 2, score, "a pending bundle keeps its score")
	require.Equal(t, uint32(reproposed), firstSeen(), "and its clock")
}

// A bundle first seen in an orphaned block must not survive the reorg purge.
func TestPurgeM4AtOrAbove(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	e := NewM4Engine(db)
	p := &Parser{db: db}

	seedBundle(t, ctx, e, "bundle-below", 100)
	seedBundle(t, ctx, e, "bundle-orphaned", 200)

	require.NoError(t, p.purgeM4AtOrAbove(ctx, 181))

	// Scanning the row at all asserts it survived.
	_, _, status := bundleState(t, ctx, e, "bundle-below")
	require.Equal(t, "pending", status, "bundles below the rewind target survive")

	var count int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM withdrawal_bundles WHERE bundle_hash = ?`, "bundle-orphaned").Scan(&count))
	require.Zero(t, count, "bundles born at or above the rewind target are wiped")
}
