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

const (
	localSeedHex   = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
	starterSeedHex = "1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"
)

func newSeedTestEngine(t *testing.T) (*WalletEngine, *mocks.MockWalletManagerServiceClient) {
	t.Helper()

	walletDir := t.TempDir()
	walletJSON := `{
		"version": 1,
		"activeWalletId": "local",
		"wallets": [
			{
				"id": "local",
				"name": "local",
				"wallet_type": "bitcoinCore",
				"master": {"seed_hex": "` + localSeedHex + `"}
			}
		]
	}`
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(walletJSON), 0o600))

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	return &WalletEngine{walletDir: walletDir, orchClient: orch}, orch
}

func TestGetStarterSeed(t *testing.T) {
	t.Run("list wallets error does not fall back to local seed", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		seed, err := engine.GetStarterSeed()
		require.ErrorContains(t, err, "orchestrator down")
		require.Empty(t, seed)
	})

	t.Run("no starter wallet returns error", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&orchpb.ListWalletsResponse{
			Wallets: []*orchpb.WalletMetadata{{Id: "local"}},
		}), nil)

		seed, err := engine.GetStarterSeed()
		require.Error(t, err)
		require.Empty(t, seed)
	})

	t.Run("returns seed of starter, not first wallet", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&orchpb.ListWalletsResponse{
			Wallets: []*orchpb.WalletMetadata{{Id: "local"}, {Id: "starter", IsStarter: true}},
		}), nil)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).DoAndReturn(
			func(_ any, req *connect.Request[orchpb.GetWalletSeedRequest]) (*connect.Response[orchpb.GetWalletSeedResponse], error) {
				require.Equal(t, "starter", req.Msg.WalletId)
				return connect.NewResponse(&orchpb.GetWalletSeedResponse{SeedHex: starterSeedHex}), nil
			})

		seed, err := engine.GetStarterSeed()
		require.NoError(t, err)
		require.Equal(t, starterSeedHex, seed)
	})
}

func TestGetWalletSeed(t *testing.T) {
	t.Run("orchestrator error does not fall back to local seed", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		seed, err := engine.GetWalletSeed("local")
		require.ErrorContains(t, err, "orchestrator down")
		require.Empty(t, seed)
	})
}
