package engines

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/stretchr/testify/require"
)

// The chain reset replaces a delete of bitwindow.db, so it has to clear every
// block-derived row. op_returns keeps its old height on re-insert, so a row
// left behind names a block the new chain never had.
func TestResetProcessedChainClearsOPReturns(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	_, err := db.ExecContext(ctx, `
		INSERT INTO op_returns (txid, vout, op_return_data, fee_sats, height)
		VALUES ('confirmed', 0, 'from the retired fork', 100, 963700),
		       ('mempool', 0, 'still unconfirmed', 100, NULL)`)
	require.NoError(t, err)

	require.NoError(t, p.resetProcessedChain(ctx))

	var confirmed, mempool int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM op_returns WHERE height IS NOT NULL`).Scan(&confirmed))
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM op_returns WHERE height IS NULL`).Scan(&mempool))

	require.Zero(t, confirmed, "confirmed op_returns belong to the chain that went away")
	require.Equal(t, 1, mempool, "mempool op_returns are not block-derived")
}

// The user's own rows are not chain data. The reset that a network change now
// relies on must leave every one of them in place.
func TestResetProcessedChainKeepsTheUsersRows(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	_, err := db.ExecContext(ctx,
		`INSERT INTO address_book (wallet_id, label, address, direction) VALUES ('w1', 'mum', 'bc1qexample', 'receive')`)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx,
		`INSERT INTO transaction_notes (wallet_id, txid, note) VALUES ('w1', 'deadbeef', 'rent')`)
	require.NoError(t, err)

	require.NoError(t, p.resetProcessedChain(ctx))

	var addresses, notes int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM address_book`).Scan(&addresses))
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM transaction_notes`).Scan(&notes))
	require.Equal(t, 1, addresses, "the address book is the user's, not the chain's")
	require.Equal(t, 1, notes, "transaction notes are the user's, not the chain's")
}

// seedBundleRow inserts a bundle with a chosen aggregate.
func seedBundleRow(t *testing.T, ctx context.Context, db *sql.DB, hash string, firstSeen, lastUpdated, score uint32) {
	t.Helper()
	_, err := db.ExecContext(ctx, `INSERT OR IGNORE INTO sidechains (slot, name) VALUES (0, 'test')`)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `
		INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, work_score, blocks_left,
			first_seen_height, last_updated_height, status)
		VALUES (0, ?, ?, 100, ?, ?, 'pending')`, hash, score, firstSeen, lastUpdated)
	require.NoError(t, err)
}

func bundleAggregate(t *testing.T, ctx context.Context, db *sql.DB, hash string) (score, lastUpdated uint32, found bool) {
	t.Helper()
	err := db.QueryRowContext(ctx,
		`SELECT work_score, last_updated_height FROM withdrawal_bundles WHERE bundle_hash = ?`,
		hash).Scan(&score, &lastUpdated)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, 0, false
	}
	require.NoError(t, err)
	return score, lastUpdated, true
}

// A bundle whose score the orphan branch moved cannot be rebuilt by a query:
// the score is a running count with a floor. The purge takes the replay back to
// the bundle's own first block instead, and clears what the branch left.
func TestForkPurgeReplaysFromABundleTheOrphanBranchScored(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	// Scored at 1000, above the fork at 950, so the branch that went away
	// touched it.
	seedBundleRow(t, ctx, db, "scored-above-the-fork", 900, 1000, 42)
	// Not touched by the fork itself, but the widened window reaches it, so its
	// own history has to be replayed too.
	seedBundleRow(t, ctx, db, "inside-the-window", 880, 920, 7)
	// Settled below the window. Nothing replays it, so nothing may touch it.
	seedBundleRow(t, ctx, db, "below-the-window", 800, 850, 5)

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	// 950 drags in the bundle first seen at 900, which drags in the one first
	// seen at 880. Stopping at 900 would clear that one with blocks 880-899
	// never replayed.
	require.Equal(t, uint32(880), replayFrom, "the window widens until it stops moving")

	_, _, found := bundleAggregate(t, ctx, db, "scored-above-the-fork")
	require.False(t, found, "the replay rebuilds it from its own first block")

	_, _, found = bundleAggregate(t, ctx, db, "inside-the-window")
	require.False(t, found, "the widened window rebuilds it too")

	score, lastUpdated, found := bundleAggregate(t, ctx, db, "below-the-window")
	require.True(t, found)
	require.Equal(t, uint32(5), score, "nothing replays it, so nothing may touch it")
	require.Equal(t, uint32(850), lastUpdated)
}

// With no bundle for the orphan branch to have scored, the replay starts at the
// fork and no aggregate moves.
func TestForkPurgeStaysAtTheForkWithNoTouchedBundle(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	seedBundleRow(t, ctx, db, "settled-below-the-fork", 900, 940, 42)

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	require.Equal(t, uint32(950), replayFrom)

	score, _, found := bundleAggregate(t, ctx, db, "settled-below-the-fork")
	require.True(t, found)
	require.Equal(t, uint32(42), score, "a bundle the fork never reached keeps its score")
}

