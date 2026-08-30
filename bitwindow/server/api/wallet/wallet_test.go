package api_wallet_test

import (
	"context"
	"database/sql"
	"fmt"
	"testing"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"

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
	"google.golang.org/protobuf/types/known/emptypb"
)

func TestService_GetBalance(t *testing.T) {
	t.Parallel()

	t.Run("get balance successfully", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		// The balance comes from the orchestrator wallet manager now.
		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			GetBalance(gomock.Any(), gomock.Any()).
			Return(&connect.Response[orchpb.GetBalanceResponse]{
				Msg: &orchpb.GetBalanceResponse{
					ConfirmedSats:   100000,
					UnconfirmedSats: 50000,
				},
			}, nil)

		// Create mock bitcoind client (to handle ensureWatchWallet calls)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{
					Wallets: []string{}, // No wallets exist yet
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{
					Name: "test_wallet",
				},
			}, nil).
			AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithOrchestrator(mockOrch), apitests.WithBitcoind(mockBitcoind)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetBalance(context.Background(), connect.NewRequest(&walletv1.GetBalanceRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, uint64(100000), resp.Msg.ConfirmedSatoshi)
		require.Equal(t, uint64(50000), resp.Msg.PendingSatoshi)
	})

}

func TestService_GetNewAddress(t *testing.T) {
	t.Parallel()

	t.Run("get new address successfully", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		// Addresses come from the orchestrator wallet manager now.
		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(&connect.Response[orchpb.GetNewAddressResponse]{
				Msg: &orchpb.GetNewAddressResponse{Address: "bc1qtest123456789"},
			}, nil)

		// Create mock bitcoind client (to handle ensureWatchWallet calls)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{
					Wallets: []string{}, // No wallets exist yet
				},
			}, nil).
			AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{
					Name: "test_wallet",
				},
			}, nil).
			AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithOrchestrator(mockOrch), apitests.WithBitcoind(mockBitcoind)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetNewAddress(context.Background(), connect.NewRequest(&walletv1.GetNewAddressRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, "bc1qtest123456789", resp.Msg.Address)
	})
}

