package orchestrator

import (
	"bytes"
	"encoding/hex"
	"fmt"
)

var m8Tag = []byte{0x00, 0xBF, 0x00}

const (
	blockHashLen = 32
	opReturn     = 0x6a
)

// M8BmmRequestScript builds a BIP301 M8 BMM request scriptPubKey:
// OP_RETURN [0x00, 0xBF, 0x00] <slot> <critical hash> <prev mainchain hash>.
func M8BmmRequestScript(slot uint8, criticalHash, prevMainHash string) ([]byte, error) {
	critical, err := decodeBlockHash(criticalHash)
	if err != nil {
		return nil, fmt.Errorf("sidechain block hash: %w", err)
	}
	prevMain, err := decodeBlockHash(prevMainHash)
	if err != nil {
		return nil, fmt.Errorf("mainchain block hash: %w", err)
	}
	// bitcoind prints mainchain block hashes in reverse byte order.
	reverseBytes(prevMain)

	message := make([]byte, 0, len(m8Tag)+1+2*blockHashLen)
	message = append(message, m8Tag...)
	message = append(message, slot)
	message = append(message, critical...)
	message = append(message, prevMain...)

	script := make([]byte, 0, len(message)+2)
	script = append(script, opReturn, byte(len(message)))
	return append(script, message...), nil
}

// BmmRequest is a BIP301 M8 BMM request read back off the wire.
type BmmRequest struct {
	Slot         uint8
	CriticalHash string
	PrevMainHash string
}

// ParseM8BmmRequestScript reads an M8 request from an output's scriptPubKey.
// It returns nil for any other script, so it can be run over a whole mempool.
func ParseM8BmmRequestScript(script []byte) *BmmRequest {
	const messageLen = 3 + 1 + 2*blockHashLen
	if len(script) != messageLen+2 {
		return nil
	}
	if script[0] != opReturn || int(script[1]) != messageLen {
		return nil
	}
	if !bytes.Equal(script[2:5], m8Tag) {
		return nil
	}
	prevMain := make([]byte, blockHashLen)
	copy(prevMain, script[6+blockHashLen:])
	reverseBytes(prevMain)
	return &BmmRequest{
		Slot:         script[5],
		CriticalHash: hex.EncodeToString(script[6 : 6+blockHashLen]),
		PrevMainHash: hex.EncodeToString(prevMain),
	}
}

func decodeBlockHash(s string) ([]byte, error) {
	decoded, err := hex.DecodeString(s)
	if err != nil {
		return nil, err
	}
	if len(decoded) != blockHashLen {
		return nil, fmt.Errorf("want %d bytes, got %d", blockHashLen, len(decoded))
	}
	return decoded, nil
}

func reverseBytes(b []byte) {
	for i, j := 0, len(b)-1; i < j; i, j = i+1, j-1 {
		b[i], b[j] = b[j], b[i]
	}
}
