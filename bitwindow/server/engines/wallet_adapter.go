package engines

import (
	"context"
	"encoding/hex"
	"fmt"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	validatorpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// WalletAdapter adapts the wallet service for timestamp engine
type WalletAdapter struct {
	wallet *service.Service[validatorrpc.WalletServiceClient]
}

func NewWalletAdapter(wallet *service.Service[validatorrpc.WalletServiceClient]) *WalletAdapter {
	return &WalletAdapter{wallet: wallet}
}

func (w *WalletAdapter) SendTransaction(ctx context.Context, opReturnData []byte) (string, error) {
	client, err := w.wallet.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("get wallet client: %w", err)
	}

	resp, err := client.SendTransaction(ctx, connect.NewRequest(&validatorpb.SendTransactionRequest{
		OpReturnMessage: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: hex.EncodeToString(opReturnData),
			},
		},
	}))
	if err != nil {
		return "", fmt.Errorf("send transaction: %w", err)
	}

	return resp.Msg.Txid.Hex.Value, nil
}
