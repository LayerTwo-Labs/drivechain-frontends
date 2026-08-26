package orchestrator

import (
	"errors"
	"fmt"
	"net"
	"syscall"
	"testing"

	"github.com/stretchr/testify/require"
)

// A stop RPC that never landed must skip the graceful wait. A stop RPC that
// may have landed must not: bitcoind answers `stop`, then drops the connection
// while it flushes, and a signal there can corrupt on-disk state.
func TestUnreachableTellsAMissedStopFromAFlushingDaemon(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{"no error", nil, false},
		{"no client", fmt.Errorf("bitcoind RPC stop: %w: down", errNoStopClient), true},
		{"connection refused", fmt.Errorf("stop: %w", syscall.ECONNREFUSED), true},
		{"dial failed", &net.OpError{Op: "dial", Err: errors.New("no route")}, true},
		{"read after the ack", &net.OpError{Op: "read", Err: errors.New("reset by peer")}, false},
		{"timeout", errors.New("stop: context deadline exceeded"), false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			require.Equal(t, tt.want, unreachable(tt.err))
		})
	}
}
