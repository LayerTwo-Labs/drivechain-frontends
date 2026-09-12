package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"math"
	"testing"

	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const feeTestWalletSats = int64(200_000)

// fundFeeTestWallet gives the fixture one confirmed coin to spend.
func fundFeeTestWallet(fake *fakeEsplora, addr string) {
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: feeTestWalletSats, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "7777777777777777777777777777777777777777777777777777777777777777",
		Vout: 0, Value: feeTestWalletSats,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}
}

// broadcastFeeRate is the sat/vB the broadcast transaction pays.
func broadcastFeeRate(t *testing.T, rawHex string) float64 {
	t.Helper()
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	out := int64(0)
	for _, o := range tx.TxOut {
		out += o.Value
	}
	weight := tx.SerializeSizeStripped()*3 + tx.SerializeSize()
	vsize := math.Ceil(float64(weight) / 4)
	return float64(feeTestWalletSats-out) / vsize
}

// A send with no fee rate takes the chain's estimate. The chain cannot answer,
// so the send must fail: a 1 sat/vB stand-in leaves the coins stuck.
func TestElectrumSendRefusesAFailedFeeEstimate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeErr = errors.New("estimatefee: connection refused")

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
	})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no fee estimate")
	assert.Empty(t, fake.broadcast, "a send without a rate must build no transaction")
}

// A server that answers zero (or a negative number) has no estimate either.
func TestElectrumSendRefusesAZeroFeeEstimate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeRate = 0

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
	})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no fee estimate")
	assert.Empty(t, fake.broadcast, "a send without a rate must build no transaction")
}

// The chain answers, so the send pays what it answered.
func TestElectrumSendPaysTheEstimatedRate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeRate = 401.5

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
	})
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)
	assert.InDelta(t, 401.5, broadcastFeeRate(t, fake.broadcast[0]), 10)
}

// The user names the rate, so the wallet pays it and asks no server.
func TestElectrumSendKeepsTheRateTheUserNamed(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeRate = 401.5

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		FeeRateSatPerVB:  3,
	})
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)
	assert.InDelta(t, 3, broadcastFeeRate(t, fake.broadcast[0]), 0.5)
	assert.Zero(t, fake.feeCalls, "a named rate needs no estimate")
}

// A server-side OP_RETURN sender passes no fee at all. It gets an error it can
// try again on, never a transaction at a made-up rate.
func TestElectrumSendOpReturnRefusesAFailedFeeEstimate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeErr = errors.New("estimatefee: connection refused")

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		OpReturnHex: hex.EncodeToString([]byte("coinnews: hello world")),
	})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no fee estimate")
	assert.Empty(t, fake.broadcast)

	fake.feeRate = 401.5
	fake.feeErr = nil
	_, err = p.Send(context.Background(), w.ID, SendRequest{
		OpReturnHex: hex.EncodeToString([]byte("coinnews: hello world")),
	})
	require.NoError(t, err, "the caller can try again once the server answers")
	require.Len(t, fake.broadcast, 1)
}

// Without an estimate the preview still reports the transaction, so the user
// can name a rate or pay a child. It carries no suggested rate.
func TestElectrumPreviewBumpFeeWithoutAnEstimateStillPreviews(t *testing.T) {
	p, fake, w, txid, _ := bumpFeeFixture(t)
	fake.feeErr = errors.New("estimatefee: connection refused")

	preview, err := p.PreviewBumpFee(context.Background(), w.ID, BumpFeeRequest{TxID: txid})
	require.NoError(t, err)
	require.NotNil(t, preview)
	assert.True(t, preview.CanReplace)
	assert.Zero(t, preview.SuggestedRate)
	assert.Len(t, preview.Outputs, 2)
	assert.Equal(t, int64(151), preview.OldFeeSats)
	assert.Nil(t, preview.Plan)
	assert.Contains(t, preview.Reason, "fee estimate")
}

// A bump that asks the code to pick the rate needs the estimate.
func TestElectrumBumpFeeWithoutAnEstimateRefusesToPickTheRate(t *testing.T) {
	p, fake, w, txid, _ := bumpFeeFixture(t)
	fake.feeErr = errors.New("estimatefee: connection refused")

	_, err := p.BumpFee(context.Background(), w.ID, BumpFeeRequest{TxID: txid})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "fee estimate")
	assert.Empty(t, fake.broadcast)
}

// The user names the rate, so the bump goes out with no estimate at all.
func TestElectrumBumpFeeWithoutAnEstimateTakesANamedRate(t *testing.T) {
	p, fake, w, txid, _ := bumpFeeFixture(t)
	fake.feeErr = errors.New("estimatefee: connection refused")

	result, err := p.BumpFee(context.Background(), w.ID, BumpFeeRequest{TxID: txid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Equal(t, int64(1510), result.Plan.NewFeeSats)
	require.Len(t, fake.broadcast, 1)
}

// A fixed fee names the whole fee, so a dead estimate must not stop a CPFP
// child or a deposit.
func TestElectrumSendWithAFixedFeeNeedsNoEstimate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fundFeeTestWallet(fake, addr)
	fake.feeErr = errors.New("estimatefee: connection refused")

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		FixedFeeSats:     1_000,
	})
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)
	assert.Zero(t, fake.feeCalls, "a fixed fee needs no estimate")
}
