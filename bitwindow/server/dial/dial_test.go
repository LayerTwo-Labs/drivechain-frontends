package dial

import (
	"testing"

	"golang.org/x/net/http2"
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

// TestClientForScheme guards the cookie-leak regression. Every dial used the
// h2c client, whose DialTLS hook discards the *tls.Config it is handed and
// plain net.Dials instead — x/net/http2 routes https:// connections through
// that same hook, so an https:// orchestrator.addr dialed cleartext and the
// local-auth bearer cookie went out unencrypted. https:// must get a transport
// that actually does TLS.
func TestClientForScheme(t *testing.T) {
	cleartext := clientForScheme(t.Context(), "http://localhost:30400")
	encrypted := clientForScheme(t.Context(), "https://orch.example.com")

	if cleartext == encrypted {
		t.Fatal("http:// and https:// got the same client")
	}

	h2c, ok := cleartext.Transport.(*http2.Transport)
	if !ok {
		t.Fatalf("http:// transport = %T, want *http2.Transport", cleartext.Transport)
	}
	if !h2c.AllowHTTP || h2c.DialTLS == nil {
		t.Error("http:// client is not the h2c transport")
	}

	tlsTransport, ok := encrypted.Transport.(*http2.Transport)
	if !ok {
		t.Fatalf("https:// transport = %T, want *http2.Transport", encrypted.Transport)
	}
	if tlsTransport.AllowHTTP {
		t.Error("https:// client allows cleartext HTTP/2")
	}
	if tlsTransport.DialTLS != nil || tlsTransport.DialTLSContext != nil {
		t.Error("https:// client overrides the TLS dialer, bypassing TLS")
	}

	// ensureHTTPScheme passes mixed-case schemes through untouched.
	if got := clientForScheme(t.Context(), "HTTPS://orch.example.com"); got != encrypted {
		t.Error("mixed-case https:// did not get the TLS client")
	}
}
