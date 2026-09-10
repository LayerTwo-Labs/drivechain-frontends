package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	frozenCoinTxid = "1111111111111111111111111111111111111111111111111111111111111111"
	freeCoinTxid   = "2222222222222222222222222222222222222222222222222222222222222222"
)

// twoCoinWallet gives the wallet a large coin a live bid holds, and a smaller
// free coin that covers the send on its own.
func twoCoinWallet(t *testing.T) (*ElectrumBackend, *fakeEsplora, *WalletData, string) {
	t.Helper()
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 2, FundedTxoSum: 5_000_000, TxCount: 2},
	}
	fake.utxos[addr] = []EsploraUTXO{
		{TxID: frozenCoinTxid, Vout: 1, Value: 4_000_000, Status: EsploraStatus{Confirmed: false}},
		{TxID: freeCoinTxid, Vout: 0, Value: 1_000_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
	}
	p.svc.SetFrozenCoins(func(_ context.Context, candidates []Outpoint) (map[string]bool, error) {
		frozen := map[string]bool{}
		for _, c := range candidates {
			if c.TxID == frozenCoinTxid {
				frozen[c.Key()] = true
			}
		}
		return frozen, nil
	})
	return p, fake, w, addr
}

func broadcastTx(t *testing.T, fake *fakeEsplora) *wire.MsgTx {
	t.Helper()
	require.Len(t, fake.broadcast, 1)
	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	return &tx
}

func inputTxids(tx *wire.MsgTx) []string {
	txids := make([]string, 0, len(tx.TxIn))
	for _, in := range tx.TxIn {
		txids = append(txids, in.PreviousOutPoint.Hash.String())
	}
	return txids
}

// Coin selection takes the largest coin first, and the change of a live bid is
// the largest coin the wallet lists.
func TestElectrumSendSkipsACoinABidHolds(t *testing.T) {
	p, fake, w, _ := twoCoinWallet(t)

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)

	assert.Equal(t, []string{freeCoinTxid}, inputTxids(broadcastTx(t, fake)))
}

// A deposit spends the sidechain treasury plus a wallet coin. The wallet coin
// must outlive the next round, or the deposit dies with the bid below it.
func TestElectrumDepositSkipsACoinABidHolds(t *testing.T) {
	p, fake, w, _ := twoCoinWallet(t)
	ctx := context.Background()

	treasuryScript := []byte{txscript.OP_NOP5, txscript.OP_DATA_1, 9, txscript.OP_TRUE}
	treasuryPrev := wire.NewMsgTx(2)
	treasuryPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	treasuryPrev.AddTxOut(wire.NewTxOut(250_000, treasuryScript))
	var buf bytes.Buffer
	require.NoError(t, treasuryPrev.Serialize(&buf))
	ctipTxid := treasuryPrev.TxHash().String()
	fake.hexByID[ctipTxid] = hex.EncodeToString(buf.Bytes())

	_, err := p.Send(ctx, w.ID, SendRequest{
		FixedFeeSats: 50_000,
		RawOutputs: []TxOutSpec{
			{RawScriptHex: hex.EncodeToString(treasuryScript), AmountSats: 1_150_000},
		},
		OpReturnHex:    hex.EncodeToString([]byte("sidechainaddress")),
		ExternalInputs: []ExternalInput{{TxID: ctipTxid, Vout: 0, AmountSats: 250_000}},
	})
	require.NoError(t, err)

	assert.Equal(t, []string{ctipTxid, freeCoinTxid}, inputTxids(broadcastTx(t, fake)))
}

// A raise replaces its own bid, so it has to spend the inputs of that bid. The
// freeze holds every other send off those coins, and lets the raise through.
func TestElectrumSendPinsACoinTheFreezeHolds(t *testing.T) {
	p, fake, w, _ := twoCoinWallet(t)

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
		RequiredInputs:   []RequiredInput{{TxID: frozenCoinTxid, Vout: 1}},
	})
	require.NoError(t, err)

	assert.Equal(t, []string{frozenCoinTxid}, inputTxids(broadcastTx(t, fake)))
}

// A freeze the backend cannot read leaves it blind to the bids, and a blind
// send can spend a coin the next replacement takes away.
func TestElectrumSendFailsWhenTheFreezeCannotBeRead(t *testing.T) {
	p, fake, w, _ := twoCoinWallet(t)
	p.svc.SetFrozenCoins(func(context.Context, []Outpoint) (map[string]bool, error) {
		return nil, errors.New("the node is down")
	})

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
	})
	require.ErrorContains(t, err, "the node is down")
	assert.Empty(t, fake.broadcast)
}

