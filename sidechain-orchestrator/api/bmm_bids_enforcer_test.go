package api

import (
	"context"
	"io"
	"net/http"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// bidValidator answers the seen bids of one parent block, cheapest first.
type bidValidator struct {
	enforcerrpc.UnimplementedValidatorServiceHandler
	askedParent string
	askedSlot   uint32
}

func (v *bidValidator) GetSeenBmmRequests(
	_ context.Context, req *connect.Request[enforcerpb.GetSeenBmmRequestsRequest],
) (*connect.Response[enforcerpb.GetSeenBmmRequestsResponse], error) {
	v.askedParent = req.Msg.GetPrevBlockHash().GetHex().GetValue()
	v.askedSlot = req.Msg.GetSidechainNumber().GetValue()
	return connect.NewResponse(&enforcerpb.GetSeenBmmRequestsResponse{
		Requests: []*enforcerpb.GetSeenBmmRequestsResponse_BmmRequest{
			{
				SidechainNumber: 9,
				Txid:            &commonpb.ReverseHex{Hex: wrapperspb.String("cheap")},
				CriticalHash:    &commonpb.ConsensusHex{Hex: wrapperspb.String("block-a")},
				BidSats:         2_000,
			},
			{
				SidechainNumber: 9,
				Txid:            &commonpb.ReverseHex{Hex: wrapperspb.String("rich")},
				CriticalHash:    &commonpb.ConsensusHex{Hex: wrapperspb.String("block-b")},
				BidSats:         25_000,
			},
		},
	}), nil
}

// The enforcer holds every bid the mainchain mempool carries, so both modes
// read it there. The answer names the highest bid first, whatever order the
// enforcer sends.
func TestListBidsReadsTheEnforcerInBothModes(t *testing.T) {
	for _, mode := range []orchestrator.NodeMode{orchestrator.NodeModeFull, orchestrator.NodeModeLight} {
		t.Run(string(mode), func(t *testing.T) {
			validator := &bidValidator{}
			mux := http.NewServeMux()
			path, handler := enforcerrpc.NewValidatorServiceHandler(validator)
			mux.Handle(path, handler)
			server := h2cServer(mux)
			t.Cleanup(server.Close)
			host, port := hostPort(t, server)

			orch := orchestrator.New(t.TempDir(), string(config.NetworkECash), t.TempDir(),
				[]orchestrator.BinaryConfig{
					{Name: "enforcer", Host: host, Port: port},
					{Name: "thunder", ChainLayer: 2, Slot: 9},
				}, zerolog.New(io.Discard))
			t.Cleanup(orch.StopAllMonitors)
			entry := config.ECashEndpoints()
			t.Cleanup(func() { config.SetECashEndpoints(entry) })
			remote := entry
			remote.Services.Enforcer.URL = server.URL
			config.SetECashEndpoints(remote)
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, mode))
			t.Cleanup(func() { require.NoError(t, orch.SetNodeMode(context.Background(), orchestrator.NodeModeFull)) })
			require.Equal(t, mode, orch.NodeMode())

			resp, err := NewBMMHandler(orch, nil).ListBids(context.Background(),
				connect.NewRequest(&bmmpb.ListBidsRequest{
					Sidechain:    pb.BinaryType_BINARY_TYPE_THUNDER,
					PrevMainHash: "parent-1",
				}))
			require.NoError(t, err)

			require.Len(t, resp.Msg.Bids, 2)
			assert.Equal(t, "rich", resp.Msg.Bids[0].Txid, "the highest bid comes first")
			assert.EqualValues(t, 25_000, resp.Msg.Bids[0].BidSats)
			assert.Equal(t, "block-b", resp.Msg.Bids[0].CriticalHash)
			assert.Equal(t, "parent-1", resp.Msg.Bids[0].PrevMainHash)
			assert.Equal(t, "cheap", resp.Msg.Bids[1].Txid)

			assert.Equal(t, "parent-1", validator.askedParent)
			assert.EqualValues(t, 9, validator.askedSlot)
		})
	}
}
