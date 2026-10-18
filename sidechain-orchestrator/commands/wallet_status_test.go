package commands

import (
	"context"
	"flag"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

type statusTestDaemon struct {
	rpc.UnimplementedWalletManagerServiceHandler
	generated *pb.GenerateWalletRequest
}

func (d *statusTestDaemon) GetWalletStatus(context.Context, *connect.Request[pb.GetWalletStatusRequest]) (*connect.Response[pb.GetWalletStatusResponse], error) {
	return connect.NewResponse(&pb.GetWalletStatusResponse{State: pb.WalletState_WALLET_STATE_NO_WALLET}), nil
}

func (d *statusTestDaemon) GenerateWallet(_ context.Context, req *connect.Request[pb.GenerateWalletRequest]) (*connect.Response[pb.GenerateWalletResponse], error) {
	d.generated = req.Msg
	return connect.NewResponse(&pb.GenerateWalletResponse{WalletId: "new-wallet"}), nil
}

func TestWalletStatusCreatesCoreWalletWhenNoneExists(t *testing.T) {
	daemon := &statusTestDaemon{}
	mux := http.NewServeMux()
	path, handler := rpc.NewWalletManagerServiceHandler(daemon)
	mux.Handle(path, handler)
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	stdin, err := os.CreateTemp(t.TempDir(), "stdin")
	require.NoError(t, err)
	_, err = stdin.WriteString("y\n")
	require.NoError(t, err)
	_, err = stdin.Seek(0, io.SeekStart)
	require.NoError(t, err)
	oldStdin := os.Stdin
	os.Stdin = stdin
	t.Cleanup(func() { os.Stdin = oldStdin })

	set := flag.NewFlagSet("status", flag.ContinueOnError)
	set.String("rpcserver", strings.TrimPrefix(server.URL, "http://"), "")
	set.String("bitwindow-dir", t.TempDir(), "")
	cctx := cli.NewContext(&cli.App{Writer: io.Discard, ErrWriter: io.Discard}, set, nil)
	cctx.Context = context.Background()

	require.NoError(t, walletStatusCommand.Action(cctx))
	require.NotNil(t, daemon.generated)
	require.Equal(t, "Bitcoin Core Wallet", daemon.generated.Name)
}
