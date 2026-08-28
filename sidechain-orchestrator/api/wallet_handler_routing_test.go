package api

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"google.golang.org/protobuf/proto"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// recordingProvider captures Send/Balance calls; the embedded nil interface
// panics on anything the test doesn't expect.
type recordingProvider struct {
	wallet.Backend
	lastSendWallet string
	lastSend       wallet.SendRequest
	sendErr        error
	lastBumpWallet string
	lastBump       wallet.BumpFeeRequest
	bumpErr        error
}

func (f *recordingProvider) Send(ctx context.Context, walletID string, req wallet.SendRequest) (string, error) {
	f.lastSendWallet = walletID
	f.lastSend = req
	if f.sendErr != nil {
		return "", f.sendErr
	}
	return "fake-txid", nil
}

func (f *recordingProvider) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	return 1.5, 0.25, nil
}

// newRoutedHandler builds the real Service + BackendRouter + WalletEngine
// stack over recording fakes — the exact production wiring minus daemons. One
// electrum wallet and one Core wallet, so routing has two sides to pick from.
func newRoutedHandler(t *testing.T) (*WalletHandler, *recordingProvider, *recordingProvider, string, string) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	core, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)
	require.Equal(t, wallet.WalletTypeBitcoinCore, core.WalletType)
	elec, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, wallet.WalletTypeElectrum, elec.WalletType)

	elecFake := &recordingProvider{}
	chainFake := &recordingProvider{}
	router := wallet.NewBackendRouter(svc, chainFake, elecFake)
	engine := wallet.NewWalletEngine(svc, router, nil, log)

	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	return h, elecFake, chainFake, elec.ID, core.ID
}

func TestSendTransactionRoutesPerWalletType(t *testing.T) {
	h, elecFake, chainFake, elecID, coreID := newRoutedHandler(t)
	ctx := context.Background()

	resp, err := h.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           elecID,
		Destinations:       map[string]int64{"addr": 10_000},
		FeeRateSatPerVbyte: 2,
		OpReturnHex:        "beef",
		RequiredInputs: []*pb.UnspentOutput{
			{Txid: "pin", Vout: 3, AmountSats: 40_000},
		},
	}))
	require.NoError(t, err)
	assert.Equal(t, "fake-txid", resp.Msg.Txid)

	assert.Equal(t, elecID, elecFake.lastSendWallet)
	assert.Equal(t, int64(10_000), elecFake.lastSend.DestinationsSats["addr"])
	assert.Equal(t, int64(2), elecFake.lastSend.FeeRateSatPerVB)
	assert.Equal(t, "beef", elecFake.lastSend.OpReturnHex)
	require.Len(t, elecFake.lastSend.RequiredInputs, 1)
	assert.Equal(t, wallet.RequiredInput{TxID: "pin", Vout: 3, AmountSats: 40_000}, elecFake.lastSend.RequiredInputs[0])
	assert.Empty(t, chainFake.lastSendWallet)

	_, err = h.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     coreID,
		Destinations: map[string]int64{"addr": 10_000},
	}))
	require.NoError(t, err)
	assert.Equal(t, coreID, chainFake.lastSendWallet)
}

