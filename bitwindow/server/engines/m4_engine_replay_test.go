package engines

import (
	"context"
	"encoding/binary"
	"errors"
	"testing"
	"time"

	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

const testBundleMaxAge = 26300

// seedBundle inserts a pending bundle on slot 0.
func seedBundle(t *testing.T, ctx context.Context, e *M4Engine, hash string, firstSeen uint32) {
	t.Helper()
	_, err := e.db.ExecContext(ctx, `INSERT OR IGNORE INTO sidechains (slot, name) VALUES (0, 'test')`)
	require.NoError(t, err)
	_, err = e.db.ExecContext(ctx, `
		INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, work_score, blocks_left,
			first_seen_height, last_updated_height, status)
		VALUES (0, ?, 1, ?, ?, ?, 'pending')`,
		hash, testBundleMaxAge, firstSeen, firstSeen)
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
	ctx := t.Context()
	db := database.Test(t)
	e := NewM4Engine(db, config.NetworkMainnet, "")

	seedBundle(t, ctx, e, "bundle-a", 100)

	require.NoError(t, e.updateBundleStates(ctx, 120))
	_, afterFirst, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, testBundleMaxAge-20, afterFirst, "blocks_left tracks height minus first seen")

	// Same height again, as a reorg replay would.
	require.NoError(t, e.updateBundleStates(ctx, 120))
	_, afterReplay, _ := bundleState(t, ctx, e, "bundle-a")
	require.Equal(t, afterFirst, afterReplay, "replaying a height must not age the bundle twice")
}

