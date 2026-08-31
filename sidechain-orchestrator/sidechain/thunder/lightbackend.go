package thunder

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/btcsuite/btcd/chaincfg"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
	tw "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// lightBackend runs the wallet in this process, over an Esplora index. It
// starts no thunder binary, and it holds the keys it signs with.
type lightBackend struct {
	keys  *tw.MemoryKeyring
	known AddressSource
	coins *tw.ReservedCoins

	client *sidechainesplora.Client
	wallet *tw.Wallet
	// params name the mainchain of the mode this backend was built for.
	params *chaincfg.Params
}

func newLightBackend(
	keys *tw.MemoryKeyring, known AddressSource,
	client *sidechainesplora.Client, params *chaincfg.Params,
) *lightBackend {
	// The index lags what the wallet spends, so a second send must not pick a
	// coin the first one already used.
	coins := tw.NewReservedCoins(tw.NewIndexCoins(client))
	return &lightBackend{
		keys:   keys,
		known:  known,
		coins:  coins,
		client: client,
		wallet: tw.New(coins, keys, tw.NewIndexBroadcast(client.BaseURL())),
		params: params,
	}
}

// addresses names the keys the wallet reaches. Reading every key it could ever
// hold would cost one request each, so discovery bounds the walk.
func (b *lightBackend) addresses(ctx context.Context) ([]tw.Address, error) {
	if b.known == nil {
		return b.keys.Addresses(), nil
	}
	names, err := b.known.Addresses(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]tw.Address, 0, len(names))
	for _, name := range names {
		address, err := tw.ParseAddress(name)
		if err != nil {
			return nil, fmt.Errorf("read the wallet address %q: %w", name, err)
		}
		out = append(out, address)
	}
	return out, nil
}

// Balance sums the coins the index holds for this wallet. The index carries
// confirmed coins, so the whole balance is spendable.
func (b *lightBackend) Balance(ctx context.Context) (int64, int64, error) {
	addresses, err := b.addresses(ctx)
	if err != nil {
		return 0, 0, err
	}
	coins, err := b.coins.Coins(ctx, addresses)
	if err != nil {
		return 0, 0, err
	}
	var total int64
	for _, coin := range coins {
		total += int64(coin.ValueSats)
	}
	return total, total, nil
}

// NewAddress hands out the first address that never received a coin. Asking
// twice answers the same address until that one is paid, which is what a
// receive page shows.
func (b *lightBackend) NewAddress(ctx context.Context) (string, error) {
	address, err := b.unusedAddress(ctx, 0)
	if err != nil {
		return "", err
	}
	return address.String(), nil
}

func (b *lightBackend) UTXOs(ctx context.Context) (json.RawMessage, error) {
	addresses, err := b.addresses(ctx)
	if err != nil {
		return nil, err
	}
	coins, err := b.coins.Coins(ctx, addresses)
	if err != nil {
		return nil, err
	}
	return tw.MarshalUTXOs(coins)
}

func (b *lightBackend) Transfer(
	ctx context.Context, address string, amountSats, feeSats int64,
) (string, error) {
	to, err := tw.ParseAddress(address)
	if err != nil {
		return "", fmt.Errorf("read the address %q: %w", address, err)
	}
	amount, fee, err := amountAndFee(amountSats, feeSats)
	if err != nil {
		return "", err
	}
	from, err := b.addresses(ctx)
	if err != nil {
		return "", err
	}
	change, err := b.changeAddress(ctx)
	if err != nil {
		return "", err
	}

	txid, err := b.wallet.Send(ctx, from,
		[]tw.Recipient{{Address: to, ValueSats: amount}}, fee, change)
	if err != nil {
		return "", err
	}
	return txid.String(), nil
}

func (b *lightBackend) Withdraw(
	ctx context.Context, address string, amountSats, sideFeeSats, mainFeeSats int64,
) (string, error) {
	script, err := tw.MainScriptPubKey(address, b.params)
	if err != nil {
		return "", err
	}
	amount, fee, err := amountAndFee(amountSats, sideFeeSats)
	if err != nil {
		return "", err
	}
	if mainFeeSats < 0 {
		return "", fmt.Errorf("the mainchain fee is negative")
	}
	from, err := b.addresses(ctx)
	if err != nil {
		return "", err
	}
	change, err := b.changeAddress(ctx)
	if err != nil {
		return "", err
	}

	txid, err := b.wallet.Withdraw(ctx, from, tw.WithdrawalRequest{
		MainScriptPubKey: script,
		MainAddress:      address,
		ValueSats:        amount,
		MainFeeSats:      uint64(mainFeeSats),
	}, fee, change)
	if err != nil {
		return "", err
	}
	return txid.String(), nil
}

// changeAddress takes the second free address, never the first.
//
// NewAddress always hands out the first free one, so that address may carry an
// invoice nobody paid yet. Change on it would tie the payment out to the
// invoice, and the payment that arrives later would mingle with the change.
// Skipping by position needs no memory, so a restart cannot forget.
func (b *lightBackend) changeAddress(ctx context.Context) (tw.Address, error) {
	address, err := b.unusedAddress(ctx, 1)
	if err == nil {
		return address, nil
	}
	// One free address is left, and it carries the invoice. Reusing it beats
	// refusing to spend at all.
	return b.unusedAddress(ctx, 0)
}

// unusedAddress walks the derived window and returns an address that received
// nothing. skip says how many such addresses to pass over first.
func (b *lightBackend) unusedAddress(ctx context.Context, skip int) (tw.Address, error) {
	addresses := b.keys.Addresses()
	for _, address := range addresses {
		stats, err := b.client.AddressStats(ctx, address.String())
		if err != nil {
			return tw.Address{}, fmt.Errorf("read %s: %w", address, err)
		}
		// A coin that is broadcast but not yet mined shows in the mempool
		// counts. Reusing that address would link the payments together.
		if stats.ChainStats.FundedTxoCount > 0 || stats.MempoolStats.FundedTxoCount > 0 {
			continue
		}
		deposits, err := b.client.AddressDeposits(ctx, address.String())
		if err != nil {
			return tw.Address{}, fmt.Errorf("read deposits for %s: %w", address, err)
		}
		if len(deposits) == 0 {
			if skip > 0 {
				skip--
				continue
			}
			return address, nil
		}
	}
	return tw.Address{}, fmt.Errorf(
		"the wallet used every one of its %d addresses", len(addresses))
}

func amountAndFee(amountSats, feeSats int64) (uint64, uint64, error) {
	if amountSats <= 0 {
		return 0, 0, fmt.Errorf("the amount must be above zero")
	}
	if feeSats < 0 {
		return 0, 0, fmt.Errorf("the fee is negative")
	}
	return uint64(amountSats), uint64(feeSats), nil
}

var _ WalletBackend = (*lightBackend)(nil)
