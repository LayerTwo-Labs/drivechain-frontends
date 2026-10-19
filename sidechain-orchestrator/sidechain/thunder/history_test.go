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
			_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"method not found"}}`))
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

// A current node names a coinbase output by its txid. An older node names the
// block's merkle root.
func TestLocalHistoryNamesACoinbaseOutpoint(t *testing.T) {
	for name, tc := range map[string]struct {
		outpoint string
		want     string
	}{
		"by txid":        {`{"Coinbase":{"txid":"cb","vout":3}}`, "cb"},
		"by merkle root": {`{"Coinbase":{"merkle_root":"mr","vout":3}}`, "mr"},
	} {
		t.Run(name, func(t *testing.T) {
			proxy := nodeWith(t, map[string]string{
				"get_wallet_addresses": `["alice"]`,
				"get_utxos": `[{"outpoint":` + tc.outpoint + `,
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
			if got.Txid != tc.want {
				t.Errorf("txid = %q, want %q", got.Txid, tc.want)
			}
			if got.Vout != 3 {
				t.Errorf("vout = %d, want 3", got.Vout)
			}
		})
	}
}

func historyOf(t *testing.T, results map[string]string) map[string]*pb.SidechainWalletTransaction {
	t.Helper()
	h := NewHandlerWithIndex(nodeWith(t, results), "")
	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list: %v", err)
	}
	got := map[string]*pb.SidechainWalletTransaction{}
	for _, tx := range resp.Msg.Transactions {
		got[tx.Txid] = tx
	}
	return got
}

const (
	fundedCoin = `[{"outpoint":{"Regular":{"txid":"aa","vout":0}},
		"output":{"address":"alice","content":{"Value":10000}}}]`
	paymentToBob = `[{"txid":"pay","size":240,"tx":{
		"inputs":[[{"Regular":{"txid":"aa","vout":0}},"00"]],
		"outputs":[
			{"address":"bob","content":{"Value":3000}},
			{"address":"alice","content":{"Value":6000}}]}}]`
	minedChange = `[{"outpoint":{"Regular":{"txid":"pay","vout":1}},
		"output":{"address":"alice","content":{"Value":6000}}}]`
	minedSpend = `[{"outpoint":{"Regular":{"txid":"aa","vout":0}},
		"output":{"output":{"address":"alice","content":{"Value":10000}},
		          "inpoint":{"Regular":{"txid":"pay","vin":0}}}}]`
)

func TestLocalHistoryShowsAPendingSend(t *testing.T) {
	for name, tc := range map[string]struct {
		utxos, stxos, mempool string
		wantConfirmed         bool
	}{
		"in the mempool":          {fundedCoin, `[]`, paymentToBob, false},
		"mined":                   {minedChange, minedSpend, `[]`, true},
		"mined, still in mempool": {minedChange, minedSpend, paymentToBob, true},
	} {
		t.Run(name, func(t *testing.T) {
			got := historyOf(t, map[string]string{
				"get_wallet_addresses": `["alice"]`,
				"get_utxos":            tc.utxos,
				"get_stxos":            tc.stxos,
				"list_mempool":         tc.mempool,
			})
			if len(got) != 2 {
				t.Fatalf("history = %v, want aa and pay", got)
			}
			if aa := got["aa"]; aa.ValueSats != 10000 || !aa.Confirmed {
				t.Errorf("aa = %d confirmed %v, want 10000 confirmed", aa.ValueSats, aa.Confirmed)
			}
			pay := got["pay"]
			if pay.ValueSats != -4000 {
				t.Errorf("pay = %d, want -4000", pay.ValueSats)
			}
			if pay.Confirmed != tc.wantConfirmed {
				t.Errorf("pay confirmed = %v, want %v", pay.Confirmed, tc.wantConfirmed)
			}
			if pay.Vout != 1 {
				t.Errorf("pay vout = %d, want 1", pay.Vout)
			}
		})
	}
}

func TestLocalHistoryChainsPendingSends(t *testing.T) {
	got := historyOf(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos":            fundedCoin,
		"get_stxos":            `[]`,
		"list_mempool": `[
			{"txid":"self","size":240,"tx":{
				"inputs":[[{"Regular":{"txid":"aa","vout":0}},"00"]],
				"outputs":[
					{"address":"alice","content":{"Value":1000}},
					{"address":"alice","content":{"Value":8900}}]}},
			{"txid":"next","size":240,"tx":{
				"inputs":[[{"Regular":{"txid":"self","vout":1}},"00"]],
				"outputs":[
					{"address":"bob","content":{"Value":5000}},
					{"address":"alice","content":{"Value":3800}}]}}]`,
	})
	if got["self"].ValueSats != -100 || got["self"].Confirmed {
		t.Errorf("self = %d confirmed %v, want -100 pending", got["self"].ValueSats, got["self"].Confirmed)
	}
	if got["next"].ValueSats != -5100 || got["next"].Confirmed {
		t.Errorf("next = %d confirmed %v, want -5100 pending", got["next"].ValueSats, got["next"].Confirmed)
	}
}

func TestLocalHistoryWithoutListMempool(t *testing.T) {
	got := historyOf(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos":            fundedCoin,
		"get_stxos":            `[]`,
	})
	if len(got) != 1 {
		t.Fatalf("history = %v, want aa alone", got)
	}
	if aa := got["aa"]; aa.ValueSats != 10000 || !aa.Confirmed {
		t.Errorf("aa = %d confirmed %v, want 10000 confirmed", aa.ValueSats, aa.Confirmed)
	}
}
