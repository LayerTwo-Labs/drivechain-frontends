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
	mempool  string
	template string
	called   []string
}

func (n *fakeNode) CallRaw(_ context.Context, method string, _ any) (json.RawMessage, error) {
	n.called = append(n.called, method)
	if method == "list_mempool" && n.mempool != "" {
		return json.RawMessage(n.mempool), nil
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

func TestCreditCountsOnlyOurAddresses(t *testing.T) {
	txs := []MempoolTx{{Outputs: []MempoolOutput{
		{Address: "mine", ValueSats: 10000},
		{Address: "theirs", ValueSats: 500},
		{Address: "mine", ValueSats: 250},
	}}}

	assert.Equal(t, int64(10250), CreditFor(txs, map[string]bool{"mine": true}))
	assert.Zero(t, CreditFor(txs, nil), "a wallet with no address is owed nothing")
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
