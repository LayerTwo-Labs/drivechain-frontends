package sidechain

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeNode answers the two feeds a mempool read can use.
type fakeNode struct {
	BMMNode
	mempool   string
	template  string
	addresses string
	utxos     string
	stxos     string
	called    []string
}

func (n *fakeNode) CallRaw(_ context.Context, method string, _ any) (json.RawMessage, error) {
	n.called = append(n.called, method)
	if method == "list_mempool" && n.mempool != "" {
		return json.RawMessage(n.mempool), nil
	}
	if method == "get_wallet_addresses" && n.addresses != "" {
		return json.RawMessage(n.addresses), nil
	}
	if method == "get_wallet_utxos" {
		if n.utxos == "" {
			return json.RawMessage("[]"), nil
		}
		return json.RawMessage(n.utxos), nil
	}
	if method == "get_stxos" && n.stxos != "" {
		return json.RawMessage(n.stxos), nil
	}
	return nil, fmt.Errorf("this node serves no %s", method)
}

func (n *fakeNode) GetBlockTemplate(_ context.Context) (*BlockTemplate, error) {
	n.called = append(n.called, "get_block_template")
	if n.template == "" {
		return nil, fmt.Errorf("no template")
	}
	return &BlockTemplate{Block: json.RawMessage(n.template)}, nil
}

const listMempoolAnswer = `[
  {"txid": "aa", "size": 240, "tx": {"outputs": [
     {"address": "mine", "content": {"Value": 10000}},
     {"address": "theirs", "content": {"Value": 500}}
  ]}}
]`

const templateAnswer = `{"header": {"merkle_root": "m"}, "body": {"transactions": [
  {"outputs": [{"address": "mine", "content": {"BitcoinSats": 7000}}]}
]}}`

func TestMempoolPrefersTheNodeListing(t *testing.T) {
	node := &fakeNode{mempool: listMempoolAnswer, template: templateAnswer}

	txs, err := Mempool(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, txs, 1)
	assert.Equal(t, "aa", txs[0].Txid)
	assert.Equal(t, int64(240), txs[0].SizeBytes)
	require.Len(t, txs[0].Outputs, 2)
	assert.Equal(t, uint32(1), txs[0].Outputs[1].Vout)
	assert.NotContains(t, node.called, "get_block_template", "the listing answers it whole")
}

// An older node serves no list_mempool. The template holds the same
// transactions, so the balance still moves; only the txid is missing.
func TestMempoolFallsBackToTheTemplate(t *testing.T) {
	node := &fakeNode{template: templateAnswer}

	txs, err := Mempool(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, txs, 1)
	assert.Empty(t, txs[0].Txid, "a template names no txid")
	assert.Equal(t, int64(7000), txs[0].Outputs[0].ValueSats)
}

func TestMempoolReadsThunderInputPairs(t *testing.T) {
	const transaction = `{"inputs":[
		[{"Regular":{"txid":"old","vout":2}},"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"],
		[{"Deposit":"maintxid:0"},"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"]
	],"outputs":[{"address":"mine","content":{"Value":9000}}]}`
	for _, tc := range []struct {
		name string
		node *fakeNode
		txid string
	}{
		{
			name: "mempool",
			node: &fakeNode{mempool: `[{"txid":"spend","size":240,"tx":` + transaction + `}]`},
			txid: "spend",
		},
		{
			name: "template",
			node: &fakeNode{template: `{"body":{"transactions":[` + transaction + `]}}`},
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			txs, err := Mempool(context.Background(), tc.node)
			require.NoError(t, err)
			require.Len(t, txs, 1)
			assert.Equal(t, tc.txid, txs[0].Txid)
			assert.Equal(t, []MempoolInput{{Key: "old:2"}, {Key: "maintxid:0"}}, txs[0].Inputs)
			assert.Equal(t, []MempoolOutput{{Address: "mine", Vout: 0, ValueSats: 9000}}, txs[0].Outputs)
			if tc.txid != "" {
				assert.NotContains(t, tc.node.called, "get_block_template")
			}
		})
	}
}

func TestMempoolIsEmptyWhenNeitherFeedAnswers(t *testing.T) {
	txs, err := Mempool(context.Background(), &fakeNode{})
	require.Error(t, err)
	assert.Empty(t, txs)
}

func TestDeltaCountsOnlyOurAddresses(t *testing.T) {
	txs := []MempoolTx{{Txid: "aa", Outputs: []MempoolOutput{
		{Address: "mine", ValueSats: 10000},
		{Address: "theirs", ValueSats: 500},
		{Address: "mine", ValueSats: 250},
	}}}
	mine := map[string]bool{"mine": true}

	assert.Equal(t, int64(10250), DeltaFor(txs, mine, nil).CreditSats)
	assert.Zero(t, DeltaFor(txs, nil, nil).CreditSats, "a wallet with no address is owed nothing")
}

