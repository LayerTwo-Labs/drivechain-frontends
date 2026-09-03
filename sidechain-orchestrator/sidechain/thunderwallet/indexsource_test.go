package thunderwallet

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
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

// A coin the chain has not mined yet is not spendable, and the wallet reads it
// through Pending instead.
func TestIndexCoinsSplitsTheUnconfirmedCoins(t *testing.T) {
	const address = "3nRfgx4Lbhxas4P2J2CpCQ98Srsr"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/address/"+address+"/utxo" {
			_, _ = w.Write([]byte("[]"))
			return
		}
		_, _ = w.Write([]byte(`[
			{"txid":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","vout":0,"value":6000,"outpoint_kind":"regular",
			 "content_type":"value",
			 "status":{"confirmed":true,"block_height":1,"block_time":1}},
			{"txid":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","vout":1,"value":1500,"outpoint_kind":"regular",
			 "content_type":"value",
			 "status":{"confirmed":false,"block_height":null,"block_time":null}}]`))
	}))
	defer server.Close()

	parsed, err := ParseAddress(address)
	if err != nil {
		t.Fatalf("read the address: %v", err)
	}
	source := NewIndexCoins(sidechainesplora.New(server.URL))

	confirmed, pending, err := source.Split(context.Background(), []Address{parsed})
	if err != nil {
		t.Fatalf("split: %v", err)
	}
	if len(confirmed) != 1 || confirmed[0].ValueSats != 6000 {
		t.Errorf("spendable coins = %+v, want the mined one alone", confirmed)
	}
	if len(pending) != 1 || pending[0].ValueSats != 1500 {
		t.Errorf("pending coins = %+v, want the unmined one alone", pending)
	}

	coins, err := source.Coins(context.Background(), []Address{parsed})
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(coins) != 1 || coins[0].ValueSats != 6000 {
		t.Errorf("coins = %+v, want the spendable half", coins)
	}
}

// A wallet reads a wide window, so the addresses must not queue behind each
// other. Every answer must still land under its own address.
func TestIndexCoinsReadsEveryAddress(t *testing.T) {
	const count = 20
	ring, err := DeriveKeyring(make([]byte, 64), count)
	if err != nil {
		t.Fatalf("derive the keyring: %v", err)
	}
	addresses := ring.Addresses()

	values := make(map[string]int64, count)
	for i, address := range addresses {
		values[address.String()] = int64(1000 + i)
	}

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		name := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/address/"), "/utxo")
		value, ok := values[name]
		if !ok {
			_, _ = w.Write([]byte("[]"))
			return
		}
		_, _ = fmt.Fprintf(w, `[{"txid":"%s","vout":0,"value":%d,
			"outpoint_kind":"regular","content_type":"value",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`,
			strings.Repeat("aa", 32), value)
	}))
	defer server.Close()

	coins, err := NewIndexCoins(sidechainesplora.New(server.URL)).
		Coins(context.Background(), addresses)
	if err != nil {
		t.Fatalf("coins: %v", err)
	}
	if len(coins) != count {
		t.Fatalf("read %d coins, want %d", len(coins), count)
	}
	for _, coin := range coins {
		if want := values[coin.Address.String()]; int64(coin.ValueSats) != want {
			t.Errorf("%s holds %d sats, want %d", coin.Address, coin.ValueSats, want)
		}
	}
}
