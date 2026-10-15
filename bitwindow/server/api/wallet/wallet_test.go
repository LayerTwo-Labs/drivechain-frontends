package wallet_test

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"testing"
	"time"

	"connectrpc.com/connect"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/addressbook"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
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
		resp, err := cli.GetBalance(t.Context(), connect.NewRequest(&walletv1.GetBalanceRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, uint64(100000), resp.Msg.ConfirmedSatoshi)
		require.Equal(t, uint64(50000), resp.Msg.PendingSatoshi)
	})

}

func TestGetBalanceRoundsBTCToSats(t *testing.T) {
	t.Parallel()

	for _, tt := range []struct {
		btc  float64
		sats uint64
	}{
		{btc: 0, sats: 0},
		{btc: 0.29, sats: 29_000_000},
		{btc: 2.01, sats: 201_000_000},
		{btc: 21e6, sats: 2_100_000_000_000_000},
	} {
		t.Run(fmt.Sprintf("%v BTC", tt.btc), func(t *testing.T) {
			t.Parallel()

			db := database.Test(t)
			mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			mockBitcoind.EXPECT().
				GetBalances(gomock.Any(), gomock.Any()).
				Return(connect.NewResponse(&bitcoindv1alpha.GetBalancesResponse{
					Mine: &bitcoindv1alpha.GetBalancesResponse_Mine{Trusted: tt.btc, UntrustedPending: tt.btc, Immature: tt.btc},
				}), nil)
			apitests.ExpectCoreWalletSetup(mockBitcoind)
			cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

			resp, err := cli.GetBalance(t.Context(), connect.NewRequest(&walletv1.GetBalanceRequest{WalletId: testWalletID}))
			require.NoError(t, err)
			require.Equal(t, tt.sats, resp.Msg.ConfirmedSatoshi)
			require.Equal(t, tt.sats, resp.Msg.PendingSatoshi)
			require.Equal(t, tt.sats, resp.Msg.ImmatureSatoshi)
		})
	}
}

func TestListUnspentRoundsBTCToSats(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&bitcoindv1alpha.ListUnspentResponse{
			Unspent: []*bitcoindv1alpha.UnspentOutput{{Txid: "aa", Vout: 1, Address: "bcrt1qtest", Amount: 0.29}},
		}), nil)
	apitests.ExpectCoreWalletSetup(mockBitcoind)
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

	resp, err := cli.ListUnspent(t.Context(), connect.NewRequest(&walletv1.ListUnspentRequest{WalletId: testWalletID}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Utxos, 1)
	require.Equal(t, uint64(29_000_000), resp.Msg.Utxos[0].ValueSats)
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
		resp, err := cli.GetNewAddress(t.Context(), connect.NewRequest(&walletv1.GetNewAddressRequest{
			WalletId: "test-wallet-id-1234",
		}))
		require.NoError(t, err)
		require.Equal(t, "bc1qtest123456789", resp.Msg.Address)
	})

	t.Run("an address the book holds returns again", func(t *testing.T) {
		t.Parallel()

		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.GetNewAddressResponse{Address: "bc1qtest123456789"}), nil).
			Times(2)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithOrchestrator(mockOrch)))

		for range 2 {
			resp, err := cli.GetNewAddress(t.Context(), connect.NewRequest(&walletv1.GetNewAddressRequest{WalletId: testWalletID}))
			require.NoError(t, err)
			require.Equal(t, "bc1qtest123456789", resp.Msg.Address)
		}
	})
}

