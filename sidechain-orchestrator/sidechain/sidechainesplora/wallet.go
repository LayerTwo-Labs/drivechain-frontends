package sidechainesplora

import (
	"context"
	"fmt"
	"sort"
)

// Wallet reads a set of addresses through the index. It runs no sidechain node.
type Wallet struct {
	client *Client
}

// NewWallet wraps a client.
func NewWallet(client *Client) *Wallet { return &Wallet{client: client} }

// Client is the index this wallet reads through.
func (w *Wallet) Client() *Client { return w.client }

// TipHeight is the height of the last block the index read.
func (w *Wallet) TipHeight(ctx context.Context) (uint32, error) {
	return w.client.TipHeight(ctx)
}

// Balance sums what a set of addresses holds.
func (w *Wallet) Balance(ctx context.Context, addresses []string) (int64, error) {
	var total int64
	for _, address := range addresses {
		stats, err := w.client.AddressStats(ctx, address)
		if err != nil {
			return 0, fmt.Errorf("balance for %s: %w", address, err)
		}
		total += stats.Balance()
	}
	return total, nil
}

// UTXOs lists every unspent output of a set of addresses, newest first.
func (w *Wallet) UTXOs(ctx context.Context, addresses []string) ([]UTXO, error) {
	var out []UTXO
	for _, address := range addresses {
		utxos, err := w.client.AddressUTXOs(ctx, address)
		if err != nil {
			return nil, fmt.Errorf("utxos for %s: %w", address, err)
		}
		out = append(out, utxos...)
	}
	sort.SliceStable(out, func(i, j int) bool {
		return out[i].Status.BlockHeight > out[j].Status.BlockHeight
	})
	return out, nil
}

// Entry is one row of a wallet history.
type Entry struct {
	Txid string
	// ValueSats is what the wallet gained, or lost when negative.
	ValueSats   int64
	FeeSats     int64
	BlockHeight uint32
	BlockTime   int64
	Confirmed   bool
	// IsDeposit marks a mainchain deposit. Its Txid is a mainchain txid, so it
	// names no sidechain transaction.
	IsDeposit bool
	// Vout names the first output this wallet owns. A row the wallet only
	// spends from carries zero, because it owns no output there.
	Vout uint32
}

// maxHistoryPages bounds one address walk, so a very long history answers
// rather than runs forever.
const maxHistoryPages = 200

// History lists the transactions that touched a set of addresses, newest first.
// One transaction that pays two of the addresses appears one time, with the two
// amounts added.
//
// A mainchain deposit has no sidechain transaction, so it comes from the
// deposits route instead.
func (w *Wallet) History(ctx context.Context, addresses []string) ([]Entry, error) {
	byID := make(map[string]*Entry)
	var order []string

	// ownsOutput marks the entries that already name an output of this wallet.
	// A transaction first seen through an address it spends from owns none, and
	// a later address may still name the real one.
	ownsOutput := make(map[string]bool)

	add := func(id string, entry Entry, value int64, owned bool) {
		existing, seen := byID[id]
		if !seen {
			entry.ValueSats = 0
			byID[id] = &entry
			order = append(order, id)
			existing = byID[id]
		}
		if owned && !ownsOutput[id] {
			existing.Vout = entry.Vout
			ownsOutput[id] = true
		}
		existing.ValueSats += value
	}

	for _, address := range addresses {
		txs, err := w.AddressHistory(ctx, address)
		if err != nil {
			return nil, err
		}
		for _, tx := range txs {
			vout, owned := tx.FirstOutputFor(address)
			add(tx.Txid, Entry{
				Txid:        tx.Txid,
				FeeSats:     tx.Fee,
				BlockHeight: tx.Status.BlockHeight,
				BlockTime:   tx.Status.BlockTime,
				Confirmed:   tx.Status.Confirmed,
				Vout:        vout,
			}, tx.NetValueFor(address), owned)
		}

		deposits, err := w.client.AddressDeposits(ctx, address)
		if err != nil {
			return nil, fmt.Errorf("deposits for %s: %w", address, err)
		}
		for _, deposit := range deposits {
			add(deposit.Txid, Entry{
				Txid:        deposit.Txid,
				BlockHeight: deposit.Status.BlockHeight,
				BlockTime:   deposit.Status.BlockTime,
				Confirmed:   deposit.Status.Confirmed,
				IsDeposit:   true,
				Vout:        deposit.Vout,
			}, deposit.Value, true)
		}
	}

	out := make([]Entry, 0, len(order))
	for _, id := range order {
		out = append(out, *byID[id])
	}
	sort.SliceStable(out, func(i, j int) bool {
		return out[i].BlockHeight > out[j].BlockHeight
	})
	return out, nil
}

// AddressHistory walks every page of one address history, newest first.
//
// Only a mined transaction paginates. The chain route refuses a mempool txid,
// so the cursor is the oldest mined transaction of a page, never the last row.
func (w *Wallet) AddressHistory(ctx context.Context, address string) ([]Tx, error) {
	var out []Tx
	lastSeen := ""
	for range maxHistoryPages {
		txs, err := w.client.AddressTxs(ctx, address, lastSeen)
		if err != nil {
			return nil, fmt.Errorf("history for %s: %w", address, err)
		}
		if len(txs) == 0 {
			return out, nil
		}
		out = append(out, txs...)

		cursor := ""
		for _, tx := range txs {
			if tx.Status.Confirmed {
				cursor = tx.Txid
			}
		}
		if cursor == "" || cursor == lastSeen {
			return out, nil
		}
		lastSeen = cursor
	}
	return out, nil
}