// A transfer of ours pays change back. Counting the change alone reads the
// spent coin twice, because the node still lists it as confirmed.
func TestDeltaSubtractsWhatWeSpend(t *testing.T) {
	txs := []MempoolTx{{
		Txid:    "spend",
		Inputs:  []MempoolInput{{Key: "old:0"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 9000}, {Address: "theirs", ValueSats: 900}},
	}}
	ourCoins := map[string]int64{"old:0": 10000}

	got := DeltaFor(txs, map[string]bool{"mine": true}, ourCoins)
	assert.Equal(t, int64(9000), got.CreditSats, "the change comes back")
	assert.Equal(t, int64(10000), got.DebitSats, "and the coin it spends goes")
}

// A payment from a stranger spends no coin of ours, so nothing subtracts.
func TestDeltaIgnoresAStrangersInputs(t *testing.T) {
	txs := []MempoolTx{{
		Txid:    "gift",
		Inputs:  []MempoolInput{{Key: "theirs:3"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 10000}},
	}}

	got := DeltaFor(txs, map[string]bool{"mine": true}, map[string]int64{"old:0": 10000})
	assert.Equal(t, int64(10000), got.CreditSats)
	assert.Zero(t, got.DebitSats, "we spend nothing of ours")
}

func TestOwnedOutputsDropsTheRestOfTheTransaction(t *testing.T) {
	txs := []MempoolTx{
		{Txid: "aa", Outputs: []MempoolOutput{
			{Address: "mine", Vout: 0, ValueSats: 10000},
			{Address: "theirs", Vout: 1, ValueSats: 500},
		}},
		{Txid: "bb", Outputs: []MempoolOutput{{Address: "theirs", ValueSats: 900}}},
	}

	kept := OwnedOutputs(txs, map[string]bool{"mine": true})
	require.Len(t, kept, 1, "a transaction that pays us nothing has no row")
	assert.Equal(t, "aa", kept[0].Txid)
	require.Len(t, kept[0].Outputs, 1)
	assert.Equal(t, uint32(0), kept[0].Outputs[0].Vout)
}

// A withdrawal costs the payout and the mainchain fee together, so a balance
// that counts the payout alone reads high.
func TestOutputValueReadsEveryShape(t *testing.T) {
	for name, want := range map[string]int64{
		`{"Value":10000}`:      10000,
		`{"BitcoinSats":7000}`: 7000,
		`{"BitAsset":3}`:       0,
		`{"Withdrawal":{"value":50000,"main_fee":1200,"main_address":"bc1q"}}`:                  51200,
		`{"BitcoinWithdrawal":{"value_sats":50000,"main_fee_sats":1200,"main_address":"bc1q"}}`: 51200,
	} {
		assert.Equal(t, want, OutputValueSats(json.RawMessage(name)), "reading %s", name)
	}
}

// The node lists only mined coins, so a payment on its way reads as no coin
// at all until the next block.
func TestWithMempoolUTXOsAppendsTheUnconfirmedCoins(t *testing.T) {
	node := &fakeNode{
		mempool:   listMempoolAnswer,
		addresses: `["mine"]`,
	}
	confirmed := json.RawMessage(`[{"outpoint":{"Regular":{"txid":"old","vout":0}},` +
		`"output":{"address":"mine","content":{"Value":2000}}}]`)

	merged := WithMempoolUTXOs(context.Background(), node, confirmed)
	var rows []map[string]any
	require.NoError(t, json.Unmarshal(merged, &rows))
	require.Len(t, rows, 2, "the mined coin keeps its place, and the new one follows")

	assert.Nil(t, rows[0]["confirmed"], "a mined coin carries no flag")
	assert.Equal(t, false, rows[1]["confirmed"])

	outpoint := rows[1]["outpoint"].(map[string]any)["Regular"].(map[string]any)
	assert.Equal(t, "aa", outpoint["txid"])
	output := rows[1]["output"].(map[string]any)
	assert.Equal(t, "mine", output["address"])
	assert.Equal(t, float64(10000), output["content"].(map[string]any)["Value"])
}

// A coin with no outpoint is not a coin. The balance still counts it.
func TestWithMempoolUTXOsSkipsATemplateWithNoTxid(t *testing.T) {
	node := &fakeNode{template: templateAnswer, addresses: `["mine"]`}
	confirmed := json.RawMessage(`[]`)

	merged := WithMempoolUTXOs(context.Background(), node, confirmed)
	assert.JSONEq(t, `[]`, string(merged))
}

