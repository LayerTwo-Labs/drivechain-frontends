package api

import (
	"context"

	"connectrpc.com/connect/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

var errNoBroadcast = connect.NewError(connect.CodeUnimplemented,
	"the sidechain node does not export or broadcast signed transactions")

// GetSignedTransaction is not available: no sidechain node exports its signed transactions.
func (h *ExplorerHandler) GetSignedTransaction(
	context.Context, *pb.GetSignedTransactionRequest,
) (*pb.GetSignedTransactionResponse, error) {
	return nil, errNoBroadcast
}

// RebroadcastTransaction is not available: no sidechain node rebroadcasts a transaction.
func (h *ExplorerHandler) RebroadcastTransaction(
	context.Context, *pb.RebroadcastTransactionRequest,
) (*pb.RebroadcastTransactionResponse, error) {
	return nil, errNoBroadcast
}

// BroadcastTransaction is not available: no sidechain node takes a signed transaction.
func (h *ExplorerHandler) BroadcastTransaction(
	context.Context, *pb.BroadcastTransactionRequest,
) (*pb.BroadcastTransactionResponse, error) {
	return nil, errNoBroadcast
}
