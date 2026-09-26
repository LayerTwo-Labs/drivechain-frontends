package engines

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// stubOrchWalletClient fails CreateBitcoinCoreWallet with a fixed error.
type stubOrchWalletClient struct {
	orchrpc.WalletManagerServiceClient
	err error
}

func (s stubOrchWalletClient) CreateBitcoinCoreWallet(context.Context, *connect.Request[orchpb.CreateBitcoinCoreWalletRequest]) (*connect.Response[orchpb.CreateBitcoinCoreWalletResponse], error) {
	return nil, s.err
}

// TestEnsureWatchOnlyWalletTransientOrchestratorError asserts an orchestrator
// error reaches the caller. Only the orchestrator creates a Core wallet.
func TestEnsureWatchOnlyWalletTransientOrchestratorError(t *testing.T) {
	for _, orchErr := range []error{
		connect.NewError(connect.CodeInternal, errors.New("-28: Verifying blocks…")),
		connect.NewError(connect.CodeUnavailable, errors.New("connection refused")),
	} {
		e := NewWalletEngine(nil, t.TempDir(), &chaincfg.MainNetParams)
		e.SetOrchestratorClient(stubOrchWalletClient{err: orchErr})

		_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
		require.ErrorIs(t, err, orchErr)
	}
}

// A wallet from before the rename holds the scan state, so it wins over a fresh
// wallet_<prefix>.
func TestEnsureWatchOnlyWalletPrefersLegacyName(t *testing.T) {
	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{Wallets: []string{"watch_deadbeef"}},
		}, nil).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, t.TempDir(), &chaincfg.MainNetParams)

	walletName, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
	require.NoError(t, err)
	require.Equal(t, "watch_deadbeef", walletName)
}

// A load failure that does not say the wallet is absent must not create a
// second wallet beside the first one.
func TestEnsureWatchOnlyWalletPropagatesLegacyLoadError(t *testing.T) {
	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
		}, nil).
		AnyTimes()
	mockBitcoind.EXPECT().
		LoadWallet(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("Wallet already loading.")).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, t.TempDir(), &chaincfg.MainNetParams)

	_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
	require.ErrorContains(t, err, "load legacy watch-only wallet")
}
