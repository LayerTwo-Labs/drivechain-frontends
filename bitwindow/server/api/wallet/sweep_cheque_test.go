package wallet_test

import (
	"context"
	"database/sql"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
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
