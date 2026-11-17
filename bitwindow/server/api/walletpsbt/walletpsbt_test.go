package walletpsbt_test

import (
	"context"
	"errors"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	api "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/walletpsbt"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/walletpsbt"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
)

// spending builds a PSBT that spends one coin of each txid, at vout 0.
func spending(t *testing.T, txids ...string) string {
	t.Helper()
	inputs := make([]*wire.OutPoint, 0, len(txids))
	sequences := make([]uint32, 0, len(txids))
	for _, txid := range txids {
		hash, err := chainhash.NewHashFromStr(txid)
		require.NoError(t, err)
		inputs = append(inputs, wire.NewOutPoint(hash, 0))
		sequences = append(sequences, wire.MaxTxInSequenceNum)
	}
	packet, err := psbt.New(inputs, []*wire.TxOut{wire.NewTxOut(1000, []byte{0x51})}, 2, 0, sequences)
	require.NoError(t, err)
	encoded, err := packet.B64Encode()
	require.NoError(t, err)
	return encoded
}

func TestDrafts(t *testing.T) {
	t.Parallel()

	t.Run("save, list and delete a draft", func(t *testing.T) {
		t.Parallel()

		orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
		apitests.ExpectOrchestratorReads(orch)
		cli := rpc.NewWalletPsbtServiceClient(apitests.RPC(t, database.Test(t), apitests.WithOrchestrator(orch)))
		ctx := t.Context()
		list := func(walletID string) []*pb.PsbtDraft {
			resp, err := cli.ListDrafts(ctx, &pb.ListDraftsRequest{WalletId: walletID})
			require.NoError(t, err)
			return resp.Drafts
		}
		coin := strings.Repeat("aa", 32)

		saved, err := cli.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: &pb.PsbtDraft{
			WalletId: "w1", Label: "rent", PsbtBase64: spending(t, coin),
		}})
		require.NoError(t, err)
		require.NotEmpty(t, saved.Draft.Id)
		assert.Equal(t, []string{coin + ":0"}, saved.Draft.Inputs)

		updated, err := cli.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: &pb.PsbtDraft{
			Id: saved.Draft.Id, WalletId: "w1", Label: "rent", PsbtBase64: saved.Draft.PsbtBase64, Txid: "aa",
		}})
		require.NoError(t, err)
		assert.Equal(t, saved.Draft.CreatedAt, updated.Draft.CreatedAt)

		drafts := list("w1")
		require.Len(t, drafts, 1)
		assert.Equal(t, "aa", drafts[0].Txid)
		assert.Equal(t, []string{coin + ":0"}, drafts[0].Inputs)
		assert.Empty(t, list("w2"))

		_, err = cli.DeleteDraft(ctx, &pb.DeleteDraftRequest{Id: saved.Draft.Id})
		require.NoError(t, err)
		assert.Empty(t, list("w1"))
	})

	t.Run("refuses a request with a missing field", func(t *testing.T) {
		t.Parallel()

		cli := rpc.NewWalletPsbtServiceClient(apitests.RPC(t, database.Test(t)))
		ctx := t.Context()

		_, err := cli.ListDrafts(ctx, &pb.ListDraftsRequest{})
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		valid := spending(t, strings.Repeat("aa", 32))
		for _, draft := range []*pb.PsbtDraft{
			nil, {PsbtBase64: valid}, {WalletId: "w1"}, {WalletId: "w1", PsbtBase64: "cHNidP8B"},
		} {
			_, err = cli.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: draft})
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		}

		_, err = cli.DeleteDraft(ctx, &pb.DeleteDraftRequest{})
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

// No new send may take the coins of a draft that waits for a broadcast. A
// broadcast or a discard gives them back.
func TestDraftsLockTheirCoinsUntilBroadcastOrDiscard(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	store := walletpsbt.NewStore(db)
	var locked []string
	srv := api.New(db, func(ctx context.Context) error {
		var err error
		locked, err = store.PendingInputs(ctx, []string{"w1"})
		return err
	})
	ctx := t.Context()
	rent, gift := strings.Repeat("aa", 32), strings.Repeat("bb", 32)

	first, err := srv.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: &pb.PsbtDraft{WalletId: "w1", PsbtBase64: spending(t, rent)}})
	require.NoError(t, err)
	assert.Equal(t, []string{rent + ":0"}, locked)

	second, err := srv.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: &pb.PsbtDraft{WalletId: "w1", PsbtBase64: spending(t, gift)}})
	require.NoError(t, err)
	assert.ElementsMatch(t, []string{rent + ":0", gift + ":0"}, locked)

	first.Draft.Txid = strings.Repeat("cc", 32)
	_, err = srv.SaveDraft(ctx, &pb.SaveDraftRequest{Draft: first.Draft})
	require.NoError(t, err)
	assert.Equal(t, []string{gift + ":0"}, locked)

	_, err = srv.DeleteDraft(ctx, &pb.DeleteDraftRequest{Id: second.Draft.Id})
	require.NoError(t, err)
	assert.Empty(t, locked)
}

// A new draft whose coins could not lock must not stay behind with no tab.
func TestSaveDraftFailsWhenTheLockFails(t *testing.T) {
	t.Parallel()

	db := database.Test(t)
	srv := api.New(db, func(context.Context) error { return errors.New("drivechaind is down") })
	_, err := srv.SaveDraft(t.Context(), &pb.SaveDraftRequest{Draft: &pb.PsbtDraft{
		WalletId: "w1", PsbtBase64: spending(t, strings.Repeat("aa", 32)),
	}})
	require.ErrorContains(t, err, "drivechaind is down")

	drafts, err := walletpsbt.NewStore(db).List(t.Context(), "w1")
	require.NoError(t, err)
	assert.Empty(t, drafts)
}
