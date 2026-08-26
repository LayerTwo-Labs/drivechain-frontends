package orchestrator

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// A full-mode boot writes a chain. Without a directory of its own it writes to
// the platform default, over whatever the user already runs there, so the
// backend refuses rather than trusting every frontend to ask first.
func TestStartWithL1RefusesUntilTheNetworkHasADatadir(t *testing.T) {
	o := planFixture(t, "ecash")
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.True(t, o.PlanNetworkChange(NetworkChangeRequest{}).MustSelectDatadir)

	_, err := o.StartWithL1(context.Background(), "enforcer", StartOpts{})
	require.ErrorContains(t, err, "no data directory")
}

// With a directory chosen the gate is silent, and the boot runs as before.
func TestStartWithL1RunsOnceTheDatadirExists(t *testing.T) {
	o := planFixture(t, "ecash")
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.NoError(t, o.BitcoinConf.UpdateDataDir(t.TempDir(), config.NetworkECash))
	require.False(t, o.PlanNetworkChange(NetworkChangeRequest{}).MustSelectDatadir)

	_, err := o.StartWithL1(context.Background(), "enforcer", StartOpts{})
	if err != nil {
		require.NotContains(t, err.Error(), "no data directory")
	}
}
