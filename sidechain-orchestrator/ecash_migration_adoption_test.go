package orchestrator

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestECashMigrationResumesAdoptedTarget(t *testing.T) {
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", false)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	_, err := o.StartECashMigration(ctx, "alphanet", "betanet")
	require.NoError(t, err)
	complete := waitMigrationEngineTest(t, o)
	requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
	o.StopAllMonitors()
	child := o.process.Get("bitcoind")
	require.NotNil(t, child)
	client, err := o.CoreStatusClient()
	require.NoError(t, err)
	require.NoError(t, migrationRPC(ctx, client, "setnetworkactive", nil, false))
	state, err := o.readMigration()
	require.NoError(t, err)
	state.Step = 4
	state.Status.Complete = false
	state.Status.Phase = "check"
	require.NoError(t, o.saveMigration(state))

	catalog := o.Catalog
	catalog.SchemaVersion = 1
	data, err := json.Marshal(catalog)
	require.NoError(t, err)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, err := w.Write(data)
		require.NoError(t, err)
	}))
	defer server.Close()
	next := New(o.DataDir, "ecash", o.BitwindowDir, AllDefaults(), testLogger(t))
	registerMigrationEngineCleanup(t, next)
	lock, held, err := TakeOwnerLock(next.DataDir)
	require.NoError(t, err)
	require.True(t, held)
	next.SetOwnerLock(lock)
	t.Cleanup(func() { require.NoError(t, lock.Release()) })
	next.catalogURL = server.URL
	require.NoError(t, next.AdoptOrphans(ctx))
	adopted := next.process.Get("bitcoind")
	require.NotNil(t, adopted)
	require.Equal(t, child.Pid, adopted.Pid)
	require.True(t, adopted.Adopted)
	require.True(t, next.mayStopAdopted("bitcoind"))
	require.Equal(t, child.BinPath, adopted.BinPath)
	next.ResolveNetworkCatalog(ctx)
	require.Eventually(t, func() bool {
		next.mu.RLock()
		defer next.mu.RUnlock()
		entry, ok := next.Catalog.ByID("alphanet")
		return ok && entry.ForkHeight == 101
	}, 5*time.Second, 25*time.Millisecond)
	require.Equal(t, child.BinPath, adopted.BinPath)
	_, err = next.StartECashMigration(ctx, "alphanet", "betanet")
	require.NoError(t, err)
	resumed := waitMigrationEngineTest(t, next)
	requireMigrationEngineResult(t, next, fixture, resumed, block, undo, wallet)
	require.Equal(t, child.Pid, next.process.Get("bitcoind").Pid)
}
