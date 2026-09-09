package dial

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/stretchr/testify/require"
)

type validatorHandler struct {
	rpc.UnimplementedValidatorServiceHandler
}

func (validatorHandler) GetSidechains(context.Context, *connect.Request[pb.GetSidechainsRequest]) (*connect.Response[pb.GetSidechainsResponse], error) {
	return connect.NewResponse(&pb.GetSidechainsResponse{}), nil
}

func TestValidatorUsesTheOrchestratorCookie(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)
	previous := cookieDir
	SetCookieDir(dir)
	t.Cleanup(func() { SetCookieDir(previous) })

	mux := http.NewServeMux()
	path, handler := rpc.NewValidatorServiceHandler(validatorHandler{}, connect.WithInterceptors(localauth.Interceptor(dir)))
	mux.Handle(path, handler)
	server := httptest.NewUnstartedServer(mux)
	server.Config.Protocols = new(http.Protocols)
	server.Config.Protocols.SetHTTP1(true)
	server.Config.Protocols.SetUnencryptedHTTP2(true)
	server.Start()
	t.Cleanup(server.Close)

	for _, address := range []string{server.URL, strings.TrimPrefix(server.URL, "http://")} {
		client, err := EnforcerValidator(t.Context(), address)
		require.NoError(t, err)
		_, err = client.GetSidechains(t.Context(), connect.NewRequest(&pb.GetSidechainsRequest{}))
		require.NoError(t, err)
	}

	SetCookieDir("")
	_, err = EnforcerValidator(t.Context(), server.URL)
	require.Error(t, err)
	require.Contains(t, err.Error(), "unauthenticated")
}
