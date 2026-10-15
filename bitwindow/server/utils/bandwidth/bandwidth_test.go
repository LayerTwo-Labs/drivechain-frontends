package bandwidth_test

import (
	"os"
	"runtime"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/utils/bandwidth"
)

func TestGetStats(t *testing.T) {
	if runtime.GOOS != "linux" {
		t.Skip("rates come from /proc")
	}

	t.Run("first sample reports no rate", func(t *testing.T) {
		stats, err := bandwidth.NewTracker().GetStats(os.Getpid(), "test")
		require.NoError(t, err)
		assert.Zero(t, stats.RxBytesPerSec)
		assert.Zero(t, stats.TxBytesPerSec)
	})
}