// An upvote replayed at a height already counted must not score twice.
func TestApplyM4Votes_ReplayDoesNotDoubleCount(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	e := NewM4Engine(db, config.NetworkMainnet, "")

	seedBundle(t, ctx, e, "bundle-a", 100)

	msg := &m4.M4Message{Votes: []m4.M4Vote{{
		SidechainSlot: 0,
		VoteType:      m4.VoteTypeUpvote,
		BundleHash:    lo.ToPtr("bundle-a"),
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

func coinbaseBlockOf(script []byte, blockTime time.Time) *wire.MsgBlock {
	coinbase := &wire.MsgTx{
		TxIn:  []*wire.TxIn{{}},
		TxOut: []*wire.TxOut{{PkScript: script}},
	}
	return &wire.MsgBlock{
		Header:       wire.BlockHeader{Timestamp: blockTime},
		Transactions: []*wire.MsgTx{coinbase},
	}
}

func opReturnScript(t *testing.T, payload []byte) []byte {
	t.Helper()
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData(payload).Script()
	require.NoError(t, err)
	return script
}

func m3ProposalScript(t *testing.T, slot uint8, bundleHash [32]byte) []byte {
	payload := binary.BigEndian.AppendUint32(nil, m4.M3CommitmentHeader)
	payload = append(payload, slot)
	return opReturnScript(t, append(payload, bundleHash[:]...))
}

// m4Script builds a version 0x01 M4 with one byte per active sidechain.
func m4Script(t *testing.T, vector ...byte) []byte {
	payload := binary.BigEndian.AppendUint32(nil, m4.M4CommitmentHeader)
	return opReturnScript(t, append(append(payload, 0x01), vector...))
}

// enforcerAt serves an enforcer at tip with slot -> activation height.
func enforcerAt(t *testing.T, tip uint32, activations map[uint32]uint32) *service.Service[validatorrpc.ValidatorServiceClient] {
	var sidechains []*validatorpb.GetSidechainsResponse_SidechainInfo
	for slot, height := range activations {
		sidechains = append(sidechains, &validatorpb.GetSidechainsResponse_SidechainInfo{
			SidechainNumber:  wrapperspb.UInt32(slot),
			ActivationHeight: wrapperspb.UInt32(height),
		})
	}
	validator := mocks.NewMockValidatorServiceClient(gomock.NewController(t))
	validator.EXPECT().GetChainTip(gomock.Any(), gomock.Any()).
		Return(&validatorpb.GetChainTipResponse{
			BlockHeaderInfo: &validatorpb.BlockHeaderInfo{Height: tip},
		}, nil).
		AnyTimes()
	validator.EXPECT().GetSidechains(gomock.Any(), gomock.Any()).
		Return(&validatorpb.GetSidechainsResponse{Sidechains: sidechains}, nil).
		AnyTimes()
	return service.New("enforcer", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
		return validator, nil
	})
}

func workScoreOn(t *testing.T, ctx context.Context, p *Parser, slot uint8) int {
	t.Helper()
	var workScore int
	require.NoError(t, p.db.QueryRowContext(ctx,
		`SELECT work_score FROM withdrawal_bundles WHERE sidechain_slot = ?`, slot,
	).Scan(&workScore))
	return workScore
}

func TestProcessBlocks_AppliesM4InHeightOrder(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db, config.NetworkMainnet, ""), enforcer: enforcerAt(t, 101, map[uint32]uint32{0: 10})}

	blockTime := time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC)
	proposal := coinbaseBlockOf(m3ProposalScript(t, 0, [32]byte{0xab, 0xcd}), blockTime)
	upvote := coinbaseBlockOf(m4Script(t, 0x00), blockTime.Add(10*time.Minute))

	require.NoError(t, p.processBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(101), upvote),
		lo.T2(uint32(100), proposal),
	}))
	require.NoError(t, p.applyPendingM4(ctx))

	var workScore, lastUpdated int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT work_score, last_updated_height FROM withdrawal_bundles WHERE sidechain_slot = 0`,
	).Scan(&workScore, &lastUpdated))

	require.Equal(t, 2, workScore, "the upvote at 101 MUST score the bundle proposed at 100")
	require.Equal(t, 101, lastUpdated, "the vote from the highest block is the last one applied")
}

// The scan never waits on the enforcer. The M4 waits, then its second vote
// lands on slot 9, the second active slot. Slot 5 activates later.
func TestApplyPendingM4_WaitsForEnforcerThenUsesActiveSlots(t *testing.T) {
	ctx := t.Context()
	p := newCoinNewsParser(t)
	p.m4Engine = NewM4Engine(p.db, config.NetworkMainnet, "")
	activations := map[uint32]uint32{0: 10, 9: 20, 5: 500}
	p.enforcer = enforcerAt(t, 100, activations)

	story, err := codec.EncodeStory(codec.Story{Topic: codec.Topic{0x48, 0x4e, 0x53, 0x21}, Headline: "M4 waits"})
	require.NoError(t, err)
	blockTime := time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC)
	proposal := coinbaseBlockOf(m3ProposalScript(t, 9, [32]byte{0xab, 0xcd}), blockTime)
	upvote := coinbaseBlockOf(m4Script(t, 0xFF, 0x00), blockTime.Add(10*time.Minute))
	upvote.Transactions = append(upvote.Transactions, blockOf(t, [][]byte{story}, blockTime).Transactions[0])

	require.NoError(t, p.processBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(100), proposal),
		lo.T2(uint32(101), upvote),
	}))
	require.NoError(t, p.applyPendingM4(ctx))

	tip, err := blocks.GetProcessedTip(ctx, p.db)
	require.NoError(t, err)
	require.Equal(t, uint32(101), tip.Height, "the scan MUST NOT wait on the enforcer")
	var stories int
	require.NoError(t, p.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM cn_stories`).Scan(&stories))
	require.Equal(t, 1, stories, "CoinNews MUST NOT wait on the enforcer")
	require.Equal(t, 1, workScoreOn(t, ctx, p, 9), "the M4 waits for the enforcer")

	p.enforcer = enforcerAt(t, 101, activations)
	require.NoError(t, p.applyPendingM4(ctx))
	require.Equal(t, 2, workScoreOn(t, ctx, p, 9), "the second vote MUST land on slot 9")

	require.NoError(t, p.applyPendingM4(ctx))
	require.Equal(t, 2, workScoreOn(t, ctx, p, 9), "an applied M4 MUST NOT apply again")
}

