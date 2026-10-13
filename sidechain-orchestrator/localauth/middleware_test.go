package localauth

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestMiddleware(t *testing.T) {
	dir := t.TempDir()
	token, err := WriteCookie(dir)
	if err != nil {
		t.Fatalf("write cookie: %v", err)
	}

	handler := Middleware(dir, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	// No token → fails closed.
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/enforcer/jsonrpc", nil))
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("no token: status = %d, want 401", rec.Code)
	}

	// Wrong token → fails closed.
	rec = httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/enforcer/jsonrpc", nil)
	req.Header.Set("Authorization", "Bearer wrong")
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("wrong token: status = %d, want 401", rec.Code)
	}

	// Cookie token → passes.
	rec = httptest.NewRecorder()
	req = httptest.NewRequest(http.MethodPost, "/enforcer/jsonrpc", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Errorf("valid token: status = %d, want 200", rec.Code)
	}

	// Empty dir is the explicit insecure mode — everything passes.
	open := Middleware("", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	rec = httptest.NewRecorder()
	open.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/x", nil))
	if rec.Code != http.StatusOK {
		t.Errorf("empty dir: status = %d, want 200", rec.Code)
	}
}

func TestLoopbackHost(t *testing.T) {
	serve := func(t *testing.T, listenAddr, host string) (int, bool) {
		t.Helper()
		called := false
		next := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			called = true
			w.WriteHeader(http.StatusOK)
		})
		req := httptest.NewRequest(http.MethodPost, "/", nil)
		req.Host = host
		rec := httptest.NewRecorder()
		LoopbackHost(listenAddr, next).ServeHTTP(rec, req)
		return rec.Code, called
	}

	cases := []struct {
		name   string
		listen string
		host   string
		allow  bool
	}{
		{"localhost", "localhost:30400", "localhost:30400", true},
		{"localhost upper case", "localhost:30400", "LOCALHOST:30400", true},
		{"ipv4 loopback", "localhost:30400", "127.0.0.1:30400", true},
		{"ipv6 loopback", "localhost:30400", "[::1]:30400", true},
		{"localhost without port", "localhost:30400", "localhost", true},
		{"foreign name", "localhost:30400", "evil.com:30400", false},
		{"localhost prefix", "localhost:30400", "localhost.evil.com:30400", false},
		{"loopback ip prefix", "localhost:30400", "127.0.0.1.evil.com", false},
		{"lan ip", "localhost:30400", "192.168.1.5:30400", false},
		{"empty host", "localhost:30400", "", false},
		{"all interfaces ipv4", "0.0.0.0:30400", "evil.com:30400", true},
		{"all interfaces empty host", ":30400", "evil.com:30400", true},
		{"listen ip", "192.168.1.5:30400", "192.168.1.5:30400", true},
		{"listen ip foreign name", "192.168.1.5:30400", "evil.com:30400", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			code, called := serve(t, tc.listen, tc.host)
			if tc.allow {
				if code != http.StatusOK || !called {
					t.Fatalf("host %q: code %d called %v, want 200 and called", tc.host, code, called)
				}
				return
			}
			if code != http.StatusForbidden || called {
				t.Fatalf("host %q: code %d called %v, want 403 and not called", tc.host, code, called)
			}
		})
	}
}
