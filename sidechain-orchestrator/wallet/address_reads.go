package wallet

import (
	"context"
	"fmt"

	"github.com/btcsuite/btcd/btcutil"
)

// AddressUnspent reports the UTXOs of an address the wallet does not own —
// a cheque address, whose coins have been given away.
func (p *ElectrumBackend) AddressUnspent(ctx context.Context, address string) ([]UTXO, int, error) {
	// An address from another network would silently return nothing, so reject
	// it against the params the electrum server is being asked about.
	if _, err := btcutil.DecodeAddress(address, p.params()); err != nil {
		return nil, 0, fmt.Errorf("address %s is not valid on this network: %w", address, err)
	}

	utxos, err := p.client.AddressUTXOs(ctx, address)
	if err != nil {
		return nil, 0, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, 0, err
	}

	out := make([]UTXO, 0, len(utxos))
	for _, u := range utxos {
		out = append(out, UTXO{
			TxID:          u.TxID,
			Vout:          u.Vout,
			Address:       address,
			Amount:        float64(u.Value) / 1e8,
			Confirmations: confsFor(u.Status, tip),
			Solvable:      true,
			ReceivedAt:    u.Status.BlockTime,
		})
	}
	return out, tip, nil
}

// BroadcastRaw sends a signed transaction over the electrum chain source,
// regardless of which backend the active wallet uses.
func (p *ElectrumBackend) BroadcastRaw(ctx context.Context, txHex string) (string, error) {
	return p.client.Broadcast(ctx, txHex)
}

// AddressUnspent routes to the electrum backend: a cheque's funding is chain
// data about an address, not wallet state.
func (e *WalletEngine) AddressUnspent(ctx context.Context, address string) ([]UTXO, int, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return nil, 0, err
	}
	return eb.AddressUnspent(ctx, address)
}

// BroadcastRaw sends a transaction over the electrum chain source.
func (e *WalletEngine) BroadcastRaw(ctx context.Context, txHex string) (string, error) {
	eb, err := e.electrumBackend()
	if err != nil {
		return "", err
	}
	return eb.BroadcastRaw(ctx, txHex)
}