func TestApplyPendingM4_NoEnforcerKeepsParsing(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	p := &Parser{
		db:       db,
		m4Engine: NewM4Engine(db, config.NetworkMainnet, ""),
		enforcer: service.New("enforcer", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
			return nil, errors.New("no enforcer")
		}),
	}

	blockTime := time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC)
	require.NoError(t, p.processBlocks(ctx, []lo.Tuple2[uint32, *wire.MsgBlock]{
		lo.T2(uint32(100), coinbaseBlockOf(m3ProposalScript(t, 0, [32]byte{0xab, 0xcd}), blockTime)),
		lo.T2(uint32(101), coinbaseBlockOf(m4Script(t, 0x00), blockTime.Add(10*time.Minute))),
	}))
	require.NoError(t, p.applyPendingM4(ctx))

	tip, err := blocks.GetProcessedTip(ctx, db)
	require.NoError(t, err)
	require.Equal(t, uint32(101), tip.Height)
	require.Equal(t, 1, workScoreOn(t, ctx, p, 0), "the M3 lands without the enforcer")
}

// A bundle first seen in an orphaned block must not survive the reorg purge.
func TestPurgeM4AtOrAbove(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	e := NewM4Engine(db, config.NetworkMainnet, "")

	seedBundle(t, ctx, e, "bundle-below", 100)
	seedBundle(t, ctx, e, "bundle-orphaned", 200)

	require.NoError(t, ResetChainData(ctx, db, 181))

	// Scanning the row at all asserts it survived.
	_, _, status := bundleState(t, ctx, e, "bundle-below")
	require.Equal(t, "pending", status, "bundles below the rewind target survive")

	var count int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM withdrawal_bundles WHERE bundle_hash = ?`, "bundle-orphaned").Scan(&count))
	require.Zero(t, count, "bundles born at or above the rewind target are wiped")
}

func TestProcessBlocks_PersistFailureKeepsHeightUnprocessed(t *testing.T) {
	blockTime := time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC)
	cases := []struct {
		name  string
		table string
		block func(t *testing.T) *wire.MsgBlock
	}{
		{"M3", "m3_messages", func(t *testing.T) *wire.MsgBlock {
			return coinbaseBlockOf(m3ProposalScript(t, 0, [32]byte{0xab, 0xcd}), blockTime)
		}},
		{"M4", "m4_messages", func(t *testing.T) *wire.MsgBlock {
			return coinbaseBlockOf(m4Script(t, 0x00), blockTime)
		}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			ctx := t.Context()
			db := database.Test(t)
			p := &Parser{db: db, m4Engine: NewM4Engine(db, config.NetworkMainnet, "")}
			batch := []lo.Tuple2[uint32, *wire.MsgBlock]{lo.T2(uint32(100), tc.block(t))}

			_, err := db.ExecContext(ctx, `CREATE TRIGGER fail_insert BEFORE INSERT ON `+tc.table+`
				BEGIN SELECT RAISE(ABORT, 'insert refused'); END`)
			require.NoError(t, err)

			require.ErrorContains(t, p.processBlocks(ctx, batch), "insert refused")
			tip, err := blocks.GetProcessedTip(ctx, db)
			require.NoError(t, err)
			require.Nil(t, tip)

			_, err = db.ExecContext(ctx, `DROP TRIGGER fail_insert`)
			require.NoError(t, err)

			require.NoError(t, p.processBlocks(ctx, batch))
			require.NoError(t, p.processBlocks(ctx, batch))
			tip, err = blocks.GetProcessedTip(ctx, db)
			require.NoError(t, err)
			require.Equal(t, uint32(100), tip.Height)
			var rows int
			require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM `+tc.table).Scan(&rows))
			require.Equal(t, 1, rows)
		})
	}
}

func TestProcessBlock_SkipsMalformedM4(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	e := NewM4Engine(db, config.NetworkMainnet, "")

	payload := binary.BigEndian.AppendUint32(nil, m4.M4CommitmentHeader)
	block := coinbaseBlockOf(opReturnScript(t, append(payload, 0x04)), time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC))

	require.NoError(t, e.ProcessBlock(ctx, 100, block))
	var rows int
	require.NoError(t, db.QueryRowContext(ctx, `SELECT COUNT(*) FROM m4_messages`).Scan(&rows))
	require.Zero(t, rows)
}

