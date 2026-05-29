package localauth_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth/localauthtest"
)

// Exercises the real connect interceptor over an httptest server: a bare
// unary handler wrapped with the server interceptor, called by a client
// wrapped with the client interceptor — the same wiring used in production.
const testProcedure = "/localauth.test.v1.EchoService/Echo"

func echoServer(t *testing.T, dir string) *httptest.Server {
	t.Helper()
	mux := http.NewServeMux()
	handler := connect.NewUnaryHandler(
		testProcedure,
		func(ctx context.Context, _ *connect.Request[emptypb.Empty]) (*connect.Response[emptypb.Empty], error) {
			return connect.NewResponse(&emptypb.Empty{}), nil
		},
		connect.WithInterceptors(localauth.Interceptor(dir)),
	)
	mux.Handle(testProcedure, handler)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	return srv
}

func echoClient(srvURL, dir string) *connect.Client[emptypb.Empty, emptypb.Empty] {
	return connect.NewClient[emptypb.Empty, emptypb.Empty](
		http.DefaultClient,
		srvURL+testProcedure,
		connect.WithInterceptors(localauth.Interceptor(dir)),
	)
}

func TestEndToEndAuth(t *testing.T) {
	dir := t.TempDir()
	if _, err := localauth.WriteCookie(dir); err != nil {
		t.Fatal(err)
	}
	srv := echoServer(t, dir)

	// Client reads the cookie from dir and attaches it -> allowed.
	client := echoClient(srv.URL, dir)
	if _, err := client.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{})); err != nil {
		t.Fatalf("cookie-backed call should succeed: %v", err)
	}

	// AuthContext carries the token explicitly (the bbtest pattern) -> allowed.
	if _, err := client.CallUnary(localauthtest.AuthContext(t, dir), connect.NewRequest(&emptypb.Empty{})); err != nil {
		t.Fatalf("AuthContext call should succeed: %v", err)
	}

	// A client with no cookie (different, empty dir) sends no token, so the
	// server rejects with Unauthenticated.
	noAuth := echoClient(srv.URL, t.TempDir())
	_, err := noAuth.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{}))
	if got := connect.CodeOf(err); got != connect.CodeUnauthenticated {
		t.Fatalf("expected Unauthenticated, got %v (err=%v)", got, err)
	}
}

func TestEndToEndDisabledWithEmptyDir(t *testing.T) {
	dir := "" // explicit insecure/test no-op
	srv := echoServer(t, dir)
	client := echoClient(srv.URL, dir)
	if _, err := client.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{})); err != nil {
		t.Fatalf("empty dir should mean auth disabled (call passes): %v", err)
	}
}

func TestEndToEndMissingCookieFailsClosed(t *testing.T) {
	dir := t.TempDir()
	srv := echoServer(t, dir)
	client := echoClient(srv.URL, dir)
	_, err := client.CallUnary(context.Background(), connect.NewRequest(&emptypb.Empty{}))
	if got := connect.CodeOf(err); got != connect.CodeUnauthenticated {
		t.Fatalf("expected Unauthenticated, got %v (err=%v)", got, err)
	}
}
