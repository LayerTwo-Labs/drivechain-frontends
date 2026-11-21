package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/wire"
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

// newTxTries is the number of reads after which a written tx that the
// wallet does not hold counts as not the wallet's.
const newTxTries = 2

func (h *WalletHandler) WatchBalance(ctx context.Context, req *pb.WatchBalanceRequest, stream rpc.WalletManagerServiceWatchBalanceServerStream) error {
	if err := h.requireEngine(); err != nil {
		return connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}
	changed := h.balanceChanges(ctx)
	var fresh *freshTxids
	if h.chainData != nil {
		fresh = &freshTxids{tried: map[string]freshTx{}}
		changed = fresh.follow(ctx, h.chainData, changed)
	}
	var last *pb.WatchBalanceResponse
	read := func() (*pb.WatchBalanceResponse, error) {
		for {
			if req.WalletId == "" && h.svc.ActiveWalletID() == "" {
				return &pb.WatchBalanceResponse{}, nil
			}
			walletID, err := h.engine.ResolveWalletID(req.WalletId)
			if err != nil {
				return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
			}
			// The balance goes out first, and the entries of a send in the next
			// frame. That frame reads no balance, so it waits for no wallet read
			// that the first frame starts.
			if fresh != nil && last != nil && last.WalletId == walletID && fresh.consumeTurn() {
				entries, err := h.freshEntries(ctx, walletID, fresh)
				if err != nil {
					return nil, err
				}
				return &pb.WatchBalanceResponse{WalletId: walletID, Balance: last.Balance, Transactions: entries}, nil
			}
			balance, err := h.readBalance(ctx, walletID)
			if err == nil {
				last = &pb.WatchBalanceResponse{WalletId: walletID, Balance: balance}
				if fresh != nil {
					fresh.armTurn()
				}
				return last, nil
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
	return watch.Changes(ctx, changed, balanceRecheckInterval, WatchHeartbeatInterval, read,
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

// freshTxids holds the txs that a write made after the last balance read.
type freshTxids struct {
	mu     sync.Mutex
	tried  map[string]freshTx
	events uint64
	// entriesTurn marks that the last read sent the balance only.
	entriesTurn bool
	wake        func()
}

type freshTx struct {
	tries     int
	lastEvent uint64
}

// follow adds the txid of each write and wakes the reader. It forwards each
// wallet event of in.
func (f *freshTxids) follow(ctx context.Context, data *chaindata.Engine, in <-chan struct{}) <-chan struct{} {
	out := make(chan struct{}, 1)
	wake := func() {
		select {
		case out <- struct{}{}:
		default:
		}
	}
	f.wake = wake
	writes := data.SubscribeWrites(ctx)
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case txid := <-writes:
				f.mu.Lock()
				f.tried[txid] = freshTx{lastEvent: f.events - 1}
				f.mu.Unlock()
				wake()
			case _, ok := <-in:
				if !ok {
					return
				}
				f.mu.Lock()
				f.events++
				f.mu.Unlock()
				wake()
			}
		}
	}()
	return out
}

// consumeTurn reports whether this read sends the entries, and clears the turn.
func (f *freshTxids) consumeTurn() bool {
	f.mu.Lock()
	defer f.mu.Unlock()
	turn := f.entriesTurn
	f.entriesTurn = false
	return turn
}

// armTurn gives the next read to the entries when a txid waits for a read,
// and wakes that read.
func (f *freshTxids) armTurn() {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, t := range f.tried {
		if t.lastEvent != f.events {
			f.entriesTurn = true
			if f.wake != nil {
				f.wake()
			}
			return
		}
	}
}

// due gives the txids to read: each one at most one time per wallet event.
func (f *freshTxids) due() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []string
	for txid, t := range f.tried {
		if t.lastEvent == f.events {
			continue
		}
		t.tries++
		t.lastEvent = f.events
		if t.tries >= newTxTries {
			delete(f.tried, txid)
		} else {
			f.tried[txid] = t
		}
		out = append(out, txid)
	}
	return out
}

func (f *freshTxids) found(txid string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	delete(f.tried, txid)
}

// freshEntries reads the written txs that the wallet holds, as
// ListTransactions entries.
func (h *WalletHandler) freshEntries(ctx context.Context, walletID string, fresh *freshTxids) ([]*pb.TransactionEntry, error) {
	// The txids come from Core writes, so only a Core wallet can hold them.
	if w := h.svc.GetWalletByID(walletID); w == nil || w.WalletType == wallet.WalletTypeElectrum {
		return nil, nil
	}
	var rows []wallet.WalletTransaction
	for _, txid := range fresh.due() {
		tx, err := h.engine.Backend().GetWalletTransaction(ctx, walletID, txid)
		if err != nil {
			if strings.Contains(err.Error(), "non-wallet transaction") {
				continue
			}
			return nil, fmt.Errorf("read new transaction %s: %w", txid, err)
		}
		fresh.found(txid)
		if err := h.keepBidScript(tx); err != nil {
			return nil, err
		}
		rows = append(rows, tx.Rows()...)
	}
	if len(rows) == 0 {
		return nil, nil
	}
	return h.transactionEntries(ctx, walletID, rows)
}

// keepBidScript stores the first output script of tx for the bid labels, so
// they need no Core read for it.
func (h *WalletHandler) keepBidScript(tx *wallet.WalletTx) error {
	raw, err := hex.DecodeString(tx.Hex)
	if err != nil {
		return fmt.Errorf("decode the hex of %s: %w", tx.TxID, err)
	}
	var msg wire.MsgTx
	if err := msg.Deserialize(bytes.NewReader(raw)); err != nil {
		return fmt.Errorf("decode transaction %s: %w", tx.TxID, err)
	}
	if len(msg.TxOut) > 0 {
		h.bidScripts.Store(tx.TxID, hex.EncodeToString(msg.TxOut[0].PkScript))
	}
	return nil
}
