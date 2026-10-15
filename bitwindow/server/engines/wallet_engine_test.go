package engines

import (
	"context"
	"encoding/json"
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

func TestCoreWalletName(t *testing.T) {
	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.ListWalletsResponse{Wallets: []string{"watch_deadbeef", "watch_cafebabe"}}), nil).
		AnyTimes()
	orch := mocks.NewMockWalletManagerServiceClient(ctrl)
	orch.EXPECT().
		CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ any, req *connect.Request[orchpb.CreateBitcoinCoreWalletRequest]) (*connect.Response[orchpb.CreateBitcoinCoreWalletResponse], error) {
			return connect.NewResponse(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "wallet_" + req.Msg.WalletId[:8]}), nil
		}).
		AnyTimes()

	walletDir := t.TempDir()
	walletJSON := `{
		"version": 1,
		"activeWalletId": "cafebabedeadbeef",
		"wallets": [
			{"id": "deadbeefcafebabe", "name": "watch", "wallet_type": "bitcoinCore", "watch_only": {"xpub": "xpub-test"}},
			{"id": "cafebabedeadbeef", "name": "seed", "wallet_type": "bitcoinCore", "master": {"seed_hex": "` + localSeedHex + `"}}
		]
	}`
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(walletJSON), 0o600))

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, walletDir, &chaincfg.MainNetParams)
	e.SetOrchestratorClient(orch)

	t.Run("a watch-only wallet uses the legacy wallet", func(t *testing.T) {
		name, err := e.CoreWalletName(t.Context(), "deadbeefcafebabe")
		require.NoError(t, err)
		require.Equal(t, "watch_deadbeef", name)
	})

	t.Run("a seed wallet ignores a legacy wallet", func(t *testing.T) {
		name, err := e.CoreWalletName(t.Context(), "cafebabedeadbeef")
		require.NoError(t, err)
		require.Equal(t, "wallet_cafebabe", name)
	})

	t.Run("an unknown wallet fails", func(t *testing.T) {
		_, err := e.CoreWalletName(t.Context(), "0000000000000000")
		require.ErrorContains(t, err, "not found")
	})
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
	t.Run("a local wallet with no seed fails the precondition", func(t *testing.T) {
		walletDir := t.TempDir()
		walletJSON := `{"version": 1, "activeWalletId": "watch", "wallets": [{"id": "watch", "wallet_type": "bitcoinCore"}]}`
		require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(walletJSON), 0o600))
		engine := &WalletEngine{walletDir: walletDir}

		_, err := engine.GetWalletSeed("watch")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("orchestrator error does not fall back to local seed", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		seed, err := engine.GetWalletSeed("local")
		require.ErrorContains(t, err, "orchestrator down")
		require.Empty(t, seed)
	})
}

func TestGetWalletInfo(t *testing.T) {
	const walletsJSON = `{"version":1,"activeWalletId":"a","wallets":[
		{"id":"a","name":"Alpha","wallet_type":"enforcer","master":{"seed_hex":"00"}},
		{"id":"b","name":"Beta","wallet_type":"bitcoinCore","master":{"seed_hex":"01"}}
	]}`

	t.Run("plain wallet.json", func(t *testing.T) {
		walletDir := t.TempDir()
		require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(walletsJSON), 0o600))
		e := &WalletEngine{walletDir: walletDir}

		info, err := e.GetWalletInfo(t.Context(), "b")
		require.NoError(t, err)
		require.Equal(t, "Beta", info.Name)

		_, err = e.GetWalletInfo(t.Context(), "missing")
		require.ErrorContains(t, err, "wallet missing not found")
	})

	t.Run("encrypted wallet reads the unlock cache", func(t *testing.T) {
		walletDir := t.TempDir()
		require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet_encryption.json"), []byte(`{"encrypted":true}`), 0o600))
		e := NewWalletEngine(nil, walletDir, &chaincfg.MainNetParams)

		_, err := e.GetWalletInfo(t.Context(), "b")
		require.ErrorContains(t, err, "wallet is encrypted and locked")

		var walletData map[string]any
		require.NoError(t, json.Unmarshal([]byte(walletsJSON), &walletData))
		require.NoError(t, e.Unlock(walletData))

		info, err := e.GetWalletInfo(t.Context(), "b")
		require.NoError(t, err)
		require.Equal(t, "Beta", info.Name)

		_, err = e.GetWalletInfo(t.Context(), "missing")
		require.ErrorContains(t, err, "wallet missing not found")
	})
}

func TestUnlock_BadWalletEntryFails(t *testing.T) {
	e := NewWalletEngine(nil, t.TempDir(), &chaincfg.MainNetParams)

	var walletData map[string]any
	require.NoError(t, json.Unmarshal([]byte(`{"activeWalletId":"a","wallets":[
		{"id":"a","master":{"seed_hex":"00"}},
		{"id":"b","name":7,"master":{"seed_hex":"01"}}
	]}`), &walletData))

	require.ErrorContains(t, e.Unlock(walletData), "parse wallet for cache")
	require.False(t, e.IsUnlocked())
	require.Empty(t, e.walletCache)
}
