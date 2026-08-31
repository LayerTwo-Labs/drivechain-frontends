package sidechainesplora_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// fakeIndex serves the routes a light wallet reads.
func fakeIndex(t *testing.T, routes map[string]any) *sidechainesplora.Client {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, ok := routes[r.URL.Path]
		if !ok {
			if strings.Contains(r.URL.Path, "/txs/chain/") ||
				strings.HasSuffix(r.URL.Path, "/deposits") {
				_, _ = w.Write([]byte("[]"))
				return
			}
			http.Error(w, "not found", http.StatusNotFound)
			return
		}
		if text, isText := body.(string); isText {
			w.Header().Set("Content-Type", "text/plain")
			_, _ = w.Write([]byte(text))
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(body)
	}))
	t.Cleanup(server.Close)
	return sidechainesplora.New(server.URL)
}

func TestBalanceSumsEveryAddress(t *testing.T) {
	client := fakeIndex(t, map[string]any{
		"/address/alice": sidechainesplora.AddressStats{
			ChainStats: sidechainesplora.TxoStats{FundedTxoSum: 10000, SpentTxoSum: 2500},
		},
		"/address/bob": sidechainesplora.AddressStats{
			ChainStats: sidechainesplora.TxoStats{FundedTxoSum: 4000},
		},
	})

	got, err := sidechainesplora.NewWallet(client).Balance(
		context.Background(), []string{"alice", "bob"})
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if got != 11500 {
		t.Errorf("balance = %d, want 11500", got)
	}
}

// A transaction that pays and spends for the same wallet counts one time, with
// a net amount. Counting it twice would double a user's history.
func TestHistoryMergesOneTransactionAcrossAddresses(t *testing.T) {
	shared := sidechainesplora.Tx{
		Txid: "aa",
		Fee:  300,
		Vin: []sidechainesplora.Vin{{
			Txid:    "ff",
			Prevout: &sidechainesplora.Vout{ScriptPubKeyAddress: "alice", Value: 10000},
		}},
		Vout: []sidechainesplora.Vout{
			{ScriptPubKeyAddress: "bob", Value: 6000},
			{ScriptPubKeyAddress: "other", Value: 3700},
		},
		Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 7, BlockTime: 1000},
	}

	client := fakeIndex(t, map[string]any{
		"/address/alice/txs": []sidechainesplora.Tx{shared},
		"/address/bob/txs":   []sidechainesplora.Tx{shared},
	})

	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice", "bob"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 1 {
		t.Fatalf("history has %d entries, want 1", len(entries))
	}
	// Alice loses 10000 and bob gains 6000, so the wallet is 4000 down.
	if entries[0].ValueSats != -4000 {
		t.Errorf("net value = %d, want -4000", entries[0].ValueSats)
	}
	if entries[0].FeeSats != 300 || entries[0].BlockHeight != 7 {
		t.Errorf("entry = %+v", entries[0])
	}
}

func TestHistorySortsNewestFirst(t *testing.T) {
	client := fakeIndex(t, map[string]any{
		"/address/alice/txs": []sidechainesplora.Tx{
			{Txid: "old", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 2}},
			{Txid: "new", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 9}},
		},
	})

	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 2 || entries[0].Txid != "new" {
		t.Errorf("history = %+v, want the newest first", entries)
	}
}

// A deposit has no sidechain txid, so its row names the mainchain one. The
// wallet must still show it as an unspent coin.
func TestUTXOsIncludeADeposit(t *testing.T) {
	client := fakeIndex(t, map[string]any{
		"/address/alice/utxo": []sidechainesplora.UTXO{
			{Txid: "side", Value: 1000, OutpointKind: "regular",
				Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 3}},
			{Txid: "main", Value: 500000, OutpointKind: "deposit",
				Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 8}},
		},
	})

	utxos, err := sidechainesplora.NewWallet(client).UTXOs(
		context.Background(), []string{"alice"})
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	if len(utxos) != 2 {
		t.Fatalf("got %d utxos, want 2", len(utxos))
	}
	if utxos[0].OutpointKind != "deposit" {
		t.Errorf("first utxo = %+v, want the newest, which is the deposit", utxos[0])
	}
}

