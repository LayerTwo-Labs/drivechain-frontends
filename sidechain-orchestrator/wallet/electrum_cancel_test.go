package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	electrumCancelTxid        = "3333333333333333333333333333333333333333333333333333333333333333"
	electrumCancelFundingTxid = "1111111111111111111111111111111111111111111111111111111111111111"
	electrumCancelForeignTxid = "2222222222222222222222222222222222222222222222222222222222222222"
	electrumCancelChildTxid   = "4444444444444444444444444444444444444444444444444444444444444444"
	electrumCancelForeignAddr = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
)

// electrumCancelFixture wires a deposit-like transaction: a foreign input sits
// next to the wallet's own, and a child spends its change.
func electrumCancelFixture(t *testing.T) (*ElectrumBackend, *fakeEsplora, *WalletData) {
	t.Helper()
	p, fake, w, addr := newElectrumFixture(t)
	changeAddr, err := p.NextChangeAddress(context.Background(), w.ID)
	require.NoError(t, err)

	fake.txByID[electrumCancelFundingTxid] = EsploraTx{
		TxID:   electrumCancelFundingTxid,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
		Vout:   []EsploraVout{{ScriptPubKeyAddress: addr, Value: 200_000}},
	}
	tx := EsploraTx{
		TxID:   electrumCancelTxid,
		Weight: 601,
		Fee:    151,
		Vin: []EsploraVin{
			{TxID: electrumCancelForeignTxid, Vout: 0, Prevout: &EsploraVout{ScriptPubKeyAddress: electrumCancelForeignAddr, Value: 50_000}},
			{TxID: electrumCancelFundingTxid, Vout: 0, Prevout: &EsploraVout{ScriptPubKeyAddress: addr, Value: 200_000}},
		},
		Vout: []EsploraVout{
			{ScriptPubKeyAddress: electrumCancelForeignAddr, Value: 150_000},
			{ScriptPubKeyAddress: changeAddr, Value: 99_849},
		},
	}
	child := EsploraTx{
		TxID:   electrumCancelChildTxid,
		Weight: 440,
		Fee:    4_000,
		Vin:    []EsploraVin{{TxID: electrumCancelTxid, Vout: 1, Prevout: &EsploraVout{ScriptPubKeyAddress: changeAddr, Value: 99_849}}},
		Vout:   []EsploraVout{{ScriptPubKeyAddress: electrumCancelForeignAddr, Value: 95_849}},
	}
	fake.txByID[electrumCancelTxid] = tx
	fake.txByID[electrumCancelChildTxid] = child

	fake.stats[addr] = EsploraAddressStats{
		Address:      addr,
		ChainStats:   EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
		MempoolStats: EsploraTxoStats{SpentTxoCount: 1, SpentTxoSum: 200_000, TxCount: 1},
	}
	fake.txs[addr] = []EsploraTx{tx}
	fake.stats[changeAddr] = EsploraAddressStats{
		Address:      changeAddr,
		MempoolStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 99_849, SpentTxoCount: 1, SpentTxoSum: 99_849, TxCount: 2},
	}
	fake.utxos[changeAddr] = []EsploraUTXO{}
	fake.txs[changeAddr] = []EsploraTx{child, tx}
	return p, fake, w
}

// The cancel evicts the child too, so it outpays both: 4151 sats of evicted
// fees plus 1 sat/vB on a bound of 151 + 1 input + 31 bytes of change.
const electrumCancelFeeSats = 4_151 + 183

func TestElectrumCancelReturnsTheOwnInputs(t *testing.T) {
	p, fake, w := electrumCancelFixture(t)
	ctx := context.Background()

	preview, err := p.PreviewCancel(ctx, w.ID, electrumCancelTxid)
	require.NoError(t, err)
	require.NotNil(t, preview.Plan, preview.Reason)
	assert.Equal(t, int64(electrumCancelFeeSats), preview.Plan.FeeSats)
	assert.Equal(t, int64(200_000-electrumCancelFeeSats), preview.Plan.RecoveredSats)

	result, err := p.CancelTransaction(ctx, w.ID, electrumCancelTxid, electrumCancelFeeSats)
	require.NoError(t, err)
	assert.Equal(t, "broadcasttxid", result.NewTxID)

	require.Len(t, fake.broadcast, 1)
	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.Len(t, tx.TxIn, 1, "the cancel drops the foreign input")
	assert.Equal(t, electrumCancelFundingTxid, tx.TxIn[0].PreviousOutPoint.Hash.String())
	require.NotEmpty(t, tx.TxIn[0].Witness)
	assert.Equal(t, bip125Sequence, tx.TxIn[0].Sequence, "the cancel stays replaceable")
	require.Len(t, tx.TxOut, 1, "everything returns to one new change address")
	assert.Equal(t, int64(200_000-electrumCancelFeeSats), tx.TxOut[0].Value)
}

func TestElectrumCancelRefusesATransactionWithNoOwnInput(t *testing.T) {
	p, fake, w := electrumCancelFixture(t)
	tx := fake.txByID[electrumCancelTxid]
	tx.Vin = tx.Vin[:1]
	fake.txByID[electrumCancelTxid] = tx

	preview, err := p.PreviewCancel(context.Background(), w.ID, electrumCancelTxid)
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.Contains(t, preview.Reason, "signs none of the inputs")

	_, err = p.CancelTransaction(context.Background(), w.ID, electrumCancelTxid, electrumCancelFeeSats)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, fake.broadcast)
}

func TestElectrumCancelRefusesAConfirmedTransaction(t *testing.T) {
	p, fake, w := electrumCancelFixture(t)
	tx := fake.txByID[electrumCancelTxid]
	tx.Status = EsploraStatus{Confirmed: true, BlockHeight: 105}
	fake.txByID[electrumCancelTxid] = tx

	_, err := p.CancelTransaction(context.Background(), w.ID, electrumCancelTxid, electrumCancelFeeSats)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, fake.broadcast)
}

func TestElectrumCancelRefusesAMultisigWithTooFewKeys(t *testing.T) {
	p, fake, w := electrumCancelFixture(t)
	ctx := context.Background()
	_, err := p.PreviewCancel(ctx, w.ID, electrumCancelTxid)
	require.NoError(t, err)

	p.svc.GetWalletByID(w.ID).Multisig = &MultisigWalletData{M: 2, N: 3, Cosigners: []MultisigCosigner{
		{Xpub: "held", Xprv: "xprv"}, {Xpub: "a"}, {Xpub: "b"},
	}}
	preview, err := p.PreviewCancel(ctx, w.ID, electrumCancelTxid)
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.Contains(t, preview.Reason, "fewer keys")

	_, err = p.CancelTransaction(ctx, w.ID, electrumCancelTxid, electrumCancelFeeSats)
	require.Error(t, err)
	assert.Empty(t, fake.broadcast)
}

func TestElectrumCancelRefusesAFeeOverTheConfirmedOne(t *testing.T) {
	p, fake, w := electrumCancelFixture(t)

	_, err := p.CancelTransaction(context.Background(), w.ID, electrumCancelTxid, electrumCancelFeeSats-1)
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	assert.Empty(t, fake.broadcast)
}
