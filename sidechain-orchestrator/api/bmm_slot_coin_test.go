package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// fakeSlotMempool answers the two Core reads the coin choice makes.
type fakeSlotMempool struct {
	// slots names the slot each mempool bid claims, by txid.
	slots map[string]int
	// plain names the mempool transactions that carry no bid.
	plain []string
	// unreadable names the mempool transactions the node refuses to read.
	unreadable []string
	// spends names the mempool transaction that spends each outpoint, by
	// txid:vout.
	spends map[string]string
	// ancestors names the unconfirmed ancestors of each mempool transaction.
	ancestors map[string][]string
	// spenderQueries counts the gettxspendingprevout calls, and the outpoints
	// each one carried.
	spenderQueries []int
}

func (m *fakeSlotMempool) call(_ context.Context, method, paramsJSON, _ string) (json.RawMessage, error) {
	switch method {
	case "getrawmempool":
		txids := make([]string, 0, len(m.slots)+len(m.plain)+len(m.unreadable))
		for txid := range m.slots {
			txids = append(txids, txid)
		}
		txids = append(txids, m.plain...)
		txids = append(txids, m.unreadable...)
		if paramsJSON == "[false]" {
			return json.Marshal(txids)
		}
		entries := map[string]any{}
		for _, txid := range txids {
			entries[txid] = map[string]any{"fees": map[string]any{"base": 0.0001}}
		}
		return json.Marshal(entries)

	case "getmempoolancestors":
		var params []string
		if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
			return nil, err
		}
		return json.Marshal(m.ancestors[params[0]])

	case "gettxspendingprevout":
		var params [][]struct {
			Txid string `json:"txid"`
			Vout int    `json:"vout"`
		}
		if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
			return nil, err
		}
		m.spenderQueries = append(m.spenderQueries, len(params[0]))
		out := []map[string]any{}
		for _, o := range params[0] {
			entry := map[string]any{"txid": o.Txid, "vout": o.Vout}
			if spender, ok := m.spends[fmt.Sprintf("%s:%d", o.Txid, o.Vout)]; ok {
				entry["spendingtxid"] = spender
			}
			out = append(out, entry)
		}
		return json.Marshal(out)

	case "getrawtransaction":
		var params []any
		if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
			return nil, err
		}
		txid, _ := params[0].(string)
		if slices.Contains(m.unreadable, txid) {
			return nil, fmt.Errorf("no transaction %s", txid)
		}
		slot, ok := m.slots[txid]
		if !ok {
			if !slices.Contains(m.plain, txid) {
				// Without a txindex, Core reads no transaction outside its mempool.
				return nil, fmt.Errorf("no transaction %s", txid)
			}
			// A transaction that is no bid carries a script the M8 parser refuses.
			return json.Marshal(map[string]any{"vout": []map[string]any{{
				"scriptPubKey": map[string]any{"hex": "51"},
			}}})
		}
		script, err := orchestrator.M8BmmRequestScript(
			uint8(slot), strings.Repeat("ab", 32), strings.Repeat("cd", 32))
		if err != nil {
			return nil, err
		}
		return json.Marshal(map[string]any{"vout": []map[string]any{{
			"scriptPubKey": map[string]any{"hex": hex.EncodeToString(script)},
		}}})
	}
	return nil, fmt.Errorf("the coin choice called %s", method)
}

// fakeBidWallet stands in for the wallet the bid spends through.
type fakeBidWallet struct {
	utxos []*wpb.UnspentOutput
	// byWallet holds the coins of each wallet, for a test that names more than
	// one. It comes before utxos.
	byWallet  map[string][]*wpb.UnspentOutput
	addresses int
	sends     []*wpb.SendTransactionRequest
	sendTxid  string
	// details answers GetTransactionDetails, and txs answers ListTransactions.
	details map[string]*wpb.GetTransactionDetailsResponse
	txs     []*wpb.TransactionEntry
	// listErr fails ListTransactions per wallet, for a test that names a
	// wallet the manager no longer holds.
	listErr map[string]error
	// listed records every ListTransactions request the wallet took.
	listed []*wpb.ListTransactionsRequest
}

