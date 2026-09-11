package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// thunderNode is a fake Thunder node at 294 blocks. progress answers
// mainchain_sync_progress; a nil progress makes the node lack the method.
func thunderNode(t *testing.T, progress func(w http.ResponseWriter, id int64)) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		method, id := readJSONRPC(r)
		switch {
		case method == "getblockcount":
			writeJSONRPCResult(w, id, 294)
		case method == "mainchain_sync_progress" && progress != nil:
			progress(w, id)
		default:
			writeJSONRPCError(w, id, RPCMethodNotFound, "Method not found")
		}
	}))
	t.Cleanup(srv.Close)
	return srv
}

func answerProgress(phase string, done, total, tip uint32) func(http.ResponseWriter, int64) {
	return func(w http.ResponseWriter, id int64) {
		writeJSONRPCResult(w, id, map[string]any{
			"phase":      phase,
			"done":       done,
			"total":      total,
			"tip_height": tip,
		})
	}
}

// thunderSyncStatus returns Thunder's slot from one GetSyncStatus poll. The
// explorer puts Thunder's tip at 500.
func thunderSyncStatus(t *testing.T, progress func(http.ResponseWriter, int64)) *ChainSyncResult {
	t.Helper()
	o := newTestOrchestrator(t)
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return jsonResponse(map[string]map[string]any{
				"thunder": {"height": "500"},
			}), nil
		}),
	}
	srv := thunderNode(t, progress)
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	slot := out.Sidechains["thunder"]
	require.NotNil(t, slot)
	return slot
}

func TestGetSyncStatus_ReportsMainchainSyncPhase(t *testing.T) {
	for _, phase := range []sidechain.MainchainSyncPhase{
		sidechain.MainchainSyncHeaders,
		sidechain.MainchainSyncWriting,
		sidechain.MainchainSyncState,
		"rewind",
	} {
		t.Run(string(phase), func(t *testing.T) {
			slot := thunderSyncStatus(t, answerProgress(string(phase), 412000, 997070, 997071))

			assert.Empty(t, slot.Error)
			assert.Equal(t, phase, slot.MainchainSyncPhase)
			assert.Equal(t, int64(412000), slot.Blocks)
			assert.Equal(t, int64(997070), slot.Headers, "the explorer tip must not replace the phase total")
			assert.Equal(t, int64(997071), slot.MainchainTipHeight)
		})
	}
}

func TestGetSyncStatus_IdleMainchainSyncReportsBlocks(t *testing.T) {
	slot := thunderSyncStatus(t, answerProgress("idle", 0, 0, 0))

	assert.Empty(t, slot.Error)
	assert.Empty(t, slot.MainchainSyncPhase)
	assert.Equal(t, int64(294), slot.Blocks)
	assert.Equal(t, int64(500), slot.Headers)
	assert.Zero(t, slot.MainchainTipHeight)
}

func TestGetSyncStatus_NodeWithoutMainchainSyncProgressReportsBlocks(t *testing.T) {
	slot := thunderSyncStatus(t, nil)

	assert.Empty(t, slot.Error)
	assert.Empty(t, slot.MainchainSyncPhase)
	assert.Equal(t, int64(294), slot.Blocks)
	assert.Equal(t, int64(500), slot.Headers)
}

func TestGetSyncStatus_MainchainSyncProgressFailureIsAnError(t *testing.T) {
	slot := thunderSyncStatus(t, func(w http.ResponseWriter, id int64) {
		writeJSONRPCError(w, id, -32603, "Internal error")
	})

	assert.NotEmpty(t, slot.Error)
	assert.Zero(t, slot.Blocks)
	assert.Empty(t, slot.MainchainSyncPhase)
}

// A phase starts at zero done. A transient failure right after must keep the
// phase, not replace it with an error.
func TestGetSyncStatus_KeepsZeroProgressPhaseAcrossTransientFailures(t *testing.T) {
	o := newTestOrchestrator(t)
	o.explorerHTTPClient = &http.Client{
		Transport: roundTripperFunc(func(*http.Request) (*http.Response, error) {
			return statusResponse(http.StatusServiceUnavailable), nil
		}),
	}
	var calls int32
	srv := thunderNode(t, func(w http.ResponseWriter, id int64) {
		if atomic.AddInt32(&calls, 1) == 1 {
			answerProgress("headers", 0, 997070, 997070)(w, id)
			return
		}
		w.WriteHeader(http.StatusInternalServerError)
	})
	setSidechainPort(t, o, "thunder", srv.URL)
	adoptSidechain(t, o, "thunder")

	_, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	o.invalidateSyncConnectionCacheForTest("thunder")

	out, err := o.GetSyncStatus(context.Background())
	require.NoError(t, err)
	slot := out.Sidechains["thunder"]
	assert.Empty(t, slot.Error)
	assert.Equal(t, sidechain.MainchainSyncHeaders, slot.MainchainSyncPhase)
	assert.Equal(t, int64(997070), slot.Headers)
}
