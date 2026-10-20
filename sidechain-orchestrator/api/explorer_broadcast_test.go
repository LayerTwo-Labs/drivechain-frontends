package api

import (
	"context"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

func TestExplorerBroadcastIsUnimplemented(t *testing.T) {
	const txid = "ec28b4ae39901902690bbe36a06e5e3088aab1fa2871a82cd70efa91c7b48bfc"
	h := &ExplorerHandler{sources: func(string) (source, error) {
		t.Error("the handler asked for a node")
		return source{}, nil
	}}
	ctx := context.Background()

	_, err := h.GetSignedTransaction(ctx, &pb.GetSignedTransactionRequest{Chain: "bitnames", Txid: txid})
	require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))
	_, err = h.RebroadcastTransaction(ctx, &pb.RebroadcastTransactionRequest{Chain: "bitnames", Txid: txid})
	require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))
	_, err = h.BroadcastTransaction(ctx, &pb.BroadcastTransactionRequest{
		Chain: "bitassets", SignedTransaction: `{"transaction":{},"authorizations":[]}`,
	})
	require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))
}