// The default topics are seeded by a migration at height 0 with an empty txid.
// No block replays them, so a purge that takes them loses them for good — the
// migration is already recorded and never runs again.
func TestForkPurgeKeepsTheBootstrapTopics(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	// A topic created on chain, which a replay rebuilds.
	_, err := db.ExecContext(ctx,
		`INSERT INTO cn_topics (topic, name, retention_days, created_height, txid)
		 VALUES (x'b1b1b1b1', 'On Chain', 30, 900, 'deadbeef')`)
	require.NoError(t, err)

	_, err = p.purgeAtOrAbove(ctx, 0)
	require.NoError(t, err)

	var bootstrap, onChain int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM cn_topics WHERE txid = ''`).Scan(&bootstrap))
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM cn_topics WHERE txid != ''`).Scan(&onChain))

	require.Equal(t, 2, bootstrap, "the seeded default topics must survive")
	require.Zero(t, onChain, "a topic a replay rebuilds must go")
}

// A bundle can go terminal without a vote: updateBundleStates ages it out. That
// transition has to stamp its height, or the purge cannot tell a bundle that
// failed on the branch that went away from one that failed below the fork.
func TestBundleAgeingStampsTheHeightSoAForkPurgeSeesIt(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	// Last voted at 900, so no vote moves it. It ages out at 1000, above the
	// fork at 950.
	seedBundleRow(t, ctx, db, "aged-out-above-the-fork", 880, 900, 0)
	_, err := db.ExecContext(ctx, `UPDATE withdrawal_bundles SET max_age = 0, blocks_left = 0`)
	require.NoError(t, err)

	require.NoError(t, p.m4Engine.updateBundleStates(ctx, 1000))

	_, lastUpdated, found := bundleAggregate(t, ctx, db, "aged-out-above-the-fork")
	require.True(t, found)
	require.Equal(t, uint32(1000), lastUpdated, "the transition must stamp its height")

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	require.Equal(t, uint32(880), replayFrom, "the replay must rebuild it from its first block")

	_, _, found = bundleAggregate(t, ctx, db, "aged-out-above-the-fork")
	require.False(t, found, "the orphan branch's terminal state must not survive")
}

// A terminal bundle written before the transitions stamped their height carries
// only its last vote. The replay cannot repair it — every update guards on
// status = 'pending' — so the purge has to take it.
func TestForkPurgeTakesLegacyTerminalBundles(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	// Last vote at 900, below the fork, and no stamp. max_age reaches past the
	// fork, so it could only have aged out on the branch that went away.
	seedBundleRow(t, ctx, db, "legacy-expired", 900, 900, 3)
	_, err := db.ExecContext(ctx,
		`UPDATE withdrawal_bundles SET status = 'expired', max_age = 100, blocks_left = 0`)
	require.NoError(t, err)

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	require.Equal(t, uint32(900), replayFrom, "the replay must rebuild it from its first block")

	_, _, found := bundleAggregate(t, ctx, db, "legacy-expired")
	require.False(t, found, "a terminal state the replay cannot repair must go")
}

// One that aged out below the window stays: blocks_left reaches 0 only at
// first_seen_height + max_age, and that is under the fork.
func TestForkPurgeKeepsABundleThatAgedOutBelowTheWindow(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	seedBundleRow(t, ctx, db, "expired-long-ago", 800, 800, 3)
	_, err := db.ExecContext(ctx,
		`UPDATE withdrawal_bundles SET status = 'expired', max_age = 10, blocks_left = 0`)
	require.NoError(t, err)

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	require.Equal(t, uint32(950), replayFrom, "nothing below the fork had to move")

	_, _, found := bundleAggregate(t, ctx, db, "expired-long-ago")
	require.True(t, found, "a bundle the fork never reached keeps its state")
}

// A stamped terminal bundle carries the height its transition happened at, so
// the conservative fallback must not reach it. Without that guard every
// approved bundle pulls the window back and a one-block reorg rescans years.
func TestForkPurgeLeavesStampedTerminalBundlesAlone(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db)}

	seedBundleRow(t, ctx, db, "approved-long-ago", 800, 850, 20000)
	_, err := db.ExecContext(ctx,
		`UPDATE withdrawal_bundles SET status = 'approved', status_stamped = 1`)
	require.NoError(t, err)

	replayFrom, err := p.purgeAtOrAbove(ctx, 950)
	require.NoError(t, err)
	require.Equal(t, uint32(950), replayFrom, "a stamped bundle says it ended below the fork")

	score, _, found := bundleAggregate(t, ctx, db, "approved-long-ago")
	require.True(t, found)
	require.Equal(t, uint32(20000), score, "nothing replays it, so nothing may touch it")
}
