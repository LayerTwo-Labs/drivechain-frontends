// Package m1 encodes a BIP300 M1 "Propose New Sidechain" coinbase output.
//
// BIP300 ignores an M1 that is not a coinbase output, so the script this
// package returns is only useful to whoever assembles the block.
package m1

import (
	"crypto/sha256"
	"fmt"

	"github.com/btcsuite/btcd/txscript"
)

// Tag is the four-byte M1 header that follows OP_RETURN.
var Tag = []byte{0xD5, 0xE0, 0xC4, 0xAF}

const (
	declarationVersion = 0
	hashID1Len         = 32
	hashID2Len         = 20
	maxTitleLen        = 255
)

// Declaration is the sidechain description carried by an M1.
type Declaration struct {
	Title       string
	Description string
	HashID1     [hashID1Len]byte
	HashID2     [hashID2Len]byte
}

// Describe serializes the declaration into the description bytes D.
// Layout: version, title length, title, description, hashID1, hashID2.
func (d Declaration) Describe() ([]byte, error) {
	if d.Title == "" {
		return nil, fmt.Errorf("title is empty")
	}
	if len(d.Title) > maxTitleLen {
		return nil, fmt.Errorf("title is %d bytes, and the length field holds %d", len(d.Title), maxTitleLen)
	}

	out := make([]byte, 0, 2+len(d.Title)+len(d.Description)+hashID1Len+hashID2Len)
	out = append(out, declarationVersion)
	out = append(out, byte(len(d.Title)))
	out = append(out, d.Title...)
	out = append(out, d.Description...)
	out = append(out, d.HashID1[:]...)
	out = append(out, d.HashID2[:]...)
	return out, nil
}

// DescriptionHash returns the sha256d of D. A miner puts this hash in the M2
// that ACKs the proposal.
func DescriptionHash(description []byte) [32]byte {
	first := sha256.Sum256(description)
	return sha256.Sum256(first[:])
}

// Script builds the M1 scriptPubKey for a slot and a declaration. It also
// returns D, because the caller hashes D to build the matching M2.
func Script(slot uint8, d Declaration) (script []byte, description []byte, err error) {
	description, err = d.Describe()
	if err != nil {
		return nil, nil, err
	}

	body := make([]byte, 0, len(Tag)+1+len(description))
	body = append(body, Tag...)
	body = append(body, slot)
	body = append(body, description...)

	script, err = txscript.NewScriptBuilder().
		AddOp(txscript.OP_RETURN).
		AddData(body).
		Script()
	if err != nil {
		return nil, nil, fmt.Errorf("build the M1 script: %w", err)
	}
	return script, description, nil
}
