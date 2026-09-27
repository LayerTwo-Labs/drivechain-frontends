package api

import (
	"context"
	"encoding/hex"
	"errors"
	"testing"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// fakeChain serves a chain of deposits: spends[outpoint] names the spender, and
// txs[txid] is that spender's outputs.
type fakeChain struct {
	deadSource bool
	hardFail   map[string]bool
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
	if f.hardFail[txid] {
		return nil, wallet.ErrTxUnreadable
	}
	if f.deadSource {
		return nil, errors.New("dial tcp: connection refused")
	}
	tx, ok := f.txs[txid]
	if !ok {
		return nil, wallet.ErrTxNotFound
	}
	return tx, nil
}

func (f *fakeChain) Broadcast(context.Context, string) (string, error) { return "", nil }
func (f *fakeChain) TipHeight(context.Context) (int, error)            { return 0, nil }

// noRecords keeps the old behaviour for a test that does not exercise the
// records fallback: a source that cannot name a spender stops at the tip.
func noRecords(_ context.Context, _ wallet.ChainSource, _ []byte, from treasuryOutpoint) (treasuryOutpoint, error) {
	return from, nil
}

// oneSource answers for every wallet with one chain source.
func oneSource(chain wallet.ChainSource) func(string) wallet.ChainSource {
	return func(string) wallet.ChainSource { return chain }
}

func outpointKey(txid string, vout int) string {
	return txid + ":" + string(rune('0'+vout))
}

// treasuryTx builds a transaction paying `sats` to the slot treasury at vout 1,
// with an unrelated output at vout 0. spends names the treasury output it took.
func treasuryTx(slot uint8, sats int64, spends ...string) *wallet.RawTransaction {
	vin := []wallet.RawTxIn{{TxID: "a-funding-coin", Vout: 0}}
	for _, parent := range spends {
		vin = append(vin, wallet.RawTxIn{TxID: parent, Vout: 1})
	}
	return &wallet.RawTransaction{Vin: vin, Vout: []wallet.RawTxOut{
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

	tip, err := treasuryTip(context.Background(), chain, 2, ctip, noRecords)

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

	tip, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}, noRecords)

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

	tip, err := treasuryTip(context.Background(), chain, 2, ctip, noRecords)

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

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}, noRecords)

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

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}, noRecords)

	require.ErrorIs(t, err, errTreasurySpentElsewhere)
}

// A source that fails for any other reason must not silently return a stale
// outpoint: the deposit would double-spend.
func TestTreasuryTipFailsOnALookupError(t *testing.T) {
	chain := &fakeChain{spenderErr: errors.New("connection refused")}

	_, err := treasuryTip(context.Background(), chain, 2, treasuryOutpoint{txid: "ctip", vout: 0, valueSats: 100}, noRecords)

	require.Error(t, err)
	require.NotErrorIs(t, err, errTreasuryChainFull)
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

	out, err := h.firstTreasuryOf(ctx, oneSource(chain), 2)

	require.NoError(t, err)
	require.NotNil(t, out)
	require.Equal(t, "first", out.txid)
	require.Equal(t, int64(1000), out.valueSats)
	require.Equal(t, 1, out.ancestors, "an unconfirmed first deposit is already an ancestor")
}

// Wallet A broadcast the first deposit through Core, and wallet B deposits
// through Esplora before the public host received it. Wallet B must read the
// deposit through the source of wallet A, or it builds a rival treasury root.
func TestFirstTreasuryOfReadsADepositThroughItsOwnWallet(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "first", WalletID: "core-wallet", Slot: 2, AmountSats: 1000,
	}))

	h := &WalletHandler{svc: svc}
	core := &fakeChain{txs: map[string]*wallet.RawTransaction{"first": treasuryTx(2, 1000)}}
	esplora := &fakeChain{}

	out, err := h.firstTreasuryOf(ctx, func(walletID string) wallet.ChainSource {
		if walletID == "core-wallet" {
			return core
		}
		return esplora
	}, 2)

	require.NoError(t, err)
	require.NotNil(t, out)
	require.Equal(t, "first", out.txid)
}

// Nothing deposited to the slot yet, so this deposit creates the treasury.
func TestFirstTreasuryOfReportsNoneOnAFreshSlot(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}

	out, err := h.firstTreasuryOf(ctx, oneSource(&fakeChain{}), 2)

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

	_, err := h.firstTreasuryOf(ctx, oneSource(&unreachableChain{}), 2)

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
	}, noRecords)

	require.ErrorIs(t, err, errTreasuryChainFull)
}

