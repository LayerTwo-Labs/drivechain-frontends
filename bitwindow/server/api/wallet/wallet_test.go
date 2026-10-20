package wallet_test

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strconv"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
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

		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			GetBalance(gomock.Any(), gomock.Any()).
			Return(&orchpb.GetBalanceResponse{
				ConfirmedSats:   100000,
				UnconfirmedSats: 50000,
			}, nil)

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithOrchestrator(mockOrch)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetBalance(t.Context(), &walletv1.GetBalanceRequest{
			WalletId: "test-wallet-id-1234",
		})
		require.NoError(t, err)
		require.Equal(t, uint64(100000), resp.ConfirmedSatoshi)
		require.Equal(t, uint64(50000), resp.PendingSatoshi)
	})

}

func TestSendTransaction(t *testing.T) {
	t.Parallel()

	for _, tt := range []struct {
		name    string
		req     *walletv1.SendTransactionRequest
		wantErr string
	}{
		{
			name:    "no destination",
			req:     &walletv1.SendTransactionRequest{},
			wantErr: "the request must include a destination",
		},
		{
			name:    "an amount below dust",
			req:     &walletv1.SendTransactionRequest{Destinations: map[string]uint64{"bcrt1qdest": 545}},
			wantErr: "below dust limit",
		},
		{
			name: "a fee rate and a fixed fee",
			req: &walletv1.SendTransactionRequest{
				Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
				FeeSatPerVbyte: 2,
				FixedFeeSats:   500,
			},
			wantErr: "the request cannot set both fee rate and fixed fee",
		},
		{
			name: "an input with no vout",
			req: &walletv1.SendTransactionRequest{
				Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
				RequiredInputs: []*walletv1.UnspentOutput{{Output: "abcdef"}},
			},
			wantErr: "invalid UTXO format",
		},
		{
			name: "an input with a vout that is no number",
			req: &walletv1.SendTransactionRequest{
				Destinations:   map[string]uint64{"bcrt1qdest": 50_000},
				RequiredInputs: []*walletv1.UnspentOutput{{Output: "txid:abc"}},
			},
			wantErr: "invalid vout",
		},
	} {
		t.Run(tt.name+" is an invalid argument", func(t *testing.T) {
			t.Parallel()

			mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
			apitests.ExpectOrchestratorReads(mockOrch)
			cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(mockOrch)))

			tt.req.WalletId = testWalletID
			_, err := cli.SendTransaction(t.Context(), tt.req)
			require.ErrorContains(t, err, tt.wantErr)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}

	t.Run("an amount at the dust limit sends", func(t *testing.T) {
		t.Parallel()

		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			SendTransaction(gomock.Any(), gomock.Cond(func(req *orchpb.SendTransactionRequest) bool {
				return req.Destinations["bcrt1qdest"] == 546
			})).
			Return(&orchpb.SendTransactionResponse{Txid: "sent"}, nil)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(mockOrch)))

		resp, err := cli.SendTransaction(t.Context(), &walletv1.SendTransactionRequest{
			WalletId:     testWalletID,
			Destinations: map[string]uint64{"bcrt1qdest": 546},
		})
		require.NoError(t, err)
		assert.Equal(t, "sent", resp.Txid)
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
				Return(connectv1.NewResponse(&bitcoindv1alpha.GetBalancesResponse{
					Mine: &bitcoindv1alpha.GetBalancesResponse_Mine{Trusted: tt.btc, UntrustedPending: tt.btc, Immature: tt.btc},
				}), nil)
			apitests.ExpectCoreWalletSetup(mockBitcoind)
			cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

			resp, err := cli.GetBalance(t.Context(), &walletv1.GetBalanceRequest{WalletId: testWalletID})
			require.NoError(t, err)
			require.Equal(t, tt.sats, resp.ConfirmedSatoshi)
			require.Equal(t, tt.sats, resp.PendingSatoshi)
			require.Equal(t, tt.sats, resp.ImmatureSatoshi)
		})
	}
}

func TestGetBalanceSumsMineAndWatchOnly(t *testing.T) {
	t.Parallel()

	for _, tt := range []struct {
		name string
		resp *bitcoindv1alpha.GetBalancesResponse
		sats uint64
	}{
		{
			name: "descriptor wallet with no watchonly key",
			resp: &bitcoindv1alpha.GetBalancesResponse{
				Mine: &bitcoindv1alpha.GetBalancesResponse_Mine{Trusted: 0.5, UntrustedPending: 0.5, Immature: 0.5},
			},
			sats: 50_000_000,
		},
		{
			name: "legacy wallet with watchonly coins",
			resp: &bitcoindv1alpha.GetBalancesResponse{
				Mine:      &bitcoindv1alpha.GetBalancesResponse_Mine{},
				Watchonly: &bitcoindv1alpha.GetBalancesResponse_Watchonly{Trusted: 0.5, UntrustedPending: 0.5, Immature: 0.5},
			},
			sats: 50_000_000,
		},
		{
			name: "both keys",
			resp: &bitcoindv1alpha.GetBalancesResponse{
				Mine:      &bitcoindv1alpha.GetBalancesResponse_Mine{Trusted: 0.25, UntrustedPending: 0.25, Immature: 0.25},
				Watchonly: &bitcoindv1alpha.GetBalancesResponse_Watchonly{Trusted: 0.5, UntrustedPending: 0.5, Immature: 0.5},
			},
			sats: 75_000_000,
		},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			db := database.Test(t)
			mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			mockBitcoind.EXPECT().
				GetBalances(gomock.Any(), gomock.Any()).
				Return(connectv1.NewResponse(tt.resp), nil)
			mockBitcoind.EXPECT().
				LoadWallet(gomock.Any(), gomock.Any()).
				Return(nil, errors.New("wallet file not found")).
				AnyTimes()
			apitests.ExpectCoreWalletSetup(mockBitcoind)
			cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db,
				apitests.WithCoreWallet(), apitests.WithWatchOnlyWallet(), apitests.WithBitcoind(mockBitcoind)))

			resp, err := cli.GetBalance(t.Context(), &walletv1.GetBalanceRequest{WalletId: testWalletID})
			require.NoError(t, err)
			assert.Equal(t, tt.sats, resp.ConfirmedSatoshi)
			assert.Equal(t, tt.sats, resp.PendingSatoshi)
			assert.Equal(t, tt.sats, resp.ImmatureSatoshi)
		})
	}
}

