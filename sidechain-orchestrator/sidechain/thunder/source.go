package thunder

import (
	"context"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// HistorySource lists transactions for wallet addresses.
type HistorySource interface {
	History(ctx context.Context, addresses []string) ([]sidechainesplora.Entry, error)
	// TipHeight returns the tip height of the history source.
	TipHeight(ctx context.Context) (uint32, error)
}

// AddressSource lists the local wallet addresses.
type AddressSource interface {
	Addresses(ctx context.Context) ([]string, error)
}

var _ HistorySource = (*sidechainesplora.Wallet)(nil)
