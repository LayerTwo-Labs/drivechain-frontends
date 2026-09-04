package replay

import (
	"bytes"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
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
	tx := txWithSequence(wire.MaxTxInSequenceNum)
	ApplyLockTime(tx)
	if tx.LockTime != ReplayLockTime {
		t.Fatalf("locktime = %d, want %d", tx.LockTime, ReplayLockTime)
	}
}

func TestApplyLockTimeMakesFinalInputNonFinal(t *testing.T) {
	tx := txWithSequence(wire.MaxTxInSequenceNum)
	ApplyLockTime(tx)
	// A final input would make bitcoind ignore the locktime, defeating the
	// protection — it must be lowered below SEQUENCE_FINAL.
	if tx.TxIn[0].Sequence >= wire.MaxTxInSequenceNum {
		t.Fatalf("input still final: sequence = %#x", tx.TxIn[0].Sequence)
	}
}

func TestApplyLockTimeLeavesNonFinalInputAlone(t *testing.T) {
	const rbf = wire.MaxTxInSequenceNum - 2 // an already non-final sequence
	tx := txWithSequence(rbf)
	ApplyLockTime(tx)
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
	in := rawHexOf(t, txWithSequence(wire.MaxTxInSequenceNum))

	out, err := ApplyLockTimeHex(in)
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
	if tx.LockTime != ReplayLockTime {
		t.Fatalf("locktime = %d, want %d", tx.LockTime, ReplayLockTime)
	}
	if tx.TxIn[0].Sequence >= wire.MaxTxInSequenceNum {
		t.Fatal("the input must be non-final, else the locktime does nothing")
	}
}

func TestApplyLockTimeHexKeepsTheOutputs(t *testing.T) {
	src := txWithSequence(wire.MaxTxInSequenceNum)
	out, err := ApplyLockTimeHex(rawHexOf(t, src))
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
		if _, err := ApplyLockTimeHex(in); err == nil {
			t.Fatalf("ApplyLockTimeHex(%q) must return an error", in)
		}
	}
}

func TestProtectedNeedsANonFinalInput(t *testing.T) {
	if Protected(ReplayLockTime, []uint32{wire.MaxTxInSequenceNum}) {
		t.Fatal("a tx with every input final counts as protected")
	}
	if !Protected(ReplayLockTime, []uint32{wire.MaxTxInSequenceNum, nonFinalSequence}) {
		t.Fatal("one non-final input does not count as protected")
	}
}

func TestProtectedNeedsTheMagicLocktime(t *testing.T) {
	if Protected(0, []uint32{nonFinalSequence}) {
		t.Fatal("a plain locktime counts as protected")
	}
	if Protected(ReplayLockTime, nil) {
		t.Fatal("a tx without inputs counts as protected")
	}
}