func TestService_CreateCheque(t *testing.T) {
	t.Parallel()

	t.Run("an empty wallet id is an invalid argument", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithEncryptedWallet()))

		_, err := cli.CreateCheque(t.Context(), connect.NewRequest(&walletv1.CreateChequeRequest{ExpectedAmountSats: 1000}))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
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

		resp, err := cli.ListCheques(t.Context(), connect.NewRequest(&walletv1.ListChequesRequest{
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

		_, err := cli.GetCheque(t.Context(), connect.NewRequest(&walletv1.GetChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.ErrorContains(t, err, "cheque not found")
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

		_, err := cli.DeleteCheque(t.Context(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		}))
		require.ErrorContains(t, err, "cheque not found")
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
		chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, "tb1qpartialdelete000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, chequeID,
			[]cheques.FundingOutput{{Txid: "partial0partial0partial0partial0partial0partial0partial0partial0"}}, 50_000_000))

		_, err = cli.DeleteCheque(t.Context(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.ErrorContains(t, err, "cannot delete funded cheque")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		// The row must survive — its recorded funds are still unswept.
		_, err = cheques.Get(t.Context(), db, testWalletID, chequeID)
		require.NoError(t, err)
	})

	t.Run("fully funded unswept cheque cannot be deleted", func(t *testing.T) {
		t.Parallel()

		cli, db := deleteChequeClient(t)

		chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, "tb1qfulldelete0000000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, chequeID,
			[]cheques.FundingOutput{{Txid: "full0000full0000full0000full0000full0000full0000full0000full0000"}}, 100_000_000))

		_, err = cli.DeleteCheque(t.Context(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.ErrorContains(t, err, "cannot delete funded cheque")
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		_, err = cheques.Get(t.Context(), db, testWalletID, chequeID)
		require.NoError(t, err)
	})

	t.Run("swept cheque can be deleted", func(t *testing.T) {
		t.Parallel()

		cli, db := deleteChequeClient(t)

		chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, "tb1qsweptdelete000000000000000000000000000000")
		require.NoError(t, err)
		require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, chequeID,
			[]cheques.FundingOutput{{Txid: "swept000swept000swept000swept000swept000swept000swept000swept000"}}, 100_000_000))
		require.NoError(t, cheques.UpdateSwept(t.Context(), db, testWalletID, chequeID,
			"deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef0"))

		_, err = cli.DeleteCheque(t.Context(), connect.NewRequest(&walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		}))
		require.NoError(t, err)

		// Once swept, the row is gone.
		_, err = cheques.Get(t.Context(), db, testWalletID, chequeID)
		require.ErrorIs(t, err, sql.ErrNoRows)
	})
}

