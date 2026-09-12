package wallet

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestHeldCoinsJoinTheCoinsABidHolds(t *testing.T) {
	svc := newTestService(t)
	candidates := []Outpoint{
		{TxID: frozenCoinTxid, Vout: 1},
		{TxID: freeCoinTxid, Vout: 0},
	}

	svc.SetHeldCoins("wallet-1", []Outpoint{{TxID: freeCoinTxid, Vout: 0}})
	svc.SetFrozenCoins(func(context.Context, string, []Outpoint) (map[string]bool, error) {
		return map[string]bool{Outpoint{TxID: frozenCoinTxid, Vout: 1}.Key(): true}, nil
	})

	frozen, err := svc.FrozenCoins(context.Background(), "wallet-1", candidates)
	require.NoError(t, err)

	assert.True(t, frozen[Outpoint{TxID: freeCoinTxid, Vout: 0}.Key()], "the user froze this coin")
	assert.True(t, frozen[Outpoint{TxID: frozenCoinTxid, Vout: 1}.Key()], "a live bid holds this coin")
}

func TestHeldCoinsBelongToOneWallet(t *testing.T) {
	svc := newTestService(t)
	coin := Outpoint{TxID: freeCoinTxid, Vout: 0}

	svc.SetHeldCoins("wallet-1", []Outpoint{coin})

	assert.True(t, svc.FreezesCoins(), "a held coin is a source of its own")
	frozen, err := svc.FrozenCoins(context.Background(), "wallet-2", []Outpoint{coin})
	require.NoError(t, err)
	assert.Empty(t, frozen, "another wallet holds nothing")
}

func TestSetHeldCoinsReplacesTheSetBefore(t *testing.T) {
	svc := newTestService(t)
	coin := Outpoint{TxID: freeCoinTxid, Vout: 0}
	svc.SetHeldCoins("wallet-1", []Outpoint{coin})

	// The user unfroze the coin, so the new set is empty.
	svc.SetHeldCoins("wallet-1", nil)

	frozen, err := svc.FrozenCoins(context.Background(), "wallet-1", []Outpoint{coin})
	require.NoError(t, err)
	assert.Empty(t, frozen)
	assert.False(t, svc.FreezesCoins())
}

// Core picks the coins on most of its send paths, so a held coin has to sit
// locked for as long as the send runs.
func TestCoreSendLocksAHeldCoin(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0x21), net)
	change := p2wpkhAddr(t, fixedKey(0x22), net)
	// Core hides a locked output from listunspent, which is how one lock keeps
	// every one of its selection paths off the coin.
	locked := map[string]bool{}
	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		coins := []map[string]any{}
		for _, coin := range []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "address": change, "amount": 0.04, "confirmations": 0, "spendable": true},
			{"txid": freeCoinTxid, "vout": 0, "address": change, "amount": 0.01, "confirmations": 6, "spendable": true},
		} {
			if !locked[fmt.Sprintf("%s:%d", coin["txid"], coin["vout"])] {
				coins = append(coins, coin)
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
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-held", "" })
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

	backend.svc.SetHeldCoins(coreID, []Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
	})
	require.NoError(t, err)

	require.Len(t, selected, 1)
	assert.Equal(t, freeCoinTxid, selected[0].TxID, "the send spends the coin the user left free")

	require.Len(t, locks, 2)
	var unlock bool
	require.NoError(t, json.Unmarshal(locks[0].Params[0], &unlock))
	assert.False(t, unlock, "the send locks first")
	var held []RawInput
	require.NoError(t, json.Unmarshal(locks[0].Params[1], &held))
	require.Len(t, held, 1)
	assert.Equal(t, fmt.Sprintf("%s:%d", frozenCoinTxid, 1), fmt.Sprintf("%s:%d", held[0].TxID, held[0].Vout))
	require.NoError(t, json.Unmarshal(locks[1].Params[0], &unlock))
	assert.True(t, unlock, "the send unlocks when it ends")
}

func TestElectrumSendSkipsAHeldCoin(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 2, FundedTxoSum: 5_000_000, TxCount: 2},
	}
	fake.utxos[addr] = []EsploraUTXO{
		{TxID: frozenCoinTxid, Vout: 1, Value: 4_000_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 90}},
		{TxID: freeCoinTxid, Vout: 0, Value: 1_000_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
	}
	p.svc.SetHeldCoins(w.ID, []Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	dest := p2wpkhAddr(t, fixedKey(0x31), &chaincfg.SigNetParams)
	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 100_000},
		FeeRateSatPerVB:  1,
	})
	require.NoError(t, err)

	assert.Equal(t, []string{freeCoinTxid}, inputTxids(broadcastTx(t, fake)))
}
