package wallet_test

import (
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	walletv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1"
	walletv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
)

func TestDeleteChequeKeepsLegacyPartialFunds(t *testing.T) {
	db := database.Test(t)
	id, err := cheques.Create(t.Context(), db, testWalletID, 0, 2000, "legacy-address")
	require.NoError(t, err)
	_, err = db.ExecContext(t.Context(), `
		UPDATE cheques SET funded_txid = 'legacy-receipt', actual_amount_sats = 1000 WHERE id = ?
	`, id)
	require.NoError(t, err)
	client := walletv1connect.NewWalletServiceClient(apitests.RPC(t, db))
	_, err = client.DeleteCheque(t.Context(), &walletv1.DeleteChequeRequest{WalletId: testWalletID, Id: id})
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	row, err := cheques.Get(t.Context(), db, testWalletID, id)
	require.NoError(t, err)
	require.True(t, row.IsPartiallyFunded())
}
