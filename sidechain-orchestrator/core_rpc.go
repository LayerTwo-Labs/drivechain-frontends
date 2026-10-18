package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
)

// Stop acks immediately; the caller must wait for process exit for the flush.
func (c *CoreStatusClient) Stop(ctx context.Context) error {
	if _, err := c.call(ctx, "stop"); err != nil {
		return fmt.Errorf("bitcoind stop RPC: %w", err)
	}
	return nil
}

// --- Helpers ---

// callWallet calls a method on a specific wallet using the /wallet/<name> URL path.
func (c *CoreStatusClient) callWallet(ctx context.Context, walletName, method string, params ...interface{}) (json.RawMessage, error) {
	origURL := c.url
	c.url = fmt.Sprintf("%s/wallet/%s", origURL, walletName)
	defer func() { c.url = origURL }()

	if params == nil {
		params = []interface{}{}
	}
	return c.call(ctx, method, params...)
}
