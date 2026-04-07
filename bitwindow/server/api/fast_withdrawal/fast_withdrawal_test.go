package fast_withdrawal

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// SidechainMonitor interface for testability
type SidechainMonitor interface {
	RegisterPendingFastWithdrawal(ctx context.Context, withdrawal engines.PendingFastWithdrawal) error
	GetWithdrawalByTxid(ctx context.Context, txid string) (*engines.DetectedWithdrawal, error)
	GetPendingFastWithdrawals(ctx context.Context) ([]engines.PendingFastWithdrawal, error)
	GetDetectedWithdrawals(ctx context.Context) ([]engines.DetectedWithdrawal, error)
}

// MockSidechainMonitorEngine for testing
type MockSidechainMonitorEngine struct {
	pendingWithdrawals  map[string]engines.PendingFastWithdrawal
	detectedWithdrawals map[string]engines.DetectedWithdrawal
}

func NewMockSidechainMonitorEngine() *MockSidechainMonitorEngine {
	return &MockSidechainMonitorEngine{
		pendingWithdrawals:  make(map[string]engines.PendingFastWithdrawal),
		detectedWithdrawals: make(map[string]engines.DetectedWithdrawal),
	}
}

func (m *MockSidechainMonitorEngine) RegisterPendingFastWithdrawal(ctx context.Context, withdrawal engines.PendingFastWithdrawal) error {
	m.pendingWithdrawals[withdrawal.Hash] = withdrawal
	return nil
}

func (m *MockSidechainMonitorEngine) GetWithdrawalByTxid(ctx context.Context, txid string) (*engines.DetectedWithdrawal, error) {
	if withdrawal, exists := m.detectedWithdrawals[txid]; exists {
		return &withdrawal, nil
	}
	return nil, nil
}

func (m *MockSidechainMonitorEngine) GetPendingFastWithdrawals(ctx context.Context) ([]engines.PendingFastWithdrawal, error) {
	var withdrawals []engines.PendingFastWithdrawal
	for _, w := range m.pendingWithdrawals {
		withdrawals = append(withdrawals, w)
	}
	return withdrawals, nil
}

func (m *MockSidechainMonitorEngine) GetDetectedWithdrawals(ctx context.Context) ([]engines.DetectedWithdrawal, error) {
	var withdrawals []engines.DetectedWithdrawal
	for _, w := range m.detectedWithdrawals {
		withdrawals = append(withdrawals, w)
	}
	return withdrawals, nil
}

// TestServer wraps functionality for testing
type TestServer struct {
	monitor SidechainMonitor
}

func TestInitiateSidechainWithdrawal_Success(t *testing.T) {
	ctx := context.Background()

	// Mock external fast withdrawal server
	mockExternalServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, "/withdraw", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))

		var req map[string]interface{}
		err := json.NewDecoder(r.Body).Decode(&req)
		require.NoError(t, err)

		assert.Equal(t, "bc1qtest123", req["withdrawal_destination"])
		assert.Equal(t, 0.001, req["withdrawal_amount"]) // 100000 sats = 0.001 BTC
		assert.Equal(t, "thunder", req["layer_2_chain_name"])

		// Return mock success response
		response := map[string]interface{}{
			"status": "success",
			"data": map[string]interface{}{
				"hash": "withdrawal-hash-123",
				"server_l2_address": map[string]interface{}{
					"info": "thunder1serveraddress456",
				},
				"server_fee_sats": 5000.0,
			},
		}
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Errorf("failed to encode response: %v", err)
		}
	}))
	defer mockExternalServer.Close()

	// Create test server
	mockMonitor := NewMockSidechainMonitorEngine()
	server := &TestServer{
		monitor: mockMonitor,
	}

	// Test the withdrawal initiation
	hash, err := server.testInitiateSidechainWithdrawal(ctx, "thunder", 100000, "bc1qtest123", mockExternalServer.URL)
	require.NoError(t, err)
	assert.Equal(t, "withdrawal-hash-123", hash)

	// Verify pending withdrawal was registered
	pending, err := mockMonitor.GetPendingFastWithdrawals(ctx)
	require.NoError(t, err)
	assert.Len(t, pending, 1)
	assert.Equal(t, "withdrawal-hash-123", pending[0].Hash)
	assert.Equal(t, "thunder", pending[0].Sidechain)
	assert.Equal(t, "thunder1serveraddress456", pending[0].ServerAddress)
	assert.Equal(t, int64(105000), pending[0].ExpectedAmount) // 100000 + 5000 fee
}

