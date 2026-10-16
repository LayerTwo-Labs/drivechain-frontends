package engines

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
)

// MockNotificationEngine for testing
type MockNotificationEngine struct {
	sentEvents []*notificationv1.WatchResponse
}

func (m *MockNotificationEngine) Deliver(ctx context.Context, event *notificationv1.WatchResponse) int {
	m.sentEvents = append(m.sentEvents, event)
	return 1
}

func TestSidechainMonitorEngine_StoreWithdrawal(t *testing.T) {
	ctx := t.Context()

	mockNotification := &MockNotificationEngine{}

	engine := NewSidechainMonitorEngine(
		nil, nil, nil, nil, nil, nil,
		mockNotification,
	)

	// Create test withdrawal
	withdrawal := DetectedWithdrawal{
		Txid:        "detected-txid-123",
		Sidechain:   "thunder",
		Amount:      100000000, // 1 BTC in sats
		Destination: "bc1qtest789",
		DetectedAt:  time.Now(),
	}

	// Store withdrawal
	engine.storeWithdrawal(ctx, withdrawal)

	// Verify it was stored
	stored, err := engine.GetWithdrawalByTxid(ctx, "detected-txid-123")
	require.NoError(t, err)
	require.NotNil(t, stored)
	assert.Equal(t, "detected-txid-123", stored.Txid)
	assert.Equal(t, "thunder", stored.Sidechain)
	assert.Equal(t, int64(100000000), stored.Amount)

	// Verify notification was sent
	assert.Len(t, mockNotification.sentEvents, 1)
	assert.NotNil(t, mockNotification.sentEvents[0].Event.(*notificationv1.WatchResponse_SidechainWithdrawal))
}

func TestSidechainMonitorEngine_GetPollInterval(t *testing.T) {
	engine := NewSidechainMonitorEngine(
		nil, nil, nil, nil, nil, nil,
		&MockNotificationEngine{},
	)

	// When no withdrawals detected, should return 30 seconds
	interval := engine.getPollInterval()
	assert.Equal(t, 30*time.Second, interval)

	// Add a detected withdrawal
	engine.detectedWithdrawals["test-txid"] = DetectedWithdrawal{
		Txid:       "test-txid",
		Sidechain:  "thunder",
		DetectedAt: time.Now(),
	}

	// Should now return 5 seconds for faster polling (new logic: light activity)
	interval = engine.getPollInterval()
	assert.Equal(t, 5*time.Second, interval)
}

func TestSidechainMonitorEngine_CleanupOldWithdrawals(t *testing.T) {
	engine := NewSidechainMonitorEngine(
		nil, nil, nil, nil, nil, nil,
		&MockNotificationEngine{},
	)

	// Add old and new withdrawals
	oldTime := time.Now().Add(-2 * time.Hour)    // 2 hours ago (older than 1 hour cutoff)
	newTime := time.Now().Add(-30 * time.Minute) // 30 minutes ago (newer than cutoff)

	engine.detectedWithdrawals["old-txid"] = DetectedWithdrawal{
		Txid:       "old-txid",
		DetectedAt: oldTime,
	}
	engine.detectedWithdrawals["new-txid"] = DetectedWithdrawal{
		Txid:       "new-txid",
		DetectedAt: newTime,
	}

	// Run cleanup
	engine.cleanupOldWithdrawals()

	// Old withdrawal should be removed, new one should remain
	assert.NotContains(t, engine.detectedWithdrawals, "old-txid")
	assert.Contains(t, engine.detectedWithdrawals, "new-txid")
}

type fakeSidechainRPC struct {
	bundle string
}

func (f fakeSidechainRPC) PendingWithdrawalBundle(context.Context) (json.RawMessage, error) {
	return json.RawMessage(f.bundle), nil
}

func TestSidechainMonitorEngine_Monitor(t *testing.T) {
	ctx := t.Context()
	engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, &MockNotificationEngine{})
	client := fakeSidechainRPC{
		bundle: `{"transactions":[{"txid":"bundle-tx","amount":5000,"destination":"bc1qdest"}]}`,
	}

	require.NoError(t, engine.monitor(ctx, "photon", func(context.Context) (sidechainRPC, error) {
		return client, nil
	}))

	stored, err := engine.GetWithdrawalByTxid(ctx, "bundle-tx")
	require.NoError(t, err)
	require.NotNil(t, stored)
	require.Equal(t, "photon", stored.Sidechain)
	require.Equal(t, int64(5000), stored.Amount)

	err = engine.monitor(ctx, "photon", func(context.Context) (sidechainRPC, error) {
		return nil, errors.New("not running")
	})
	require.ErrorContains(t, err, "get photon client: not running")
}
