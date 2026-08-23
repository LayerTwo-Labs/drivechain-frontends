package orchestrator

import (
	"context"
	"fmt"
	"time"

	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// InitForkEngine wires the fork engine once the wallet engine (Core RPC) is
// available — called from main after NewWalletEngine. The fork.Engine is the
// single source of truth for fork state; ForkState is a thin pass-through.
func (o *Orchestrator) InitForkEngine(we *wallet.WalletEngine) {
	o.forkEngine = fork.NewEngine(o, &forkWalletScanner{o: o, engine: we}, time.Second)
}

// SetWalletEngine hands the orchestrator the engine it resets on a network swap.
func (o *Orchestrator) SetWalletEngine(we *wallet.WalletEngine) {
	o.walletEngine = we
}

// ForkState returns the canonical fork snapshot, or a zero state if the fork
// engine isn't wired yet (no Core RPC).
func (o *Orchestrator) ForkState(ctx context.Context) (*fork.ForkState, error) {
	if o.forkEngine == nil {
		return &fork.ForkState{}, nil
	}
	return o.forkEngine.State(ctx)
}

// ChainTipSource reads the mainchain height from the wallet chain source.
// Both the esplora and the electrum client satisfy it.
type ChainTipSource interface {
	TipHeight(ctx context.Context) (int, error)
}

// SetChainTipSource hands the orchestrator the chain source it reads the
// height from when no local Core answers.
func (o *Orchestrator) SetChainTipSource(src ChainTipSource) {
	o.mu.Lock()
	o.chainTip = src
	o.mu.Unlock()
}

func (o *Orchestrator) chainTipSource() ChainTipSource {
	o.mu.RLock()
	defer o.mu.RUnlock()
	return o.chainTip
}

// chainSourceHeightConnection reads the tip from the wallet chain source.
type chainSourceHeightConnection struct{ o *Orchestrator }

func (c *chainSourceHeightConnection) Fetch(ctx context.Context) (int, error) {
	src := c.o.chainTipSource()
	if src == nil {
		return 0, fmt.Errorf("no wallet chain source")
	}
	rpcCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	return src.TipHeight(rpcCtx)
}

// chainSourceHeightCached returns the single cached connection every
// chain-source height read goes through, so one poll per TTL reaches the
// server no matter how many callers ask.
func (o *Orchestrator) chainSourceHeightCached() *CachedConnection[int] {
	o.syncConnMu.Lock()
	defer o.syncConnMu.Unlock()
	if o.chainSourceHeight == nil {
		o.chainSourceHeight = &CachedConnection[int]{
			inner: &chainSourceHeightConnection{o: o},
			ttl:   chainSyncCacheTTL,
		}
	}
	return o.chainSourceHeight
}

// ChainSourceHeight returns the tip the wallet chain source reports. An
// electrum wallet runs no local node, so this is the only height it has.
func (o *Orchestrator) ChainSourceHeight(ctx context.Context) (int, error) {
	return o.chainSourceHeightCached().Fetch(ctx)
}

// ForkTip implements fork.TipSource off the cached getblockchaininfo, and off
// the wallet chain source when no local Core runs.
func (o *Orchestrator) ForkTip(ctx context.Context) (fork.Tip, error) {
	network := config.NetworkFromString(o.Network)
	tip := fork.Tip{
		Network:     o.Network,
		ForkHeight:  config.PublishedForkHeight(network),
		DisplayName: config.PublishedDisplayName(network),
	}

	info, err := o.GetMainchainBlockchainInfo(ctx)
	if err == nil {
		tip.Blocks, tip.Headers = info.Blocks, info.Headers
		return tip, nil
	}
	if o.chainTipSource() == nil {
		return fork.Tip{}, err
	}
	// One height, so blocks and headers are the same: the server serves a
	// synced chain, and a claim scan reads that same server.
	height, chainErr := o.ChainSourceHeight(ctx)
	if chainErr != nil {
		return fork.Tip{}, err
	}
	tip.Blocks, tip.Headers = height, height
	return tip, nil
}

// forkWalletScanner adapts wallet.Service + wallet.WalletEngine + the enforcer
// wallet to fork.WalletScanner, normalizing each backend's UTXOs to an absolute
// confirmation height.
type forkWalletScanner struct {
	o      *Orchestrator
	engine *wallet.WalletEngine
}

func (s *forkWalletScanner) Wallets() []fork.WalletMeta {
	if s.o.WalletSvc == nil {
		return nil
	}
	return lo.FilterMap(s.o.WalletSvc.GetAllWallets(), func(w wallet.WalletData, _ int) (fork.WalletMeta, bool) {
		if !forkScannable(w) {
			return fork.WalletMeta{}, false
		}
		return fork.WalletMeta{
			ID:   w.ID,
			Name: w.Name,
		}, true
	})
}

// forkScannable reports whether a wallet's coins can reach a claim. A
// single-sig watch-only wallet holds no key, so its coins can never move. A
// multisig wallet always can: its split leaves as a PSBT, and the cosigners
// sign it on a device or elsewhere.
func forkScannable(w wallet.WalletData) bool {
	return !w.IsWatchOnly() || w.Multisig != nil
}

// forkSpendable reports whether a coin can still move. A watch-only scan of a
// multisig wallet marks every coin unspendable, but a psbt its cosigners sign
// moves it, so the claim keeps it.
func forkSpendable(spendable, multisig bool) bool {
	return spendable || multisig
}

func (s *forkWalletScanner) Unspent(ctx context.Context, walletID string, tipHeight int) ([]fork.Utxo, error) {
	return s.coreUnspent(ctx, walletID, tipHeight)
}

// coreUnspent reads a Core wallet's UTXOs; Core only reports confirmations, so
// height is derived tip - confirmations + 1.
func (s *forkWalletScanner) coreUnspent(ctx context.Context, walletID string, tipHeight int) ([]fork.Utxo, error) {
	if s.engine == nil {
		return nil, nil
	}
	coreUTXOs, err := s.engine.Backend().ListUnspent(ctx, walletID)
	if err != nil {
		return nil, err
	}
	multisig := false
	if s.o.WalletSvc != nil {
		if w := s.o.WalletSvc.GetWalletByID(walletID); w != nil {
			multisig = w.Multisig != nil
		}
	}
	return lo.Map(coreUTXOs, func(u wallet.UTXO, _ int) fork.Utxo {
		height := 0
		if u.Confirmations > 0 {
			height = tipHeight - u.Confirmations + 1
		}
		return fork.Utxo{
			Outpoint:  fork.Outpoint(u.TxID, u.Vout),
			Address:   u.Address,
			Label:     u.Label,
			Sats:      fork.BTCToSats(u.Amount),
			Height:    height,
			Spendable: forkSpendable(u.Spendable, multisig),
		}
	}), nil
}
