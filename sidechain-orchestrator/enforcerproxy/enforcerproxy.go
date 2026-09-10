// Package enforcerproxy forwards enforcer traffic for the daemons that
// front it (drivechaind for sidechain apps, bitwindowd for bitwindow):
// Connect/gRPC service calls and the JSON-RPC mining endpoint. Frontends
// only ever dial their local daemon.
package enforcerproxy

import (
	"context"
	"crypto/tls"
	"fmt"
	"io"
	stdlog "log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"

	"golang.org/x/net/http2"
)

// DefaultJSONRPCAddr is the enforcer's JSON-RPC listen address.
const DefaultJSONRPCAddr = "127.0.0.1:8122"

// Connect reverse-proxies Connect/gRPC requests to the enforcer's main
// gRPC endpoint, preserving the request path. upstream is e.g.
// "http://127.0.0.1:50051". errorLog takes the transport failures; a nil
// errorLog sends them to the standard logger.
func Connect(upstream string, errorLog *stdlog.Logger) (http.Handler, error) {
	u, err := url.Parse(upstream)
	if err != nil {
		return nil, fmt.Errorf("parse enforcer upstream %q: %w", upstream, err)
	}
	if u.Host == "" || (u.Scheme != "http" && u.Scheme != "https") || u.User != nil || u.RawQuery != "" || u.Fragment != "" {
		return nil, fmt.Errorf("invalid enforcer URL %q", upstream)
	}
	transport := &http2.Transport{}
	if u.Scheme == "http" {
		transport.AllowHTTP = true
		transport.DialTLSContext = func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
			var d net.Dialer
			return d.DialContext(ctx, network, addr)
		}
	}
	return &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			r.SetURL(u)
			r.Out.Header.Del("Authorization")
			r.Out.Header.Del("Cookie")
		},
		Transport:     transport,
		FlushInterval: -1,
		ErrorLog:      errorLog,
	}, nil
}

// ConnectDynamic resolves the enforcer endpoint for each request.
func ConnectDynamic(resolve func() (string, error), errorLog *stdlog.Logger) http.Handler {
	var mu sync.Mutex
	var current string
	var handler http.Handler
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		upstream, err := resolve()
		if err != nil {
			http.Error(w, err.Error(), http.StatusServiceUnavailable)
			return
		}
		mu.Lock()
		if handler == nil || upstream != current {
			next, err := Connect(upstream, errorLog)
			if err != nil {
				mu.Unlock()
				http.Error(w, err.Error(), http.StatusBadGateway)
				return
			}
			if old, ok := handler.(*httputil.ReverseProxy); ok {
				old.Transport.(*http2.Transport).CloseIdleConnections()
			}
			handler, current = next, upstream
		}
		next := handler
		mu.Unlock()
		next.ServeHTTP(w, r)
	})
}

// JSONRPC forwards JSON-RPC requests (e.g. getblocktemplate) to the
// enforcer's JSON-RPC server, which has no Connect handler.
func JSONRPC(addr string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		req, err := http.NewRequestWithContext(r.Context(), http.MethodPost, "http://"+addr+"/", r.Body)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		req.Header.Set("Content-Type", "application/json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		defer func() { _ = resp.Body.Close() }()

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(resp.StatusCode)
		_, _ = io.Copy(w, resp.Body)
	})
}
