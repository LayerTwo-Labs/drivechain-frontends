package api_wallet_test

import (
	"context"
	"errors"
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
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

const testWalletID = "test-wallet-id-1234"

// fakeOrchestrator answers for one cheque address only, so the engine's
// background recovery scan can't consume the responses a test set up.
type fakeOrchestrator struct {
	orchrpc.WalletManagerServiceClient

	address string
	utxos   []*orchpb.AddressUnspentOutput
	// perCall serves a different answer per poll, for the poll-after-send case.
	perCall func(n int32) []*orchpb.AddressUnspentOutput
	calls   atomic.Int32
}

// Seeds come from the local wallet file in tests, so refuse here and let the
// engine fall through.
func (f *fakeOrchestrator) GetWalletSeed(
	_ context.Context, _ *connect.Request[orchpb.GetWalletSeedRequest],
) (*connect.Response[orchpb.GetWalletSeedResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("no orchestrator seed in tests"))
}

func (f *fakeOrchestrator) GetAddressUnspent(
	_ context.Context, req *connect.Request[orchpb.GetAddressUnspentRequest],
) (*connect.Response[orchpb.GetAddressUnspentResponse], error) {
	if req.Msg.Address != f.address {
		return connect.NewResponse(&orchpb.GetAddressUnspentResponse{}), nil
	}
	utxos := f.utxos
	if f.perCall != nil {
		utxos = f.perCall(f.calls.Add(1))
	}
	return connect.NewResponse(&orchpb.GetAddressUnspentResponse{Utxos: utxos, TipHeight: 100}), nil
}

func TestCheckChequeFunding_UnfundedCheck(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qtestaddress000000000000000000000000000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{address: chequeAddr})),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
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
	db := database.Test(t)

	chequeAddr := "tb1qunconfirmedtestaddr00000000000000000000"
	fundingTxid := "abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: fundingTxid, Vout: 0, ValueSats: 100_000_000, Confirmations: 0},
			},
		})),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded)
	require.Equal(t, []string{fundingTxid}, resp.Msg.FundedTxids)
	require.EqualValues(t, 0, resp.Msg.MinConfirmations)
}

func TestCheckChequeFunding_DetectsConfirmedTx(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qconfirmedtestaddr0000000000000000000000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{
					Txid:          "beef0000beef0000beef0000beef0000beef0000beef0000beef0000beef0000",
					Vout:          1,
					ValueSats:     50_000_000,
					Confirmations: 3,
				},
			},
		})),
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
	require.EqualValues(t, 3, resp.Msg.MinConfirmations)
}

func TestCheckChequeFunding_PersistsFundingToDatabase(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpersisttestaddr000000000000000000000000"
	fundingTxid := "dead0000dead0000dead0000dead0000dead0000dead0000dead0000dead0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: fundingTxid, Vout: 0, ValueSats: 100_000_000},
			},
		})),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, resp.Msg.Funded)

	cheque, err := cheques.Get(context.Background(), db, testWalletID, chequeID)
	require.NoError(t, err)
	require.Equal(t, []string{fundingTxid}, cheque.FundedTxids)
	require.NotNil(t, cheque.ActualAmountSats)
	require.Equal(t, uint64(100_000_000), *cheque.ActualAmountSats)
	require.NotNil(t, cheque.FundedAt)
}

func TestCheckChequeFunding_MultipleUTXOs(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qmultiutxotestaddr00000000000000000000000"
	first := "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000"
	second := "bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: first, Vout: 0, ValueSats: 100_000_000, Confirmations: 0},
				{Txid: second, Vout: 0, ValueSats: 100_000_000, Confirmations: 1},
			},
		})),
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
	require.Contains(t, resp.Msg.FundedTxids, first)
	require.Contains(t, resp.Msg.FundedTxids, second)
	require.EqualValues(t, 0, resp.Msg.MinConfirmations, "the least-confirmed output sets the floor")
}

func TestCheckChequeFunding_PartialFunding(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpartialtestaddr0000000000000000000000000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{
					Txid:          "partial0partial0partial0partial0partial0partial0partial0partial0",
					Vout:          0,
					ValueSats:     50_000_000, // only half of what the cheque expects
					Confirmations: 1,
				},
			},
		})),
	)

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

