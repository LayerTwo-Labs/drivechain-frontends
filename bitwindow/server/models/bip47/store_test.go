package bip47_test

import (
	"context"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bip47"
)

func TestReserveNextIndex_Sequential(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	for want := uint32(0); want < 5; want++ {
		got, err := bip47.ReserveNextIndex(ctx, db, "w1", "PMtest")
		require.NoError(t, err)
		assert.Equal(t, want, got)
	}

	state, err := bip47.GetState(ctx, db, "w1", "PMtest")
	require.NoError(t, err)
	require.NotNil(t, state)
	assert.Equal(t, uint32(5), state.NextSendIndex)
}

func TestReserveNextIndex_Concurrent(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	const goroutines = 16
	const perGoroutine = 8

	var wg sync.WaitGroup
	wg.Add(goroutines)

	results := make(chan uint32, goroutines*perGoroutine)
	for g := 0; g < goroutines; g++ {
		go func() {
			defer wg.Done()
			for i := 0; i < perGoroutine; i++ {
				idx, err := bip47.ReserveNextIndex(ctx, db, "w1", "PMtest")
				if err != nil {
					t.Errorf("ReserveNextIndex: %v", err)
					return
				}
				results <- idx
			}
		}()
	}
	wg.Wait()
	close(results)

	seen := make(map[uint32]bool, goroutines*perGoroutine)
	for idx := range results {
		if seen[idx] {
			t.Fatalf("index %d was reserved twice", idx)
		}
		seen[idx] = true
	}

	for i := uint32(0); i < goroutines*perGoroutine; i++ {
		assert.True(t, seen[i], "expected index %d to be reserved exactly once", i)
	}
}

func TestMarkNotifiedAndGetState(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	state, err := bip47.GetState(ctx, db, "w1", "PMtest")
	require.NoError(t, err)
	assert.Nil(t, state)

	require.NoError(t, bip47.MarkNotified(ctx, db, "w1", "PMtest", "abc123"))

	state, err = bip47.GetState(ctx, db, "w1", "PMtest")
	require.NoError(t, err)
	require.NotNil(t, state)
	require.NotNil(t, state.NotificationTxID)
	assert.Equal(t, "abc123", *state.NotificationTxID)
	require.NotNil(t, state.NotificationBroadcastAt)
	assert.Equal(t, uint32(0), state.NextSendIndex)

	// MarkNotified should be idempotent and not reset next_send_index when a
	// counter has already advanced.
	_, err = bip47.ReserveNextIndex(ctx, db, "w1", "PMtest")
	require.NoError(t, err)
	_, err = bip47.ReserveNextIndex(ctx, db, "w1", "PMtest")
	require.NoError(t, err)

	require.NoError(t, bip47.MarkNotified(ctx, db, "w1", "PMtest", "def456"))

	state, err = bip47.GetState(ctx, db, "w1", "PMtest")
	require.NoError(t, err)
	require.NotNil(t, state)
	require.NotNil(t, state.NotificationTxID)
	assert.Equal(t, "def456", *state.NotificationTxID)
	assert.Equal(t, uint32(2), state.NextSendIndex)
}

func TestGetState_DistinctRecipients(t *testing.T) {
	db := database.Test(t)
	ctx := context.Background()

	_, err := bip47.ReserveNextIndex(ctx, db, "w1", "PMtest1")
	require.NoError(t, err)
	_, err = bip47.ReserveNextIndex(ctx, db, "w1", "PMtest1")
	require.NoError(t, err)
	_, err = bip47.ReserveNextIndex(ctx, db, "w1", "PMtest2")
	require.NoError(t, err)

	s1, err := bip47.GetState(ctx, db, "w1", "PMtest1")
	require.NoError(t, err)
	require.NotNil(t, s1)
	assert.Equal(t, uint32(2), s1.NextSendIndex)

	s2, err := bip47.GetState(ctx, db, "w1", "PMtest2")
	require.NoError(t, err)
	require.NotNil(t, s2)
	assert.Equal(t, uint32(1), s2.NextSendIndex)
}
