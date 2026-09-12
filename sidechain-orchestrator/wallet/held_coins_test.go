package wallet

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"sync/atomic"
	"testing"
	"time"

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

	svc.SetHeldCoins([]Outpoint{{TxID: freeCoinTxid, Vout: 0}})
	svc.SetFrozenCoins(func(context.Context, string, []Outpoint) (map[string]bool, error) {
		return map[string]bool{Outpoint{TxID: frozenCoinTxid, Vout: 1}.Key(): true}, nil
	})

	frozen, err := svc.FrozenCoins(context.Background(), "wallet-1", candidates)
	require.NoError(t, err)

	assert.True(t, frozen[Outpoint{TxID: freeCoinTxid, Vout: 0}.Key()], "the user froze this coin")
	assert.True(t, frozen[Outpoint{TxID: frozenCoinTxid, Vout: 1}.Key()], "a live bid holds this coin")
}

// An outpoint names one coin of one wallet, so the set covers every wallet.
// A BMM target can name a wallet the user does not run right now.
func TestHeldCoinsCoverEveryWallet(t *testing.T) {
	svc := newTestService(t)
	coin := Outpoint{TxID: freeCoinTxid, Vout: 0}

	svc.SetHeldCoins([]Outpoint{coin})

	assert.True(t, svc.FreezesCoins(), "a held coin is a source of its own")
	for _, walletID := range []string{"wallet-1", "wallet-2"} {
		frozen, err := svc.FrozenCoins(context.Background(), walletID, []Outpoint{coin})
		require.NoError(t, err)
		assert.True(t, frozen[coin.Key()], "the coin is frozen whichever wallet asks")
	}
}

func TestSetHeldCoinsReplacesTheSetBefore(t *testing.T) {
	svc := newTestService(t)
	coin := Outpoint{TxID: freeCoinTxid, Vout: 0}
	svc.SetHeldCoins([]Outpoint{coin})

	// The user unfroze the coin, so the new set is empty.
	svc.SetHeldCoins(nil)

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

	backend.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

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
	p.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	dest := p2wpkhAddr(t, fixedKey(0x31), &chaincfg.SigNetParams)
	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 100_000},
		FeeRateSatPerVB:  1,
	})
	require.NoError(t, err)

	assert.Equal(t, []string{freeCoinTxid}, inputTxids(broadcastTx(t, fake)))
}

// Two sends of one wallet can run at the same time. The second reads a list
// that already hides the locked coins, so it locks nothing of its own. The
// first must not give the coins back while the second still runs.
func TestOverlappingSendsHoldTheLockToTheEnd(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	name := "wallet_" + coreID[:8]

	locked := map[string]bool{}
	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		coins := []map[string]any{}
		for _, coin := range []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
			{"txid": freeCoinTxid, "vout": 0, "amount": 0.01, "spendable": true},
		} {
			if !locked[fmt.Sprintf("%s:%d", coin["txid"], coin["vout"])] {
				coins = append(coins, coin)
			}
		}
		return coins, ""
	})
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		var outputs []RawInput
		require.NoError(t, json.Unmarshal(c.Params[1], &outputs))
		for _, o := range outputs {
			locked[fmt.Sprintf("%s:%d", o.TxID, o.Vout)] = !unlock
		}
		return true, ""
	})
	backend.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	ctx := context.Background()
	first, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)
	require.True(t, locked[fmt.Sprintf("%s:%d", frozenCoinTxid, 1)], "the first send locks the coin")

	second, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)

	first()
	assert.True(t, locked[fmt.Sprintf("%s:%d", frozenCoinTxid, 1)],
		"the second send still runs, so the coin stays locked")

	second()
	assert.False(t, locked[fmt.Sprintf("%s:%d", frozenCoinTxid, 1)],
		"the last send out gives the coin back")
}

