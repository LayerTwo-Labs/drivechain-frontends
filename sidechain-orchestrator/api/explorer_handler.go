package api

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"strings"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// blockListSize is how many headers the overview carries.
const blockListSize = 6

// activityListSize is how many rows the overview carries.
const activityListSize = 12

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
	if h.orch.NodeMode() == orchestrator.NodeModeLight {
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
	if out.GetTreasury() == nil {
		out.Treasury = h.enforcerTreasury(ctx, src.slot)
	}
	h.resolveMainchainHeights(ctx, out.GetBlocks())
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

	// The template is what the node would mine next, so its body is the
	// unconfirmed set.
	if template, err := src.node.GetBlockTemplate(ctx); err == nil && template != nil {
		out.Mempool.FeesSats = template.FeesSats
		var body nodeHeaderJSON
		if err := json.Unmarshal(template.Block, &body); err == nil {
			out.Mempool.TxCount = uint32(len(body.transactions()))
		}
	}
	if raw, err := src.node.GetPendingWithdrawalBundle(ctx); err == nil {
		out.PendingBundle = parseBundle(raw)
	}
	return out, nil
}

// enforcerTreasury reads what the mainchain escrow holds for one slot. A node
// mode install reads its own enforcer. An install with none answers nil, and
// the page then shows no treasury rather than an empty one.
func (h *ExplorerHandler) enforcerTreasury(ctx context.Context, slot uint32) *pb.Treasury {
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return nil
	}
	chains, err := validator.GetSidechains(ctx, connect.NewRequest(&enforcerpb.GetSidechainsRequest{}))
	if err != nil {
		return nil
	}
	var out *pb.Treasury
	for _, c := range chains.Msg.GetSidechains() {
		if c.GetSidechainNumber().GetValue() != slot {
			continue
		}
		out = &pb.Treasury{Slot: slot, ActivationHeight: c.GetActivationHeight().GetValue()}
	}
	if out == nil {
		return nil
	}

	ctip, err := validator.GetCtip(ctx, connect.NewRequest(&enforcerpb.GetCtipRequest{
		SidechainNumber: wrapperspb.UInt32(slot),
	}))
	if err != nil {
		return out
	}
	if c := ctip.Msg.GetCtip(); c != nil {
		out.BalanceSats = int64(c.GetValue())
		out.CtipTxid = c.GetTxid().GetHex().GetValue()
		out.CtipVout = c.GetVout()
	}
	return out
}

// resolveMainchainHeights names the mainchain block each header points at. A
// hash alone tells a reader nothing, and only the enforcer holds the height.
func (h *ExplorerHandler) resolveMainchainHeights(ctx context.Context, blocks []*pb.Block) {
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return
	}
	for _, block := range blocks {
		if block.GetMainchainHeight() != 0 || block.GetMainchainHash() == "" {
			continue
		}
		resp, err := validator.GetBlockHeaderInfo(ctx, connect.NewRequest(
			&enforcerpb.GetBlockHeaderInfoRequest{
				BlockHash: &commonv1.ReverseHex{
					Hex: wrapperspb.String(block.GetMainchainHash()),
				},
			}))
		if err != nil {
			return
		}
		for _, info := range resp.Msg.GetHeaderInfos() {
			block.MainchainHeight = info.GetHeight()
			break
		}
	}
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

	height := req.Msg.GetHeight()
	if hash == "" {
		hash, err = nodeHashAtHeight(ctx, src, height)
		if err != nil {
			return nil, err
		}
	} else {
		// A node block names no height, so a block opened by hash carries
		// none. Walking from the tip finds it.
		height, err = nodeHeightOfHash(ctx, src, hash)
		if err != nil {
			return nil, err
		}
	}
	block, activity, err := nodeBlock(ctx, src, hash, height)
	if err != nil {
		return nil, err
	}
	h.resolveMainchainHeights(ctx, []*pb.Block{block})
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
		read := nodeTransaction
		if src.core {
			read = coreTransaction
		}
		out, err := read(ctx, src, txid)
		if err != nil {
			return nil, err
		}
		return connect.NewResponse(&pb.GetTransactionResponse{Transaction: out}), nil
	}
	tx, err := src.index.Tx(ctx, txid)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	return connect.NewResponse(&pb.GetTransactionResponse{Transaction: newTransaction(tx)}), nil
}