func TestService_IsWalletUnlocked(t *testing.T) {
	t.Parallel()

	t.Run("an unencrypted wallet is unlocked", func(t *testing.T) {
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

		_, err := cli.IsWalletUnlocked(t.Context(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
	})

	t.Run("an encrypted wallet is locked at start", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithEncryptedWallet()))

		_, err := cli.IsWalletUnlocked(t.Context(), connect.NewRequest(&emptypb.Empty{}))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func TestService_LockWallet(t *testing.T) {
	t.Parallel()

	t.Run("a locked wallet reads as locked", func(t *testing.T) {
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

		_, err := cli.LockWallet(t.Context(), connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)

		_, err = cli.IsWalletUnlocked(t.Context(), connect.NewRequest(&emptypb.Empty{}))
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
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
		_, err := cli.UnlockWallet(t.Context(), connect.NewRequest(&walletv1.UnlockWalletRequest{
			Password: "anypassword",
		}))
		require.ErrorContains(t, err, "not encrypted")
	})
}

func TestUnlockWalletReportsABadWalletFile(t *testing.T) {
	t.Parallel()

	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithEncryptedWallet()))

	_, err := cli.UnlockWallet(t.Context(), connect.NewRequest(&walletv1.UnlockWalletRequest{Password: "anypassword"}))
	require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	require.EqualError(t, err, "internal: decrypt wallet: invalid ciphertext format")
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

	resp, err := cli.ListSidechainDeposits(t.Context(), connect.NewRequest(&walletv1.ListSidechainDepositsRequest{Slot: 9}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Deposits, 1)
	require.Equal(t, "deadbeef", resp.Msg.Deposits[0].Txid)
	require.Equal(t, int64(50_000), resp.Msg.Deposits[0].Amount)
}

const depositSidechainAddress = "2N4sbtVhMXbzwtNrfACjoGzGkQxSJ9Fz2eP"

func checksummedDepositAddress(slot int, address string) string {
	prefix := fmt.Sprintf("s%d_%s_", slot, address)
	hash := sha256.Sum256([]byte(prefix))
	return prefix + hex.EncodeToString(hash[:3])
}

func TestCreateSidechainDepositSlot(t *testing.T) {
	db := database.Test(t)
	ctrl := gomock.NewController(t)
	mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
	apitests.ExpectOrchestratorReads(mockOrch)
	var deposits []*orchpb.CreateDepositRequest
	mockOrch.EXPECT().
		CreateDeposit(gomock.Any(), gomock.Any()).
		DoAndReturn(func(
			_ any, req *connect.Request[orchpb.CreateDepositRequest],
		) (*connect.Response[orchpb.CreateDepositResponse], error) {
			deposits = append(deposits, req.Msg)
			return connect.NewResponse(&orchpb.CreateDepositResponse{Txid: "deposit-txid"}), nil
		}).
		AnyTimes()
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(mockOrch)))

	createDeposit := func(t *testing.T, slot int64, destination string) error {
		deposits = nil
		_, err := cli.CreateSidechainDeposit(t.Context(), connect.NewRequest(&walletv1.CreateSidechainDepositRequest{
			WalletId:    testWalletID,
			Slot:        slot,
			Destination: destination,
			Amount:      0.001,
			Fee:         0.0001,
		}))
		return err
	}

	t.Run("an address for another slot is refused", func(t *testing.T) {
		err := createDeposit(t, 2, checksummedDepositAddress(9, depositSidechainAddress))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		require.ErrorContains(t, err, "slot 9")
		require.Empty(t, deposits)
	})

	t.Run("an address for the same slot deposits to that slot", func(t *testing.T) {
		require.NoError(t, createDeposit(t, 2, checksummedDepositAddress(2, depositSidechainAddress)))
		require.Len(t, deposits, 1)
		require.Equal(t, int32(2), deposits[0].Slot)
		require.Equal(t, depositSidechainAddress, deposits[0].Destination)
	})

	t.Run("no request slot uses the address slot", func(t *testing.T) {
		require.NoError(t, createDeposit(t, 0, checksummedDepositAddress(9, depositSidechainAddress)))
		require.Len(t, deposits, 1)
		require.Equal(t, int32(9), deposits[0].Slot)
		require.Equal(t, depositSidechainAddress, deposits[0].Destination)
	})

	t.Run("bad input is an invalid argument", func(t *testing.T) {
		for _, tt := range []struct {
			name string
			req  *walletv1.CreateSidechainDepositRequest
		}{
			{name: "address", req: &walletv1.CreateSidechainDepositRequest{Destination: "s2_nonsense_000000", Amount: 0.001, Fee: 0.0001}},
			{name: "no slot", req: &walletv1.CreateSidechainDepositRequest{Destination: depositSidechainAddress, Amount: 0.001, Fee: 0.0001}},
			{name: "slot above 255", req: &walletv1.CreateSidechainDepositRequest{Slot: 256, Destination: depositSidechainAddress, Amount: 0.001, Fee: 0.0001}},
			{name: "zero amount", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: 0, Fee: 0.0001}},
			{name: "negative amount", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: -0.001, Fee: 0.0001}},
			{name: "zero fee", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: 0.001, Fee: 0}},
		} {
			t.Run(tt.name, func(t *testing.T) {
				deposits = nil
				tt.req.WalletId = testWalletID
				_, err := cli.CreateSidechainDeposit(t.Context(), connect.NewRequest(tt.req))
				require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
				require.Empty(t, deposits)
			})
		}
	})

	t.Run("a bare address uses the request slot", func(t *testing.T) {
		require.NoError(t, createDeposit(t, 2, depositSidechainAddress))
		require.Len(t, deposits, 1)
		require.Equal(t, int32(2), deposits[0].Slot)
		require.Equal(t, depositSidechainAddress, deposits[0].Destination)
	})
}

