package daemon

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
)

type confStub struct {
	rpc.UnimplementedBitcoinConfServiceHandler
}

func (confStub) GetBitcoinConfig(context.Context, *pb.GetBitcoinConfigRequest) (*pb.GetBitcoinConfigResponse, error) {
	return &pb.GetBitcoinConfigResponse{Network: "regtest", ConfigContent: strings.Repeat("rpcport=18443\n", 100)}, nil
}

func postAcceptingGzip(t *testing.T, url, body string) *http.Response {
	t.Helper()
	req, err := http.NewRequest(http.MethodPost, url, strings.NewReader(body))
	require.NoError(t, err)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Encoding", "gzip")
	transport := &http.Transport{DisableCompression: true}
	resp, err := transport.RoundTrip(req)
	require.NoError(t, err)
	t.Cleanup(func() { _ = resp.Body.Close() })
	return resp
}

func TestMountedHandlersSendUncompressedResponses(t *testing.T) {
	server := connect.NewServer()
	rpc.RegisterBitcoinConfServiceHandler(server, confStub{})
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server, mountOptions()...)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	resp := postAcceptingGzip(t, srv.URL+"/orchestrator.v1.BitcoinConfService/GetBitcoinConfig", "{}")
	require.Equal(t, http.StatusOK, resp.StatusCode)
	require.Empty(t, resp.Header.Get("Content-Encoding"))
}

func TestCoreProxySendsUncompressedResponses(t *testing.T) {
	core := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"result":[{"txid":"` + strings.Repeat("ab", 32) + `","vout":0,"amount":1}],"error":null,"id":1}`))
	}))
	t.Cleanup(core.Close)

	ctx := context.Background()
	proxy, err := coreproxy.NewBitcoind(ctx, strings.TrimPrefix(core.URL, "http://"), "user", "pass",
		coreproxy.WithoutInitialConnectionCheck())
	require.NoError(t, err)
	t.Cleanup(func() { proxy.Shutdown(ctx) })

	path, h := corerpc.NewBitcoinServiceHandler(proxy, coreProxyHandlerOptions())
	mux := http.NewServeMux()
	mux.Handle(path, h)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	resp := postAcceptingGzip(t, srv.URL+path+"ListUnspent", `{"wallet":"w"}`)
	require.Equal(t, http.StatusOK, resp.StatusCode)
	require.Empty(t, resp.Header.Get("Content-Encoding"))
}
