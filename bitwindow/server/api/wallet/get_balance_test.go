package api_wallet

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// A locked wallet must not hand out balances.
func TestGetBalanceRejectsLockedWallet(t *testing.T) {
	const walletID = "80CEBA2163224572BDEADD2D2181C51B"

	tempDir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": walletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": testSeedHex},
			"id":          walletID,
			"name":        "test",
			"wallet_type": "electrum",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(tempDir, "wallet.json"), walletData, 0o600))

	walletEngine := engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		tempDir,
		&chaincfg.SigNetParams,
	)
	walletEngine.Lock()

	server := &Server{walletEngine: walletEngine}

	_, err = server.GetBalance(context.Background(), connect.NewRequest(&pb.GetBalanceRequest{
		WalletId: walletID,
	}))
	require.Error(t, err)
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
}
