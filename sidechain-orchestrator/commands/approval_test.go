package commands

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	orpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

type approvalTestServer struct {
	rpc.UnimplementedWalletManagerServiceHandler
	sendCalls   int
	deleteCalls int
}

func (s *approvalTestServer) SendTransaction(context.Context, *pb.SendTransactionRequest) (*pb.SendTransactionResponse, error) {
	s.sendCalls++
	return &pb.SendTransactionResponse{Txid: "sent"}, nil
}

func (s *approvalTestServer) DeleteAllWallets(context.Context, *pb.DeleteAllWalletsRequest) (*pb.DeleteAllWalletsResponse, error) {
	s.deleteCalls++
	return &pb.DeleteAllWalletsResponse{}, nil
}

func TestCommandsUseExplicitApproval(t *testing.T) {
	for _, command := range []struct {
		name string
		args []string
	}{
		{"send", []string{"wallet", "send", "--to", "recipient", "--sats", "1000", "wallet-id"}},
		{"delete", []string{"wallet", "delete", "--all"}},
		{"reset", []string{"reset", "run", "--logs"}},
	} {
		for _, answer := range []struct {
			name     string
			text     string
			approved bool
		}{
			{"empty", "\n", false},
			{"spaces", " \t\n", false},
			{"no", "n\n", false},
			{"eof", "", false},
			{"partial", "yes", false},
			{"yes", "y\n", true},
			{"word", "YES\n", true},
		} {
			t.Run(command.name+"/"+answer.name, func(t *testing.T) {
				walletServer := &approvalTestServer{}
				resetServer := &resetTestServer{}
				server := connect.NewServer()
				rpc.RegisterWalletManagerServiceHandler(server, walletServer)
				orpc.RegisterOrchestratorServiceHandler(server, resetServer)
				mux := http.NewServeMux()
				connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
				httpServer := httptest.NewServer(mux)
				t.Cleanup(httpServer.Close)
				app := &cli.App{
					Flags: GlobalFlags, Commands: Commands(), Reader: strings.NewReader(answer.text),
					Writer: io.Discard, ErrWriter: io.Discard,
				}
				args := []string{"drivechain-cli", "--rpcserver", strings.TrimPrefix(httpServer.URL, "http://"), "--bitwindow-dir", t.TempDir()}
				err := app.RunContext(t.Context(), append(args, command.args...))
				calls := walletServer.sendCalls + walletServer.deleteCalls + resetServer.deleteCalls
				if answer.approved {
					require.NoError(t, err)
					require.Equal(t, 1, calls)
				} else {
					require.Error(t, err)
					require.Zero(t, calls)
				}
			})
		}
	}
}

func TestReadApprovalKeepsThePromptDefault(t *testing.T) {
	for _, defaultYes := range []bool{false, true} {
		approved, err := readApproval(strings.NewReader("\n"), defaultYes)
		require.NoError(t, err)
		require.Equal(t, defaultYes, approved)
		approved, err = readApproval(strings.NewReader(""), defaultYes)
		require.ErrorIs(t, err, io.EOF)
		require.False(t, approved)
	}
}
