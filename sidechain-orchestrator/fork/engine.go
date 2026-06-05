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
func ForkHeightFor(chain string) int {
	switch chain {
	case "regtest":
		return 400
	default: // main, signet (non-sim path is unused for signet), testnet, ...
		return 100_000
	}
}

// Tip is the minimal mainchain view the engine needs. Kept local to this
// package so the engine imports nothing app-specific (no import cycle, easy to
// fake in tests).
type Tip struct {
	Chain   string
	Blocks  int
	Headers int
}

// TipSource yields the current mainchain tip. The orchestrator satisfies this.
type TipSource interface {
	ForkTip(ctx context.Context) (Tip, error)
}

// WalletMeta identifies a spendable L1 wallet to scan for claimable coins.
// ReplayProtectable is false for wallets whose claim can't be replay-protected
// (the enforcer wallet) — those coins are detected but not safely sweepable.
type WalletMeta struct {
	ID                string
	Name              string
	ReplayProtectable bool
}

// Utxo is one unspent output at an absolute confirmation height (0 if
// unconfirmed). The scanner adapter normalizes each wallet backend to this —
// Core derives height from confirmations, the enforcer reads it directly — so
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
// orchestrator adapts wallet.Service + wallet.WalletEngine + the enforcer wallet
// to this. tipHeight is supplied so adapters that only know confirmations can
// derive an absolute height.
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
}

// WalletClaim is one wallet's claimable pre-fork coins.
type WalletClaim struct {
	WalletID          string
	WalletName        string
	ClaimableSats     uint64
	ReplayProtectable bool
	UTXOs             []ClaimUTXO
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
		ClaimBoundary:  claimBoundary,
		CurrentHeight:  tip.Blocks,
		CurrentHeaders: tip.Headers,
	}

	// The fork has "happened" for these coins only once the tip reaches the
	// claim boundary — guards against a fixed-height network showing claims
	// before the fork.
	if tip.Blocks >= claimBoundary {
		st.Claims = e.scan(ctx, claimBoundary, tip.Blocks)
	}
	// Only replay-protectable claims count as "funds to claim" — the enforcer
	// wallet is detected but can't be swept, so it must not keep the claim card
	// open (or the countdown suppressed) once everything claimable is gone.
	for _, c := range st.Claims {
		if c.ReplayProtectable && c.ClaimableSats > 0 {
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
	if tip.Chain == "signet" {
		claimBoundary := (tip.Blocks / signetForkInterval) * signetForkInterval
		forkHeight := (tip.Headers/signetForkInterval)*signetForkInterval + signetForkInterval
		return true, forkHeight, claimBoundary
	}
	h := ForkHeightFor(tip.Chain)
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
			})
		}
		if len(picks) > 0 {
			claims = append(claims, WalletClaim{
				WalletID:          w.ID,
				WalletName:        w.Name,
				ClaimableSats:     sum,
				ReplayProtectable: w.ReplayProtectable,
				UTXOs:             picks,
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
