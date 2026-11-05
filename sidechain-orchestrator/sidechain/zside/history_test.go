package zside

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
)

type walletLists struct {
	utxos, stxos, utxosUnconfirmed, stxosUnconfirmed string
}

func historyFrom(t *testing.T, lists walletLists) []*pb.WalletTransaction {
	t.Helper()
	orEmpty := func(list string) json.RawMessage {
		if list == "" {
			return json.RawMessage(`[]`)
		}
		return json.RawMessage(list)
	}
	node := nodeServer(t, map[string]any{
		"get_wallet_utxos":             orEmpty(lists.utxos),
		"get_wallet_stxos":             orEmpty(lists.stxos),
		"get_wallet_utxos_unconfirmed": orEmpty(lists.utxosUnconfirmed),
		"get_wallet_stxos_unconfirmed": orEmpty(lists.stxosUnconfirmed),
	})
	resp, err := NewHandler(node.JSONRPCProxy).ListWalletTransactions(context.Background(), &pb.ListWalletTransactionsRequest{})
	require.NoError(t, err)
	return resp.Transactions
}

func valuesByTxid(txs []*pb.WalletTransaction) map[string]int64 {
	got := map[string]int64{}
	for _, tx := range txs {
		got[tx.Txid] = tx.ValueSats
	}
	return got
}

func TestHistoryRecordsAReceive(t *testing.T) {
	txs := historyFrom(t, walletLists{utxos: `[{"outpoint":{"Regular":{"txid":"aa","vout":1}},
		"output":{"address":"alice","content":{"Value":7000}}}]`})

	require.Len(t, txs, 1)
	assert.Equal(t, "aa", txs[0].Txid)
	assert.Equal(t, int64(7000), txs[0].ValueSats)
	assert.Equal(t, uint32(1), txs[0].Vout)
	assert.True(t, txs[0].Confirmed)
}

// The send spends 10000 and pays 6000 back as change, so the wallet lost 4000.
func TestHistoryRecordsASendWithChange(t *testing.T) {
	txs := historyFrom(t, walletLists{
		utxos: `[{"outpoint":{"Regular":{"txid":"send","vout":1}},
			"output":{"address":"alice","content":{"Value":6000}}}]`,
		stxos: `[{"output":{"outpoint":{"Regular":{"txid":"fund","vout":0}},
			"output":{"address":"alice","content":{"Value":10000}}},
			"inpoint":{"Regular":{"txid":"send","vin":0}}}]`,
	})

	assert.Equal(t, map[string]int64{"fund": 10000, "send": -4000}, valuesByTxid(txs))
}

func TestHistoryRecordsADeposit(t *testing.T) {
	txs := historyFrom(t, walletLists{utxos: `[{"outpoint":{"Deposit":"dd:2"},
		"output":{"address":"alice","content":{"Value":50000}}}]`})

	require.Len(t, txs, 1)
	assert.Equal(t, "dd", txs[0].Txid)
	assert.Equal(t, int64(50000), txs[0].ValueSats)
	assert.Equal(t, uint32(2), txs[0].Vout)
}

// The wallet lost the funding less the change. The withdrawal output and its
// bundle spend count no second time.
func TestHistoryRecordsAWithdrawal(t *testing.T) {
	txs := historyFrom(t, walletLists{
		utxos: `[{"outpoint":{"Regular":{"txid":"wd","vout":1}},
			"output":{"address":"alice","content":{"Value":4900}}}]`,
		stxos: `[{"output":{"outpoint":{"Regular":{"txid":"fund","vout":0}},
			"output":{"address":"alice","content":{"Value":10000}}},
			"inpoint":{"Regular":{"txid":"wd","vin":0}}},
		  {"output":{"outpoint":{"Regular":{"txid":"wd","vout":0}},
			"output":{"address":"alice",
			"content":{"Withdrawal":{"value_sats":4000,"main_fee_sats":1000,"main_address":"tb1q"}}}},
			"inpoint":{"Withdrawal":{"m6id":"m6"}}}]`,
	})

	assert.Equal(t, map[string]int64{"fund": 10000, "wd": -5100}, valuesByTxid(txs))
}

// A failed bundle gives the coin back at an outpoint that names the bundle.
func TestHistoryRecordsAnUnsuccessfulWithdrawal(t *testing.T) {
	txs := historyFrom(t, walletLists{utxos: `[{"outpoint":{"UnsuccessfulWithdrawal":{"m6id":"m6","height":40,"vout":0}},
		"output":{"address":"alice","content":{"Value":5000}}}]`})

	assert.Equal(t, map[string]int64{"m6": 5000}, valuesByTxid(txs))
}

// get_wallet_utxos still lists a coin a mempool transaction spends, so the
// coin credits its maker one time only.
func TestHistoryRecordsAMempoolSend(t *testing.T) {
	coin := `{"outpoint":{"Regular":{"txid":"fund","vout":0}},
		"output":{"address":"alice","content":{"Value":10000}}}`
	txs := historyFrom(t, walletLists{
		utxos: `[` + coin + `]`,
		utxosUnconfirmed: `[{"outpoint":{"Regular":{"txid":"send","vout":1}},
			"output":{"address":"alice","content":{"Value":6000}}}]`,
		stxosUnconfirmed: `[{"output":` + coin + `,"inpoint":{"Regular":{"txid":"send","vin":0}}}]`,
	})

	require.Len(t, txs, 2)
	assert.Equal(t, "fund", txs[0].Txid)
	assert.Equal(t, int64(10000), txs[0].ValueSats)
	assert.True(t, txs[0].Confirmed)
	assert.Equal(t, "send", txs[1].Txid)
	assert.Equal(t, int64(-4000), txs[1].ValueSats)
	assert.False(t, txs[1].Confirmed, "the mempool holds the send")
}

func TestHistoryReportsAnUnknownOutpoint(t *testing.T) {
	node := nodeServer(t, map[string]any{
		"get_wallet_utxos": json.RawMessage(`[{"outpoint":{"Other":{}},
			"output":{"address":"alice","content":{"Value":1}}}]`),
		"get_wallet_stxos":             []any{},
		"get_wallet_utxos_unconfirmed": []any{},
		"get_wallet_stxos_unconfirmed": []any{},
	})

	_, err := NewHandler(node.JSONRPCProxy).ListWalletTransactions(context.Background(), &pb.ListWalletTransactionsRequest{})
	require.ErrorContains(t, err, "unknown kind")
}

func TestHistoryReportsANodeFault(t *testing.T) {
	node := nodeServer(t, map[string]any{"get_wallet_utxos": []any{}})

	_, err := NewHandler(node.JSONRPCProxy).ListWalletTransactions(context.Background(), &pb.ListWalletTransactionsRequest{})
	require.ErrorContains(t, err, "get_wallet_stxos")
}
