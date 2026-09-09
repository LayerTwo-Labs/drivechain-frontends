package coinshift

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	bip39 "github.com/tyler-smith/go-bip39"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

const testDepositTxid = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

// testIndex serves a deposit of 21000 sats to one address.
func testIndex(t *testing.T, funded string) string {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := strings.TrimPrefix(r.URL.Path, "/address/")
		switch {
		case path == funded+"/utxo":
			_, _ = io.WriteString(w, `[{"txid":"`+testDepositTxid+`","vout":0,
				"value":21000,"outpoint_kind":"deposit","content_type":"value",
				"status":{"confirmed":true,"block_height":1,"block_time":1}}]`)
		case strings.HasSuffix(path, "/utxo"), strings.HasSuffix(path, "/deposits"):
			_, _ = io.WriteString(w, "[]")
		default:
			count := "0"
			if path == funded {
				count = "1"
			}
			_, _ = io.WriteString(w, `{"address":"`+path+`",
				"chain_stats":{"funded_txo_count":`+count+`,"funded_txo_sum":0,
				"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0},
				"mempool_stats":{"funded_txo_count":0,"funded_txo_sum":0,
				"spent_txo_count":0,"spent_txo_sum":0,"tx_count":0}}`)
		}
	}))
	t.Cleanup(server.Close)
	return server.URL
}

// A light install starts no coinshift daemon, so the wallet must answer from
// the index alone. The handler dials a port nothing listens on, and a call
// that reaches for a node fails the test.
func TestLightHandlerReadsTheIndex(t *testing.T) {
	seed := bip39.NewSeed(testMnemonic, "")
	first, err := deriveAddress(seed, 0)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	url := testIndex(t, first.String())

	h := NewLightHandler(
		sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() lightwallet.Mode { return lightwallet.NewMode(true, url) },
		func() ([]byte, error) { return seed, nil },
	)
	if !h.ReadsIndex() {
		t.Fatal("the wallet reads no index in light mode")
	}

	ctx := context.Background()
	balance, err := h.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		t.Fatalf("balance: %v", err)
	}
	if balance.Msg.TotalSats != 21000 || balance.Msg.AvailableSats != 21000 {
		t.Errorf("balance = %d total and %d available, want 21000 of each",
			balance.Msg.TotalSats, balance.Msg.AvailableSats)
	}

	utxos, err := h.GetWalletUtxos(ctx, connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	if !strings.Contains(utxos.Msg.UtxosJson, `"Value":21000`) {
		t.Errorf("utxos = %s, want the deposit under Value", utxos.Msg.UtxosJson)
	}
	if !strings.Contains(utxos.Msg.UtxosJson, `"Deposit":"`+testDepositTxid+`:0"`) {
		t.Errorf("utxos = %s, want the mainchain outpoint", utxos.Msg.UtxosJson)
	}

	// The paid address is used, so a receive page must show the next one.
	second, err := deriveAddress(seed, 1)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	address, err := h.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	if address.Msg.Address != second.String() {
		t.Errorf("address = %s, want %s", address.Msg.Address, second)
	}

	addresses, err := h.GetWalletAddresses(ctx, connect.NewRequest(&pb.GetWalletAddressesRequest{}))
	if err != nil {
		t.Fatalf("wallet addresses: %v", err)
	}
	if len(addresses.Msg.Addresses) == 0 || addresses.Msg.Addresses[0] != first.String() {
		t.Errorf("addresses = %v, want the derived window", addresses.Msg.Addresses)
	}
}

// A full install runs its own node, and the wallet addresses stay on the host.
func TestFullHandlerReadsNoIndex(t *testing.T) {
	h := NewLightHandler(
		sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() lightwallet.Mode { return lightwallet.NewMode(false, "https://index.example") },
		func() ([]byte, error) { return bip39.NewSeed(testMnemonic, ""), nil },
	)
	if h.ReadsIndex() {
		t.Error("a full install reads a remote index")
	}
}

// A network with no hosted index cannot serve a light wallet, so the chain
// runs in full mode there.
func TestLightHandlerRefusesAnUnhostedNetwork(t *testing.T) {
	h := NewLightHandler(
		sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() lightwallet.Mode { return lightwallet.NewMode(true, "") },
		func() ([]byte, error) { return bip39.NewSeed(testMnemonic, ""), nil },
	)
	if h.ReadsIndex() {
		t.Error("a network with no index reads one anyway")
	}
}
