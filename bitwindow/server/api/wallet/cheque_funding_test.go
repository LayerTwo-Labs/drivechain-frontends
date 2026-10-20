package wallet_test

import (
	"context"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
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
	seedHex string
	locked  bool
}

func (f *fakeOrchestrator) GetWalletStatus(
	context.Context, *orchpb.GetWalletStatusRequest,
) (*orchpb.GetWalletStatusResponse, error) {
	state := orchpb.WalletState_WALLET_STATE_UNLOCKED
	if f.locked {
		state = orchpb.WalletState_WALLET_STATE_LOCKED
	}
	return &orchpb.GetWalletStatusResponse{State: state}, nil
}

func (f *fakeOrchestrator) ListWallets(
	context.Context, *orchpb.ListWalletsRequest,
) (*orchpb.ListWalletsResponse, error) {
	resp := &orchpb.ListWalletsResponse{ActiveWalletId: testWalletID}
	if !f.locked {
		resp.Wallets = []*orchpb.WalletMetadata{{Id: testWalletID, WalletType: orchpb.WalletType_WALLET_TYPE_ELECTRUM}}
	}
	return resp, nil
}

// The runtime hands over the frozen coins on a timer, whatever else runs.
func (f *fakeOrchestrator) SetFrozenCoins(
	context.Context, *orchpb.SetFrozenCoinsRequest,
) (*emptypb.Empty, error) {
	return &emptypb.Empty{}, nil
}

// The pollers ask before each tick. A full-mode answer keeps them running,
// which is what these tests exercise.
func (f *fakeOrchestrator) GetNodeMode(
	_ context.Context, _ *orchpb.GetNodeModeRequest,
) (*orchpb.GetNodeModeResponse, error) {
	return &orchpb.GetNodeModeResponse{
		Mode: orchpb.NodeMode_NODE_MODE_FULL,
	}, nil
}

// Seeds come from the local wallet file in tests, so refuse here and let the
// engine fall through.
func (f *fakeOrchestrator) GetWalletSeed(
	_ context.Context, _ *orchpb.GetWalletSeedRequest,
) (*orchpb.GetWalletSeedResponse, error) {
	if f.seedHex != "" {
		return &orchpb.GetWalletSeedResponse{SeedHex: f.seedHex}, nil
	}
	return nil, connect.NewError(connect.CodeUnimplemented, "no orchestrator seed in tests")
}

func (f *fakeOrchestrator) GetAddressUnspent(
	_ context.Context, req *orchpb.GetAddressUnspentRequest,
) (*orchpb.GetAddressUnspentResponse, error) {
	if req.Address != f.address {
		return &orchpb.GetAddressUnspentResponse{}, nil
	}
	utxos := f.utxos
	if f.perCall != nil {
		utxos = f.perCall(f.calls.Add(1))
	}
	return &orchpb.GetAddressUnspentResponse{Utxos: utxos, TipHeight: 100}, nil
}

func TestCheckChequeFunding_UnfundedCheck(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qtestaddress000000000000000000000000000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{address: chequeAddr})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.False(t, resp.Funded)
}

func TestCheckChequeFunding_DetectsUnconfirmedTx(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qunconfirmedtestaddr00000000000000000000"
	fundingTxid := "abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: fundingTxid, Vout: 0, ValueSats: 100_000_000, Confirmations: 0},
			},
		})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.True(t, resp.Funded)
	require.Equal(t, []string{fundingTxid}, resp.FundedTxids)
	require.EqualValues(t, 0, resp.MinConfirmations)
}

func TestCheckChequeFunding_DetectsConfirmedTx(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qconfirmedtestaddr0000000000000000000000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
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

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 50_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.True(t, resp.Funded)
	require.Equal(t, uint64(50_000_000), resp.ActualAmountSats)
	require.EqualValues(t, 3, resp.MinConfirmations)
}

