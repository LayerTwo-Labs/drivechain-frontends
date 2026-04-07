package engines

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// MockNotificationEngine for testing
type MockNotificationEngine struct {
	sentEvents []*notificationv1.WatchResponse
}

func (m *MockNotificationEngine) Broadcast(ctx context.Context, event *notificationv1.WatchResponse) {
	m.sentEvents = append(m.sentEvents, event)
}

func TestSidechainMonitorEngine_RegisterPendingFastWithdrawal(t *testing.T) {
	ctx := context.Background()

	// Create engine with nil notification (not testing notifications here)
	engine := NewSidechainMonitorEngine(
		nil, nil, nil, nil, nil, nil, // sidechain services not needed for this test
		nil, // notification engine not needed for this test
	)

	// Create test withdrawal
	withdrawal := PendingFastWithdrawal{
		Hash:           "test-hash-123456789abcdef",
		Sidechain:      "thunder",
		ServerAddress:  "thunder1test456",
		ExpectedAmount: 105000, // 1.05 BTC in sats
		ServerURL:      "https://fw1.drivechain.info",
		CreatedAt:      time.Now(),
	}

	// Register withdrawal
	err := engine.RegisterPendingFastWithdrawal(ctx, withdrawal)
	require.NoError(t, err)

	// Verify it was stored
	pending, err := engine.GetPendingFastWithdrawals(ctx)
	require.NoError(t, err)
	assert.Len(t, pending, 1)
	assert.Equal(t, "test-hash-123456789abcdef", pending[0].Hash)
	assert.Equal(t, "thunder", pending[0].Sidechain)
	assert.Equal(t, "thunder1test456", pending[0].ServerAddress)
}

func TestSidechainMonitorEngine_CompleteWithdrawal(t *testing.T) {
	ctx := zerolog.New(zerolog.NewTestWriter(t)).WithContext(context.Background())

	// Mock external fast withdrawal server
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "/paid", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		var payload map[string]string
		err := json.NewDecoder(r.Body).Decode(&payload)
		require.NoError(t, err)

		assert.Equal(t, "test-hash-123456789abcdef", payload["hash"])
		assert.Equal(t, "test-txid-456789abcdef123", payload["txid"])

		// Return success response
		response := map[string]interface{}{
			"status": "success",
			"message": map[string]string{
				"info": "l1-withdrawal-txid-789",
			},
		}
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Errorf("failed to encode response: %v", err)
		}
	}))
	defer mockServer.Close()

	// Create engine
	engine := NewSidechainMonitorEngine(
		nil, nil, nil, nil, nil, nil,
		nil,
	)

	// Register pending withdrawal
	pending := PendingFastWithdrawal{
		Hash:           "test-hash-123456789abcdef", // Make hash longer for validation
		Sidechain:      "thunder",
		ServerAddress:  "thunder1test456",
		ExpectedAmount: 105000,
		ServerURL:      mockServer.URL, // Use mock server URL
		CreatedAt:      time.Now(),
	}

	err := engine.RegisterPendingFastWithdrawal(ctx, pending)
	require.NoError(t, err)

	// Complete the withdrawal
	err = engine.completeWithdrawal(ctx, pending, "test-txid-456789abcdef123")
	require.NoError(t, err)

	// Verify withdrawal was removed from pending
	remaining, err := engine.GetPendingFastWithdrawals(ctx)
	require.NoError(t, err)
	assert.Len(t, remaining, 0)
}

func TestSidechainMonitorEngine_StoreWithdrawal(t *testing.T) {
	ctx := context.Background()

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
	err := engine.storeWithdrawal(ctx, withdrawal)
	require.NoError(t, err)

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
		nil,
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
		nil,
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
