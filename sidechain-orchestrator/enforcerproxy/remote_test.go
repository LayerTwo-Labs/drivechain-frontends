package enforcerproxy

import (
	"bytes"
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/http/httputil"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	"golang.org/x/net/http2"
)

func testClient(t *testing.T) *http.Client {
	t.Helper()
	transport := &http2.Transport{
		AllowHTTP: true,
		DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
			var dialer net.Dialer
			return dialer.DialContext(ctx, network, addr)
		},
	}
	t.Cleanup(transport.CloseIdleConnections)
	return &http.Client{Transport: transport, Timeout: 5 * time.Second}
}

func testServer(handler http.Handler) *httptest.Server {
	server := httptest.NewUnstartedServer(handler)
	server.Config.Protocols = &http.Protocols{}
	server.Config.Protocols.SetHTTP1(true)
	server.Config.Protocols.SetUnencryptedHTTP2(true)
	server.Start()
	return server
}

func TestRemoteForwardsTLSAndTrailers(t *testing.T) {
	frame := []byte{0, 0, 0, 0, 0}
	upstream := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, "/enforcer/cusf.mainchain.v1.ValidatorService/GetChainTip", r.URL.Path)
		require.Equal(t, 2, r.ProtoMajor)
		require.NotNil(t, r.TLS)
		require.Empty(t, r.Header.Get("Authorization"))
		require.Empty(t, r.Header.Get("Cookie"))
		body, err := io.ReadAll(r.Body)
		require.NoError(t, err)
		require.Equal(t, frame, body)
		w.Header().Set("Content-Type", "application/grpc")
		w.Header().Set("Trailer", "Grpc-Status")
		_, err = w.Write(frame)
		require.NoError(t, err)
		w.Header().Set("Grpc-Status", "0")
	}))
	upstream.EnableHTTP2 = true
	upstream.StartTLS()
	defer upstream.Close()

	proxy, err := Connect(upstream.URL + "/enforcer")
	require.NoError(t, err)
	roots := x509.NewCertPool()
	roots.AddCert(upstream.Certificate())
	proxy.(*httputil.ReverseProxy).Transport.(*http2.Transport).TLSClientConfig = &tls.Config{RootCAs: roots}
	remote, err := newRemote(proxy)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, remote.Close()) })

	request, err := http.NewRequest(http.MethodPost, remote.URL()+"/cusf.mainchain.v1.ValidatorService/GetChainTip", bytes.NewReader(frame))
	require.NoError(t, err)
	request.Header.Set("Content-Type", "application/grpc")
	request.Header.Set("Authorization", "Bearer test-local-wallet-token")
	request.Header.Set("Cookie", "session=test-local-session")
	response, err := testClient(t).Do(request)
	require.NoError(t, err)
	defer func() { require.NoError(t, response.Body.Close()) }()
	body, err := io.ReadAll(response.Body)
	require.NoError(t, err)
	require.Equal(t, http.StatusOK, response.StatusCode)
	require.Equal(t, frame, body)
	require.Equal(t, "0", response.Trailer.Get("Grpc-Status"))
}

func TestRemoteBlocksAdminMethods(t *testing.T) {
	upstream := testServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		t.Error("the proxy sent a blocked method upstream")
		w.WriteHeader(http.StatusOK)
	}))
	defer upstream.Close()
	remote, err := NewRemote(upstream.URL)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, remote.Close()) })

	for _, path := range []string{
		"/cusf.mainchain.v1.ValidatorService/Stop",
		"/cusf.mainchain.v1.WalletService/SendTransaction",
		"/cusf.mainchain.v1.BlockProducerService/ProposeSidechain",
		"/cusf.mainchain.v1.MiningService/GenerateBlocks",
		"/cusf.mainchain.v1.ValidatorService/GetUnknown",
	} {
		t.Run(path, func(t *testing.T) {
			response, err := testClient(t).Post(remote.URL()+path, "application/grpc", strings.NewReader("probe"))
			require.NoError(t, err)
			require.Equal(t, http.StatusForbidden, response.StatusCode)
			require.NoError(t, response.Body.Close())
		})
	}
}

func TestRemoteCloseStopsSubscriptions(t *testing.T) {
	cancelled := make(chan struct{})
	release := make(chan struct{})
	upstream := testServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/grpc")
		_, err := w.Write([]byte{0, 0, 0, 0, 0})
		require.NoError(t, err)
		w.(http.Flusher).Flush()
		select {
		case <-r.Context().Done():
			close(cancelled)
		case <-release:
		}
	}))
	defer upstream.Close()
	defer close(release)
	remote, err := NewRemote(upstream.URL)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, remote.Close()) })
	response, err := testClient(t).Post(remote.URL()+"/cusf.mainchain.v1.ValidatorService/SubscribeEvents", "application/grpc", nil)
	require.NoError(t, err)
	defer func() { require.NoError(t, response.Body.Close()) }()
	frame := make([]byte, 5)
	_, err = io.ReadFull(response.Body, frame)
	require.NoError(t, err)
	require.NoError(t, remote.Close())
	select {
	case <-cancelled:
	case <-time.After(time.Second):
		t.Fatal("the upstream subscription stayed open after bridge close")
	}
}

