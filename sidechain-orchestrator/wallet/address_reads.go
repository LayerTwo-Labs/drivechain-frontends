package wallet

import (
	"bytes"
	"context"
	"fmt"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// AddressUnspent reports the UTXOs of an address the wallet does not own —
// a cheque address, whose coins have been given away. Each value comes from the
// raw funding tx, which must hash to its txid and pay the address.
func (p *ElectrumBackend) AddressUnspent(ctx context.Context, address string) ([]UTXO, int, error) {
	// An address from another network would silently return nothing, so reject
	// it against the params the electrum server is being asked about.
	addr, err := btcutil.DecodeAddress(address, p.params())
	if err != nil {
		return nil, 0, fmt.Errorf("address %s is not valid on this network: %w", address, err)
	}
	pkScript, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return nil, 0, fmt.Errorf("create script for %s: %w", address, err)
	}

	utxos, err := p.client.AddressUTXOs(ctx, address)
	if err != nil {
		return nil, 0, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, 0, err
	}

	prevTxs := map[string]*wire.MsgTx{}
	out := make([]UTXO, 0, len(utxos))
	for _, u := range utxos {
		prevTx, ok := prevTxs[u.TxID]
		if !ok {
			rawHex, err := p.client.TxHex(ctx, u.TxID)
			if err != nil {
				return nil, 0, fmt.Errorf("get tx %s: %w", u.TxID, err)
			}
			if prevTx, err = decodeTxWithID(u.TxID, rawHex); err != nil {
				return nil, 0, err
			}
			prevTxs[u.TxID] = prevTx
		}
		value, err := checkedOutputValue(prevTx, u.TxID, u.Vout, pkScript)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, UTXO{
			TxID:          u.TxID,
			Vout:          u.Vout,
			Address:       address,
			Amount:        float64(value) / 1e8,
			Confirmations: confsFor(u.Status, tip),
			Solvable:      true,
			ReceivedAt:    u.Status.BlockTime,
		})
	}
	return out, tip, nil
}

// checkedOutputValue reads the value of output vout from the raw tx, and
// refuses an output that does not pay pkScript.
func checkedOutputValue(tx *wire.MsgTx, txid string, vout int, pkScript []byte) (int64, error) {
	if vout < 0 || vout >= len(tx.TxOut) {
		return 0, fmt.Errorf("tx %s has no output %d", txid, vout)
	}
	out := tx.TxOut[vout]
	if !bytes.Equal(out.PkScript, pkScript) {
		return 0, fmt.Errorf("output %s:%d does not pay the address", txid, vout)
	}
	return out.Value, nil
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
