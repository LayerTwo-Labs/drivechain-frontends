// Package fork is the single source of truth for eCash fork state. One engine
// computes everything fork-related — the fork/claim heights (fixed per network,
// or a recurring 144-block "daily fork" simulation on signet), the pre-fork
// claimable scan across wallets, and the claim-before-countdown gate. Every
// consumer (the GetForkStatus RPC, the countdown, the claim card, the sweep's
// input list) reads the one ForkState this produces; nothing re-derives it.
package fork

import (
	"context"
	"fmt"
	"math"
	"sync"
	"time"
)

// signetForkInterval makes signet "fork" every 144 blocks (~1 day at 10
// min/block) so the whole fork UI + sweep can be exercised daily on a loop.
const signetForkInterval = 144

// ForkHeightFor is the fixed fork height for non-simulated networks — the single
// source of truth for per-network fork heights.
func ForkHeightFor(network string) int {
	switch network {
	case "regtest":
		return 400
	default: // mainnet, forknet, testnet, ...
		return 100_000
	}
}

// Tip is the minimal mainchain view the engine needs. Kept local to this
// package so the engine imports nothing app-specific (no import cycle, easy to
// fake in tests).
type Tip struct {
	// Network is the drivechain network, not Core's chain: eCash and forknet
	// are both chain=main, so Core cannot tell them apart.
	Network string
	Blocks  int
	Headers int
	// ForkHeight is the height published for this network, 0 when none is.
	// The catalog carries it so a new eCash needs no release.
	ForkHeight int
	// DisplayName names the fork that is coming ("ECash 4"), so a rehearsal is
	// never mistaken for the real eCash fork.
	DisplayName string
}

// TipSource yields the current mainchain tip. The orchestrator satisfies this.
type TipSource interface {
	ForkTip(ctx context.Context) (Tip, error)
}

// WalletMeta identifies a spendable L1 wallet to scan for claimable coins.
type WalletMeta struct {
	ID   string
	Name string
}

// Utxo is one unspent output at an absolute confirmation height (0 if
// unconfirmed). The scanner adapter normalizes each wallet backend to this, so
// the engine only ever compares heights.
type Utxo struct {
	Outpoint  string // "txid:vout"
	Address   string
	Label     string
	Sats      uint64
	Height    int
	Spendable bool
}

// WalletScanner enumerates spendable wallets and their UTXOs, server-side. The
// orchestrator adapts wallet.Service + wallet.WalletEngine to this. tipHeight is
// supplied so adapters that only know confirmations can derive an absolute
// height.
type WalletScanner interface {
	Wallets() []WalletMeta
	Unspent(ctx context.Context, walletID string, tipHeight int) ([]Utxo, error)
}

// ClaimUTXO carries everything the frontend sweep needs as a requiredInput.
type ClaimUTXO struct {
	Outpoint string
	Address  string
	Label    string
	Sats     uint64
	Height   int
}

// WalletClaim is one wallet's claimable pre-fork coins.
type WalletClaim struct {
	WalletID      string
	WalletName    string
	ClaimableSats uint64
	UTXOs         []ClaimUTXO
}

// ForkState is the canonical fork snapshot every consumer reads.
type ForkState struct {
	Simulated       bool
	ForkHeight      int // next fork / countdown target
	ClaimBoundary   int // coins confirmed at/before this height are claimable
	CurrentHeight   int
	CurrentHeaders  int
	HasFundsToClaim bool
	ShowCountdown   bool
	Claims          []WalletClaim
	// NetworkName names the fork being counted down to ("ECash 4"), so a
	// rehearsal never reads as the real eCash fork.
	NetworkName string
}

// Engine computes ForkState. Construct with NewEngine; call State.
type Engine struct {
	tip     TipSource
	wallets WalletScanner // may be nil before Core RPC is up — claims skipped
	ttl     time.Duration

	mu       sync.Mutex
	cached   *ForkState
	cachedAt time.Time
}

// NewEngine wires the tip + wallet sources. ttl caches the (per-wallet UTXO
// scan) result so a fast poll cadence doesn't re-scan every tick; ttl<=0
// disables caching (used by tests).
func NewEngine(tip TipSource, wallets WalletScanner, ttl time.Duration) *Engine {
	return &Engine{tip: tip, wallets: wallets, ttl: ttl}
}

