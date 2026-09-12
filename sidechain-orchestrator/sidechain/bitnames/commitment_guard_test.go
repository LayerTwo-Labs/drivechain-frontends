package bitnames

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCheckGlobalAddressRejectsNonPublic(t *testing.T) {
	// A BitName holder picks this address, so it can aim at the victim's own
	// machine or network.
	for _, address := range []string{
		"127.0.0.1:6002",
		"localhost:6002",
		"10.0.0.1:6002",
		"192.168.1.1:6002",
		"172.16.0.1:6002",
		"169.254.1.1:6002",
		"[::1]:6002",
		// Go calls these global unicast, and they still reach a carrier or a lab.
		"100.64.0.1:6002",
		"198.18.0.1:6002",
		"192.0.0.8:6002",
		"203.0.113.7:6002",
		"198.51.100.1:6002",
		"192.0.2.1:6002",
		"240.0.0.1:6002",
		"[2001:db8::1]:6002",
		"[fc00::1]:6002",
	} {
		err := checkGlobalAddress(address)
		require.Error(t, err, "address %s must not pass", address)
	}
}

func TestCheckGlobalAddressRejectsMalformed(t *testing.T) {
	for _, address := range []string{"", "psztorc.com", "psztorc.com:", ":6002"} {
		require.Error(t, checkGlobalAddress(address), "address %q must not pass", address)
	}
}

func TestCheckGlobalAddressAcceptsPublic(t *testing.T) {
	// A literal address skips DNS, so this test needs no network.
	require.NoError(t, checkGlobalAddress("8.8.8.8:6002"))
	require.NoError(t, checkGlobalAddress("[2606:4700:4700::1111]:6002"))
}

func TestFetchCommitmentRefusesLoopback(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{"bitname_commit": map[string]string{"a": "b"}})
	defer srv.Close()

	// The test server listens on loopback, which is exactly what the guard stops.
	_, _, err := FetchCommitment(context.Background(), strings.TrimPrefix(srv.URL, "http://"))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "non-public")
}

func TestCallRefusesAnswerOverTheCap(t *testing.T) {
	big := strings.Repeat("x", 4096)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, err := json.Marshal(rpcResponse{Result: json.RawMessage(`"` + big + `"`)})
		require.NoError(t, err)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write(body)
	}))
	defer srv.Close()

	capped := &Client{baseURL: srv.URL, http: srv.Client(), maxBody: 512}
	_, err := capped.call(context.Background(), "bitname_commit", nil)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "larger than 512 bytes")

	uncapped := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err = uncapped.call(context.Background(), "bitname_commit", nil)
	require.NoError(t, err)
}
