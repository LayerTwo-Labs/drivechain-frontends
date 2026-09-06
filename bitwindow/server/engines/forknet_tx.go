package engines

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"io"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
)

// Forknet marks a replay-protected transaction with a magic version followed
// by a single extra byte, and hashes that byte along with the rest of the
// transaction. Stock btcd knows about neither.
const (
	txReplayVersion = 12566463 // 0x00bfbfbf
	txReplayMarker  = 0x3f
)

// deserializeBlock decodes a raw block from Core.
func (p *Parser) deserializeBlock(raw []byte) (*wire.MsgBlock, error) {
	if p.conf.BitcoinCoreNetwork == config.NetworkForknet {
		return decodeForknetBlock(raw)
	}

	var block wire.MsgBlock
	if err := block.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, err
	}
	return &block, nil
}

// decodeForknetBlock decodes a raw block the way forknet serializes it: a
// stock header and transaction count, then transactions that may carry the
// replay marker.
func decodeForknetBlock(raw []byte) (*wire.MsgBlock, error) {
	r := bytes.NewReader(raw)

	var block wire.MsgBlock
	if err := block.Header.Deserialize(r); err != nil {
		return nil, fmt.Errorf("header: %w", err)
	}

	count, err := wire.ReadVarInt(r, 0)
	if err != nil {
		return nil, fmt.Errorf("transaction count: %w", err)
	}

	for i := uint64(0); i < count; i++ {
		tx, err := readForknetTx(r)
		if err != nil {
			return nil, fmt.Errorf("transaction %d: %w", i, err)
		}
		block.Transactions = append(block.Transactions, tx)
	}

	return &block, nil
}

// readForknetTx reads one forknet transaction. Non-replay transactions decode
// exactly like stock ones.
func readForknetTx(r io.Reader) (*wire.MsgTx, error) {
	var version [4]byte
	if _, err := io.ReadFull(r, version[:]); err != nil {
		return nil, fmt.Errorf("version: %w", err)
	}

	if binary.LittleEndian.Uint32(version[:]) == txReplayVersion {
		var marker [1]byte
		if _, err := io.ReadFull(r, marker[:]); err != nil {
			return nil, fmt.Errorf("replay marker: %w", err)
		}
		if marker[0] != txReplayMarker {
			return nil, fmt.Errorf("unexpected replay marker %#x", marker[0])
		}
	}

	// btcd has no notion of the marker, so hand it the version followed by the
	// stock transaction body.
	var tx wire.MsgTx
	if err := tx.BtcDecode(io.MultiReader(bytes.NewReader(version[:]), r), 0, wire.WitnessEncoding); err != nil {
		return nil, err
	}
	return &tx, nil
}

// txHash returns the txid Core reports for tx. Forknet hashes the replay
// marker, so btcd's serialization comes up one byte short of what Core hashed.
func (p *Parser) txHash(tx *wire.MsgTx) chainhash.Hash {
	if p.conf.BitcoinCoreNetwork != config.NetworkForknet || tx.Version != txReplayVersion {
		return tx.TxHash()
	}

	var buf bytes.Buffer
	buf.Grow(tx.SerializeSizeStripped() + 1)
	if err := tx.SerializeNoWitness(&buf); err != nil {
		return tx.TxHash()
	}

	stripped := buf.Bytes()
	marked := make([]byte, 0, len(stripped)+1)
	marked = append(marked, stripped[:4]...)
	marked = append(marked, txReplayMarker)
	marked = append(marked, stripped[4:]...)

	return chainhash.DoubleHashH(marked)
}

// txID is txHash in the string form Core's RPCs use.
func (p *Parser) txID(tx *wire.MsgTx) string {
	return p.txHash(tx).String()
}
