package replay

import (
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
