package engines

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// mustReturn fails the test if fn is still running after 3s.
func mustReturn(t *testing.T, fn func()) {
	t.Helper()

	done := make(chan struct{})
	go func() {
		defer close(done)
		fn()
	}()

	select {
	case <-done:
	case <-time.After(3 * time.Second):
		t.Fatal("call did not return, engine deadlocked")
	}
}

// An encrypted wallet resolves its info from the cache under a read lock, which
// the ensure paths used to take while already holding the write lock.
func TestEnsureWalletsEncryptedDoesNotDeadlock(t *testing.T) {
	walletDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet_encryption.json"), []byte(`{
		"encrypted": true,
		"salt": "c2FsdA==",
		"iterations": 1000
	}`), 0o600))

	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{Wallets: []string{"wallet_deadbeef", "wallet_feedface"}},
		}, nil).
		AnyTimes()
	// No wallet from before the rename, so the local name applies.
	mockBitcoind.EXPECT().
		LoadWallet(gomock.Any(), gomock.Any()).
		Return(nil, errors.New("Wallet file verification failed. Path does not exist.")).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, walletDir, &chaincfg.MainNetParams)

	require.NoError(t, e.Unlock(map[string]any{
		"version":        1,
		"activeWalletId": "deadbeefcafebabe",
		"wallets": []any{
			map[string]any{
				"id":          "deadbeefcafebabe",
				"name":        "spender",
				"wallet_type": "bitcoinCore",
				"master":      map[string]any{"seed_hex": "000102030405060708090a0b0c0d0e0f"},
			},
			map[string]any{
				"id":          "feedfacedeadbeef",
				"name":        "watcher",
				"wallet_type": "bitcoinCore",
				"master":      map[string]any{"seed_hex": ""},
				"watch_only": map[string]any{
					"xpub": "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj",
				},
			},
		},
	}))

	t.Run("bitcoin core", func(t *testing.T) {
		var walletName string
		var err error
		mustReturn(t, func() {
			walletName, err = e.EnsureBitcoinCoreWallet(context.Background(), "deadbeefcafebabe")
		})
		require.NoError(t, err)
		require.Equal(t, "wallet_deadbeef", walletName)
	})

	t.Run("watch-only", func(t *testing.T) {
		var walletName string
		var err error
		mustReturn(t, func() {
			walletName, err = e.EnsureWatchOnlyWallet(context.Background(), "feedfacedeadbeef")
		})
		require.NoError(t, err)
		require.Equal(t, "wallet_feedface", walletName)
	})
}
