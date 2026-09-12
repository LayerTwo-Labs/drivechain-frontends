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

// recordParams answers every call, and keeps the params of the last one.
func recordParams(t *testing.T, result string) (*httptest.Server, *json.RawMessage) {
	t.Helper()
	var seen json.RawMessage
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		seen = req.Params
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":"t","result":` + result + `}`))
	}))
	return srv, &seen
}

// The node reads params by position. A wrong order reaches the node as
// "Invalid params", and the call never runs.
func TestSignArbitraryMsgSendsTheKeyFirst(t *testing.T) {
	srv, seen := recordParams(t, `"0xsignature"`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err := client.SignArbitraryMsg(context.Background(), "the message", "bn-svk1key")
	require.NoError(t, err)
	assert.JSONEq(t, `["bn-svk1key","the message"]`, string(*seen))
}

func TestSignArbitraryMsgAsAddrSendsTheAddressFirst(t *testing.T) {
	srv, seen := recordParams(t, `{"verifying_key":"bn-svk1key","signature":"0xsig"}`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err := client.SignArbitraryMsgAsAddr(context.Background(), "the message", "3Dsq1WDmpX")
	require.NoError(t, err)
	assert.JSONEq(t, `["3Dsq1WDmpX","the message"]`, string(*seen))
}

// JSON-RPC carries params as an array. A bare string reaches the node as
// "Invalid params".
func TestConnectPeerSendsAnArray(t *testing.T) {
	srv, seen := recordParams(t, `null`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	require.NoError(t, client.ConnectPeer(context.Background(), "127.0.0.1:4002"))
	assert.True(t, strings.HasPrefix(string(*seen), "["), "params must be an array, and they are %s", *seen)
	assert.JSONEq(t, `["127.0.0.1:4002"]`, string(*seen))
}

func TestEncryptMsgSendsTheKeyFirst(t *testing.T) {
	srv, seen := recordParams(t, `"cipher"`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err := client.EncryptMsg(context.Background(), "bn-enc1key", "the message")
	require.NoError(t, err)
	assert.JSONEq(t, `["bn-enc1key","the message"]`, string(*seen))
}
