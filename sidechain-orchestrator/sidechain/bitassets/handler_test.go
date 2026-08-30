package bitassets

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// rpcCapture is a JSON-RPC request as it went out on the wire.
type rpcCapture struct {
	Method string          `json:"method"`
	Params json.RawMessage `json:"params"`
}

// captureRPC returns an httptest.Server that publishes every request it
// receives and answers each one with rawResult, plus a Handler proxying to it.
func captureRPC(t *testing.T, rawResult string) (*Handler, <-chan rpcCapture) {
	t.Helper()

	requests := make(chan rpcCapture, 4)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req rpcCapture
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		requests <- req

		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + rawResult + `}`))
	}))
	t.Cleanup(srv.Close)

	host, port, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	portNum, err := strconv.Atoi(port)
	require.NoError(t, err)

	return NewHandler(sidechain.NewJSONRPCProxy(host, portNum)), requests
}

// The backend takes transfer_bitasset(dest, asset_id, amount, fee_sats); sending
// the first two the other way round transfers the wrong asset to the wrong place.
func TestTransferBitAssetParamOrder(t *testing.T) {
	h, requests := captureRPC(t, `"txid-1"`)

	resp, err := h.TransferBitAsset(context.Background(), connect.NewRequest(&pb.TransferBitAssetRequest{
		AssetId: "asset-1",
		Dest:    "bNdest",
		Amount:  500,
		FeeSats: 7,
	}))
	require.NoError(t, err)
	assert.Equal(t, "txid-1", resp.Msg.Txid)

	req := <-requests
	assert.Equal(t, "transfer_bitasset", req.Method)
	assert.JSONEq(t, `["bNdest","asset-1",500,7]`, string(req.Params))
}