func TestCheckChequeFunding_PersistsFundingToDatabase(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpersisttestaddr000000000000000000000000"
	fundingTxid := "dead0000dead0000dead0000dead0000dead0000dead0000dead0000dead0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: fundingTxid, Vout: 0, ValueSats: 100_000_000},
			},
		})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.True(t, resp.Funded)

	cheque, err := cheques.Get(t.Context(), db, testWalletID, chequeID)
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
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: first, Vout: 0, ValueSats: 100_000_000, Confirmations: 0},
				{Txid: second, Vout: 0, ValueSats: 100_000_000, Confirmations: 1},
			},
		})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 200_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.True(t, resp.Funded)
	require.Equal(t, uint64(200_000_000), resp.ActualAmountSats)
	require.Len(t, resp.FundedTxids, 2)
	require.Contains(t, resp.FundedTxids, first)
	require.Contains(t, resp.FundedTxids, second)
	require.EqualValues(t, 0, resp.MinConfirmations, "the least-confirmed output sets the floor")
}

func TestCheckChequeFunding_TwoOutputsFromOneTransaction(t *testing.T) {
	t.Parallel()
	db := database.Test(t)
	ctx := t.Context()
	address := "tb1qtestaddress000000000000000000000000000"
	txid := "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: address,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: txid, Vout: 1, ValueSats: 600, Confirmations: 3},
				{Txid: txid, Vout: 2, ValueSats: 400, Confirmations: 3},
			},
		})),
	)
	id, err := cheques.Create(ctx, db, testWalletID, 0, 1000, address)
	require.NoError(t, err)

	for range 2 {
		resp, err := cli.CheckChequeFunding(ctx, &walletv1.CheckChequeFundingRequest{
			WalletId: testWalletID,
			Id:       id,
		})
		require.NoError(t, err)
		require.True(t, resp.Funded)
		require.Equal(t, uint64(1000), resp.ActualAmountSats)
		require.Equal(t, []string{txid}, resp.FundedTxids)
	}

	type outputRow struct {
		Txid        string `db:"txid"`
		Vout        int32  `db:"vout"`
		ValueSats   int64  `db:"value_sats"`
		BlockHeight uint32 `db:"block_height"`
	}
	rows, err := database.Select[outputRow](ctx, db, `
		SELECT txid, vout, value_sats, block_height
		FROM cheque_funding_outputs WHERE cheque_id = ? ORDER BY vout
	`, id)
	require.NoError(t, err)
	require.Equal(t, []outputRow{
		{Txid: txid, Vout: 1, ValueSats: 600, BlockHeight: 98},
		{Txid: txid, Vout: 2, ValueSats: 400, BlockHeight: 98},
	}, rows)
}

func TestCheckChequeFunding_RefusesDeleteAfterAnotherPayment(t *testing.T) {
	t.Parallel()
	for _, tt := range []struct {
		name   string
		amount int64
	}{
		{name: "a partial payment", amount: 500},
		{name: "a full payment", amount: 1000},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			db := database.Test(t)
			ctx := t.Context()
			address := "tb1qtestaddress000000000000000000000000000"
			first := "aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000"
			second := "bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000"
			cli := walletv1connect.NewWalletServiceClient(
				apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
					address: address,
					perCall: func(n int32) []*orchpb.AddressUnspentOutput {
						if n == 1 {
							return []*orchpb.AddressUnspentOutput{{Txid: first, ValueSats: 1000}}
						}
						return []*orchpb.AddressUnspentOutput{{Txid: second, Vout: 2, ValueSats: tt.amount}}
					},
				})),
			)
			id, err := cheques.Create(ctx, db, testWalletID, 0, 1000, address)
			require.NoError(t, err)
			request := &walletv1.CheckChequeFundingRequest{WalletId: testWalletID, Id: id}
			_, err = cli.CheckChequeFunding(ctx, request)
			require.NoError(t, err)
			require.NoError(t, cheques.UpdateSwept(ctx, db, testWalletID, id, "sweep"))

			resp, err := cli.CheckChequeFunding(ctx, request)
			require.NoError(t, err)
			require.Equal(t, uint64(tt.amount), resp.ActualAmountSats)
			_, err = cli.DeleteCheque(ctx, &walletv1.DeleteChequeRequest{
				WalletId: testWalletID,
				Id:       id,
			})
			require.ErrorContains(t, err, "cannot delete funded cheque")
			require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))

			got, err := cheques.Get(ctx, db, testWalletID, id)
			require.NoError(t, err)
			require.Nil(t, got.SweptTxid)
			require.Nil(t, got.SweptAt)
			require.ElementsMatch(t, []string{first, second}, got.FundedTxids)
		})
	}
}

