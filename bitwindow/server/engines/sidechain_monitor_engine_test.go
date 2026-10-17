package engines

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"testing"

	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	notificationv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1"
)

// MockNotificationEngine for testing
type MockNotificationEngine struct {
	sentEvents []*notificationv1.WatchResponse
	noListener bool
}

func (m *MockNotificationEngine) Deliver(ctx context.Context, event *notificationv1.WatchResponse) int {
	if m.noListener {
		return 0
	}
	m.sentEvents = append(m.sentEvents, event)
	return 1
}

type fakeSidechainRPC struct {
	bundle string
}

func (f fakeSidechainRPC) PendingWithdrawalBundle(context.Context) (json.RawMessage, error) {
	return json.RawMessage(f.bundle), nil
}

func TestSidechainMonitorEngine_Monitor(t *testing.T) {
	t.Parallel()

	thunderBundle, err := os.ReadFile("testdata/thunder_pending_withdrawal_bundle.json")
	require.NoError(t, err)

	poll := func(t *testing.T, engine *SidechainMonitorEngine, bundle string) error {
		t.Helper()
		return engine.monitor(t.Context(), "thunder", func(context.Context) (sidechainRPC, error) {
			return fakeSidechainRPC{bundle: bundle}, nil
		})
	}

	t.Run("reads each payout of a thunder bundle", func(t *testing.T) {
		t.Parallel()

		sink := &MockNotificationEngine{}
		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, sink)
		require.NoError(t, poll(t, engine, string(thunderBundle)))

		first, err := engine.GetWithdrawalByTxid(t.Context(), "3c5d1c5f8f0b2a4e6d7c8b9a0f1e2d3c4b5a69788796a5b4c3d2e1f00112233a")
		require.NoError(t, err)
		require.NotNil(t, first)
		assert.Equal(t, "thunder", first.Sidechain)
		assert.Equal(t, int64(50000), first.Amount)
		assert.Equal(t, "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx", first.Destination)

		second, err := engine.GetWithdrawalByTxid(t.Context(), "9a8b7c6d5e4f30211203f4e5d6c7b8a99a8b7c6d5e4f30211203f4e5d6c7b8a9")
		require.NoError(t, err)
		require.NotNil(t, second)
		assert.Equal(t, int64(120000), second.Amount)

		assert.Len(t, sink.sentEvents, 2)
	})

	t.Run("a second poll of the same bundle reports nothing new", func(t *testing.T) {
		t.Parallel()

		sink := &MockNotificationEngine{}
		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, sink)
		require.NoError(t, poll(t, engine, string(thunderBundle)))
		require.NoError(t, poll(t, engine, string(thunderBundle)))

		assert.Len(t, sink.sentEvents, 2)
	})

	t.Run("a withdrawal found with no listener is reported later", func(t *testing.T) {
		t.Parallel()

		sink := &MockNotificationEngine{noListener: true}
		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, sink)
		require.NoError(t, poll(t, engine, string(thunderBundle)))
		withdrawals, err := engine.GetDetectedWithdrawals(t.Context())
		require.NoError(t, err)
		assert.Len(t, withdrawals, 2)

		sink.noListener = false
		require.NoError(t, poll(t, engine, string(thunderBundle)))
		require.NoError(t, poll(t, engine, string(thunderBundle)))
		assert.Len(t, sink.sentEvents, 2)
	})

	t.Run("no pending bundle clears the withdrawals", func(t *testing.T) {
		t.Parallel()

		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, &MockNotificationEngine{})
		require.NoError(t, poll(t, engine, string(thunderBundle)))
		require.NoError(t, poll(t, engine, "null"))

		withdrawals, err := engine.GetDetectedWithdrawals(t.Context())
		require.NoError(t, err)
		assert.Empty(t, withdrawals)
	})

	t.Run("two payouts of one tx stay two withdrawals", func(t *testing.T) {
		t.Parallel()

		sink := &MockNotificationEngine{}
		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, sink)
		payout := func(vout int, sats int) string {
			return fmt.Sprintf(`[{"Regular":{"txid":"bb","vout":%d}},{"address":"s","content":{"Withdrawal":{"value_sats":%d,"main_fee_sats":1,"main_address":"tb1q"}}}]`, vout, sats)
		}
		require.NoError(t, poll(t, engine, `{"spend_utxos":[`+payout(0, 1000)+`,`+payout(1, 2000)+`],"tx":{}}`))

		withdrawals, err := engine.GetDetectedWithdrawals(t.Context())
		require.NoError(t, err)
		require.Len(t, withdrawals, 2)
		amounts := lo.Map(withdrawals, func(w DetectedWithdrawal, _ int) int64 { return w.Amount })
		assert.ElementsMatch(t, []int64{1000, 2000}, amounts)
		assert.Len(t, sink.sentEvents, 2)
	})

	t.Run("a spend of a plain coin fails", func(t *testing.T) {
		t.Parallel()

		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, &MockNotificationEngine{})
		err := poll(t, engine, `{"spend_utxos":[[{"Regular":{"txid":"aa","vout":0}},{"address":"s","content":{"Value":1}}]],"tx":{}}`)
		require.ErrorContains(t, err, "not a withdrawal")
	})

	t.Run("a client error fails", func(t *testing.T) {
		t.Parallel()

		engine := NewSidechainMonitorEngine(nil, nil, nil, nil, nil, nil, &MockNotificationEngine{})
		err := engine.monitor(t.Context(), "photon", func(context.Context) (sidechainRPC, error) {
			return nil, errors.New("not running")
		})
		require.ErrorContains(t, err, "get photon client: not running")
	})
}