// Three of our deposits already chain from the unconfirmed first one. Starting
// at the newest would report one ancestor and let the chain run past the
// mempool limit, so the walk must start at the base and count each hop.
func TestFirstTreasuryOfStartsAtTheBaseOfTheChain(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	for _, txid := range []string{"one", "two", "three"} {
		require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
			Txid: txid, WalletID: "w", Slot: 2, AmountSats: 100,
		}))
	}

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{
		spends: map[string]string{
			outpointKey("one", 1): "two",
			outpointKey("two", 1): "three",
		},
		txs: map[string]*wallet.RawTransaction{
			"one":   treasuryTx(2, 100),
			"two":   treasuryTx(2, 200, "one"),
			"three": treasuryTx(2, 300, "two"),
		},
	}

	start, err := h.firstTreasuryOf(ctx, oneSource(chain), 2)
	require.NoError(t, err)
	require.Equal(t, "one", start.txid, "the walk must begin at the base")

	tip, err := treasuryTip(ctx, chain, 2, *start, noRecords)
	require.NoError(t, err)
	require.Equal(t, "three", tip.txid)
	require.Equal(t, 3, tip.ancestors, "one for the base plus one per hop")
}

// A deposit also spends ordinary confirmed coins, and a Core node with no
// txindex cannot read those. Aborting there would refuse every deposit on a
// supported node, so an unreadable input is simply not the treasury link.
func TestTreasuryBaseIgnoresAnUnreadableFundingInput(t *testing.T) {
	ctx := context.Background()
	script := orchestrator.M8TreasuryScript(2)
	chain := &fakeChain{
		txs: map[string]*wallet.RawTransaction{"only": treasuryTx(2, 100)},
		// "a-funding-coin" resolves to no entry, so the fake answers a plain
		// error rather than ErrTxNotFound.
		hardFail: map[string]bool{"a-funding-coin": true},
	}

	base, err := treasuryBase(ctx, chain, script, &treasuryOutpoint{txid: "only", vout: 1, valueSats: 100})

	require.NoError(t, err)
	require.Equal(t, "only", base.txid)
	require.Equal(t, 1, base.ancestors)
}

// A dead source is not the same as a node with no txindex. Skipping its
// silence would put the base too high and run the chain past the mempool
// limit, so the deposit must refuse instead.
func TestTreasuryBaseRefusesOnADeadSource(t *testing.T) {
	ctx := context.Background()
	script := orchestrator.M8TreasuryScript(2)
	chain := &fakeChain{
		txs:        map[string]*wallet.RawTransaction{"only": treasuryTx(2, 100)},
		deadSource: true,
	}

	_, err := treasuryBase(ctx, chain, script, &treasuryOutpoint{txid: "only", vout: 1, valueSats: 100})

	require.Error(t, err)
	require.NotErrorIs(t, err, wallet.ErrTxUnreadable)
}

// Mainnet runs an Electrum-only source, which cannot name the spender of an
// outpoint. Stopping at the confirmed ctip there makes the second deposit
// conflict with the first, which is the loss this whole walk prevents.
func TestTreasuryTipUsesOurRecordsWhenTheSpenderIsUnknown(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "pending", WalletID: "w", Slot: 2, AmountSats: 500,
	}))

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{
		spenderErr: wallet.ErrSpenderUnknown,
		txs: map[string]*wallet.RawTransaction{
			"pending": treasuryTx(2, 500, "ctip"),
			"ctip":    treasuryTx(2, 100),
		},
	}
	ctip := treasuryOutpoint{txid: "ctip", vout: 1, valueSats: 100}

	tip, err := treasuryTip(ctx, chain, 2, ctip, h.recordedTipOf(2))

	require.NoError(t, err)
	require.Equal(t, "pending", tip.txid, "the deposit must extend our unconfirmed one")
	require.Equal(t, int64(500), tip.valueSats)
	require.Equal(t, 1, tip.ancestors)
}

// No record of ours builds on the ctip, so it is the tip.
func TestTreasuryTipKeepsTheCtipWithNoRecordAboveIt(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{spenderErr: wallet.ErrSpenderUnknown}
	ctip := treasuryOutpoint{txid: "ctip", vout: 1, valueSats: 100}

	tip, err := treasuryTip(ctx, chain, 2, ctip, h.recordedTipOf(2))

	require.NoError(t, err)
	require.Equal(t, ctip, tip)
}

