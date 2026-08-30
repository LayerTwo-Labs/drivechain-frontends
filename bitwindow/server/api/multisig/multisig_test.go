package api_multisig_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	api_multisig "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/multisig"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"
)

// activeWallet stands in for the wallet engine, always active.
type activeWallet string

func (w activeWallet) GetActiveWallet(context.Context) (*engines.WalletInfo, error) {
	return &engines.WalletInfo{ID: string(w)}, nil
}

func saveGroup(t *testing.T, srv *api_multisig.Server, id string) {
	t.Helper()

	_, err := srv.SaveGroup(context.Background(), connect.NewRequest(&pb.SaveGroupRequest{
		Group: &pb.MultisigGroup{Id: id, Name: id, N: 2, M: 3, Created: 1700000000},
	}))
	require.NoError(t, err)
}

func TestGroupsAreScopedToTheActiveWallet(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	walletA := api_multisig.New(db, activeWallet("wallet-a"))
	walletB := api_multisig.New(db, activeWallet("wallet-b"))

	saveGroup(t, walletA, "grp-a")
	saveGroup(t, walletB, "grp-b")

	groups, err := walletA.ListGroups(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Len(t, groups.Msg.Groups, 1)
	assert.Equal(t, "grp-a", groups.Msg.Groups[0].Id)

	// Wallet B cannot read, mutate or delete wallet A's group.
	_, err = walletB.SaveGroup(ctx, connect.NewRequest(&pb.SaveGroupRequest{
		Group: &pb.MultisigGroup{Id: "grp-a", Name: "stolen", N: 2, M: 3},
	}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	_, err = walletB.DeleteGroup(ctx, connect.NewRequest(&pb.DeleteGroupRequest{GroupId: "grp-a"}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	_, err = walletB.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{GroupId: "grp-a"}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	// The group survived both attempts, unchanged.
	groups, err = walletA.ListGroups(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Len(t, groups.Msg.Groups, 1)
	assert.Equal(t, "grp-a", groups.Msg.Groups[0].Name)
}

func TestTransactionsAreScopedToTheActiveWallet(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	walletA := api_multisig.New(db, activeWallet("wallet-a"))
	walletB := api_multisig.New(db, activeWallet("wallet-b"))

	saveGroup(t, walletA, "grp-a")

	_, err := walletA.SaveTransaction(ctx, connect.NewRequest(&pb.SaveTransactionRequest{
		Transaction: &pb.MultisigTransaction{
			Id: "tx-a", GroupId: "grp-a", Txid: "abc123", InitialPsbt: "psbt",
			Status: pb.TxStatus_TX_STATUS_NEEDS_SIGNATURES,
		},
	}))
	require.NoError(t, err)

	txns, err := walletB.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{}))
	require.NoError(t, err)
	assert.Empty(t, txns.Msg.Transactions)

	_, err = walletB.GetTransaction(ctx, connect.NewRequest(&pb.GetTransactionRequest{TransactionId: "tx-a"}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	_, err = walletB.GetTransactionByTxid(ctx, connect.NewRequest(&pb.GetTransactionByTxidRequest{Txid: "abc123"}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	// Voiding, like every other status change, goes through SaveTransaction.
	_, err = walletB.SaveTransaction(ctx, connect.NewRequest(&pb.SaveTransactionRequest{
		Transaction: &pb.MultisigTransaction{Id: "tx-a", GroupId: "grp-a", Status: pb.TxStatus_TX_STATUS_VOIDED},
	}))
	assert.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))

	txns, err = walletA.ListTransactions(ctx, connect.NewRequest(&pb.ListTransactionsRequest{}))
	require.NoError(t, err)
	require.Len(t, txns.Msg.Transactions, 1)
	assert.Equal(t, pb.TxStatus_TX_STATUS_NEEDS_SIGNATURES, txns.Msg.Transactions[0].Status)
}

func TestGroupsSavedBeforeWalletScopingStayVisible(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)

	_, err := db.ExecContext(ctx, `
		INSERT INTO multisig_groups (id, name, n, m, created) VALUES ('grp-legacy', 'legacy', 2, 3, 1700000000)`)
	require.NoError(t, err)

	for _, walletID := range []string{"wallet-a", "wallet-b"} {
		groups, err := api_multisig.New(db, activeWallet(walletID)).
			ListGroups(ctx, connect.NewRequest(&emptypb.Empty{}))
		require.NoError(t, err)
		require.Len(t, groups.Msg.Groups, 1, walletID)
		assert.Equal(t, "grp-legacy", groups.Msg.Groups[0].Id)
	}
}
