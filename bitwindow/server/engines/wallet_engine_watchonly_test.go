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
	tests := map[string]error{
		"unavailable": connect.NewError(connect.CodeUnavailable, errors.New("wallet backend warming up")),
		"startup":     connect.NewError(connect.CodeInternal, errors.New("-28: Verifying blocks…")),
	}

	for name, orchErr := range tests {
		t.Run(name, func(t *testing.T) {
			e := NewWalletEngine(nil, nil, t.TempDir(), &chaincfg.MainNetParams)
			e.SetOrchestratorClient(stubOrchWalletClient{err: orchErr})

			_, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
			require.ErrorIs(t, err, orchErr)
		})
	}
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
		}, nil)

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, nil, walletDir, &chaincfg.MainNetParams)

	walletName, err := e.EnsureWatchOnlyWallet(context.Background(), "deadbeefcafebabe")
	require.NoError(t, err)
	require.Equal(t, "wallet_deadbeef", walletName)
}
