package thunderwallet

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A withdrawal output is leaving the chain. Counting it inflates the balance,
// and its leaf hash covers a withdrawal rather than a value, so a transaction
// that spends it is one no node accepts.
func TestIndexCoinsSkipsAWithdrawalOutput(t *testing.T) {
	const address = "3nRfgx4Lbhxas4P2J2CpCQ98Srsr"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/address/"+address+"/utxo" {
			_, _ = w.Write([]byte("[]"))
			return
		}
		_, _ = w.Write([]byte(`[
			{"txid":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","vout":0,"value":5000000,"outpoint_kind":"regular",
			 "content_type":"withdrawal",
			 "status":{"confirmed":true,"block_height":1,"block_time":1}},
			{"txid":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","vout":1,"value":4999000,"outpoint_kind":"regular",
			 "content_type":"value",
			 "status":{"confirmed":true,"block_height":1,"block_time":1}}]`))
	}))
	defer server.Close()

	parsed, err := ParseAddress(address)
	if err != nil {
		t.Fatalf("read the address: %v", err)
	}
	coins, err := NewIndexCoins(sidechainesplora.New(server.URL)).
		Coins(context.Background(), []Address{parsed})
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(coins) != 1 {
		t.Fatalf("the wallet holds %d coins, want 1", len(coins))
	}
	if coins[0].ValueSats != 4999000 {
		t.Errorf("the wallet counts %d sats, want 4999000", coins[0].ValueSats)
	}
}

// An index that sends no content type is older than the field. Every row then
// reads as spendable, which is what every row was before it arrived.
func TestIndexCoinsAcceptsAnOlderIndex(t *testing.T) {
	const address = "3nRfgx4Lbhxas4P2J2CpCQ98Srsr"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/address/"+address+"/utxo" {
			_, _ = w.Write([]byte("[]"))
			return
		}
		_, _ = w.Write([]byte(`[{"txid":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","vout":0,"value":7000,
			"outpoint_kind":"regular",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`))
	}))
	defer server.Close()

	parsed, err := ParseAddress(address)
	if err != nil {
		t.Fatalf("read the address: %v", err)
	}
	coins, err := NewIndexCoins(sidechainesplora.New(server.URL)).
		Coins(context.Background(), []Address{parsed})
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(coins) != 1 {
		t.Fatalf("the wallet holds %d coins, want 1", len(coins))
	}
}