// A Core-backed wallet can bid too, and its fixed-fee path picks the largest
// coin first, which is the change of a live bid.
func TestCoreBackendSendSkipsACoinABidHolds(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0x88), net)
	change := p2wpkhAddr(t, fixedKey(0x99), net)

	// Core hides a locked output from listunspent, which is how a lock keeps
	// every one of its selection paths off the coin.
	locked := map[string]bool{}
	var minConf []json.RawMessage
	fake.handle("listunspent", func(c bitcoindCall) (any, string) {
		if len(c.Params) > 0 {
			minConf = append(minConf, c.Params[0])
		}
		coins := []map[string]any{}
		for _, c := range []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
			{"txid": freeCoinTxid, "vout": 0, "amount": 0.01, "spendable": true},
		} {
			if !locked[fmt.Sprintf("%s:%d", c["txid"], c["vout"])] {
				coins = append(coins, c)
			}
		}
		return coins, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) { return change, "" })
	var selected []RawInput
	fake.handle("createrawtransaction", func(c bitcoindCall) (any, string) {
		require.NoError(t, json.Unmarshal(c.Params[0], &selected))
		return "deadbeef00112233", ""
	})
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-fixed", "" })

	backend.svc.SetFrozenCoins(func(_ context.Context, candidates []Outpoint) (map[string]bool, error) {
		frozen := map[string]bool{}
		for _, c := range candidates {
			if c.TxID == frozenCoinTxid {
				frozen[c.Key()] = true
			}
		}
		return frozen, nil
	})

	var locks []bitcoindCall
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		locks = append(locks, c)
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		var outputs []RawInput
		require.NoError(t, json.Unmarshal(c.Params[1], &outputs))
		for _, o := range outputs {
			locked[fmt.Sprintf("%s:%d", o.TxID, o.Vout)] = !unlock
		}
		return true, ""
	})

	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
	})
	require.NoError(t, err)

	require.Len(t, selected, 1)
	assert.Equal(t, freeCoinTxid, selected[0].TxID)

	// Core picks the coins itself on its other send paths, so the send holds a
	// lock on the frozen coin for as long as it runs.
	require.Len(t, locks, 2)
	var unlock bool
	require.NoError(t, json.Unmarshal(locks[0].Params[0], &unlock))
	assert.False(t, unlock, "the send locks first")
	var held []RawInput
	require.NoError(t, json.Unmarshal(locks[0].Params[1], &held))
	require.Len(t, held, 1)
	assert.Equal(t, frozenCoinTxid, held[0].TxID)
	require.NoError(t, json.Unmarshal(locks[1].Params[0], &unlock))
	assert.True(t, unlock, "the send unlocks when it ends")
	// The coin a live bid holds is unconfirmed change, which Core hides at the
	// default minconf.
	require.NotEmpty(t, minConf)
	assert.Equal(t, "0", string(minConf[0]))
}

// A canceled send must still give the coins back, or they stay locked until
// the next restart and the wallet cannot spend them at all.
func TestCoreBackendUnlocksAfterACanceledSend(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
		}, ""
	})
	var locks []bool
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		locks = append(locks, unlock)
		return true, ""
	})
	fake.handle("sendtoaddress", func(bitcoindCall) (any, string) { return "", "the node is busy" })

	backend.svc.SetFrozenCoins(func(_ context.Context, candidates []Outpoint) (map[string]bool, error) {
		frozen := map[string]bool{}
		for _, c := range candidates {
			frozen[c.Key()] = true
		}
		return frozen, nil
	})

	ctx, cancel := context.WithCancel(context.Background())
	_, err := backend.Send(ctx, coreID, SendRequest{
		DestinationsSats: map[string]int64{"bcrt1qdest": 25_000},
	})
	cancel()
	require.Error(t, err)

	require.Equal(t, []bool{false, true}, locks, "the send locks, then unlocks")
}

func TestElectrumCpfpRejectsACoinABidHolds(t *testing.T) {
	p, fake, w, _ := twoCoinWallet(t)
	fake.txByID[frozenCoinTxid] = EsploraTx{
		TxID:   frozenCoinTxid,
		Weight: 600,
		Fee:    150,
		Status: EsploraStatus{Confirmed: false},
	}

	_, err := p.CreateCpfp(context.Background(), w.ID, CpfpRequest{
		ParentTxID: frozenCoinTxid, ParentVout: 1, TargetRate: 20,
	})
	assert.ErrorContains(t, err, "held by a live bmm bid")
	assert.Empty(t, fake.broadcast)
}

func TestCoreCpfpRejectsACoinABidHolds(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	backend.svc.SetFrozenCoins(func(_ context.Context, candidates []Outpoint) (map[string]bool, error) {
		frozen := map[string]bool{}
		for _, c := range candidates {
			if c.TxID == frozenCoinTxid {
				frozen[c.Key()] = true
			}
		}
		return frozen, nil
	})
	childAddr := p2wpkhAddr(t, fixedKey(0x77), &chaincfg.RegressionNetParams)
	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{{"txid": frozenCoinTxid, "vout": 1, "amount": 0.002, "spendable": true}}, ""
	})
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return map[string]any{"vsize": 150, "fees": map[string]any{"base": 0.0000015}}, ""
	})
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": childAddr, "amount": 0.0, "txids": []string{}}}, ""
	})
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "child", "" })
	fake.handle("signrawtransactionwithwallet", func(bitcoindCall) (any, string) {
		return map[string]any{"hex": "child", "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "child-txid", "" })

	_, err := backend.CreateCpfp(context.Background(), coreID, CpfpRequest{
		ParentTxID: frozenCoinTxid, ParentVout: 1, TargetRate: 20,
	})
	assert.ErrorContains(t, err, "held by a live bmm bid")
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}
