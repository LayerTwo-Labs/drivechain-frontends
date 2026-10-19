package replay

import (
	"bytes"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
)

const (
	betanetLockTime uint32 = 499999999
	mainnetLockTime uint32 = 499999998
)

// txWithSequence builds a version-2 tx with a single input at the given sequence.
func txWithSequence(seq uint32) *wire.MsgTx {
	tx := wire.NewMsgTx(2)
	var prev chainhash.Hash
	in := wire.NewTxIn(wire.NewOutPoint(&prev, 0), nil, nil)
	in.Sequence = seq
	tx.AddTxIn(in)
	tx.AddTxOut(wire.NewTxOut(1000, []byte{0x51})) // OP_TRUE
	return tx
}

func TestApplyLockTimeSetsMagicLockTime(t *testing.T) {
	for _, lockTime := range []uint32{betanetLockTime, mainnetLockTime} {
		tx := txWithSequence(wire.MaxTxInSequenceNum)
		ApplyLockTime(tx, lockTime)
		if tx.LockTime != lockTime {
			t.Fatalf("locktime = %d, want %d", tx.LockTime, lockTime)
		}
	}
}

func TestApplyLockTimeMakesFinalInputNonFinal(t *testing.T) {
	tx := txWithSequence(wire.MaxTxInSequenceNum)
	ApplyLockTime(tx, betanetLockTime)
	// A final input would make bitcoind ignore the locktime, defeating the
	// protection — it must be lowered below SEQUENCE_FINAL.
	if tx.TxIn[0].Sequence >= wire.MaxTxInSequenceNum {
		t.Fatalf("input still final: sequence = %#x", tx.TxIn[0].Sequence)
	}
}

func TestApplyLockTimeLeavesNonFinalInputAlone(t *testing.T) {
	const rbf = wire.MaxTxInSequenceNum - 2 // an already non-final sequence
	tx := txWithSequence(rbf)
	ApplyLockTime(tx, betanetLockTime)
	if tx.TxIn[0].Sequence != rbf {
		t.Fatalf("non-final sequence changed: got %#x, want %#x", tx.TxIn[0].Sequence, rbf)
	}
}

// rawHexOf serializes a tx to hex the way a builder hands it to a signer.
func rawHexOf(t *testing.T, tx *wire.MsgTx) string {
	t.Helper()
	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		t.Fatalf("serialize: %v", err)
	}
	return hex.EncodeToString(buf.Bytes())
}

func TestApplyLockTimeHexStampsTheRawTransaction(t *testing.T) {
	for _, lockTime := range []uint32{betanetLockTime, mainnetLockTime} {
		in := rawHexOf(t, txWithSequence(wire.MaxTxInSequenceNum))

		out, err := ApplyLockTimeHex(in, lockTime)
		if err != nil {
			t.Fatalf("ApplyLockTimeHex: %v", err)
		}

		raw, err := hex.DecodeString(out)
		if err != nil {
			t.Fatalf("decode: %v", err)
		}
		var tx wire.MsgTx
		if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
			t.Fatalf("deserialize: %v", err)
		}
		if tx.LockTime != lockTime {
			t.Fatalf("locktime = %d, want %d", tx.LockTime, lockTime)
		}
		if tx.TxIn[0].Sequence >= wire.MaxTxInSequenceNum {
			t.Fatal("the input must be non-final, else the locktime does nothing")
		}
	}
}

func TestApplyLockTimeHexKeepsTheOutputs(t *testing.T) {
	src := txWithSequence(wire.MaxTxInSequenceNum)
	out, err := ApplyLockTimeHex(rawHexOf(t, src), betanetLockTime)
	if err != nil {
		t.Fatalf("ApplyLockTimeHex: %v", err)
	}

	raw, _ := hex.DecodeString(out)
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		t.Fatalf("deserialize: %v", err)
	}
	if len(tx.TxOut) != len(src.TxOut) {
		t.Fatalf("outputs = %d, want %d", len(tx.TxOut), len(src.TxOut))
	}
	if tx.TxOut[0].Value != src.TxOut[0].Value {
		t.Fatalf("value = %d, want %d", tx.TxOut[0].Value, src.TxOut[0].Value)
	}
	if tx.TxIn[0].PreviousOutPoint != src.TxIn[0].PreviousOutPoint {
		t.Fatal("the outpoint must not move: the BIP47 payload blinds against it")
	}
}

func TestApplyLockTimeHexRejectsBadInput(t *testing.T) {
	for _, in := range []string{"zz", "00"} {
		if _, err := ApplyLockTimeHex(in, betanetLockTime); err == nil {
			t.Fatalf("ApplyLockTimeHex(%q) must return an error", in)
		}
	}
}

func TestProtectedNeedsANonFinalInput(t *testing.T) {
	if Protected(betanetLockTime, betanetLockTime, []uint32{wire.MaxTxInSequenceNum}) {
		t.Fatal("a tx with every input final counts as protected")
	}
	if !Protected(betanetLockTime, betanetLockTime, []uint32{wire.MaxTxInSequenceNum, nonFinalSequence}) {
		t.Fatal("one non-final input does not count as protected")
	}
}

func TestProtectedNeedsTheMagicLocktime(t *testing.T) {
	if Protected(betanetLockTime, 0, []uint32{nonFinalSequence}) {
		t.Fatal("a plain locktime counts as protected")
	}
	if Protected(betanetLockTime, betanetLockTime, nil) {
		t.Fatal("a tx without inputs counts as protected")
	}
}

func TestProtectedNeedsTheNetworkLockTime(t *testing.T) {
	tests := []struct {
		name    string
		network uint32
		stamped uint32
		want    bool
	}{
		{"betanet stamp on betanet", betanetLockTime, betanetLockTime, true},
		{"mainnet stamp on mainnet", mainnetLockTime, mainnetLockTime, true},
		{"betanet stamp on mainnet", mainnetLockTime, betanetLockTime, false},
		{"mainnet stamp on betanet", betanetLockTime, mainnetLockTime, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tx := txWithSequence(wire.MaxTxInSequenceNum)
			ApplyLockTime(tx, tt.stamped)
			got := Protected(tt.network, tx.LockTime, []uint32{tx.TxIn[0].Sequence})
			if got != tt.want {
				t.Fatalf("Protected = %v, want %v", got, tt.want)
			}
		})
	}
}