func TestWithMempoolUTXOsKeepsTheListingWhenTheWalletHasNoAddress(t *testing.T) {
	node := &fakeNode{mempool: listMempoolAnswer}
	confirmed := json.RawMessage(`[{"outpoint":{"Regular":{"txid":"old","vout":0}}}]`)

	assert.JSONEq(t, string(confirmed), string(WithMempoolUTXOs(context.Background(), node, confirmed)))
}

// A wallet can hold a deposit coin as well as a regular one, so both count.
// A coinbase names no coin a wallet spends.
func TestSpendsNamesEveryCoinAnInputTakes(t *testing.T) {
	node := &fakeNode{mempool: `[
	  {"txid":"aa","size":10,"tx":{
	     "inputs":[
	       {"Regular":{"txid":"old","vout":2}},
	       {"Deposit":"maintxid:0"},
	       {"Coinbase":{"merkle_root":"mr","vout":0}}
	     ],
	     "outputs":[{"address":"mine","content":{"Value":10}}]}}
	]`}

	txs, err := Mempool(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, txs[0].Inputs, 2, "a regular input and a deposit both name a coin")
	assert.Equal(t, MempoolInput{Key: "old:2"}, txs[0].Inputs[0])
}

func TestOurCoinsKeysEachCoinByItsOutpoint(t *testing.T) {
	node := &fakeNode{utxos: `[
	  {"outpoint":{"Regular":{"txid":"aa","vout":1}},"output":{"content":{"Value":2000}}},
	  {"outpoint":{"Deposit":"maintxid:0"},"output":{"content":{"Value":500}}}
	]`}

	coins, err := OurCoins(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, coins, 2, "a deposit is a coin the wallet can spend")
	assert.Equal(t, int64(2000), coins["aa:1"])
	assert.Equal(t, int64(500), coins["maintxid:0"])
}

func TestSpentCoinsKeysEachCoinByItsOutpoint(t *testing.T) {
	node := &fakeNode{stxos: `[
	  {"outpoint":{"Deposit":"maintxid:0"},
	   "output":{"output":{"address":"mine","content":{"Value":500}},"inpoint":{"Regular":{"txid":"bb","vin":0}}}},
	  [{"Regular":{"txid":"aa","vout":1}},
	   {"output":{"address":"mine","content":{"Value":2000}},"inpoint":{"Regular":{"txid":"cc","vin":1}}}]
	]`}

	coins, err := SpentCoins(context.Background(), node, []string{"mine"})
	require.NoError(t, err)
	assert.Equal(t, map[string]int64{"maintxid:0": 500, "aa:1": 2000}, coins)
}

