package api_misc

import (
	"context"
	"database/sql"

	"connectrpc.com/connect"
	miscv1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/misc/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/servers/bitwindow/models/opreturns"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var _ rpc.MiscServiceHandler = new(Server)

// New creates a new misc Server. Misc is a horrible name, but can't think of
// anything else just yet.
func New(
	bitcoind *coreproxy.Bitcoind, database *sql.DB,
) *Server {
	s := &Server{
		bitcoind: bitcoind,
		database: database,
	}
	return s
}

type Server struct {
	bitcoind *coreproxy.Bitcoind
	database *sql.DB
}

// ListOPReturn implements miscv1connect.MiscServiceHandler.
func (s *Server) ListOPReturn(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[miscv1.ListOPReturnResponse], error) {
	opReturns, err := opreturns.Select(ctx, s.database)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&miscv1.ListOPReturnResponse{
		OpReturns: lo.Map(opReturns, opReturnToProto),
	}), nil
}

func opReturnToProto(opReturn opreturns.OPReturn, _ int) *miscv1.OPReturn {
	return &miscv1.OPReturn{
		Id:         opReturn.ID,
		Message:    opreturns.OPReturnToReadable(opReturn.Data),
		Txid:       opReturn.TxID,
		Vout:       opReturn.Vout,
		Height:     opReturn.Height,
		FeeSatoshi: opReturn.FeeSatoshi,

		CreateTime: timestamppb.New(opReturn.CreatedAt),
	}
}