func TestSendTransactionPassesThroughConnectCodes(t *testing.T) {
	h, elecFake, _, elecID, _ := newRoutedHandler(t)

	// Providers reject unsupported features with their own connect code —
	// the handler must not rewrap it as internal.
	elecFake.sendErr = connect.NewError(
		connect.CodeInvalidArgument,
		errors.New("this wallet cannot allow a replay"),
	)

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     elecID,
		Destinations: map[string]int64{"addr": 10_000},
		AllowReplay:  true,
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestSendTransactionDustCheck(t *testing.T) {
	h, elecFake, _, elecID, _ := newRoutedHandler(t)

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     elecID,
		Destinations: map[string]int64{"addr": 100},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	assert.Empty(t, elecFake.lastSendWallet)
}

func TestGetBalanceUsesProviderAndConvertsToSats(t *testing.T) {
	h, _, _, _, coreID := newRoutedHandler(t)

	resp, err := h.GetBalance(context.Background(), connect.NewRequest(&pb.GetBalanceRequest{WalletId: coreID}))
	require.NoError(t, err)
	assert.Equal(t, float64(150_000_000), resp.Msg.ConfirmedSats)
	assert.Equal(t, float64(25_000_000), resp.Msg.UnconfirmedSats)
}

func TestGetBalanceEmptyWalletIDResolvesActive(t *testing.T) {
	h, _, _, _, coreID := newRoutedHandler(t)

	// GenerateWallet leaves the most recent wallet active (the core one).
	resp, err := h.GetBalance(context.Background(), connect.NewRequest(&pb.GetBalanceRequest{}))
	require.NoError(t, err)
	assert.Equal(t, float64(150_000_000), resp.Msg.ConfirmedSats)
	_ = coreID
}

func (f *recordingProvider) BumpFee(ctx context.Context, walletID string, req wallet.BumpFeeRequest) (*wallet.BumpFeeResult, error) {
	f.lastBumpWallet = walletID
	f.lastBump = req
	if f.bumpErr != nil {
		return nil, f.bumpErr
	}
	return &wallet.BumpFeeResult{
		NewTxID: "replacement-txid",
		Plan: wallet.BumpFeePlan{
			OldFeeSats: 150, NewFeeSats: 1500, ExtraFeeSats: 1350, NewFeeRate: 10,
			FeeFromVout: 1, AmountBefore: 99_850, AmountAfter: 98_500,
			OutputRemoved: false, ReducesPayment: true,
		},
	}, nil
}

func (f *recordingProvider) PreviewBumpFee(ctx context.Context, walletID string, req wallet.BumpFeeRequest) (*wallet.BumpFeePreview, error) {
	f.lastBumpWallet = walletID
	f.lastBump = req
	return &wallet.BumpFeePreview{
		InputCount: 2, VsizeVBytes: 151, OldFeeSats: 151, OldFeeRate: 1, SuggestedRate: 10,
		CanReplace: true, HasChild: true, Reason: "another transaction already spends this one",
		Outputs: []wallet.BumpFeeOutput{
			{Vout: 0, AmountSats: 100_000, Address: "tb1qpayment", DustSats: 294, VsizeBytes: 31},
			{Vout: 1, AmountSats: 99_849, Address: "tb1qchange", IsChange: true, IsMine: true, DustSats: 294, VsizeBytes: 31},
		},
	}, nil
}

// Output 0 is a real choice. It must not arrive at the backend as "take it from
// the change output", which would replace the transaction the user never asked
// for.
func TestBumpFeeCarriesOutputZero(t *testing.T) {
	h, elecFake, _, elecID, _ := newRoutedHandler(t)

	_, err := h.BumpFee(context.Background(), connect.NewRequest(&pb.BumpFeeRequest{
		WalletId: elecID, Txid: "abc", NewFeeRate: 10, FeeFromVout: proto.Int32(0),
	}))
	require.NoError(t, err)
	require.NotNil(t, elecFake.lastBump.FeeFromVout)
	assert.Equal(t, 0, *elecFake.lastBump.FeeFromVout)

	_, err = h.BumpFee(context.Background(), connect.NewRequest(&pb.BumpFeeRequest{
		WalletId: elecID, Txid: "abc", NewFeeRate: 10,
	}))
	require.NoError(t, err)
	assert.Nil(t, elecFake.lastBump.FeeFromVout, "an unset output means the change output")
}

func TestBumpFeeReportsThePlan(t *testing.T) {
	h, _, _, elecID, _ := newRoutedHandler(t)

	resp, err := h.BumpFee(context.Background(), connect.NewRequest(&pb.BumpFeeRequest{
		WalletId: elecID, Txid: "abc", NewFeeRate: 10,
	}))
	require.NoError(t, err)
	assert.Equal(t, "replacement-txid", resp.Msg.NewTxid)
	require.NotNil(t, resp.Msg.Plan)
	assert.Equal(t, int64(150), resp.Msg.Plan.OldFeeSats)
	assert.Equal(t, int64(1500), resp.Msg.Plan.NewFeeSats)
	assert.Equal(t, int64(1350), resp.Msg.Plan.ExtraFeeSats)
	assert.InDelta(t, 10.0, resp.Msg.Plan.NewFeeRateSatVb, 0.001)
	assert.Equal(t, int32(1), resp.Msg.Plan.FeeFromVout)
	assert.Equal(t, int64(99_850), resp.Msg.Plan.AmountBeforeSats)
	assert.Equal(t, int64(98_500), resp.Msg.Plan.AmountAfterSats)
	assert.False(t, resp.Msg.Plan.OutputRemoved)
	assert.True(t, resp.Msg.Plan.ReducesPayment)
}

func TestPreviewBumpFeeReportsEveryField(t *testing.T) {
	h, _, _, elecID, _ := newRoutedHandler(t)

	resp, err := h.PreviewBumpFee(context.Background(), connect.NewRequest(&pb.PreviewBumpFeeRequest{
		WalletId: elecID, Txid: "abc",
	}))
	require.NoError(t, err)
	msg := resp.Msg
	assert.Equal(t, int32(2), msg.InputCount)
	assert.Equal(t, int64(151), msg.VsizeVbytes)
	assert.Equal(t, int64(151), msg.OldFeeSats)
	assert.Equal(t, int64(10), msg.SuggestedFeeRate)
	assert.True(t, msg.CanReplace)
	assert.True(t, msg.HasChild)
	assert.Contains(t, msg.Reason, "already spends this one")
	assert.Nil(t, msg.Plan)
	require.Len(t, msg.Outputs, 2)
	assert.Equal(t, int32(1), msg.Outputs[1].Vout)
	assert.Equal(t, "tb1qchange", msg.Outputs[1].Address)
	assert.True(t, msg.Outputs[1].IsChange)
	assert.True(t, msg.Outputs[1].IsMine)
	assert.Equal(t, int64(294), msg.Outputs[1].DustSats)
	assert.False(t, msg.Outputs[0].IsMine)
}

func TestBumpFeeKeepsTheBackendErrorCode(t *testing.T) {
	h, elecFake, _, elecID, _ := newRoutedHandler(t)
	elecFake.bumpErr = connect.NewError(connect.CodeFailedPrecondition, errors.New("transaction is confirmed"))

	_, err := h.BumpFee(context.Background(), connect.NewRequest(&pb.BumpFeeRequest{
		WalletId: elecID, Txid: "abc",
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err),
		"the dialog shows a reason, not an internal error")
}
