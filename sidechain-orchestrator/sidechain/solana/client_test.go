package solana

import (
	"context"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

const (
	testCritical = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff"
	testPrevMain = "0000000000000000000000000000000000000000000000000000000000000abc"
	testBlock    = `{"prev_main_hash":"` + testPrevMain + `","height":7,"bank_hash":"9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin","payee":"4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T","slot":8}`
)

// fakeNode answers each method with its JSON result, or with the error code
// that codes names. It records the params of each call.
func fakeNode(t *testing.T, results map[string]string, codes map[string]int) (*Client, map[string]json.RawMessage) {
	t.Helper()
	seen := map[string]json.RawMessage{}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			JSONRPC string          `json:"jsonrpc"`
			Method  string          `json:"method"`
			Params  json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		assert.Equal(t, "2.0", req.JSONRPC)
		assert.Equal(t, http.MethodPost, r.Method)
		seen[req.Method] = req.Params
		if code, ok := codes[req.Method]; ok {
			_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":` + strconv.Itoa(code) + `,"message":"refused"}}`))
			return
		}
		result, ok := results[req.Method]
		if !ok {
			t.Errorf("unexpected method: %s", req.Method)
			_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}`))
			return
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(srv.Close)

	parsed, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portText, err := net.SplitHostPort(parsed.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return NewClient(host, port), seen
}

func TestGetBlockTemplateReadsTheContract(t *testing.T) {
	client, _ := fakeNode(t, map[string]string{
		"get_block_template": `{"critical_hash":"` + testCritical + `","block":` + testBlock + `,"fees_sats":5000}`,
	}, nil)

	template, err := client.GetBlockTemplate(context.Background())
	require.NoError(t, err)

	assert.Equal(t, testCritical, template.CriticalHash)
	assert.Equal(t, int64(5000), template.FeesSats)
	assert.JSONEq(t, testBlock, string(template.Block))
}

func TestNotReadyAsksAgainOnTheSameTip(t *testing.T) {
	client, _ := fakeNode(t, nil, map[string]int{"get_block_template": -32001})

	_, err := client.GetBlockTemplate(context.Background())

	require.ErrorIs(t, err, sidechain.ErrNotReady)
}

func TestSettledHeightIsAPlainError(t *testing.T) {
	client, _ := fakeNode(t, nil, map[string]int{"get_block_template": -32002})

	_, err := client.GetBlockTemplate(context.Background())

	require.Error(t, err)
	assert.False(t, errors.Is(err, sidechain.ErrNotReady))
}

func TestConnectBlockSendsTheBlockAndTheMainBlock(t *testing.T) {
	client, seen := fakeNode(t, map[string]string{"connect_block": `true`}, nil)

	connected, err := client.ConnectBlock(context.Background(), json.RawMessage(testBlock), "beef")
	require.NoError(t, err)

	assert.True(t, connected)
	assert.JSONEq(t, `[`+testBlock+`,"beef"]`, string(seen["connect_block"]))
}

func TestGetBmmInclusionsSendsTheCriticalHash(t *testing.T) {
	client, seen := fakeNode(t, map[string]string{"get_bmm_inclusions": `["aa","bb"]`}, nil)

	inclusions, err := client.GetBmmInclusions(context.Background(), testCritical)
	require.NoError(t, err)

	assert.Equal(t, []string{"aa", "bb"}, inclusions)
	assert.JSONEq(t, `["`+testCritical+`"]`, string(seen["get_bmm_inclusions"]))
}

func TestTemplateOnTipAsksTheNode(t *testing.T) {
	for _, valid := range []bool{true, false} {
		t.Run(strconv.FormatBool(valid), func(t *testing.T) {
			client, seen := fakeNode(t, map[string]string{"template_valid": strconv.FormatBool(valid)}, nil)

			onTip, err := client.TemplateOnTip(context.Background(), json.RawMessage(testBlock))
			require.NoError(t, err)

			assert.Equal(t, valid, onTip)
			assert.JSONEq(t, `[`+testBlock+`]`, string(seen["template_valid"]))
		})
	}
}

func TestGetBlockCount(t *testing.T) {
	client, _ := fakeNode(t, map[string]string{"getblockcount": `42`}, nil)

	count, err := client.GetBlockCount(context.Background())
	require.NoError(t, err)

	assert.Equal(t, int64(42), count)
}

// The node runs outside the orchestrator and keeps no wallet there, so these
// answers never reach it.
func TestLocalAnswersSendNoCall(t *testing.T) {
	client, seen := fakeNode(t, nil, nil)
	ctx := context.Background()

	require.NoError(t, client.Stop(ctx))

	total, available, err := client.GetBalance(ctx)
	require.NoError(t, err)
	assert.Zero(t, total)
	assert.Zero(t, available)

	_, err = client.GetNewAddress(ctx)
	require.Error(t, err)

	held, err := client.ChainHolds(ctx, testCritical, 11)
	require.NoError(t, err)
	assert.False(t, held)

	args, err := client.Args(ctx, nil)
	require.NoError(t, err)
	assert.Nil(t, args)

	assert.Empty(t, seen)
}
