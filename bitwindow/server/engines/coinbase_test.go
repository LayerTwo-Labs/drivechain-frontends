package engines

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func payTo(t *testing.T, address string) []byte {
	t.Helper()
	decoded, err := btcutil.DecodeAddress(address, &chaincfg.MainNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(decoded)
	require.NoError(t, err)
	return script
}

func TestCoinbaseFacts(t *testing.T) {
	t.Parallel()

	const (
		miner = "bc1qljvzxk0tp6qtrunt590z5rtdhs8jhkkn4ny4rm"
		pool  = "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk"
	)
	script := []byte("\x03\x01\x02\x03/powre/")
	coinbase := wire.NewMsgTx(1)
	coinbase.AddTxIn(&wire.TxIn{SignatureScript: script})
	coinbase.AddTxOut(wire.NewTxOut(100, payTo(t, miner)))
	coinbase.AddTxOut(wire.NewTxOut(200, payTo(t, pool)))
	coinbase.AddTxOut(wire.NewTxOut(300, payTo(t, miner)))
	coinbase.AddTxOut(wire.NewTxOut(0, []byte{txscript.OP_RETURN, 0x04, 0xaa, 0xbb, 0xcc, 0xdd}))

	block := wire.NewMsgBlock(&wire.BlockHeader{
		Version:   4,
		Timestamp: time.Unix(1_800_000_000, 0),
		Bits:      0x1d00ffff,
	})
	require.NoError(t, block.AddTransaction(coinbase))
	require.NoError(t, block.AddTransaction(wire.NewMsgTx(2)))

	t.Run("the facts name every paid address once", func(t *testing.T) {
		t.Parallel()
		facts := coinbaseFacts(500, block, &chaincfg.MainNetParams)

		assert.EqualValues(t, 500, facts.Height)
		assert.Equal(t, block.Header.BlockHash().String(), facts.Hash)
		assert.Equal(t, block.Header.Timestamp, facts.BlockTime)
		assert.EqualValues(t, 0x1d00ffff, facts.Bits)
		assert.EqualValues(t, 2, facts.TxCount)
		assert.Equal(t, script, facts.Script)
		assert.Equal(t, []string{miner, pool}, facts.Addresses)
	})

	t.Run("no chain params read no addresses", func(t *testing.T) {
		t.Parallel()
		facts := coinbaseFacts(500, block, nil)

		assert.Equal(t, script, facts.Script)
		assert.Empty(t, facts.Addresses)
	})
}

func TestAForkPurgeForgetsTheCoinbasesAboveTheFork(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)
	at := time.Unix(1_800_000_000, 0)
	require.NoError(t, coinbases.Put(ctx, db, []coinbases.Coinbase{
		{Height: 99, Hash: "h99", BlockTime: at},
		{Height: 100, Hash: "h100", BlockTime: at},
		{Height: 101, Hash: "h101", BlockTime: at},
	}))

	require.NoError(t, ResetChainData(ctx, db, 100))

	rows, err := coinbases.ListRange(ctx, db, 0, 200)
	require.NoError(t, err)
	require.Len(t, rows, 1)
	assert.Equal(t, "h99", rows[0].Hash)
}
