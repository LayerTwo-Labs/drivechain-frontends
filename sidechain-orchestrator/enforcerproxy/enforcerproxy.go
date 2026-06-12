// Package enforcerproxy forwards enforcer traffic for the daemons that
// front it (orchestratord for sidechain apps, bitwindowd for bitwindow):
// Connect/gRPC service calls and the JSON-RPC mining endpoint. Frontends
// only ever dial their local daemon.
package enforcerproxy

import (
	"context"
	"crypto/tls"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"

	"golang.org/x/net/http2"
)

// DefaultJSONRPCAddr is the enforcer's JSON-RPC listen address.
const DefaultJSONRPCAddr = "127.0.0.1:8122"

// Connect reverse-proxies Connect/gRPC requests to the enforcer's main
// gRPC endpoint, preserving the request path. upstream is e.g.
// "http://127.0.0.1:50051".
func Connect(upstream string) (http.Handler, error) {
	u, err := url.Parse(upstream)
	if err != nil {
		return nil, fmt.Errorf("parse enforcer upstream %q: %w", upstream, err)
	}
	return &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			r.SetURL(u)
		},
		// The enforcer speaks gRPC over h2c; trailers require HTTP/2 on the
		// upstream leg.
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
				var d net.Dialer
				return d.DialContext(ctx, network, addr)
			},
		},
		FlushInterval: -1,
	}, nil
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
