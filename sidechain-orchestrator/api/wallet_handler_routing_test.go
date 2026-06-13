package api

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// recordingProvider captures Send/Balance calls; the embedded nil interface
// panics on anything the test doesn't expect.
type recordingProvider struct {
	wallet.Provider
	lastSendWallet string
	lastSend       wallet.SendRequest
	sendErr        error
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

// newRoutedHandler builds the real Service + RoutingProvider + WalletEngine
// stack over recording fakes — the exact production wiring minus daemons.
func newRoutedHandler(t *testing.T) (*WalletHandler, *recordingProvider, *recordingProvider, string, string) {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	enf, err := svc.GenerateWallet("Enforcer", "", "", nil)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)
	require.Equal(t, "bitcoinCore", core.WalletType)

	enfFake := &recordingProvider{}
	chainFake := &recordingProvider{}
	router := wallet.NewRoutingProvider(svc, enfFake, chainFake, nil)
	engine := wallet.NewWalletEngine(svc, router, nil, log)

	h := NewWalletHandler(svc)
	h.SetEngine(engine)
	return h, enfFake, chainFake, enf.ID, core.ID
}

func TestSendTransactionRoutesPerWalletType(t *testing.T) {
	h, enfFake, chainFake, enfID, coreID := newRoutedHandler(t)
	ctx := context.Background()

	resp, err := h.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:           enfID,
		Destinations:       map[string]int64{"addr": 10_000},
		FeeRateSatPerVbyte: 2,
		OpReturnHex:        "beef",
		RequiredInputs: []*pb.UnspentOutput{
			{Txid: "pin", Vout: 3, AmountSats: 40_000},
		},
	}))
	require.NoError(t, err)
	assert.Equal(t, "fake-txid", resp.Msg.Txid)

	assert.Equal(t, enfID, enfFake.lastSendWallet)
	assert.Equal(t, int64(10_000), enfFake.lastSend.DestinationsSats["addr"])
	assert.Equal(t, int64(2), enfFake.lastSend.FeeRateSatPerVB)
	assert.Equal(t, "beef", enfFake.lastSend.OpReturnHex)
	require.Len(t, enfFake.lastSend.RequiredInputs, 1)
	assert.Equal(t, wallet.RequiredInput{TxID: "pin", Vout: 3, AmountSats: 40_000}, enfFake.lastSend.RequiredInputs[0])
	assert.Empty(t, chainFake.lastSendWallet)

	_, err = h.SendTransaction(ctx, connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     coreID,
		Destinations: map[string]int64{"addr": 10_000},
	}))
	require.NoError(t, err)
	assert.Equal(t, coreID, chainFake.lastSendWallet)
}

func TestSendTransactionPassesThroughConnectCodes(t *testing.T) {
	h, enfFake, _, enfID, _ := newRoutedHandler(t)

	// Providers reject unsupported features with their own connect code —
	// the handler must not rewrap it as internal.
	enfFake.sendErr = connect.NewError(
		connect.CodeInvalidArgument,
		errors.New("replay protection is only supported for Bitcoin Core wallets"),
	)

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:      enfID,
		Destinations:  map[string]int64{"addr": 10_000},
		ReplayProtect: true,
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestSendTransactionDustCheck(t *testing.T) {
	h, enfFake, _, enfID, _ := newRoutedHandler(t)

	_, err := h.SendTransaction(context.Background(), connect.NewRequest(&pb.SendTransactionRequest{
		WalletId:     enfID,
		Destinations: map[string]int64{"addr": 100},
	}))
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	assert.Empty(t, enfFake.lastSendWallet)
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