func TestCheckChequeFunding_PartialFunding(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpartialtestaddr0000000000000000000000000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
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

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	resp, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.False(t, resp.Funded, "should NOT be fully funded with only half the amount")
	require.Equal(t, uint64(50_000_000), resp.ActualAmountSats)
	require.Len(t, resp.FundedTxids, 1, "should still track the partial txid")
}

// Mirrors the Flutter polling loop: the first poll can race the broadcast and
// must report unfunded; a later one flips the cheque to funded and persists it.
func TestCheckChequeFunding_PollAfterSend(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qpolltestaddr00000000000000000000000000000"
	fundingTxid := "feed0000feed0000feed0000feed0000feed0000feed0000feed0000feed0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
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

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 210_000_000, chequeAddr)
	require.NoError(t, err)

	respFirst, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.False(t, respFirst.Funded)
	require.Empty(t, respFirst.FundedTxids)

	respSecond, err := cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.NoError(t, err)
	require.True(t, respSecond.Funded, "second poll should detect the broadcast")
	require.Equal(t, []string{fundingTxid}, respSecond.FundedTxids)
	require.Equal(t, uint64(210_000_000), respSecond.ActualAmountSats)

	persisted, err := cheques.Get(t.Context(), db, testWalletID, chequeID)
	require.NoError(t, err)
	require.True(t, persisted.IsFunded())
	require.NotNil(t, persisted.FundedAt)
	require.Equal(t, []string{fundingTxid}, persisted.FundedTxids)
}

// With no orchestrator wired — regtest, or any dev setup without an electrum
// endpoint — cheques must fall back to Bitcoin Core's watch-only wallet.
func TestCheckChequeFunding_NeedsElectrum(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qnoelectrumtestaddr0000000000000000000"

	// No WithOrchestrator: cheques have no other chain source.
	cli := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db))

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	_, err = cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
}

func TestCheckChequeFunding_ReportsAFailedSweptMark(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qsweptmarktestaddr00000000000000000000000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{address: chequeAddr})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)
	require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, chequeID,
		[]cheques.FundingOutput{{Txid: "cafe0000cafe0000cafe0000cafe0000cafe0000cafe0000cafe0000cafe0000"}}, 100_000_000))
	_, err = db.ExecContext(t.Context(), `
		CREATE TRIGGER refuse_sweep BEFORE UPDATE OF swept_txid ON cheques
		BEGIN SELECT RAISE(ABORT, 'sweep refused'); END`)
	require.NoError(t, err)

	_, err = cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
	require.ErrorContains(t, err, "mark cheque swept")
}

func TestChequeReads_ReportAFailedKeyDerivation(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qkeyfailtestaddr000000000000000000000000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&fakeOrchestrator{address: chequeAddr, seedHex: "not-hex"})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)
	require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, chequeID,
		[]cheques.FundingOutput{{Txid: "f00d0000f00d0000f00d0000f00d0000f00d0000f00d0000f00d0000f00d0000"}}, 100_000_000))

	t.Run("GetCheque", func(t *testing.T) {
		_, err := cli.GetCheque(t.Context(), &walletv1.GetChequeRequest{
			WalletId: testWalletID,
			Id:       chequeID,
		})
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		require.ErrorContains(t, err, "private key")
	})

	t.Run("ListCheques", func(t *testing.T) {
		_, err := cli.ListCheques(t.Context(), &walletv1.ListChequesRequest{
			WalletId: testWalletID,
		})
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		require.ErrorContains(t, err, "private key")
	})
}

type downOrchestrator struct {
	*fakeOrchestrator
}

func (d *downOrchestrator) GetAddressUnspent(
	context.Context, *orchpb.GetAddressUnspentRequest,
) (*orchpb.GetAddressUnspentResponse, error) {
	return nil, connect.NewError(connect.CodeUnavailable, "esplora down")
}

func TestCheckChequeFunding_FailedQueryNamesTheAddress(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qtestaddress000000000000000000000000000"
	cli := walletv1connect.NewWalletServiceClient(
		apitests.RPC(t, db, apitests.WithOrchestrator(&downOrchestrator{&fakeOrchestrator{address: chequeAddr}})),
	)

	chequeID, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	_, err = cli.CheckChequeFunding(t.Context(), &walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	})
	require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	require.ErrorContains(t, err, "query UTXOs of "+chequeAddr)
	require.ErrorContains(t, err, "esplora down")
}
