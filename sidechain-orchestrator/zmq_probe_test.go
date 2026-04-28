package orchestrator

import (
	"context"
	"net"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExtractZmqSequenceAddr(t *testing.T) {
	cases := []struct {
		name string
		args []string
		want string
	}{
		{
			name: "flag with equals and tcp scheme",
			args: []string{"--node-rpc-addr=127.0.0.1:8332", "--node-zmq-addr-sequence=tcp://127.0.0.1:29000"},
			want: "127.0.0.1:29000",
		},
		{
			name: "flag without scheme",
			args: []string{"--node-zmq-addr-sequence=127.0.0.1:29000"},
			want: "127.0.0.1:29000",
		},
		{
			name: "flag absent",
			args: []string{"--node-rpc-addr=127.0.0.1:8332"},
			want: "",
		},
		{
			name: "no args",
			args: nil,
			want: "",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, extractZmqSequenceAddr(tc.args))
		})
	}
}

// A reachable socket should make the probe return immediately on the first
// dial — no retry loop, no error.
func TestWaitForZmqReachable_Reachable(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer listener.Close() //nolint:errcheck

	log := zerolog.Nop()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	require.NoError(t, waitForZmqReachable(ctx, listener.Addr().String(), &log))
}

// If the context cancels mid-retry we surface the cancel — no point in
// completing the full retry budget while the orchestrator is shutting down.
func TestWaitForZmqReachable_ContextCancel(t *testing.T) {
	log := zerolog.Nop()
	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	err := waitForZmqReachable(ctx, "127.0.0.1:1", &log)
	require.Error(t, err)
}
