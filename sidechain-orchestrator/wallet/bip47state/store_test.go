package bip47state_test

import (
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

func TestReserveNextIndex_Sequential(t *testing.T) {
	dir := t.TempDir()
	st := bip47state.NewStore(dir)

	for want := uint32(0); want < 5; want++ {
		got, err := st.ReserveNextIndex("w1", "PMtest")
		require.NoError(t, err)
		assert.Equal(t, want, got)
	}

	state, err := st.GetState("w1", "PMtest")
	require.NoError(t, err)
	require.NotNil(t, state)
	assert.Equal(t, uint32(5), state.NextSendIndex)
}

func TestReserveNextIndex_Concurrent(t *testing.T) {
	dir := t.TempDir()
	st := bip47state.NewStore(dir)

	const goroutines = 16
	const perGoroutine = 8

	var wg sync.WaitGroup
	wg.Add(goroutines)

	results := make(chan uint32, goroutines*perGoroutine)
	for g := 0; g < goroutines; g++ {
		go func() {
			defer wg.Done()
			for i := 0; i < perGoroutine; i++ {
				idx, err := st.ReserveNextIndex("w1", "PMtest")
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

func TestPersistenceAcrossReopen(t *testing.T) {
	dir := t.TempDir()
	st := bip47state.NewStore(dir)

	_, err := st.ReserveNextIndex("w1", "PMtest")
	require.NoError(t, err)
	_, err = st.ReserveNextIndex("w1", "PMtest")
	require.NoError(t, err)
	require.NoError(t, st.MarkNotified("w1", "PMtest", "abc"))

	// Reopen and verify state survives.
	st2 := bip47state.NewStore(dir)
	got, err := st2.GetState("w1", "PMtest")
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, uint32(2), got.NextSendIndex)
	require.NotNil(t, got.NotificationTxID)
	assert.Equal(t, "abc", *got.NotificationTxID)

	idx, err := st2.ReserveNextIndex("w1", "PMtest")
	require.NoError(t, err)
	assert.Equal(t, uint32(2), idx)
}

func TestDistinctRecipients(t *testing.T) {
	dir := t.TempDir()
	st := bip47state.NewStore(dir)

	_, err := st.ReserveNextIndex("w1", "PMtest1")
	require.NoError(t, err)
	_, err = st.ReserveNextIndex("w1", "PMtest1")
	require.NoError(t, err)
	_, err = st.ReserveNextIndex("w1", "PMtest2")
	require.NoError(t, err)

	s1, err := st.GetState("w1", "PMtest1")
	require.NoError(t, err)
	require.NotNil(t, s1)
	assert.Equal(t, uint32(2), s1.NextSendIndex)

	s2, err := st.GetState("w1", "PMtest2")
	require.NoError(t, err)
	require.NotNil(t, s2)
	assert.Equal(t, uint32(1), s2.NextSendIndex)
}
