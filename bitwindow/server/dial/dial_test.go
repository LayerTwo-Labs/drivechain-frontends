package dial

import "testing"

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