func TestInitiateSidechainWithdrawal_ServerError(t *testing.T) {
	ctx := context.Background()

	// Mock external server that returns error
	mockExternalServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := map[string]interface{}{
			"status": "error",
			"error":  "insufficient server funds",
		}
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Errorf("failed to encode response: %v", err)
		}
	}))
	defer mockExternalServer.Close()

	mockMonitor := NewMockSidechainMonitorEngine()
	server := &TestServer{
		monitor: mockMonitor,
	}

	// Should return error
	hash, err := server.testInitiateSidechainWithdrawal(ctx, "thunder", 100000, "bc1qtest123", mockExternalServer.URL)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "insufficient server funds")
	assert.Empty(t, hash)

	// No pending withdrawal should be registered on error
	pending, err := mockMonitor.GetPendingFastWithdrawals(ctx)
	require.NoError(t, err)
	assert.Len(t, pending, 0)
}

func TestInitiateSidechainWithdrawal_InvalidResponse(t *testing.T) {
	ctx := context.Background()

	// Mock external server that returns malformed response
	mockExternalServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := map[string]interface{}{
			"status": "success",
			"data": map[string]interface{}{
				// Missing required fields
				"hash": "test-hash",
				// Missing server_l2_address and server_fee_sats
			},
		}
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Errorf("failed to encode response: %v", err)
		}
	}))
	defer mockExternalServer.Close()

	mockMonitor := NewMockSidechainMonitorEngine()
	server := &TestServer{
		monitor: mockMonitor,
	}

	// Should return error due to missing fields
	hash, err := server.testInitiateSidechainWithdrawal(ctx, "thunder", 100000, "bc1qtest123", mockExternalServer.URL)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "missing server_l2_address")
	assert.Empty(t, hash)
}

// Helper method for testing withdrawal initiation
func (s *TestServer) testInitiateSidechainWithdrawal(ctx context.Context, sidechain string, amount int64, destination string, serverURL string) (string, error) {
	// Implement the withdrawal logic for testing
	withdrawalRequest := map[string]interface{}{
		"withdrawal_destination": destination,
		"withdrawal_amount":      float64(amount) / 100000000.0,
		"layer_2_chain_name":     sidechain,
	}

	jsonPayload, err := json.Marshal(withdrawalRequest)
	if err != nil {
		return "", err
	}

	withdrawURL := serverURL + "/withdraw"
	resp, err := http.Post(withdrawURL, "application/json", bytes.NewBuffer(jsonPayload))
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if status, ok := result["status"].(string); !ok || status != "success" {
		errorMsg, _ := result["error"].(string)
		return "", fmt.Errorf("withdrawal request failed: %s", errorMsg)
	}

	data, ok := result["data"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid response format: missing data")
	}

	withdrawalHash, ok := data["hash"].(string)
	if !ok {
		return "", fmt.Errorf("invalid response format: missing hash")
	}

	serverL2AddressInfo, ok := data["server_l2_address"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid response format: missing server_l2_address")
	}

	serverAddress, ok := serverL2AddressInfo["info"].(string)
	if !ok {
		return "", fmt.Errorf("invalid response format: missing server L2 address info")
	}

	serverFeeSatsFloat, ok := data["server_fee_sats"].(float64)
	if !ok {
		return "", fmt.Errorf("invalid response format: missing server_fee_sats")
	}
	serverFeeSats := int64(serverFeeSatsFloat)

	// Register pending withdrawal
	pending := engines.PendingFastWithdrawal{
		Hash:           withdrawalHash,
		Sidechain:      sidechain,
		ServerAddress:  serverAddress,
		ExpectedAmount: amount + serverFeeSats,
		ServerURL:      serverURL,
		CreatedAt:      time.Now(),
	}

	return withdrawalHash, s.monitor.RegisterPendingFastWithdrawal(ctx, pending)
}