func TestListUnspentRoundsBTCToSats(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		Return(connectv1.NewResponse(&bitcoindv1alpha.ListUnspentResponse{
			Unspent: []*bitcoindv1alpha.UnspentOutput{{Txid: "aa", Vout: 1, Address: "bcrt1qtest", Amount: 0.29}},
		}), nil)
	apitests.ExpectCoreWalletSetup(mockBitcoind)
	cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

	resp, err := cli.ListUnspent(t.Context(), &walletv1.ListUnspentRequest{WalletId: testWalletID})
	require.NoError(t, err)
	require.Len(t, resp.Utxos, 1)
	require.Equal(t, uint64(29_000_000), resp.Utxos[0].ValueSats)
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
			Return(&orchpb.GetNewAddressResponse{Address: "bc1qtest123456789"}, nil)

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithOrchestrator(mockOrch)))

		// Use the test wallet ID from apitests.createTestWalletJSON
		resp, err := cli.GetNewAddress(t.Context(), &walletv1.GetNewAddressRequest{
			WalletId: "test-wallet-id-1234",
		})
		require.NoError(t, err)
		require.Equal(t, "bc1qtest123456789", resp.Address)
	})

	t.Run("an address the book holds returns again", func(t *testing.T) {
		t.Parallel()

		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		apitests.ExpectOrchestratorReads(mockOrch)
		mockOrch.EXPECT().
			GetNewAddress(gomock.Any(), gomock.Any()).
			Return(&orchpb.GetNewAddressResponse{Address: "bc1qtest123456789"}, nil).
			Times(2)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(mockOrch)))

		for range 2 {
			resp, err := cli.GetNewAddress(t.Context(), &walletv1.GetNewAddressRequest{WalletId: testWalletID})
			require.NoError(t, err)
			require.Equal(t, "bc1qtest123456789", resp.Address)
		}
	})
}

func TestService_CreateCheque(t *testing.T) {
	t.Parallel()

	t.Run("an empty wallet id is an invalid argument", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))

		_, err := cli.CreateCheque(t.Context(), &walletv1.CreateChequeRequest{ExpectedAmountSats: 1000})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("a locked wallet refuses", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithPasswordWallet()))

		_, err := cli.CreateCheque(t.Context(), &walletv1.CreateChequeRequest{WalletId: testWalletID, ExpectedAmountSats: 1000})
		require.ErrorContains(t, err, "wallet is locked")
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		list, err := cheques.List(t.Context(), db, testWalletID)
		require.NoError(t, err)
		assert.Empty(t, list)
	})

	t.Run("a wallet with no seed keeps the orchestrator code", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t),
			apitests.WithOrchestrator(seedlessOrchestrator{&fakeOrchestrator{}})))

		_, err := cli.CreateCheque(t.Context(), &walletv1.CreateChequeRequest{WalletId: testWalletID, ExpectedAmountSats: 1000})
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

type seedlessOrchestrator struct {
	*fakeOrchestrator
}

func (seedlessOrchestrator) GetWalletSeed(
	context.Context, *orchpb.GetWalletSeedRequest,
) (*orchpb.GetWalletSeedResponse, error) {
	return nil, connect.NewError(connect.CodeFailedPrecondition, "wallet has no seed")
}

