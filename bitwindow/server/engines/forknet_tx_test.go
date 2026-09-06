package engines

import (
	"bytes"
	"testing"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
)

func forknetTestTx(version int32, witness bool) *wire.MsgTx {
	tx := wire.NewMsgTx(version)

	in := wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1, 2, 3}, 0), []byte{txscript.OP_TRUE}, nil)
	if witness {
		in.Witness = wire.TxWitness{{0xaa, 0xbb}}
	}
	tx.AddTxIn(in)
	tx.AddTxOut(wire.NewTxOut(1000, []byte{txscript.OP_RETURN, 0x02, 0xde, 0xad}))

	return tx
}

// forknetBlockBytes serializes a block the way forknet does: replay-versioned
// transactions carry the marker byte right after the version.
func forknetBlockBytes(t *testing.T, txs ...*wire.MsgTx) []byte {
	t.Helper()

	var prefix bytes.Buffer
	header := wire.NewBlockHeader(1, &chainhash.Hash{}, &chainhash.Hash{}, 0x1d00ffff, 42)
	require.NoError(t, header.Serialize(&prefix))
	require.NoError(t, wire.WriteVarInt(&prefix, 0, uint64(len(txs))))

	block := prefix.Bytes()
	for _, tx := range txs {
		var raw bytes.Buffer
		require.NoError(t, tx.Serialize(&raw))

		serialized := raw.Bytes()
		block = append(block, serialized[:4]...)
		if tx.Version == txReplayVersion {
			block = append(block, txReplayMarker)
		}
		block = append(block, serialized[4:]...)
	}

	return block
}

// A replay-versioned transaction stalls the indexer under stock btcd, and
// decodes under the forknet decoder.
func TestForknetBlockWithAReplayTransactionDecodes(t *testing.T) {
	stock := forknetTestTx(2, false)
	replay := forknetTestTx(txReplayVersion, true)
	raw := forknetBlockBytes(t, stock, replay)

	require.Error(t, new(wire.MsgBlock).Deserialize(bytes.NewReader(raw)),
		"stock btcd must choke on the replay marker")

	block, err := parserOn(config.NetworkForknet).deserializeBlock(raw)
	require.NoError(t, err)

	require.Len(t, block.Transactions, 2)
	assert.EqualValues(t, 2, block.Transactions[0].Version)
	assert.EqualValues(t, txReplayVersion, block.Transactions[1].Version)
	assert.Equal(t, replay.TxOut[0].PkScript, block.Transactions[1].TxOut[0].PkScript)
	assert.Equal(t, replay.TxIn[0].Witness, block.Transactions[1].TxIn[0].Witness)
}

// Core hashes the marker, so the txid we store must too.
func TestForknetReplayTxidIncludesTheMarker(t *testing.T) {
	replay := forknetTestTx(txReplayVersion, false)
	raw := forknetBlockBytes(t, replay)

	// No witness, so the bytes forknet wrote into the block are exactly the
	// bytes Core hashes for the txid.
	expected := chainhash.DoubleHashH(raw[81:])

	p := parserOn(config.NetworkForknet)
	block, err := p.deserializeBlock(raw)
	require.NoError(t, err)

	assert.Equal(t, expected, p.txHash(block.Transactions[0]))
	assert.NotEqual(t, replay.TxHash(), p.txHash(block.Transactions[0]))
	assert.Equal(t, expected.String(), p.txID(block.Transactions[0]))

	// A witness doesn't move the txid: it hashes the stripped bytes.
	assert.Equal(t, expected, p.txHash(forknetTestTx(txReplayVersion, true)))
}

// Everything else keeps hashing and decoding exactly as before.
func TestNonForknetDecodingIsUnchanged(t *testing.T) {
	stock := forknetTestTx(2, true)
	raw := forknetBlockBytes(t, stock)

	for _, network := range []config.Network{config.NetworkMainnet, config.NetworkForknet} {
		t.Run(string(network), func(t *testing.T) {
			p := parserOn(network)

			block, err := p.deserializeBlock(raw)
			require.NoError(t, err)
			require.Len(t, block.Transactions, 1)
			assert.Equal(t, stock.TxHash(), p.txHash(block.Transactions[0]))
		})
	}

	// A replay-versioned transaction is only special on forknet.
	replay := forknetTestTx(txReplayVersion, false)
	assert.Equal(t, replay.TxHash(), parserOn(config.NetworkMainnet).txHash(replay))
}

func TestForknetRejectsAnUnknownReplayMarker(t *testing.T) {
	raw := forknetBlockBytes(t, forknetTestTx(txReplayVersion, false))
	raw[80+1+4] = 0x40

	_, err := decodeForknetBlock(raw)
	require.ErrorContains(t, err, "unexpected replay marker")
}
