package thunderwallet

import (
	"encoding/hex"
	"testing"
)

// The signature covers these exact bytes, and the txid hashes them. A change
// here makes every signature this wallet writes invalid, with no other sign.
func TestEncodeTransactionBytes(t *testing.T) {
	var source Hash
	for i := range source {
		source[i] = byte(i + 1)
	}
	var leaf Hash
	for i := range leaf {
		leaf[i] = 0xAA
	}
	var address Address
	for i := range address {
		address[i] = 0x11
	}
	value := uint64(21000)

	tx := Transaction{
		Inputs: []Input{{
			OutPoint: OutPoint{Kind: KindRegular, Source: source, Vout: 1},
			LeafHash: leaf,
		}},
		Outputs: []Output{{Address: address, Content: Content{Value: &value}}},
	}

	got, err := EncodeTransaction(tx)
	if err != nil {
		t.Fatalf("encode: %v", err)
	}

	want := "01000000" + // one input
		"00" + // regular
		"0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20" +
		"01000000" + // vout 1
		"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
		"01000000" + // one output
		"1111111111111111111111111111111111111111" + // address
		"00" + // Value
		"0852000000000000" // 21000 sats, little endian

	if hex.EncodeToString(got) != want {
		t.Errorf("encoding =\n  %s\nwant\n  %s", hex.EncodeToString(got), want)
	}
}

// A withdrawal writes both amounts and the mainchain script, which borsh
// writes as a byte slice with a length.
func TestEncodeWithdrawalBytes(t *testing.T) {
	var address Address
	tx := Transaction{Outputs: []Output{{
		Address: address,
		Content: Content{Withdrawal: &Withdrawal{
			ValueSats:        1000,
			MainFeeSats:      250,
			MainScriptPubKey: []byte{0x00, 0x14, 0xff},
		}},
	}}}

	got, err := EncodeTransaction(tx)
	if err != nil {
		t.Fatalf("encode: %v", err)
	}

	want := "00000000" + // no inputs
		"01000000" + // one output
		"0000000000000000000000000000000000000000" + // the zero address
		"01" + // Withdrawal
		"e803000000000000" + // 1000 sats
		"fa00000000000000" + // 250 sats
		"03000000" + "0014ff" // the script, with its length

	if hex.EncodeToString(got) != want {
		t.Errorf("encoding =\n  %s\nwant\n  %s", hex.EncodeToString(got), want)
	}
}

// An empty transaction still writes both lengths.
func TestEncodeEmptyTransaction(t *testing.T) {
	got, err := EncodeTransaction(Transaction{})
	if err != nil {
		t.Fatalf("encode: %v", err)
	}
	if hex.EncodeToString(got) != "0000000000000000" {
		t.Errorf("encoding = %s, want two zero lengths", hex.EncodeToString(got))
	}
}

func TestEncodeRejectsEmptyContent(t *testing.T) {
	tx := Transaction{Outputs: []Output{{}}}
	if _, err := EncodeTransaction(tx); err == nil {
		t.Fatal("want an error for an output with no content, got none")
	}
}
