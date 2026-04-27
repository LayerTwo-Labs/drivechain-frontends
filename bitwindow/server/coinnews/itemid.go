package coinnews

import (
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"fmt"
)

// ItemID is the 12-byte truncated SHA-256 of a CoinNews Item's outpoint
// (BIP §4). 96 bits of collision space — at any plausible CoinNews
// volume the chance of any collision is < 10⁻¹³.
type ItemID [ItemIDLen]byte

// ComputeItemID hashes (txid_LE ‖ vout_LE) and returns the first 12
// bytes. txid is the natural byte order Bitcoin Core gives us when
// it deserialises a transaction (NOT the display-reversed form most
// block explorers show); callers reading from RPC SHOULD reverse the
// hex string into raw bytes before calling.
func ComputeItemID(txid [32]byte, vout uint32) ItemID {
	var buf [36]byte
	copy(buf[:32], txid[:])
	binary.LittleEndian.PutUint32(buf[32:], vout)
	sum := sha256.Sum256(buf[:])
	var id ItemID
	copy(id[:], sum[:ItemIDLen])
	return id
}

// String returns the hex form of an ItemID — convenient for log lines
// and SQL keys.
func (id ItemID) String() string { return hex.EncodeToString(id[:]) }

// ParseItemID decodes a hex-encoded ItemID. Used by RPC handlers and
// Dart callers that pass IDs as strings.
func ParseItemID(s string) (ItemID, error) {
	b, err := hex.DecodeString(s)
	if err != nil {
		return ItemID{}, fmt.Errorf("coinnews: itemid hex: %w", err)
	}
	if len(b) != ItemIDLen {
		return ItemID{}, fmt.Errorf("coinnews: itemid wrong length: got %d, want %d", len(b), ItemIDLen)
	}
	var id ItemID
	copy(id[:], b)
	return id, nil
}
