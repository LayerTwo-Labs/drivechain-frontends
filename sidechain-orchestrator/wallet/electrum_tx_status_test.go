package wallet

import (
	"context"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The lone transaction read carries no block, and the address history does.
func TestElectrumTxStatusReadsTheAddressHistory(t *testing.T) {
	fake := newFakeEsplora()
	fake.txByID["bid"] = EsploraTx{TxID: "bid", Vout: []EsploraVout{{}, {ScriptPubKeyAddress: "change"}}}
	fake.txs["change"] = []EsploraTx{{TxID: "bid", Status: EsploraStatus{Confirmed: true, BlockHeight: 997083}}}
	p := NewElectrumBackend(newTestService(t), fake, StaticParams(&chaincfg.SigNetParams), zerolog.New(zerolog.NewTestWriter(t)))

	status, err := p.TxStatus(context.Background(), "bid")
	require.NoError(t, err)
	assert.True(t, status.Confirmed)
	assert.Equal(t, 997083, status.BlockHeight)
}

// A history that names no such transaction proves nothing, so the read fails.
func TestElectrumTxStatusFailsWhenTheHistoryOmitsIt(t *testing.T) {
	fake := newFakeEsplora()
	fake.txByID["bid"] = EsploraTx{TxID: "bid", Vin: []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: "coin"}}}}
	p := NewElectrumBackend(newTestService(t), fake, StaticParams(&chaincfg.SigNetParams), zerolog.New(zerolog.NewTestWriter(t)))

	_, err := p.TxStatus(context.Background(), "bid")
	require.Error(t, err)
}
