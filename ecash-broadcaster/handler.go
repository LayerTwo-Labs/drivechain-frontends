package main

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	ecashv1 "github.com/LayerTwo-Labs/sidesail/ecash-broadcaster/gen/ecash/v1"
)

// handler implements ecashv1connect.ECashBroadcastServiceHandler.
type handler struct {
	bitcoind *bitcoindClient
}

func (h *handler) BroadcastECashTx(
	ctx context.Context,
	req *connect.Request[ecashv1.BroadcastECashTxRequest],
) (*connect.Response[ecashv1.BroadcastECashTxResponse], error) {
	if req.Msg.SignedHex == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("signed_hex is required"))
	}

	txid, err := h.bitcoind.sendRawTransaction(ctx, req.Msg.SignedHex)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("broadcast: %w", err))
	}

	return connect.NewResponse(&ecashv1.BroadcastECashTxResponse{Txid: txid}), nil
}
