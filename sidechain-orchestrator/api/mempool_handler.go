package api

import (
	"context"
	"time"

	"connectrpc.com/connect/v2"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/mempool/v1/mempoolv1connect"
)

// snapshotPart is the most transactions in one snapshot message.
const snapshotPart = 5000

var _ rpc.MempoolServiceHandler = (*MempoolHandler)(nil)

// MempoolHandler serves MempoolService from the mempool tracker.
type MempoolHandler struct {
	mempool   *chaindata.Mempool
	heartbeat time.Duration
}

// NewMempoolHandler builds a MempoolHandler on m.
func NewMempoolHandler(m *chaindata.Mempool) *MempoolHandler {
	return &MempoolHandler{mempool: m, heartbeat: WatchHeartbeatInterval}
}

func (h *MempoolHandler) ListTransactions(ctx context.Context, req *pb.ListTransactionsRequest) (*pb.ListTransactionsResponse, error) {
	txs, total, err := h.mempool.Newest(ctx, int(req.GetCount()))
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	out := &pb.ListTransactionsResponse{Transactions: make([]*pb.Transaction, len(txs)), Total: uint64(total)}
	for i, tx := range txs {
		out.Transactions[i] = txToProto(tx)
	}
	return out, nil
}

func (h *MempoolHandler) GetStats(ctx context.Context, req *pb.GetStatsRequest) (*pb.GetStatsResponse, error) {
	stats, err := h.mempool.Stats(ctx, req.GetBucketEdges())
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	out := &pb.GetStatsResponse{
		TxCount:       stats.TxCount,
		Vsize:         stats.Vsize,
		FeeSats:       stats.FeeSats,
		MedianFeeRate: stats.MedianFeeRate,
		Buckets:       make([]*pb.FeeBucket, len(stats.Buckets)),
	}
	for i, b := range stats.Buckets {
		out.Buckets[i] = &pb.FeeBucket{MinFeeRate: b.MinFeeRate, TxCount: b.TxCount, Vsize: b.Vsize, FeeSats: b.FeeSats}
	}
	return out, nil
}

func (h *MempoolHandler) WatchTransactions(ctx context.Context, _ *pb.WatchTransactionsRequest, stream rpc.MempoolServiceWatchTransactionsServerStream) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	feed := h.mempool.Watch(ctx)
	if err := stream.SendHeaders(); err != nil {
		return err
	}
	type next struct {
		snap    *chaindata.MempoolSnapshot
		changes []chaindata.MempoolChange
		err     error
	}
	results := make(chan next)
	go func() {
		for {
			snap, changes, err := feed.Next(ctx)
			select {
			case results <- next{snap, changes, err}:
			case <-ctx.Done():
				return
			}
			if err != nil {
				return
			}
		}
	}()
	beat := time.NewTicker(h.heartbeat)
	defer beat.Stop()
	for {
		select {
		case <-ctx.Done():
			return nil
		case <-beat.C:
			if err := stream.Send(&pb.WatchTransactionsResponse{Heartbeat: true}); err != nil {
				return err
			}
		case n := <-results:
			if n.err != nil {
				return nil
			}
			if err := sendFeed(stream, n.snap, n.changes); err != nil {
				return err
			}
		}
	}
}

func sendFeed(stream rpc.MempoolServiceWatchTransactionsServerStream, snap *chaindata.MempoolSnapshot, changes []chaindata.MempoolChange) error {
	if snap != nil {
		for start := 0; ; start += snapshotPart {
			end := min(start+snapshotPart, len(snap.Txs))
			part := &pb.Snapshot{Height: snap.Height, More: end < len(snap.Txs)}
			for _, tx := range snap.Txs[start:end] {
				part.Transactions = append(part.Transactions, txToProto(tx))
			}
			if err := stream.Send(&pb.WatchTransactionsResponse{Snapshot: part}); err != nil {
				return err
			}
			if !part.More {
				break
			}
		}
	}
	if len(changes) == 0 {
		return nil
	}
	msg := &pb.WatchTransactionsResponse{Changes: make([]*pb.Change, len(changes))}
	for i, c := range changes {
		switch {
		case c.Added != nil:
			msg.Changes[i] = &pb.Change{Change: &pb.Change_Added{Added: txToProto(*c.Added)}}
		case c.Block != nil:
			msg.Changes[i] = &pb.Change{Change: &pb.Change_Block{Block: &pb.Block{
				Hash: c.Block.Hash, Height: c.Block.Height, Connected: c.Block.Connected, Txids: c.Block.Txids,
			}}}
		default:
			msg.Changes[i] = &pb.Change{Change: &pb.Change_Removed{Removed: c.Removed}}
		}
	}
	return stream.Send(msg)
}

func txToProto(tx chaindata.MempoolTx) *pb.Transaction {
	return &pb.Transaction{
		Txid:            tx.Txid,
		FeeSats:         uint64(max(tx.FeeSats, 0)),
		Vsize:           tx.Vsize,
		Time:            timestamppb.New(tx.Time),
		AncestorFeeSats: uint64(max(tx.AncestorFeeSats, 0)),
		AncestorVsize:   tx.AncestorVsize,
		Height:          tx.Height,
	}
}