func TestService_GetChequePrivateKey(t *testing.T) {
	t.Parallel()

	t.Run("a locked wallet refuses", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "tb1qtestaddress000000000000000000000000000")
		require.NoError(t, err)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithPasswordWallet()))

		_, err = cli.GetChequePrivateKey(t.Context(), &walletv1.GetChequePrivateKeyRequest{WalletId: testWalletID, Id: chequeID})
		require.ErrorContains(t, err, "wallet is locked")
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("the key spends from the cheque address", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t)))
		created, err := cli.CreateCheque(t.Context(), &walletv1.CreateChequeRequest{WalletId: testWalletID, ExpectedAmountSats: 1000})
		require.NoError(t, err)

		resp, err := cli.GetChequePrivateKey(t.Context(), &walletv1.GetChequePrivateKeyRequest{WalletId: testWalletID, Id: created.Id})
		require.NoError(t, err)

		wif, err := btcutil.DecodeWIF(resp.PrivateKeyWif)
		require.NoError(t, err)
		address, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(wif.SerializePubKey()), &chaincfg.SigNetParams)
		require.NoError(t, err)
		assert.Equal(t, created.Address, address.EncodeAddress())
	})

	t.Run("a wallet with no seed keeps the orchestrator code", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "tb1qtestaddress000000000000000000000000000")
		require.NoError(t, err)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db,
			apitests.WithOrchestrator(seedlessOrchestrator{&fakeOrchestrator{}})))

		_, err = cli.GetChequePrivateKey(t.Context(), &walletv1.GetChequePrivateKeyRequest{WalletId: testWalletID, Id: chequeID})
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func TestService_SignMessage(t *testing.T) {
	t.Parallel()

	t.Run("a signature verifies without a node", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t)))
		const message = "signed by Bjørn"
		for _, address := range []string{fixtureSegwitAddress(t, 2), fixtureTaprootAddress(t, 1)} {
			signed, err := cli.SignMessage(t.Context(), &walletv1.SignMessageRequest{
				WalletId: testWalletID,
				Message:  message,
				Address:  address,
			})
			require.NoError(t, err)

			for _, tc := range []struct {
				message string
				valid   bool
			}{{message, true}, {message + " ", false}} {
				verified, err := cli.VerifyMessage(t.Context(), &walletv1.VerifyMessageRequest{
					Message:   tc.message,
					Signature: signed.Signature,
					PublicKey: address,
				})
				require.NoError(t, err)
				assert.Equal(t, tc.valid, verified.Valid)
			}
		}
	})

	t.Run("a locked wallet refuses", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))

		_, err := cli.SignMessage(t.Context(), &walletv1.SignMessageRequest{
			WalletId: testWalletID,
			Address:  "tb1qtestaddress000000000000000000000000000",
			Message:  "hello",
		})
		require.ErrorContains(t, err, "wallet is locked")
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("an address of another wallet is an invalid argument", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t)))

		_, err := cli.SignMessage(t.Context(), &walletv1.SignMessageRequest{
			WalletId: testWalletID,
			Address:  "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl",
			Message:  "hello",
		})
		require.ErrorContains(t, err, "is not one of the wallet's first")
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("a wallet with no seed is a failed precondition", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithWatchOnlyWallet()))

		_, err := cli.SignMessage(t.Context(), &walletv1.SignMessageRequest{
			WalletId: testWalletID,
			Address:  "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl",
			Message:  "hello",
		})
		require.ErrorContains(t, err, "holds no master seed")
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListCheques(t.Context(), &walletv1.ListChequesRequest{
			WalletId: "test-wallet-id-1234",
		})
		require.NoError(t, err)
		require.Empty(t, resp.Cheques)
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.GetCheque(t.Context(), &walletv1.GetChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		})
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.DeleteCheque(t.Context(), &walletv1.DeleteChequeRequest{
			WalletId: "test-wallet-id-1234",
			Id:       99999,
		})
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithBitcoind(mockBitcoind)))
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

		_, err = cli.DeleteCheque(t.Context(), &walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		})
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

		_, err = cli.DeleteCheque(t.Context(), &walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		})
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

		_, err = cli.DeleteCheque(t.Context(), &walletv1.DeleteChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		})
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithBitcoind(mockBitcoind)))

		_, err := cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
	})

	t.Run("an encrypted wallet is locked at start", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))

		_, err := cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func TestService_LockWallet(t *testing.T) {
	t.Parallel()

	t.Run("a wallet with no password refuses the lock", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t)))

		_, err := cli.LockWallet(t.Context(), &emptypb.Empty{})
		require.ErrorContains(t, err, "wallet is not encrypted")
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
	})

	t.Run("a locked password wallet unlocks again", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))
		unlock := func() error {
			_, err := cli.UnlockWallet(t.Context(), &walletv1.UnlockWalletRequest{Password: apitests.EncryptedWalletPassword})
			return err
		}
		require.NoError(t, unlock())

		_, err := cli.LockWallet(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
		_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		require.NoError(t, unlock())
		_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
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
			Return(&connectv1.Response[bitcoindv1alpha.ListWalletsResponse]{
				Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{}},
			}, nil).AnyTimes()
		mockBitcoind.EXPECT().
			CreateWallet(gomock.Any(), gomock.Any()).
			Return(&connectv1.Response[bitcoindv1alpha.CreateWalletResponse]{
				Msg: &bitcoindv1alpha.CreateWalletResponse{Name: "test_wallet"},
			}, nil).AnyTimes()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database, apitests.WithBitcoind(mockBitcoind)))

		// Test wallet is not encrypted, so unlock should fail
		_, err := cli.UnlockWallet(t.Context(), &walletv1.UnlockWalletRequest{
			Password: "anypassword",
		})
		require.ErrorContains(t, err, "not encrypted")
	})

	t.Run("the right password unlocks", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))
		_, err := cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

		_, err = cli.UnlockWallet(t.Context(), &walletv1.UnlockWalletRequest{Password: apitests.EncryptedWalletPassword})
		require.NoError(t, err)

		_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
	})

	t.Run("a wrong password is unauthenticated", func(t *testing.T) {
		t.Parallel()

		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithPasswordWallet()))

		_, err := cli.UnlockWallet(t.Context(), &walletv1.UnlockWalletRequest{Password: "wrong"})
		require.ErrorContains(t, err, "incorrect password")
		assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))

		_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})
}

