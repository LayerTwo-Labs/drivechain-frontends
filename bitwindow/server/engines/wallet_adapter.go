package engines

import (
	"context"
)

// WalletAdapter adapts the wallet engine for the timestamp engine, routing
// OP_RETURN broadcasts through the active wallet's backend (electrum or enforcer).
type WalletAdapter struct {
	engine *WalletEngine
}

func NewWalletAdapter(engine *WalletEngine) *WalletAdapter {
	return &WalletAdapter{engine: engine}
}

func (w *WalletAdapter) SendTransaction(ctx context.Context, opReturnData []byte) (string, error) {
	return w.engine.BroadcastOpReturn(ctx, opReturnData, 0, 0)
}
