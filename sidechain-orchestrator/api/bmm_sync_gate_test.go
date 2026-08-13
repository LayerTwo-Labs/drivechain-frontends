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

func TestEnforcerBiddingBlocked(t *testing.T) {
	tests := []struct {
		name   string
		status *orchestrator.SyncStatus
		code   connect.Code
		reason string
	}{
		{
			name:   "level with core",
			status: syncStatus(&orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}, &orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}),
		},
		{
			name:   "enforcer trails core",
			status: syncStatus(&orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}, &orchestrator.ChainSyncResult{Blocks: 4000, Headers: 8725}),
			code:   connect.CodeFailedPrecondition,
			reason: "still syncing",
		},
		{
			name:   "enforcer ahead of core",
			status: syncStatus(&orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}, &orchestrator.ChainSyncResult{Blocks: 8726, Headers: 8725}),
			code:   connect.CodeFailedPrecondition,
			reason: "still syncing",
		},
		{
			name:   "nothing synced yet",
			status: syncStatus(&orchestrator.ChainSyncResult{}, &orchestrator.ChainSyncResult{}),
			code:   connect.CodeFailedPrecondition,
			reason: "still syncing",
		},
		{
			name:   "enforcer not running",
			status: syncStatus(&orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}, &orchestrator.ChainSyncResult{Error: "not running"}),
			code:   connect.CodeFailedPrecondition,
			reason: "enforcer is not available",
		},
		{
			name:   "core not running",
			status: syncStatus(&orchestrator.ChainSyncResult{Error: "not running"}, &orchestrator.ChainSyncResult{Blocks: 8725, Headers: 8725}),
			code:   connect.CodeFailedPrecondition,
			reason: "bitcoin core is not available",
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
			err := enforcerBiddingBlocked(tc.status)
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
