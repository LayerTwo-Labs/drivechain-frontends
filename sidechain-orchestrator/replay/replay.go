// Package replay applies replay protection via a magic nLockTime. A transaction
// stamped with nLockTime == ReplayLockTime (LOCKTIME_THRESHOLD - 1) is treated
// as final only by a patched bitcoind; stock Bitcoin Core reads it as a block
// height ~500 million blocks in the future and rejects it as non-final, so the
// transaction can never replay onto Bitcoin.
//
// The locktime is only enforced if at least one input is non-final, so every
// input's sequence is lowered below SEQUENCE_FINAL. Apply this BEFORE signing —
// both the locktime and the sequences are covered by the signature.
package replay

import "github.com/btcsuite/btcd/wire"

// ReplayLockTime is LOCKTIME_THRESHOLD - 1 (500000000 - 1).
const ReplayLockTime uint32 = 499999999

// nonFinalSequence is SEQUENCE_FINAL - 1: the largest sequence that still lets
// nLockTime take effect.
const nonFinalSequence uint32 = wire.MaxTxInSequenceNum - 1

// ApplyLockTime stamps the replay locktime and makes every final input
// non-final so the locktime is actually enforced. Call it before signing.
func ApplyLockTime(tx *wire.MsgTx) {
	tx.LockTime = ReplayLockTime
	for _, in := range tx.TxIn {
		if in.Sequence == wire.MaxTxInSequenceNum {
			in.Sequence = nonFinalSequence
		}
	}
}
