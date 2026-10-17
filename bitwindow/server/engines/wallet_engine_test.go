package engines

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

// openWalletClient lists wallet as the one open wallet. Every other call goes
// to the embedded client.
type openWalletClient struct {
	orchrpc.WalletManagerServiceClient
	wallet *orchpb.WalletMetadata
}

func (o openWalletClient) ListWallets(context.Context, *connect.Request[orchpb.ListWalletsRequest]) (*connect.Response[orchpb.ListWalletsResponse], error) {
	return connect.NewResponse(&orchpb.ListWalletsResponse{
		Wallets:        []*orchpb.WalletMetadata{o.wallet},
		ActiveWalletId: o.wallet.Id,
	}), nil
}

func (o openWalletClient) GetWalletStatus(context.Context, *connect.Request[orchpb.GetWalletStatusRequest]) (*connect.Response[orchpb.GetWalletStatusResponse], error) {
	return connect.NewResponse(&orchpb.GetWalletStatusResponse{State: orchpb.WalletState_WALLET_STATE_UNLOCKED}), nil
}

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
		e := NewWalletEngine(nil, stubOrchWalletClient{err: orchErr}, &chaincfg.MainNetParams, nil)

		_, err := e.EnsureWatchOnlyWallet(t.Context(), "deadbeefcafebabe")
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
	}, mocks.NewMockWalletManagerServiceClient(ctrl), &chaincfg.MainNetParams, nil)

	walletName, err := e.EnsureWatchOnlyWallet(t.Context(), "deadbeefcafebabe")
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
	}, mocks.NewMockWalletManagerServiceClient(ctrl), &chaincfg.MainNetParams, nil)

	_, err := e.EnsureWatchOnlyWallet(t.Context(), "deadbeefcafebabe")
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
	orch.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&orchpb.ListWalletsResponse{
			Wallets: []*orchpb.WalletMetadata{
				{Id: "deadbeefcafebabe", Name: "watch", WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE, WatchOnly: true},
				{Id: "cafebabedeadbeef", Name: "seed", WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE},
			},
			ActiveWalletId: "cafebabedeadbeef",
		}), nil).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, orch, &chaincfg.MainNetParams, nil)

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

const starterSeedHex = "1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100"

func newSeedTestEngine(t *testing.T) (*WalletEngine, *mocks.MockWalletManagerServiceClient) {
	t.Helper()
	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	return &WalletEngine{orchClient: orch}, orch
}

func TestGetStarterSeed(t *testing.T) {
	t.Run("list wallets error does not fall back to local seed", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		seed, err := engine.GetStarterSeed(t.Context())
		require.ErrorContains(t, err, "orchestrator down")
		require.Empty(t, seed)
	})

	t.Run("no starter wallet returns error", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&orchpb.ListWalletsResponse{
			Wallets: []*orchpb.WalletMetadata{{Id: "local"}},
		}), nil)

		seed, err := engine.GetStarterSeed(t.Context())
		require.ErrorContains(t, err, "no starter wallet")
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

		seed, err := engine.GetStarterSeed(t.Context())
		require.NoError(t, err)
		require.Equal(t, starterSeedHex, seed)
	})

	t.Run("a canceled context reaches the orchestrator", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).DoAndReturn(
			func(ctx context.Context, _ *connect.Request[orchpb.ListWalletsRequest]) (*connect.Response[orchpb.ListWalletsResponse], error) {
				return nil, ctx.Err()
			})

		ctx, cancel := context.WithCancel(t.Context())
		cancel()
		_, err := engine.GetStarterSeed(ctx)
		require.ErrorIs(t, err, context.Canceled)
	})
}

func TestGetWalletSeed(t *testing.T) {
	t.Run("a wallet with no seed fails the precondition", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet watch holds no master seed")))

		_, err := engine.GetWalletSeed(t.Context(), "watch")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("orchestrator error does not fall back to local seed", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		seed, err := engine.GetWalletSeed(t.Context(), "local")
		require.ErrorContains(t, err, "orchestrator down")
		require.Empty(t, seed)
	})

	t.Run("a canceled context reaches the orchestrator", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletSeed(gomock.Any(), gomock.Any()).DoAndReturn(
			func(ctx context.Context, _ *connect.Request[orchpb.GetWalletSeedRequest]) (*connect.Response[orchpb.GetWalletSeedResponse], error) {
				return nil, ctx.Err()
			})

		ctx, cancel := context.WithCancel(t.Context())
		cancel()
		_, err := engine.GetWalletSeed(ctx, "local")
		require.ErrorIs(t, err, context.Canceled)
	})
}