func TestRemoteSetUpstreamKeepsOldStreamUntilClose(t *testing.T) {
	nextFrame := make(chan struct{})
	cancelled := make(chan struct{})
	release := make(chan struct{})
	first := testServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/grpc")
		_, err := w.Write([]byte{0, 0, 0, 0, 0})
		require.NoError(t, err)
		w.(http.Flusher).Flush()
		select {
		case <-nextFrame:
			_, err = w.Write([]byte{0, 0, 0, 0, 0})
			require.NoError(t, err)
			w.(http.Flusher).Flush()
		case <-r.Context().Done():
		case <-release:
			return
		}
		select {
		case <-r.Context().Done():
			close(cancelled)
		case <-release:
		}
	}))
	defer first.Close()
	defer close(release)
	second := testServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, err := io.WriteString(w, "second")
		require.NoError(t, err)
	}))
	defer second.Close()
	remote, err := NewRemote(first.URL)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, remote.Close()) })
	endpoint := remote.URL()
	client := testClient(t)
	stream, err := client.Post(endpoint+"/cusf.mainchain.v1.ValidatorService/SubscribeEvents", "application/grpc", nil)
	require.NoError(t, err)
	defer func() { require.NoError(t, stream.Body.Close()) }()
	frame := make([]byte, 5)
	_, err = io.ReadFull(stream.Body, frame)
	require.NoError(t, err)

	require.NoError(t, remote.SetUpstream(second.URL))
	require.Equal(t, endpoint, remote.URL())
	close(nextFrame)
	_, err = io.ReadFull(stream.Body, frame)
	require.NoError(t, err)
	require.Equal(t, []byte{0, 0, 0, 0, 0}, frame)
	response, err := client.Post(endpoint+"/cusf.mainchain.v1.ValidatorService/GetChainTip", "application/grpc", nil)
	require.NoError(t, err)
	body, err := io.ReadAll(response.Body)
	require.NoError(t, err)
	require.NoError(t, response.Body.Close())
	require.Equal(t, "second", string(body))
	blocked, err := client.Post(endpoint+"/cusf.mainchain.v1.WalletService/SendTransaction", "application/grpc", nil)
	require.NoError(t, err)
	require.NoError(t, blocked.Body.Close())
	require.Equal(t, http.StatusForbidden, blocked.StatusCode)

	require.NoError(t, remote.Close())
	select {
	case <-cancelled:
	case <-time.After(time.Second):
		t.Fatal("the old subscription stayed open after bridge close")
	}
	require.ErrorIs(t, remote.SetUpstream(second.URL), net.ErrClosed)
}

func TestRemoteSetUpstreamDuringRequests(t *testing.T) {
	requests := make(chan struct{}, 32)
	server := func(body string) *httptest.Server {
		return testServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			_, err := io.WriteString(w, body)
			require.NoError(t, err)
			requests <- struct{}{}
		}))
	}
	first, second := server("first"), server("second")
	defer first.Close()
	defer second.Close()
	remote, err := NewRemote(first.URL)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, remote.Close()) })
	client := testClient(t)
	var wg sync.WaitGroup
	for range 4 {
		wg.Go(func() {
			for range 8 {
				response, err := client.Post(remote.URL()+"/cusf.mainchain.v1.ValidatorService/GetChainTip", "application/grpc", nil)
				require.NoError(t, err)
				body, err := io.ReadAll(response.Body)
				require.NoError(t, err)
				require.NoError(t, response.Body.Close())
				require.Contains(t, []string{"first", "second"}, string(body))
			}
		})
	}
	for range 8 {
		select {
		case <-requests:
		case <-time.After(5 * time.Second):
			t.Fatal("the validator request did not arrive")
		}
		require.NoError(t, remote.SetUpstream(second.URL))
		require.NoError(t, remote.SetUpstream(first.URL))
	}
	wg.Wait()
}

func TestConnectDynamicChangesEndpoint(t *testing.T) {
	server := func(body string) *httptest.Server {
		return testServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			_, err := io.WriteString(w, body)
			require.NoError(t, err)
		}))
	}
	first, second := server("first"), server("second")
	defer first.Close()
	defer second.Close()
	url := first.URL
	var resolveErr error
	handler := ConnectDynamic(func() (string, error) { return url, resolveErr })
	for _, test := range []struct {
		url  string
		body string
	}{
		{first.URL, "first"},
		{second.URL, "second"},
	} {
		url = test.url
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, httptest.NewRequest(http.MethodPost, "/service/method", nil))
		require.Equal(t, http.StatusOK, response.Code)
		require.Equal(t, test.body, response.Body.String())
	}
	resolveErr = errors.New("no remote enforcer for this network")
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodPost, "/service/method", nil))
	require.Equal(t, http.StatusServiceUnavailable, response.Code)
}

func TestConnectRejectsInvalidURLs(t *testing.T) {
	for _, url := range []string{"", "localhost:50051", "ftp://example.com", "https://user:secret@example.com", "https://example.com?token=x"} {
		_, err := Connect(url)
		require.Error(t, err)
	}
}
