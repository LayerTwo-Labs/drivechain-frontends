package api_wallet_test

import (
	"context"
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
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{
					{
						Txid:          fundingTxid,
						Vout:          0,
						Address:       chequeAddr,
						Amount:        1.0, // 1 BTC
						Confirmations: 0,   // unconfirmed!
					},
				},
			},
		}, nil)

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

	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{
					{
						Txid:          "beef0000beef0000beef0000beef0000beef0000beef0000beef0000beef0000",
						Vout:          1,
						Address:       chequeAddr,
						Amount:        0.5,
						Confirmations: 3,
					},
				},
			},
		}, nil)

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

	// First call returns UTXO, triggering DB update
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{
					{
						Txid:          fundingTxid,
						Vout:          0,
						Address:       chequeAddr,
						Amount:        1.0,
						Confirmations: 0,
					},
				},
			},
		}, nil)

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
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{
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
				},
			},
		}, nil)

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
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListUnspentResponse]{
			Msg: &bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{
					{
						Txid:          "partial0partial0partial0partial0partial0partial0partial0partial0",
						Vout:          0,
						Address:       chequeAddr,
						Amount:        0.5, // Only half!
						Confirmations: 1,
					},
				},
			},
		}, nil)

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
