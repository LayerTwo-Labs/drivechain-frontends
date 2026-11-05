package wallet_test

import (
	"context"
	"testing"

	connectv1 "connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletpb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

type feeStatsOrchestrator struct {
	orchrpc.WalletManagerServiceClient
}

func (feeStatsOrchestrator) GetSidechainDepositTotals(context.Context, *orchpb.GetSidechainDepositTotalsRequest) (*orchpb.GetSidechainDepositTotalsResponse, error) {
	return &orchpb.GetSidechainDepositTotalsResponse{}, nil
}

func TestStatsExcludeTheReplacedFee(t *testing.T) {
	for _, tc := range []struct {
		name   string
		oldFee float64
	}{{name: "one confirmed send"}, {name: "a confirmed replacement", oldFee: -0.00001}} {
		t.Run(tc.name, func(t *testing.T) {
			core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			txs := []*corepb.GetTransactionResponse{{Txid: "replacement", Amount: -0.001, Fee: -0.00002, Confirmations: 1, Time: timestamppb.Now()}}
			if tc.oldFee != 0 {
				txs = append(txs, &corepb.GetTransactionResponse{Txid: "replaced", Amount: -0.001, Fee: tc.oldFee, Confirmations: -1})
			}
			core.EXPECT().ListTransactions(gomock.Any(), gomock.Any()).Return(connectv1.NewResponse(&corepb.ListTransactionsResponse{Transactions: txs}), nil)
			core.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).Return(connectv1.NewResponse(&corepb.ListUnspentResponse{}), nil)
			expectCoreTip(core, 100)
			apitests.ExpectCoreWalletSetup(core)
			orch := feeStatsOrchestrator{apitests.OpenWallet(apitests.CoreWalletOrchestrator(t), &orchpb.WalletMetadata{Id: testWalletID, WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE})}
			client := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(core), apitests.WithOrchestrator(orch)))
			response, err := client.GetStats(t.Context(), &walletpb.GetStatsRequest{WalletId: testWalletID})
			require.NoError(t, err)
			assert.Equal(t, int64(2000), response.TotalFeesSats)
		})
	}
}