// A send that arrives while the first one still locks has to wait. Core would
// pick the coin the first send is about to lock.
func TestASecondSendWaitsForTheFirstLock(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	name := "wallet_" + coreID[:8]

	// Core hides a locked output from listunspent, so the second send sees
	// nothing left to lock.
	var lockMu sync.Mutex
	locked := map[string]bool{}
	listing := make(chan struct{})
	release := make(chan struct{})
	var listed atomic.Int32
	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		if listed.Add(1) == 1 {
			close(listing)
			<-release
		}
		lockMu.Lock()
		defer lockMu.Unlock()
		coins := []map[string]any{}
		for _, coin := range []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
		} {
			if !locked[fmt.Sprintf("%s:%d", coin["txid"], coin["vout"])] {
				coins = append(coins, coin)
			}
		}
		return coins, ""
	})
	var locks atomic.Int32
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		locks.Add(1)
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		var outputs []RawInput
		require.NoError(t, json.Unmarshal(c.Params[1], &outputs))
		lockMu.Lock()
		defer lockMu.Unlock()
		for _, o := range outputs {
			locked[fmt.Sprintf("%s:%d", o.TxID, o.Vout)] = !unlock
		}
		return true, ""
	})
	backend.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	ctx := context.Background()
	firstDone := make(chan func(), 1)
	go func() {
		unlock, err := backend.lockFrozenCoins(ctx, coreID, name)
		assert.NoError(t, err)
		firstDone <- unlock
	}()

	<-listing
	secondDone := make(chan func(), 1)
	go func() {
		unlock, err := backend.lockFrozenCoins(ctx, coreID, name)
		assert.NoError(t, err)
		secondDone <- unlock
	}()

	// The second send must hold here: the first one has not locked yet.
	select {
	case <-secondDone:
		t.Fatal("the second send ran before the first send locked the coin")
	case <-time.After(200 * time.Millisecond):
	}

	close(release)
	first := <-firstDone
	second := <-secondDone
	assert.Equal(t, int32(1), locks.Load(), "the coin is locked, so the second send adds nothing")

	first()
	second()
}

// The user can freeze a coin while a send runs. The next send locks that coin
// too, instead of joining a hold that never covered it.
func TestALaterSendLocksACoinFrozenMeanwhile(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	name := "wallet_" + coreID[:8]

	locked := map[string]bool{}
	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		coins := []map[string]any{}
		for _, coin := range []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
			{"txid": freeCoinTxid, "vout": 0, "amount": 0.01, "spendable": true},
		} {
			if !locked[fmt.Sprintf("%s:%d", coin["txid"], coin["vout"])] {
				coins = append(coins, coin)
			}
		}
		return coins, ""
	})
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		var outputs []RawInput
		require.NoError(t, json.Unmarshal(c.Params[1], &outputs))
		for _, o := range outputs {
			locked[fmt.Sprintf("%s:%d", o.TxID, o.Vout)] = !unlock
		}
		return true, ""
	})

	ctx := context.Background()
	backend.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})
	first, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)

	// The user freezes the other coin while the first send still runs.
	backend.svc.SetHeldCoins([]Outpoint{
		{TxID: frozenCoinTxid, Vout: 1},
		{TxID: freeCoinTxid, Vout: 0},
	})
	second, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)

	assert.True(t, locked[fmt.Sprintf("%s:%d", freeCoinTxid, 0)], "the new coin is locked too")

	first()
	second()
	assert.False(t, locked[fmt.Sprintf("%s:%d", frozenCoinTxid, 1)], "the last send gives both back")
	assert.False(t, locked[fmt.Sprintf("%s:%d", freeCoinTxid, 0)])
}

// Core hides a locked coin from listunspent, so the hold is the only way back
// to it. A failed unlock keeps that record for the next send.
func TestAFailedUnlockKeepsTheCoins(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	name := "wallet_" + coreID[:8]

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true},
		}, ""
	})
	var unlocks int
	fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
		var unlock bool
		require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
		if !unlock {
			return true, ""
		}
		unlocks++
		if unlocks == 1 {
			return nil, "Core is busy"
		}
		return true, ""
	})
	backend.svc.SetHeldCoins([]Outpoint{{TxID: frozenCoinTxid, Vout: 1}})

	ctx := context.Background()
	first, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)
	first()
	assert.Equal(t, 1, unlocks, "the first unlock failed")

	second, err := backend.lockFrozenCoins(ctx, coreID, name)
	require.NoError(t, err)
	second()
	assert.Equal(t, 2, unlocks, "the next send tries the unlock again")
}

// A txid is hexadecimal, and an RPC client can spell it in either case.
func TestAFrozenCoinReadsInEitherCase(t *testing.T) {
	svc := newTestService(t)
	upper := "AABBCC"
	lower := "aabbcc"

	svc.SetHeldCoins([]Outpoint{{TxID: upper, Vout: 1}})

	held := svc.HeldCoins()
	assert.True(t, held[Outpoint{TxID: lower, Vout: 1}.Key()], "the lowercase spelling names the same coin")
	assert.True(t, held[Outpoint{TxID: upper, Vout: 1}.Key()])
}
