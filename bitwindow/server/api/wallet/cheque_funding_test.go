package api_wallet_test

import (
	"context"
	"slices"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

const testWalletID = "test-wallet-id-1234"

// expectChequeListUnspent installs a permissive ListUnspent expectation that
// returns the given UTXOs only when the request targets the test cheque
// address, and an empty response otherwise. This is the pattern every
// cheque-funding test needs because the cheque engine's background
// ScanForFunds also calls ListUnspent (with derived addresses, 20 times per
// wallet), and that loop would otherwise eat a Times(1) expectation before
// the test's CheckChequeFunding call ever runs.
func expectChequeListUnspent(mock *mocks.MockBitcoinServiceClient, chequeAddr string, utxos []*bitcoindv1alpha.UnspentOutput) {
	mock.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[bitcoindv1alpha.ListUnspentRequest]) (*connect.Response[bitcoindv1alpha.ListUnspentResponse], error) {
			if !slices.Contains(req.Msg.Addresses, chequeAddr) {
				return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
					Msg: &bitcoindv1alpha.ListUnspentResponse{},
				}, nil
			}
			return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
				Msg: &bitcoindv1alpha.ListUnspentResponse{Unspent: utxos},
			}, nil
		}).
		AnyTimes()
}

func TestCheckChequeFunding_UnfundedCheck(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// Mock: no UTXOs at the cheque address
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{},
			},
		}, nil)

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	// Insert cheque directly into DB (bypasses wallet lock requirement)
	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, "tb1qtestaddress000000000000000000000000000")
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.False(t, resp.Msg.Funded)
}

func TestCheckChequeFunding_DetectsUnconfirmedTx(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qunconfirmedtestaddr00000000000000000000"
	fundingTxid := "abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// Mock: unconfirmed UTXO at the cheque address (0 confirmations)
	expectChequeListUnspent(mockBitcoind, chequeAddr, []*bitcoindv1alpha.UnspentOutput{
		{
			Txid:          fundingTxid,
			Vout:          0,
			Address:       chequeAddr,
			Amount:        1.0, // 1 BTC
			Confirmations: 0,   // unconfirmed!
		},
	})

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded, "should detect unconfirmed tx as funded")
	require.Equal(t, uint64(100_000_000), resp.Msg.ActualAmountSats)
	require.Equal(t, []string{fundingTxid}, resp.Msg.FundedTxids)
}

func TestCheckChequeFunding_DetectsConfirmedTx(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qconfirmedtestaddr0000000000000000000000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	expectChequeListUnspent(mockBitcoind, chequeAddr, []*bitcoindv1alpha.UnspentOutput{
		{
			Txid:          "beef0000beef0000beef0000beef0000beef0000beef0000beef0000beef0000",
			Vout:          1,
			Address:       chequeAddr,
			Amount:        0.5,
			Confirmations: 3,
		},
	})

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 50_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded)
	require.Equal(t, uint64(50_000_000), resp.Msg.ActualAmountSats)
}

func TestCheckChequeFunding_PersistsFundingToDatabase(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qpersisttestaddr000000000000000000000000"
	fundingTxid := "dead0000dead0000dead0000dead0000dead0000dead0000dead0000dead0000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// UTXO at the cheque address triggers DB update on the test's poll.
	expectChequeListUnspent(mockBitcoind, chequeAddr, []*bitcoindv1alpha.UnspentOutput{
		{
			Txid:          fundingTxid,
			Vout:          0,
			Address:       chequeAddr,
			Amount:        1.0,
			Confirmations: 0,
		},
	})

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded)

	// Verify: DB should now have the funding persisted
	cheque, err := cheques.Get(context.Background(), db, testWalletID, chequeID)
	require.NoError(t, err)
	require.Equal(t, []string{fundingTxid}, cheque.FundedTxids)
	require.NotNil(t, cheque.ActualAmountSats)
	require.Equal(t, uint64(100_000_000), *cheque.ActualAmountSats)
	require.NotNil(t, cheque.FundedAt)
}

