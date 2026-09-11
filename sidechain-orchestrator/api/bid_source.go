package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// Replacement is what it takes to replace one of our own bids: the coins to
// respend, every bid that goes with it, and the fee it has to beat.
type Replacement struct {
	// Inputs are the coins to respend, which a block already carries.
	Inputs []*wpb.UnspentOutput
	// Roots are the bids of the chain that hold those coins.
	Roots []string
	// Evicted names every bid the replacement removes.
	Evicted []string
	// EvictedFeeSats totals what those bids pay.
	EvictedFeeSats int64
	// FloorSats is the least a replacement can pay and still evict them.
	FloorSats int64
}

// BidSource answers what the mainchain knows about BMM bids.
type BidSource interface {
	// Rivals reports the bids for one slot, built on prevMainHash, highest
	// first. It reports our own bids alongside those of other bidders.
	Rivals(ctx context.Context, slot int, prevMainHash string) ([]*bmmpb.Bid, error)
	// Replacement prices a replacement of one of our own bids.
	Replacement(ctx context.Context, walletID, txid string) (Replacement, error)
	// PendingTxids names our own transactions no block carries yet, over every
	// wallet in walletIDs. The first id names the current funding wallet.
	PendingTxids(ctx context.Context, walletIDs []string) (map[string]bool, error)
	// Mined reports whether a block carries txid, one that PendingTxids named.
	Mined(ctx context.Context, txid string) (bool, error)
	// PaidSats reports what one of our own bids paid. It reports false when
	// no source names the transaction.
	PaidSats(ctx context.Context, walletID, txid string) (int64, bool, error)
	// FrozenCoins names the candidates a live bid of ours holds, keyed
	// txid:vout: the change it made, and the coins it spends.
	FrozenCoins(ctx context.Context, walletID string, candidates []wallet.Outpoint) (map[string]bool, error)
}

// ownBids reads our own bid. Bitcoin Core answers it for a full install, and
// the wallet answers it for a light one.
type ownBids interface {
	spends(ctx context.Context, walletID, txid string) ([]*wpb.UnspentOutput, error)
	// pending says whether txid is an unconfirmed BMM request.
	pending(ctx context.Context, walletID, txid string) bool
	// feeSats reports what a replacement of txid has to beat, false for one no
	// longer worth beating.
	feeSats(ctx context.Context, walletID, txid string) (int64, bool, error)
	// paidSats reports what txid pays a miner, false for one no source names.
	paidSats(ctx context.Context, walletID, txid string) (int64, bool, error)
	// evicted names every bid a replacement of the walked chain removes.
	evicted(ctx context.Context, roots, chain []string) []string
	// PendingTxids names our own transactions no block carries yet, over every
	// wallet in walletIDs.
	PendingTxids(ctx context.Context, walletIDs []string) (map[string]bool, error)
	// mined reports whether a block carries txid, one that PendingTxids named.
	mined(ctx context.Context, txid string) (bool, error)
	// frozenCoins names the candidates a live bid of ours holds.
	frozenCoins(ctx context.Context, walletID string, candidates []wallet.Outpoint) (map[string]bool, error)
}

// bids builds the source for this install. It is the only place that reads the
// node mode: every caller below it works the same way in both.
func (h *BMMHandler) bids() BidSource {
	if h.ReadsMempool() {
		return bidSource{h: h, own: coreBids{h: h}}
	}
	return bidSource{h: h, own: walletBids{h: h}}
}

type bidSource struct {
	h   *BMMHandler
	own ownBids
}

// Rivals reads the enforcer, which holds every M8 the mainchain mempool
// carries. A light install reads a remote enforcer and a full one reads its
// own, so the bids arrive the same way in both.
func (s bidSource) Rivals(ctx context.Context, slot int, prevMainHash string) ([]*bmmpb.Bid, error) {
	return s.h.enforcerBids(ctx, slot, prevMainHash)
}

