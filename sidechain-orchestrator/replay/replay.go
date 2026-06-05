// Package replay encodes eCash replay-protected transactions. A claim tx is made
// un-deserializable by Bitcoin Core (so it can't replay onto Bitcoin) by giving
// it a magic version and writing one extra byte right after the version field —
// CryptAxe's deprecated-mainchain scheme. Bitcoin Core chokes on that byte; the
// eCash fork node knows to read past it.
//
// This package is pure hex surgery on a serialized transaction — no node, no
// keys — so it's trivially testable. The version must be set BEFORE the tx is
// signed (the signature commits to it); the byte is injected AFTER signing.
package replay

import (
	"encoding/hex"
	"fmt"
)

// TxReplayVersion is the magic transaction version that triggers the eCash
// serialization. 12566463 == 0x00BFBFBF; little-endian on the wire it is the 4
// bytes bf bf bf 00.
const TxReplayVersion int32 = 12566463

// versionHexLE is TxReplayVersion as the first 4 little-endian bytes of a tx.
const versionHexLE = "bfbfbf00"

// TxReplayByte is the extra byte written after the version when it equals
// TxReplayVersion. Its value only matters in that it breaks Bitcoin Core's
// deserializer.
const TxReplayByte byte = 0x3f

// SetVersion overwrites the transaction's 4-byte version field with the magic
// replay version, leaving the rest of the serialization untouched. Call this on
// the unsigned tx so the signature commits to the magic version.
func SetVersion(rawHex string) (string, error) {
	if err := validate(rawHex); err != nil {
		return "", err
	}
	return versionHexLE + rawHex[8:], nil
}

// InjectReplayByte inserts TxReplayByte immediately after the 4-byte version
// field, producing the eCash wire format that Bitcoin Core cannot deserialize.
// Call this on the fully signed tx, just before broadcast.
func InjectReplayByte(rawHex string) (string, error) {
	if err := validate(rawHex); err != nil {
		return "", err
	}
	return rawHex[:8] + fmt.Sprintf("%02x", TxReplayByte) + rawHex[8:], nil
}

func validate(rawHex string) error {
	if len(rawHex) < 8 {
		return fmt.Errorf("raw tx hex too short: %d chars", len(rawHex))
	}
	if _, err := hex.DecodeString(rawHex); err != nil {
		return fmt.Errorf("raw tx is not valid hex: %w", err)
	}
	return nil
}
