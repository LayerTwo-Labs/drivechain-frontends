package wallet_test

import (
	"context"
	"database/sql"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

type broadcastOrchestrator struct {
	*fakeOrchestrator

	broadcasts []string
}

func (b *broadcastOrchestrator) BroadcastElectrumTransaction(
	_ context.Context, req *connect.Request[orchpb.BroadcastElectrumTransactionRequest],
) (*connect.Response[orchpb.BroadcastElectrumTransactionResponse], error) {
	b.broadcasts = append(b.broadcasts, req.Msg.TxHex)
	return connect.NewResponse(&orchpb.BroadcastElectrumTransactionResponse{Txid: "swept-txid"}), nil
}

func TestSweepChequeOnALockedWallet(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	privKey, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	wif, err := btcutil.NewWIF(privKey, &chaincfg.SigNetParams, true)
	require.NoError(t, err)
	candidates, err := engines.SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)

	orchestrator := &broadcastOrchestrator{fakeOrchestrator: &fakeOrchestrator{
		locked:  true,
		address: candidates[0].Address,
		utxos: []*orchpb.AddressUnspentOutput{{
			Txid:          "aa00000000000000000000000000000000000000000000000000000000000001",
			Vout:          0,
			ValueSats:     100_000,
			Confirmations: 3,
		}},
	}}

	t.Run("the claim needs no unlock", func(t *testing.T) {
		cli := walletv1connect.NewWalletServiceClient(
			apitests.API(t, db, apitests.WithOrchestrator(orchestrator)),
		)

		resp, err := cli.SweepCheque(t.Context(), connect.NewRequest(&walletv1.SweepChequeRequest{
			WalletId:           testWalletID,
			PrivateKeyWif:      wif.String(),
			DestinationAddress: candidates[0].Address,
			FeeSatPerVbyte:     1,
		}))
		require.NoError(t, err)
		require.Equal(t, "swept-txid", resp.Msg.Txid)
		require.Equal(t, uint64(100_000), resp.Msg.AmountSats)
		require.Len(t, orchestrator.broadcasts, 1)
	})
}

func TestSweepChequeMarksTheCheque(t *testing.T) {
	t.Parallel()

	privKey, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	wif, err := btcutil.NewWIF(privKey, &chaincfg.SigNetParams, true)
	require.NoError(t, err)
	candidates, err := engines.SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)

	sweep := func(t *testing.T, db *sql.DB) (*broadcastOrchestrator, error) {
		orchestrator := &broadcastOrchestrator{fakeOrchestrator: &fakeOrchestrator{
			address: candidates[0].Address,
			utxos: []*orchpb.AddressUnspentOutput{{
				Txid:          "aa00000000000000000000000000000000000000000000000000000000000001",
				ValueSats:     100_000,
				Confirmations: 3,
			}},
		}}
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(orchestrator)))
		_, err := cli.SweepCheque(t.Context(), connect.NewRequest(&walletv1.SweepChequeRequest{
			WalletId:           testWalletID,
			PrivateKeyWif:      wif.String(),
			DestinationAddress: candidates[0].Address,
			FeeSatPerVbyte:     1,
		}))
		return orchestrator, err
	}

	t.Run("the cheque reads as swept", func(t *testing.T) {
		db := database.Test(t)
		id, err := cheques.Create(t.Context(), db, testWalletID, 0, 100_000, candidates[0].Address)
		require.NoError(t, err)

		_, err = sweep(t, db)
		require.NoError(t, err)

		cheque, err := cheques.Get(t.Context(), db, testWalletID, id)
		require.NoError(t, err)
		require.NotNil(t, cheque.SweptTxid)
		require.Equal(t, "swept-txid", *cheque.SweptTxid)
	})

	t.Run("a key that is no cheque sweeps", func(t *testing.T) {
		_, err := sweep(t, database.Test(t))
		require.NoError(t, err)
	})

	t.Run("a failed cheque read stops the sweep before the broadcast", func(t *testing.T) {
		db := database.Test(t)
		_, err := db.ExecContext(t.Context(), `DROP TABLE cheques`)
		require.NoError(t, err)

		orchestrator, err := sweep(t, db)
		require.Equal(t, connect.CodeInternal, connect.CodeOf(err))
		require.ErrorContains(t, err, "no such table")
		assert.Empty(t, orchestrator.broadcasts)
	})
}

func TestSweepChequeRefusesAWIFOfAnotherNetwork(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	privKey, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	mainnetWIF, err := btcutil.NewWIF(privKey, &chaincfg.MainNetParams, true)
	require.NoError(t, err)
	orchestrator := &broadcastOrchestrator{fakeOrchestrator: &fakeOrchestrator{}}
	cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(orchestrator)))

	_, err = cli.SweepCheque(t.Context(), connect.NewRequest(&walletv1.SweepChequeRequest{
		WalletId:           testWalletID,
		PrivateKeyWif:      mainnetWIF.String(),
		DestinationAddress: "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl",
		FeeSatPerVbyte:     1,
	}))
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	require.ErrorContains(t, err, "WIF is not for network")
	assert.Empty(t, orchestrator.broadcasts)
}

