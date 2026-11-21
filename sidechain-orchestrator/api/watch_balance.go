package api

import (
	"context"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/proto"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/watch"
)

// balanceRecheckInterval matches the old app poll. It finds a change that
// sends no event, such as a mempool payment to a Core with no ZMQ. The engine
// cache answers the recheck from memory when Core has ZMQ.
var balanceRecheckInterval = time.Second

func (h *WalletHandler) WatchBalance(ctx context.Context, req *pb.WatchBalanceRequest, stream rpc.WalletManagerServiceWatchBalanceServerStream) error {
	if err := h.requireEngine(); err != nil {
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	read := func() (*pb.WatchBalanceResponse, error) {
		if req.WalletId == "" && h.svc.ActiveWalletID() == "" {
			return &pb.WatchBalanceResponse{}, nil
		}
		walletID, err := h.engine.ResolveWalletID(req.WalletId)
		if err != nil {
			return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
		}
		balance, err := h.readBalance(ctx, walletID)
		if err != nil {
			return nil, err
		}
		return &pb.WatchBalanceResponse{WalletId: walletID, Balance: balance}, nil
	}
	return watch.Changes(ctx, h.balanceChanges(ctx), balanceRecheckInterval, WatchHeartbeatInterval, read,
		func(a, b *pb.WatchBalanceResponse) bool { return proto.Equal(a, b) },
		func(r *pb.WatchBalanceResponse) error {
			if r.Balance != nil {
				if err := h.saveBalance(r.WalletId, r.Balance); err != nil {
					return err
				}
			}
			return stream.Send(r)
		},
		func() error { return stream.Send(&pb.WatchBalanceResponse{Heartbeat: true}) },
	)
}

// balanceChanges wakes on each wallet event of Core and on each wallet
// switch. The wallet service also wakes it for an electrum wallet change.
func (h *WalletHandler) balanceChanges(ctx context.Context) <-chan struct{} {
	out := make(chan struct{}, 1)
	forward := func(in <-chan struct{}) {
		for range in {
			select {
			case out <- struct{}{}:
			default:
			}
		}
	}
	go forward(h.svc.Subscribe(ctx))
	if h.chainData != nil {
		go forward(h.chainData.Subscribe(ctx, chaindata.KindWallet))
	}
	return out
}
