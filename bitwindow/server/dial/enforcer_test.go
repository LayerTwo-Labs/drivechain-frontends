package dial

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

type validatorHandler struct {
	rpc.UnimplementedValidatorServiceHandler
}

func (validatorHandler) GetSidechains(context.Context, *pb.GetSidechainsRequest) (*pb.GetSidechainsResponse, error) {
	return &pb.GetSidechainsResponse{}, nil
}

func TestValidatorUsesTheOrchestratorCookie(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)

	mux := http.NewServeMux()
	srv := connect.NewServer(localauth.ServerInterceptor(dir))
	rpc.RegisterValidatorServiceHandler(srv, validatorHandler{})
	connecthttp.Mount(mux, srv, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewUnstartedServer(mux)
	server.Config.Protocols = new(http.Protocols)
	server.Config.Protocols.SetHTTP1(true)
	server.Config.Protocols.SetUnencryptedHTTP2(true)
	server.Start()
	t.Cleanup(server.Close)

	for _, address := range []string{server.URL, strings.TrimPrefix(server.URL, "http://")} {
		client, err := EnforcerValidator(t.Context(), address, dir)
		require.NoError(t, err)
		_, err = client.GetSidechains(t.Context(), &pb.GetSidechainsRequest{})
		require.NoError(t, err)
	}

	_, err = EnforcerValidator(t.Context(), server.URL, "")
	require.ErrorContains(t, err, "unauthenticated")
}