// State returns the current canonical fork state.
func (e *Engine) State(ctx context.Context) (*ForkState, error) {
	e.mu.Lock()
	if e.ttl > 0 && e.cached != nil && time.Since(e.cachedAt) < e.ttl {
		st := e.cached
		e.mu.Unlock()
		return st, nil
	}
	e.mu.Unlock()

	st, err := e.compute(ctx)
	if err != nil {
		return nil, err
	}

	e.mu.Lock()
	e.cached, e.cachedAt = st, time.Now()
	e.mu.Unlock()
	return st, nil
}

func (e *Engine) compute(ctx context.Context) (*ForkState, error) {
	tip, err := e.tip.ForkTip(ctx)
	if err != nil {
		return nil, err
	}

	simulated, forkHeight, claimBoundary := heightsFor(tip)

	st := &ForkState{
		Simulated:      simulated,
		ForkHeight:     forkHeight,
		NetworkName:    tip.DisplayName,
		ClaimBoundary:  claimBoundary,
		CurrentHeight:  tip.Blocks,
		CurrentHeaders: tip.Headers,
	}

	// The chain passes the boundary, not the local node: a node in initial
	// block download sits far behind the headers it already knows.
	if tip.Headers >= claimBoundary {
		st.Claims = e.scan(ctx, claimBoundary, tip.Blocks)
	}
	for _, c := range st.Claims {
		if c.ClaimableSats > 0 {
			st.HasFundsToClaim = true
			break
		}
	}

	// Claim-before-countdown: never show the next-fork timer while coins are
	// still unclaimed. This gate lives here and only here.
	st.ShowCountdown = !st.HasFundsToClaim && (simulated || tip.Headers < forkHeight)
	return st, nil
}

// heightsFor returns (simulated, forkHeight, claimBoundary). Signet simulates a
// recurring fork every 144 blocks: claimBoundary = last boundary (by confirmed
// tip), forkHeight = next boundary (by header tip).
func heightsFor(tip Tip) (bool, int, int) {
	if tip.Network == "signet" {
		claimBoundary := (tip.Blocks / signetForkInterval) * signetForkInterval
		forkHeight := (tip.Headers/signetForkInterval)*signetForkInterval + signetForkInterval
		return true, forkHeight, claimBoundary
	}
	h := tip.ForkHeight
	if h <= 0 {
		h = ForkHeightFor(tip.Network)
	}
	return false, h, h
}

// scan collects each wallet's claimable pre-fork UTXOs. A wallet whose Core
// wallet isn't loaded/unlocked errors and is skipped — never fatal.
func (e *Engine) scan(ctx context.Context, claimBoundary, tipHeight int) []WalletClaim {
	if e.wallets == nil {
		return nil
	}
	var claims []WalletClaim
	for _, w := range e.wallets.Wallets() {
		utxos, err := e.wallets.Unspent(ctx, w.ID, tipHeight)
		if err != nil {
			continue
		}
		var (
			sum   uint64
			picks []ClaimUTXO
		)
		for _, u := range utxos {
			if !u.Spendable || u.Height <= 0 {
				continue
			}
			if u.Height > claimBoundary {
				continue // confirmed after the fork — not claimable
			}
			sum += u.Sats
			picks = append(picks, ClaimUTXO{
				Outpoint: u.Outpoint,
				Address:  u.Address,
				Label:    u.Label,
				Sats:     u.Sats,
				Height:   u.Height,
			})
		}
		if len(picks) > 0 {
			claims = append(claims, WalletClaim{
				WalletID:      w.ID,
				WalletName:    w.Name,
				ClaimableSats: sum,
				UTXOs:         picks,
			})
		}
	}
	return claims
}

// BTCToSats converts a bitcoind BTC amount to satoshis. Exported so the
// orchestrator's scanner adapter shares the one rounding rule.
func BTCToSats(btc float64) uint64 {
	if btc <= 0 {
		return 0
	}
	return uint64(math.Round(btc * 1e8))
}

// Outpoint formats a txid:vout the way the frontend sweep expects.
func Outpoint(txid string, vout int) string {
	return fmt.Sprintf("%s:%d", txid, vout)
}
