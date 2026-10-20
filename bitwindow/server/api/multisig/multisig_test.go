package multisig_test

import (
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1/multisigv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
)

func TestSaveGroup(t *testing.T) {
	t.Parallel()

	t.Run("each key keeps its own psbts", func(t *testing.T) {
		t.Parallel()

		cli := rpc.NewMultisigServiceClient(apitests.RPC(t, database.Test(t)))
		group := &pb.MultisigGroup{
			Id: "g1", Name: "family", N: 2, M: 2,
			Keys: []*pb.MultisigKey{
				{
					Owner: "alice", Xpub: "xpubA", Fingerprint: "aaaaaaaa",
					ActivePsbts:  map[string]string{"tx1": "activeA1", "tx2": "activeA2"},
					InitialPsbts: map[string]string{"tx1": "initialA1", "tx2": "initialA2"},
				},
				{
					Owner: "bob", Xpub: "xpubB", Fingerprint: "bbbbbbbb",
					ActivePsbts:  map[string]string{"tx1": "activeB1", "tx2": "activeB2"},
					InitialPsbts: map[string]string{"tx1": "initialB1", "tx2": "initialB2"},
				},
			},
			TransactionIds: []string{"tx1", "tx2"},
		}

		saved, err := cli.SaveGroup(t.Context(), &pb.SaveGroupRequest{Group: group})
		require.NoError(t, err)
		listed, err := cli.ListGroups(t.Context(), &emptypb.Empty{})
		require.NoError(t, err)
		require.Len(t, listed.Groups, 1)

		for _, got := range []*pb.MultisigGroup{saved.Group, listed.Groups[0]} {
			require.Len(t, got.Keys, 2)
			for i, key := range got.Keys {
				assert.Equal(t, group.Keys[i].Xpub, key.Xpub)
				assert.Equal(t, group.Keys[i].ActivePsbts, key.ActivePsbts)
				assert.Equal(t, group.Keys[i].InitialPsbts, key.InitialPsbts)
			}
			assert.ElementsMatch(t, group.TransactionIds, got.TransactionIds)
		}
	})

	t.Run("refuses a group with no id", func(t *testing.T) {
		t.Parallel()

		cli := rpc.NewMultisigServiceClient(apitests.RPC(t, database.Test(t)))

		_, err := cli.SaveGroup(t.Context(), &pb.SaveGroupRequest{Group: &pb.MultisigGroup{Name: "family"}})
		require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}
