package bitnames

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type fakeNode struct {
	addresses     []string
	mempool       string
	utxos         string
	postage       string
	postageByName map[string]string
	postageErr    error
	err           error
}

func (f fakeNode) Call(_ context.Context, method string, params any, result any) error {
	if f.err != nil {
		return f.err
	}
	switch method {
	case "get_wallet_addresses":
		return json.Unmarshal([]byte(mustJSON(f.addresses)), result)
	case "list_mempool":
		return json.Unmarshal([]byte(f.mempool), result)
	case "bitname_data":
		if f.postageErr != nil {
			return f.postageErr
		}
		if f.postageByName != nil {
			return json.Unmarshal([]byte(f.postageByName[params.([]any)[0].(string)]), result)
		}
		if f.postage == "" {
			return json.Unmarshal([]byte("{}"), result)
		}
		return json.Unmarshal([]byte(f.postage), result)
	case "list_utxos":
		if f.utxos == "" {
			return json.Unmarshal([]byte("[]"), result)
		}
		return json.Unmarshal([]byte(f.utxos), result)
	}
	return nil
}

func mustJSON(v any) string {
	raw, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	return string(raw)
}

// This is the shape the live node returns for list_mempool.
const liveMempool = `[
  {"txid":"f5ebe7044511d94a083fe68bd37b7ac575ba9540871017ea57f3bf41c40e9783","size":37,
   "tx":{"inputs":[{"Regular":{"txid":"e198e2c0","vout":0}}],"outputs":[
     {"address":"3Dsq1WDmpXCLztjqa25gM2ivoV8q","content":{"BitcoinSats":1000},"memo":"7bfbaf4b"},
     {"address":"3Dsq1WDmpXCLztjqa25gM2ivoV8q","content":{"BitcoinSats":998900},"memo":""}
   ],"memo":""}},
  {"txid":"4904e243fa39dda41c4de1bb3d9c9f1e2e3f970e72e391edd38658a32cbe4c05","size":28,
   "tx":{"inputs":[],"outputs":[
     {"address":"8G8dvEzV7oFUNCLbVBXLbW1qQ43","content":{"BitcoinSats":100},"memo":"deadbeef"}
   ],"memo":""}}
]`

const mailUTXOs = `[{"output":{"address":"3Dsq1WDmpXCLztjqa25gM2ivoV8q","content":{"BitName":"d228dfbd"}}}]`

// A message reaches a BitName one block before get_paymail reports it, so the
// mempool is the only place a chat can read it at once.
func TestPendingPaymailReadsTheMempool(t *testing.T) {
	node := fakeNode{
		addresses: []string{"3Dsq1WDmpXCLztjqa25gM2ivoV8q"}, mempool: liveMempool,
		utxos: mailUTXOs, postage: `{"paymail_fee_sats":1000}`,
	}

	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, pending, 1, "only the output with a memo, paid to my address")

	key := `{"Regular":{"txid":"f5ebe7044511d94a083fe68bd37b7ac575ba9540871017ea57f3bf41c40e9783","vout":0}}`
	entry, ok := pending[key]
	require.True(t, ok, "the key must match the outpoint get_paymail uses")
	assert.Equal(t, "3Dsq1WDmpXCLztjqa25gM2ivoV8q", entry.Address)
	assert.Equal(t, memoBytes{0x7b, 0xfb, 0xaf, 0x4b}, entry.Memo)
	assert.JSONEq(t, `{"BitcoinSats":1000}`, string(entry.Content))
}

// The memo carries the message, so an output without one is a payment.
func TestPendingPaymailSkipsAnOutputWithNoMemo(t *testing.T) {
	node := fakeNode{
		addresses: []string{"3Dsq1WDmpXCLztjqa25gM2ivoV8q"}, mempool: liveMempool,
		utxos: mailUTXOs, postage: `{"paymail_fee_sats":1000}`,
	}
	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)
	require.Len(t, pending, 1)
	for key := range pending {
		assert.NotContains(t, key, `"vout":1`)
	}
}

