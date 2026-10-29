package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

type addressUnspentFixture struct {
	backend *ElectrumBackend
	fake    *fakeEsplora
	address string
	prevID  string
}

// newAddressUnspentFixture funds an uncompressed p2pkh address with one tx
// that holds 150_000 sats at vout 0 and 250_000 sats at vout 1.
func newAddressUnspentFixture(t *testing.T) addressUnspentFixture {
	t.Helper()
	net := &chaincfg.SigNetParams
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	addr, err := btcutil.NewAddressPubKeyHash(btcutil.Hash160(priv.PubKey().SerializeUncompressed()), net)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(addr)
	require.NoError(t, err)

	prev := wire.NewMsgTx(2)
	prev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 1}, nil, nil))
	prev.AddTxOut(wire.NewTxOut(150_000, script))
	prev.AddTxOut(wire.NewTxOut(250_000, script))
	var buf bytes.Buffer
	require.NoError(t, prev.Serialize(&buf))

	fake := newFakeEsplora()
	prevID := prev.TxHash().String()
	fake.hexByID[prevID] = hex.EncodeToString(buf.Bytes())

	return addressUnspentFixture{
		backend: NewElectrumBackend(newTestService(t), fake, StaticParams(net), zerolog.Nop()),
		fake:    fake,
		address: addr.EncodeAddress(),
		prevID:  prevID,
	}
}

func (f addressUnspentFixture) serve(utxos ...EsploraUTXO) {
	f.fake.utxos[f.address] = utxos
}

func TestAddressUnspentReadsValuesFromTheRawTx(t *testing.T) {
	f := newAddressUnspentFixture(t)
	f.serve(
		EsploraUTXO{TxID: f.prevID, Vout: 0, Value: 150_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
		EsploraUTXO{TxID: f.prevID, Vout: 1, Value: 250_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
	)

	utxos, tip, err := f.backend.AddressUnspent(context.Background(), f.address)
	require.NoError(t, err)
	require.Equal(t, 110, tip)
	require.Len(t, utxos, 2)
	require.InDelta(t, 0.0015, utxos[0].Amount, 1e-12)
	require.InDelta(t, 0.0025, utxos[1].Amount, 1e-12)
	require.Equal(t, 11, utxos[0].Confirmations)
}

func TestAddressUnspentIgnoresALowServerValue(t *testing.T) {
	f := newAddressUnspentFixture(t)
	f.serve(
		EsploraUTXO{TxID: f.prevID, Vout: 0, Value: 1_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
		EsploraUTXO{TxID: f.prevID, Vout: 1, Value: 2_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}},
	)

	utxos, _, err := f.backend.AddressUnspent(context.Background(), f.address)
	require.NoError(t, err)
	require.Len(t, utxos, 2)
	require.InDelta(t, 0.0015, utxos[0].Amount, 1e-12)
	require.InDelta(t, 0.0025, utxos[1].Amount, 1e-12)
}

func TestAddressUnspentRefusesABadServer(t *testing.T) {
	other := wire.NewMsgTx(2)
	other.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 2}, nil, nil))
	other.AddTxOut(wire.NewTxOut(150_000, []byte{txscript.OP_TRUE}))
	var otherBuf bytes.Buffer
	require.NoError(t, other.Serialize(&otherBuf))

	tests := []struct {
		name  string
		setup func(f addressUnspentFixture)
		want  string
	}{
		{
			name: "raw tx hashes to another txid",
			setup: func(f addressUnspentFixture) {
				f.fake.hexByID[f.prevID] = hex.EncodeToString(otherBuf.Bytes())
				f.serve(EsploraUTXO{TxID: f.prevID, Vout: 0, Value: 150_000})
			},
			want: "server answered tx",
		},
		{
			name: "vout out of range",
			setup: func(f addressUnspentFixture) {
				f.serve(EsploraUTXO{TxID: f.prevID, Vout: 2, Value: 150_000})
			},
			want: "has no output 2",
		},
		{
			name: "output pays another script",
			setup: func(f addressUnspentFixture) {
				otherID := other.TxHash().String()
				f.fake.hexByID[otherID] = hex.EncodeToString(otherBuf.Bytes())
				f.serve(EsploraUTXO{TxID: otherID, Vout: 0, Value: 150_000})
			},
			want: "does not pay the address",
		},
		{
			name: "raw tx is missing",
			setup: func(f addressUnspentFixture) {
				delete(f.fake.hexByID, f.prevID)
				f.serve(EsploraUTXO{TxID: f.prevID, Vout: 0, Value: 150_000})
			},
			want: "not found",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			f := newAddressUnspentFixture(t)
			tt.setup(f)

			_, _, err := f.backend.AddressUnspent(context.Background(), f.address)
			require.ErrorContains(t, err, tt.want)
		})
	}
}
