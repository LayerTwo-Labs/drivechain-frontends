package engines

import (
	"context"
	"errors"
	"os"
	"path/filepath"
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

// TestEnsureWatchOnlyWalletTransientOrchestratorError asserts a warming-up
// orchestrator or a starting bitcoind propagates instead of falling through to
// the local path, which would mint a second Core wallet for the same walletId.
func TestEnsureWatchOnlyWalletTransientOrchestratorError(t *testing.T) {
	// A starting bitcoind fails the local path the same way, so it propagates.
	t.Run("startup propagates", func(t *testing.T) {
		orchErr := connect.NewError(connect.CodeInternal, errors.New("-28: Verifying blocks…"))
		e := NewWalletEngine(nil, nil, t.TempDir(), &chaincfg.MainNetParams)
		e.SetOrchestratorClient(stubOrchWalletClient{err: orchErr})

		_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
		require.ErrorIs(t, err, orchErr)
	})

	// A down orchestrator is exactly what the local path is the fallback for.
	t.Run("unavailable falls back to local", func(t *testing.T) {
		orchErr := connect.NewError(connect.CodeUnavailable, errors.New("connection refused"))
		e := NewWalletEngine(nil, nil, t.TempDir(), &chaincfg.MainNetParams)
		e.SetOrchestratorClient(stubOrchWalletClient{err: orchErr})

		_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
		require.NotErrorIs(t, err, orchErr)
	})
}

// TestEnsureWatchOnlyWalletLocalName asserts the local fallback names the Core
// wallet the same way the orchestrator does, so both resolve one walletId to
// one bitcoind wallet.
func TestEnsureWatchOnlyWalletLocalName(t *testing.T) {
	walletDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(`{
		"version": 1,
		"activeWalletId": "deadbeefcafebabe",
		"wallets": [{
			"id": "deadbeefcafebabe",
			"name": "watcher",
			"wallet_type": "bitcoinCore",
			"watch_only": {"xpub": "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj"}
		}]
	}`), 0o600))

	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{Wallets: []string{"wallet_deadbeef"}},
		}, nil).
		AnyTimes()
	// No wallet from before the rename, so the local name applies.
	mockBitcoind.EXPECT().
		LoadWallet(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("Wallet file verification failed. Path does not exist.")).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, nil, walletDir, &chaincfg.MainNetParams)

	walletName, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
	require.NoError(t, err)
	require.Equal(t, "wallet_deadbeef", walletName)
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
	}, nil, t.TempDir(), &chaincfg.MainNetParams)

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
	}, nil, t.TempDir(), &chaincfg.MainNetParams)

	_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
	require.ErrorContains(t, err, "load legacy watch-only wallet")
}
