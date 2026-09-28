package api

import (
	"context"
	"errors"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

var errNoBroadcast = connect.NewError(connect.CodeUnimplemented,
	errors.New("the sidechain node does not export or broadcast signed transactions"))

// GetSignedTransaction is not available: no sidechain node exports its signed transactions.
func (h *ExplorerHandler) GetSignedTransaction(
	context.Context, *connect.Request[pb.GetSignedTransactionRequest],
) (*connect.Response[pb.GetSignedTransactionResponse], error) {
	return nil, errNoBroadcast
}

// RebroadcastTransaction is not available: no sidechain node rebroadcasts a transaction.
func (h *ExplorerHandler) RebroadcastTransaction(
	context.Context, *connect.Request[pb.RebroadcastTransactionRequest],
) (*connect.Response[pb.RebroadcastTransactionResponse], error) {
	return nil, errNoBroadcast
}

// BroadcastTransaction is not available: no sidechain node takes a signed transaction.
func (h *ExplorerHandler) BroadcastTransaction(
	context.Context, *connect.Request[pb.BroadcastTransactionRequest],
) (*connect.Response[pb.BroadcastTransactionResponse], error) {
	return nil, errNoBroadcast
}
