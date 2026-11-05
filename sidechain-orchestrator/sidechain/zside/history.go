package zside

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"strconv"
	"strings"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
)

// walletOutput is one entry of get_wallet_utxos and get_wallet_utxos_unconfirmed.
type walletOutput struct {
	OutPoint outPoint `json:"outpoint"`
	Output   output   `json:"output"`
}

// walletSpentOutput is one entry of get_wallet_stxos and
// get_wallet_stxos_unconfirmed. The inpoint names what spent the coin.
type walletSpentOutput struct {
	Output  walletOutput `json:"output"`
	InPoint inPoint      `json:"inpoint"`
}

type outPoint struct {
	Regular *struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	} `json:"Regular,omitempty"`
	Coinbase *struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	} `json:"Coinbase,omitempty"`
	// Deposit is the mainchain outpoint as one "txid:vout" string.
	Deposit                *string `json:"Deposit,omitempty"`
	UnsuccessfulWithdrawal *struct {
		M6id string `json:"m6id"`
		Vout uint32 `json:"vout"`
	} `json:"UnsuccessfulWithdrawal,omitempty"`
}

// id is the transaction that made the coin. A deposit names its mainchain
// transaction, and a coin a failed bundle gave back names the bundle M6ID.
func (o outPoint) id() (string, uint32, error) {
	switch {
	case o.Regular != nil:
		return o.Regular.Txid, o.Regular.Vout, nil
	case o.Coinbase != nil:
		return o.Coinbase.Txid, o.Coinbase.Vout, nil
	case o.Deposit != nil:
		txid, voutText, found := strings.Cut(*o.Deposit, ":")
		if !found {
			return "", 0, fmt.Errorf("read the deposit outpoint %q: no vout", *o.Deposit)
		}
		vout, err := strconv.ParseUint(voutText, 10, 32)
		if err != nil {
			return "", 0, fmt.Errorf("read the deposit outpoint %q: %w", *o.Deposit, err)
		}
		return txid, uint32(vout), nil
	case o.UnsuccessfulWithdrawal != nil:
		return o.UnsuccessfulWithdrawal.M6id, o.UnsuccessfulWithdrawal.Vout, nil
	default:
		return "", 0, errors.New("read an outpoint of an unknown kind")
	}
}

// inPoint names what spent a coin. A withdrawal bundle spends with no
// transaction, so it names an M6ID.
type inPoint struct {
	Regular *struct {
		Txid string `json:"txid"`
	} `json:"Regular,omitempty"`
	Withdrawal *struct {
		M6id string `json:"m6id"`
	} `json:"Withdrawal,omitempty"`
}

type output struct {
	Content struct {
		Value      *int64    `json:"Value,omitempty"`
		Withdrawal *struct{} `json:"Withdrawal,omitempty"`
	} `json:"content"`
}

type coinKey struct {
	txid string
	vout uint32
}

type historyEntry struct {
	tx         *pb.WalletTransaction
	ownsOutput bool
}

// walletHistory folds the coins of the transparent wallet into one entry per
// transaction. The node records no height and no time for a coin.
type walletHistory struct {
	entries map[string]*historyEntry
	made    map[coinKey]bool
	spent   map[coinKey]bool
}

func (h *walletHistory) entry(txid string, confirmed bool) *historyEntry {
	entry, seen := h.entries[txid]
	if !seen {
		entry = &historyEntry{tx: &pb.WalletTransaction{Txid: txid}}
		h.entries[txid] = entry
	}
	entry.tx.Confirmed = entry.tx.Confirmed || confirmed
	return entry
}

// addCoin credits the transaction that made coin, one time for each coin.
func (h *walletHistory) addCoin(coin walletOutput, confirmed bool) error {
	// A withdrawal output is money on its way to the mainchain. The inputs and
	// the change of the withdrawal already record what left the wallet.
	if coin.Output.Content.Withdrawal != nil {
		return nil
	}
	if coin.Output.Content.Value == nil {
		return errors.New("read a wallet coin with no value")
	}
	txid, vout, err := coin.OutPoint.id()
	if err != nil {
		return err
	}
	key := coinKey{txid, vout}
	entry := h.entry(txid, confirmed)
	if h.made[key] {
		return nil
	}
	h.made[key] = true
	entry.tx.ValueSats += *coin.Output.Content.Value
	if !entry.ownsOutput || vout < entry.tx.Vout {
		entry.tx.Vout = vout
		entry.ownsOutput = true
	}
	return nil
}

// addSpend debits the transaction that spent coin, one time for each coin.
func (h *walletHistory) addSpend(spend walletSpentOutput, confirmed bool) error {
	// A bundle spends a withdrawal output. That money left one time already.
	if spend.Output.Output.Content.Withdrawal != nil || spend.InPoint.Regular == nil {
		return nil
	}
	if spend.Output.Output.Content.Value == nil {
		return errors.New("read a spent wallet coin with no value")
	}
	txid, vout, err := spend.Output.OutPoint.id()
	if err != nil {
		return err
	}
	key := coinKey{txid, vout}
	entry := h.entry(spend.InPoint.Regular.Txid, confirmed)
	if h.spent[key] {
		return nil
	}
	h.spent[key] = true
	entry.tx.ValueSats -= *spend.Output.Output.Content.Value
	return nil
}

// listWalletTransactions reads the transparent wallet history from the node.
// A coin in a confirmed list makes its transaction confirmed. The unconfirmed
// lists add what the mempool holds.
func (h *Handler) listWalletTransactions(ctx context.Context) ([]*pb.WalletTransaction, error) {
	var utxos, utxosUnconfirmed []walletOutput
	var stxos, stxosUnconfirmed []walletSpentOutput
	for _, call := range []struct {
		method string
		result any
	}{
		{"get_wallet_utxos", &utxos},
		{"get_wallet_stxos", &stxos},
		{"get_wallet_utxos_unconfirmed", &utxosUnconfirmed},
		{"get_wallet_stxos_unconfirmed", &stxosUnconfirmed},
	} {
		if err := h.proxy.Client.Call(ctx, call.method, nil, call.result); err != nil {
			return nil, fmt.Errorf("read the zSide wallet history with %s: %w", call.method, err)
		}
	}

	history := &walletHistory{
		entries: map[string]*historyEntry{},
		made:    map[coinKey]bool{},
		spent:   map[coinKey]bool{},
	}
	for _, group := range []struct {
		coins     []walletOutput
		spends    []walletSpentOutput
		confirmed bool
	}{{utxos, stxos, true}, {utxosUnconfirmed, stxosUnconfirmed, false}} {
		for _, coin := range group.coins {
			if err := history.addCoin(coin, group.confirmed); err != nil {
				return nil, err
			}
		}
		for _, spend := range group.spends {
			if err := history.addCoin(spend.Output, group.confirmed); err != nil {
				return nil, err
			}
			if err := history.addSpend(spend, group.confirmed); err != nil {
				return nil, err
			}
		}
	}

	out := make([]*pb.WalletTransaction, 0, len(history.entries))
	for _, entry := range history.entries {
		out = append(out, entry.tx)
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Confirmed != out[j].Confirmed {
			return out[i].Confirmed
		}
		return out[i].Txid < out[j].Txid
	})
	return out, nil
}