func TestGetTransactionDetails(t *testing.T) {
	t.Parallel()

	spend := &bitcoindv1alpha.GetRawTransactionResponse{
		Txid:    "spend",
		Vsize:   100,
		Inputs:  []*bitcoindv1alpha.Input{{Txid: "parent", Vout: 1}},
		Outputs: []*bitcoindv1alpha.Output{{Amount: 0.28}},
	}
	parent := &bitcoindv1alpha.GetRawTransactionResponse{
		Txid:    "parent",
		Outputs: []*bitcoindv1alpha.Output{{Amount: 1}, {Amount: 0.29}},
	}

	details := func(t *testing.T, parentErr error) (*connect.Response[walletv1.GetTransactionDetailsResponse], error) {
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			GetRawTransaction(gomock.Any(), gomock.Any()).
			DoAndReturn(func(_ context.Context, req *connect.Request[bitcoindv1alpha.GetRawTransactionRequest]) (*connect.Response[bitcoindv1alpha.GetRawTransactionResponse], error) {
				if req.Msg.Txid == "spend" {
					return connect.NewResponse(spend), nil
				}
				if parentErr != nil {
					return nil, parentErr
				}
				return connect.NewResponse(parent), nil
			}).
			AnyTimes()
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithBitcoind(mockBitcoind)))
		return cli.GetTransactionDetails(t.Context(), connect.NewRequest(&walletv1.GetTransactionDetailsRequest{Txid: "spend"}))
	}

	t.Run("the fee is inputs less outputs", func(t *testing.T) {
		resp, err := details(t, nil)
		require.NoError(t, err)
		require.Equal(t, int64(29_000_000), resp.Msg.TotalInputSats)
		require.Equal(t, int64(28_000_000), resp.Msg.TotalOutputSats)
		require.Equal(t, int64(1_000_000), resp.Msg.FeeSats)
	})

	t.Run("a prevout read that fails returns the error", func(t *testing.T) {
		_, err := details(t, connect.NewError(connect.CodeUnavailable, errors.New("node down")))
		require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
		require.ErrorContains(t, err, "node down")
	})
}

type bumpOrchestrator struct {
	*fakeOrchestrator

	errs map[string]error
}

func (b *bumpOrchestrator) ListWallets(
	context.Context, *connect.Request[orchpb.ListWalletsRequest],
) (*connect.Response[orchpb.ListWalletsResponse], error) {
	return connect.NewResponse(&orchpb.ListWalletsResponse{
		Wallets: []*orchpb.WalletMetadata{{Id: "owner"}, {Id: "other"}},
	}), nil
}

func (b *bumpOrchestrator) BumpFee(
	_ context.Context, req *connect.Request[orchpb.BumpFeeRequest],
) (*connect.Response[orchpb.BumpFeeResponse], error) {
	if err, ok := b.errs[req.Msg.WalletId]; ok {
		return nil, err
	}
	return connect.NewResponse(&orchpb.BumpFeeResponse{NewTxid: "replacement"}), nil
}

func TestBumpFee(t *testing.T) {
	t.Parallel()

	notFound := connect.NewError(connect.CodeInternal, errors.New("the chain holds no such transaction"))

	bump := func(t *testing.T, errs map[string]error) (*connect.Response[walletv1.BumpFeeResponse], error) {
		orchestrator := &bumpOrchestrator{fakeOrchestrator: &fakeOrchestrator{}, errs: errs}
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t), apitests.WithOrchestrator(orchestrator)))
		return cli.BumpFee(t.Context(), connect.NewRequest(&walletv1.BumpFeeRequest{Txid: "original"}))
	}

	t.Run("the owner wallet bumps the fee", func(t *testing.T) {
		resp, err := bump(t, map[string]error{"": notFound})
		require.NoError(t, err)
		require.Equal(t, "replacement", resp.Msg.Txid)
	})

	t.Run("the owner wallet error reaches the caller", func(t *testing.T) {
		resp, err := bump(t, map[string]error{
			"":      notFound,
			"owner": connect.NewError(connect.CodeInternal, errors.New("insufficient fee")),
			"other": notFound,
		})
		require.Nil(t, resp)
		require.ErrorContains(t, err, "insufficient fee")
		require.ErrorContains(t, err, `wallet "other"`)
	})
}