func TestOrchestratorLockStateShowsInBitwindowd(t *testing.T) {
	t.Parallel()

	orchestrator := apitests.PasswordWalletOrchestrator(t)
	cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(orchestrator)))

	_, err := orchestrator.UnlockWallet(t.Context(), &orchpb.UnlockWalletRequest{Password: apitests.EncryptedWalletPassword})
	require.NoError(t, err)
	_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
	require.NoError(t, err)

	_, err = orchestrator.LockWallet(t.Context(), &orchpb.LockWalletRequest{})
	require.NoError(t, err)
	_, err = cli.IsWalletUnlocked(t.Context(), &emptypb.Empty{})
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
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
		Return(&orchpb.ListSidechainDepositsResponse{
			Deposits: []*orchpb.SidechainDeposit{
				{Txid: "deadbeef", Slot: 9, AmountSats: 50_000},
			},
		}, nil)

	cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database,
		apitests.WithBitcoind(mockBitcoind), apitests.WithOrchestrator(mockOrch)))

	resp, err := cli.ListSidechainDeposits(t.Context(), &walletv1.ListSidechainDepositsRequest{Slot: 9})
	require.NoError(t, err)
	require.Len(t, resp.Deposits, 1)
	require.Equal(t, "deadbeef", resp.Deposits[0].Txid)
	require.Equal(t, int64(50_000), resp.Deposits[0].Amount)
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
			_ any, req *orchpb.CreateDepositRequest,
		) (*orchpb.CreateDepositResponse, error) {
			deposits = append(deposits, req)
			return &orchpb.CreateDepositResponse{Txid: "deposit-txid"}, nil
		}).
		AnyTimes()
	cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithOrchestrator(mockOrch)))

	createDeposit := func(t *testing.T, slot int64, destination string) error {
		deposits = nil
		_, err := cli.CreateSidechainDeposit(t.Context(), &walletv1.CreateSidechainDepositRequest{
			WalletId:    testWalletID,
			Slot:        slot,
			Destination: destination,
			Amount:      0.001,
			Fee:         0.0001,
		})
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
			{name: "negative slot", req: &walletv1.CreateSidechainDepositRequest{Slot: -1, Destination: depositSidechainAddress, Amount: 0.001, Fee: 0.0001}},
			{name: "slot above 255", req: &walletv1.CreateSidechainDepositRequest{Slot: 256, Destination: depositSidechainAddress, Amount: 0.001, Fee: 0.0001}},
			{name: "zero amount", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: 0, Fee: 0.0001}},
			{name: "negative amount", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: -0.001, Fee: 0.0001}},
			{name: "zero fee", req: &walletv1.CreateSidechainDepositRequest{Slot: 2, Destination: depositSidechainAddress, Amount: 0.001, Fee: 0}},
		} {
			t.Run(tt.name, func(t *testing.T) {
				deposits = nil
				tt.req.WalletId = testWalletID
				_, err := cli.CreateSidechainDeposit(t.Context(), tt.req)
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

	spend := func(prevOut *bitcoindv1alpha.PreviousOutput) *bitcoindv1alpha.GetRawTransactionResponse {
		return &bitcoindv1alpha.GetRawTransactionResponse{
			Txid:    "spend",
			Vsize:   100,
			Inputs:  []*bitcoindv1alpha.Input{{Txid: "parent", Vout: 1, PreviousOutput: prevOut}},
			Outputs: []*bitcoindv1alpha.Output{{Amount: 0.28}},
		}
	}

	details := func(t *testing.T, tx *bitcoindv1alpha.GetRawTransactionResponse) (*walletv1.GetTransactionDetailsResponse, error) {
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			GetRawTransaction(gomock.Any(), gomock.Any()).
			Times(1).
			Return(connectv1.NewResponse(tx), nil)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithBitcoind(mockBitcoind)))
		return cli.GetTransactionDetails(t.Context(), &walletv1.GetTransactionDetailsRequest{Txid: "spend"})
	}

	t.Run("the fee is inputs less outputs", func(t *testing.T) {
		resp, err := details(t, spend(&bitcoindv1alpha.PreviousOutput{
			Amount:       0.29,
			ScriptPubKey: &bitcoindv1alpha.ScriptPubKey{Address: "tb1qparent"},
		}))
		require.NoError(t, err)
		assert.Equal(t, int64(29_000_000), resp.TotalInputSats)
		assert.Equal(t, int64(28_000_000), resp.TotalOutputSats)
		assert.Equal(t, int64(1_000_000), resp.FeeSats)
		require.Len(t, resp.Inputs, 1)
		assert.Equal(t, "tb1qparent", resp.Inputs[0].Address)
	})

	withParent := func(t *testing.T, parentOutputs []*bitcoindv1alpha.Output) (*walletv1.GetTransactionDetailsResponse, error) {
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			GetRawTransaction(gomock.Any(), gomock.Any()).
			Times(2).
			DoAndReturn(func(_ context.Context, req *connectv1.Request[bitcoindv1alpha.GetRawTransactionRequest]) (*connectv1.Response[bitcoindv1alpha.GetRawTransactionResponse], error) {
				if req.Msg.Txid == "parent" {
					return connectv1.NewResponse(&bitcoindv1alpha.GetRawTransactionResponse{Txid: "parent", Outputs: parentOutputs}), nil
				}
				return connectv1.NewResponse(spend(nil)), nil
			})
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithBitcoind(mockBitcoind)))
		return cli.GetTransactionDetails(t.Context(), &walletv1.GetTransactionDetailsRequest{Txid: "spend"})
	}

	t.Run("an input with no prevout reads the parent", func(t *testing.T) {
		resp, err := withParent(t, []*bitcoindv1alpha.Output{
			{Amount: 0.5},
			{Amount: 0.29, ScriptPubKey: &bitcoindv1alpha.ScriptPubKey{Address: "tb1qparent"}},
		})
		require.NoError(t, err)
		assert.Equal(t, int64(29_000_000), resp.TotalInputSats)
		assert.Equal(t, int64(1_000_000), resp.FeeSats)
		require.Len(t, resp.Inputs, 1)
		assert.Equal(t, "tb1qparent", resp.Inputs[0].Address)
	})

	t.Run("a parent with no such output returns an error", func(t *testing.T) {
		_, err := withParent(t, []*bitcoindv1alpha.Output{{Amount: 0.5}})
		require.Equal(t, connect.CodeUnknown, connect.CodeOf(err))
		require.NotContains(t, err.Error(), "previous transaction parent has no output 1")
	})

	for _, tt := range []struct {
		name     string
		readErr  error
		wantCode connect.Code
	}{
		{name: "an unknown txid is not found", readErr: errors.New("-5: No such mempool or blockchain transaction. Use gettransaction for wallet transactions."), wantCode: connect.CodeNotFound},
		{name: "a down node keeps its code", readErr: connect.NewError(connect.CodeUnavailable, "node down"), wantCode: connect.CodeUnavailable},
	} {
		t.Run(tt.name, func(t *testing.T) {
			mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
			mockBitcoind.EXPECT().
				GetRawTransaction(gomock.Any(), gomock.Any()).
				Return(nil, tt.readErr)
			apitests.ExpectCoreWalletSetup(mockBitcoind)
			cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithBitcoind(mockBitcoind)))

			_, err := cli.GetTransactionDetails(t.Context(), &walletv1.GetTransactionDetailsRequest{Txid: "spend"})
			assert.Equal(t, tt.wantCode, connect.CodeOf(err))
		})
	}
}

