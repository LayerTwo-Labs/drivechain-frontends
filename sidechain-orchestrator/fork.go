package orchestrator

import (
	"context"
	"time"

	"connectrpc.com/connect"

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

// ForkTip implements fork.TipSource off the cached getblockchaininfo.
func (o *Orchestrator) ForkTip(ctx context.Context) (fork.Tip, error) {
	info, err := o.GetMainchainBlockchainInfo(ctx)
	if err != nil {
		return fork.Tip{}, err
	}
	return fork.Tip{Chain: info.Chain, Blocks: info.Blocks, Headers: info.Headers}, nil
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
	var out []fork.WalletMeta
	for _, w := range s.o.WalletSvc.GetAllWallets() {
		// Watch-only has no key, so it can't be swept. Core and enforcer
		// wallets both hold spendable L1 BTC, but only Core claims can be
		// replay-protected (the custom-serialized tx path is Core-only).
		if w.IsWatchOnly() {
			continue
		}
		out = append(out, fork.WalletMeta{
			ID:                w.ID,
			Name:              w.Name,
			ReplayProtectable: w.WalletType != "enforcer",
		})
	}
	return out
}

func (s *forkWalletScanner) Unspent(ctx context.Context, walletID string, tipHeight int) ([]fork.Utxo, error) {
	if s.walletType(walletID) == "enforcer" {
		return s.enforcerUnspent(ctx)
	}
	return s.coreUnspent(ctx, walletID, tipHeight)
}

func (s *forkWalletScanner) walletType(walletID string) string {
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
	out := make([]fork.Utxo, 0, len(coreUTXOs))
	for _, u := range coreUTXOs {
		height := 0
		if u.Confirmations > 0 {
			height = tipHeight - u.Confirmations + 1
		}
		out = append(out, fork.Utxo{
			Outpoint:  fork.Outpoint(u.TxID, u.Vout),
			Address:   u.Address,
			Label:     u.Label,
			Sats:      fork.BTCToSats(u.Amount),
			Height:    height,
			Spendable: u.Spendable,
		})
	}
	return out, nil
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
	out := make([]fork.Utxo, 0, len(resp.Msg.Outputs))
	for _, u := range resp.Msg.Outputs {
		height := 0
		if u.IsConfirmed {
			height = int(u.ConfirmedAtBlock)
		}
		out = append(out, fork.Utxo{
			Outpoint:  fork.Outpoint(u.Txid.GetHex().GetValue(), int(u.Vout)),
			Address:   u.Address.GetValue(),
			Sats:      u.ValueSats,
			Height:    height,
			Spendable: true,
		})
	}
	return out, nil
}
