package engines_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func TestDenialKeepsBroadcastHopAfterStop(t *testing.T) {
	ctx := t.Context()
	conf := config.Config{Datadir: t.TempDir()}
	db, err := database.New(ctx, conf)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })
	ctrl := gomock.NewController(t)
	core := mocks.NewMockBitcoinServiceClient(ctrl)
	orch := mocks.NewMockWalletManagerServiceClient(ctrl)
	runCtx, stop := context.WithCancel(ctx)
	defer stop()
	orch.EXPECT().SetFrozenCoins(gomock.Any(), gomock.Any()).Return(&emptypb.Empty{}, nil)
	orch.EXPECT().CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).AnyTimes().
		Return(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "wallet_80CEBA21"}, nil)
	orch.EXPECT().SendTransaction(gomock.Any(), gomock.Any()).
		DoAndReturn(func(context.Context, *orchpb.SendTransactionRequest) (*orchpb.SendTransactionResponse, error) {
			stop()
			return &orchpb.SendTransactionResponse{Txid: "sent-hop"}, nil
		})
	core.EXPECT().GetNewAddress(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetNewAddressResponse{Address: "bc1qtest"}), nil)
	core.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).Return(connect.NewResponse(&corepb.ListUnspentResponse{}), nil)
	core.EXPECT().GetTransaction(gomock.Any(), gomock.Any()).
		Return(nil, connect.NewError(connect.CodeNotFound, errors.New("Invalid or non-wallet transaction id")))
	core.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).Times(2).
		Return(connect.NewResponse(&corepb.ListUnspentResponse{Unspent: []*corepb.UnspentOutput{
			{Txid: "sent-hop", Vout: 0, Address: "bc1qtest", Amount: 0.005},
		}}), nil)
	coreService := service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	})
	wallet := testDenialWalletEngine(t, core, orch)
	engine := engines.NewDeniability(coreService, db, wallet)
	denial, err := deniability.Create(ctx, db, denialWalletID, "old-tip", 0, time.Hour, 3, nil)
	require.NoError(t, err)
	err = engine.ProcessUTXO(runCtx, &engines.UTXO{Txid: "old-tip", ValueSats: 1_000_000}, denial)
	require.ErrorContains(t, err, "context cancelled")

	require.NoError(t, db.Close())
	db, err = database.New(ctx, conf)
	require.NoError(t, err)
	restart := engines.NewDeniability(coreService, db, wallet)
	_, runnable, err := restart.CleanupDenials(ctx)
	require.NoError(t, err)
	require.Empty(t, runnable)
	pending, err := deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.Nil(t, pending.CancelledAt)
	require.NotNil(t, pending.Pending)
	require.Equal(t, "sent-hop", pending.Pending.ToTxID)
	_, _, err = restart.CleanupDenials(ctx)
	require.NoError(t, err)
	stored, err := deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.Nil(t, stored.CancelledAt)
	require.Nil(t, stored.Pending)
	require.Equal(t, "sent-hop", stored.TipTXID)
	require.Len(t, stored.ExecutedDenials, 1)
	_, _, err = restart.CleanupDenials(ctx)
	require.NoError(t, err)
	stored, err = deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.Len(t, stored.ExecutedDenials, 1)
}

func TestDenialStopsWhenSentHopIsSpent(t *testing.T) {
	ctx := t.Context()
	db, err := database.New(ctx, config.Config{Datadir: t.TempDir()})
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })
	ctrl := gomock.NewController(t)
	core := mocks.NewMockBitcoinServiceClient(ctrl)
	orch := mocks.NewMockWalletManagerServiceClient(ctrl)
	orch.EXPECT().CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).AnyTimes().
		Return(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "wallet_80CEBA21"}, nil)
	core.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).Times(2).
		Return(connect.NewResponse(&corepb.ListUnspentResponse{}), nil)
	core.EXPECT().GetTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetTransactionResponse{
			Txid:          "sent-hop",
			Confirmations: 2,
			Details: []*corepb.GetTransactionResponse_Details{
				{Address: "bc1qtest", Category: corepb.GetTransactionResponse_CATEGORY_SEND, Vout: 0},
				{Address: "bc1qtest", Category: corepb.GetTransactionResponse_CATEGORY_RECEIVE, Vout: 0},
				{Address: "bc1qother", Category: corepb.GetTransactionResponse_CATEGORY_RECEIVE, Vout: 1},
			},
		}), nil)
	coreService := service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	})
	engine := engines.NewDeniability(coreService, db, testDenialWalletEngine(t, core, orch))
	denial, err := deniability.Create(ctx, db, denialWalletID, "old-tip", 0, time.Hour, 3, nil)
	require.NoError(t, err)
	require.NoError(t, deniability.SavePending(ctx, db, denial.ID, "old-tip", 0, "sent-hop", map[string]uint64{"bc1qtest": 500_000}))

	_, runnable, err := engine.CleanupDenials(ctx)
	require.NoError(t, err)
	require.Empty(t, runnable)
	stored, err := deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.Nil(t, stored.Pending)
	require.Nil(t, stored.CancelledAt)
	require.Equal(t, "sent-hop", stored.TipTXID)
	require.Len(t, stored.ExecutedDenials, 1)

	_, runnable, err = engine.CleanupDenials(ctx)
	require.NoError(t, err)
	require.Empty(t, runnable)
	stored, err = deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.NotNil(t, stored.CancelledAt)
	require.Len(t, stored.ExecutedDenials, 1)
}

func TestDenialCancelsWhenSentHopConflicts(t *testing.T) {
	ctx := t.Context()
	db, err := database.New(ctx, config.Config{Datadir: t.TempDir()})
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })
	ctrl := gomock.NewController(t)
	core := mocks.NewMockBitcoinServiceClient(ctrl)
	orch := mocks.NewMockWalletManagerServiceClient(ctrl)
	orch.EXPECT().CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).AnyTimes().
		Return(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "wallet_80CEBA21"}, nil)
	core.EXPECT().ListUnspent(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.ListUnspentResponse{}), nil)
	core.EXPECT().GetTransaction(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&corepb.GetTransactionResponse{Txid: "sent-hop", Confirmations: -1}), nil)
	coreService := service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return core, nil
	})
	engine := engines.NewDeniability(coreService, db, testDenialWalletEngine(t, core, orch))
	denial, err := deniability.Create(ctx, db, denialWalletID, "old-tip", 0, time.Hour, 3, nil)
	require.NoError(t, err)
	require.NoError(t, deniability.SavePending(ctx, db, denial.ID, "old-tip", 0, "sent-hop", map[string]uint64{"bc1qtest": 500_000}))

	_, runnable, err := engine.CleanupDenials(ctx)
	require.NoError(t, err)
	require.Empty(t, runnable)
	stored, err := deniability.Get(ctx, db, denial.ID)
	require.NoError(t, err)
	require.NotNil(t, stored.CancelledAt)
	require.Nil(t, stored.Pending)
	require.Empty(t, stored.ExecutedDenials)
	require.NotNil(t, stored.CancelReason)
	require.Contains(t, *stored.CancelReason, "conflict")
}
