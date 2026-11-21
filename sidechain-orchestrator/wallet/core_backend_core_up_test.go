package wallet

import (
	"context"
	"sync/atomic"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCoreBackendEnsureTriesAgainOnceCoreIsUp(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	var warm atomic.Bool
	listWallets := fake.handlerFor("listwallets")
	fake.handle("listwallets", func(c bitcoindCall) (any, string) {
		if !warm.Load() {
			return nil, "Loading wallet…"
		}
		return listWallets(c)
	})

	_, err := backend.Ensure(context.Background(), coreID)
	require.ErrorContains(t, err, "Loading wallet")
	warm.Store(true)
	_, err = backend.Ensure(context.Background(), coreID)
	require.ErrorContains(t, err, "Loading wallet", "the error stays for the backoff while Core warms up")

	backend.CoreUp()
	name, err := backend.Ensure(context.Background(), coreID)
	require.NoError(t, err)
	require.Equal(t, "wallet_"+coreID[:8], name)
	backend.bip47Imports.Wait()
}