func TestPreviewSweep(t *testing.T) {
	t.Parallel()

	newKey := func(t *testing.T, params *chaincfg.Params, compressed bool) (*btcutil.WIF, []engines.SweepCandidate) {
		t.Helper()
		privKey, err := btcec.NewPrivateKey()
		require.NoError(t, err)
		wif, err := btcutil.NewWIF(privKey, params, compressed)
		require.NoError(t, err)
		candidates, err := engines.SweepCandidates(wif, &chaincfg.SigNetParams)
		require.NoError(t, err)
		return wif, candidates
	}
	funded := []*orchpb.AddressUnspentOutput{
		{Txid: "aa00000000000000000000000000000000000000000000000000000000000001", ValueSats: 60_000, Confirmations: 3},
		{Txid: "aa00000000000000000000000000000000000000000000000000000000000002", Vout: 1, ValueSats: 40_000, Confirmations: 1},
	}

	tests := []struct {
		name        string
		compressed  bool
		fundedIndex int
		utxos       []*orchpb.AddressUnspentOutput
		feeRate     uint64
		wantKind    walletv1.SweepAddressKind
		wantFee     uint64
		wantReceive uint64
	}{
		{
			name: "a funded p2wpkh key", compressed: true, fundedIndex: 0, utxos: funded, feeRate: 10,
			wantKind: walletv1.SweepAddressKind_SWEEP_ADDRESS_KIND_P2WPKH, wantFee: (2*68 + 11 + 31) * 10, wantReceive: 100_000 - (2*68+11+31)*10,
		},
		{
			name: "a funded compressed p2pkh key", compressed: true, fundedIndex: 1, utxos: funded, feeRate: 10,
			wantKind: walletv1.SweepAddressKind_SWEEP_ADDRESS_KIND_P2PKH, wantFee: (2*148 + 11 + 31) * 10, wantReceive: 100_000 - (2*148+11+31)*10,
		},
		{
			name: "a funded uncompressed p2pkh key", compressed: false, fundedIndex: 0, utxos: funded, feeRate: 10,
			wantKind: walletv1.SweepAddressKind_SWEEP_ADDRESS_KIND_P2PKH, wantFee: (2*180 + 11 + 31) * 10, wantReceive: 100_000 - (2*180+11+31)*10,
		},
		{
			name: "an empty key", compressed: true, fundedIndex: 0, feeRate: 10,
			wantKind: walletv1.SweepAddressKind_SWEEP_ADDRESS_KIND_P2WPKH, wantFee: (11 + 31) * 10,
		},
		{
			name: "a fee above the balance receives nothing", compressed: true, fundedIndex: 0, utxos: funded, feeRate: 1_000,
			wantKind: walletv1.SweepAddressKind_SWEEP_ADDRESS_KIND_P2WPKH, wantFee: (2*68 + 11 + 31) * 1_000,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			db := database.Test(t)
			wif, candidates := newKey(t, &chaincfg.SigNetParams, tt.compressed)
			source := candidates[tt.fundedIndex]
			cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(
				&fakeOrchestrator{address: source.Address, utxos: tt.utxos},
			)))

			resp, err := cli.PreviewSweep(t.Context(), connect.NewRequest(&walletv1.PreviewSweepRequest{
				PrivateKeyWif:  wif.String(),
				FeeSatPerVbyte: tt.feeRate,
			}))
			require.NoError(t, err)
			assert.Equal(t, source.Address, resp.Msg.Address)
			assert.Equal(t, tt.wantKind, resp.Msg.AddressKind)
			assert.Equal(t, uint32(len(tt.utxos)), resp.Msg.OutputCount)
			assert.Equal(t, uint64(lo.SumBy(tt.utxos, func(u *orchpb.AddressUnspentOutput) int64 { return u.ValueSats })), resp.Msg.AmountSats)
			assert.Equal(t, tt.feeRate, resp.Msg.FeeSatPerVbyte)
			assert.Equal(t, tt.wantFee, resp.Msg.FeeSats)
			assert.Equal(t, tt.wantReceive, resp.Msg.ReceiveSats)
		})
	}

	t.Run("a WIF of another network is refused", func(t *testing.T) {
		t.Parallel()
		db := database.Test(t)
		mainnetWIF, _ := newKey(t, &chaincfg.MainNetParams, true)
		cli := walletv1connect.NewWalletServiceClient(apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{})))

		_, err := cli.PreviewSweep(t.Context(), connect.NewRequest(&walletv1.PreviewSweepRequest{
			PrivateKeyWif:  mainnetWIF.String(),
			FeeSatPerVbyte: 1,
		}))
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		require.ErrorContains(t, err, "WIF is not for network")
	})
}
