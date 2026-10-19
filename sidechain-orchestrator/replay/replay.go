// Package replay applies replay protection via a magic nLockTime. Each eCash
// network publishes its own magic value just below LOCKTIME_THRESHOLD. A
// transaction stamped with it is treated as final only by that network's
// patched bitcoind; stock Bitcoin Core reads it as a block height ~500 million
// blocks in the future and rejects it as non-final, so the transaction can
// never replay onto Bitcoin or onto an eCash network with another value.
//
// The locktime is only enforced if at least one input is non-final, so every
// input's sequence is lowered below SEQUENCE_FINAL. Apply this BEFORE signing —
// both the locktime and the sequences are covered by the signature.
package replay

import (
	"bytes"
	"encoding/hex"
	"fmt"

	"github.com/btcsuite/btcd/wire"
)

// nonFinalSequence is SEQUENCE_FINAL - 1: the largest sequence that still lets
// nLockTime take effect.
const nonFinalSequence uint32 = wire.MaxTxInSequenceNum - 1

// Protected reports whether the stamp binds: the network's magic lockTime plus
// at least one non-final input. With every input final, Bitcoin ignores nLockTime.
func Protected(lockTime, txLockTime uint32, sequences []uint32) bool {
	if txLockTime != lockTime {
		return false
	}
	for _, s := range sequences {
		if s != wire.MaxTxInSequenceNum {
			return true
		}
	}
	return false
}

// ApplyLockTime stamps lockTime and makes every final input non-final so the
// locktime is actually enforced. Call it before signing.
func ApplyLockTime(tx *wire.MsgTx, lockTime uint32) {
	tx.LockTime = lockTime
	for _, in := range tx.TxIn {
		if in.Sequence == wire.MaxTxInSequenceNum {
			in.Sequence = nonFinalSequence
		}
	}
}

// ApplyLockTimeHex stamps lockTime on an unsigned raw transaction and returns
// the new hex. Call it before signing.
func ApplyLockTimeHex(rawHex string, lockTime uint32) (string, error) {
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		return "", fmt.Errorf("decode raw transaction: %w", err)
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return "", fmt.Errorf("deserialize raw transaction: %w", err)
	}
	ApplyLockTime(&tx, lockTime)
	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		return "", fmt.Errorf("serialize raw transaction: %w", err)
	}
	return hex.EncodeToString(buf.Bytes()), nil
}
