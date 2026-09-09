package enforcerproxy

import (
	"errors"
	"fmt"
	"net"
	"net/http"
	"net/http/httputil"
	"sync"

	"golang.org/x/net/http2"
)

// Remote serves a remote validator through a loopback h2c listener.
type Remote struct {
	server    *http.Server
	listener  net.Listener
	mu        sync.RWMutex
	proxy     http.Handler
	closed    bool
	done      chan error
	closeOnce sync.Once
	closeErr  error
}

func closeIdleConnections(handler http.Handler) {
	if proxy, ok := handler.(*httputil.ReverseProxy); ok {
		proxy.Transport.(*http2.Transport).CloseIdleConnections()
	}
}

// NewRemote starts a loopback bridge to the remote enforcer URL.
func NewRemote(upstream string) (*Remote, error) {
	proxy, err := Connect(upstream)
	if err != nil {
		return nil, err
	}
	return newRemote(proxy)
}

func newRemote(proxy http.Handler) (*Remote, error) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return nil, fmt.Errorf("listen for remote enforcer: %w", err)
	}
	protocols := &http.Protocols{}
	protocols.SetHTTP1(true)
	protocols.SetUnencryptedHTTP2(true)
	r := &Remote{
		listener: listener,
		proxy:    proxy,
		done:     make(chan error, 1),
	}
	r.server = &http.Server{
		Handler:   ValidatorOnly(http.HandlerFunc(r.serveHTTP)),
		Protocols: protocols,
	}
	go func() {
		r.done <- r.server.Serve(listener)
	}()
	return r, nil
}

func (r *Remote) serveHTTP(w http.ResponseWriter, request *http.Request) {
	r.mu.RLock()
	proxy := r.proxy
	r.mu.RUnlock()
	proxy.ServeHTTP(w, request)
}

// SetUpstream changes the validator endpoint without a listener change.
func (r *Remote) SetUpstream(upstream string) error {
	handler, err := Connect(upstream)
	if err != nil {
		return err
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.closed {
		return net.ErrClosed
	}
	previous := r.proxy
	r.proxy = handler
	closeIdleConnections(previous)
	return nil
}

// URL returns the loopback enforcer URL.
func (r *Remote) URL() string {
	return "http://" + r.listener.Addr().String()
}

// Close stops the bridge and its active subscriptions.
func (r *Remote) Close() error {
	r.closeOnce.Do(func() {
		r.mu.Lock()
		r.closed = true
		proxy := r.proxy
		r.mu.Unlock()
		closeErr := r.server.Close()
		serveErr := <-r.done
		if errors.Is(serveErr, http.ErrServerClosed) {
			serveErr = nil
		}
		closeIdleConnections(proxy)
		r.closeErr = errors.Join(closeErr, serveErr)
	})
	return r.closeErr
}

// ValidatorOnly permits validator reads and health checks.
func ValidatorOnly(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !validatorPath(r.URL.Path) {
			http.Error(w, "remote enforcer method is unavailable", http.StatusForbidden)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func validatorPath(path string) bool {
	switch path {
	case "/grpc.health.v1.Health/Check",
		"/grpc.health.v1.Health/Watch",
		"/cusf.mainchain.v1.ValidatorService/GetBlockHeaderInfo",
		"/cusf.mainchain.v1.ValidatorService/GetBlockInfo",
		"/cusf.mainchain.v1.ValidatorService/GetBmmHStarCommitment",
		"/cusf.mainchain.v1.ValidatorService/GetChainInfo",
		"/cusf.mainchain.v1.ValidatorService/GetChainTip",
		"/cusf.mainchain.v1.ValidatorService/GetCoinbasePSBT",
		"/cusf.mainchain.v1.ValidatorService/GetCtip",
		"/cusf.mainchain.v1.ValidatorService/GetSidechainProposals",
		"/cusf.mainchain.v1.ValidatorService/GetSidechains",
		"/cusf.mainchain.v1.ValidatorService/GetTwoWayPegData",
		"/cusf.mainchain.v1.ValidatorService/GetWithdrawalBundleProposals",
		"/cusf.mainchain.v1.ValidatorService/SubscribeEvents",
		"/cusf.mainchain.v1.ValidatorService/SubscribeHeaderSyncProgress":
		return true
	default:
		return false
	}
}
