package engines

import (
	"context"
	"encoding/hex"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// recordingSendClient records every SendTransaction that reaches the orchestrator.
type recordingSendClient struct {
	orchrpc.WalletManagerServiceClient
	sent []*orchpb.SendTransactionRequest
}

func (c *recordingSendClient) SendTransaction(_ context.Context, req *connect.Request[orchpb.SendTransactionRequest]) (*connect.Response[orchpb.SendTransactionResponse], error) {
	c.sent = append(c.sent, req.Msg)
	return connect.NewResponse(&orchpb.SendTransactionResponse{Txid: "txid"}), nil
}

// An unencrypted wallet auto-unlocks at startup and GetActiveWallet reads
// wallet.json regardless of the lock, so BroadcastOpReturn has to refuse the
// spend itself after Lock.
func TestBroadcastOpReturnRefusesLockedWallet(t *testing.T) {
	walletDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(`{
		"version": 1,
		"activeWalletId": "deadbeefcafebabe",
		"wallets": [{
			"id": "deadbeefcafebabe",
			"name": "spender",
			"wallet_type": "electrum",
			"master": {"seed_hex": "000102030405060708090a0b0c0d0e0f"}
		}]
	}`), 0o600))

	orch := &recordingSendClient{}
	e := NewWalletEngine(nil, walletDir, &chaincfg.MainNetParams)
	e.SetOrchestratorClient(orch)
	require.True(t, e.IsUnlocked())

	e.Lock()

	_, err := e.BroadcastOpReturn(context.Background(), []byte("news"), 5, 0)
	require.ErrorContains(t, err, "wallet is locked")
	require.Empty(t, orch.sent)

	// Positive control: unlocking again lets the payload through.
	walletData, err := wallet.LoadUnencryptedWallet(walletDir)
	require.NoError(t, err)
	require.NoError(t, e.Unlock(walletData))

	txid, err := e.BroadcastOpReturn(context.Background(), []byte("news"), 5, 0)
	require.NoError(t, err)
	require.Equal(t, "txid", txid)
	require.Len(t, orch.sent, 1)
	require.Equal(t, hex.EncodeToString([]byte("news")), orch.sent[0].OpReturnHex)
}
