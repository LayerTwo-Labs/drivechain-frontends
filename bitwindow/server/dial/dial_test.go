package dial

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	walletmanagerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	walletmanagerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func TestEnsureHTTPScheme(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{"bare host:port gets http://", "localhost:30400", "http://localhost:30400"},
		{"http URL passes through", "http://localhost:30400", "http://localhost:30400"},
		{"https URL passes through", "https://orch.example.com", "https://orch.example.com"},
		{"mixed-case scheme passes through", "HTTP://localhost:30400", "HTTP://localhost:30400"},
		{"leading whitespace not normalized", " localhost:30400", "http:// localhost:30400"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := ensureHTTPScheme(tc.in)
			require.Equal(t, tc.want, got)
		})
	}
}

// TestBitcoind_RejectsEmptyAddr is the only behavioral check we can do without
// mocking out connect's transport — empty addr must error rather than silently
// dial nothing.
func TestBitcoind_RejectsEmptyAddr(t *testing.T) {
	_, err := Bitcoind(t.Context(), "", "")
	require.ErrorContains(t, err, "empty orchestrator addr")
}

// TestSharedClientSpeaksH2C guards the transport rewrite: bitwindowd talks to
// the orchestrator over plain TCP, and Connect needs HTTP/2 there.
func TestSharedClientSpeaksH2C(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer listener.Close()

	serverProtocols := new(http.Protocols)
	serverProtocols.SetUnencryptedHTTP2(true)

	server := &http.Server{
		Protocols: serverProtocols,
		Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprint(w, r.Proto)
		}),
	}
	defer server.Close()
	go func() { _ = server.Serve(listener) }()

	response, err := getSharedClient(t.Context()).Get("http://" + listener.Addr().String())
	require.NoError(t, err)
	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	require.NoError(t, err)
	require.Equal(t, "HTTP/2.0", string(body))
}

type fakeSidechain struct{ err error }

func (f *fakeSidechain) Balance(context.Context) (int, error) { return 0, f.err }

func TestDialSidechain(t *testing.T) {
	t.Run("empty host", func(t *testing.T) {
		_, err := dialSidechain(t.Context(), "thunder", "", &fakeSidechain{})
		require.EqualError(t, err, "empty thunder host")
	})
	t.Run("balance fails", func(t *testing.T) {
		cause := errors.New("connection refused")
		_, err := dialSidechain(t.Context(), "photon", "localhost", &fakeSidechain{err: cause})
		require.ErrorIs(t, err, cause)
		require.ErrorContains(t, err, "photon connection test")
	})
	t.Run("ok", func(t *testing.T) {
		want := &fakeSidechain{}
		got, err := dialSidechain(t.Context(), "photon", "localhost", want)
		require.NoError(t, err)
		require.Same(t, want, got)
	})
}

func TestEnforcerDialers_RejectEmptyURL(t *testing.T) {
	t.Run("block producer", func(t *testing.T) {
		_, err := EnforcerBlockProducer(t.Context(), "")
		require.EqualError(t, err, "empty block producer url")
	})
	t.Run("mining", func(t *testing.T) {
		_, err := EnforcerMining(t.Context(), "")
		require.EqualError(t, err, "empty mining url")
	})
	t.Run("crypto", func(t *testing.T) {
		_, err := EnforcerCrypto(t.Context(), "")
		require.EqualError(t, err, "empty crypto url")
	})
}

type restartL1Handler struct {
	orchrpc.UnimplementedOrchestratorServiceHandler
}

func (restartL1Handler) RestartL1(context.Context, *connect.Request[orchpb.RestartL1Request]) (*connect.Response[orchpb.RestartL1Response], error) {
	return connect.NewResponse(&orchpb.RestartL1Response{}), nil
}

func TestOrchestrator(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)

	mux := http.NewServeMux()
	mux.Handle(orchrpc.NewOrchestratorServiceHandler(restartL1Handler{}, connect.WithInterceptors(localauth.Interceptor(dir))))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	t.Run("the cookie authenticates the call", func(t *testing.T) {
		_, err := Orchestrator(server.URL, dir).RestartL1(t.Context(), connect.NewRequest(&orchpb.RestartL1Request{}))
		require.NoError(t, err)
	})

	t.Run("no cookie fails the call", func(t *testing.T) {
		_, err := Orchestrator(server.URL, t.TempDir()).RestartL1(t.Context(), connect.NewRequest(&orchpb.RestartL1Request{}))
		require.ErrorContains(t, err, "unauthenticated")
	})
}

type bitcoinConfHandler struct {
	orchrpc.UnimplementedBitcoinConfServiceHandler
}

func (bitcoinConfHandler) GetBitcoinConfig(context.Context, *connect.Request[orchpb.GetBitcoinConfigRequest]) (*connect.Response[orchpb.GetBitcoinConfigResponse], error) {
	return connect.NewResponse(&orchpb.GetBitcoinConfigResponse{Network: "signet"}), nil
}

func TestBitcoinConf(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)

	mux := http.NewServeMux()
	mux.Handle(orchrpc.NewBitcoinConfServiceHandler(bitcoinConfHandler{}, connect.WithInterceptors(localauth.Interceptor(dir))))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	t.Run("the cookie authenticates the call", func(t *testing.T) {
		resp, err := BitcoinConf(server.URL, dir).GetBitcoinConfig(t.Context(), connect.NewRequest(&orchpb.GetBitcoinConfigRequest{}))
		require.NoError(t, err)
		assert.Equal(t, "signet", resp.Msg.GetNetwork())
	})

	t.Run("no cookie fails the call", func(t *testing.T) {
		_, err := BitcoinConf(server.URL, t.TempDir()).GetBitcoinConfig(t.Context(), connect.NewRequest(&orchpb.GetBitcoinConfigRequest{}))
		require.ErrorContains(t, err, "unauthenticated")
	})
}

type walletManagerHandler struct {
	walletmanagerrpc.UnimplementedWalletManagerServiceHandler
}

func (walletManagerHandler) GetNodeMode(context.Context, *connect.Request[walletmanagerpb.GetNodeModeRequest]) (*connect.Response[walletmanagerpb.GetNodeModeResponse], error) {
	return connect.NewResponse(&walletmanagerpb.GetNodeModeResponse{Mode: walletmanagerpb.NodeMode_NODE_MODE_FULL}), nil
}

func TestWalletManager(t *testing.T) {
	dir := t.TempDir()
	_, err := localauth.WriteCookie(dir)
	require.NoError(t, err)

	mux := http.NewServeMux()
	mux.Handle(walletmanagerrpc.NewWalletManagerServiceHandler(walletManagerHandler{}, connect.WithInterceptors(localauth.Interceptor(dir))))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	t.Run("the cookie authenticates the call", func(t *testing.T) {
		resp, err := WalletManager(server.URL, dir).GetNodeMode(t.Context(), connect.NewRequest(&walletmanagerpb.GetNodeModeRequest{}))
		require.NoError(t, err)
		assert.Equal(t, walletmanagerpb.NodeMode_NODE_MODE_FULL, resp.Msg.GetMode())
	})

	t.Run("no cookie fails the call", func(t *testing.T) {
		_, err := WalletManager(server.URL, t.TempDir()).GetNodeMode(t.Context(), connect.NewRequest(&walletmanagerpb.GetNodeModeRequest{}))
		require.ErrorContains(t, err, "unauthenticated")
	})
}