type bumpOrchestrator struct {
	*fakeOrchestrator

	errs map[string]error
}

func (b *bumpOrchestrator) ListWallets(
	context.Context, *orchpb.ListWalletsRequest,
) (*orchpb.ListWalletsResponse, error) {
	return &orchpb.ListWalletsResponse{
		Wallets: []*orchpb.WalletMetadata{{Id: "owner"}, {Id: "other"}},
	}, nil
}

func (b *bumpOrchestrator) BumpFee(
	_ context.Context, req *orchpb.BumpFeeRequest,
) (*orchpb.BumpFeeResponse, error) {
	if err, ok := b.errs[req.WalletId]; ok {
		return nil, err
	}
	return &orchpb.BumpFeeResponse{NewTxid: "replacement"}, nil
}

func TestBumpFee(t *testing.T) {
	t.Parallel()

	notFound := connect.NewError(connect.CodeInternal, "the chain holds no such transaction")

	bump := func(t *testing.T, errs map[string]error) (*walletv1.BumpFeeResponse, error) {
		orchestrator := &bumpOrchestrator{fakeOrchestrator: &fakeOrchestrator{}, errs: errs}
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(orchestrator)))
		return cli.BumpFee(t.Context(), &walletv1.BumpFeeRequest{Txid: "original"})
	}

	t.Run("the owner wallet bumps the fee", func(t *testing.T) {
		resp, err := bump(t, map[string]error{"": notFound})
		require.NoError(t, err)
		require.Equal(t, "replacement", resp.Txid)
	})

	t.Run("the owner wallet error reaches the caller", func(t *testing.T) {
		resp, err := bump(t, map[string]error{
			"":      notFound,
			"owner": connect.NewError(connect.CodeInternal, "insufficient fee"),
			"other": notFound,
		})
		require.Nil(t, resp)
		require.ErrorContains(t, err, "insufficient fee")
		require.ErrorContains(t, err, `wallet "other"`)
	})
}

