package api

import (
	"context"
	"encoding/hex"
	"errors"
	"testing"
	"time"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// fakeChain serves a chain of deposits: spends[outpoint] names the spender, and
// txs[txid] is that spender's outputs.
type fakeChain struct {
	spends     map[string]string
	txs        map[string]*wallet.RawTransaction
	spenderErr error
	lookups    int
}

func (f *fakeChain) SpenderOf(_ context.Context, txid string, vout int) (string, bool, error) {
	f.lookups++
	if f.spenderErr != nil {
		return "", false, f.spenderErr
	}
	spender, ok := f.spends[outpointKey(txid, vout)]
	return spender, ok, nil
}

func (f *fakeChain) GetRawTransaction(_ context.Context, txid string) (*wallet.RawTransaction, error) {
	tx, ok := f.txs[txid]
	if !ok {
		return nil, wallet.ErrTxNotFound
	}
	return tx, nil
}

func (f *fakeChain) Broadcast(context.Context, string) (string, error) { return "", nil }
func (f *fakeChain) TipHeight(context.Context) (int, error)            { return 0, nil }

func outpointKey(txid string, vout int) string {
	return txid + ":" + string(rune('0'+vout))
}

// treasuryTx builds a transaction paying `sats` to the slot treasury at vout 1,
// with an unrelated output at vout 0.
func treasuryTx(slot uint8, sats int64) *wallet.RawTransaction {
	return &wallet.RawTransaction{Vout: []wallet.RawTxOut{
		{N: 0, Value: 0.5, ScriptPubKey: wallet.ScriptPubKey{Hex: "51"}},
		{N: 1, Value: float64(sats) / 1e8, ScriptPubKey: wallet.ScriptPubKey{
			Hex: hex.EncodeToString(orchestrator.M8TreasuryScript(slot)),
		}},
	}}
}

// Nothing spends the confirmed ctip, so it is the tip.
func TestTreasuryTipKeepsAnUnspentCtip(t *testing.T) {
	chain := &fakeChain{spends: map[string]string{}}
	ctip := treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}

	tip, err := treasuryTip(context.Background(), chain, 2, ctip)

	require.NoError(t, err)
	require.Equal(t, ctip, tip)
}

// The enforcer ctip is stale: three unconfirmed deposits already build on it.
func TestTreasuryTipFollowsTheUnconfirmedChain(t *testing.T) {
	chain := &fakeChain{
		spends: map[string]string{
			outpointKey("ctip", 0): "dep1",
			outpointKey("dep1", 1): "dep2",
			outpointKey("dep2", 1): "dep3",
		},
		txs: map[string]*wallet.RawTransaction{
			"dep1": treasuryTx(2, 200),
			"dep2": treasuryTx(2, 300),
			"dep3": treasuryTx(2, 400),
		},
	}

	tip, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100})

	require.NoError(t, err)
	require.Equal(t, "dep3", tip.txid)
	require.Equal(t, 1, tip.vout)
	require.Equal(t, int64(400), tip.valueSats)
	require.Equal(t, 3, tip.ancestors)
}

// An Electrum backend cannot name a spender, so the walk keeps the last
// outpoint it proved rather than failing the deposit.
func TestTreasuryTipStopsWhenTheSourceCannotAnswer(t *testing.T) {
	chain := &fakeChain{spenderErr: wallet.ErrSpenderUnknown}
	ctip := treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}

	tip, err := treasuryTip(context.Background(), chain, 2, ctip)

	require.NoError(t, err)
	require.Equal(t, ctip, tip)
}

// Core refuses a transaction past its ancestor limit, so the deposit must not
// get built at all.
func TestTreasuryTipRefusesAFullChain(t *testing.T) {
	spends := map[string]string{outpointKey("ctip", 0): "dep0"}
	txs := map[string]*wallet.RawTransaction{}
	for i := 0; i < depositAncestorLimit+2; i++ {
		id := "dep" + string(rune('a'+i))
		next := "dep" + string(rune('a'+i+1))
		txs[id] = treasuryTx(2, int64(100+i))
		spends[outpointKey(id, 1)] = next
	}
	txs["dep0"] = treasuryTx(2, 100)
	spends[outpointKey("dep0", 1)] = "depa"
	chain := &fakeChain{spends: spends, txs: txs}

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100})

	require.ErrorIs(t, err, errTreasuryChainFull)
}

// A withdrawal already took the treasury output. Building on a spent outpoint
// makes a conflict, so the deposit must wait rather than fall back to it.
func TestTreasuryTipRefusesWhenSomethingElseTookTheOutput(t *testing.T) {
	chain := &fakeChain{
		spends: map[string]string{outpointKey("ctip", 0): "other"},
		txs: map[string]*wallet.RawTransaction{
			"other": {Vout: []wallet.RawTxOut{{N: 0, Value: 1, ScriptPubKey: wallet.ScriptPubKey{Hex: "51"}}}},
		},
	}

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100})

	require.ErrorIs(t, err, errTreasurySpentElsewhere)
}

