package wallet

import (
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

func mustScript(t *testing.T, addr string, net *chaincfg.Params) []byte {
	t.Helper()
	a, err := btcutil.DecodeAddress(addr, net)
	if err != nil {
		t.Fatalf("decode address %q: %v", addr, err)
	}
	s, err := txscript.PayToAddrScript(a)
	if err != nil {
		t.Fatalf("script for %q: %v", addr, err)
	}
	return s
}

func TestDecodeTransactionRawTx(t *testing.T) {
	net := &chaincfg.MainNetParams
	const wpkh = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"
	const p2pkh = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

	tx := wire.NewMsgTx(2)
	prev, _ := chainhash.NewHashFromStr("aa00000000000000000000000000000000000000000000000000000000000001")
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(prev, 1), nil, nil))
	tx.AddTxOut(wire.NewTxOut(50_000_000, mustScript(t, wpkh, net)))
	tx.AddTxOut(wire.NewTxOut(546, mustScript(t, p2pkh, net)))

	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		t.Fatalf("serialize: %v", err)
	}
	rawHex := hex.EncodeToString(buf.Bytes())

	got, err := DecodeTransaction(rawHex, net)
	if err != nil {
		t.Fatalf("DecodeTransaction: %v", err)
	}
	if got.Form != DecodedFormRawTx {
		t.Fatalf("form = %v, want RawTx", got.Form)
	}
	if got.TxID != tx.TxHash().String() {
		t.Errorf("txid = %s, want %s", got.TxID, tx.TxHash().String())
	}
	if len(got.Outputs) != 2 {
		t.Fatalf("outputs = %d, want 2", len(got.Outputs))
	}
	if got.Outputs[0].Address != wpkh {
		t.Errorf("output 0 address = %q, want %q", got.Outputs[0].Address, wpkh)
	}
	if got.Outputs[1].Address != p2pkh {
		t.Errorf("output 1 address = %q, want %q", got.Outputs[1].Address, p2pkh)
	}
	if got.Outputs[0].ValueSats != 50_000_000 || got.Outputs[1].ValueSats != 546 {
		t.Errorf("output values = %d,%d", got.Outputs[0].ValueSats, got.Outputs[1].ValueSats)
	}
	if got.VsizeVBytes != int32(msgTxVsize(tx)) || got.VsizeVBytes <= 0 {
		t.Errorf("vsize = %d, want %d", got.VsizeVBytes, msgTxVsize(tx))
	}
	if got.TotalOutput != 50_000_546 {
		t.Errorf("total output = %d", got.TotalOutput)
	}
	if got.HasTotalInput || got.HasFee {
		t.Error("raw tx with unknown input values must not report total input or fee")
	}
}

func TestDecodeTransactionTxid(t *testing.T) {
	txid := "abc0000000000000000000000000000000000000000000000000000000000def"
	got, err := DecodeTransaction("  "+txid+"  ", &chaincfg.MainNetParams)
	if err != nil {
		t.Fatalf("DecodeTransaction: %v", err)
	}
	if got.Form != DecodedFormTxid {
		t.Fatalf("form = %v, want Txid", got.Form)
	}
	if got.TxID != txid {
		t.Errorf("txid = %q, want %q", got.TxID, txid)
	}
}

func TestDecodeTransactionPSBT(t *testing.T) {
	net := &chaincfg.MainNetParams
	const wpkh = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"
	const dest = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

	tx := wire.NewMsgTx(2)
	prev, _ := chainhash.NewHashFromStr("bb00000000000000000000000000000000000000000000000000000000000002")
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(prev, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(90_000, mustScript(t, dest, net)))

	packet, err := psbt.NewFromUnsignedTx(tx)
	if err != nil {
		t.Fatalf("new psbt: %v", err)
	}
	packet.Inputs[0].WitnessUtxo = wire.NewTxOut(100_000, mustScript(t, wpkh, net))

	var buf bytes.Buffer
	if err := packet.Serialize(&buf); err != nil {
		t.Fatalf("serialize psbt: %v", err)
	}
	b64 := base64.StdEncoding.EncodeToString(buf.Bytes())

	got, err := DecodeTransaction(b64, net)
	if err != nil {
		t.Fatalf("DecodeTransaction: %v", err)
	}
	if got.Form != DecodedFormPSBT || !got.IsPSBT {
		t.Fatalf("form = %v isPSBT = %v, want PSBT", got.Form, got.IsPSBT)
	}
	if len(got.Inputs) != 1 || len(got.Outputs) != 1 {
		t.Fatalf("inputs/outputs = %d/%d, want 1/1", len(got.Inputs), len(got.Outputs))
	}
	if !got.Inputs[0].HasValue || got.Inputs[0].ValueSats != 100_000 {
		t.Errorf("input value = %d hasValue=%v, want 100000", got.Inputs[0].ValueSats, got.Inputs[0].HasValue)
	}
	if got.Inputs[0].Address != wpkh {
		t.Errorf("input address = %q, want %q", got.Inputs[0].Address, wpkh)
	}
	if got.Inputs[0].Signed || got.SignedInputs != 0 {
		t.Errorf("unsigned psbt reported signed: input=%v count=%d", got.Inputs[0].Signed, got.SignedInputs)
	}
	if !got.HasTotalInput || got.TotalInputSats != 100_000 {
		t.Errorf("total input = %d hasTotal=%v", got.TotalInputSats, got.HasTotalInput)
	}
	if !got.HasFee || got.FeeSats != 10_000 {
		t.Errorf("fee = %d hasFee=%v, want 10000", got.FeeSats, got.HasFee)
	}
	if got.FeeRateSatVB <= 0 {
		t.Errorf("fee rate = %f, want > 0", got.FeeRateSatVB)
	}
}

func TestDecodeTransactionPSBTSignedFlag(t *testing.T) {
	net := &chaincfg.MainNetParams
	tx := wire.NewMsgTx(2)
	prev, _ := chainhash.NewHashFromStr("cc00000000000000000000000000000000000000000000000000000000000003")
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(prev, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(90_000, mustScript(t, "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", net)))

	packet, err := psbt.NewFromUnsignedTx(tx)
	if err != nil {
		t.Fatalf("new psbt: %v", err)
	}
	packet.Inputs[0].WitnessUtxo = wire.NewTxOut(100_000, mustScript(t, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu", net))
	packet.Inputs[0].FinalScriptWitness = []byte{0x01, 0x00}

	var buf bytes.Buffer
	if err := packet.Serialize(&buf); err != nil {
		t.Fatalf("serialize psbt: %v", err)
	}

	got, err := DecodeTransaction(base64.StdEncoding.EncodeToString(buf.Bytes()), net)
	if err != nil {
		t.Fatalf("DecodeTransaction: %v", err)
	}
	if !got.Inputs[0].Signed || got.SignedInputs != 1 {
		t.Errorf("signed input not detected: input=%v count=%d", got.Inputs[0].Signed, got.SignedInputs)
	}
}

func TestDecodeTransactionGarbage(t *testing.T) {
	for _, in := range []string{"", "  ", "hello world", "zzzz", "1234567890"} {
		if _, err := DecodeTransaction(in, &chaincfg.MainNetParams); err != ErrUnrecognizedTransaction {
			t.Errorf("DecodeTransaction(%q) err = %v, want ErrUnrecognizedTransaction", in, err)
		}
	}
}