// Mirrors the Flutter polling loop: the first poll can race the broadcast and
// must report unfunded; a later one flips the cheque to funded and persists it.
func TestCheckChequeFunding_PollAfterSend(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpolltestaddr00000000000000000000000000000"
	fundingTxid := "feed0000feed0000feed0000feed0000feed0000feed0000feed0000feed0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			perCall: func(n int32) []*orchpb.AddressUnspentOutput {
				if n == 1 {
					return nil
				}
				return []*orchpb.AddressUnspentOutput{
					{Txid: fundingTxid, Vout: 0, ValueSats: 210_000_000},
				}
			},
		})),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 210_000_000, chequeAddr)
	require.NoError(t, err)

	respFirst, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.False(t, respFirst.Msg.Funded)
	require.Empty(t, respFirst.Msg.FundedTxids)

	respSecond, err := cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)
	require.True(t, respSecond.Msg.Funded, "second poll should detect the broadcast")
	require.Equal(t, []string{fundingTxid}, respSecond.Msg.FundedTxids)
	require.Equal(t, uint64(210_000_000), respSecond.Msg.ActualAmountSats)

	persisted, err := cheques.Get(context.Background(), db, testWalletID, chequeID)
	require.NoError(t, err)
	require.True(t, persisted.IsFunded())
	require.NotNil(t, persisted.FundedAt)
	require.Equal(t, []string{fundingTxid}, persisted.FundedTxids)
}

// With no orchestrator wired — regtest, or any dev setup without an electrum
// endpoint — cheques must fall back to Bitcoin Core's watch-only wallet.
func TestCheckChequeFunding_FallsBackToCore(t *testing.T) {
	t.Parallel()
	ctrl := gomock.NewController(t)
	db := database.Test(t)

	chequeAddr := "tb1qcorefallbacktestaddr000000000000000000"
	fundingTxid := "c0de0000c0de0000c0de0000c0de0000c0de0000c0de0000c0de0000c0de0000"

	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ListWalletsResponse]{
			Msg: &bitcoindv1alpha.ListWalletsResponse{Wallets: []string{"cheque_watch"}},
		}, nil).AnyTimes()
	mockBitcoind.EXPECT().
		GetDescriptorInfo(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.GetDescriptorInfoResponse]{
			Msg: &bitcoindv1alpha.GetDescriptorInfoResponse{Descriptor_: "addr(" + chequeAddr + ")#checksum"},
		}, nil).AnyTimes()
	mockBitcoind.EXPECT().
		ImportDescriptors(gomock.Any(), gomock.Any()).
		Return(&connect.Response[bitcoindv1alpha.ImportDescriptorsResponse]{
			Msg: &bitcoindv1alpha.ImportDescriptorsResponse{
				Responses: []*bitcoindv1alpha.ImportDescriptorsResponse_Response{{Success: true}},
			},
		}, nil).AnyTimes()
	mockBitcoind.EXPECT().
		ListUnspent(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[bitcoindv1alpha.ListUnspentRequest]) (*connect.Response[bitcoindv1alpha.ListUnspentResponse], error) {
			if !slices.Contains(req.Msg.Addresses, chequeAddr) {
				return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
					Msg: &bitcoindv1alpha.ListUnspentResponse{},
				}, nil
			}
			return &connect.Response[bitcoindv1alpha.ListUnspentResponse]{
				Msg: &bitcoindv1alpha.ListUnspentResponse{
					Unspent: []*bitcoindv1alpha.UnspentOutput{
						{Txid: fundingTxid, Vout: 0, Address: chequeAddr, Amount: 1.0, Confirmations: 2},
					},
				},
			}, nil
		}).AnyTimes()

	// No WithOrchestrator: the electrum chain reports itself unavailable.
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
	require.True(t, resp.Msg.Funded, "Core must answer when electrum has no chain source")
	require.Equal(t, uint64(100_000_000), resp.Msg.ActualAmountSats)
	require.Equal(t, []string{fundingTxid}, resp.Msg.FundedTxids)
}