// nodeHeightOfHash walks down from the tip to the height of one hash.
func nodeHeightOfHash(ctx context.Context, src source, hash string) (uint32, error) {
	count, err := src.node.GetBlockCount(ctx)
	if err != nil {
		return 0, connect.NewError(connect.CodeUnavailable, err)
	}
	raw, err := src.node.CallRaw(ctx, "get_best_sidechain_block_hash", nil)
	if err != nil {
		return 0, connect.NewError(connect.CodeUnavailable, err)
	}
	var at string
	if err := json.Unmarshal(raw, &at); err != nil {
		return 0, connect.NewError(connect.CodeInternal,
			fmt.Errorf("read the tip hash: %w", err))
	}

	for height := count - 1; height >= 0; height-- {
		if at == hash {
			return uint32(height), nil
		}
		header, err := nodeHeader(ctx, src, at)
		if err != nil {
			return 0, err
		}
		prev := header.prevSideHash()
		if prev == nil {
			break
		}
		at = *prev
	}
	return 0, connect.NewError(connect.CodeNotFound,
		fmt.Errorf("no block on %s hashes to %s", src.name, hash))
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
	// No node holds an address index, so an address always reads the hosted
	// one, whether the app runs a full node or a light client.
	index := src.index
	if index == nil {
		index = h.addressIndex(src.name)
	}
	if index == nil {
		return nil, connect.NewError(connect.CodeUnimplemented,
			fmt.Errorf("%s has no index, and a node keeps no address history", src.name))
	}

	stats, err := index.AddressStats(ctx, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}
	// The first page already carries the unconfirmed rows, so a separate
	// mempool read would list every one of them twice.
	history, err := sidechainesplora.NewWallet(index).AddressHistory(ctx, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
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

	// A deposit creates a coin with no sidechain transaction, so the history
	// route never carries one. The address view marks deposits, so they come
	// from their own route.
	deposits, err := index.AddressDeposits(ctx, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err)
	}
	for _, deposit := range deposits {
		out.Transactions = append(out.Transactions, depositTransaction(address, deposit))
		out.TxCount++
	}
	sortNewestFirst(out.Transactions)
	return connect.NewResponse(out), nil
}

// sortNewestFirst orders an address history the way the view reads it: the
// unconfirmed rows first, then the newest block.
func sortNewestFirst(rows []*pb.Transaction) {
	sort.SliceStable(rows, func(i, j int) bool {
		a, b := rows[i], rows[j]
		if a.GetConfirmed() != b.GetConfirmed() {
			return !a.GetConfirmed()
		}
		return a.GetBlockHeight() > b.GetBlockHeight()
	})
}

// addressIndex resolves the hosted index for one chain, whatever mode the
// node runs in.
func (h *ExplorerHandler) addressIndex(chain string) *sidechainesplora.Client {
	url := config.SidechainEsploraURLForNetwork(chain, config.NetworkFromString(h.orch.CurrentNetwork()))
	if url == "" {
		return nil
	}
	return sidechainesplora.New(url)
}

// depositTransaction reads one mainchain deposit as a row the address view can
// show. Its txid is a mainchain txid, and it spends nothing on this chain.
func depositTransaction(address string, deposit sidechainesplora.UTXO) *pb.Transaction {
	return &pb.Transaction{
		Txid:        deposit.Txid,
		Kind:        pb.Kind_KIND_DEPOSIT,
		Confirmed:   deposit.Status.Confirmed,
		BlockHeight: deposit.Status.BlockHeight,
		BlockHash:   deposit.Status.BlockHash,
		BlockTime:   deposit.Status.BlockTime,
		Outputs: []*pb.Coin{{
			Address:      address,
			ValueSats:    deposit.Value,
			OutpointKind: sidechainesplora.KindDeposit,
			ContentType:  deposit.ContentType,
			Vout:         deposit.Vout,
		}},
	}
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
		prev := header.prevSideHash()
		if prev == nil {
			break
		}
		hash = *prev
	}
	return hash, nil
}

