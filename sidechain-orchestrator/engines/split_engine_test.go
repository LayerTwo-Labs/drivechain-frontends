package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

type fakeForkState struct{ st *fork.ForkState }

func (f *fakeForkState) ForkState(context.Context) (*fork.ForkState, error) { return f.st, nil }

type fakeOutspend struct {
	calls        map[string]int
	spent        map[string]bool
	mempoolSpent map[string]bool
	missing      map[string]bool
	fail         map[string]bool
	// unknownTx names transactions Bitcoin never saw.
	unknownTx map[string]bool
}

func newFakeOutspend() *fakeOutspend {
	return &fakeOutspend{
		calls:        map[string]int{},
		spent:        map[string]bool{},
		mempoolSpent: map[string]bool{},
		missing:      map[string]bool{},
		fail:         map[string]bool{},
		unknownTx:    map[string]bool{},
	}
}

func (f *fakeOutspend) Outspend(_ context.Context, txid string, vout int) (wallet.EsploraOutspend, bool, error) {
	op := fork.Outpoint(txid, vout)
	f.calls[op]++
	if f.fail[op] {
		return wallet.EsploraOutspend{}, false, errors.New("boom")
	}
	if f.missing[op] || f.unknownTx[txid] {
		return wallet.EsploraOutspend{}, false, nil
	}
	if f.mempoolSpent[op] {
		return wallet.EsploraOutspend{Spent: true}, true, nil
	}
	if f.spent[op] {
		return wallet.EsploraOutspend{Spent: true, Status: wallet.EsploraStatus{Confirmed: true}}, true, nil
	}
	return wallet.EsploraOutspend{}, true, nil
}

type fakeSplitStore struct{ statuses map[string]bool }

func (f *fakeSplitStore) SplitStatuses(context.Context) (map[string]bool, error) {
	out := map[string]bool{}
	for k, v := range f.statuses {
		out[k] = v
	}
	return out, nil
}

func (f *fakeSplitStore) SaveSplitStatus(_ context.Context, outpoint string, splittable bool) error {
	f.statuses[outpoint] = splittable
	return nil
}

type fakeCoins struct {
	utxos []fork.Utxo
	err   error
}

func (f *fakeCoins) WalletUnspent(context.Context) ([]fork.Utxo, error) { return f.utxos, f.err }

// claimBoundary every test shares; a coin below it is pre-fork.
const testBoundary = 1000

func forkStateWith(outpoints ...string) *fork.ForkState {
	return &fork.ForkState{HasFundsToClaim: true, ClaimBoundary: testBoundary}
}

// preFork lists coins confirmed before the fork — both chains share them.
func preFork(outpoints ...string) *fakeCoins {
	c := &fakeCoins{}
	for _, op := range outpoints {
		c.utxos = append(c.utxos, fork.Utxo{Outpoint: op, Sats: 100, Height: testBoundary - 1, Spendable: true})
	}
	return c
}

// postFork lists coins confirmed after the fork — this chain alone made them.
func postFork(outpoints ...string) *fakeCoins {
	c := &fakeCoins{}
	for _, op := range outpoints {
		c.utxos = append(c.utxos, fork.Utxo{Outpoint: op, Sats: 100, Height: testBoundary + 1, Spendable: true})
	}
	return c
}

func newTestSplitEngine(st *fork.ForkState, coins *fakeCoins, btc *fakeOutspend, store *fakeSplitStore, network string) *SplitEngine {
	return NewSplitEngine(zerolog.Nop(), &fakeForkState{st: st}, coins, btc, store, func() string { return network })
}

func TestSplitEngineChecksEachOutpointOnce(t *testing.T) {
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0", "bb:1"), btc, store, "ecash")

	e.tick(context.Background())
	e.tick(context.Background())

	require.Equal(t, 1, btc.calls["aa:0"])
	require.Equal(t, 1, btc.calls["bb:1"])
	require.Equal(t, map[string]bool{"aa:0": true, "bb:1": true}, store.statuses)
}