func (s bidSource) PendingTxids(ctx context.Context, walletIDs []string) (map[string]bool, error) {
	return s.own.PendingTxids(ctx, walletIDs)
}

func (s bidSource) Mined(ctx context.Context, txid string) (bool, error) {
	return s.own.mined(ctx, txid)
}

func (s bidSource) PaidSats(ctx context.Context, walletID, txid string) (int64, bool, error) {
	return s.own.paidSats(ctx, walletID, txid)
}

func (s bidSource) FrozenCoins(
	ctx context.Context, walletID string, candidates []wallet.Outpoint,
) (map[string]bool, error) {
	return s.own.frozenCoins(ctx, walletID, candidates)
}

// maxBidChain bounds the walk down a chain of stranded bids. A wallet that
// stacks more than this names a loop, not a chain.
const maxBidChain = 50

// Replacement walks down from txid to the coins a block already carries.
//
// A new bid takes the change of the bid before it, so one bid can carry a whole
// chain of bids under it. Respending the top one leaves the rest, and every one
// of them holds the chain unminable. Spending the coins under the chain evicts
// all of them at one time, so the replacement pays more than all of them
// together.
func (s bidSource) Replacement(ctx context.Context, walletID, txid string) (Replacement, error) {
	var (
		inputs    []*wpb.UnspentOutput
		roots     []string
		chain     []string
		seen      = make(map[string]bool)
		rootSeen  = make(map[string]bool)
		chainSeen = make(map[string]bool)
	)

	var walk func(txid string, depth int) error
	walk = func(txid string, depth int) error {
		if depth > maxBidChain {
			return connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf(
				"bid %s sits over more than %d unconfirmed bids", txid, maxBidChain))
		}
		if !chainSeen[txid] {
			chainSeen[txid] = true
			chain = append(chain, txid)
		}
		spends, err := s.own.spends(ctx, walletID, txid)
		if err != nil {
			return err
		}
		for _, in := range spends {
			key := fmt.Sprintf("%s:%d", in.Txid, in.Vout)
			if seen[key] {
				continue
			}
			seen[key] = true
			if s.own.pending(ctx, walletID, in.Txid) {
				if err := walk(in.Txid, depth+1); err != nil {
					return err
				}
				continue
			}
			inputs = append(inputs, in)
			// This bid holds a coin under the chain, so every bid above it
			// goes with it.
			if !rootSeen[txid] {
				rootSeen[txid] = true
				roots = append(roots, txid)
			}
		}
		return nil
	}

	if err := walk(txid, 0); err != nil {
		return Replacement{}, err
	}
	if len(inputs) == 0 {
		return Replacement{}, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("bid %s has no inputs to reuse", txid))
	}

	evicted := s.own.evicted(ctx, roots, chain)
	evictedSats, err := s.evictedFeeSats(ctx, walletID, evicted)
	if err != nil {
		return Replacement{}, err
	}
	return Replacement{
		Inputs:         inputs,
		Roots:          roots,
		Evicted:        evicted,
		EvictedFeeSats: evictedSats,
		FloorSats:      floorSats(evictedSats),
	}, nil
}

// evictedFeeSats totals what the evicted bids pay.
func (s bidSource) evictedFeeSats(ctx context.Context, walletID string, evicted []string) (int64, error) {
	var total int64
	for _, txid := range evicted {
		fee, ok, err := s.own.feeSats(ctx, walletID, txid)
		if err != nil {
			return 0, err
		}
		if ok {
			total += fee
		}
	}
	// A node that deprioritised the chain reports a fee far below zero, and a
	// replacement then beats it at any price. Core compares the same modified
	// fees, so this is the number its own rule reads.
	return max(total, 0), nil
}

// floorSats is the least a replacement can pay and still evict a chain that
// pays evictedSats. A bid the mempool no longer holds needs no floor at all.
func floorSats(evictedSats int64) int64 {
	if evictedSats == 0 {
		return 0
	}
	return evictedSats + replacementBumpSats
}