func (w *fakeBidWallet) GetTransactionDetails(
	_ context.Context, req *connect.Request[wpb.GetTransactionDetailsRequest],
) (*connect.Response[wpb.GetTransactionDetailsResponse], error) {
	details, ok := w.details[req.Msg.Txid]
	if !ok {
		return nil, fmt.Errorf("the wallet knows no transaction %s", req.Msg.Txid)
	}
	return connect.NewResponse(details), nil
}

func (w *fakeBidWallet) ListTransactions(
	_ context.Context, req *connect.Request[wpb.ListTransactionsRequest],
) (*connect.Response[wpb.ListTransactionsResponse], error) {
	w.listed = append(w.listed, req.Msg)
	if err, ok := w.listErr[req.Msg.WalletId]; ok {
		return nil, err
	}
	// The handler defaults an unset count to 100, and the electrum backend cuts
	// the list at it after sorting an unconfirmed row last.
	count := int(req.Msg.Count)
	if count <= 0 {
		count = 100
	}
	txs := w.txs
	if count < len(txs) {
		txs = txs[:count]
	}
	return connect.NewResponse(&wpb.ListTransactionsResponse{Transactions: txs}), nil
}

func (w *fakeBidWallet) ResolveWalletID(walletID string) (string, error) {
	if walletID == "" {
		return "active", nil
	}
	return walletID, nil
}

func (w *fakeBidWallet) ListUnspent(
	_ context.Context, req *connect.Request[wpb.ListUnspentRequest],
) (*connect.Response[wpb.ListUnspentResponse], error) {
	utxos := w.utxos
	if w.byWallet != nil {
		utxos = w.byWallet[req.Msg.WalletId]
	}
	return connect.NewResponse(&wpb.ListUnspentResponse{Utxos: utxos}), nil
}

func (w *fakeBidWallet) GetNewAddress(
	_ context.Context, _ *connect.Request[wpb.GetNewAddressRequest],
) (*connect.Response[wpb.GetNewAddressResponse], error) {
	w.addresses++
	return connect.NewResponse(&wpb.GetNewAddressResponse{
		Address: fmt.Sprintf("address-%d", w.addresses),
	}), nil
}

func (w *fakeBidWallet) SendTransaction(
	_ context.Context, req *connect.Request[wpb.SendTransactionRequest],
) (*connect.Response[wpb.SendTransactionResponse], error) {
	w.sends = append(w.sends, req.Msg)
	return connect.NewResponse(&wpb.SendTransactionResponse{Txid: w.sendTxid}), nil
}

func slotCoinHandler(t *testing.T, mempool *fakeSlotMempool, wallet *fakeBidWallet) *BMMHandler {
	t.Helper()
	h, _ := newBMMModeHandler(t)
	h.wallet = wallet
	h.SetCoreCaller(mempool.call)
	return h
}

func bidRequest() *bmmpb.CreateBidRequest {
	return &bmmpb.CreateBidRequest{WalletId: "bidder", MaxBidSats: 30_000, FeeRateSatVb: 2}
}

// The change of another slot's bid is that slot's next coin. A bid that spends
// it dies when that slot replaces its own bid, because a replacement evicts
// every mempool descendant of the transaction it replaces.
func TestSlotCoinSkipsAnotherSlotsBidChange(t *testing.T) {
	const otherBid = "1111111111111111111111111111111111111111111111111111111111111111"
	const free = "2222222222222222222222222222222222222222222222222222222222222222"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: otherBid, Vout: 1, AmountSats: 1_000_000, Spendable: true},
		{Txid: free, Vout: 0, AmountSats: 500_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{slots: map[string]int{otherBid: 9}}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)
	require.NoError(t, err)

	assert.Equal(t, free, coin.Txid, "the larger coin belongs to slot 9")
	assert.Empty(t, wallet.sends, "a free coin needs no split")
}

// The bid pins one coin, and that coin covers the bid. Coin selection then adds
// no other coin, so the bid stays on its own lineage.
func TestSlotCoinPinsOneCoinThatCoversTheBid(t *testing.T) {
	const small = "3333333333333333333333333333333333333333333333333333333333333333"
	const large = "4444444444444444444444444444444444444444444444444444444444444444"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: small, Vout: 0, AmountSats: 12_000, Spendable: true, Confirmations: 6},
		{Txid: large, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)
	require.NoError(t, err)

	assert.Equal(t, large, coin.Txid)
	assert.GreaterOrEqual(t, coin.AmountSats, int64(10_000+bmmSlotCoinFeeSats))
}

