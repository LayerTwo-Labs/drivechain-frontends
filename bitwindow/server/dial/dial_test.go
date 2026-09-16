package dial

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"testing"
)

// TestEnsureHTTPScheme guards the double-prefix regression. config.OrchestratorAddr
// defaults to a full URL ("http://localhost:30400"); dial.Bitcoind used to wrap
// it in another fmt.Sprintf("http://%s", ...) and the resulting
// "http://http://localhost:30400" tripped Connect's URL parser into dialing
// "http" as a hostname ("dial tcp: lookup http: no such host"). Every
// bitcoind-touching call from bitwindowd silently failed for the user.
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
			if got != tc.want {
				t.Fatalf("ensureHTTPScheme(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}

// TestBitcoind_RejectsEmptyAddr is the only behavioral check we can do without
// mocking out connect's transport — empty addr must error rather than silently
// dial nothing.
func TestBitcoind_RejectsEmptyAddr(t *testing.T) {
	if _, err := Bitcoind(t.Context(), ""); err == nil {
		t.Fatal("Bitcoind(\"\") returned nil error")
	}
}

// TestSharedClientSpeaksH2C guards the transport rewrite: bitwindowd talks to
// the orchestrator over plain TCP, and Connect needs HTTP/2 there.
func TestSharedClientSpeaksH2C(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
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
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)
	if err != nil {
		t.Fatalf("read body: %v", err)
	}
	if got := string(body); got != "HTTP/2.0" {
		t.Fatalf("server saw %q, want %q", got, "HTTP/2.0")
	}
}