func TestGetCoinSelectionStrategy(t *testing.T) {
	t.Parallel()

	get := func(t *testing.T, stored string) (*walletv1.GetCoinSelectionStrategyResponse, error) {
		db := database.Test(t)
		if stored != "" {
			require.NoError(t, preferences.Set(t.Context(), db, preferences.KeyCoinSelectionStrategy, stored))
		}
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db))
		return cli.GetCoinSelectionStrategy(t.Context(), &emptypb.Empty{})
	}

	t.Run("no value gives the default", func(t *testing.T) {
		resp, err := get(t, "")
		require.NoError(t, err)
		require.Equal(t, walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_LARGEST_FIRST, resp.Strategy)
	})

	t.Run("a stored value reads back", func(t *testing.T) {
		resp, err := get(t, strconv.Itoa(int(walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_SMALLEST_FIRST)))
		require.NoError(t, err)
		require.Equal(t, walletv1.CoinSelectionStrategy_COIN_SELECTION_STRATEGY_SMALLEST_FIRST, resp.Strategy)
	})

	t.Run("a value that is no number fails", func(t *testing.T) {
		_, err := get(t, "largest")
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		require.ErrorContains(t, err, `parse coin selection strategy "largest"`)
	})
}

func TestListTransactions(t *testing.T) {
	t.Parallel()

	t.Run("electrum gives one transaction for a send to two payees", func(t *testing.T) {
		t.Parallel()

		orchestrator := &statsOrchestrator{
			fakeOrchestrator: &fakeOrchestrator{},
			transactions: []*orchpb.TransactionEntry{
				{Txid: "pay2", Category: "send", Address: "bcrt1qa", AmountSats: -1_000, Fee: -0.00000300},
				{Txid: "pay2", Category: "send", Address: "bcrt1qb", AmountSats: -2_000},
				{Txid: "other", Category: "receive", Address: "bcrt1qc", AmountSats: 500},
			},
		}
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(orchestrator)))

		resp, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		require.Len(t, resp.Transactions, 2)
		pay := resp.Transactions[0]
		assert.Equal(t, "pay2", pay.Txid)
		assert.Equal(t, "bcrt1qa", pay.Address)
		assert.Equal(t, uint64(3_000), pay.SentSatoshi)
		assert.Equal(t, uint64(0), pay.ReceivedSatoshi)
		assert.Equal(t, uint64(300), pay.FeeSats)
		assert.Equal(t, "other", resp.Transactions[1].Txid)
	})

	t.Run("core gives one transaction for a send to two payees", func(t *testing.T) {
		t.Parallel()

		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connectv1.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{
				Transactions: []*bitcoindv1alpha.GetTransactionResponse{
					{Txid: "pay2", Amount: -0.00001, Fee: -0.000003},
					{Txid: "pay2", Amount: -0.00002, Fee: -0.000003},
				},
			}), nil)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		require.Len(t, resp.Transactions, 1)
		assert.Equal(t, uint64(3_000), resp.Transactions[0].SentSatoshi)
		assert.Equal(t, uint64(300), resp.Transactions[0].FeeSats)
	})

	t.Run("core pages until a short page", func(t *testing.T) {
		t.Parallel()

		page := func(n int, prefix string) *connectv1.Response[bitcoindv1alpha.ListTransactionsResponse] {
			txs := make([]*bitcoindv1alpha.GetTransactionResponse, n)
			for i := range txs {
				txs[i] = &bitcoindv1alpha.GetTransactionResponse{Txid: fmt.Sprintf("%s%d", prefix, i), Amount: 0.001}
			}
			return connectv1.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{Transactions: txs})
		}
		skip := func(n uint32) any {
			return gomock.Cond(func(req *connectv1.Request[bitcoindv1alpha.ListTransactionsRequest]) bool {
				return req.Msg.Count == 1000 && req.Msg.Skip == n
			})
		}
		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		gomock.InOrder(
			mockBitcoind.EXPECT().ListTransactions(gomock.Any(), skip(0)).Return(page(1000, "a"), nil),
			mockBitcoind.EXPECT().ListTransactions(gomock.Any(), skip(1000)).Return(page(1000, "b"), nil),
			mockBitcoind.EXPECT().ListTransactions(gomock.Any(), skip(2000)).Return(page(1, "c"), nil),
		)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		assert.Len(t, resp.Transactions, 2001)
	})

	t.Run("core reads the tip from core, not from the enforcer", func(t *testing.T) {
		t.Parallel()

		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connectv1.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{
				Transactions: []*bitcoindv1alpha.GetTransactionResponse{
					{Txid: "tx", Amount: 0.001, Confirmations: 3, Time: timestamppb.Now()},
				},
			}), nil)
		expectCoreTip(mockBitcoind, 300)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		require.Len(t, resp.Transactions, 1)
		assert.Equal(t, uint32(298), resp.Transactions[0].ConfirmationTime.Height)
	})

	t.Run("a failed core tip read gives no heights and no error", func(t *testing.T) {
		t.Parallel()

		mockBitcoind := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connectv1.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{
				Transactions: []*bitcoindv1alpha.GetTransactionResponse{
					{Txid: "tx", Amount: 0.001, Confirmations: 3, Time: timestamppb.Now()},
				},
			}), nil)
		mockBitcoind.EXPECT().
			GetBlockchainInfo(gomock.Any(), gomock.Any()).
			Return(nil, connectv1.NewError(connectv1.CodeUnavailable, errors.New("core restarts")))
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithCoreWallet(), apitests.WithBitcoind(mockBitcoind)))

		resp, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		require.Len(t, resp.Transactions, 1)
		assert.Equal(t, uint32(0), resp.Transactions[0].ConfirmationTime.Height)
	})

	t.Run("electrum asks for all rows", func(t *testing.T) {
		t.Parallel()

		mockOrch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		mockOrch.EXPECT().
			ListTransactions(gomock.Any(), gomock.Cond(func(req *orchpb.ListTransactionsRequest) bool {
				return req.Count == math.MaxInt32
			})).
			Return(&orchpb.ListTransactionsResponse{}, nil)
		apitests.ExpectOrchestratorReads(mockOrch)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(mockOrch)))

		_, err := cli.ListTransactions(t.Context(), &walletv1.ListTransactionsRequest{WalletId: testWalletID})
		require.NoError(t, err)
	})
}

