package sidechain

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeNode answers the two feeds a mempool read can use.
type fakeNode struct {
	SidechainRPCProxy
	mempool   string
	template  string
	addresses string
	utxos     string
	called    []string
}

func (n *fakeNode) GetWalletUtxos(_ context.Context) (json.RawMessage, error) {
	n.called = append(n.called, "get_wallet_utxos")
	if n.utxos == "" {
		return json.RawMessage("[]"), nil
	}
	return json.RawMessage(n.utxos), nil
}

func (n *fakeNode) CallRaw(_ context.Context, method string, _ any) (json.RawMessage, error) {
	n.called = append(n.called, method)
	if method == "list_mempool" && n.mempool != "" {
		return json.RawMessage(n.mempool), nil
	}
	if method == "get_wallet_addresses" && n.addresses != "" {
		return json.RawMessage(n.addresses), nil
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

func TestMempoolIsEmptyWhenNeitherFeedAnswers(t *testing.T) {
	txs, err := Mempool(context.Background(), &fakeNode{})
	require.Error(t, err)
	assert.Empty(t, txs)
}

func TestNetCreditCountsOnlyOurAddresses(t *testing.T) {
	txs := []MempoolTx{{Outputs: []MempoolOutput{
		{Address: "mine", ValueSats: 10000},
		{Address: "theirs", ValueSats: 500},
		{Address: "mine", ValueSats: 250},
	}}}
	mine := map[string]bool{"mine": true}

	assert.Equal(t, int64(10250), NetCreditFor(txs, mine, nil))
	assert.Zero(t, NetCreditFor(txs, nil, nil), "a wallet with no address is owed nothing")
}

// A transfer of ours pays change back. Counting the change alone reads the
// spent coin twice, because the node still lists it as confirmed.
func TestNetCreditSubtractsWhatWeSpend(t *testing.T) {
	txs := []MempoolTx{{
		Inputs:  []MempoolInput{{Key: "old:0"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 9000}, {Address: "theirs", ValueSats: 900}},
	}}
	ourCoins := map[string]int64{"old:0": 10000}

	got := NetCreditFor(txs, map[string]bool{"mine": true}, ourCoins)
	assert.Equal(t, int64(-1000), got, "we part with the payment and the fee")
}

// A payment from a stranger spends no coin of ours, so nothing subtracts.
func TestNetCreditIgnoresAStrangersInputs(t *testing.T) {
	txs := []MempoolTx{{
		Inputs:  []MempoolInput{{Key: "theirs:3"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 10000}},
	}}

	got := NetCreditFor(txs, map[string]bool{"mine": true}, map[string]int64{"old:0": 10000})
	assert.Equal(t, int64(10000), got)
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

// A child spends a coin its parent made, and that coin never reached the
// confirmed listing. Without it the child's change counts on top of money the
// wallet never held.
func TestNetCreditFollowsAChainedSpend(t *testing.T) {
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

	got := NetCreditFor(txs, map[string]bool{"mine": true}, nil)
	assert.Equal(t, int64(9000), got, "the parent's coin is spent, so only the child's stands")
}

// A wallet can spend a deposit, and its outpoint is a plain string.
func TestNetCreditSubtractsASpentDeposit(t *testing.T) {
	txs := []MempoolTx{{
		Inputs:  []MempoolInput{{Key: "maintxid:0"}},
		Outputs: []MempoolOutput{{Address: "mine", ValueSats: 400}},
	}}

	got := NetCreditFor(txs, map[string]bool{"mine": true}, map[string]int64{"maintxid:0": 500})
	assert.Equal(t, int64(-100), got)
}

// A coin an unconfirmed transaction spends is no longer spendable. Listing it
// beside the change shows the same money twice.
func TestWithMempoolUTXOsDropsWhatTheMempoolSpends(t *testing.T) {
	node := &fakeNode{
		addresses: `["mine"]`,
		mempool: `[{"txid":"spend","size":100,"tx":{
		    "inputs":[{"Regular":{"txid":"old","vout":0}}],
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
