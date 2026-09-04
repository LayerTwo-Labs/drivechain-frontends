package api

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"connectrpc.com/connect"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// blockListSize is how many headers the overview carries.
const blockListSize = 6

// activityListSize is how many rows the overview carries.
const activityListSize = 12

// addressPageSize is how many confirmed rows one index page carries. A shorter
// page is the last one.
const addressPageSize = 25

// addressHistoryLimit bounds how deep the explorer reads one address. A busy
// address then costs a bounded number of calls.
const addressHistoryLimit = 100

// Bundle weights, as the chain sizes a withdrawal bundle.
const (
	maxWithdrawalBundleWeight  = 50000
	baseWithdrawalBundleWeight = 288
	weightPerWithdrawalOutput  = 136
)

// ExplorerHandler serves the block explorer.
//
// A light client runs no node, so it reads a hosted index. A full node answers
// from its own chain. No sidechain node keeps an address history, so the
// address call needs an index either way.
type ExplorerHandler struct {
	orch *orchestrator.Orchestrator
}

// NewExplorerHandler builds the handler.
func NewExplorerHandler(orch *orchestrator.Orchestrator) *ExplorerHandler {
	return &ExplorerHandler{orch: orch}
}

// source is where one chain's explorer reads from. Exactly one of index and
// node is set.
type source struct {
	name  string
	slot  uint32
	index *sidechainesplora.Client
	node  sidechain.SidechainRPCProxy
	// core is true for a chain built on Bitcoin Core. Such a node speaks
	// Core's own method names, not the CUSF ones this file reads.
	core bool
}

// sourceFor picks the index when one is hosted, and the local node otherwise.
func (h *ExplorerHandler) sourceFor(chain string) (source, error) {
	if h.orch == nil {
		return source{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("orchestrator not wired"))
	}
	chain = strings.TrimSpace(chain)
	if chain == "" {
		return source{}, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("name a chain"))
	}
	cfg, ok := h.orch.Configs()[chain]
	if !ok {
		return source{}, connect.NewError(connect.CodeNotFound,
			fmt.Errorf("sidechain %s is not configured", chain))
	}
	network := config.NetworkFromString(h.orch.CurrentNetwork())

	out := source{name: chain, core: cfg.IsBitcoinCore}
	if cfg.Slot >= 0 && cfg.Slot <= 255 {
		out.slot = uint32(cfg.Slot)
	}
	// A full node answers from its own chain. Only a light client reads the
	// hosted index, so the two never disagree about the tip. This is the same
	// answer the wallet resolves, and it moves with a network swap.
	light := orchestrator.NodeModeForNetwork(
		orchestrator.ReadNodeMode(h.orch.BitwindowDir), network,
	) == orchestrator.NodeModeLight
	if light {
		if url := config.SidechainEsploraURLForNetwork(chain, network); url != "" {
			out.index = sidechainesplora.New(url)
			return out, nil
		}
	}
	node, err := sidechainProxy(cfg, network)
	if err != nil {
		return source{}, connect.NewError(connect.CodeUnavailable, err)
	}
	out.node = node
	return out, nil
}

