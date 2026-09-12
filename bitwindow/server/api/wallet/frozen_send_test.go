package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// A send that names its inputs spends exactly those coins, so no lock reaches
// them. A frozen one has to stop the send.
func TestSendRefusesAFrozenRequiredInput(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	ctx := context.Background()
	frozen := true
	_, err := cli.SetUTXOMetadata(ctx, connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "frozen:0",
		IsFrozen: &frozen,
	}))
	require.NoError(t, err)

	_, err = cli.SendTransaction(ctx, connect.NewRequest(&walletv1.SendTransactionRequest{
		WalletId:       "test-wallet-id-1234",
		Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
		RequiredInputs: []*walletv1.UnspentOutput{{Output: "frozen:0"}},
	}))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "is frozen")
}

// A freeze the daemon never learns is no freeze at all, so the write reports
// the failure instead of success.
func TestSetUTXOMetadataReportsAFailedPush(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReadsWithoutFrozenCoins(mockOrch)
	mockOrch.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		AnyTimes().
		Return((*connect.Response[emptypb.Empty])(nil), connect.NewError(connect.CodeUnavailable, assert.AnError))
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	frozen := true
	_, err := cli.SetUTXOMetadata(context.Background(), connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "aa:0",
		IsFrozen: &frozen,
	}))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "set frozen coins")
}

// A caller can spell a vout with a leading zero, and a txid in either case.
func TestSendRefusesAFrozenInputInAnySpelling(t *testing.T) {
	ctrl := gomock.NewController(t)
	db := database.Test(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	ctx := context.Background()
	frozen := true
	_, err := cli.SetUTXOMetadata(ctx, connect.NewRequest(&walletv1.SetUTXOMetadataRequest{
		Outpoint: "abcdef:1",
		IsFrozen: &frozen,
	}))
	require.NoError(t, err)

	for _, spelling := range []string{"ABCDEF:1", "abcdef:01", "ABCDEF:01"} {
		_, err = cli.SendTransaction(ctx, connect.NewRequest(&walletv1.SendTransactionRequest{
			WalletId:       "test-wallet-id-1234",
			Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
			RequiredInputs: []*walletv1.UnspentOutput{{Output: spelling}},
		}))
		require.Error(t, err, spelling)
		assert.Contains(t, err.Error(), "is frozen", spelling)
	}
}