// A message for somebody else must stay out of my inbox.
func TestPendingPaymailSkipsAnotherAddress(t *testing.T) {
	node := fakeNode{addresses: []string{"3yGh6d2CpN4yHjRMsUDLpEN38Uiq"}, mempool: liveMempool}
	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)
	assert.Empty(t, pending)
}

// The memo must decode as hex, because the reader hands bytes to the caller.
func TestPendingPaymailSkipsAMemoThatIsNotHex(t *testing.T) {
	node := fakeNode{
		addresses: []string{"a"},
		mempool:   `[{"txid":"aa","tx":{"outputs":[{"address":"a","content":{"BitcoinSats":1000},"memo":"zz"}]}}]`,
		utxos:     `[{"output":{"address":"a","content":{"BitName":"bb"}}}]`,
		postage:   `{"paymail_fee_sats":1000}`,
	}
	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)
	assert.Empty(t, pending)
}

// The marshalled form must read like get_paymail, so one parser handles both.
func TestPendingPaymailMarshalsMemoAsBytes(t *testing.T) {
	node := fakeNode{
		addresses: []string{"3Dsq1WDmpXCLztjqa25gM2ivoV8q"}, mempool: liveMempool,
		utxos: mailUTXOs, postage: `{"paymail_fee_sats":1000}`,
	}
	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)

	raw, err := json.Marshal(pending)
	require.NoError(t, err)
	assert.Contains(t, string(raw), `"memo":[123,251,175,75]`)
}

// get_paymail hides a message that pays less than the postage, so the pending
// view hides it too. Otherwise a message appears and then vanishes.
func TestPendingPaymailHidesAnUnderpaidMessage(t *testing.T) {
	node := fakeNode{
		addresses: []string{"3Dsq1WDmpXCLztjqa25gM2ivoV8q"},
		mempool:   liveMempool,
		utxos: `[{"outpoint":{"Regular":{"txid":"bb","vout":0}},
		          "output":{"address":"3Dsq1WDmpXCLztjqa25gM2ivoV8q",
		                    "content":{"BitName":"d228dfbd"}}}]`,
		postage: `{"paymail_fee_sats": 5000}`,
	}

	pending, err := pendingPaymail(context.Background(), node)
	require.NoError(t, err)
	assert.Empty(t, pending, "the message pays 1000, and the postage is 5000")
}

func TestPendingPaymailChecksPostage(t *testing.T) {
	for _, test := range []struct {
		name    string
		utxos   string
		postage string
		content string
		count   int
	}{
		{name: "no BitName", utxos: `[]`, postage: `{"paymail_fee_sats":0}`, content: `{"BitcoinSats":1000}`},
		{name: "reservation", utxos: `[{"output":{"address":"a","content":{"BitNameReservation":["bb"]}}}]`, postage: `{"paymail_fee_sats":0}`, content: `{"BitcoinSats":1000}`},
		{name: "another address", utxos: `[{"output":{"address":"b","content":{"BitName":"bb"}}}]`, postage: `{"paymail_fee_sats":0}`, content: `{"BitcoinSats":1000}`},
		{name: "null fee", postage: `{"paymail_fee_sats":null}`, content: `{"BitcoinSats":1000}`},
		{name: "absent fee", postage: `{}`, content: `{"BitcoinSats":1000}`},
		{name: "absent data", postage: `null`, content: `{"BitcoinSats":1000}`},
		{name: "empty content", postage: `{"paymail_fee_sats":0}`, content: `{}`},
		{name: "BitName content", postage: `{"paymail_fee_sats":0}`, content: `{"BitName":"cc"}`},
		{name: "null sats", postage: `{"paymail_fee_sats":0}`, content: `{"BitcoinSats":null}`},
		{name: "zero fee", postage: `{"paymail_fee_sats":0}`, content: `{"BitcoinSats":0}`, count: 1},
		{name: "exact fee", postage: `{"paymail_fee_sats":1000}`, content: `{"BitcoinSats":1000}`, count: 1},
	} {
		t.Run(test.name, func(t *testing.T) {
			utxos := test.utxos
			if utxos == "" {
				utxos = `[{"output":{"address":"a","content":{"BitName":"bb"}}}]`
			}
			node := fakeNode{
				addresses: []string{"a"},
				mempool:   `[{"txid":"aa","tx":{"outputs":[{"address":"a","content":` + test.content + `,"memo":"abcd"}]}}]`,
				utxos:     utxos,
				postage:   test.postage,
			}

			pending, err := pendingPaymail(context.Background(), node)
			require.NoError(t, err)
			assert.Len(t, pending, test.count)
		})
	}
}

