package bandwidth_test

import (
	"net"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/utils/bandwidth"
)

func TestGetStats(t *testing.T) {
	t.Run("no socket counts zero", func(t *testing.T) {
		stats, err := bandwidth.NewTracker().GetStats(os.Getpid(), "test")
		require.NoError(t, err)
		assert.Zero(t, stats.ConnectionCount)
	})

	t.Run("counts only the sockets of the process", func(t *testing.T) {
		listener, err := net.Listen("tcp", "127.0.0.1:0")
		require.NoError(t, err)
		t.Cleanup(func() { require.NoError(t, listener.Close()) })

		stats, err := bandwidth.NewTracker().GetStats(os.Getpid(), "test")
		require.NoError(t, err)
		assert.Equal(t, int32(1), stats.ConnectionCount)
		assert.Zero(t, stats.RxBytesPerSec)
		assert.Zero(t, stats.TotalRxBytes)
	})

	t.Run("refuses a bad PID", func(t *testing.T) {
		_, err := bandwidth.NewTracker().GetStats(0, "test")
		require.ErrorContains(t, err, "invalid PID")
	})
}