func TestGetWalletInfo(t *testing.T) {
	engine, orch := newSeedTestEngine(t)
	orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&orchpb.ListWalletsResponse{
		Wallets: []*orchpb.WalletMetadata{
			{Id: "a", Name: "Alpha", WalletType: orchpb.WalletType_WALLET_TYPE_ELECTRUM},
			{Id: "b", Name: "Beta", WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE, ScriptType: "taproot", AccountIndex: 3},
		},
		ActiveWalletId: "a",
	}), nil).Times(3)

	info, err := engine.GetWalletInfo(t.Context(), "b")
	require.NoError(t, err)
	require.Equal(t, WalletInfo{ID: "b", Name: "Beta", WalletType: WalletTypeBitcoinCore, ScriptType: "taproot", AccountIndex: 3}, *info)

	active, err := engine.GetActiveWallet(t.Context())
	require.NoError(t, err)
	require.Equal(t, "Alpha", active.Name)

	_, err = engine.GetWalletInfo(t.Context(), "missing")
	require.ErrorContains(t, err, "wallet missing not found")
}

func TestGetWalletInfoWhileLocked(t *testing.T) {
	engine, orch := newSeedTestEngine(t)
	orch.EXPECT().ListWallets(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&orchpb.ListWalletsResponse{ActiveWalletId: "a"}), nil)

	_, err := engine.GetWalletInfo(t.Context(), "a")
	require.ErrorContains(t, err, "no wallet is unlocked")
}

func TestWalletEngineLockState(t *testing.T) {
	status := func(state orchpb.WalletState) *connect.Response[orchpb.GetWalletStatusResponse] {
		return connect.NewResponse(&orchpb.GetWalletStatusResponse{State: state})
	}

	t.Run("the orchestrator state decides", func(t *testing.T) {
		for state, unlocked := range map[orchpb.WalletState]bool{
			orchpb.WalletState_WALLET_STATE_NO_WALLET: false,
			orchpb.WalletState_WALLET_STATE_LOCKED:    false,
			orchpb.WalletState_WALLET_STATE_UNLOCKED:  true,
		} {
			engine, orch := newSeedTestEngine(t)
			orch.EXPECT().GetWalletStatus(gomock.Any(), gomock.Any()).Return(status(state), nil)

			got, err := engine.IsUnlocked(t.Context())
			require.NoError(t, err)
			assert.Equal(t, unlocked, got, state.String())
		}
	})

	t.Run("an orchestrator error is no answer", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().GetWalletStatus(gomock.Any(), gomock.Any()).Return(nil, errors.New("orchestrator down"))

		_, err := engine.IsUnlocked(t.Context())
		require.ErrorContains(t, err, "orchestrator down")
	})

	t.Run("unlock and lock go to the orchestrator", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().UnlockWallet(gomock.Any(), gomock.Any()).DoAndReturn(
			func(_ context.Context, req *connect.Request[orchpb.UnlockWalletRequest]) (*connect.Response[orchpb.UnlockWalletResponse], error) {
				require.Equal(t, "hunter2", req.Msg.Password)
				return connect.NewResponse(&orchpb.UnlockWalletResponse{}), nil
			})
		orch.EXPECT().LockWallet(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&orchpb.LockWalletResponse{}), nil)

		require.NoError(t, engine.Unlock(t.Context(), "hunter2"))
		require.NoError(t, engine.Lock(t.Context()))
	})

	t.Run("a wrong password keeps its code", func(t *testing.T) {
		engine, orch := newSeedTestEngine(t)
		orch.EXPECT().UnlockWallet(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnauthenticated, errors.New("incorrect password")))

		err := engine.Unlock(t.Context(), "wrong")
		require.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
	})
}
