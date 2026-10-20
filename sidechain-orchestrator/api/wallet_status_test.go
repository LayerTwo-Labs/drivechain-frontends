package api

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
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
		resp, err := h.GetWalletStatus(ctx, &pb.GetWalletStatusRequest{})
		require.NoError(t, err)
		return resp
	}
	unlock := func(password string) connect.Code {
		_, err := h.UnlockWallet(ctx, &pb.UnlockWalletRequest{Password: password})
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
	_, err = h.UnlockWallet(ctx, &pb.UnlockWalletRequest{Password: "pass"})
	require.NoError(t, err)
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, status().State)
}

func TestWalletPasswordCodes(t *testing.T) {
	for _, test := range []struct {
		name string
		call func(*WalletHandler, string) error
	}{
		{"unlock", func(h *WalletHandler, password string) error {
			_, err := h.UnlockWallet(t.Context(), &pb.UnlockWalletRequest{Password: password})
			return err
		}},
		{"change password", func(h *WalletHandler, password string) error {
			_, err := h.ChangePassword(t.Context(), &pb.ChangePasswordRequest{
				OldPassword: password,
				NewPassword: "newpass",
			})
			return err
		}},
		{"remove encryption", func(h *WalletHandler, password string) error {
			_, err := h.RemoveEncryption(t.Context(), &pb.RemoveEncryptionRequest{Password: password})
			return err
		}},
	} {
		t.Run(test.name, func(t *testing.T) {
			svc := wallet.NewService(t.TempDir(), zerolog.Nop())
			require.NoError(t, svc.Init())
			t.Cleanup(svc.Close)
			_, err := svc.GenerateWallet("Password", "", "", nil)
			require.NoError(t, err)
			h := NewWalletHandler(svc)

			err = test.call(h, "pass")
			require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
			require.ErrorIs(t, err, wallet.ErrNotEncrypted)

			require.NoError(t, svc.EncryptWallet("pass"))
			svc.LockWallet()

			err = test.call(h, "wrong")
			require.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
			require.ErrorIs(t, err, wallet.ErrIncorrectPassword)
			require.Equal(t, wallet.StateLocked, svc.State())
			require.True(t, svc.IsEncrypted())

			require.NoError(t, test.call(h, "pass"))
		})
	}
}

func TestChangePasswordFileError(t *testing.T) {
	dir := t.TempDir()
	svc := wallet.NewService(dir, zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	_, err := svc.GenerateWallet("Password", "", "", nil)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet("oldpass"))
	svc.LockWallet()

	metaPath := filepath.Join(dir, "wallet_encryption.json")
	require.NoError(t, os.Chmod(metaPath, 0400))
	require.NoError(t, os.Mkdir(metaPath+".tmp", 0700))

	_, err = NewWalletHandler(svc).ChangePassword(t.Context(), &pb.ChangePasswordRequest{
		OldPassword: "oldpass",
		NewPassword: "newpass",
	})
	require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	require.ErrorContains(t, err, "write encryption metadata")
	var pathErr *os.PathError
	require.ErrorAs(t, err, &pathErr)
	require.NoError(t, svc.UnlockWallet("oldpass"))
	require.Equal(t, "Password", svc.ActiveWalletName())
}

func TestLockSendsALockedFrame(t *testing.T) {
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	_, err := svc.GenerateWallet("Lock", "", "", nil)
	require.NoError(t, err)
	require.NoError(t, svc.EncryptWallet("pass"))

	mux := http.NewServeMux()
	srv := connect.NewServer()
	rpc.RegisterWalletManagerServiceHandler(srv, NewWalletHandler(svc))
	connecthttp.Mount(mux, srv, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	client := rpc.NewWalletManagerServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	stream, err := client.WatchWalletData(ctx, &emptypb.Empty{})
	require.NoError(t, err)
	t.Cleanup(func() { _ = stream.Close() })

	response, err := stream.Receive()
	require.NoError(t, err)
	require.Equal(t, pb.WalletState_WALLET_STATE_UNLOCKED, response.State)

	svc.LockWallet()

	var streamErr error
	for {
		msg, err := stream.Receive()
		if err != nil {
			streamErr = err
			break
		}
		if msg.Heartbeat {
			continue
		}
		require.Equal(t, pb.WalletState_WALLET_STATE_LOCKED, msg.State)
		require.Empty(t, msg.Wallets)
		return
	}
	if errors.Is(streamErr, io.EOF) {
		streamErr = nil
	}
	t.Fatalf("no frame after the lock: %v", streamErr)
}
