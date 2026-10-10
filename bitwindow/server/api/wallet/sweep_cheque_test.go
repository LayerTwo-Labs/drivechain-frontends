package api_wallet_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
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
			apitests.API(t, db, apitests.WithEncryptedWallet(), apitests.WithOrchestrator(orchestrator)),
		)

		resp, err := cli.SweepCheque(context.Background(), connect.NewRequest(&walletv1.SweepChequeRequest{
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