func TestGetCoinSelectionStrategy(t *testing.T) {
	t.Parallel()

	get := func(t *testing.T, stored string) (*connect.Response[walletv1.GetCoinSelectionStrategyResponse], error) {
		db := database.Test(t)
		if stored != "" {
			require.NoError(t, preferences.Set(t.Context(), db, preferences.KeyCoinSelectionStrategy, stored))
		}
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db))
		return cli.GetCoinSelectionStrategy(t.Context(), connect.NewRequest(&emptypb.Empty{}))
	}

	t.Run("no value gives the default", func(t *testing.T) {
		resp, err := get(t, "")
		require.NoError(t, err)
		require.Equal(t, walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST, resp.Msg.Strategy)
	})

	t.Run("a stored value reads back", func(t *testing.T) {
		resp, err := get(t, strconv.Itoa(int(walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_SMALLEST_FIRST)))
		require.NoError(t, err)
		require.Equal(t, walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_SMALLEST_FIRST, resp.Msg.Strategy)
	})

	t.Run("a value that is no number fails", func(t *testing.T) {
		_, err := get(t, "largest")
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		require.ErrorContains(t, err, `parse coin selection strategy "largest"`)
	})
}

type statsOrchestrator struct {
	*fakeOrchestrator

	transactions []*orchpb.TransactionEntry
	unspent      []*orchpb.UnspentOutput
}

func (s *statsOrchestrator) ListTransactions(
	context.Context, *connect.Request[orchpb.ListTransactionsRequest],
) (*connect.Response[orchpb.ListTransactionsResponse], error) {
	return connect.NewResponse(&orchpb.ListTransactionsResponse{Transactions: s.transactions}), nil
}

func (s *statsOrchestrator) ListUnspent(
	context.Context, *connect.Request[orchpb.ListUnspentRequest],
) (*connect.Response[orchpb.ListUnspentResponse], error) {
	return connect.NewResponse(&orchpb.ListUnspentResponse{Utxos: s.unspent}), nil
}

func (s *statsOrchestrator) GetSidechainDepositTotals(
	context.Context, *connect.Request[orchpb.GetSidechainDepositTotalsRequest],
) (*connect.Response[orchpb.GetSidechainDepositTotalsResponse], error) {
	return connect.NewResponse(&orchpb.GetSidechainDepositTotalsResponse{TotalSats: 7, RecentSats: 3}), nil
}

func chainTipValidator(t *testing.T, height uint32) *mocks.MockValidatorServiceClient {
	validator := mocks.NewMockValidatorServiceClient(gomock.NewController(t))
	validator.EXPECT().
		GetChainTip(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&mainchainv1.GetChainTipResponse{
			BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{Height: height},
		}), nil)
	return validator
}