// nodeHeaderJSON is a block as a sidechain node returns it.
//
// Two layouts exist. Thunder and photon nest the header and the body; every
// other CUSF chain flattens both to the top level and adds a height. A field
// set in either place lands here.
type nodeHeaderJSON struct {
	Header struct {
		MerkleRoot   string  `json:"merkle_root"`
		PrevSideHash *string `json:"prev_side_hash"`
		PrevMainHash string  `json:"prev_main_hash"`
	} `json:"header"`
	Body struct {
		Transactions []nodeBodyTx `json:"transactions"`
	} `json:"body"`

	MerkleRoot   string       `json:"merkle_root"`
	PrevSideHash *string      `json:"prev_side_hash"`
	PrevMainHash string       `json:"prev_main_hash"`
	Transactions []nodeBodyTx `json:"transactions"`
	// Height is set on the flat layout only, and it saves a walk.
	Height *uint32 `json:"height"`
}

// merkleRoot, prevSideHash, prevMainHash and transactions read whichever
// layout the node sent.
func (b nodeHeaderJSON) merkleRoot() string {
	if b.Header.MerkleRoot != "" {
		return b.Header.MerkleRoot
	}
	return b.MerkleRoot
}

func (b nodeHeaderJSON) prevSideHash() *string {
	if b.Header.PrevSideHash != nil {
		return b.Header.PrevSideHash
	}
	return b.PrevSideHash
}

func (b nodeHeaderJSON) prevMainHash() string {
	if b.Header.PrevMainHash != "" {
		return b.Header.PrevMainHash
	}
	return b.PrevMainHash
}

// nodeBodyTx is one transaction in a block body. A node writes no fee, so
// only the outputs read back.
type nodeBodyTx struct {
	Outputs []struct {
		Address string          `json:"address"`
		Content json.RawMessage `json:"content"`
	} `json:"outputs"`
}

// paidOut is what one transaction paid out, in sats.
func (t nodeBodyTx) paidOut() int64 {
	var total int64
	for _, out := range t.Outputs {
		// A withdrawal reads first. A plain decode of {"Value":n} also
		// succeeds on a withdrawal, and it then reads zero.
		if w, ok := readWithdrawal(out.Content); ok {
			total += w.GetValueSats() + w.GetMainFeeSats()
			continue
		}
		total += contentValue(out.Content)
	}
	return total
}

func (b nodeHeaderJSON) transactions() []nodeBodyTx {
	if len(b.Header.MerkleRoot) > 0 || len(b.Body.Transactions) > 0 {
		return b.Body.Transactions
	}
	return b.Transactions
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
	if len(raw) == 0 || string(raw) == "null" {
		return nodeHeaderJSON{}, connect.NewError(connect.CodeNotFound,
			fmt.Errorf("no block on %s hashes to %s", src.name, hash))
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

	if block.Height != nil {
		height = *block.Height
	}
	out := &pb.Block{
		Height:        height,
		Hash:          hash,
		MerkleRoot:    block.merkleRoot(),
		MainchainHash: block.prevMainHash(),
		TxCount:       uint32(len(block.transactions())),
	}
	if prev := block.prevSideHash(); prev != nil {
		out.PrevHash = *prev
	}

	// get_block_index names the txids a body does not carry. A node without
	// it still answers the header, and the block then lists no transactions.
	rawIndex, err := src.node.CallRaw(ctx, "get_block_index", []string{hash})
	if err != nil {
		return blockValueFromBody(out, block), nil, nil
	}
	var index nodeBlockIndex
	if err := json.Unmarshal(rawIndex, &index); err != nil {
		return blockValueFromBody(out, block), nil, nil
	}

	// The block index names the txids in body order, so a transaction pairs
	// with the body entry at the same place.
	body := block.transactions()
	activity := make([]*pb.Activity, 0, len(index.Txs)+len(index.Deposits))
	for i, tx := range index.Txs {
		out.SizeBytes += int64(tx.Size)
		row := &pb.Activity{
			Kind:        pb.Kind_KIND_TRANSFER,
			Id:          tx.Txid,
			SizeBytes:   int64(tx.Size),
			Confirmed:   true,
			BlockHeight: height,
		}
		if i < len(body) {
			row.ValueSats = body[i].paidOut()
			out.ValueSats += row.ValueSats
		}
		activity = append(activity, row)
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

// blockValueFromBody sums what a block paid out. Only get_block_index names
// the txids, so a chain without it lists no transactions, and the value still
// reads back.
func blockValueFromBody(out *pb.Block, block nodeHeaderJSON) *pb.Block {
	for _, tx := range block.transactions() {
		out.ValueSats += tx.paidOut()
	}
	return out
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
		FeesKnown:     true,
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
