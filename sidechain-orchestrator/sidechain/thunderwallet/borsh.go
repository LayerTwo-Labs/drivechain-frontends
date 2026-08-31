// Package thunderwallet builds, signs and broadcasts thunder transactions
// without a local node. It mirrors what an Electrum backend does for L1.
package thunderwallet

import (
	"bytes"
	"encoding/binary"
	"fmt"

	"lukechampine.com/blake3"
)

// Borsh is the encoding a thunder txid hashes over, and the bytes an
// authorization signs. Every rule here mirrors the rust types crate, so a
// change on either side breaks a signature.
type borshWriter struct {
	buf bytes.Buffer
}

// writeU32 writes a little-endian u32, which is also how borsh writes a
// sequence length.
func (w *borshWriter) writeU32(v uint32) {
	var b [4]byte
	binary.LittleEndian.PutUint32(b[:], v)
	w.buf.Write(b[:])
}

func (w *borshWriter) writeU64(v uint64) {
	var b [8]byte
	binary.LittleEndian.PutUint64(b[:], v)
	w.buf.Write(b[:])
}

func (w *borshWriter) writeU8(v uint8) { w.buf.WriteByte(v) }

// writeFixed writes an array, which carries no length.
func (w *borshWriter) writeFixed(b []byte) { w.buf.Write(b) }

// writeBytes writes a slice, which carries a u32 length first.
func (w *borshWriter) writeBytes(b []byte) {
	w.writeU32(uint32(len(b)))
	w.buf.Write(b)
}

func (w *borshWriter) bytes() []byte { return w.buf.Bytes() }

// encodeOutPoint writes the discriminant and the variant fields. This is the
// same 37 bytes the node uses as its own database key.
func encodeOutPoint(w *borshWriter, o OutPoint) error {
	switch o.Kind {
	case KindRegular, KindCoinbase, KindDeposit:
		w.writeU8(uint8(o.Kind))
		w.writeFixed(o.Source[:])
		w.writeU32(o.Vout)
		return nil
	default:
		return fmt.Errorf("outpoint kind %d is not known", o.Kind)
	}
}

// encodeContent writes an OutputContent. An amount is a u64 of sats, and a
// mainchain address is its script pubkey, written as a byte slice.
func encodeContent(w *borshWriter, c Content) error {
	switch {
	case c.Withdrawal != nil:
		w.writeU8(1)
		w.writeU64(c.Withdrawal.ValueSats)
		w.writeU64(c.Withdrawal.MainFeeSats)
		w.writeBytes(c.Withdrawal.MainScriptPubKey)
		return nil
	case c.Value != nil:
		w.writeU8(0)
		w.writeU64(*c.Value)
		return nil
	default:
		return fmt.Errorf("output content names no variant")
	}
}

func encodeOutput(w *borshWriter, o Output) error {
	w.writeFixed(o.Address[:])
	return encodeContent(w, o.Content)
}

// EncodeTransaction writes the canonical encoding. The utreexo proof is skipped,
// because the node regenerates it when it accepts the transaction.
func EncodeTransaction(tx Transaction) ([]byte, error) {
	var w borshWriter

	w.writeU32(uint32(len(tx.Inputs)))
	for _, in := range tx.Inputs {
		if err := encodeOutPoint(&w, in.OutPoint); err != nil {
			return nil, err
		}
		w.writeFixed(in.LeafHash[:])
	}

	w.writeU32(uint32(len(tx.Outputs)))
	for i, out := range tx.Outputs {
		if err := encodeOutput(&w, out); err != nil {
			return nil, fmt.Errorf("output %d: %w", i, err)
		}
	}
	return w.bytes(), nil
}

// LeafHash is where a coin sits in the utreexo accumulator: a blake3 digest
// over the borsh encoding of its outpoint and its output together.
//
// The node looks the coin up by this hash when it regenerates a proof, so a
// wrong one reads as "could not find node" rather than as a bad signature.
func LeafHash(outpoint OutPoint, out Output) (Hash, error) {
	var w borshWriter
	if err := encodeOutPoint(&w, outpoint); err != nil {
		return Hash{}, err
	}
	if err := encodeOutput(&w, out); err != nil {
		return Hash{}, err
	}
	return Hash(blake3.Sum256(w.bytes())), nil
}
