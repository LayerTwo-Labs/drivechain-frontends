package api_drivechain

import (
	"context"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/drivechaind/v1"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/samber/lo"
)

var _ rpc.DrivechainServiceHandler = new(Server)

// New creates a new Server
func New(bitcoind *coreproxy.Bitcoind) *Server {
	s := &Server{bitcoind: bitcoind}
	return s
}

type Server struct {
	bitcoind *coreproxy.Bitcoind
}

// ListSidechains implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListSidechains(ctx context.Context, _ *connect.Request[pb.ListSidechainsRequest]) (*connect.Response[pb.ListSidechainsResponse], error) {
	sidechains, err := s.bitcoind.ListActiveSidechains(ctx, connect.NewRequest(&corepb.ListActiveSidechainsRequest{}))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&pb.ListSidechainsResponse{
		Sidechains: lo.Map(sidechains.Msg.Sidechains, func(sidechain *corepb.ListActiveSidechainsResponse_Sidechain, _ int) *pb.ListSidechainsResponse_Sidechain {
			return &pb.ListSidechainsResponse_Sidechain{
				Title:         sidechain.Title,
				Description:   sidechain.Description,
				Nversion:      sidechain.Nversion,
				Hashid1:       sidechain.Hashid1,
				Hashid2:       sidechain.Hashid2,
				Slot:          sidechain.Slot,
				AmountSatoshi: sidechain.AmountSatoshi,
				ChaintipTxid:  sidechain.ChaintipTxid,
			}
		}),
	}), nil
}
