package wallet

import (
	"bytes"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

func TestBuildUnsignedTransaction(t *testing.T) {
	inputs := []RawInput{
		{TxID: "aa00000000000000000000000000000000000000000000000000000000000001", Vout: 1},
		{TxID: "aa00000000000000000000000000000000000000000000000000000000000002", Vout: 0},
	}
	outputs := []TxOutSpec{
		{Address: "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu", AmountBTC: 0.5},
		{OpReturnHex: "deadbeef"},
		{Address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", AmountBTC: 0.00000546},
	}

	rawHex, err := BuildUnsignedTransaction(inputs, outputs, &chaincfg.MainNetParams)
	if err != nil {
		t.Fatalf("BuildUnsignedTransaction: %v", err)
	}

	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		t.Fatalf("decode hex: %v", err)
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		t.Fatalf("deserialize: %v", err)
	}

	// createrawtransaction defaults: version 2, locktime 0, BIP125 sequence.
	if tx.Version != 2 {
		t.Errorf("version = %d, want 2", tx.Version)
	}
	if tx.LockTime != 0 {
		t.Errorf("locktime = %d, want 0", tx.LockTime)
	}
	if len(tx.TxIn) != 2 {
		t.Fatalf("inputs = %d, want 2", len(tx.TxIn))
	}
	for i, in := range tx.TxIn {
		if in.Sequence != wire.MaxTxInSequenceNum-2 {
			t.Errorf("input %d sequence = %x, want %x", i, in.Sequence, wire.MaxTxInSequenceNum-2)
		}
		if len(in.SignatureScript) != 0 || len(in.Witness) != 0 {
			t.Errorf("input %d not unsigned", i)
		}
	}
	if tx.TxIn[0].PreviousOutPoint.Hash.String() != inputs[0].TxID || tx.TxIn[0].PreviousOutPoint.Index != 1 {
		t.Errorf("input 0 outpoint mismatch: %s:%d", tx.TxIn[0].PreviousOutPoint.Hash, tx.TxIn[0].PreviousOutPoint.Index)
	}

	if len(tx.TxOut) != 3 {
		t.Fatalf("outputs = %d, want 3", len(tx.TxOut))
	}
	if tx.TxOut[0].Value != 50_000_000 {
		t.Errorf("output 0 = %d sats, want 50000000", tx.TxOut[0].Value)
	}
	if c := txscript.GetScriptClass(tx.TxOut[0].PkScript); c != txscript.WitnessV0PubKeyHashTy {
		t.Errorf("output 0 script class = %s, want witness_v0_keyhash", c)
	}
	if tx.TxOut[1].Value != 0 {
		t.Errorf("op_return output value = %d, want 0", tx.TxOut[1].Value)
	}
	wantOpReturn := []byte{txscript.OP_RETURN, 0x04, 0xde, 0xad, 0xbe, 0xef}
	if !bytes.Equal(tx.TxOut[1].PkScript, wantOpReturn) {
		t.Errorf("op_return script = %x, want %x", tx.TxOut[1].PkScript, wantOpReturn)
	}
	if tx.TxOut[2].Value != 546 {
		t.Errorf("output 2 = %d sats, want 546", tx.TxOut[2].Value)
	}
	if c := txscript.GetScriptClass(tx.TxOut[2].PkScript); c != txscript.PubKeyHashTy {
		t.Errorf("output 2 script class = %s, want pubkeyhash", c)
	}
}