type statsOrchestrator struct {
	*fakeOrchestrator

	transactions []*orchpb.TransactionEntry
	unspent      []*orchpb.UnspentOutput
}

func (s *statsOrchestrator) ListTransactions(
	context.Context, *orchpb.ListTransactionsRequest,
) (*orchpb.ListTransactionsResponse, error) {
	return &orchpb.ListTransactionsResponse{Transactions: s.transactions}, nil
}

func (s *statsOrchestrator) ListUnspent(
	context.Context, *orchpb.ListUnspentRequest,
) (*orchpb.ListUnspentResponse, error) {
	return &orchpb.ListUnspentResponse{Utxos: s.unspent}, nil
}

func (s *statsOrchestrator) GetSidechainDepositTotals(
	context.Context, *orchpb.GetSidechainDepositTotalsRequest,
) (*orchpb.GetSidechainDepositTotalsResponse, error) {
	return &orchpb.GetSidechainDepositTotalsResponse{TotalSats: 7, RecentSats: 3}, nil
}

func chainTipValidator(t *testing.T, height uint32) *mocks.MockValidatorServiceClient {
	validator := mocks.NewMockValidatorServiceClient(gomock.NewController(t))
	validator.EXPECT().
		GetChainTip(gomock.Any(), gomock.Any()).
		Return(&mainchainv1.GetChainTipResponse{
			BlockHeaderInfo: &mainchainv1.BlockHeaderInfo{Height: height},
		}, nil)
	return validator
}

func TestGetUTXODistribution(t *testing.T) {
	t.Parallel()

	for _, tt := range []struct {
		name       string
		values     []int64
		maxBuckets int32
		want       []*walletv1.UTXOBucket
	}{
		{
			name:   "values below 0.0001 get exact labels",
			values: []int64{546, 999, 1_000, 4_999, 9_999},
			want: []*walletv1.UTXOBucket{
				{Label: "0.00000546 - 0.00000999", ValueSats: 1_545, Count: 2},
				{Label: "0.00001 - 0.00004999", ValueSats: 5_999, Count: 2},
				{Label: "0.00005 - 0.00009999", ValueSats: 9_999, Count: 1},
			},
		},
		{
			name:   "one value is one bucket",
			values: []int64{100_000_000},
			want:   []*walletv1.UTXOBucket{{Label: "1.0 - 1.0", ValueSats: 100_000_000, Count: 1}},
		},
		{
			name:       "a wide range keeps to the bucket cap",
			values:     []int64{546, 50_000, 1_000_000_000},
			maxBuckets: 3,
			want: []*walletv1.UTXOBucket{
				{Label: "0.00000546 - 0.00000999", ValueSats: 546, Count: 1},
				{Label: "0.00001 - 0.010", ValueSats: 50_000, Count: 1},
				{Label: "0.01 - 10.0", ValueSats: 1_000_000_000, Count: 1},
			},
		},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			orchestrator := &statsOrchestrator{fakeOrchestrator: &fakeOrchestrator{}}
			for i, v := range tt.values {
				orchestrator.unspent = append(orchestrator.unspent, &orchpb.UnspentOutput{Txid: "tx", Vout: int32(i), Address: "bcrt1q", AmountSats: v})
			}
			cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(orchestrator)))

			resp, err := cli.GetUTXODistribution(t.Context(), &walletv1.GetUTXODistributionRequest{
				WalletId:   testWalletID,
				MaxBuckets: tt.maxBuckets,
			})
			require.NoError(t, err)
			require.Len(t, resp.Buckets, len(tt.want))
			for i, want := range tt.want {
				got := resp.Buckets[i]
				assert.Equal(t, want.Label, got.Label)
				assert.Equal(t, want.ValueSats, got.ValueSats)
				assert.Equal(t, want.Count, got.Count)
			}
		})
	}
}