func TestGetStats(t *testing.T) {
	t.Parallel()

	const address = "bcrt1qstats"
	blockTime := time.Now().Add(-time.Hour).Unix()

	t.Run("an electrum wallet reports the block of its newest transaction", func(t *testing.T) {
		t.Parallel()

		orchestrator := &statsOrchestrator{
			fakeOrchestrator: &fakeOrchestrator{address: address},
			transactions: []*orchpb.TransactionEntry{
				{Txid: "old", Address: address, AmountSats: 1_000, Confirmations: 10, BlockTime: blockTime - 600},
				{Txid: "new", Address: address, AmountSats: -500, Fee: 0.00000200, Confirmations: 3, BlockTime: blockTime},
				{Txid: "pending", Address: address, AmountSats: 100},
			},
			unspent: []*orchpb.UnspentOutput{
				{Txid: "old", Address: address, AmountSats: 500},
				{Txid: "pending", Vout: 1, Address: address, AmountSats: 100},
			},
		}
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t),
			apitests.WithOrchestrator(orchestrator), apitests.WithValidator(chainTipValidator(t, 100))))

		resp, err := cli.GetStats(t.Context(), connect.NewRequest(&walletv1.GetStatsRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		assert.Equal(t, uint32(98), resp.Msg.LastTxBlockHeight)
		assert.Equal(t, blockTime, resp.Msg.LastTxAt.Seconds)
		assert.Equal(t, uint64(2), resp.Msg.UtxosCurrent)
		assert.Equal(t, uint64(1), resp.Msg.UtxosUniqueAddresses)
		assert.Equal(t, int64(3), resp.Msg.TransactionCountTotal)
		assert.Equal(t, int64(200), resp.Msg.TotalFeesSats)
		assert.Equal(t, int64(7), resp.Msg.SidechainDepositVolume)
		assert.Equal(t, int64(3), resp.Msg.SidechainDepositVolumeLast_30Days)
	})

	t.Run("a down enforcer gives stats with no block height", func(t *testing.T) {
		t.Parallel()

		orchestrator := &statsOrchestrator{
			fakeOrchestrator: &fakeOrchestrator{address: address},
			transactions: []*orchpb.TransactionEntry{
				{Txid: "new", Address: address, AmountSats: 1_000, Confirmations: 3, BlockTime: blockTime},
			},
		}
		validator := mocks.NewMockValidatorServiceClient(gomock.NewController(t))
		validator.EXPECT().
			GetChainTip(gomock.Any(), gomock.Any()).
			Return(nil, connect.NewError(connect.CodeUnavailable, errors.New("enforcer restarts")))
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t),
			apitests.WithOrchestrator(orchestrator), apitests.WithValidator(validator)))

		resp, err := cli.GetStats(t.Context(), connect.NewRequest(&walletv1.GetStatsRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		assert.Equal(t, uint32(0), resp.Msg.LastTxBlockHeight)
		assert.Equal(t, int64(1), resp.Msg.TransactionCountTotal)
	})

	t.Run("a core wallet reports the block of its newest transaction", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{
				Transactions: []*bitcoindv1alpha.GetTransactionResponse{
					{Txid: "new", Amount: 0.001, Confirmations: 2, Time: timestamppb.New(time.Unix(blockTime, 0))},
				},
			}), nil)
		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{{Txid: "new", Address: address, Amount: 0.001}},
			}), nil)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		mockOrch.EXPECT().
			GetSidechainDepositTotals(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.GetSidechainDepositTotalsResponse{}), nil)
		mockOrch.EXPECT().
			CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "core"}), nil).
			AnyTimes()
		mockOrch.EXPECT().
			DeriveAddresses(gomock.Any(), gomock.Any()).
			Return(connect.NewResponse(&orchpb.DeriveAddressesResponse{}), nil).
			AnyTimes()
		apitests.ExpectOrchestratorReads(mockOrch)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, database.Test(t),
			apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind), apitests.WithOrchestrator(mockOrch),
			apitests.WithValidator(chainTipValidator(t, 500))))

		resp, err := cli.GetStats(t.Context(), connect.NewRequest(&walletv1.GetStatsRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		assert.Equal(t, uint32(499), resp.Msg.LastTxBlockHeight)
		assert.Equal(t, uint64(1), resp.Msg.UtxosCurrent)
		assert.Equal(t, int64(1), resp.Msg.TransactionCountTotal)
	})
}

func TestListReceiveAddresses(t *testing.T) {
	t.Parallel()

	t.Run("an electrum wallet sums its UTXOs per address", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		require.NoError(t, addressbook.Create(t.Context(), db, nil, "savings", "bcrt1qone", addressbook.DirectionReceive))
		orchestrator := &statsOrchestrator{
			fakeOrchestrator: &fakeOrchestrator{},
			unspent: []*orchpb.UnspentOutput{
				{Txid: "a", Address: "bcrt1qone", AmountSats: 1_000},
				{Txid: "b", Address: "bcrt1qone", AmountSats: 500},
				{Txid: "c", Address: "bcrt1qtwo", AmountSats: 7},
			},
		}
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(orchestrator)))

		resp, err := cli.ListReceiveAddresses(t.Context(), connect.NewRequest(&walletv1.ListReceiveAddressesRequest{WalletId: testWalletID}))
		require.NoError(t, err)
		assert.ElementsMatch(t, []*walletv1.ReceiveAddress{
			{Address: "bcrt1qone", Label: "savings", CurrentBalanceSat: 1_500},
			{Address: "bcrt1qtwo", CurrentBalanceSat: 7},
		}, resp.Msg.Addresses)
	})
}
