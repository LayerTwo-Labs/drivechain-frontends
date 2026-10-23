package commands

import (
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"context"
	"flag"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

type statusTestDaemon struct {
	rpc.UnimplementedWalletManagerServiceHandler
	generated *pb.GenerateWalletRequest
}

func (d *statusTestDaemon) GetWalletStatus(context.Context, *pb.GetWalletStatusRequest) (*pb.GetWalletStatusResponse, error) {
	return &pb.GetWalletStatusResponse{State: pb.WalletState_WALLET_STATE_NO_WALLET}, nil
}

func (d *statusTestDaemon) GenerateWallet(_ context.Context, req *pb.GenerateWalletRequest) (*pb.GenerateWalletResponse, error) {
	d.generated = req
	return &pb.GenerateWalletResponse{WalletId: "new-wallet"}, nil
}

func TestWalletStatusCreatesCoreWalletWhenNoneExists(t *testing.T) {
	daemon := &statusTestDaemon{}
	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterWalletManagerServiceHandler(rpcServer, daemon)
	connecthttp.Mount(mux, rpcServer, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	set := flag.NewFlagSet("status", flag.ContinueOnError)
	set.String("rpcserver", strings.TrimPrefix(server.URL, "http://"), "")
	set.String("bitwindow-dir", t.TempDir(), "")
	cctx := cli.NewContext(&cli.App{Reader: strings.NewReader("\n"), Writer: io.Discard, ErrWriter: io.Discard}, set, nil)
	cctx.Context = context.Background()

	require.NoError(t, walletStatusCommand.Action(cctx))
	require.NotNil(t, daemon.generated)
	require.Equal(t, "Bitcoin Core Wallet", daemon.generated.Name)
}
