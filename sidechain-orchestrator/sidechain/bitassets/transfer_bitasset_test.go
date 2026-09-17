package bitassets

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// paramsNode answers every method with the given result, and records the
// params of each request.
func paramsNode(t *testing.T, result string) (*sidechain.JSONRPCProxy, *[]any) {
	t.Helper()
	params := []any{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Params []any `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		params = req.Params
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(server.Close)

	host, portText, found := strings.Cut(strings.TrimPrefix(server.URL, "http://"), ":")
	require.True(t, found, "cannot split %q", server.URL)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(host, port), &params
}

// The node signature is transfer_bitasset(dest, asset_id, amount, fee_sats,
// memo). The wrong order makes the node reject the address.
func TestTransferBitAssetSendsDestBeforeAssetID(t *testing.T) {
	proxy, params := paramsNode(t, `"e3b0c44298fc1c149afbf4c8996fb924"`)

	resp, err := NewHandler(proxy).TransferBitAsset(context.Background(),
		connect.NewRequest(&pb.TransferBitAssetRequest{
			AssetId: "d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076",
			Dest:    "3w3mR6SMpc3irb7etdJbDu5rLyLv",
			Amount:  7000000,
			FeeSats: 1000,
		}))
	require.NoError(t, err)
	assert.Equal(t, "e3b0c44298fc1c149afbf4c8996fb924", resp.Msg.Txid)

	assert.Equal(t, []any{
		"3w3mR6SMpc3irb7etdJbDu5rLyLv",
		"d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076",
		float64(7000000),
		float64(1000),
		nil,
	}, *params)
}