// A coin under the bid plus its change cannot fund the bid alone, and the
// wallet would fill the rest from a coin another slot owns. The bid waits for
// PrepareBMM instead.
func TestSlotCoinRefusesWhenEveryCoinIsTooSmall(t *testing.T) {
	const tiny = "5555555555555555555555555555555555555555555555555555555555555555"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{{Txid: tiny, Vout: 0, AmountSats: 11_000, Spendable: true, Confirmations: 6}}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	_, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)

	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err),
		"the engine opens the round again on the next tick")
	assert.Empty(t, wallet.sends, "the bid path never splits")
}

// Two slots take two coins, so a replacement of one slot's bid respends coins
// the other slot never touched. The other bid stays in the mempool.
func TestSlotCoinGivesTwoSlotsTwoCoins(t *testing.T) {
	const first = "8888888888888888888888888888888888888888888888888888888888888888"
	const second = "9999999999999999999999999999999999999999999999999999999999999999"
	const bidOfFirstSlot = "aaaa111111111111111111111111111111111111111111111111111111111111"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: first, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
		{Txid: second, Vout: 0, AmountSats: 2_000_000, Spendable: true, Confirmations: 6},
	}}
	mempool := &fakeSlotMempool{}
	h := slotCoinHandler(t, mempool, wallet)

	ctx := context.Background()
	coinOne, err := h.slotCoin(ctx, bidRequest(), 1, 10_000)
	require.NoError(t, err)
	require.Equal(t, second, coinOne.Txid, "the smaller slot-sized coin comes first")

	// Slot 1 spends its coin, so the wallet now holds that bid's change.
	mempool.slots = map[string]int{bidOfFirstSlot: 1}
	wallet.utxos = []*wpb.UnspentOutput{
		{Txid: bidOfFirstSlot, Vout: 1, AmountSats: 1_990_000, Spendable: true},
		{Txid: first, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
	}

	coinTwo, err := h.slotCoin(ctx, bidRequest(), 2, 10_000)
	require.NoError(t, err)

	assert.Equal(t, first, coinTwo.Txid)
	assert.NotEqual(t, coinOne.Txid, coinTwo.Txid, "the two slots spend separate coins")
	assert.Empty(t, wallet.sends, "two free coins need no split")
}

func prepareRequest(sidechains int) *connect.Request[bmmpb.PrepareBMMRequest] {
	targets := make([]*bmmpb.PrepareBMMTarget, 0, sidechains)
	for range sidechains {
		targets = append(targets, &bmmpb.PrepareBMMTarget{WalletId: "bidder", MaxBidSats: 30_000})
	}
	return connect.NewRequest(&bmmpb.PrepareBMMRequest{Targets: targets})
}

// prepared reads the one wallet the tests below prepare.
func prepared(t *testing.T, resp *connect.Response[bmmpb.PrepareBMMResponse]) *bmmpb.PrepareBMMWallet {
	t.Helper()
	require.Len(t, resp.Msg.Wallets, 1)
	return resp.Msg.Wallets[0]
}

// workingSats is the balance one sidechain bids many rounds from.
const workingSats = 30_000*bmmSlotCoinRounds + bmmSlotCoinFeeSats