func TestTipHeight(t *testing.T) {
	client := fakeIndex(t, map[string]any{"/blocks/tip/height": "412\n"})
	height, err := client.TipHeight(context.Background())
	if err != nil {
		t.Fatalf("tip height: %v", err)
	}
	if height != 412 {
		t.Errorf("tip height = %d, want 412", height)
	}
}

// A down index must report a plain error, never a wrong balance.
func TestErrorsReachTheCaller(t *testing.T) {
	client := fakeIndex(t, map[string]any{})
	if _, err := client.AddressStats(context.Background(), "alice"); err == nil {
		t.Fatal("want an error from a missing route, got none")
	}
}

// An address history spans pages. Reading only the first page silently drops
// the older transactions.
func TestHistoryFollowsEveryPage(t *testing.T) {
	pages := map[string][]sidechainesplora.Tx{
		"/address/alice/txs": {
			{Txid: "newest", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 9}},
			{Txid: "page1last", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 8}},
		},
		"/address/alice/txs/chain/page1last": {
			{Txid: "older", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 4}},
		},
		"/address/alice/txs/chain/older": {},
	}
	routes := map[string]any{}
	for path, txs := range pages {
		routes[path] = txs
	}
	client := fakeIndex(t, routes)

	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 3 {
		t.Fatalf("history has %d entries, want 3 across the pages", len(entries))
	}
	if entries[0].Txid != "newest" || entries[2].Txid != "older" {
		t.Errorf("history = %+v, want newest first and older last", entries)
	}
}

// A mainchain deposit has no sidechain transaction, so it reaches the history
// only through the deposits route. Without it a deposit that funded the wallet
// never shows.
func TestHistoryIncludesDeposits(t *testing.T) {
	client := fakeIndex(t, map[string]any{
		"/address/alice/txs": []sidechainesplora.Tx{},
		"/address/alice/deposits": []sidechainesplora.UTXO{{
			Txid: "mainchaintx", Value: 500000, OutpointKind: "deposit",
			Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 3},
		}},
	})

	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 1 {
		t.Fatalf("history has %d entries, want the deposit", len(entries))
	}
	if entries[0].ValueSats != 500000 || !entries[0].IsDeposit {
		t.Errorf("entry = %+v, want a deposit worth 500000", entries[0])
	}
}

// The chain route refuses a mempool txid. A page that ends on an unmined
// transaction must page from the oldest mined one, or the whole read fails.
func TestHistoryPagesFromAMinedTransaction(t *testing.T) {
	routes := map[string]any{
		"/address/alice/txs": []sidechainesplora.Tx{
			{Txid: "pending", Status: sidechainesplora.Status{Confirmed: false}},
			{Txid: "mined", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 8}},
			{Txid: "alsopending", Status: sidechainesplora.Status{Confirmed: false}},
		},
		"/address/alice/txs/chain/mined": []sidechainesplora.Tx{
			{Txid: "older", Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 4}},
		},
		"/address/alice/txs/chain/older": []sidechainesplora.Tx{},
	}
	client := fakeIndex(t, routes)

	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 4 {
		t.Fatalf("history has %d entries, want 4", len(entries))
	}
}

// A transaction can reach the wallet through an address it spends from before
// the address it pays. The row must name the output the wallet owns.
func TestHistoryKeepsTheOwnedOutput(t *testing.T) {
	spend := sidechainesplora.Tx{
		Txid:   "aa",
		Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 5},
		Vin: []sidechainesplora.Vin{{
			Prevout: &sidechainesplora.Vout{ScriptPubKeyAddress: "alice", Value: 9000},
		}},
		Vout: []sidechainesplora.Vout{
			{ScriptPubKeyAddress: "carol", Value: 4000},
			{ScriptPubKeyAddress: "bob", Value: 4900},
		},
	}
	routes := map[string]any{
		"/address/alice/txs": []sidechainesplora.Tx{spend},
		"/address/bob/txs":   []sidechainesplora.Tx{spend},
	}
	client := fakeIndex(t, routes)

	// alice comes first, and owns no output of this transaction.
	entries, err := sidechainesplora.NewWallet(client).History(
		context.Background(), []string{"alice", "bob"})
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(entries) != 1 {
		t.Fatalf("history has %d entries, want 1", len(entries))
	}
	if entries[0].Vout != 1 {
		t.Errorf("the row names output %d, want the change at 1", entries[0].Vout)
	}
}
