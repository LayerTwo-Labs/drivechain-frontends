package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
)

type broadcastResult struct {
	Txid      string `json:"txid"`
	PeerCount uint32 `json:"peer_count"`
}

func (h *ExplorerHandler) broadcastSource(chain string) (source, error) {
	chain = strings.TrimSpace(chain)
	// FreeBank is a plain-bitassets fork, so it speaks the same signed-transaction
	// broadcast RPC as BitNames and BitAssets.
	if chain != "bitnames" && chain != "bitassets" && chain != "freebank" {
		return source{}, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("transaction rebroadcast supports BitNames, BitAssets and FreeBank"))
	}
	src, err := h.sourceOf(chain)
	if err != nil {
		return source{}, err
	}
	if src.node == nil || src.core {
		return source{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("connect a sidechain node to use transaction rebroadcast"))
	}
	return src, nil
}

func broadcastError(err error) error {
	if rpc.LacksMethod(err) {
		return connect.NewError(connect.CodeUnimplemented,
			fmt.Errorf("update the sidechain node to use transaction rebroadcast"))
	}
	return connect.NewError(connect.CodeUnavailable, err)
}

func broadcastTxid(value string) (string, error) {
	value = strings.TrimSpace(value)
	id, err := hex.DecodeString(value)
	if err != nil || len(id) != 32 {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("enter a transaction ID with 64 hexadecimal characters"))
	}
	return value, nil
}

// GetSignedTransaction exports the transaction and its stored signatures as JSON.
func (h *ExplorerHandler) GetSignedTransaction(
	ctx context.Context, req *connect.Request[pb.GetSignedTransactionRequest],
) (*connect.Response[pb.GetSignedTransactionResponse], error) {
	txid, err := broadcastTxid(req.Msg.GetTxid())
	if err != nil {
		return nil, err
	}
	src, err := h.broadcastSource(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	raw, err := src.node.CallRaw(ctx, "get_authorized_transaction", []any{txid})
	if err != nil {
		return nil, broadcastError(err)
	}
	if len(raw) == 0 || strings.TrimSpace(string(raw)) == "null" {
		return nil, connect.NewError(connect.CodeNotFound,
			fmt.Errorf("the node does not hold this signed transaction"))
	}
	return connect.NewResponse(&pb.GetSignedTransactionResponse{SignedTransaction: string(raw)}), nil
}

// RebroadcastTransaction sends a stored pending transaction to connected peers.
func (h *ExplorerHandler) RebroadcastTransaction(
	ctx context.Context, req *connect.Request[pb.RebroadcastTransactionRequest],
) (*connect.Response[pb.RebroadcastTransactionResponse], error) {
	txid, err := broadcastTxid(req.Msg.GetTxid())
	if err != nil {
		return nil, err
	}
	src, err := h.broadcastSource(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	out, err := callBroadcast(ctx, src, "rebroadcast_transaction", txid)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RebroadcastTransactionResponse{
		Txid: out.Txid, PeerCount: out.PeerCount,
	}), nil
}

// BroadcastTransaction submits signed JSON without a new signature or payment.
func (h *ExplorerHandler) BroadcastTransaction(
	ctx context.Context, req *connect.Request[pb.BroadcastTransactionRequest],
) (*connect.Response[pb.BroadcastTransactionResponse], error) {
	raw := json.RawMessage(req.Msg.GetSignedTransaction())
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(raw, &fields); err != nil || fields == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("paste a signed transaction as a JSON object"))
	}
	if !jsonObject(fields["transaction"]) || !jsonArray(fields["authorizations"]) {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("the signed transaction must contain transaction and authorizations"))
	}
	src, err := h.broadcastSource(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	out, err := callBroadcast(ctx, src, "broadcast_transaction", raw)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.BroadcastTransactionResponse{
		Txid: out.Txid, PeerCount: out.PeerCount,
	}), nil
}

func jsonObject(raw json.RawMessage) bool {
	var value map[string]json.RawMessage
	return json.Unmarshal(raw, &value) == nil && value != nil
}

func jsonArray(raw json.RawMessage) bool {
	var value []json.RawMessage
	return json.Unmarshal(raw, &value) == nil && value != nil
}

func callBroadcast(ctx context.Context, src source, method string, value any) (*broadcastResult, error) {
	raw, err := src.node.CallRaw(ctx, method, []any{value})
	if err != nil {
		return nil, broadcastError(err)
	}
	var out broadcastResult
	if err := json.Unmarshal(raw, &out); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("read the broadcast result: %w", err))
	}
	return &out, nil
}