// Five sidechains bid from one wallet, so the wallet needs five coins. The
// split pays the missing ones out of the largest coin, and leaves the coins the
// other slots already bid from alone.
func TestPrepareBMMSplitsWhenCoinsAreMissing(t *testing.T) {
	const held = "1111222222222222222222222222222222222222222222222222222222222222"
	const large = "2222333333333333333333333333333333333333333333333333333333333333"

	wallet := &fakeBidWallet{
		utxos: []*wpb.UnspentOutput{
			{Txid: held, Vout: 0, AmountSats: workingSats, Spendable: true, Confirmations: 6},
			{Txid: large, Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	resp, err := h.PrepareBMM(context.Background(), prepareRequest(5))
	require.NoError(t, err)

	wallet0 := prepared(t, resp)
	assert.Equal(t, int32(2), wallet0.UsableCoins)
	assert.Equal(t, int32(5), wallet0.WantedCoins)
	assert.Equal(t, "split-txid", wallet0.SplitTxid)

	require.Len(t, wallet.sends, 1)
	split := wallet.sends[0]
	assert.Len(t, split.Destinations, 4,
		"three coins are missing, and the split pays back the coin it spends")
	for address, sats := range split.Destinations {
		assert.Equal(t, int64(workingSats), sats, "coin %s funds many rounds", address)
	}
	require.Len(t, split.RequiredInputs, 1)
	assert.Equal(t, large, split.RequiredInputs[0].Txid,
		"the split spends the largest coin alone, so the other slots keep theirs")
}

// A wallet that already holds one coin per sidechain needs no split, and a
// split would spend the coins the slots bid from.
func TestPrepareBMMLeavesAFullWalletAlone(t *testing.T) {
	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: "aaaa", Vout: 0, AmountSats: workingSats, Spendable: true, Confirmations: 6},
		{Txid: "bbbb", Vout: 0, AmountSats: workingSats, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	resp, err := h.PrepareBMM(context.Background(), prepareRequest(2))
	require.NoError(t, err)

	assert.Equal(t, int32(2), prepared(t, resp).UsableCoins)
	assert.Empty(t, prepared(t, resp).SplitTxid)
	assert.Empty(t, wallet.sends)
}

// A coin under the working balance funds a few rounds and then leaves its slot
// with nothing, so the guard counts it as missing.
func TestPrepareBMMCountsASmallCoinAsMissing(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos: []*wpb.UnspentOutput{
			{Txid: "aaaa", Vout: 0, AmountSats: workingSats - 1, Spendable: true, Confirmations: 6},
			{Txid: "bbbb", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	resp, err := h.PrepareBMM(context.Background(), prepareRequest(2))
	require.NoError(t, err)

	assert.Equal(t, int32(1), prepared(t, resp).UsableCoins, "only the large coin can work")
	require.Len(t, wallet.sends, 1)
	assert.Len(t, wallet.sends[0].Destinations, 2,
		"one coin is missing, and the split pays back the coin it spends")
}

// The Electrum scan carries an unconfirmed coin, Bitcoin Core does not. A
// second split would spend the same coin again.
func TestPrepareBMMSplitsOnlyOnce(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos:    []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		sendTxid: "split-txid",
	}
	mempool := &fakeSlotMempool{}
	h := slotCoinHandler(t, mempool, wallet)

	ctx := context.Background()
	_, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)
	require.Len(t, wallet.sends, 1)

	mempool.plain = append(mempool.plain, wallet.sendTxid)
	resp, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)

	assert.Empty(t, prepared(t, resp).SplitTxid, "the wallet waits for the first split")
	assert.Len(t, wallet.sends, 1)
}

// The local node can take a moment to see a split an Electrum wallet broadcast
// through Esplora. A hold that drops at once pays for a second split.
func TestPrepareBMMHoldsASplitTheNodeHasNotSeen(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos:    []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	ctx := context.Background()
	_, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)
	require.Len(t, wallet.sends, 1)

	resp, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)

	assert.Empty(t, prepared(t, resp).SplitTxid, "the wallet waits out the propagation gap")
	assert.Len(t, wallet.sends, 1)
}

// A split the mempool dropped must not hold the next one back forever.
func TestPrepareBMMSplitsAgainOnceTheFirstSplitIsGone(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos:    []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	ctx := context.Background()
	_, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)

	// The node named no such transaction for longer than the propagation gap.
	h.splitMu.Lock()
	h.splits["bidder"] = pendingSplit{txid: wallet.sendTxid, at: time.Now().Add(-2 * bmmSplitPatience)}
	h.splitMu.Unlock()

	resp, err := h.PrepareBMM(ctx, prepareRequest(5))
	require.NoError(t, err)

	assert.Equal(t, "split-txid", prepared(t, resp).SplitTxid)
	assert.Len(t, wallet.sends, 2)
}

// A wallet too small for the coins says so, rather than broadcasting a split
// that spends more than it holds.
func TestPrepareBMMRefusesAWalletThatCannotPay(t *testing.T) {
	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 5_000, Spendable: true, Confirmations: 6}}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	_, err := h.PrepareBMM(context.Background(), prepareRequest(5))

	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, wallet.sends)
}