func TestPendingPaymailUsesTheMinimumFeeAtAnAddress(t *testing.T) {
	for _, test := range []struct {
		name string
		fees [2]string
	}{
		{name: "low fee first", fees: [2]string{"1000", "5000"}},
		{name: "high fee first", fees: [2]string{"5000", "1000"}},
		{name: "zero fee first", fees: [2]string{"0", "5000"}},
		{name: "null fee first", fees: [2]string{"null", "1000"}},
		{name: "null fee last", fees: [2]string{"1000", "null"}},
	} {
		t.Run(test.name, func(t *testing.T) {
			node := fakeNode{
				addresses: []string{"a"},
				mempool:   `[{"txid":"aa","tx":{"outputs":[{"address":"a","content":{"BitcoinSats":1000},"memo":"abcd"}]}}]`,
				utxos: `[{"output":{"address":"a","content":{"BitName":"bb"}}},
				         {"output":{"address":"a","content":{"BitName":"cc"}}}]`,
				postageByName: map[string]string{
					"bb": `{"paymail_fee_sats":` + test.fees[0] + `}`,
					"cc": `{"paymail_fee_sats":` + test.fees[1] + `}`,
				},
			}

			pending, err := pendingPaymail(context.Background(), node)
			require.NoError(t, err)
			assert.Len(t, pending, 1)
		})
	}
}

func TestPendingPaymailReturnsTheBitNameDataError(t *testing.T) {
	readErr := errors.New("the node is unavailable")
	node := fakeNode{
		addresses:  []string{"3Dsq1WDmpXCLztjqa25gM2ivoV8q"},
		mempool:    liveMempool,
		utxos:      mailUTXOs,
		postageErr: readErr,
	}

	pending, err := pendingPaymail(context.Background(), node)
	require.ErrorIs(t, err, readErr)
	assert.Nil(t, pending)
}

// The utxo set is large, so an idle poll must not read it.
func TestPendingPaymailSkipsTheUTXOScanWhenIdle(t *testing.T) {
	node := readCounter{fakeNode: fakeNode{
		addresses: []string{"nobody"},
		mempool:   liveMempool,
	}}

	pending, err := pendingPaymail(context.Background(), &node)
	require.NoError(t, err)
	assert.Empty(t, pending)
	assert.Zero(t, node.utxoReads, "no message for me, so no reason to read the utxos")
}

// readCounter records how often the caller reads the utxo set.
type readCounter struct {
	fakeNode
	utxoReads int
}

func (r *readCounter) Call(ctx context.Context, method string, params any, result any) error {
	if method == "list_utxos" {
		r.utxoReads++
	}
	return r.fakeNode.Call(ctx, method, params, result)
}

func TestMempoolTxidsNamesEveryTransaction(t *testing.T) {
	txids, err := mempoolTxids(context.Background(), fakeNode{mempool: liveMempool})
	require.NoError(t, err)
	assert.Equal(t, []string{
		"f5ebe7044511d94a083fe68bd37b7ac575ba9540871017ea57f3bf41c40e9783",
		"4904e243fa39dda41c4de1bb3d9c9f1e2e3f970e72e391edd38658a32cbe4c05",
	}, txids)
}