func TestSplitEngineSkipsCachedOutpoints(t *testing.T) {
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{"aa:0": false}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0", "bb:1"), btc, store, "ecash")

	e.tick(context.Background())

	require.Equal(t, 0, btc.calls["aa:0"])
	require.Equal(t, 1, btc.calls["bb:1"])
}

func TestSplitEngineSkipsNonEcashNetwork(t *testing.T) {
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0"), btc, store, "signet")

	e.tick(context.Background())

	require.Empty(t, btc.calls)
	require.Empty(t, store.statuses)
}

// Forknet has its own genesis, so no coin of its can exist on Bitcoin. Asking
// mempool.space about one leaks the txid and answers 404 forever.
func TestSplitEngineSkipsForknet(t *testing.T) {
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0"), btc, store, "forknet")

	e.tick(context.Background())

	require.Empty(t, btc.calls)
	require.Empty(t, store.statuses)
}

func TestSplitEngineSkipsSimulatedFork(t *testing.T) {
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{}}
	st := forkStateWith()
	st.Simulated = true
	e := newTestSplitEngine(st, preFork("aa:0"), btc, store, "ecash")

	e.tick(context.Background())

	require.Empty(t, btc.calls)
}

func TestSplitEngineRetriesAfterLookupError(t *testing.T) {
	btc := newFakeOutspend()
	btc.fail["aa:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0"), btc, store, "ecash")

	e.tick(context.Background())
	require.Empty(t, store.statuses)

	btc.fail["aa:0"] = false
	e.tick(context.Background())

	require.Equal(t, 2, btc.calls["aa:0"])
	require.Equal(t, map[string]bool{"aa:0": true}, store.statuses)
}

func TestSplitEngineDoesNotCacheMempoolSpend(t *testing.T) {
	btc := newFakeOutspend()
	btc.mempoolSpent["aa:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0"), btc, store, "ecash")

	e.tick(context.Background())
	require.Empty(t, store.statuses)

	btc.mempoolSpent["aa:0"] = false
	e.tick(context.Background())

	require.Equal(t, 2, btc.calls["aa:0"])
	require.Equal(t, map[string]bool{"aa:0": true}, store.statuses)
}

func TestSplitEngineStatusMapping(t *testing.T) {
	btc := newFakeOutspend()
	btc.spent["spent:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("spent:0", "unspent:0"), btc, store, "ecash")

	e.tick(context.Background())

	require.Equal(t, map[string]bool{
		"spent:0":   false,
		"unspent:0": true,
	}, store.statuses)
}

func TestSplitEngineDoesNotCacheNotFound(t *testing.T) {
	btc := newFakeOutspend()
	btc.missing["absent:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("absent:0", "unspent:0"), btc, store, "ecash")

	e.tick(context.Background())

	require.Empty(t, store.statuses["absent:0"])
	require.NotContains(t, store.statuses, "absent:0")
	require.Equal(t, true, store.statuses["unspent:0"])

	btc.missing["absent:0"] = false
	e.passRecheckInterval()
	e.tick(context.Background())

	require.Equal(t, 2, btc.calls["absent:0"])
	require.Equal(t, true, store.statuses["absent:0"])
}

func TestSplitEngineChecksACoinReceivedAfterTheFork(t *testing.T) {
	// A replayed transaction puts a post-fork coin on BTC too, so the coin
	// still needs the lookup.
	btc := newFakeOutspend()
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), postFork("new:0"), btc, store, "ecash")

	e.tick(context.Background())

	require.Equal(t, 1, btc.calls["new:0"])
	require.Equal(t, map[string]bool{"new:0": true}, store.statuses)
}

