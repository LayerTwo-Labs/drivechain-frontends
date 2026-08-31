package thunder

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	bip39 "github.com/tyler-smith/go-bip39"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// Light mode runs no thunder node, so nothing may ask one for the wallet
// addresses. The seed names them, and the index answers the history.
func TestLightModeListsHistoryWithNoNode(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon " +
		"abandon abandon abandon abandon abandon about"
	seed := bip39.NewSeed(mnemonic, "")

	ring, err := thunderwallet.DeriveKeyring(seed, 1)
	if err != nil {
		t.Fatalf("derive the keyring: %v", err)
	}
	first := ring.Addresses()[0].String()

	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/address/"+first+"/txs":
			_, _ = w.Write([]byte(`[{"txid":"aa","fee":10,
				"vin":[],"vout":[{"scriptpubkey_address":"` + first + `","value":4200}],
				"status":{"confirmed":true,"block_height":3,"block_time":99}}]`))
		case r.URL.Path == "/blocks/tip/height":
			_, _ = w.Write([]byte(`9`))
		case strings.HasSuffix(r.URL.Path, "/deposits"),
			strings.Contains(r.URL.Path, "/txs/chain/"),
			strings.HasSuffix(r.URL.Path, "/txs"):
			_, _ = w.Write([]byte(`[]`))
		case strings.HasPrefix(r.URL.Path, "/address/"):
			_, _ = w.Write([]byte(addressStats(
				strings.TrimPrefix(r.URL.Path, "/address/"),
				r.URL.Path == "/address/"+first)))
		default:
			http.Error(w, "not found", http.StatusNotFound)
		}
	}))
	defer index.Close()

	// Port 1 accepts nothing, which is what a stopped node looks like.
	deadNode := sidechain.NewJSONRPCProxy("127.0.0.1", 1)
	h := NewHandlerWithSeed(deadNode,
		func() Mode { return Mode{IndexURL: index.URL} },
		func() ([]byte, error) { return seed, nil },
	)

	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list transactions: %v", err)
	}
	if len(resp.Msg.Transactions) != 1 {
		t.Fatalf("got %d transactions, want 1", len(resp.Msg.Transactions))
	}
	if got := resp.Msg.Transactions[0]; got.Txid != "aa" || got.ValueSats != 4200 {
		t.Errorf("transaction = %+v", got)
	}
	if resp.Msg.TipHeight != 9 {
		t.Errorf("tip height = %d, want 9", resp.Msg.TipHeight)
	}
}

// Full mode keeps the addresses on the host, so it asks the node even when a
// seed is available.
func TestFullModeStillAsksTheNode(t *testing.T) {
	proxy := nodeWith(t, map[string]string{
		"get_wallet_addresses": `["alice"]`,
		"get_utxos": `[{"outpoint":{"Regular":{"txid":"aa","vout":0}},
			"output":{"address":"alice","content":{"Value":7000}}}]`,
		"get_stxos": `[]`,
	})

	h := NewHandlerWithSeed(proxy,
		func() Mode { return Mode{LocalNode: true} },
		func() ([]byte, error) { t.Fatal("full mode must not read the seed"); return nil, nil },
	)

	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list transactions: %v", err)
	}
	if len(resp.Msg.Transactions) != 1 {
		t.Fatalf("got %d transactions, want 1", len(resp.Msg.Transactions))
	}
}

// A chain with no blocks answers 404 on the tip. A wallet still reads its own
// history there, and every entry counts zero confirmations.
func TestLightModeReadsAnEmptyIndex(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon " +
		"abandon abandon abandon abandon abandon about"
	seed := bip39.NewSeed(mnemonic, "")

	ring, err := thunderwallet.DeriveKeyring(seed, 1)
	if err != nil {
		t.Fatalf("derive the keyring: %v", err)
	}
	first := ring.Addresses()[0].String()

	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/blocks/tip/height":
			http.Error(w, "the index holds no blocks yet", http.StatusNotFound)
		case r.URL.Path == "/address/"+first+"/txs":
			_, _ = w.Write([]byte(`[{"txid":"bb","fee":0,
				"vin":[],"vout":[{"scriptpubkey_address":"` + first + `","value":100}],
				"status":{"confirmed":false}}]`))
		case strings.HasSuffix(r.URL.Path, "/txs"),
			strings.HasSuffix(r.URL.Path, "/deposits"),
			strings.Contains(r.URL.Path, "/txs/chain/"):
			_, _ = w.Write([]byte(`[]`))
		case strings.HasPrefix(r.URL.Path, "/address/"):
			_, _ = w.Write([]byte(addressStats(
				strings.TrimPrefix(r.URL.Path, "/address/"),
				r.URL.Path == "/address/"+first)))
		default:
			_, _ = w.Write([]byte(`[]`))
		}
	}))
	defer index.Close()

	h := NewHandlerWithSeed(sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() Mode { return Mode{IndexURL: index.URL} },
		func() ([]byte, error) { return seed, nil },
	)

	resp, err := h.ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("list transactions: %v", err)
	}
	if len(resp.Msg.Transactions) != 1 {
		t.Fatalf("got %d transactions, want 1", len(resp.Msg.Transactions))
	}
	if resp.Msg.TipHeight != 0 {
		t.Errorf("tip height = %d, want 0", resp.Msg.TipHeight)
	}
}

// addressStats writes the stats row an index answers with.
func addressStats(address string, funded bool) string {
	count := "0"
	if funded {
		count = "1"
	}
	return `{"address":"` + address + `",
		"chain_stats":{"funded_txo_count":` + count + `,"funded_txo_sum":0,
			"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0},
		"mempool_stats":{"funded_txo_count":0,"funded_txo_sum":0,
			"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0}}`
}