// GetOverview answers the explorer landing page.
func (h *ExplorerHandler) GetOverview(
	ctx context.Context, req *connect.Request[pb.GetOverviewRequest],
) (*connect.Response[pb.GetOverviewResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	build := nodeOverview
	switch {
	case src.index != nil:
		build = indexOverview
	case src.core:
		build = coreOverview
	}
	out, err := build(ctx, src)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(out), nil
}

func indexOverview(ctx context.Context, src source) (*pb.GetOverviewResponse, error) {
	blocks, err := src.index.Blocks(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	recent, err := src.index.RecentActivity(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	pool, err := src.index.Mempool(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}

	out := &pb.GetOverviewResponse{
		Blocks:  blockList(blocks),
		Recent:  activityList(recent),
		Mempool: &pb.Mempool{TxCount: uint32(pool.Count), FeesSats: pool.Fees, SizeBytes: pool.VSize},
		Source:  "index",
	}
	if len(blocks) > 0 {
		out.TipHeight = blocks[0].Height
	}
	// The treasury and the bundle come from the mainchain and the node. An
	// index without either still answers the rest of the page.
	if info, err := src.index.Sidechain(ctx, src.slot); err == nil {
		out.Treasury = &pb.Treasury{
			Slot:             info.Slot,
			ActivationHeight: info.ActivationHeight,
		}
		if info.Treasury != nil {
			out.Treasury.BalanceSats = info.Treasury.ValueSats
			out.Treasury.CtipTxid = info.Treasury.Txid
			out.Treasury.CtipVout = info.Treasury.Vout
		}
	}
	if state, err := src.index.Withdrawals(ctx); err == nil {
		out.PendingBundle = parseBundle(state.Bundle)
	}
	return out, nil
}

func nodeOverview(ctx context.Context, src source) (*pb.GetOverviewResponse, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	out := &pb.GetOverviewResponse{Source: "node", Mempool: &pb.Mempool{}}
	if count <= 0 {
		return out, nil
	}
	tip := uint32(count - 1)
	out.TipHeight = tip

	hash, err := src.node.CallRaw(ctx, "get_best_sidechain_block_hash", nil)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	var next string
	if err := json.Unmarshal(hash, &next); err != nil {
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read the tip hash: %w", err))
	}

	for height := int64(tip); height >= 0 && next != "" && len(out.Blocks) < blockListSize; height-- {
		block, activity, err := nodeBlock(ctx, src, next, uint32(height))
		if err != nil {
			return nil, err
		}
		out.Blocks = append(out.Blocks, block)
		for _, row := range activity {
			if len(out.Recent) >= activityListSize {
				break
			}
			out.Recent = append(out.Recent, row)
		}
		next = block.GetPrevHash()
	}

	// The template is what the node would mine next, so it counts the
	// unconfirmed set.
	if template, err := src.node.GetBlockTemplate(ctx); err == nil && template != nil {
		out.Mempool.FeesSats = template.FeesSats
	}
	if raw, err := src.node.GetPendingWithdrawalBundle(ctx); err == nil {
		out.PendingBundle = parseBundle(raw)
	}
	return out, nil
}

// GetBlock reads one block and what it carried.
func (h *ExplorerHandler) GetBlock(
	ctx context.Context, req *connect.Request[pb.GetBlockRequest],
) (*connect.Response[pb.GetBlockResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	hash := strings.TrimSpace(req.Msg.GetHash())

	if src.index != nil {
		if hash == "" {
			hash, err = src.index.BlockHashAtHeight(ctx, req.Msg.GetHeight())
			if err != nil {
				return nil, connect.NewError(connect.CodeNotFound, err)
			}
			hash = strings.TrimSpace(hash)
		}
		block, err := src.index.Block(ctx, hash)
		if err != nil {
			return nil, connect.NewError(connect.CodeNotFound, err)
		}
		rows, err := src.index.BlockActivity(ctx, hash)
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
		return connect.NewResponse(&pb.GetBlockResponse{
			Block: newBlock(block), Activity: activityList(rows),
		}), nil
	}

	if src.core {
		var block *pb.Block
		var activity []*pb.Activity
		if hash != "" {
			block, activity, err = coreBlockByHash(ctx, src, hash)
		} else {
			block, activity, err = coreBlockAtHeight(ctx, src, req.Msg.GetHeight())
		}
		if err != nil {
			return nil, err
		}
		return connect.NewResponse(&pb.GetBlockResponse{Block: block, Activity: activity}), nil
	}

	if hash == "" {
		hash, err = nodeHashAtHeight(ctx, src, req.Msg.GetHeight())
		if err != nil {
			return nil, err
		}
	}
	block, activity, err := nodeBlock(ctx, src, hash, req.Msg.GetHeight())
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockResponse{Block: block, Activity: activity}), nil
}

// GetTransaction reads one transaction.
func (h *ExplorerHandler) GetTransaction(
	ctx context.Context, req *connect.Request[pb.GetTransactionRequest],
) (*connect.Response[pb.GetTransactionResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	txid := strings.TrimSpace(req.Msg.GetTxid())
	if txid == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("name a txid"))
	}
	if src.index == nil {
		return nil, connect.NewError(connect.CodeUnimplemented,
			fmt.Errorf("%s has no index, and a node reads no transaction by id", src.name))
	}
	tx, err := src.index.Tx(ctx, txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.GetTransactionResponse{Transaction: newTransaction(tx)}), nil
}

// GetAddress reads what an address holds and what it did.
func (h *ExplorerHandler) GetAddress(
	ctx context.Context, req *connect.Request[pb.GetAddressRequest],
) (*connect.Response[pb.GetAddressResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	address := strings.TrimSpace(req.Msg.GetAddress())
	if address == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("name an address"))
	}
	if src.index == nil {
		return nil, connect.NewError(connect.CodeUnimplemented,
			fmt.Errorf("%s has no index, and a node keeps no address history", src.name))
	}

	stats, err := src.index.AddressStats(ctx, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	// The first page already carries the unconfirmed rows, so a separate
	// mempool read would list every one of them twice.
	history, err := addressHistory(ctx, src, address)
	if err != nil {
		return nil, err
	}

	out := &pb.GetAddressResponse{
		Address:                address,
		ConfirmedBalanceSats:   stats.ChainStats.FundedTxoSum - stats.ChainStats.SpentTxoSum,
		UnconfirmedBalanceSats: stats.MempoolStats.FundedTxoSum - stats.MempoolStats.SpentTxoSum,
		TotalReceivedSats:      stats.ChainStats.FundedTxoSum,
		ConfirmedCoinCount:     uint32(stats.ChainStats.FundedTxoCount - stats.ChainStats.SpentTxoCount),
		UnconfirmedCoinCount:   uint32(stats.MempoolStats.FundedTxoCount),
		TxCount:                uint32(stats.ChainStats.TxCount + stats.MempoolStats.TxCount),
	}
	for _, tx := range history {
		out.Transactions = append(out.Transactions, newTransaction(tx))
	}
	return connect.NewResponse(out), nil
}

// addressHistory walks the address pages, newest first. The index pages at 25
// confirmed rows, and a page shorter than that is the last one.
func addressHistory(ctx context.Context, src source, address string) ([]sidechainesplora.Tx, error) {
	var out []sidechainesplora.Tx
	var lastSeen string
	for len(out) < addressHistoryLimit {
		page, err := src.index.AddressTxs(ctx, address, lastSeen)
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
		out = append(out, page...)
		if len(page) < addressPageSize {
			break
		}
		lastSeen = page[len(page)-1].Txid
	}
	return out, nil
}

// GetWithdrawals reads the bundle the chain proposes to the mainchain.
func (h *ExplorerHandler) GetWithdrawals(
	ctx context.Context, req *connect.Request[pb.GetWithdrawalsRequest],
) (*connect.Response[pb.GetWithdrawalsResponse], error) {
	src, err := h.sourceFor(req.Msg.GetChain())
	if err != nil {
		return nil, err
	}
	out := &pb.GetWithdrawalsResponse{}
	if src.index != nil {
		state, err := src.index.Withdrawals(ctx)
		if err != nil {
			return nil, connect.NewError(connect.CodeUnavailable, err)
		}
		out.Bundle = parseBundle(state.Bundle)
		if state.LastFailedHeight != nil {
			out.LastFailedHeight = *state.LastFailedHeight
		}
		return connect.NewResponse(out), nil
	}

	raw, err := src.node.GetPendingWithdrawalBundle(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	out.Bundle = parseBundle(raw)
	height, err := src.node.GetLatestFailedWithdrawalBundleHeight(ctx)
	if err == nil && height >= 0 {
		out.LastFailedHeight = uint32(height)
	}
	return connect.NewResponse(out), nil
}

// nodeHashAtHeight walks down from the tip to the hash at one height. No
// sidechain node reads a block by height, so the walk follows prev_side_hash.
func nodeHashAtHeight(ctx context.Context, src source, height uint32) (string, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return "", connect.NewError(connect.CodeUnavailable, err)
	}
	if count <= 0 || height > uint32(count-1) {
		return "", connect.NewError(connect.CodeNotFound,
			fmt.Errorf("%s holds no block at height %d", src.name, height))
	}

	raw, err := src.node.CallRaw(ctx, "get_best_sidechain_block_hash", nil)
	if err != nil {
		return "", connect.NewError(connect.CodeUnavailable, err)
	}
	var hash string
	if err := json.Unmarshal(raw, &hash); err != nil {
		return "", connect.NewError(connect.CodeInternal,
			fmt.Errorf("read the tip hash: %w", err))
	}

	for at := uint32(count - 1); at > height; at-- {
		header, err := nodeHeader(ctx, src, hash)
		if err != nil {
			return "", err
		}
		if header.Header.PrevSideHash == nil {
			break
		}
		hash = *header.Header.PrevSideHash
	}
	return hash, nil
}

// nodeHeaderJSON is the header shape a sidechain node returns.
type nodeHeaderJSON struct {
	Header struct {
		MerkleRoot   string  `json:"merkle_root"`
		PrevSideHash *string `json:"prev_side_hash"`
		PrevMainHash string  `json:"prev_main_hash"`
	} `json:"header"`
	Body struct {
		Transactions []json.RawMessage `json:"transactions"`
	} `json:"body"`
}

// nodeBlockIndex is what get_block_index returns: the txids and sizes a body
// does not carry.
type nodeBlockIndex struct {
	Txs []struct {
		Txid string `json:"txid"`
		Size uint64 `json:"size"`
	} `json:"txs"`
	Deposits []struct {
		Outpoint string `json:"outpoint"`
	} `json:"deposits"`
}

// nodeHeader reads one block header from the node.
func nodeHeader(ctx context.Context, src source, hash string) (nodeHeaderJSON, error) {
	// The node reads its params as a list. A bare string answers
	// "Invalid params", whatever the older handlers pass.
	raw, err := src.node.CallRaw(ctx, "get_block", []string{hash})
	if err != nil {
		return nodeHeaderJSON{}, connect.NewError(connect.CodeUnavailable, err)
	}
	var block nodeHeaderJSON
	if err := json.Unmarshal(raw, &block); err != nil {
		return nodeHeaderJSON{}, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read block %s: %w", hash, err))
	}
	return block, nil
}

// nodeBlock reads one block from the node, with the rows it carried. A node
// computes no fees, so every fee reads zero.
func nodeBlock(ctx context.Context, src source, hash string, height uint32) (*pb.Block, []*pb.Activity, error) {
	block, err := nodeHeader(ctx, src, hash)
	if err != nil {
		return nil, nil, err
	}

	out := &pb.Block{
		Height:        height,
		Hash:          hash,
		MerkleRoot:    block.Header.MerkleRoot,
		MainchainHash: block.Header.PrevMainHash,
		TxCount:       uint32(len(block.Body.Transactions)),
	}
	if block.Header.PrevSideHash != nil {
		out.PrevHash = *block.Header.PrevSideHash
	}

	// get_block_index names the txids a body does not carry. A node without
	// it still answers the header, and the block then lists no transactions.
	rawIndex, err := src.node.CallRaw(ctx, "get_block_index", []string{hash})
	if err != nil {
		return out, nil, nil
	}
	var index nodeBlockIndex
	if err := json.Unmarshal(rawIndex, &index); err != nil {
		return out, nil, nil
	}

	activity := make([]*pb.Activity, 0, len(index.Txs)+len(index.Deposits))
	for _, tx := range index.Txs {
		out.SizeBytes += int64(tx.Size)
		activity = append(activity, &pb.Activity{
			Kind:        pb.Kind_KIND_TRANSFER,
			Id:          tx.Txid,
			SizeBytes:   int64(tx.Size),
			Confirmed:   true,
			BlockHeight: height,
		})
	}
	for _, deposit := range index.Deposits {
		activity = append(activity, &pb.Activity{
			Kind:        pb.Kind_KIND_DEPOSIT,
			Id:          depositTxid(deposit.Outpoint),
			Confirmed:   true,
			BlockHeight: height,
		})
	}
	return out, activity, nil
}

// depositTxid reads the mainchain txid out of a "txid:vout" outpoint.
func depositTxid(outpoint string) string {
	if i := strings.LastIndex(outpoint, ":"); i > 0 {
		return outpoint[:i]
	}
	return outpoint
}

func blockList(rows []sidechainesplora.Block) []*pb.Block {
	out := make([]*pb.Block, 0, len(rows))
	for _, row := range rows {
		out = append(out, newBlock(row))
	}
	return out
}

func newBlock(row sidechainesplora.Block) *pb.Block {
	out := &pb.Block{
		Height:        row.Height,
		Hash:          row.ID,
		MerkleRoot:    row.MerkleRoot,
		MainchainHash: row.MainchainHash,
		TxCount:       uint32(row.TxCount),
		FeesSats:      row.Fees,
		SizeBytes:     int64(row.Size),
	}
	if row.PreviousHash != nil {
		out.PrevHash = *row.PreviousHash
	}
	if row.MainchainHeight != nil {
		out.MainchainHeight = *row.MainchainHeight
	}
	if row.Timestamp != nil {
		out.BlockTime = *row.Timestamp
	}
	return out
}

func activityList(rows []sidechainesplora.Activity) []*pb.Activity {
	out := make([]*pb.Activity, 0, len(rows))
	for _, row := range rows {
		item := &pb.Activity{
			Kind:      kindOf(row.Kind),
			Id:        row.ID,
			ValueSats: row.Value,
			FeeSats:   row.Fee,
			SizeBytes: int64(row.Size),
			Confirmed: row.Status.Confirmed,
		}
		item.BlockHeight = row.Status.BlockHeight
		item.BlockTime = row.Status.BlockTime
		out = append(out, item)
	}
	return out
}

func kindOf(name string) pb.Kind {
	switch name {
	case sidechainesplora.KindDeposit:
		return pb.Kind_KIND_DEPOSIT
	case sidechainesplora.KindWithdrawal:
		return pb.Kind_KIND_WITHDRAWAL
	case sidechainesplora.KindTransfer:
		return pb.Kind_KIND_TRANSFER
	default:
		return pb.Kind_KIND_UNSPECIFIED
	}
}