// A source that fails for any other reason must not silently return a stale
// outpoint: the deposit would double-spend.
func TestTreasuryTipFailsOnALookupError(t *testing.T) {
	chain := &fakeChain{spenderErr: errors.New("connection refused")}

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100})

	require.Error(t, err)
	require.NotErrorIs(t, err, errTreasuryChainFull)
}

// A dropped deposit sits in no block, so zero is its real count and the chain
// read would only repeat it.
func TestDepositConfirmationsSkipsADroppedDeposit(t *testing.T) {
	chain := &fakeChain{}
	h := &WalletHandler{}

	dropped := wallet.SidechainDeposit{Txid: "gone", DroppedAt: time.Now()}

	require.Zero(t, h.depositConfirmations(context.Background(), dropped))
	require.Zero(t, chain.lookups, "a dropped deposit must not touch the chain")
}

// The enforcer reads a slot as unfunded until the first deposit confirms. A
// second deposit in that window must extend the first, not build a rival
// treasury output that carries only its own amount.
func TestFirstTreasuryOfFindsOurUnconfirmedDeposit(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "first", WalletID: "w", Slot: 2, AmountSats: 1000,
	}))

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{txs: map[string]*wallet.RawTransaction{"first": treasuryTx(2, 1000)}}

	out, err := h.firstTreasuryOf(ctx, chain, 2)

	require.NoError(t, err)
	require.NotNil(t, out)
	require.Equal(t, "first", out.txid)
	require.Equal(t, int64(1000), out.valueSats)
	require.Equal(t, 1, out.ancestors, "an unconfirmed first deposit is already an ancestor")
}

// Nothing deposited to the slot yet, so this deposit creates the treasury.
func TestFirstTreasuryOfReportsNoneOnAFreshSlot(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}

	out, err := h.firstTreasuryOf(ctx, &fakeChain{}, 2)

	require.NoError(t, err)
	require.Nil(t, out)
}

// A stamped deposit that still lives must be used: the watch lifts a stamp a
// minute late, and building a rival treasury in that window loses the money.
func TestFirstTreasuryOfUsesAStampedDepositTheChainStillHolds(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "stamped", WalletID: "w", Slot: 2, AmountSats: 700,
	}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "stamped"))

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{txs: map[string]*wallet.RawTransaction{"stamped": treasuryTx(2, 700)}}

	out, err := h.firstTreasuryOf(ctx, chain, 2)

	require.NoError(t, err)
	require.NotNil(t, out)
	require.Equal(t, "stamped", out.txid)
}

// The chain lost the transaction, so it created no treasury output.
func TestFirstTreasuryOfSkipsADepositTheChainLost(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "lost", WalletID: "w", Slot: 2, AmountSats: 500,
	}))
	require.NoError(t, svc.MarkSidechainDepositDropped(ctx, "lost"))

	h := &WalletHandler{svc: svc}
	// The chain knows no such transaction.
	chain := &fakeChain{}

	out, err := h.firstTreasuryOf(ctx, chain, 2)

	require.NoError(t, err)
	require.Nil(t, out)
}

// A source that cannot answer proves nothing. Reading its failure as "no
// treasury" makes this deposit build a rival output for the slot.
func TestFirstTreasuryOfRefusesOnALookupFailure(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "first", WalletID: "w", Slot: 2, AmountSats: 1000,
	}))

	h := &WalletHandler{svc: svc}

	_, err := h.firstTreasuryOf(ctx, &unreachableChain{}, 2)

	require.Error(t, err)
	require.NotErrorIs(t, err, wallet.ErrTxNotFound)
}

// unreachableChain fails every read the way a dead server does.
type unreachableChain struct{ fakeChain }

func (c *unreachableChain) GetRawTransaction(context.Context, string) (*wallet.RawTransaction, error) {
	return nil, errors.New("dial tcp: connection refused")
}

// The chain from an unconfirmed first deposit counts that deposit, so the walk
// reaches the mempool limit one hop sooner than from a confirmed ctip.
func TestTreasuryTipCountsTheUnconfirmedStart(t *testing.T) {
	spends := map[string]string{}
	txs := map[string]*wallet.RawTransaction{}
	prev := "first"
	txs[prev] = treasuryTx(2, 100)
	for i := 0; i < depositAncestorLimit; i++ {
		next := "dep" + string(rune('a'+i))
		spends[outpointKey(prev, 1)] = next
		txs[next] = treasuryTx(2, int64(200+i))
		prev = next
	}
	chain := &fakeChain{spends: spends, txs: txs}

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{
		txid: "first", vout: 1, valueSats: 100, ancestors: 1,
	})

	require.ErrorIs(t, err, errTreasuryChainFull)
}
