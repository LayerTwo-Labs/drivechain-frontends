package apitests_test

import (
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
)

// drivechaind reports when a binary starts or stops, so an idle bitwindowd
// dials no service on a timer.
func TestIdleServerDialsNoService(t *testing.T) {
	t.Parallel()

	var dials atomic.Int32
	apitests.API(t, database.Test(t), apitests.WithDialCount(&dials))

	time.Sleep(time.Second)
	before := dials.Load()
	time.Sleep(2 * time.Second)
	require.Equal(t, before, dials.Load())
}