func TestCheckChequeFunding_MultipleUTXOs(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qmultiutxotestaddr00000000000000000000000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// Two UTXOs at the same address
	expectChequeListUnspent(mockBitcoind, chequeAddr, []*bitcoindv1alpha.UnspentOutput{
		{
			Txid:          "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000",
			Vout:          0,
			Address:       chequeAddr,
			Amount:        1.0,
			Confirmations: 0,
		},
		{
			Txid:          "bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000",
			Vout:          0,
			Address:       chequeAddr,
			Amount:        1.0,
			Confirmations: 1,
		},
	})

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 200_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded)
	require.Equal(t, uint64(200_000_000), resp.Msg.ActualAmountSats)
	require.Len(t, resp.Msg.FundedTxids, 2)
	require.Contains(t, resp.Msg.FundedTxids, "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000")
	require.Contains(t, resp.Msg.FundedTxids, "bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000")
}

func TestCheckChequeFunding_PartialFunding(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qpartialtestaddr0000000000000000000000000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// UTXO with only 0.5 BTC but cheque expects 1 BTC
	expectChequeListUnspent(mockBitcoind, chequeAddr, []*bitcoindv1alpha.UnspentOutput{
		{
			Txid:          "partial0partial0partial0partial0partial0partial0partial0partial0",
			Vout:          0,
			Address:       chequeAddr,
			Amount:        0.5, // Only half!
			Confirmations: 1,
		},
	})

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	// Cheque expects 1 BTC
	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.False(t, resp.Msg.Funded, "should NOT be fully funded with only half the amount")
	require.Equal(t, uint64(50_000_000), resp.Msg.ActualAmountSats)
	require.Len(t, resp.Msg.FundedTxids, 1, "should still track the partial txid")
}

// TestCheckChequeFunding_PollAfterSend mirrors the Flutter check_provider
// polling loop: after the user taps "Fund Check", the wallet broadcasts a tx
// and the UI polls CheckChequeFunding every few seconds. The first poll may
// race the watch wallet (no UTXOs yet) and must report unfunded; a later
// poll, once bitcoind sees the tx, must flip the cheque to funded and
// persist the txid.
func TestCheckChequeFunding_PollAfterSend(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qpolltestaddr00000000000000000000000000000"
	fundingTxid := "feed0000feed0000feed0000feed0000feed0000feed0000feed0000feed0000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()

	// Discriminate by the request's address: the cheque engine's background
	// ScanForFunds queries 20 derived addresses, and we don't want those calls
	// eating the test's two ordered poll responses. Only calls scoped to the
	// test cheque address advance the poll counter; others get an empty
	// response.
	var pollCount atomic.Int32
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[bitcoindv1alpha.ListUnspentRequest]) (*connect.Response[bitcoindv1alpha.ListUnspentResponse], error) {
			if !slices.Contains(req.Msg.Addresses, chequeAddr) {
				return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
					Msg: &bitcoindv1alpha.ListUnspentResponse{},
				}, nil
			}
			// Poll 1: empty. Poll 2+: funded.
			if pollCount.Add(1) == 1 {
				return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
					Msg: &bitcoindv1alpha.ListUnspentResponse{},
				}, nil
			}
			return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
				Msg: &bitcoindv1alpha.ListUnspentResponse{
					Unspent: []*bitcoindv1alpha.UnspentOutput{
						{
							Txid:          fundingTxid,
							Vout:          0,
							Address:       chequeAddr,
							Amount:        2.1,
							Confirmations: 0,
						},
					},
				},
			}, nil
		}).
		AnyTimes()

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 210_000_000, chequeAddr)
	require.NoError(t, err)

	// First poll: no UTXOs yet — cheque is unfunded.
	respFirst, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.False(t, respFirst.Msg.Funded)
	require.Empty(t, respFirst.Msg.FundedTxids)

	// Second poll: UTXO is now visible — cheque flips to funded, txid persisted.
	respSecond, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, respSecond.Msg.Funded, "second poll should detect the broadcast")
	require.Equal(t, []string{fundingTxid}, respSecond.Msg.FundedTxids)
	require.Equal(t, uint64(210_000_000), respSecond.Msg.ActualAmountSats)

	// And the funding is durable across calls.
	persisted, err := cheques.Get(context.Background(), db, testWalletID, chequeID)
	require.NoError(t, err)
	require.True(t, persisted.IsFunded())
	require.NotNil(t, persisted.FundedAt)
	require.Equal(t, []string{fundingTxid}, persisted.FundedTxids)
}
