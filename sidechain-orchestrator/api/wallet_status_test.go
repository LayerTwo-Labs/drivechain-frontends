package api

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestWalletStatus(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	h := NewWalletHandler(svc)

	status := func() *pb.GetWalletStatusResponse {
		t.Helper()
		resp, err := h.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		require.NoError(t, err)
		return resp.Msg
	}

	s := status()
	require.Equal(t, pb.WalletState_WALLET_STATE_NO_WALLET, s.State)
	require.False(t, s.HasWallet) //nolint:staticcheck // old apps read it
	require.False(t, s.Unlocked)  //nolint:staticcheck // old apps read it

	_, err := svc.GenerateWallet("Status", "", "", nil)
	require.NoError(t, err)
	s = status()
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, s.State)
	require.True(t, s.HasWallet) //nolint:staticcheck // old apps read it
	require.True(t, s.Unlocked)  //nolint:staticcheck // old apps read it

	require.NoError(t, svc.EncryptWallet("pass"))
	svc.LockWallet()
	s = status()
	require.Equal(t, pb.WalletState_WALLET_STATE_LOCKED, s.State)
	require.True(t, s.HasWallet) //nolint:staticcheck // old apps read it
	require.False(t, s.Unlocked) //nolint:staticcheck // old apps read it

	_, err = h.UnlockWallet(ctx, connect.NewRequest(&pb.UnlockWalletRequest{Password: "pass"}))
	require.NoError(t, err)
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, status().State)
}
