package main

import (
	"sync"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestChangeGateReportsOneCauseOneTime(t *testing.T) {
	gate := &changeGate{}

	require.True(t, gate.fires("no cookie"))
	require.False(t, gate.fires("no cookie"))
	require.False(t, gate.fires("no cookie"))
}

func TestChangeGateReportsEveryNewCause(t *testing.T) {
	gate := &changeGate{}

	require.True(t, gate.fires("no cookie"))
	require.True(t, gate.fires("bad rpcuser"))
	require.False(t, gate.fires("bad rpcuser"))
	require.True(t, gate.fires("no cookie"))
}

// The first call reports even when the state is the zero value, so a recovery
// after a failure still gets one line.
func TestChangeGateReportsTheEmptyStateFirst(t *testing.T) {
	gate := &changeGate{}

	require.True(t, gate.fires(""))
	require.False(t, gate.fires(""))
	require.True(t, gate.fires("no cookie"))
	require.True(t, gate.fires(""))
}

func TestChangeGateHoldsUnderConcurrentCalls(t *testing.T) {
	gate := &changeGate{}

	var mu sync.Mutex
	fired := 0
	var wg sync.WaitGroup
	for range 100 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if gate.fires("no cookie") {
				mu.Lock()
				fired++
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	require.Equal(t, 1, fired, "the gate reported one cause more than one time")
}