func TestSplitEngineRetriesAPostForkCoinBtcNeverSaw(t *testing.T) {
	// eCash mines faster than Bitcoin, so a replay can land there much later.
	btc := newFakeOutspend()
	btc.missing["new:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), postFork("new:0"), btc, store, "ecash")

	e.tick(context.Background())
	require.Empty(t, store.statuses)

	btc.missing["new:0"] = false
	e.passRecheckInterval()
	e.tick(context.Background())

	require.Equal(t, 2, btc.calls["new:0"])
	require.Equal(t, map[string]bool{"new:0": true}, store.statuses)
}

// A replay-protected send makes change no other chain holds, so most coins
// answer absent forever. Without a backoff each costs a request per tick.
func TestSplitEngineBacksOffACoinBtcDoesNotKnow(t *testing.T) {
	btc := newFakeOutspend()
	btc.missing["change:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), postFork("change:0"), btc, store, "ecash")

	for range 5 {
		e.tick(context.Background())
	}

	require.Equal(t, 1, btc.calls["change:0"], "the backoff must hold the extra lookups")
	require.Empty(t, store.statuses)
}

func TestSplitEngineBackoffDoesNotBlockAnotherCoin(t *testing.T) {
	btc := newFakeOutspend()
	btc.missing["change:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), postFork("change:0", "live:0"), btc, store, "ecash")

	e.tick(context.Background())
	e.tick(context.Background())

	require.Equal(t, 1, btc.calls["change:0"])
	require.Equal(t, true, store.statuses["live:0"], "a coin BTC knows still gets its answer")
}

func TestSplitEngineForgetsASpentCoin(t *testing.T) {
	btc := newFakeOutspend()
	btc.missing["spent:0"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	coins := postFork("spent:0")
	e := newTestSplitEngine(forkStateWith(), coins, btc, store, "ecash")

	e.tick(context.Background())
	require.Len(t, e.absent, 1)

	coins.utxos = nil
	e.tick(context.Background())

	require.Empty(t, e.absent, "a coin the wallet lost must not hold memory")
}

func TestDueForRecheck(t *testing.T) {
	base := time.Unix(1_700_000_000, 0)

	require.True(t, dueForRecheck(time.Time{}, base),
		"a coin no lookup reported absent yet is always due")
	require.False(t, dueForRecheck(base, base.Add(absentRecheckInterval-time.Second)),
		"a fresh absence holds the next lookup")
	require.True(t, dueForRecheck(base, base.Add(absentRecheckInterval)),
		"an absence expires, because a replay can land later")
}

func TestCheckReplayStatus(t *testing.T) {
	btc := newFakeOutspend()
	btc.spent["spent:0"] = true
	btc.mempoolSpent["mempool:0"] = true
	btc.missing["absent:0"] = true

	cases := []struct {
		name     string
		outpoint string
		want     btcStatus
	}{
		{name: "unspent on BTC", outpoint: "unspent:0", want: btcUnspent},
		{name: "spent on BTC", outpoint: "spent:0", want: btcSpent},
		{name: "spent in the BTC mempool", outpoint: "mempool:0", want: btcPending},
		{name: "BTC does not know it", outpoint: "absent:0", want: btcUnknown},
		{name: "malformed outpoint", outpoint: "nope", want: btcUnknown},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got, err := checkReplayStatus(context.Background(), btc, c.outpoint)
			require.NoError(t, err)
			require.Equal(t, c.want, got)
		})
	}
}

func TestCheckReplayStatusReturnsTheLookupError(t *testing.T) {
	btc := newFakeOutspend()
	btc.fail["aa:0"] = true

	_, err := checkReplayStatus(context.Background(), btc, "aa:0")

	require.Error(t, err)
}

// passRecheckInterval moves the engine clock past the backoff, so the next
// tick asks Bitcoin again.
func (e *SplitEngine) passRecheckInterval() {
	base := e.now()
	e.now = func() time.Time { return base.Add(absentRecheckInterval) }
}

// TestSplitEngineIgnoresCoinBitcoinNeverSaw: a server answers "not spent" for a
// transaction it never saw, exactly as it does for a live output. A coin this
// chain alone made must not read as a coin both chains hold.
func TestSplitEngineIgnoresCoinBitcoinNeverSaw(t *testing.T) {
	btc := newFakeOutspend()
	btc.unknownTx["aa"] = true
	store := &fakeSplitStore{statuses: map[string]bool{}}
	e := newTestSplitEngine(forkStateWith(), preFork("aa:0"), btc, store, "ecash")

	e.tick(context.Background())

	require.Equal(t, 1, btc.calls["aa:0"])
	require.Empty(t, store.statuses)
}