func TestSpentCoinsIsEmptyOnANodeWithNoStxos(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}`))
		assert.NoError(t, err)
	}))
	t.Cleanup(srv.Close)
	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)

	coins, err := SpentCoins(context.Background(), NewJSONRPCProxy(host, port), []string{"mine"})
	require.NoError(t, err)
	assert.Empty(t, coins)
}

func TestSpentCoinsReportsAFault(t *testing.T) {
	_, err := SpentCoins(context.Background(), &fakeNode{}, []string{"mine"})
	require.Error(t, err)
}

// A child spends a coin its parent made, and that coin never reached the
// confirmed listing. Without it the child's change counts on top of money the
// wallet never held.
func TestDeltaFollowsAChainedSpend(t *testing.T) {
	txs := []MempoolTx{
		{
			Txid:    "parent",
			Outputs: []MempoolOutput{{Address: "mine", Vout: 0, ValueSats: 10000}},
		},
		{
			Txid:    "child",
			Inputs:  []MempoolInput{{Key: "parent:0"}},
			Outputs: []MempoolOutput{{Address: "mine", Vout: 0, ValueSats: 9000}},
		},
	}

	got := DeltaFor(txs, map[string]bool{"mine": true}, nil)
	assert.Equal(t, int64(19000), got.CreditSats, "both outputs pay us")
	assert.Equal(t, int64(10000), got.ChainedDebitSats, "and the child spends the parent's coin")
	assert.Zero(t, got.DebitSats, "no confirmed coin leaves")
}

// A wallet can spend a deposit, and its outpoint is a plain string.
func TestDeltaSubtractsASpentDeposit(t *testing.T) {
	txs := []MempoolTx{{
		Txid:    "spend",
		Inputs:  []MempoolInput{{Key: "maintxid:0"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 400}},
	}}

	got := DeltaFor(txs, map[string]bool{"mine": true}, map[string]int64{"maintxid:0": 500})
	assert.Equal(t, int64(400), got.CreditSats)
	assert.Equal(t, int64(500), got.DebitSats, "a deposit is a coin we can spend")
}

// A coin an unconfirmed transaction spends is no longer spendable. Listing it
// beside the change shows the same money twice.
func TestWithMempoolUTXOsDropsWhatTheMempoolSpends(t *testing.T) {
	node := &fakeNode{
		addresses: `["mine"]`,
		mempool: `[{"txid":"spend","size":100,"tx":{
		    "inputs":[[{"Regular":{"txid":"old","vout":0}},"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"]],
		    "outputs":[{"address":"mine","content":{"Value":9000}}]}}]`,
	}
	confirmed := json.RawMessage(`[
	  {"outpoint":{"Regular":{"txid":"old","vout":0}},"output":{"address":"mine","content":{"Value":10000}}},
	  {"outpoint":{"Regular":{"txid":"keep","vout":1}},"output":{"address":"mine","content":{"Value":2000}}}
	]`)

	var rows []map[string]any
	require.NoError(t, json.Unmarshal(WithMempoolUTXOs(context.Background(), node, confirmed), &rows))

	keys := make([]string, 0, len(rows))
	for _, row := range rows {
		key, ok := outpointKey(mustJSON(t, row))
		require.True(t, ok)
		keys = append(keys, key)
	}
	assert.ElementsMatch(t, []string{"keep:1", "spend:0"}, keys,
		"the spent coin goes, the untouched one stays, and the change arrives")
}

// A child spends its parent's output, so neither the parent's coin nor a
// second copy may stand in the listing.
func TestWithMempoolUTXOsDropsAParentOutputAChildSpends(t *testing.T) {
	node := &fakeNode{
		addresses: `["mine"]`,
		mempool: `[
		  {"txid":"parent","size":10,"tx":{"inputs":[],
		     "outputs":[{"address":"mine","content":{"Value":10000}}]}},
		  {"txid":"child","size":10,"tx":{"inputs":[{"Regular":{"txid":"parent","vout":0}}],
		     "outputs":[{"address":"mine","content":{"Value":9000}}]}}
		]`,
	}

	var rows []map[string]any
	require.NoError(t, json.Unmarshal(
		WithMempoolUTXOs(context.Background(), node, json.RawMessage(`[]`)), &rows))
	require.Len(t, rows, 1)
	key, ok := outpointKey(mustJSON(t, rows[0]))
	require.True(t, ok)
	assert.Equal(t, "child:0", key)
}

func mustJSON(t *testing.T, v any) json.RawMessage {
	t.Helper()
	raw, err := json.Marshal(v)
	require.NoError(t, err)
	return raw
}

// A withdrawal output carries a change address, and the money still leaves the
// chain. Crediting it reads the payment back into the wallet.
func TestDeltaDoesNotCreditAWithdrawal(t *testing.T) {
	node := &fakeNode{
		addresses: `["mine"]`,
		mempool: `[{"txid":"w","size":100,"tx":{
		    "inputs":[{"Regular":{"txid":"old","vout":0}}],
		    "outputs":[
		      {"address":"mine","content":{"Withdrawal":{"value":5000,"main_fee":100,"main_address":"bc1q"}}},
		      {"address":"mine","content":{"Value":4900}}
		    ]}}]`,
	}

	txs, err := Mempool(context.Background(), node)
	require.NoError(t, err)
	require.True(t, txs[0].Outputs[0].Withdrawal)
	require.False(t, txs[0].Outputs[1].Withdrawal)

	delta := DeltaFor(txs, map[string]bool{"mine": true}, map[string]int64{"old:0": 10000})
	assert.Equal(t, int64(4900), delta.CreditSats, "only the change comes back")
	assert.Equal(t, int64(10000), delta.DebitSats)
}

// A withdrawal is money on its way out, never a coin the wallet can spend.
func TestWithMempoolUTXOsSkipsAWithdrawalOutput(t *testing.T) {
	node := &fakeNode{
		addresses: `["mine"]`,
		mempool: `[{"txid":"w","size":100,"tx":{"inputs":[],
		    "outputs":[
		      {"address":"mine","content":{"Withdrawal":{"value":5000,"main_fee":100,"main_address":"bc1q"}}},
		      {"address":"mine","content":{"Value":4900}}
		    ]}}]`,
	}

	var rows []map[string]any
	require.NoError(t, json.Unmarshal(
		WithMempoolUTXOs(context.Background(), node, json.RawMessage(`[]`)), &rows))
	require.Len(t, rows, 1)
	key, ok := outpointKey(mustJSON(t, rows[0]))
	require.True(t, ok)
	assert.Equal(t, "w:1", key, "the change is a coin, the withdrawal is not")
}

// A block template names no txid, so a child's input cannot be matched against
// its parent's output. Counting those outputs reads a chained spend twice.
func TestDeltaIgnoresATransactionWithNoTxid(t *testing.T) {
	txs := []MempoolTx{{Outputs: []MempoolOutput{{Address: "mine", ValueSats: 10000}}}}

	assert.Zero(t, DeltaFor(txs, map[string]bool{"mine": true}, nil).CreditSats,
		"only a node that names its txids can be reconciled")
}
