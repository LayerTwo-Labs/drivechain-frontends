package thunderwallet

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

const testTxid = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"

// mined marks a coin the chain accepted. The wallet spends no other kind.
var mined = sidechainesplora.Status{Confirmed: true, BlockHeight: 1}

// Both modes answer the same Coin shape, so everything above this seam runs
// one code path.
func TestIndexCoinsReadsEveryKind(t *testing.T) {
	var address Address
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewEncoder(w).Encode([]sidechainesplora.UTXO{
			{Txid: testTxid, Vout: 1, Value: 7000, OutpointKind: "regular", Status: mined},
			{Txid: testTxid, Vout: 0, Value: 5000, OutpointKind: "deposit", Status: mined},
		})
	}))
	defer server.Close()

	coins, err := NewIndexCoins(sidechainesplora.New(server.URL)).
		Coins(context.Background(), []Address{address})
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(coins) != 2 {
		t.Fatalf("got %d coins, want 2", len(coins))
	}
	if coins[0].OutPoint.Kind != KindRegular || coins[0].ValueSats != 7000 {
		t.Errorf("first coin = %+v", coins[0])
	}
	if coins[1].OutPoint.Kind != KindDeposit {
		t.Errorf("second coin kind = %s, want deposit", coins[1].OutPoint.Kind)
	}
	// A deposit txid is a mainchain txid, so it reads reversed.
	if coins[1].OutPoint.Source == coins[0].OutPoint.Source {
		t.Error("the deposit txid did not reverse")
	}
}

func TestIndexCoinsRejectsAnUnknownKind(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewEncoder(w).Encode([]sidechainesplora.UTXO{
			{Txid: testTxid, OutpointKind: "sideways", Status: mined},
		})
	}))
	defer server.Close()

	var address Address
	if _, err := NewIndexCoins(sidechainesplora.New(server.URL)).
		Coins(context.Background(), []Address{address}); err == nil {
		t.Fatal("want an error for an unknown outpoint kind, got none")
	}
}
