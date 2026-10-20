package main

import (
	"context"

	"connectrpc.com/connect/v2"

	ecashv1 "github.com/LayerTwo-Labs/sidesail/ecash-broadcaster/gen/ecash/v1"
)

// handler implements ecashv1connect.ECashBroadcastServiceHandler.
type handler struct {
	bitcoind *bitcoindClient
}

func (h *handler) BroadcastECashTx(
	ctx context.Context,
	req *ecashv1.BroadcastECashTxRequest,
) (*ecashv1.BroadcastECashTxResponse, error) {
	if req.SignedHex == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "signed_hex is required")
	}

	txid, err := h.bitcoind.sendRawTransaction(ctx, req.SignedHex)
	if err != nil {
		return nil, connect.Errorf(connect.CodeInternal, "broadcast: %s", err).WithCause(err)
	}

	return &ecashv1.BroadcastECashTxResponse{Txid: txid}, nil
}