// The enforcer approves a bundle only with more ACKs than the threshold of the network.
func TestUpdateBundleStates_ApprovesAboveTheNetworkThreshold(t *testing.T) {
	for _, tc := range []struct {
		name       string
		network    config.Network
		ecashID    string
		score      uint32
		wantStatus string
	}{
		{"regtest at the threshold", config.NetworkRegtest, "", 5, "pending"},
		{"regtest above the threshold", config.NetworkRegtest, "", 6, "approved"},
		{"alphanet at the threshold", config.NetworkECash, "alphanet", 72, "pending"},
		{"alphanet above the threshold", config.NetworkECash, "alphanet", 73, "approved"},
		{"mainnet below the threshold", config.NetworkMainnet, "", 73, "pending"},
		{"mainnet above the threshold", config.NetworkMainnet, "", 13151, "approved"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			ctx := t.Context()
			db := database.Test(t)
			e := NewM4Engine(db, tc.network, tc.ecashID)
			seedBundleRow(t, ctx, db, "bundle-a", 100, 100, tc.score)

			require.NoError(t, e.updateBundleStates(ctx, 101))

			_, _, status := bundleState(t, ctx, e, "bundle-a")
			assert.Equal(t, tc.wantStatus, status)
		})
	}

	t.Run("a row with the old mainnet age takes the network age", func(t *testing.T) {
		ctx := t.Context()
		db := database.Test(t)
		e := NewM4Engine(db, config.NetworkRegtest, "")
		seedBundleRow(t, ctx, db, "bundle-a", 100, 100, 5)
		_, err := db.ExecContext(ctx, `UPDATE withdrawal_bundles SET max_age = 26300`)
		require.NoError(t, err)

		require.NoError(t, e.updateBundleStates(ctx, 104))

		var maxAge int
		require.NoError(t, db.QueryRowContext(ctx, `SELECT max_age FROM withdrawal_bundles`).Scan(&maxAge))
		assert.Equal(t, 10, maxAge)
		_, blocksLeft, status := bundleState(t, ctx, e, "bundle-a")
		assert.Equal(t, 6, blocksLeft)
		assert.Equal(t, "pending", status)
	})

	t.Run("an expired bundle at the threshold fails", func(t *testing.T) {
		ctx := t.Context()
		db := database.Test(t)
		e := NewM4Engine(db, config.NetworkRegtest, "")
		seedBundleRow(t, ctx, db, "bundle-a", 100, 100, 5)

		require.NoError(t, e.updateBundleStates(ctx, 110))

		_, _, status := bundleState(t, ctx, e, "bundle-a")
		assert.Equal(t, "failed", status)
	})
}

func TestProcessBlock_StoresTheBundleMaxAge(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	e := NewM4Engine(db, config.NetworkECash, "alphanet")

	block := coinbaseBlockOf(m3ProposalScript(t, 0, [32]byte{0xab}), time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC))
	require.NoError(t, e.ProcessBlock(ctx, 100, block))

	var maxAge, blocksLeft int
	require.NoError(t, db.QueryRowContext(ctx,
		`SELECT max_age, blocks_left FROM withdrawal_bundles WHERE sidechain_slot = 0`,
	).Scan(&maxAge, &blocksLeft))
	assert.Equal(t, 144, maxAge)
	assert.Equal(t, 144, blocksLeft)
}

