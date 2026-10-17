package walletpsbt_test

import (
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
)

func TestDrafts(t *testing.T) {
	t.Parallel()

	t.Run("save, list and delete a draft", func(t *testing.T) {
		t.Parallel()

		cli := rpc.NewWalletPsbtServiceClient(apitests.API(t, database.Test(t)))
		ctx := t.Context()
		list := func(walletID string) []*pb.PsbtDraft {
			resp, err := cli.ListDrafts(ctx, connect.NewRequest(&pb.ListDraftsRequest{WalletId: walletID}))
			require.NoError(t, err)
			return resp.Msg.Drafts
		}

		saved, err := cli.SaveDraft(ctx, connect.NewRequest(&pb.SaveDraftRequest{Draft: &pb.PsbtDraft{
			WalletId: "w1", Label: "rent", PsbtBase64: "cHNidP8=",
		}}))
		require.NoError(t, err)
		require.NotEmpty(t, saved.Msg.Draft.Id)

		updated, err := cli.SaveDraft(ctx, connect.NewRequest(&pb.SaveDraftRequest{Draft: &pb.PsbtDraft{
			Id: saved.Msg.Draft.Id, WalletId: "w1", Label: "rent", PsbtBase64: "cHNidP8B", Txid: "aa",
		}}))
		require.NoError(t, err)
		assert.Equal(t, saved.Msg.Draft.CreatedAt, updated.Msg.Draft.CreatedAt)

		drafts := list("w1")
		require.Len(t, drafts, 1)
		assert.Equal(t, "cHNidP8B", drafts[0].PsbtBase64)
		assert.Equal(t, "aa", drafts[0].Txid)
		assert.Empty(t, list("w2"))

		_, err = cli.DeleteDraft(ctx, connect.NewRequest(&pb.DeleteDraftRequest{Id: saved.Msg.Draft.Id}))
		require.NoError(t, err)
		assert.Empty(t, list("w1"))
	})

	t.Run("refuses a request with a missing field", func(t *testing.T) {
		t.Parallel()

		cli := rpc.NewWalletPsbtServiceClient(apitests.API(t, database.Test(t)))
		ctx := t.Context()

		_, err := cli.ListDrafts(ctx, connect.NewRequest(&pb.ListDraftsRequest{}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))

		for _, draft := range []*pb.PsbtDraft{nil, {PsbtBase64: "cHNidP8="}, {WalletId: "w1"}} {
			_, err = cli.SaveDraft(ctx, connect.NewRequest(&pb.SaveDraftRequest{Draft: draft}))
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		}

		_, err = cli.DeleteDraft(ctx, connect.NewRequest(&pb.DeleteDraftRequest{}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}
