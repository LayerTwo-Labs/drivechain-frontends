package orchestrator

import (
	"context"
	"fmt"
	"time"

	"connectrpc.com/connect"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/fork"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
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

// SetForkEnforcerWallet attaches the enforcer wallet client to the fork scan so
// the enforcer wallet's pre-fork coins are claimable too. Called from main once
// the enforcer client exists (which is after InitForkEngine), so it's read
// dynamically by the scanner rather than captured at construction.
func (o *Orchestrator) SetForkEnforcerWallet(client enforcerrpc.WalletServiceClient) {
	o.forkEnforcerWallet = client
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

// chainSourceCacheTTL bounds how often the wallet chain source is asked for a
// height. It is a remote server, and a block arrives about every ten minutes.
const chainSourceCacheTTL = 30 * time.Second

// chainSourceFetchTimeout caps one height read against the chain source.
const chainSourceFetchTimeout = 5 * time.Second

// chainSourceHeightConnection reads the tip from the wallet chain source.
type chainSourceHeightConnection struct{ o *Orchestrator }

func (c *chainSourceHeightConnection) Fetch(ctx context.Context) (int, error) {
	src := c.o.chainTipSource()
	if src == nil {
		return 0, fmt.Errorf("no wallet chain source")
	}
	rpcCtx, cancel := context.WithTimeout(ctx, chainSourceFetchTimeout)
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
			ttl:   chainSourceCacheTTL,
		}
	}
	return o.chainSourceHeight
}

// activeWalletReadsChainSource reports whether the active wallet reads its
// chain data from the chain source. A wallet with a local node does not, so
// asking a remote server on its behalf is traffic nobody reads.
func (o *Orchestrator) activeWalletReadsChainSource() bool {
	return o.WalletSvc != nil && !o.WalletSvc.ActiveWalletNeedsBitcoinBackends()
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
	// Watch-only has no key, so it can't be swept. Core and enforcer
	// wallets both hold spendable L1 BTC, but only Core claims can be
	// replay-protected (the custom-serialized tx path is Core-only).
	return lo.FilterMap(s.o.WalletSvc.GetAllWallets(), func(w wallet.WalletData, _ int) (fork.WalletMeta, bool) {
		if w.IsWatchOnly() {
			return fork.WalletMeta{}, false
		}
		return fork.WalletMeta{
			ID:                w.ID,
			Name:              w.Name,
			ReplayProtectable: w.WalletType != wallet.WalletTypeEnforcer,
		}, true
	})
}

func (s *forkWalletScanner) Unspent(ctx context.Context, walletID string, tipHeight int) ([]fork.Utxo, error) {
	if s.walletType(walletID) == wallet.WalletTypeEnforcer {
		return s.enforcerUnspent(ctx)
	}
	return s.coreUnspent(ctx, walletID, tipHeight)
}

func (s *forkWalletScanner) walletType(walletID string) wallet.WalletType {
	for _, w := range s.o.WalletSvc.GetAllWallets() {
		if w.ID == walletID {
			return w.WalletType
		}
	}
	return ""
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
			Spendable: u.Spendable,
		}
	}), nil
}

// enforcerUnspent reads the enforcer wallet's UTXOs; the enforcer exposes the
// confirming block height directly (ConfirmedAtBlock).
func (s *forkWalletScanner) enforcerUnspent(ctx context.Context) ([]fork.Utxo, error) {
	if s.o.forkEnforcerWallet == nil {
		return nil, nil
	}
	resp, err := s.o.forkEnforcerWallet.ListUnspentOutputs(ctx, connect.NewRequest(&enforcerpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, err
	}
	return lo.Map(resp.Msg.Outputs, func(u *enforcerpb.ListUnspentOutputsResponse_Output, _ int) fork.Utxo {
		height := 0
		if u.IsConfirmed {
			height = int(u.ConfirmedAtBlock)
		}
		return fork.Utxo{
			Outpoint:  fork.Outpoint(u.Txid.GetHex().GetValue(), int(u.Vout)),
			Address:   u.Address.GetValue(),
			Sats:      u.ValueSats,
			Height:    height,
			Spendable: true,
		}
	}), nil
}
