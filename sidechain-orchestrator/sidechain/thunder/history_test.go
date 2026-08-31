package thunder

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// nodeWith serves the RPCs the local history reads.
func nodeWith(t *testing.T, results map[string]string) *sidechain.JSONRPCProxy {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			ID     any    `json:"id"`
			Method string `json:"method"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		result, ok := results[req.Method]
		if !ok && req.Method == "getblockcount" {
			// Every history read asks for the tip, and no test here reads it.
			result, ok = "1", true
		}
		if !ok {
			http.Error(w, "unexpected method "+req.Method, http.StatusBadRequest)
			return
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(server.Close)

	host, port := splitHostPort(t, server.URL)
	return sidechain.NewJSONRPCProxy(host, port)
}

// A full node holds every coin, so its own utxos and stxos name the history.
// The addresses never leave the host.
func TestLocalHistoryFromTheNode(t *testing.T) {
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos": `[{"outpoint":{"Regular":{"txid":"aa","vout":0}},
			"output":{"address":"alice","content":{"Value":7000}}}]`,
		"get_stxos": `[{"outpoint":{"Regular":{"txid":"bb","vout":0}},
			"output":{"output":{"address":"alice","content":{"Value":3000}},
			          "inpoint":{"Regular":{"txid":"cc","vin":0}}}}]`,
	})

	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}

	got := map[string]int64{}
	for _, tx := range resp.Msg.Transactions {
		got[tx.Txid] = tx.ValueSats
	}
	// aa funded 7000 and still holds it. bb funded 3000, and cc took it away.
	want := map[string]int64{"aa": 7000, "bb": 3000, "cc": -3000}
	if len(got) != len(want) {
		t.Fatalf("history = %+v, want %+v", got, want)
	}
	for txid, value := range want {
		if got[txid] != value {
			t.Errorf("%s = %d, want %d", txid, got[txid], value)
		}
	}
}

// A withdrawal takes its payout and its mainchain fee off the chain. The
// transaction that made it must record that, rather than read as a gain.
func TestLocalHistoryCountsAWithdrawalAsMoneyLeaving(t *testing.T) {
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos": `[
			{"outpoint":{"Regular":{"txid":"wd","vout":0}},
			 "output":{"address":"alice",
			           "content":{"Withdrawal":{"value_sats":4000,
			                      "main_fee_sats":1000,"main_address":"tb1q"}}}},
			{"outpoint":{"Regular":{"txid":"wd","vout":1}},
			 "output":{"address":"alice","content":{"Value":4900}}}]`,
		"get_stxos": `[{"outpoint":{"Regular":{"txid":"funding","vout":0}},
			"output":{"output":{"address":"alice","content":{"Value":10000}},
			          "inpoint":{"Regular":{"txid":"wd","vin":0}}}}]`,
	})

	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}

	got := map[string]int64{}
	for _, tx := range resp.Msg.Transactions {
		got[tx.Txid] = tx.ValueSats
	}
	// 10000 in, 4900 back as change. The payout, the mainchain fee and the
	// sidechain fee are what left.
	if got["wd"] != -5100 {
		t.Errorf("the withdrawal reads %d, want -5100", got["wd"])
	}
	if got["funding"] != 10000 {
		t.Errorf("the funding reads %d, want 10000", got["funding"])
	}
}

// A bundle spends with no transaction, so the m6id names the entry.
func TestLocalHistoryRecordsABundleSpend(t *testing.T) {
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos":            `[]`,
		"get_stxos": `[{"outpoint":{"Regular":{"txid":"aa","vout":0}},
			"output":{"output":{"address":"alice","content":{"Value":9000}},
			          "inpoint":{"Withdrawal":{"m6id":"m6"}}}}]`,
	})

	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	got := map[string]int64{}
	for _, tx := range resp.Msg.Transactions {
		got[tx.Txid] = tx.ValueSats
	}
	if got["m6"] != -9000 {
		t.Errorf("bundle entry = %d, want -9000", got["m6"])
	}
}

// An empty wallet asks the node nothing more.
func TestLocalHistoryWithNoAddresses(t *testing.T) {
	proxy := nodeWith(t, map[string]string{"get_wallet_addresses": `[]`})
	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	if len(resp.Msg.Transactions) != 0 {
		t.Errorf("got %d transactions, want none", len(resp.Msg.Transactions))
	}
}

// A deposit outpoint arrives as one "txid:vout" string. Carrying it whole
// names a transaction no chain holds, and the table then shows "txid:2:0".
func TestLocalHistorySplitsADepositOutpoint(t *testing.T) {
	const mainTxid = "aabbccddeeff00112233445566778899aabbccddeeff001122334455667788990"
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos": `[{"outpoint":{"Deposit":"` + mainTxid + `:2"},
			"output":{"address":"alice","content":{"Value":5000}}}]`,
		"get_stxos": `[]`,
	})

	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	if len(resp.Msg.Transactions) != 1 {
		t.Fatalf("got %d transactions, want 1", len(resp.Msg.Transactions))
	}
	got := resp.Msg.Transactions[0]
	if got.Txid != mainTxid {
		t.Errorf("txid = %q, want the mainchain txid alone", got.Txid)
	}
	if got.Vout != 2 {
		t.Errorf("vout = %d, want 2", got.Vout)
	}
}

// A coin at output one must not read as output zero.
func TestLocalHistoryKeepsTheOutputIndex(t *testing.T) {
	const txid = "1122334455667788991122334455667788991122334455667788991122334455"
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos": `[{"outpoint":{"Regular":{"txid":"` + txid + `","vout":1}},
			"output":{"address":"alice","content":{"Value":7000}}}]`,
		"get_stxos": `[]`,
	})

	h := NewHandlerWithIndex(proxy, "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	if got := resp.Msg.Transactions[0]; got.Vout != 1 {
		t.Errorf("vout = %d, want 1", got.Vout)
	}
}
