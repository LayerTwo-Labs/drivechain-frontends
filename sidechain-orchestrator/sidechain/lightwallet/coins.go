package lightwallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// readAhead is how many addresses the wallet reads at the same time. A balance
// covers the whole derived window, and one address after another costs a round
// trip each.
const readAhead = 8

// OutPointKind tags how an output came into being.
type OutPointKind string

const (
	KindRegular  OutPointKind = "regular"
	KindCoinbase OutPointKind = "coinbase"
	KindDeposit  OutPointKind = "deposit"
)

// OutPoint names one output. Txid is the hex the index answered with: a
// mainchain txid for a deposit, and a sidechain txid otherwise.
type OutPoint struct {
	Kind OutPointKind
	Txid string
	Vout uint32
}

// Coin is one output the wallet holds.
type Coin struct {
	OutPoint  OutPoint
	Address   Address
	ValueSats uint64
	// ContentType names what the output holds, such as "value" or "bitasset".
	ContentType string
	// Content is the chain-specific payload the node wrote for this output. It
	// names the asset a bitassets output holds, so a holder reads it back.
	Content json.RawMessage
	// Spendable is true for a plain coin. Only a plain coin counts in the
	// bitcoin balance.
	Spendable bool
}

// IndexCoins reads the coins a set of addresses holds from an Esplora index.
type IndexCoins struct {
	client *sidechainesplora.Client
}

// NewIndexCoins reads through one index.
func NewIndexCoins(client *sidechainesplora.Client) *IndexCoins {
	return &IndexCoins{client: client}
}

// Split lists every output a set of addresses holds, in two halves: the ones a
// block carries, and the ones no block carries yet. The caller picks which
// payloads its chain shows.
func (i *IndexCoins) Split(
	ctx context.Context, addresses []Address,
) (confirmed, pending []Coin, err error) {
	mined := make([][]Coin, len(addresses))
	waiting := make([][]Coin, len(addresses))
	errs := make([]error, len(addresses))

	var wg sync.WaitGroup
	limit := make(chan struct{}, readAhead)
	for at, address := range addresses {
		wg.Add(1)
		limit <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-limit }()
			mined[at], waiting[at], errs[at] = i.readAddress(ctx, address)
		}()
	}
	wg.Wait()

	for at, err := range errs {
		if err != nil {
			return nil, nil, err
		}
		confirmed = append(confirmed, mined[at]...)
		pending = append(pending, waiting[at]...)
	}
	return confirmed, pending, nil
}

func (i *IndexCoins) readAddress(
	ctx context.Context, address Address,
) (confirmed, pending []Coin, err error) {
	utxos, err := i.client.AddressUTXOs(ctx, address.String())
	if err != nil {
		return nil, nil, fmt.Errorf("read utxos for %s: %w", address, err)
	}
	for _, utxo := range utxos {
		coin, err := newCoin(address, utxo)
		if err != nil {
			return nil, nil, err
		}
		if utxo.Status.Confirmed {
			confirmed = append(confirmed, coin)
			continue
		}
		pending = append(pending, coin)
	}
	return confirmed, pending, nil
}

func newCoin(address Address, utxo sidechainesplora.UTXO) (Coin, error) {
	outpoint, err := outPointFromIndex(utxo)
	if err != nil {
		return Coin{}, err
	}
	if utxo.Value < 0 {
		return Coin{}, fmt.Errorf("%s holds a coin worth %d sats", address, utxo.Value)
	}
	return Coin{
		OutPoint:    outpoint,
		Address:     address,
		ValueSats:   uint64(utxo.Value),
		ContentType: utxo.ContentType,
		Content:     utxo.Content,
		Spendable:   utxo.Spendable(),
	}, nil
}

// outPointFromIndex reads the outpoint an index row names.
func outPointFromIndex(utxo sidechainesplora.UTXO) (OutPoint, error) {
	txid := strings.TrimSpace(utxo.Txid)
	if raw, err := hex.DecodeString(txid); err != nil || len(raw) != 32 {
		return OutPoint{}, fmt.Errorf("utxo names txid %q", utxo.Txid)
	}
	switch utxo.OutpointKind {
	case "regular", "":
		return OutPoint{Kind: KindRegular, Txid: txid, Vout: utxo.Vout}, nil
	case "coinbase":
		return OutPoint{Kind: KindCoinbase, Txid: txid, Vout: utxo.Vout}, nil
	case "deposit":
		return OutPoint{Kind: KindDeposit, Txid: txid, Vout: utxo.Vout}, nil
	default:
		return OutPoint{}, fmt.Errorf("utxo names outpoint kind %q", utxo.OutpointKind)
	}
}
