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
