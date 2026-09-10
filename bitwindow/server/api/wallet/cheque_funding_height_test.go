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
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/stretchr/testify/require"
)

func TestCheckChequeFunding_RecordsTheFundingBlock(t *testing.T) {
	t.Parallel()
	db := database.Test(t)

	chequeAddr := "tb1qfundingheighttestaddr000000000000000000"
	fundingTxid := "feed0000feed0000feed0000feed0000feed0000feed0000feed0000feed0000"

	cli := walletv1connect.NewWalletServiceClient(
		apitests.API(t, db, apitests.WithOrchestrator(&fakeOrchestrator{
			address: chequeAddr,
			utxos: []*orchpb.AddressUnspentOutput{
				{Txid: fundingTxid, Vout: 0, ValueSats: 100_000_000, Confirmations: 3},
			},
		})),
	)

	chequeID, err := cheques.Create(context.Background(), db, testWalletID, 0, 100_000_000, chequeAddr)
	require.NoError(t, err)

	_, err = cli.CheckChequeFunding(context.Background(), connect.NewRequest(&walletv1.CheckChequeFundingRequest{
		WalletId: testWalletID,
		Id:       chequeID,
	}))
	require.NoError(t, err)

	var height int64
	require.NoError(t, db.QueryRowContext(context.Background(),
		`SELECT block_height FROM cheque_funding_outputs WHERE cheque_id = ? AND txid = ?`,
		chequeID, fundingTxid,
	).Scan(&height))
	require.EqualValues(t, 98, height, "tip 100 with 3 confirmations")
}
