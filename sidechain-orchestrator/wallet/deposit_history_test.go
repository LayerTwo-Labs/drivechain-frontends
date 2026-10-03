package wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	testTreasuryHex   = "b7010951"
	testOldCtipSats   = 500_00000000
	testDepositSats   = 1_00000000
	testDepositFee    = 1_000
	testOwnInputSats  = 2_00000000
	testOwnChangeSats = testOwnInputSats - testDepositSats - testDepositFee
)

func depositTestScan(t *testing.T) (*electrumScan, scannedAddr) {
	t.Helper()
	addr, err := btcutil.NewAddressWitnessPubKeyHash(make([]byte, 20), &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	own := scannedAddr{address: addr.EncodeAddress()}
	scan := &electrumScan{addrs: []scannedAddr{own}, byAddr: map[string]scannedAddr{own.address: own}}
	return scan, own
}

func depositTestPacket(t *testing.T, own scannedAddr) *psbt.Packet {
	t.Helper()
	treasury, err := hex.DecodeString(testTreasuryHex)
	require.NoError(t, err)
	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: chainhash.Hash{1}}, nil, nil))
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: chainhash.Hash{2}}, nil, nil))
	tx.AddTxOut(wire.NewTxOut(testOldCtipSats+testDepositSats, treasury))
	tx.AddTxOut(wire.NewTxOut(0, []byte{0x6a, 0x01, 0x61}))
	tx.AddTxOut(wire.NewTxOut(testOwnChangeSats, mustAddrScript(t, own.address)))
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	return packet
}

func mustAddrScript(t *testing.T, address string) []byte {
	t.Helper()
	addr, err := btcutil.DecodeAddress(address, &chaincfg.RegressionNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(addr)
	require.NoError(t, err)
	return script
}

func TestDepositHistoryShowsTheDepositOnly(t *testing.T) {
	t.Run("a sent deposit shows the real fee before it confirms", func(t *testing.T) {
		scan, own := depositTestScan(t)
		effect := &spendEffect{
			spent: []electrumUTXO{{txid: chainhash.Hash{2}.String(), address: own.address, amountSats: testOwnInputSats}},
			external: []ExternalInput{{
				TxID: chainhash.Hash{1}.String(), AmountSats: testOldCtipSats, ScriptPubKeyHex: testTreasuryHex,
			}},
		}

		sent := buildSentTx("dep", effect, depositTestPacket(t, own), &chaincfg.RegressionNetParams, 1)
		assert.Equal(t, int64(testDepositFee), sent.Fee)

		rows := walletRowsForTx(sent, scan, 100, 1)
		require.NotEmpty(t, rows)
		assert.InDelta(t, -float64(testDepositSats)/1e8, rows[0].Amount, 1e-9)
		assert.InDelta(t, -float64(testDepositFee)/1e8, rows[0].Fee, 1e-9)
	})

	t.Run("a confirmed deposit lists the deposit, not the treasury", func(t *testing.T) {
		scan, own := depositTestScan(t)
		confirmed := EsploraTx{
			TxID: "dep",
			Vin: []EsploraVin{
				{Prevout: &EsploraVout{ScriptPubKey: testTreasuryHex, Value: testOldCtipSats}},
				{Prevout: &EsploraVout{ScriptPubKeyAddress: own.address, Value: testOwnInputSats}},
			},
			Vout: []EsploraVout{
				{ScriptPubKey: testTreasuryHex, Value: testOldCtipSats + testDepositSats},
				{ScriptPubKey: "6a0161"},
				{ScriptPubKeyAddress: own.address, Value: testOwnChangeSats},
			},
			Fee:    testDepositFee,
			Status: EsploraStatus{Confirmed: true, BlockHeight: 90},
		}

		rows := walletRowsForTx(confirmed, scan, 100, 1)
		require.Len(t, rows, 2)
		assert.InDelta(t, -float64(testDepositSats)/1e8, rows[0].Amount, 1e-9)
		assert.Zero(t, rows[1].Amount)
	})

	t.Run("a plain send lists the whole output", func(t *testing.T) {
		scan, own := depositTestScan(t)
		send := EsploraTx{
			TxID: "send",
			Vin:  []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: own.address, Value: testOwnInputSats}}},
			Vout: []EsploraVout{{ScriptPubKey: "0014aa", ScriptPubKeyAddress: "elsewhere", Value: testDepositSats}},
		}

		rows := walletRowsForTx(send, scan, 100, 1)
		require.Len(t, rows, 1)
		assert.InDelta(t, -float64(testDepositSats)/1e8, rows[0].Amount, 1e-9)
	})
}