// A parent the node cannot read may hold another slot's bid. A bid over its
// change would then die with the replacement that slot broadcasts.
func TestSlotCoinSkipsACoinItCannotRead(t *testing.T) {
	const unreadable = "cccc111111111111111111111111111111111111111111111111111111111111"
	const free = "dddd222222222222222222222222222222222222222222222222222222222222"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: unreadable, Vout: 1, AmountSats: 3_000_000, Spendable: true},
		{Txid: free, Vout: 0, AmountSats: 500_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{unreadable: []string{unreadable}}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)
	require.NoError(t, err)

	assert.Equal(t, free, coin.Txid, "the coin the node can name is the safe one")
}

// A watch-only coin cannot sign a bid, so counting it would leave a slot with
// an opening bid that always fails.
func TestSlotCoinSkipsAWatchOnlyCoin(t *testing.T) {
	const watched = "eeee111111111111111111111111111111111111111111111111111111111111"
	const own = "ffff222222222222222222222222222222222222222222222222222222222222"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: watched, Vout: 0, AmountSats: 9_000_000, Spendable: false},
		{Txid: own, Vout: 0, AmountSats: 500_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)
	require.NoError(t, err)

	assert.Equal(t, own, coin.Txid, "only a coin the wallet signs can pay a bid")
}

// One target names the wallet by its id, another leaves it empty for the active
// wallet. Both bid from the same coins, so both count toward one wallet.
func TestPrepareBMMJoinsTheAliasesOfOneWallet(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos:    []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	resp, err := h.PrepareBMM(context.Background(), connect.NewRequest(&bmmpb.PrepareBMMRequest{
		Targets: []*bmmpb.PrepareBMMTarget{
			{WalletId: "", MaxBidSats: 30_000},
			{WalletId: "active", MaxBidSats: 45_000},
		},
	}))
	require.NoError(t, err)

	only := prepared(t, resp)
	assert.Equal(t, "active", only.WalletId)
	assert.Equal(t, int32(2), only.WantedCoins, "two sidechains spend one wallet")

	require.Len(t, wallet.sends, 1)
	for _, sats := range wallet.sends[0].Destinations {
		assert.Equal(t, int64(45_000*bmmSlotCoinRounds+bmmSlotCoinFeeSats), sats,
			"the coin covers the highest ceiling either sidechain bids to")
	}
}

