package lightwallet

import (
	"encoding/json"
	"testing"
)

// The listing must read the way the node writes it, or one parser cannot serve
// both wallet modes.
func TestMarshalUTXOsWritesEveryOutpointKind(t *testing.T) {
	address := testAddress(t, 0)
	raw, err := MarshalUTXOs(ValueKeyValue, []Coin{
		{OutPoint: OutPoint{Kind: KindRegular, Txid: depositTxid, Vout: 1}, Address: address, ValueSats: 10},
		{OutPoint: OutPoint{Kind: KindCoinbase, Txid: depositTxid, Vout: 2}, Address: address, ValueSats: 20},
		{OutPoint: OutPoint{Kind: KindDeposit, Txid: depositTxid, Vout: 3}, Address: address, ValueSats: 30},
	}, nil)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var rows []map[string]json.RawMessage
	if err := json.Unmarshal(raw, &rows); err != nil {
		t.Fatalf("read the listing: %v", err)
	}
	if len(rows) != 3 {
		t.Fatalf("the listing holds %d rows, want 3", len(rows))
	}
	for at, want := range []string{
		`{"Regular":{"txid":"` + depositTxid + `","vout":1}}`,
		`{"Coinbase":{"merkle_root":"` + depositTxid + `","vout":2}}`,
		`{"Deposit":"` + depositTxid + `:3"}`,
	} {
		if got := string(rows[at]["outpoint"]); got != want {
			t.Errorf("row %d outpoint = %s, want %s", at, got, want)
		}
	}
}

// A fork that can hold more than bitcoin in an output names the value under
// another key, and its own client reads that key alone.
func TestMarshalUTXOsNamesTheChainsValueKey(t *testing.T) {
	coin := Coin{
		OutPoint:  OutPoint{Kind: KindRegular, Txid: depositTxid},
		Address:   testAddress(t, 0),
		ValueSats: 7,
	}
	for _, key := range []string{ValueKeyValue, ValueKeyBitcoinSats} {
		raw, err := MarshalUTXOs(key, []Coin{coin}, nil)
		if err != nil {
			t.Fatalf("marshal: %v", err)
		}
		var rows []struct {
			Output struct {
				Content map[string]int64 `json:"content"`
			} `json:"output"`
		}
		if err := json.Unmarshal(raw, &rows); err != nil {
			t.Fatalf("read the listing: %v", err)
		}
		if got, held := rows[0].Output.Content[key]; !held || got != 7 {
			t.Errorf("%s = %d, want 7 under that key alone: %s", key, got, raw)
		}
	}
}

// A coin of a kind the wallet cannot write must fail the whole listing, or the
// view would show a short balance and name no fault.
func TestMarshalUTXOsRefusesAnUnknownKind(t *testing.T) {
	_, err := MarshalUTXOs(ValueKeyValue, []Coin{{
		OutPoint: OutPoint{Kind: OutPointKind("minted"), Txid: depositTxid},
		Address:  testAddress(t, 0),
	}}, nil)
	if err == nil {
		t.Fatal("want an error, got none")
	}
}
