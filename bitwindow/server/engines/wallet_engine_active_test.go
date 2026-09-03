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
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

const (
	activeWalletA = "aaaaaaaacafebabe"
	activeWalletB = "bbbbbbbbcafebabe"
	activeSeedA   = "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1"
	activeSeedB   = "b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2"
)

// twoWalletData is the decrypted wallet.json shape: wallets A and B, A active.
func twoWalletData() map[string]any {
	return map[string]any{
		"version":        float64(1),
		"activeWalletId": activeWalletA,
		"wallets": []any{
			map[string]any{
				"id":          activeWalletA,
				"name":        "A",
				"wallet_type": "bitcoinCore",
				"master":      map[string]any{"seed_hex": activeSeedA},
			},
			map[string]any{
				"id":          activeWalletB,
				"name":        "B",
				"wallet_type": "bitcoinCore",
				"master":      map[string]any{"seed_hex": activeSeedB},
			},
		},
	}
}

// unlockedTwoWalletEngine returns an engine unlocked over an encrypted install
// holding both wallets, with A active.
func unlockedTwoWalletEngine(t *testing.T) *WalletEngine {
	t.Helper()

	walletDir := t.TempDir()
	require.NoError(t, os.WriteFile(
		filepath.Join(walletDir, "wallet_encryption.json"),
		[]byte(`{"salt": "c2FsdA==", "iterations": 1, "encrypted": true, "version": "1"}`),
		0o600,
	))

	e := NewWalletEngine(nil, walletDir, &chaincfg.MainNetParams)
	require.NoError(t, e.Unlock(twoWalletData()))
	return e
}

// A switch on the orchestrator must reach an encrypted install, whose active
// wallet id would otherwise stay frozen at the one cached during unlock.
func TestGetActiveWalletFollowsOrchestratorSwitch(t *testing.T) {
	e := unlockedTwoWalletEngine(t)

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(&connect.Response[orchpb.ListWalletsResponse]{
			Msg: &orchpb.ListWalletsResponse{ActiveWalletId: activeWalletB},
		}, nil)
	e.SetOrchestratorClient(orch)

	active, err := e.GetActiveWallet(context.Background())
	require.NoError(t, err)
	require.Equal(t, activeWalletB, active.ID)
}

// An orchestrator that cannot answer leaves the id from unlock in place.
func TestGetActiveWalletKeepsCachedIdOnOrchestratorError(t *testing.T) {
	e := unlockedTwoWalletEngine(t)

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return(nil, errors.New("connection refused"))
	e.SetOrchestratorClient(orch)

	active, err := e.GetActiveWallet(context.Background())
	require.NoError(t, err)
	require.Equal(t, activeWalletA, active.ID)
}

// An unencrypted install reads wallet.json, which the orchestrator rewrites on
// every switch, so it asks no one. The mock fails the test on any call.
func TestGetActiveWalletUnencryptedReadsWalletFile(t *testing.T) {
	walletDir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(walletDir, "wallet.json"), []byte(`{
		"version": 1,
		"activeWalletId": "`+activeWalletA+`",
		"wallets": [
			{"id": "`+activeWalletA+`", "name": "A", "wallet_type": "bitcoinCore", "master": {"seed_hex": "`+activeSeedA+`"}},
			{"id": "`+activeWalletB+`", "name": "B", "wallet_type": "bitcoinCore", "master": {"seed_hex": "`+activeSeedB+`"}}
		]
	}`), 0o600))

	e := NewWalletEngine(nil, walletDir, &chaincfg.MainNetParams)
	e.SetOrchestratorClient(mocks.NewMockWalletManagerServiceClient(gomock.NewController(t)))

	active, err := e.GetActiveWallet(context.Background())
	require.NoError(t, err)
	require.Equal(t, activeWalletA, active.ID)
}
