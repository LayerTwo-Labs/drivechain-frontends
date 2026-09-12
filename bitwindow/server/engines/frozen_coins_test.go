package engines_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"google.golang.org/protobuf/types/known/emptypb"
)

func engineWithClient(t *testing.T, client *mocks.MockWalletManagerServiceClient) *engines.WalletEngine {
	t.Helper()
	engine := engines.NewWalletEngine(nil, t.TempDir(), &chaincfg.RegressionNetParams)
	engine.SetOrchestratorClient(client)
	return engine
}

// A send this server makes must never take a coin the user froze, so it hands
// the orchestrator the whole frozen set first.
func TestSendHandsOverTheFrozenCoins(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client)
	engine.SetFrozenCoins(func(context.Context) ([]string, error) {
		return []string{"aa:0", "bb:12"}, nil
	})

	var sent *orchpb.SetFrozenCoinsRequest
	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		Times(1).
		DoAndReturn(func(_ context.Context, req *connect.Request[orchpb.SetFrozenCoinsRequest]) (*connect.Response[emptypb.Empty], error) {
			sent = req.Msg
			return nil, nil
		})
	client.EXPECT().
		SendTransaction(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&connect.Response[orchpb.SendTransactionResponse]{
			Msg: &orchpb.SendTransactionResponse{Txid: "txid"},
		}, nil)

	txid, err := engine.SendTransaction(context.Background(), &orchpb.SendTransactionRequest{
		WalletId:    "wallet-1",
		OpReturnHex: "beef",
	})
	require.NoError(t, err)
	assert.Equal(t, "txid", txid)

	require.NotNil(t, sent)
	assert.Equal(t, "wallet-1", sent.WalletId)
	require.Len(t, sent.Outpoints, 2)
	assert.Equal(t, "aa", sent.Outpoints[0].Txid)
	assert.Equal(t, int32(0), sent.Outpoints[0].Vout)
	assert.Equal(t, "bb", sent.Outpoints[1].Txid)
	assert.Equal(t, int32(12), sent.Outpoints[1].Vout)
}

// A frozen set this server cannot read leaves it blind to the coins the user
// protects, so the send stops instead.
func TestSendStopsWhenTheFrozenSetFails(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client)
	engine.SetFrozenCoins(func(context.Context) ([]string, error) {
		return nil, errors.New("the database is closed")
	})

	_, err := engine.SendTransaction(context.Background(), &orchpb.SendTransactionRequest{WalletId: "wallet-1"})
	require.ErrorContains(t, err, "read the frozen coins")
}

func TestSendStopsOnAnOutpointItCannotRead(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client)
	engine.SetFrozenCoins(func(context.Context) ([]string, error) {
		return []string{"no-vout-here"}, nil
	})

	_, err := engine.SendTransaction(context.Background(), &orchpb.SendTransactionRequest{WalletId: "wallet-1"})
	require.ErrorContains(t, err, "is not a txid:vout")
}

// A drivechaind restart drops the set it holds, and nothing here sees that
// restart. The engine hands the set over again while it runs.
func TestKeepFrozenCoinsHandsTheSetOverAgain(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client)
	engine.SetFrozenCoins(func(context.Context) ([]string, error) {
		return []string{"aa:0"}, nil
	})

	pushes := make(chan struct{}, 4)
	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		AnyTimes().
		DoAndReturn(func(context.Context, *connect.Request[orchpb.SetFrozenCoinsRequest]) (*connect.Response[emptypb.Empty], error) {
			pushes <- struct{}{}
			return nil, nil
		})

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go engine.KeepFrozenCoins(ctx)

	select {
	case <-pushes:
	case <-time.After(5 * time.Second):
		t.Fatal("the engine handed over no frozen set")
	}
}
