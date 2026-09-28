package engines

import (
	"context"
	"encoding/binary"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/wrapperspb"
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
		Return(connect.NewResponse(&validatorpb.GetChainTipResponse{
			BlockHeaderInfo: &validatorpb.BlockHeaderInfo{Height: tip},
		}), nil).
		AnyTimes()
	validator.EXPECT().GetSidechains(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&validatorpb.GetSidechainsResponse{Sidechains: sidechains}), nil).
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
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{db: db, m4Engine: NewM4Engine(db), enforcer: enforcerAt(t, 101, map[uint32]uint32{0: 10})}

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
	ctx := context.Background()
	p := newCoinNewsParser(t)
	p.m4Engine = NewM4Engine(p.db)
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
	ctx := context.Background()
	db := database.Test(t)
	p := &Parser{
		db:       db,
		m4Engine: NewM4Engine(db),
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
