package bitnames

import (
	"context"
	"encoding/json"
	"io/fs"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
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

// JSON-RPC carries params as an array. A bare value reaches the node as
// "Invalid params", so the call behind it never runs.
func TestBitNameDataSendsAnArray(t *testing.T) {
	srv, seen := recordParams(t, `{"seq_id":"1739-0029"}`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err := client.BitNameData(context.Background(), "c2f54351")
	require.NoError(t, err)
	assert.JSONEq(t, `["c2f54351"]`, string(*seen))
}

func TestGetBlockSendsAnArray(t *testing.T) {
	srv, seen := recordParams(t, `{"header":{}}`)
	defer srv.Close()

	client := &Client{baseURL: srv.URL, http: srv.Client()}
	_, err := client.GetBlock(context.Background(), "2574f096")
	require.NoError(t, err)
	assert.JSONEq(t, `["2574f096"]`, string(*seen))
}

// The Dart client reaches the handler, not the typed client, so the handler
// must send an array too. A bare value answers "Invalid params".
func TestNoHandlerSendsABareParameter(t *testing.T) {
	root := filepath.Join("..", "..", "sidechain")
	// Only the params position matters. A trailing result argument must not
	// exempt a bare value, so the allowance anchors on the method name too.
	// A typed client calls c.call, and a handler calls Client.Call or CallRaw.
	// Both reach the same node, so both must carry an array.
	bare := regexp.MustCompile(`\.[Cc]all(Raw)?\(ctx, "[a-z_]+", (req\.Msg\.[A-Za-z]+|[a-z][A-Za-z]*)[,)]`)
	allowed := regexp.MustCompile(`\.[Cc]all(Raw)?\(ctx, "[a-z_]+", (nil|params|body|request)[,)]`)

	var offenders []string
	err := filepath.WalkDir(root, func(path string, entry fs.DirEntry, err error) error {
		if err != nil || entry.IsDir() || !strings.HasSuffix(path, ".go") || strings.HasSuffix(path, "_test.go") {
			return err
		}
		source, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		for _, line := range strings.Split(string(source), "\n") {
			if bare.MatchString(line) && !allowed.MatchString(line) {
				offenders = append(offenders, strings.TrimSpace(line))
			}
		}
		return nil
	})
	require.NoError(t, err)
	assert.Empty(t, offenders, "every call must carry its params in an array")
}