func TestService_ListCheques(t *testing.T) {
	t.Parallel()

	t.Run("list empty cheques", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListCheques(context.Background(), connect.NewRequest(&walletv1.ListChequesRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Empty(t, resp.Msg.Cheques)
	})
}

func TestService_GetCheque(t *testing.T) {
	t.Parallel()

	t.Run("get non-existent cheque returns not found", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.GetCheque(context.Background(), connect.NewRequest(&walletv1.GetChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.Error(t, err)
		// A non-existent cheque must surface as NotFound, not a leaked
		// "no rows" internal error.
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}

func TestService_DeleteCheque(t *testing.T) {
	t.Parallel()

	t.Run("delete non-existent cheque returns not found", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.DeleteCheque(context.Background(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.Error(t, err)
		// A non-existent cheque must surface as NotFound, not a leaked
		// "no rows" internal error.
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}

// TestService_DeleteChequeFundingGuard pins the server-side deletion guard:
// a cheque with any recorded incoming funds (partial or full) that has not
// been swept must not be deletable, because its row still represents real
// money at the derived address. Once swept, the row is safe to remove.
func TestService_DeleteChequeFundingGuard(t *testing.T) {
	t.Parallel()

	// deleteChequeClient stands up an API server with the permissive bitcoind
	// mock the cheque engine bootstrap needs, and hands back both a client and
	// the backing database so the test can seed cheque funding state directly.
	deleteChequeClient := func(t *testing.T) (walletv1connect.WalletServiceClient, *sql.DB) {
		t.Helper()

		ctrl := gomock.NewController(t)
		db := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithBitcoind(mockBitcoind)))
		return cli, db
	}

	t.Run("partially funded unswept cheque cannot be deleted", func(t *testing.T) {
		t.Parallel()

		cli, db := deleteChequeClient(t)

		// Cheque expects 1 BTC but only 0.5 BTC arrived: partially funded, unswept.
		chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, "tb1qpartialdelete000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(context.Background(), db, testWalletID, chequeID,
			[]string{"partial0partial0partial0partial0partial0partial0partial0partial0"}, 50_000_000))

		_, err = cli.DeleteCheque(context.Background(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// The row must survive — its recorded funds are still unswept.
		_, err = cheques.Get(context.Background(), db, testWalletID, chequeID)
		require.NoError(t, err)
	})

	t.Run("fully funded unswept cheque cannot be deleted", func(t *testing.T) {
		t.Parallel()

		cli, db := deleteChequeClient(t)

		chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, "tb1qfulldelete0000000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(context.Background(), db, testWalletID, chequeID,
			[]string{"full0000full0000full0000full0000full0000full0000full0000full0000"}, 100_000_000))

		_, err = cli.DeleteCheque(context.Background(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.Error(t, err)
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		_, err = cheques.Get(context.Background(), db, testWalletID, chequeID)
		require.NoError(t, err)
	})

	t.Run("swept cheque can be deleted", func(t *testing.T) {
		t.Parallel()

		cli, db := deleteChequeClient(t)

		chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, "tb1qsweptdelete000000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(context.Background(), db, testWalletID, chequeID,
			[]string{"swept000swept000swept000swept000swept000swept000swept000swept000"}, 100_000_000))
		require.NoError(t, cheques.UpdateSwept(context.Background(), db, testWalletID, chequeID,
			"deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef0"))

		_, err = cli.DeleteCheque(context.Background(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.NoError(t, err)

		// Once swept, the row is gone.
		_, err = cheques.Get(context.Background(), db, testWalletID, chequeID)
		require.ErrorIs(t, err, sql.ErrNoRows)
	})
}

func TestService_IsWalletUnlocked(t *testing.T) {
	t.Parallel()

	t.Run("wallet is locked by default", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		// Test wallets are not encrypted, so they should be "unlocked"
		_, err := cli.IsWalletUnlocked(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		// The test wallet is unencrypted, so it should be considered unlocked
		require.NoError(t, err)
	})
}

func TestService_LockWallet(t *testing.T) {
	t.Parallel()

	t.Run("lock wallet succeeds", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.LockWallet(context.Background(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
	})
}

func TestService_UnlockWallet(t *testing.T) {
	t.Parallel()

	t.Run("unlock unencrypted wallet returns error", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		database := database.Test(t)

		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connect.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database, apitests.WithBitcoind(mockBitcoind)))

		// Test wallet is not encrypted, so unlock should fail
		_, err := cli.UnlockWallet(context.Background(), connect.NewRequest(&walletv1.UnlockWalletRequest{
			Password: "anypassword",
		}))
		require.Error(t, err)
		require.Contains(t, err.Error(), "not encrypted")
	})
}

// The orchestrator records each deposit as it broadcasts it, because an M5 is
// an ordinary transaction on the wire.
func TestListSidechainDepositsReadsTheOrchestrator(t *testing.T) {
	t.Parallel()

	ctrl := gomock.NewController(t)
	database := database.Test(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	apitests.ExpectCoreWalletSetup(mockBitcoind)

	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	mockOrch.EXPECT().
		ListSidechainDeposits(gomock.Any(), gomock.Any()).
		Return(&connect.Response[orchpb.ListSidechainDepositsResponse]{
			Msg: &orchpb.ListSidechainDepositsResponse{
				Deposits: []*orchpb.SidechainDeposit{
					{Txid: "deadbeef", Slot: 9, AmountSats: 50_000},
				},
			},
		}, nil)

	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database,
		apitests.WithBitcoind(mockBitcoind), apitests.WithOrchestrator(mockOrch)))

	resp, err := cli.ListSidechainDeposits(context.Background(), connect.NewRequest(&walletv1.ListSidechainDepositsRequest{Slot: 9}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Deposits, 1)
	require.Equal(t, "deadbeef", resp.Msg.Deposits[0].Txid)
	require.Equal(t, int64(50_000), resp.Msg.Deposits[0].Amount)
}

// A negative slot must be rejected here, not cast to uint32 and forwarded: the
// cast wraps, and -4294967289 lands on slot 7 — someone else's sidechain.
func TestCreateSidechainDepositRejectsNegativeSlot(t *testing.T) {
	t.Parallel()

	for _, slot := range []int64{-1, -4294967289} {
		t.Run(fmt.Sprint(slot), func(t *testing.T) {
			t.Parallel()

			ctrl := gomock.NewController(t)
			database := database.Test(t)
			mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
			apitests.ExpectCoreWalletSetup(mockBitcoind)

			// No CreateDeposit expectation: the request must not reach it.
			mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
			apitests.ExpectOrchestratorReads(mockOrch)

			cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database,
				apitests.WithBitcoind(mockBitcoind), apitests.WithOrchestrator(mockOrch)))

			_, err := cli.CreateSidechainDeposit(context.Background(), connect.NewRequest(&walletv1.CreateSidechainDepositRequest{
				WalletId:    "test-wallet-id-1234",
				Destination: "13tqn1jxdcrbDycej4bp5S5PcffYtdGNPy",
				Slot:        slot,
				Amount:      0.001,
				Fee:         0.0001,
			}))
			require.Error(t, err)
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}
}
