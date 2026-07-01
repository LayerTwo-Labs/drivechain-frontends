package wallet

import (
	"bufio"
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"net"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeElectrumHandler returns the result for one JSON-RPC method call.
type fakeElectrumHandler func(method string, params []json.RawMessage) interface{}

// startFakeElectrum runs an in-process newline-JSON-RPC server and returns its
// tcp:// URL. It answers server.version automatically.
func startFakeElectrum(t *testing.T, h fakeElectrumHandler) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	t.Cleanup(func() { _ = ln.Close() })
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close() //nolint:errcheck
				r := bufio.NewReader(c)
				for {
					line, err := r.ReadBytes('\n')
					if err != nil {
						return
					}
					var req struct {
						ID     int               `json:"id"`
						Method string            `json:"method"`
						Params []json.RawMessage `json:"params"`
					}
					if json.Unmarshal(line, &req) != nil {
						continue
					}
					var result interface{}
					if req.Method == "server.version" {
						result = []string{"fake", "1.4"}
					} else {
						result = h(req.Method, req.Params)
					}
					resp, _ := json.Marshal(map[string]interface{}{"id": req.ID, "result": result})
					_, _ = c.Write(append(resp, '\n'))
				}
			}(conn)
		}
	}()
	return "tcp://" + ln.Addr().String()
}

func txToHex(t *testing.T, tx *wire.MsgTx) string {
	t.Helper()
	var buf bytes.Buffer
	require.NoError(t, tx.Serialize(&buf))
	return hex.EncodeToString(buf.Bytes())
}

func signetAddr(t *testing.T) (string, []byte) {
	t.Helper()
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	addrs, err := DeriveBIP84Addresses(seedHex, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	decoded, err := btcutil.DecodeAddress(addrs[0], &chaincfg.SigNetParams)
	require.NoError(t, err)
	pkScript, err := txscript.PayToAddrScript(decoded)
	require.NoError(t, err)
	return addrs[0], pkScript
}

func TestElectrumClientAddressStatsAndUTXOs(t *testing.T) {
	ctx := context.Background()
	addr, _ := signetAddr(t)

	url := startFakeElectrum(t, func(method string, _ []json.RawMessage) interface{} {
		switch method {
		case "blockchain.scripthash.get_balance":
			return map[string]int64{"confirmed": 55000, "unconfirmed": 1500}
		case "blockchain.scripthash.get_history":
			return []map[string]interface{}{
				{"tx_hash": "aa", "height": 800000},
				{"tx_hash": "bb", "height": 0}, // mempool
			}
		case "blockchain.scripthash.listunspent":
			return []map[string]interface{}{
				{"tx_hash": "aa", "tx_pos": 0, "height": 800000, "value": 55000},
			}
		case "blockchain.block.header":
			return "00" // too short to parse a time; blockTime falls back to 0
		}
		return nil
	})
	c := NewElectrumClient(url, zerolog.Nop(), &chaincfg.SigNetParams)

	stats, err := c.AddressStats(ctx, addr)
	require.NoError(t, err)
	assert.Equal(t, int64(55000), stats.ChainStats.FundedTxoSum)
	assert.Equal(t, int64(1500), stats.MempoolStats.FundedTxoSum)
	assert.Equal(t, 1, stats.ChainStats.TxCount)
	assert.Equal(t, 1, stats.MempoolStats.TxCount)
	assert.True(t, stats.Used())
	assert.Greater(t, stats.ChainStats.FundedTxoCount, 0, "confirmed history must mark the address as funded")

	utxos, err := c.AddressUTXOs(ctx, addr)
	require.NoError(t, err)
	require.Len(t, utxos, 1)
	assert.Equal(t, "aa", utxos[0].TxID)
	assert.Equal(t, int64(55000), utxos[0].Value)
	assert.True(t, utxos[0].Status.Confirmed)
}

// TestElectrumClientTxResolvesPrevoutAndFee proves the client decodes a raw tx
// and resolves its input's prevout (Electrum has no verbose tx), so vin.Prevout
// and the fee are populated the way the wallet backend expects.
func TestElectrumClientTxResolvesPrevoutAndFee(t *testing.T) {
	ctx := context.Background()
	_, pkScript := signetAddr(t)

	prev := wire.NewMsgTx(2)
	prev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: chainhash.Hash{0x11}, Index: 0}, nil, nil))
	prev.AddTxOut(wire.NewTxOut(100000, pkScript))
	prevHex := txToHex(t, prev)
	prevID := prev.TxHash().String()

	spend := wire.NewMsgTx(2)
	spend.AddTxIn(wire.NewTxIn(&wire.OutPoint{Hash: prev.TxHash(), Index: 0}, nil, nil))
	spend.AddTxOut(wire.NewTxOut(90000, pkScript))
	spendHex := txToHex(t, spend)
	spendID := spend.TxHash().String()

	url := startFakeElectrum(t, func(method string, params []json.RawMessage) interface{} {
		if method == "blockchain.transaction.get" {
			var txid string
			_ = json.Unmarshal(params[0], &txid)
			switch txid {
			case prevID:
				return prevHex
			case spendID:
				return spendHex
			}
		}
		return nil
	})
	c := NewElectrumClient(url, zerolog.Nop(), &chaincfg.SigNetParams)

	tx, err := c.Tx(ctx, spendID)
	require.NoError(t, err)
	require.Len(t, tx.Vin, 1)
	require.NotNil(t, tx.Vin[0].Prevout, "input prevout must be resolved from the funding tx")
	assert.Equal(t, int64(100000), tx.Vin[0].Prevout.Value)
	require.Len(t, tx.Vout, 1)
	assert.Equal(t, int64(90000), tx.Vout[0].Value)
	assert.Equal(t, int64(10000), tx.Fee, "fee = inputs - outputs")
}

func TestElectrumClientFeeRateConversion(t *testing.T) {
	ctx := context.Background()
	url := startFakeElectrum(t, func(method string, _ []json.RawMessage) interface{} {
		if method == "blockchain.estimatefee" {
			return 0.00002 // BTC/kB -> 2 sat/vB
		}
		return nil
	})
	c := NewElectrumClient(url, zerolog.Nop(), &chaincfg.SigNetParams)
	assert.InDelta(t, 2.0, c.FeeRateForTarget(ctx, 6, 1), 1e-9)

	// A server with no estimate (negative) falls back.
	url2 := startFakeElectrum(t, func(method string, _ []json.RawMessage) interface{} {
		if method == "blockchain.estimatefee" {
			return -1
		}
		return nil
	})
	c2 := NewElectrumClient(url2, zerolog.Nop(), &chaincfg.SigNetParams)
	assert.Equal(t, 5.0, c2.FeeRateForTarget(ctx, 6, 5))
}
