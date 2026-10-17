package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	previewCoinCount = 20
	previewCoinSats  = int64(5_000)
)

// twoInputGuessSats is the fee the send page showed before the preview: two
// legacy inputs and two outputs at rate.
func twoInputGuessSats(rate int64) int64 {
	return rate * (10 + 2*148 + 2*34)
}

func fundManyCoins(fake *fakeEsplora, addr string) {
	fake.stats[addr] = EsploraAddressStats{
		Address: addr,
		ChainStats: EsploraTxoStats{
			FundedTxoCount: previewCoinCount, FundedTxoSum: previewCoinCount * previewCoinSats, TxCount: previewCoinCount,
		},
	}
	for i := range previewCoinCount {
		fake.utxos[addr] = append(fake.utxos[addr], EsploraUTXO{
			TxID: strings.Repeat(fmt.Sprintf("%02x", i+1), 32), Vout: 0, Value: previewCoinSats,
			Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
		})
	}
}

func TestElectrumPreviewSendPaysForEveryCoinItPicks(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundManyCoins(fake, addr)
	req := SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 80_000},
		FeeRateSatPerVB:  2,
	}

	preview, err := p.PreviewSend(context.Background(), w.ID, req)
	require.NoError(t, err)
	assert.Empty(t, fake.broadcast, "a preview broadcasts nothing")
	assert.Greater(t, preview.FeeSats, twoInputGuessSats(2))
	assert.Equal(t, 2*preview.VsizeVBytes, preview.FeeSats)

	req.RequiredInputs = preview.Inputs
	_, err = p.Send(context.Background(), w.ID, req)
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)
	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.Len(t, preview.Inputs, len(tx.TxIn))
	paid := int64(len(tx.TxIn)) * previewCoinSats
	for _, out := range tx.TxOut {
		paid -= out.Value
	}
	assert.Equal(t, preview.FeeSats, paid, "the send pays the fee the preview showed")
	signedVsize := int64(math.Ceil(float64(tx.SerializeSizeStripped()*3+tx.SerializeSize()) / 4))
	assert.GreaterOrEqual(t, preview.VsizeVBytes, signedVsize)
	assert.LessOrEqual(t, preview.VsizeVBytes-signedVsize, int64(len(tx.TxIn)))
}

func TestElectrumPreviewSendNeedsARate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundManyCoins(fake, addr)

	_, err := p.PreviewSend(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 80_000},
	})
	require.ErrorContains(t, err, "needs a fee rate")
}

// fundedCoreTx is an unsigned transaction that spends n coins to two P2WPKH
// outputs, as fundrawtransaction returns it.
func fundedCoreTx(t *testing.T, n int, net *chaincfg.Params) (string, []map[string]any) {
	t.Helper()
	tx := wire.NewMsgTx(wire.TxVersion)
	utxos := make([]map[string]any, 0, n)
	for i := range n {
		hash, err := chainhash.NewHashFromStr(strings.Repeat(fmt.Sprintf("%02x", i+1), 32))
		require.NoError(t, err)
		tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(hash, 1), nil, nil))
		utxos = append(utxos, map[string]any{
			"txid": hash.String(), "vout": 1, "amount": 0.00005, "spendable": true,
			"desc": "wpkh([d34db33f/84h/1h/0h/0/0]03a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd)",
		})
	}
	for _, b := range []byte{0x88, 0x99} {
		addr, err := btcutil.DecodeAddress(p2wpkhAddr(t, fixedKey(b), net), net)
		require.NoError(t, err)
		script, err := txscript.PayToAddrScript(addr)
		require.NoError(t, err)
		tx.AddTxOut(wire.NewTxOut(10_000, script))
	}
	var buf bytes.Buffer
	require.NoError(t, tx.SerializeNoWitness(&buf))
	return hex.EncodeToString(buf.Bytes()), utxos
}

func TestCoreBackendPreviewSendSizesEveryFundedInput(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	fundedHex, utxos := fundedCoreTx(t, 10, net)
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "deadbeef", "" })
	fake.handle("fundrawtransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"hex": fundedHex, "fee": 0.00001506, "changepos": 1}, ""
	})
	fake.handle("listunspent", func(bitcoindCall) (any, string) { return utxos, "" })

	preview, err := backend.PreviewSend(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{p2wpkhAddr(t, fixedKey(0x88), net): 10_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)
	assert.Equal(t, int64(1_506), preview.FeeSats)
	// 10 P2WPKH inputs of 272 WU, two P2WPKH outputs, and the 10.5 vB frame.
	assert.Equal(t, int64(753), preview.VsizeVBytes)
	require.Len(t, preview.Inputs, 10)
	assert.Equal(t, RequiredInput{TxID: strings.Repeat("01", 32), Vout: 1, AmountSats: 5_000}, preview.Inputs[0])
	assert.Greater(t, preview.FeeSats, twoInputGuessSats(2))

	funds := fake.callsFor("fundrawtransaction")
	require.Len(t, funds, 1)
	var opts map[string]any
	require.NoError(t, json.Unmarshal(funds[0].Params[1], &opts))
	assert.Equal(t, float64(2), opts["fee_rate"])
	assert.Empty(t, fake.callsFor("signrawtransactionwithwallet"))
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}

func TestCoreBackendPreviewSendRefusesAnUnknownInput(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	fundedHex, _ := fundedCoreTx(t, 1, net)
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "deadbeef", "" })
	fake.handle("fundrawtransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"hex": fundedHex, "fee": 0.00000300, "changepos": 1}, ""
	})
	fake.handle("listunspent", func(bitcoindCall) (any, string) { return []map[string]any{}, "" })

	_, err := backend.PreviewSend(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{p2wpkhAddr(t, fixedKey(0x88), net): 10_000},
		FeeRateSatPerVB:  2,
	})
	require.ErrorContains(t, err, "is not a wallet UTXO")
}

// Core keeps the change key of every funding, so a preview that let Core pick
// the change each time would leave a gap of unused change addresses.
func TestCoreBackendPreviewSendReusesOneChangeAddress(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	fundedHex, utxos := fundedCoreTx(t, 3, net)
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "deadbeef", "" })
	fake.handle("fundrawtransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"hex": fundedHex, "fee": 0.00000500, "changepos": 1}, ""
	})
	fake.handle("listunspent", func(bitcoindCall) (any, string) { return utxos, "" })

	req := SendRequest{
		DestinationsSats: map[string]int64{p2wpkhAddr(t, fixedKey(0x88), net): 10_000},
		FeeRateSatPerVB:  2,
	}
	for range 3 {
		_, err := backend.PreviewSend(context.Background(), coreID, req)
		require.NoError(t, err)
	}

	funds := fake.callsFor("fundrawtransaction")
	require.Len(t, funds, 3)
	changeAddress := func(i int) any {
		var opts map[string]any
		require.NoError(t, json.Unmarshal(funds[i].Params[1], &opts))
		return opts["changeAddress"]
	}
	assert.Nil(t, changeAddress(0), "the first preview lets Core pick the change")
	assert.Equal(t, p2wpkhAddr(t, fixedKey(0x99), net), changeAddress(1))
	assert.Equal(t, p2wpkhAddr(t, fixedKey(0x99), net), changeAddress(2))
}
