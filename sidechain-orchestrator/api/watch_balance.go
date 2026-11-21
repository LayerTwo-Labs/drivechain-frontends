package api

import (
	"context"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/proto"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
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
		for {
			if req.WalletId == "" && h.svc.ActiveWalletID() == "" {
				return &pb.WatchBalanceResponse{}, nil
			}
			walletID, err := h.engine.ResolveWalletID(req.WalletId)
			if err != nil {
				return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
			}
			balance, err := h.readBalance(ctx, walletID)
			if err == nil {
				return &pb.WatchBalanceResponse{WalletId: walletID, Balance: balance}, nil
			}
			// While Core is down, the stream stays open and reads again when Core
			// or the wallet changes.
			if !h.readsCore(walletID) || h.chainData.Health() == nil {
				return nil, err
			}
			if err := h.waitForCoreOrWallet(ctx, req.WalletId == "", walletID); err != nil {
				return nil, err
			}
		}
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

// readsCore reports whether the balance of walletID comes from the local Core.
func (h *WalletHandler) readsCore(walletID string) bool {
	if h.chainData == nil || !h.chainData.Running() {
		return false
	}
	w := h.svc.GetWalletByID(walletID)
	return w != nil && w.WalletType != wallet.WalletTypeElectrum
}

// waitForCoreOrWallet returns at the next health change of Core or wallet
// change. It returns at once when Core is up, or when the stream follows the
// active wallet and walletID is no longer active.
func (h *WalletHandler) waitForCoreOrWallet(ctx context.Context, followsActive bool, walletID string) error {
	waitCtx, cancel := context.WithCancel(ctx)
	defer cancel()
	health := h.chainData.Subscribe(waitCtx, chaindata.KindHealth)
	wallets := h.svc.Subscribe(waitCtx)
	if h.chainData.Health() == nil || (followsActive && h.svc.ActiveWalletID() != walletID) {
		return nil
	}
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-health:
	case <-wallets:
	}
	return nil
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
