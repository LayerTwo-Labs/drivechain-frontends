package thunderwallet

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"sync"
)

// ErrNotEnoughValue says the wallet holds too little to pay an amount and its
// fee.
var ErrNotEnoughValue = errors.New("not enough value")

// Coin is one output the wallet can spend.
type Coin struct {
	OutPoint  OutPoint
	LeafHash  Hash
	Address   Address
	ValueSats uint64
}

// CoinSource lists the coins a set of addresses holds. An index answers it in
// light mode, and a node answers it in full mode.
type CoinSource interface {
	Coins(ctx context.Context, addresses []Address) ([]Coin, error)
}

// Broadcaster hands a signed transaction to the network.
type Broadcaster interface {
	// Broadcast submits the transaction and returns its txid.
	Broadcast(ctx context.Context, tx AuthorizedTransaction) (Hash, error)
}

// Reserver hears what a broadcast spent, and what change it made.
//
// An index lags the node by a sync pass. It keeps offering a coin the wallet
// already spent, and it does not yet name the change. A second spend would
// then pick the spent coin, and would not see the money that came back.
type Reserver interface {
	Reserve(spent []OutPoint, change []Coin)
}

// Wallet spends thunder coins with no local node. It reads coins from a
// CoinSource, signs with a Keyring, and sends through a Broadcaster.
type Wallet struct {
	coins       CoinSource
	keys        Keyring
	broadcaster Broadcaster
	// reserver is optional. A source that already knows what it spent, such as
	// a node, needs none.
	reserver Reserver
	// spending serializes coin selection with the broadcast that follows it.
	// Two sends at the same time would otherwise pick one coin twice, and the
	// node would refuse the second as a conflict.
	spending sync.Mutex
}

// New builds a wallet over the three seams.
func New(coins CoinSource, keys Keyring, broadcaster Broadcaster) *Wallet {
	w := &Wallet{coins: coins, keys: keys, broadcaster: broadcaster}
	// A source that reserves for itself hears what each broadcast spent.
	if reserver, ok := coins.(Reserver); ok {
		w.reserver = reserver
	}
	return w
}

// Recipient is one payment a transaction makes.
type Recipient struct {
	Address   Address
	ValueSats uint64
}

// WithdrawalRequest asks for coins to leave the sidechain.
type WithdrawalRequest struct {
	// MainScriptPubKey is the mainchain script the payout goes to. It is what
	// the signature covers, because borsh writes an address as its script.
	MainScriptPubKey []byte
	// MainAddress is the same target in its text form, which the node RPC
	// takes.
	MainAddress string
	ValueSats   uint64
	MainFeeSats uint64
}

// Send pays a set of recipients and returns the txid.
//
// Change goes back to changeAddress. A caller supplies a fresh one, because a
// reused address links the payments together.
func (w *Wallet) Send(
	ctx context.Context,
	from []Address,
	to []Recipient,
	feeSats uint64,
	changeAddress Address,
) (Hash, error) {
	var outputs []Output
	var total uint64
	for _, recipient := range to {
		value := recipient.ValueSats
		outputs = append(outputs, Output{
			Address: recipient.Address,
			Content: Content{Value: &value},
		})
		if total += value; total < value {
			return Hash{}, fmt.Errorf("the payments overflow")
		}
	}
	return w.buildSignSend(ctx, from, outputs, total, feeSats, changeAddress)
}

// Withdraw asks for coins to leave the sidechain, and returns the txid.
//
// A withdrawal costs its payout plus its mainchain fee, because the enforcer
// pays both out of the treasury.
func (w *Wallet) Withdraw(
	ctx context.Context,
	from []Address,
	request WithdrawalRequest,
	feeSats uint64,
	changeAddress Address,
) (Hash, error) {
	if len(request.MainScriptPubKey) == 0 {
		return Hash{}, fmt.Errorf("a withdrawal names no mainchain script")
	}
	cost := request.ValueSats + request.MainFeeSats
	if cost < request.ValueSats {
		return Hash{}, fmt.Errorf("the withdrawal and its fee overflow")
	}
	outputs := []Output{{
		Address: changeAddress,
		Content: Content{Withdrawal: &Withdrawal{
			ValueSats:        request.ValueSats,
			MainFeeSats:      request.MainFeeSats,
			MainScriptPubKey: request.MainScriptPubKey,
			MainAddress:      request.MainAddress,
		}},
	}}
	return w.buildSignSend(ctx, from, outputs, cost, feeSats, changeAddress)
}

