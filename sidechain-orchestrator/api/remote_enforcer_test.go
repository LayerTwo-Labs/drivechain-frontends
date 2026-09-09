package api

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

type ctipValidator struct {
	enforcerrpc.UnimplementedValidatorServiceHandler
	ctip *enforcerpb.GetCtipResponse_Ctip
	err  error
}

func (v ctipValidator) GetCtip(_ context.Context, req *connect.Request[enforcerpb.GetCtipRequest]) (*connect.Response[enforcerpb.GetCtipResponse], error) {
	if req.Msg.GetSidechainNumber().GetValue() != 9 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("wrong sidechain slot"))
	}
	if v.err != nil {
		return nil, v.err
	}
	return connect.NewResponse(&enforcerpb.GetCtipResponse{Ctip: v.ctip}), nil
}

func TestDepositReadsTheEnforcerInBothModes(t *testing.T) {
	for _, mode := range []orchestrator.NodeMode{orchestrator.NodeModeFull, orchestrator.NodeModeLight} {
		t.Run(string(mode), func(t *testing.T) {
			for _, state := range []struct {
				name string
				ctip *enforcerpb.GetCtipResponse_Ctip
				err  error
			}{
				{name: "empty"},
				{name: "funded", ctip: &enforcerpb.GetCtipResponse_Ctip{
					Txid:  &commonpb.ReverseHex{Hex: wrapperspb.String("treasury")},
					Vout:  2,
					Value: 12000,
				}},
				{name: "unavailable", err: connect.NewError(connect.CodeUnavailable, fmt.Errorf("validator is unavailable"))},
			} {
				t.Run(state.name, func(t *testing.T) {
					mux := http.NewServeMux()
					path, handler := enforcerrpc.NewValidatorServiceHandler(ctipValidator{ctip: state.ctip, err: state.err})
					mux.Handle(path, handler)
					server := h2cServer(mux)
					t.Cleanup(server.Close)
					host, port := hostPort(t, server)
					cfg := orchestrator.BinaryConfig{Name: "enforcer", Host: host, Port: port}
					orch := orchestrator.New(t.TempDir(), string(config.NetworkECash), t.TempDir(), []orchestrator.BinaryConfig{cfg}, zerolog.New(io.Discard))
					entry := config.ECashEndpoints()
					t.Cleanup(func() { config.SetECashEndpoints(entry) })
					remote := entry
					remote.Services.Enforcer.URL = server.URL
					config.SetECashEndpoints(remote)
					require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, mode))
					t.Cleanup(func() { require.NoError(t, orch.SetNodeMode(context.Background(), orchestrator.NodeModeFull)) })
					require.Equal(t, mode, orch.NodeMode())

					ctip, err := (&WalletHandler{orch: orch}).sidechainCtip(context.Background(), 9)
					if state.err != nil {
						require.Error(t, err)
						require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
						return
					}
					require.NoError(t, err)
					require.Equal(t, state.ctip.GetTxid().GetHex().GetValue(), ctip.GetTxid().GetHex().GetValue())
					require.Equal(t, state.ctip.GetVout(), ctip.GetVout())
					require.Equal(t, state.ctip.GetValue(), ctip.GetValue())
				})
			}
		})
	}
}

func TestExplorerReadsLocalSidechainsInLightMode(t *testing.T) {
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, err := io.WriteString(w, `{"jsonrpc":"2.0","id":1,"result":42}`)
		if err != nil {
			t.Error(err)
		}
	})
	server := h2cServer(mux)
	t.Cleanup(server.Close)
	host, port := hostPort(t, server)
	for _, name := range []string{"thunder", "bitnames", "bitassets", "photon", "coinshift"} {
		t.Run(name, func(t *testing.T) {
			cfg := orchestrator.BinaryConfig{Name: name, Host: host, Port: port}
			orch := orchestrator.New(t.TempDir(), string(config.NetworkECash), t.TempDir(), []orchestrator.BinaryConfig{cfg}, zerolog.New(io.Discard))
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
			require.Equal(t, orchestrator.NodeModeLight, orch.NodeMode())

			source, err := NewExplorerHandler(orch).sourceFor(name)
			require.NoError(t, err)
			require.Nil(t, source.index)
			require.NotNil(t, source.node)
			count, err := source.node.GetBlockCount(context.Background())
			require.NoError(t, err)
			require.EqualValues(t, 42, count)
		})
	}
}