func expectCoreTip(mock *mocks.MockBitcoinServiceClient, height uint32) {
	mock.EXPECT().
		GetBlockchainInfo(gomock.Any(), gomock.Any()).
		Return(connectv1.NewResponse(&bitcoindv1alpha.GetBlockchainInfoResponse{Blocks: height}), nil)
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
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t),
			apitests.WithOrchestrator(orchestrator), apitests.WithValidator(chainTipValidator(t, 100))))

		resp, err := cli.GetStats(t.Context(), &walletv1.GetStatsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		assert.Equal(t, uint32(98), resp.LastTxBlockHeight)
		assert.Equal(t, blockTime, resp.LastTxAt.Seconds)
		assert.Equal(t, uint64(2), resp.UtxosCurrent)
		assert.Equal(t, uint64(1), resp.UtxosUniqueAddresses)
		assert.Equal(t, int64(3), resp.TransactionCountTotal)
		assert.Equal(t, int64(200), resp.TotalFeesSats)
		assert.Equal(t, int64(7), resp.SidechainDepositVolume)
		assert.Equal(t, int64(3), resp.SidechainDepositVolumeLast_30Days)
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
			Return(nil, connect.NewError(connect.CodeUnavailable, "enforcer restarts"))
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t),
			apitests.WithOrchestrator(orchestrator), apitests.WithValidator(validator)))

		resp, err := cli.GetStats(t.Context(), &walletv1.GetStatsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		assert.Equal(t, uint32(0), resp.LastTxBlockHeight)
		assert.Equal(t, int64(1), resp.TransactionCountTotal)
	})

	t.Run("a core wallet reports the block of its newest transaction", func(t *testing.T) {
		t.Parallel()

		ctrl := gomock.NewController(t)
		mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(connectv1.NewResponse(&bitcoindv1alpha.ListTransactionsResponse{
				Transactions: []*bitcoindv1alpha.GetTransactionResponse{
					{Txid: "new", Amount: 0.001, Confirmations: 2, Time: timestamppb.New(time.Unix(blockTime, 0))},
				},
			}), nil)
		mockBitcoind.EXPECT().
			ListUnspent(gomock.Any(), gomock.Any()).
			Return(connectv1.NewResponse(&bitcoindv1alpha.ListUnspentResponse{
				Unspent: []*bitcoindv1alpha.UnspentOutput{{Txid: "new", Address: address, Amount: 0.001}},
			}), nil)
		expectCoreTip(mockBitcoind, 500)
		apitests.ExpectCoreWalletSetup(mockBitcoind)
		mockOrch := mocks.NewMockWalletManagerServiceClient(ctrl)
		mockOrch.EXPECT().
			GetSidechainDepositTotals(gomock.Any(), gomock.Any()).
			Return(&orchpb.GetSidechainDepositTotalsResponse{}, nil)
		mockOrch.EXPECT().
			CreateBitcoinCoreWallet(gomock.Any(), gomock.Any()).
			Return(&orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: "core"}, nil).
			AnyTimes()
		mockOrch.EXPECT().
			DeriveAddresses(gomock.Any(), gomock.Any()).
			Return(&orchpb.DeriveAddressesResponse{}, nil).
			AnyTimes()
		mockOrch.EXPECT().
			ListWallets(gomock.Any(), gomock.Any()).
			Return(&orchpb.ListWalletsResponse{
				Wallets:        []*orchpb.WalletMetadata{{Id: testWalletID, WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE}},
				ActiveWalletId: testWalletID,
			}, nil).
			AnyTimes()
		apitests.ExpectOrchestratorReads(mockOrch)
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, database.Test(t),
			apitests.WithBitcoind(mockBitcoind), apitests.WithOrchestrator(mockOrch)))

		resp, err := cli.GetStats(t.Context(), &walletv1.GetStatsRequest{WalletId: testWalletID})
		require.NoError(t, err)
		assert.Equal(t, uint32(499), resp.LastTxBlockHeight)
		assert.Equal(t, uint64(1), resp.UtxosCurrent)
		assert.Equal(t, int64(1), resp.TransactionCountTotal)
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
		cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db, apitests.WithOrchestrator(orchestrator)))

		resp, err := cli.ListReceiveAddresses(t.Context(), &walletv1.ListReceiveAddressesRequest{WalletId: testWalletID})
		require.NoError(t, err)
		assert.ElementsMatch(t, []*walletv1.ReceiveAddress{
			{Address: "bcrt1qone", Label: "savings", CurrentBalanceSat: 1_500},
			{Address: "bcrt1qtwo", CurrentBalanceSat: 7},
		}, resp.Addresses)
	})
}

// fixtureKey walks m/purpose'/1'/0'/0/index of the apitests fixture seed.
func fixtureKey(t *testing.T, purpose, index uint32) *btcec.PublicKey {
	t.Helper()

	seed, err := hex.DecodeString("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f")
	require.NoError(t, err)
	key, err := hdkeychain.NewMaster(seed, &chaincfg.SigNetParams)
	require.NoError(t, err)
	const h = hdkeychain.HardenedKeyStart
	for _, child := range []uint32{h + purpose, h + 1, h + 0, 0, index} {
		key, err = key.Derive(child)
		require.NoError(t, err)
	}
	pub, err := key.ECPubKey()
	require.NoError(t, err)
	return pub
}

func fixtureSegwitAddress(t *testing.T, index uint32) string {
	t.Helper()

	addr, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(fixtureKey(t, 84, index).SerializeCompressed()), &chaincfg.SigNetParams)
	require.NoError(t, err)
	return addr.EncodeAddress()
}

func fixtureTaprootAddress(t *testing.T, index uint32) string {
	t.Helper()

	tapKey := txscript.ComputeTaprootKeyNoScript(fixtureKey(t, 86, index))
	addr, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(tapKey), &chaincfg.SigNetParams)
	require.NoError(t, err)
	return addr.EncodeAddress()
}