// buildSignSend selects coins, adds change, signs, and broadcasts.
func (w *Wallet) buildSignSend(
	ctx context.Context,
	from []Address,
	outputs []Output,
	spend uint64,
	feeSats uint64,
	changeAddress Address,
) (Hash, error) {
	w.spending.Lock()
	defer w.spending.Unlock()

	available, err := w.coins.Coins(ctx, from)
	if err != nil {
		return Hash{}, fmt.Errorf("read spendable coins: %w", err)
	}

	target := spend + feeSats
	if target < spend {
		return Hash{}, fmt.Errorf("the amount and its fee overflow")
	}

	selected, gathered, err := SelectCoins(available, target)
	if err != nil {
		return Hash{}, err
	}

	if change := gathered - target; change > 0 {
		outputs = append(outputs, Output{
			Address: changeAddress,
			Content: Content{Value: &change},
		})
	}

	tx := Transaction{Outputs: outputs}
	owners := make([]Address, 0, len(selected))
	for _, coin := range selected {
		tx.Inputs = append(tx.Inputs, Input{
			OutPoint: coin.OutPoint,
			LeafHash: coin.LeafHash,
		})
		owners = append(owners, coin.Address)
	}

	signed, err := Sign(tx, owners, w.keys)
	if err != nil {
		return Hash{}, err
	}
	if err := Verify(signed); err != nil {
		return Hash{}, fmt.Errorf("the wallet signed a transaction it cannot verify: %w", err)
	}

	txid, err := w.broadcaster.Broadcast(ctx, signed)
	if err != nil {
		return Hash{}, err
	}
	if w.reserver != nil {
		spent := make([]OutPoint, 0, len(selected))
		for _, coin := range selected {
			spent = append(spent, coin.OutPoint)
		}
		w.reserver.Reserve(spent, changeCoins(txid, tx))
	}
	return txid, nil
}

// changeCoins names the value outputs a transaction pays back to the wallet.
// The index does not carry them until it syncs, and a second send needs them.
func changeCoins(txid Hash, tx Transaction) []Coin {
	var out []Coin
	for i, output := range tx.Outputs {
		if output.Content.Value == nil {
			continue
		}
		outpoint := OutPoint{Kind: KindRegular, Source: txid, Vout: uint32(i)}
		leaf, err := LeafHash(outpoint, output)
		if err != nil {
			// A coin with no leaf hash cannot be spent, and leaving it out
			// only holds the change back until the index catches up.
			continue
		}
		out = append(out, Coin{
			OutPoint:  outpoint,
			LeafHash:  leaf,
			Address:   output.Address,
			ValueSats: *output.Content.Value,
		})
	}
	return out
}

// SelectCoins picks coins to cover a target, largest first, and returns what
// they gather. Largest first keeps the input count low, which keeps the
// transaction small and its fee down.
func SelectCoins(available []Coin, target uint64) ([]Coin, uint64, error) {
	ordered := make([]Coin, len(available))
	copy(ordered, available)
	sort.SliceStable(ordered, func(i, j int) bool {
		return ordered[i].ValueSats > ordered[j].ValueSats
	})

	var selected []Coin
	var gathered uint64
	for _, coin := range ordered {
		selected = append(selected, coin)
		if gathered += coin.ValueSats; gathered >= target {
			return selected, gathered, nil
		}
	}
	return nil, 0, fmt.Errorf(
		"%w: the wallet holds %d sats and the transaction costs %d",
		ErrNotEnoughValue, gathered, target)
}
