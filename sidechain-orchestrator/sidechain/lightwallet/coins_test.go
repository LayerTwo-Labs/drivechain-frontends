package lightwallet

import (
	"context"
	"strconv"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A withdrawal output is leaving the chain, and the treasury already pays it
// out. Counting it inflates the balance.
func TestIndexCoinsSkipsAWithdrawalOutput(t *testing.T) {
	index := newFakeIndex(t)
	address := testAddress(t, 0)
	index.rows(address.String(), `[
		{"txid":"`+depositTxid+`","vout":0,"value":5000000,"outpoint_kind":"regular",
		 "content_type":"withdrawal",
		 "status":{"confirmed":true,"block_height":1,"block_time":1}},
		{"txid":"`+depositTxid+`","vout":1,"value":4999000,"outpoint_kind":"regular",
		 "content_type":"value",
		 "status":{"confirmed":true,"block_height":1,"block_time":1}}]`)

	confirmed, _, err := NewIndexCoins(sidechainesplora.New(index.server.URL)).
		Split(context.Background(), []Address{address})
	if err != nil {
		t.Fatalf("split: %v", err)
	}
	if len(confirmed) != 1 || confirmed[0].ValueSats != 4999000 {
		t.Errorf("coins = %+v, want the plain one alone", confirmed)
	}
}

// An index that sends no content type is older than the field. Every row then
// reads as spendable, which is what every row was before it arrived.
func TestIndexCoinsAcceptsAnOlderIndex(t *testing.T) {
	index := newFakeIndex(t)
	address := testAddress(t, 0)
	index.rows(address.String(), `[{"txid":"`+depositTxid+`","vout":0,"value":7000,
		"outpoint_kind":"regular",
		"status":{"confirmed":true,"block_height":1,"block_time":1}}]`)

	confirmed, _, err := NewIndexCoins(sidechainesplora.New(index.server.URL)).
		Split(context.Background(), []Address{address})
	if err != nil {
		t.Fatalf("split: %v", err)
	}
	if len(confirmed) != 1 {
		t.Fatalf("the wallet holds %d coins, want 1", len(confirmed))
	}
}

// A row the wallet cannot read names a coin it cannot show. Answering a short
// balance would read as money that left.
func TestIndexCoinsRefusesARowItCannotRead(t *testing.T) {
	for name, listing := range map[string]string{
		"a txid of the wrong width": `[{"txid":"abcd","vout":0,"value":7000,
			"outpoint_kind":"regular","content_type":"value",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`,
		"an outpoint kind nothing names": `[{"txid":"` + depositTxid + `","vout":0,"value":7000,
			"outpoint_kind":"minted","content_type":"value",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`,
		"a value below zero": `[{"txid":"` + depositTxid + `","vout":0,"value":-1,
			"outpoint_kind":"regular","content_type":"value",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`,
	} {
		t.Run(name, func(t *testing.T) {
			index := newFakeIndex(t)
			address := testAddress(t, 0)
			index.rows(address.String(), listing)

			_, _, err := NewIndexCoins(sidechainesplora.New(index.server.URL)).
				Split(context.Background(), []Address{address})
			if err == nil {
				t.Fatal("want an error, got none")
			}
		})
	}
}

// A wallet reads a wide window, so the addresses must not queue behind each
// other. Every answer must still land under its own address.
func TestIndexCoinsReadsEveryAddress(t *testing.T) {
	index := newFakeIndex(t)
	const count = 20
	addresses := make([]Address, 0, count)
	values := map[string]uint64{}
	for i := range uint32(count) {
		address := testAddress(t, i)
		addresses = append(addresses, address)
		values[address.String()] = uint64(1000 + i)
		index.rows(address.String(), `[{"txid":"`+depositTxid+`","vout":0,"value":`+
			strconv.Itoa(1000+int(i))+`,"outpoint_kind":"regular","content_type":"value",
			"status":{"confirmed":true,"block_height":1,"block_time":1}}]`)
	}

	confirmed, _, err := NewIndexCoins(sidechainesplora.New(index.server.URL)).
		Split(context.Background(), addresses)
	if err != nil {
		t.Fatalf("split: %v", err)
	}
	if len(confirmed) != count {
		t.Fatalf("read %d coins, want %d", len(confirmed), count)
	}
	for _, coin := range confirmed {
		if want := values[coin.Address.String()]; coin.ValueSats != want {
			t.Errorf("%s holds %d sats, want %d", coin.Address, coin.ValueSats, want)
		}
	}
}
