package freebank

import (
	"context"
	"encoding/json"
	"errors"
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

// fakeNode replies per method, and records the params each call carried. A
// method mapped to nil answers the way a node without it does.
func fakeNode(t *testing.T, results map[string]json.RawMessage, seen map[string]json.RawMessage) *httptest.Server {
	t.Helper()
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		if seen != nil {
			seen[req.Method] = req.Params
		}
		result, ok := results[req.Method]
		if !ok {
			t.Fatalf("unexpected method: %s", req.Method)
		}
		w.Header().Set("Content-Type", "application/json")
		if result == nil {
			w.WriteHeader(http.StatusNotFound)
			_, _ = w.Write([]byte(`{"result":null,"error":{"code":-32601,"message":"Method not found"}}`))
			return
		}
		if string(result) == "notready" {
			w.WriteHeader(http.StatusInternalServerError)
			_, _ = w.Write([]byte(`{"result":null,"error":{"code":-40,"message":"side block for this eCash tip pending"}}`))
			return
		}
		_, _ = w.Write([]byte(`{"result":` + string(result) + `,"error":null}`))
	}))
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

const (
	internalRoot = "01" + "000000000000000000000000000000000000000000000000000000000000" + "ff"
	displayRoot  = "ff" + "000000000000000000000000000000000000000000000000000000000000" + "01"
	tipHash      = "aa" + "000000000000000000000000000000000000000000000000000000000000" + "aa"
	parentHash   = "bb" + "000000000000000000000000000000000000000000000000000000000000" + "bb"
)

func TestBlockTemplateCarriesTheMerkleRoot(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"get_block_template": json.RawMessage(`{"critical_hash":"` + internalRoot + `","block":{"prev_main_hash":"` + tipHash + `","hex":"00"},"fees_sats":1500}`),
	}, nil)
	defer srv.Close()

	template, err := clientFor(t, srv).GetBlockTemplate(context.Background())
	require.NoError(t, err)
	assert.Equal(t, internalRoot, template.CriticalHash)
	assert.Equal(t, int64(1500), template.FeesSats)
	assert.JSONEq(t, `{"prev_main_hash":"`+tipHash+`","hex":"00"}`, string(template.Block))
}

// connect_block takes the block object as the template gave it, not a string,
// and the mainchain block in display order.
func TestConnectBlockSendsTheBlockBack(t *testing.T) {
	seen := map[string]json.RawMessage{}
	srv := fakeNode(t, map[string]json.RawMessage{"connect_block": json.RawMessage(`true`)}, seen)
	defer srv.Close()

	block := json.RawMessage(`{"prev_main_hash":"` + tipHash + `","hex":"00"}`)
	connected, err := clientFor(t, srv).ConnectBlock(context.Background(), block, tipHash)
	require.NoError(t, err)
	assert.True(t, connected)
	assert.JSONEq(t, `[{"prev_main_hash":"`+tipHash+`","hex":"00"},"`+tipHash+`"]`, string(seen["connect_block"]))
}

func TestBmmInclusionsReadNoneAsEmpty(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{"get_bmm_inclusions": json.RawMessage(`[]`)}, nil)
	defer srv.Close()

	inclusions, err := clientFor(t, srv).GetBmmInclusions(context.Background(), internalRoot)
	require.NoError(t, err)
	assert.Empty(t, inclusions)
}

// A node from before v0.2.16 has no BMM methods. The engine shows the user why.
func TestAnOlderNodeSaysWhichReleaseItNeeds(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{"get_block_template": nil}, nil)
	defer srv.Close()

	_, err := clientFor(t, srv).GetBlockTemplate(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "v0.2.16")
}

// FreeBank bids with a merkle root, so ChainHolds finds a block by its merkle
// root, reversed into the display order Core prints.
func TestChainHoldsFindsTheMerkleRoot(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"getbestblockhash": json.RawMessage(`"` + tipHash + `"`),
		"getblockheader":   json.RawMessage(`{"merkleroot":"` + displayRoot + `","previousblockhash":"` + parentHash + `"}`),
	}, nil)
	defer srv.Close()

	held, err := clientFor(t, srv).ChainHolds(context.Background(), internalRoot, 11)
	require.NoError(t, err)
	assert.True(t, held)
}

// A block hash equal to the critical hash is a coincidence, not a match: only
// the merkle root counts.
func TestChainHoldsIgnoresBlockHashes(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{
		"getbestblockhash": json.RawMessage(`"` + displayRoot + `"`),
		"getblockheader":   json.RawMessage(`{"merkleroot":"` + tipHash + `","previousblockhash":""}`),
	}, nil)
	defer srv.Close()

	held, err := clientFor(t, srv).ChainHolds(context.Background(), internalRoot, 11)
	require.NoError(t, err)
	assert.False(t, held)
}

func TestTemplateOnTipReadsTheParentFromTheHeader(t *testing.T) {
	// version (4 bytes) + parent in internal order: the reverse of parentHash
	hexBlock := "20000000" + "bb" + "000000000000000000000000000000000000000000000000000000000000" + "bb" + "00"
	for tip, want := range map[string]bool{parentHash: true, tipHash: false} {
		srv := fakeNode(t, map[string]json.RawMessage{"getbestblockhash": json.RawMessage(`"` + tip + `"`)}, nil)
		onTip, err := clientFor(t, srv).TemplateOnTip(context.Background(), json.RawMessage(`{"hex":"`+hexBlock+`"}`))
		srv.Close()
		require.NoError(t, err)
		assert.Equal(t, want, onTip, "tip %s", tip)
	}
}

// freebankd's "not on this tip yet" answers become sidechain.ErrNotReady, which
// the handler turns into a same-tip retry instead of skipping the block.
func TestANodeNotReadyAsksForARetryOnTheSameTip(t *testing.T) {
	srv := fakeNode(t, map[string]json.RawMessage{"get_block_template": json.RawMessage("notready")}, nil)
	defer srv.Close()

	_, err := clientFor(t, srv).GetBlockTemplate(context.Background())
	require.Error(t, err)
	assert.True(t, errors.Is(err, sidechain.ErrNotReady))
	assert.Contains(t, err.Error(), "pending")
}
