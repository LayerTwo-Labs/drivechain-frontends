package bbc

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// fakeNode replies with a pre-encoded result per method.
func fakeNode(t *testing.T, results map[string]json.RawMessage) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string `json:"method"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		result, ok := results[req.Method]
		if !ok {
			t.Fatalf("unexpected method: %s", req.Method)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":` + string(result) + `,"error":null}`))
	}))
	return srv
}

func clientFor(t *testing.T, srv *httptest.Server) *Client {
	t.Helper()
	parsed, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portText, err := net.SplitHostPort(parsed.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)

	cookie := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:secret"), 0o600))
	return NewClient(host, port, cookie)
}

func TestSidechainInfoReportsTheMainchainLink(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"getsidechaininfo": json.RawMessage(`{"synced":true,"mainchaintip":"0000abc","lasterror":""}`),
	})
	defer srv.Close()

	info, err := clientFor(t, srv).GetSidechainInfo(context.Background())
	require.NoError(t, err)
	assert.True(t, info.Synced)
	assert.Equal(t, "0000abc", info.MainchainTip)
}

// A mainchain block that carries no commitment answers null, which is not an
// error.
func TestBmmCommitmentReadsNullAsNone(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{"getbmmcommitment": json.RawMessage(`null`)})
	defer srv.Close()

	commitment, err := clientFor(t, srv).GetBmmCommitment(context.Background(), "0000dead")
	require.NoError(t, err)
	assert.Empty(t, commitment)
}

func TestBlockTemplateCarriesTheCriticalHash(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"get_block_template": json.RawMessage(`{"critical_hash":"abc123","block":{},"fees_sats":4200}`),
	})
	defer srv.Close()

	template, err := clientFor(t, srv).GetBlockTemplate(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "abc123", template.CriticalHash)
	assert.Equal(t, int64(4200), template.FeesSats)
}

const (
	internalHash = "01" + "0000000000000000000000000000000000000000000000000000000000" + "ff"
	displayHash  = "ff" + "0000000000000000000000000000000000000000000000000000000000" + "01"
)

// critical_hash is in internal byte order, and Core names its tip in display order.
func TestChainHoldsReversesTheCriticalHash(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"getbestblockhash": json.RawMessage(`"` + displayHash + `"`),
	})
	defer srv.Close()

	held, err := clientFor(t, srv).ChainHolds(context.Background(), internalHash, 11)
	require.NoError(t, err)
	assert.True(t, held)
}

func TestChainHoldsMissesABlockOffTheChain(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"getbestblockhash": json.RawMessage(`"` + internalHash + `"`),
		"getblockheader":   json.RawMessage(`{"previousblockhash":""}`),
	})
	defer srv.Close()

	held, err := clientFor(t, srv).ChainHolds(context.Background(), internalHash, 11)
	require.NoError(t, err)
	assert.False(t, held, "an unreversed hash names no block")
}

// The BMM engine drives Bbc blocks, but Bbc settles withdrawals elsewhere. The
// explorer reads that from the type rather than from a stub error.
func TestBbcDrivesBmmButProposesNoBundle(t *testing.T) {
	var node sidechain.Node = NewClient("127.0.0.1", 1, "")

	_, drivesBMM := node.(sidechain.BMMNode)
	assert.True(t, drivesBMM)

	_, proposesBundles := node.(sidechain.WithdrawalNode)
	assert.False(t, proposesBundles, "bbc withdrawals are not wired into consensus")
}