// Two rival initial deposits carry two rival treasuries, and only one can ever
// take the slot. Extending either abandons the other, so the deposit waits.
func TestFirstTreasuryOfRefusesRivalTreasuries(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	for _, txid := range []string{"rivalA", "rivalB"} {
		require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
			Txid: txid, WalletID: "w", Slot: 2, AmountSats: 100,
		}))
	}

	h := &WalletHandler{svc: svc}
	// Neither spends the other, so each is its own base.
	chain := &fakeChain{txs: map[string]*wallet.RawTransaction{
		"rivalA": treasuryTx(2, 100),
		"rivalB": treasuryTx(2, 200),
	}}

	_, err := h.firstTreasuryOf(ctx, oneSource(chain), 2)

	require.ErrorIs(t, err, errTreasuryAmbiguous)
}

// Two records of one chain share a base, so the slot is not ambiguous.
func TestFirstTreasuryOfTakesOneChainOfTwoRecords(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()
	for _, txid := range []string{"base", "above"} {
		require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
			Txid: txid, WalletID: "w", Slot: 2, AmountSats: 100,
		}))
	}

	h := &WalletHandler{svc: svc}
	chain := &fakeChain{txs: map[string]*wallet.RawTransaction{
		"base":  treasuryTx(2, 100),
		"above": treasuryTx(2, 200, "base"),
	}}

	out, err := h.firstTreasuryOf(ctx, oneSource(chain), 2)

	require.NoError(t, err)
	require.Equal(t, "base", out.txid)
}

// A deposit that never reached the store leaves the slot's treasury chain
// unreadable from our records, so the next deposit must wait. The check sits
// above both paths: a funded slot needs our records for the chain above its
// ctip just as much as an unfunded one.
func TestDepositStartRefusesABlindSlot(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	// The slot went blind while the enforcer reported no ctip.
	h.depositSlotBlind.Store(h.blindKey(2), "")

	_, err := h.depositStart(ctx, sidechainTreasury{}, "w", 2)
	require.ErrorIs(t, err, errTreasuryAmbiguous, "an unfunded slot must refuse")
}

// A block settles the unknown chain: the enforcer reports a ctip we have not
// seen, so the slot takes deposits again. Without this a failed write would
// block the slot until the daemon restarts.
func TestDepositStartClearsABlindSlotOnANewCtip(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	h.depositSlotBlind.Store(h.blindKey(2), "")

	ctip := &enforcerpb.GetCtipResponse_Ctip{
		Txid:  &commonpb.ReverseHex{Hex: wrapperspb.String("settled")},
		Vout:  1,
		Value: 100,
	}
	start, err := h.depositStart(ctx, sidechainTreasury{ctip: ctip}, "w", 2)

	require.NoError(t, err)
	require.Equal(t, "settled", start.txid)

	// The flag is gone, so the next call passes too.
	_, stillBlind := h.depositSlotBlind.Load(h.blindKey(2))
	require.False(t, stillBlind)
}

// The same ctip means no block settled it, so the slot stays blind.
func TestDepositStartKeepsABlindSlotOnTheSameCtip(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	h.depositSlotBlind.Store(h.blindKey(2), "same")

	ctip := &enforcerpb.GetCtipResponse_Ctip{
		Txid:  &commonpb.ReverseHex{Hex: wrapperspb.String("same")},
		Vout:  1,
		Value: 100,
	}
	_, err := h.depositStart(ctx, sidechainTreasury{ctip: ctip}, "w", 2)

	require.ErrorIs(t, err, errTreasuryAmbiguous)
}

// A slot with no failed record reads normally.
func TestFirstTreasuryOfReadsASightedSlot(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}

	out, err := h.firstTreasuryOf(ctx, oneSource(&fakeChain{}), 2)

	require.NoError(t, err)
	require.Nil(t, out)
}

// The broadcast cannot be undone, so a busy store is worth a retry.
func TestRecordDepositRetriesABusyStore(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	err := h.recordDeposit(ctx, wallet.SidechainDeposit{Txid: "dep", WalletID: "w", Slot: 2, AmountSats: 5})

	require.NoError(t, err)
	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
}

// The handler outlives a network switch, so a marker on one network must not
// block the same slot number on another.
func TestBlindSlotStateIsPerNetwork(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	h.depositSlotBlind.Store(h.blindKey(2), "")

	_, err := h.depositStart(ctx, sidechainTreasury{}, "w", 2)
	require.ErrorIs(t, err, errTreasuryAmbiguous, "signet slot 2 is blind")

	svc.SetNetwork("regtest")
	_, blocked := h.slotStaysBlind(2, "")
	require.False(t, blocked, "regtest slot 2 carries no marker of its own")

	svc.SetNetwork("signet")
	_, blocked = h.slotStaysBlind(2, "")
	require.True(t, blocked, "the signet marker survives the round trip")
}
