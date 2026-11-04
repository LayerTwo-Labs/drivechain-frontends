package thunder

import (
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

func thunderClientFor(t *testing.T, proxy *sidechain.JSONRPCProxy) svc.ThunderServiceClient {
	t.Helper()
	server := connect.NewServer(sidechain.KeepErrorText())
	svc.RegisterThunderServiceHandler(server, NewHandler(proxy))
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	httpServer := httptest.NewServer(mux)
	t.Cleanup(httpServer.Close)
	return svc.NewThunderServiceClient(connect.NewClient(connecthttp.NewTransport(httpServer.Client(), httpServer.URL)))
}

func closedPortProxy(t *testing.T) *sidechain.JSONRPCProxy {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())
	return sidechain.NewJSONRPCProxy("127.0.0.1", port)
}

func rpcErrorProxy(t *testing.T, body string) *sidechain.JSONRPCProxy {
	t.Helper()
	node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(node.Close)
	u, err := url.Parse(node.URL)
	require.NoError(t, err)
	port, err := strconv.Atoi(u.Port())
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(u.Hostname(), port)
}

func callTransferAndUtxos(t *testing.T, client svc.ThunderServiceClient) map[string]error {
	t.Helper()
	_, transferErr := client.Transfer(t.Context(), &pb.TransferRequest{Address: "addr", AmountSats: 1000, FeeSats: 1000})
	_, utxosErr := client.GetWalletUtxos(t.Context(), &pb.GetWalletUtxosRequest{})
	return map[string]error{"Transfer": transferErr, "GetWalletUtxos": utxosErr}
}

func TestHandlerErrorsReachTheClientWhenTheNodeRefusesTheConnection(t *testing.T) {
	client := thunderClientFor(t, closedPortProxy(t))

	for method, err := range callTransferAndUtxos(t, client) {
		t.Run(method, func(t *testing.T) {
			cerr, ok := errors.AsType[*connect.Error](err)
			require.True(t, ok, "error %v", err)
			assert.Equal(t, connect.CodeUnavailable, cerr.Code())
			assert.Contains(t, cerr.Message(), "connection refused")
		})
	}
}

func TestHandlerErrorsReachTheClientWhenTheNodeSendsAnRPCError(t *testing.T) {
	proxy := rpcErrorProxy(t, `{"jsonrpc":"2.0","id":1,"error":{"code":-32000,"message":"wallet has insufficient funds"}}`)
	client := thunderClientFor(t, proxy)

	for method, err := range callTransferAndUtxos(t, client) {
		t.Run(method, func(t *testing.T) {
			cerr, ok := errors.AsType[*connect.Error](err)
			require.True(t, ok, "error %v", err)
			assert.Equal(t, connect.CodeUnknown, cerr.Code())
			assert.Contains(t, cerr.Message(), "rpc error -32000: wallet has insufficient funds")
		})
	}
}
