package explorer

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	btcpb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/jsonrpc"
)

func TestSidechainTipHeight(t *testing.T) {
	t.Parallel()

	for _, tt := range []struct {
		name   string
		count  uint64
		height uint64
	}{
		{name: "empty chain", count: 0, height: 0},
		{name: "one block", count: 1, height: 0},
		{name: "multiple blocks", count: 42, height: 41},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			mainchain := &btcpb.GetBlockResponse{
				Hash: "mainchain-tip",
				Time: timestamppb.New(time.Unix(1234567890, 0)),
			}
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				var request jsonrpc.Request
				if !assert.NoError(t, json.NewDecoder(r.Body).Decode(&request)) {
					return
				}
				var result any
				switch request.Method {
				case "get_best_sidechain_block_hash":
					if tt.count > 0 {
						result = "sidechain-tip"
					}
				case "get_best_mainchain_block_hash":
					if tt.count > 0 {
						result = mainchain.Hash
					}
				case "getblockcount":
					result = tt.count
				default:
					t.Errorf("unexpected method %s", request.Method)
				}
				assert.NoError(t, json.NewEncoder(w).Encode(map[string]any{
					"jsonrpc": "2.0", "id": request.ID, "result": result,
				}))
			}))
			defer server.Close()

			s := &Server{}
			tip, err := s.getSidechainTip(t.Context(), lo.T2("Thunder", jsonrpc.NewClient(server.URL, "", "")), mainchain)
			require.NoError(t, err)
			assert.Equal(t, pb.ChainTipStatus_CHAIN_TIP_STATUS_ACTIVE, tip.Status)
			assert.Equal(t, tt.height, tip.Height)
			if tt.count == 0 {
				assert.Empty(t, tip.Hash)
				assert.Nil(t, tip.Timestamp)
			} else {
				assert.Equal(t, "sidechain-tip", tip.Hash)
				assert.Equal(t, mainchain.Time, tip.Timestamp)
			}
		})
	}
}