// The split spends its source. A source that counted as usable therefore has to
// pay itself back, or the wallet ends the split one coin short.
func TestPrepareBMMPaysBackTheCoinTheSplitSpends(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos: []*wpb.UnspentOutput{
			{Txid: "aaaa", Vout: 0, AmountSats: 3 * workingSats, Spendable: true, Confirmations: 6},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	resp, err := h.PrepareBMM(context.Background(), prepareRequest(2))
	require.NoError(t, err)

	assert.Equal(t, int32(1), prepared(t, resp).UsableCoins)
	require.Len(t, wallet.sends, 1)
	assert.Len(t, wallet.sends[0].Destinations, 2,
		"two sidechains bid, and the one usable coin pays for both")
}

// One wallet that cannot pay must not hold back the coins of the next one. The
// engine counts again only on the next block, so that slot would miss the whole
// round.
func TestPrepareBMMPreparesEveryWalletAfterAFailure(t *testing.T) {
	wallet := &fakeBidWallet{
		byWallet: map[string][]*wpb.UnspentOutput{
			"poor": {{Txid: "aaaa", Vout: 0, AmountSats: 5_000, Spendable: true, Confirmations: 6}},
			"rich": {{Txid: "bbbb", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	_, err := h.PrepareBMM(context.Background(), connect.NewRequest(&bmmpb.PrepareBMMRequest{
		Targets: []*bmmpb.PrepareBMMTarget{
			{WalletId: "poor", MaxBidSats: 30_000},
			{WalletId: "rich", MaxBidSats: 30_000},
			{WalletId: "rich", MaxBidSats: 30_000},
		},
	}))

	require.Error(t, err, "the poor wallet cannot pay for its coin")
	require.Len(t, wallet.sends, 1, "the rich wallet still gets its coins")
	assert.Equal(t, "bbbb", wallet.sends[0].RequiredInputs[0].Txid)
}

// A bid sized at a rate carries no amount yet. A coin under what the rate costs
// makes the wallet reach for the coin of another slot.
func TestPinSatsCoversARateSizedBid(t *testing.T) {
	assert.Equal(t, int64(12_000), pinSats(12_000, false, 50),
		"an amount names what the bid pays")
	assert.Equal(t, int64(50*nominalBidVsize), pinSats(0, true, 50),
		"a rate names it by the size the wallet builds")
}

// An Electrum wallet lists its own change before Core sees the bid that pays
// it. A coin the node cannot name may be another slot's change, and a bid over
// it dies with that slot's replacement.
func TestSlotCoinWaitsForACoinTheNodeCannotName(t *testing.T) {
	const fresh = "cccc333333333333333333333333333333333333333333333333333333333333"
	const confirmed = "dddd444444444444444444444444444444444444444444444444444444444444"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: fresh, Vout: 1, AmountSats: 3_000_000, Spendable: true},
		{Txid: confirmed, Vout: 0, AmountSats: 500_000, Spendable: true, Confirmations: 1},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 1, 10_000)
	require.NoError(t, err)

	assert.Equal(t, confirmed, coin.Txid, "a block put the confirmed coin out of reach")
}

// A coin a live bid created still belongs to the slot that made it, and that
// slot bids from it again. Counting it as missing pays for a split the wallet
// does not need.
func TestPrepareBMMCountsTheCoinOfALiveBid(t *testing.T) {
	const bidOfSlotNine = "eeee999999999999999999999999999999999999999999999999999999999999"

	wallet := &fakeBidWallet{
		utxos: []*wpb.UnspentOutput{
			{Txid: bidOfSlotNine, Vout: 1, AmountSats: workingSats, Spendable: true},
			{Txid: "ffff", Vout: 0, AmountSats: workingSats, Spendable: true, Confirmations: 6},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{slots: map[string]int{bidOfSlotNine: 9}}, wallet)

	resp, err := h.PrepareBMM(context.Background(), prepareRequest(2))
	require.NoError(t, err)

	assert.Equal(t, int32(2), prepared(t, resp).UsableCoins, "slot 9 bids from its own change again")
	assert.Empty(t, wallet.sends, "a full wallet needs no split")
}

// A split spends a coin no live bid created, or a replacement on that slot
// evicts the split and every coin it pays.
func TestPrepareBMMNeverSplitsTheCoinOfALiveBid(t *testing.T) {
	const bidOfSlotNine = "aaaa888888888888888888888888888888888888888888888888888888888888"

	wallet := &fakeBidWallet{
		utxos: []*wpb.UnspentOutput{
			{Txid: bidOfSlotNine, Vout: 1, AmountSats: 499_485_401, Spendable: true},
			{Txid: "bbbb", Vout: 0, AmountSats: 5_000, Spendable: true, Confirmations: 6},
		},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{slots: map[string]int{bidOfSlotNine: 9}}, wallet)

	_, err := h.PrepareBMM(context.Background(), prepareRequest(5))

	require.Error(t, err)
	assert.Empty(t, wallet.sends)
}

// The split paid its coins, so the wallet waits for nothing. A hold that stays
// on keeps a sidechain that starts later out of the round.
func TestPrepareBMMDropsTheHoldOnceTheSplitPaid(t *testing.T) {
	wallet := &fakeBidWallet{
		utxos:    []*wpb.UnspentOutput{{Txid: "aaaa", Vout: 0, AmountSats: 499_485_401, Spendable: true, Confirmations: 6}},
		sendTxid: "split-txid",
	}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	ctx := context.Background()
	_, err := h.PrepareBMM(ctx, prepareRequest(2))
	require.NoError(t, err)
	require.Len(t, wallet.sends, 1)

	// The split confirmed, and one more sidechain now bids.
	wallet.utxos = append(wallet.utxos, &wpb.UnspentOutput{
		Txid: "split-txid", Vout: 0, AmountSats: workingSats, Spendable: true, Confirmations: 1,
	})
	resp, err := h.PrepareBMM(ctx, prepareRequest(4))
	require.NoError(t, err)

	assert.Equal(t, "split-txid", prepared(t, resp).SplitTxid, "the wallet pays the coins it still needs")
	assert.Len(t, wallet.sends, 2)
}

// An electrum scan lists a coin a live bid already spends until it catches up.
// An opening bid over that coin conflicts with the bid, and the node refuses it
// at the same fee.
func TestSlotCoinSkipsACoinALiveBidSpends(t *testing.T) {
	const taken = "6666666666666666666666666666666666666666666666666666666666666666"
	const free = "7777777777777777777777777777777777777777777777777777777777777777"
	const bid = "8888888888888888888888888888888888888888888888888888888888888888"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: taken, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
		{Txid: free, Vout: 0, AmountSats: 1_000_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{
		slots:  map[string]int{bid: 9},
		spends: map[string]string{taken + ":0": bid},
	}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 99, 10_000)
	require.NoError(t, err)

	assert.Equal(t, free, coin.Txid, "the larger coin already funds a live bid")
}

// The largest coin of the wallet pays every other send. A bid takes a
// slot-sized coin instead, so a replacement can never take that balance away.
func TestSlotCoinTakesTheSmallestSlotSizedCoin(t *testing.T) {
	const slotSized = "9999999999999999999999999999999999999999999999999999999999999999"
	const bulk = "aaaa999999999999999999999999999999999999999999999999999999999999"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: slotSized, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
		{Txid: bulk, Vout: 0, AmountSats: 480_000_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 9, 10_000)
	require.NoError(t, err)

	assert.Equal(t, slotSized, coin.Txid)
}

// A deposit over a live bid carries no bid of its own. A replacement of the
// bid below it takes the deposit and its change away as well, so no other slot
// may bid from that change.
func TestSlotCoinSkipsTheChangeOfABidDescendant(t *testing.T) {
	const bid = "bbbb111111111111111111111111111111111111111111111111111111111111"
	const deposit = "cccc222222222222222222222222222222222222222222222222222222222222"
	const free = "dddd333333333333333333333333333333333333333333333333333333333333"

	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: deposit, Vout: 2, AmountSats: 400_000_000, Spendable: true},
		{Txid: free, Vout: 0, AmountSats: 3_000_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{
		slots:     map[string]int{bid: 9},
		plain:     []string{deposit},
		ancestors: map[string][]string{deposit: {bid}},
	}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 2, 10_000)
	require.NoError(t, err)

	assert.Equal(t, free, coin.Txid, "the deposit change belongs to slot 9")
}

func TestSlotCoinSkipsItsOwnBidDescendant(t *testing.T) {
	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: plainTx, Vout: 0, AmountSats: 4_000_000, Spendable: true},
		{Txid: oldBlock, Vout: 0, AmountSats: 5_000_000, Spendable: true, Confirmations: 6},
	}}
	h := slotCoinHandler(t, &fakeSlotMempool{
		slots:     map[string]int{liveBid: 9},
		plain:     []string{plainTx},
		ancestors: map[string][]string{plainTx: {liveBid}},
	}, wallet)

	coin, err := h.slotCoin(context.Background(), bidRequest(), 9, 10_000)
	require.NoError(t, err)
	assert.Equal(t, oldBlock, coin.Txid)
}

func TestPrepareBMMSkipsABidDescendant(t *testing.T) {
	wallet := &fakeBidWallet{utxos: []*wpb.UnspentOutput{
		{Txid: plainTx, Vout: 0, AmountSats: 4_000_000, Spendable: true},
		{Txid: oldBlock, Vout: 0, AmountSats: 10_000_000, Spendable: true, Confirmations: 6},
	}, sendTxid: "split"}
	h := slotCoinHandler(t, &fakeSlotMempool{
		slots:     map[string]int{liveBid: 9},
		plain:     []string{plainTx},
		ancestors: map[string][]string{plainTx: {liveBid}},
	}, wallet)

	_, err := h.PrepareBMM(context.Background(), prepareRequest(2))
	require.NoError(t, err)
	require.Len(t, wallet.sends, 1)
	require.Len(t, wallet.sends[0].RequiredInputs, 1)
	assert.Equal(t, oldBlock, wallet.sends[0].RequiredInputs[0].Txid)
}
