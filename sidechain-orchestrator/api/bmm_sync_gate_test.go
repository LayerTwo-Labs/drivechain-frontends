package api

import (
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
)

func syncStatus(mainchain, enforcer *orchestrator.ChainSyncResult) *orchestrator.SyncStatus {
	return &orchestrator.SyncStatus{Mainchain: mainchain, Enforcer: enforcer}
}

func withChainSource(status *orchestrator.SyncStatus, source *orchestrator.ChainSyncResult) *orchestrator.SyncStatus {
	status.ChainSource = source
	return status
}

func TestEnforcerBiddingBlocked(t *testing.T) {
	synced := func() *orchestrator.ChainSyncResult {
		return &orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}
	}
	coreDown := func() *orchestrator.ChainSyncResult {
		return &orchestrator.ChainSyncResult{Error: "not running"}
	}

	tests := []struct {
		name      string
		status    *orchestrator.SyncStatus
		readsCore bool
		code      connect.Code
		reason    string
	}{
		{
			name:      "level with core",
			status:    syncStatus(synced(), synced()),
			readsCore: true,
		},
		{
			name:      "enforcer trails core",
			status:    syncStatus(synced(), &orchestrator.ChainSyncResult{Blocks: 4000, Headers: 8725}),
			readsCore: true,
			code:      connect.CodeFailedPrecondition,
			reason:    "still syncing",
		},
		{
			name:      "enforcer ahead of core",
			status:    syncStatus(synced(), &orchestrator.ChainSyncResult{Blocks: 8726, Headers: 8725}),
			readsCore: true,
			code:      connect.CodeFailedPrecondition,
			reason:    "still syncing",
		},
		{
			name:      "nothing synced yet",
			status:    syncStatus(&orchestrator.ChainSyncResult{}, &orchestrator.ChainSyncResult{}),
			readsCore: true,
			code:      connect.CodeFailedPrecondition,
			reason:    "still syncing",
		},
		{
			name:      "enforcer not running",
			status:    syncStatus(synced(), &orchestrator.ChainSyncResult{Error: "not running"}),
			readsCore: true,
			code:      connect.CodeFailedPrecondition,
			reason:    "enforcer is not available",
		},
		{
			name:      "core not running",
			status:    syncStatus(&orchestrator.ChainSyncResult{Error: "not running"}, synced()),
			readsCore: true,
			code:      connect.CodeFailedPrecondition,
			reason:    "bitcoin core is not available",
		},
		{
			// An install with no local Core reports a mainchain error at all
			// times, so the wallet chain source measures the remote enforcer.
			name:   "no core, enforcer level with the chain source",
			status: withChainSource(syncStatus(coreDown(), synced()), synced()),
		},
		{
			name:   "no core, enforcer trails the chain source",
			status: withChainSource(syncStatus(coreDown(), &orchestrator.ChainSyncResult{Blocks: 8700, Headers: 8700}), synced()),
			code:   connect.CodeFailedPrecondition,
			reason: "still syncing",
		},
		{
			// An electrum server that trails the enforcer must not stop a bid.
			name:   "no core, enforcer ahead of the chain source",
			status: withChainSource(syncStatus(coreDown(), &orchestrator.ChainSyncResult{Blocks: 8726, Headers: 8726}), synced()),
		},
		{
			name:   "no core, no chain source tip",
			status: withChainSource(syncStatus(coreDown(), synced()), &orchestrator.ChainSyncResult{Error: "electrum is not reachable"}),
			code:   connect.CodeUnavailable,
			reason: "no tip to measure the enforcer against",
		},
		{
			name:   "no core, remote enforcer down",
			status: withChainSource(syncStatus(coreDown(), &orchestrator.ChainSyncResult{Error: "remote validator is not ready"}), synced()),
			code:   connect.CodeFailedPrecondition,
			reason: "enforcer is not available",
		},
		{
			name:   "no status",
			status: nil,
			code:   connect.CodeUnavailable,
			reason: "sync status unavailable",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			err := enforcerBiddingBlocked(tc.status, tc.readsCore)
			if tc.reason == "" {
				assert.NoError(t, err)
				return
			}
			require.Error(t, err)
			assert.Equal(t, tc.code, connect.CodeOf(err))
			assert.Contains(t, err.Error(), tc.reason)
		})
	}
}
