package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const coreCancelForeignFundingTxid = "99999999999999999999999999999999999999999999999999999999999999cc"

// coreCancelFixture turns the bump fee transaction into a deposit-like one: a
// foreign input sits next to the wallet's own, and a child spends it.
func coreCancelFixture(t *testing.T) (*CoreBackend, *fakeBitcoind, string, *string, string) {
	t.Helper()
	backend, fake, coreID, paymentAddr, changeAddr := coreBumpFeeFixture(t)
	foreignAddr := p2wpkhAddr(t, fixedKey(0x77), &chaincfg.RegressionNetParams)
	newChangeAddr := p2wpkhAddr(t, fixedKey(0x66), &chaincfg.RegressionNetParams)

	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return map[string]any{
			"vsize":           150,
			"fees":            map[string]any{"base": float64(150) / 1e8, "descendant": float64(5_150) / 1e8},
			"descendantcount": 2,
		}, ""
	})
	fake.handle("getnetworkinfo", func(bitcoindCall) (any, string) {
		return map[string]any{"incrementalfee": 0.00001}, ""
	})
	fake.handle("getrawtransaction", func(c bitcoindCall) (any, string) {
		switch mustString(t, c.Params[0]) {
		case coreBumpFundingTxid:
			return map[string]any{
				"txid": coreBumpFundingTxid,
				"vout": []map[string]any{
					{"value": 0.002, "n": 0, "scriptPubKey": map[string]any{"address": changeAddr}},
				},
			}, ""
		case coreCancelForeignFundingTxid:
			return map[string]any{
				"txid": coreCancelForeignFundingTxid,
				"vout": []map[string]any{
					{"value": 0.5, "n": 0, "scriptPubKey": map[string]any{"address": foreignAddr}},
				},
			}, ""
		}
		return map[string]any{
			"txid":  coreBumpTxid,
			"vsize": 150,
			"vin": []map[string]any{
				{"txid": coreCancelForeignFundingTxid, "vout": 0, "sequence": 4294967295},
				{"txid": coreBumpFundingTxid, "vout": 0, "sequence": 4294967295},
			},
			"vout": []map[string]any{
				{"value": 0.501, "n": 0, "scriptPubKey": map[string]any{"address": paymentAddr}},
				{"value": 0.0009985, "n": 1, "scriptPubKey": map[string]any{"address": changeAddr}},
			},
		}, ""
	})
	fake.handle("listunspent", func(bitcoindCall) (any, string) { return []map[string]any{}, "" })
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) { return newChangeAddr, "" })
	var signedHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signedHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signedHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "cancel-txid", "" })
	return backend, fake, coreID, &signedHex, changeAddr
}

// The cancel evicts the child too, so it outpays both: 5150 sats of evicted
// fees plus 1 sat/vB on a bound of 150 + 1 input + 31 bytes of change.
const coreCancelFeeSats = 5_150 + 182

func TestCoreBackendCancelReturnsTheOwnInputs(t *testing.T) {
	backend, fake, coreID, signedHex, _ := coreCancelFixture(t)

	preview, err := backend.PreviewCancel(context.Background(), coreID, coreBumpTxid)
	require.NoError(t, err)
	require.NotNil(t, preview.Plan, preview.Reason)
	assert.Equal(t, int64(coreCancelFeeSats), preview.Plan.FeeSats)
	assert.Equal(t, int64(200_000-coreCancelFeeSats), preview.Plan.RecoveredSats)

	result, err := backend.CancelTransaction(context.Background(), coreID, coreBumpTxid, coreCancelFeeSats)
	require.NoError(t, err)
	assert.Equal(t, "cancel-txid", result.NewTxID)
	assert.Equal(t, int64(200_000-coreCancelFeeSats), result.Plan.RecoveredSats)

	raw, err := hex.DecodeString(*signedHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.Len(t, tx.TxIn, 1, "the cancel drops the foreign input")
	assert.Equal(t, coreBumpFundingTxid, tx.TxIn[0].PreviousOutPoint.Hash.String())
	assert.Equal(t, bip125Sequence, tx.TxIn[0].Sequence, "the cancel stays replaceable")
	require.Len(t, tx.TxOut, 1, "everything returns to one new change address")
	assert.Equal(t, int64(200_000-coreCancelFeeSats), tx.TxOut[0].Value)
	assert.Len(t, fake.callsFor("getrawchangeaddress"), 1)
}

func TestCoreBackendCancelRefusesATransactionWithNoOwnInput(t *testing.T) {
	backend, fake, coreID, _, _ := coreCancelFixture(t)
	fake.handle("getaddressinfo", func(c bitcoindCall) (any, string) {
		return map[string]any{"address": mustString(t, c.Params[0]), "ismine": false}, ""
	})

	preview, err := backend.PreviewCancel(context.Background(), coreID, coreBumpTxid)
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.Contains(t, preview.Reason, "signs none of the inputs")

	_, err = backend.CancelTransaction(context.Background(), coreID, coreBumpTxid, coreCancelFeeSats)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}

func TestCoreBackendCancelRefusesAConfirmedTransaction(t *testing.T) {
	backend, fake, coreID, _, _ := coreCancelFixture(t)
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return nil, "Transaction not in mempool"
	})

	_, err := backend.CancelTransaction(context.Background(), coreID, coreBumpTxid, coreCancelFeeSats)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}

func TestCoreBackendCancelRefusesAFeeOverTheConfirmedOne(t *testing.T) {
	backend, fake, coreID, _, _ := coreCancelFixture(t)

	_, err := backend.CancelTransaction(context.Background(), coreID, coreBumpTxid, coreCancelFeeSats-1)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Contains(t, err.Error(), "over the 5331 sats you confirmed")
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}

// A default node keeps no txindex. The parent of a confirmed input then answers
// from the chain view, and the cancel preview still prices the coins.
func TestCoreBackendCancelReadsAConfirmedParentWithoutTxindex(t *testing.T) {
	backend, fake, coreID, _, changeAddr := coreCancelFixture(t)
	child := fake.handlerFor("getrawtransaction")
	fake.handle("getrawtransaction", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) == coreBumpFundingTxid {
			return nil, "No such mempool transaction. Use -txindex to enable blockchain transaction queries."
		}
		return child(c)
	})
	fake.handle("gettxout", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) != coreBumpFundingTxid {
			return nil, ""
		}
		return map[string]any{
			"value":        0.002,
			"scriptPubKey": map[string]any{"address": changeAddr},
		}, ""
	})

	preview, err := backend.PreviewCancel(context.Background(), coreID, coreBumpTxid)
	require.NoError(t, err)
	require.NotNil(t, preview.Plan, preview.Reason)
	assert.Equal(t, int64(200_000-coreCancelFeeSats), preview.Plan.RecoveredSats)

	result, err := backend.CancelTransaction(context.Background(), coreID, coreBumpTxid, coreCancelFeeSats)
	require.NoError(t, err)
	assert.Equal(t, "cancel-txid", result.NewTxID)
	assert.Equal(t, int64(200_000-coreCancelFeeSats), result.Plan.RecoveredSats)
}
