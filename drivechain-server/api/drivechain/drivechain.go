package api_drivechain

import (
	"context"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/drivechain/v1/drivechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/enforcer"
	coreproxy "github.com/barebitcoin/btc-buf/server"
)

var _ rpc.DrivechainServiceHandler = new(Server)

// New creates a new Server
func New(
	bitcoind *coreproxy.Bitcoind, enforcer enforcer.ValidatorClient,

) *Server {
	s := &Server{
		bitcoind: bitcoind, enforcer: enforcer,
	}
	return s
}

type Server struct {
	bitcoind *coreproxy.Bitcoind
	enforcer enforcer.ValidatorClient
}

// ListSidechains implements drivechainv1connect.DrivechainServiceHandler.
func (s *Server) ListSidechains(ctx context.Context, _ *connect.Request[pb.ListSidechainsRequest]) (*connect.Response[pb.ListSidechainsResponse], error) {
	return connect.NewResponse(&pb.ListSidechainsResponse{
		Sidechains: []*pb.ListSidechainsResponse_Sidechain{
			{
				Title:         "Testchain",
				Description:   "A test sidechain",
				Nversion:      1,
				Hashid1:       "0000000000000000000000000000000000000000000000000000000000000001",
				Hashid2:       "0000000000000000000000000000000000000000000000000000000000000002",
				Slot:          1,
				AmountSatoshi: 1000000,
				ChaintipTxid:  "1111111111111111111111111111111111111111111111111111111111111111",
			},
			{
				Title:         "ZKchain",
				Description:   "A zero-knowledge sidechain",
				Nversion:      1,
				Hashid1:       "0000000000000000000000000000000000000000000000000000000000000003",
				Hashid2:       "0000000000000000000000000000000000000000000000000000000000000004",
				Slot:          2,
				AmountSatoshi: 2000000,
				ChaintipTxid:  "2222222222222222222222222222222222222222222222222222222222222222",
			},
			{
				Title:         "Smartchain",
				Description:   "A smart contract sidechain",
				Nversion:      1,
				Hashid1:       "0000000000000000000000000000000000000000000000000000000000000005",
				Hashid2:       "0000000000000000000000000000000000000000000000000000000000000006",
				Slot:          3,
				AmountSatoshi: 3000000,
				ChaintipTxid:  "3333333333333333333333333333333333333333333333333333333333333333",
			},
		},
	}), nil
}
