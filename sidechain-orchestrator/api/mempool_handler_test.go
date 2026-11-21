package api

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
)

func TestMempoolHandlerAnswersInSats(t *testing.T) {
	core := func(_ context.Context, method string, _ ...any) (json.RawMessage, error) {
		if method != "getrawmempool" {
			return nil, fmt.Errorf("no %s", method)
		}
		return json.RawMessage(fmt.Sprintf(`{
			"%064x": {"vsize": 100, "ancestorsize": 150, "time": 10, "height": 7, "fees": {"base": 0.00000300, "ancestor": 0.00000450}},
			"%064x": {"vsize": 200, "ancestorsize": 200, "time": 20, "height": 8, "fees": {"base": 0.00004000, "ancestor": 0.00004000}}
		}`, 1, 2)), nil
	}
	h := NewMempoolHandler(chaindata.New(chaindata.Config{Call: core, Log: zerolog.Nop()}).Mempool())

	list, err := h.ListTransactions(t.Context(), &pb.ListTransactionsRequest{Count: 1})
	require.NoError(t, err)
	require.Equal(t, uint64(2), list.Total)
	require.Len(t, list.Transactions, 1)
	tx := list.Transactions[0]
	require.Equal(t, fmt.Sprintf("%064x", 2), tx.Txid)
	require.Equal(t, uint64(4000), tx.FeeSats)
	require.Equal(t, uint32(200), tx.Vsize)
	require.Equal(t, int64(20), tx.Time.AsTime().Unix())
	require.Equal(t, uint32(8), tx.Height)

	stats, err := h.GetStats(t.Context(), &pb.GetStatsRequest{BucketEdges: []float64{0, 5, 10}})
	require.NoError(t, err)
	require.Equal(t, uint64(2), stats.TxCount)
	require.Equal(t, uint64(300), stats.Vsize)
	require.Equal(t, uint64(4300), stats.FeeSats)
	require.InDelta(t, 20, stats.MedianFeeRate, 1e-9)
	require.Equal(t, uint64(1), stats.Buckets[0].TxCount)
	require.Equal(t, uint64(0), stats.Buckets[1].TxCount)
	require.Equal(t, uint64(1), stats.Buckets[2].TxCount)

	_, err = h.GetStats(t.Context(), &pb.GetStatsRequest{BucketEdges: []float64{5, 1}})
	require.Error(t, err)
}
