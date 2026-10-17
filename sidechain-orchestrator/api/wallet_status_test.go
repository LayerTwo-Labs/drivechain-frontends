package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestWalletStatusAndUnlockCodes(t *testing.T) {
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
	unlock := func(password string) connect.Code {
		_, err := h.UnlockWallet(ctx, connect.NewRequest(&pb.UnlockWalletRequest{Password: password}))
		return connect.CodeOf(err)
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
	require.Equal(t, connect.CodeFailedPrecondition, unlock("any"))

	require.NoError(t, svc.EncryptWallet("pass"))
	svc.LockWallet()
	s = status()
	require.Equal(t, pb.WalletState_WALLET_STATE_LOCKED, s.State)
	require.True(t, s.HasWallet) //nolint:staticcheck // old apps read it
	require.False(t, s.Unlocked) //nolint:staticcheck // old apps read it

	require.Equal(t, connect.CodeUnauthenticated, unlock("wrong"))
	_, err = h.UnlockWallet(ctx, connect.NewRequest(&pb.UnlockWalletRequest{Password: "pass"}))
	require.NoError(t, err)
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, status().State)
}

func TestLockSendsALockedFrame(t *testing.T) {
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	_, err := svc.GenerateWallet("Lock", "", "", nil)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet("pass"))

	mux := http.NewServeMux()
	mux.Handle(rpc.NewWalletManagerServiceHandler(NewWalletHandler(svc)))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	client := rpc.NewWalletManagerServiceClient(server.Client(), server.URL)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	stream, err := client.WatchWalletData(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	t.Cleanup(func() { _ = stream.Close() })

	require.True(t, stream.Receive(), stream.Err())
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, stream.Msg().State)

	svc.LockWallet()

	for stream.Receive() {
		if stream.Msg().Heartbeat {
			continue
		}
		require.Equal(t, pb.WalletState_WALLET_STATE_LOCKED, stream.Msg().State)
		require.Empty(t, stream.Msg().Wallets)
		return
	}
	t.Fatalf("no frame after the lock: %v", stream.Err())
}
