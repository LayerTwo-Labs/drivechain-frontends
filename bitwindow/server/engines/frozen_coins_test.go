package engines_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func engineWithClient(t *testing.T, client *mocks.MockWalletManagerServiceClient, frozenCoins engines.FrozenCoinsFunc) *engines.WalletEngine {
	t.Helper()
	return engines.NewWalletEngine(nil, client, &chaincfg.RegressionNetParams, frozenCoins)
}

// A send this server makes must never take a coin the user froze, so it hands
// the orchestrator the whole frozen set first.
func TestSendHandsOverTheFrozenCoins(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"aa:0", "bb:12"}, nil
	})

	var sent *orchpb.SetFrozenCoinsRequest
	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		Times(1).
		DoAndReturn(func(_ context.Context, req *orchpb.SetFrozenCoinsRequest) (*emptypb.Empty, error) {
			sent = req
			return nil, nil
		})
	client.EXPECT().
		SendTransaction(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&orchpb.SendTransactionResponse{Txid: "txid"}, nil)

	txid, err := engine.SendTransaction(t.Context(), &orchpb.SendTransactionRequest{
		WalletId:    "wallet-1",
		OpReturnHex: "beef",
	})
	require.NoError(t, err)
	assert.Equal(t, "txid", txid)

	require.NotNil(t, sent)
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
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return nil, errors.New("the database is closed")
	})

	_, err := engine.SendTransaction(t.Context(), &orchpb.SendTransactionRequest{WalletId: "wallet-1"})
	require.ErrorContains(t, err, "read the frozen coins")
}

func TestSendStopsOnAnOutpointItCannotRead(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"no-vout-here"}, nil
	})

	_, err := engine.SendTransaction(t.Context(), &orchpb.SendTransactionRequest{WalletId: "wallet-1"})
	require.ErrorContains(t, err, "is not a txid:vout")
}

// A drivechaind restart drops the set it holds, and nothing here sees that
// restart. The engine hands the set over again while it runs.
func TestKeepFrozenCoinsHandsTheSetOverAgain(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"aa:0"}, nil
	})

	pushes := make(chan struct{}, 4)
	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		AnyTimes().
		DoAndReturn(func(context.Context, *orchpb.SetFrozenCoinsRequest) (*emptypb.Empty, error) {
			pushes <- struct{}{}
			return nil, nil
		})

	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()
	go engine.KeepFrozenCoins(ctx)

	select {
	case <-pushes:
	case <-time.After(5 * time.Second):
		t.Fatal("the engine handed over no frozen set")
	}
}

// A deposit funds the treasury from the wallet, so it hands the frozen set
// over the same way a send does.
func TestDepositHandsOverTheFrozenCoins(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"aa:0"}, nil
	})

	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&emptypb.Empty{}, nil)
	client.EXPECT().
		CreateDeposit(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&orchpb.CreateDepositResponse{Txid: "deposit-txid"}, nil)

	txid, err := engine.CreateDeposit(t.Context(), &orchpb.CreateDepositRequest{WalletId: "wallet-1"})
	require.NoError(t, err)
	assert.Equal(t, "deposit-txid", txid)
}

// A bump reaches for another coin when the change cannot pay the raise, so it
// hands the frozen set over first.
func TestBumpFeeHandsOverTheFrozenCoins(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"aa:0"}, nil
	})

	client.EXPECT().
		SetFrozenCoins(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&emptypb.Empty{}, nil)
	client.EXPECT().
		BumpFee(gomock.Any(), gomock.Any()).
		Times(1).
		Return(&orchpb.BumpFeeResponse{NewTxid: "bumped"}, nil)

	resp, err := engine.BumpFee(t.Context(), &orchpb.BumpFeeRequest{Txid: "old"})
	require.NoError(t, err)
	assert.Equal(t, "bumped", resp.NewTxid)
}

// The orchestrator spends a required input through its freeze, so the engine
// refuses a frozen one before any orchestrator call.
func TestSendRefusesAFrozenRequiredInput(t *testing.T) {
	client := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	engine := engineWithClient(t, client, func(context.Context) ([]string, error) {
		return []string{"TIP:00"}, nil
	})
	client.EXPECT().SetFrozenCoins(gomock.Any(), gomock.Any()).Times(0)
	client.EXPECT().SendTransaction(gomock.Any(), gomock.Any()).Times(0)

	_, err := engine.SendTransaction(t.Context(), &orchpb.SendTransactionRequest{
		WalletId:       "wallet-1",
		RequiredInputs: []*orchpb.UnspentOutput{{Txid: "tip", Vout: 0}},
	})
	require.ErrorIs(t, err, engines.ErrFrozenInput)
}