// The rules come from bip300301_enforcer lib/validator/task/mod.rs:
// handle_m4_votes, handle_m4_repeat_previous and handle_m4_leading_by_50.
func TestApplyPendingM4_EnforcerVoteRules(t *testing.T) {
	t.Parallel()

	sidechains := []*validatorpb.GetSidechainsResponse_SidechainInfo{{
		SidechainNumber:  wrapperspb.UInt32(0),
		ActivationHeight: wrapperspb.UInt32(10),
	}}
	blockTime := time.Date(2026, 8, 30, 12, 0, 0, 0, time.UTC)
	m4Version := func(t *testing.T, version byte, vector ...byte) []byte {
		payload := binary.BigEndian.AppendUint32(nil, m4.M4CommitmentHeader)
		return opReturnScript(t, append(append(payload, version), vector...))
	}
	apply := func(t *testing.T, e *M4Engine, height uint32, script []byte) {
		t.Helper()
		block := coinbaseBlockOf(script, blockTime.Add(time.Duration(height)*time.Minute))
		require.NoError(t, e.ProcessBlock(t.Context(), height, block))
		require.NoError(t, e.ApplyPendingM4(t.Context(), height, sidechains))
	}
	setWorkScore := func(t *testing.T, e *M4Engine, hash string, workScore int) {
		t.Helper()
		_, err := e.db.ExecContext(t.Context(),
			`UPDATE withdrawal_bundles SET work_score = ? WHERE bundle_hash = ?`, workScore, hash)
		require.NoError(t, err)
	}
	workScores := func(t *testing.T, e *M4Engine, hashes ...string) []int {
		t.Helper()
		return lo.Map(hashes, func(hash string, _ int) int {
			workScore, _, _ := bundleState(t, t.Context(), e, hash)
			return workScore
		})
	}

	t.Run("an upvote downvotes the other pending bundles", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		seedBundle(t, t.Context(), e, "bundle-b", 101)
		seedBundle(t, t.Context(), e, "bundle-c", 102)
		setWorkScore(t, e, "bundle-b", 5)
		setWorkScore(t, e, "bundle-c", 0)

		apply(t, e, 150, m4Version(t, 0x01, 0x00))

		assert.Equal(t, []int{2, 4, 0}, workScores(t, e, "bundle-a", "bundle-b", "bundle-c"))
	})

	t.Run("version 0x00 repeats the upvote of the previous block", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		seedBundle(t, t.Context(), e, "bundle-b", 101)
		setWorkScore(t, e, "bundle-a", 5)

		apply(t, e, 150, m4Version(t, 0x01, 0x01))
		apply(t, e, 151, m4Version(t, 0x00))

		assert.Equal(t, []int{3, 3}, workScores(t, e, "bundle-a", "bundle-b"))
	})

	t.Run("version 0x00 repeats an alarm", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		setWorkScore(t, e, "bundle-a", 5)

		apply(t, e, 150, m4Version(t, 0x01, 0xFE))
		apply(t, e, 151, m4Version(t, 0x00))

		assert.Equal(t, []int{3}, workScores(t, e, "bundle-a"))
	})

	t.Run("version 0x00 with no M4 in the previous block changes nothing", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)

		apply(t, e, 150, m4Version(t, 0x01, 0x00))
		apply(t, e, 152, m4Version(t, 0x00))

		assert.Equal(t, []int{2}, workScores(t, e, "bundle-a"))
	})

	t.Run("version 0x03 upvotes a bundle that leads by 50", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		seedBundle(t, t.Context(), e, "bundle-b", 101)
		setWorkScore(t, e, "bundle-a", 10)
		setWorkScore(t, e, "bundle-b", 60)

		apply(t, e, 150, m4Version(t, 0x03))

		assert.Equal(t, []int{9, 61}, workScores(t, e, "bundle-a", "bundle-b"))
	})

	t.Run("version 0x03 upvotes a single bundle with 50", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		setWorkScore(t, e, "bundle-a", 50)

		apply(t, e, 150, m4Version(t, 0x03))

		assert.Equal(t, []int{51}, workScores(t, e, "bundle-a"))
	})

	t.Run("version 0x03 skips a lead below 50", func(t *testing.T) {
		t.Parallel()

		e := NewM4Engine(database.Test(t), config.NetworkMainnet, "")
		seedBundle(t, t.Context(), e, "bundle-a", 100)
		seedBundle(t, t.Context(), e, "bundle-b", 101)
		setWorkScore(t, e, "bundle-a", 10)
		setWorkScore(t, e, "bundle-b", 59)

		apply(t, e, 150, m4Version(t, 0x03))

		assert.Equal(t, []int{10, 59}, workScores(t, e, "bundle-a", "bundle-b"))
	})
}
