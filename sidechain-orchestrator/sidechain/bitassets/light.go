package bitassets

import (
	"context"
	"encoding/json"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

// NewLightHandler builds a handler that also works with no node. Light mode
// reads the wallet from a hosted index, and derives the addresses from the
// seed, because the node that would otherwise hold them does not run.
func NewLightHandler(
	proxy *sidechain.JSONRPCProxy, mode lightwallet.ModeFunc, seed lightwallet.Seed,
) *Handler {
	return &Handler{proxy: proxy, light: lightwallet.NewWallet(mode, lightwallet.Chain{
		Seed:     seed,
		Derive:   deriveAddress,
		ValueKey: lightwallet.ValueKeyBitcoinSats,
	})}
}

// ReadsIndex reports whether this chain reads a remote index right now.
func (h *Handler) ReadsIndex() bool { return h.light.ReadsIndex() }

// WalletBalance reads the balance whatever mode runs. Another service answers
// the same number from here, so both modes agree.
func (h *Handler) WalletBalance(ctx context.Context) (total, available int64, err error) {
	if backend := h.light.Backend(); backend != nil {
		return backend.Balance(ctx)
	}
	// The node names this call bitcoin_balance, not balance.
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := h.proxy.Client.Call(ctx, "bitcoin_balance", nil, &result); err != nil {
		return 0, 0, err
	}
	return result.TotalSats, result.AvailableSats, nil
}

func (h *Handler) walletAddress(ctx context.Context) (string, error) {
	if backend := h.light.Backend(); backend != nil {
		return backend.NewAddress(ctx)
	}
	return h.proxy.GetNewAddress(ctx)
}

func (h *Handler) walletAddresses(ctx context.Context) ([]string, error) {
	if backend := h.light.Backend(); backend != nil {
		return backend.Addresses(ctx)
	}
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return addresses, nil
}

func (h *Handler) walletUTXOs(ctx context.Context) (json.RawMessage, error) {
	if backend := h.light.Backend(); backend != nil {
		return backend.UTXOs(ctx)
	}
	return h.proxy.GetWalletUtxos(ctx)
}
