package api

import (
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/stretchr/testify/require"
)

// Each network holds its own coinnews log, so a network swap does not mix the
// records of two chains in one file.
func TestCoinnewsLogPathFollowsTheNetworkDatadir(t *testing.T) {
	base := t.TempDir()

	conf := config.Config{Datadir: base}
	require.NoError(t, conf.Finalize(config.NetworkSignet))
	require.Equal(t, filepath.Join(base, "signet", "coinnews-sync.log"), coinnewsLogPath(conf))

	require.NoError(t, conf.Finalize(config.NetworkMainnet))
	require.Equal(t, filepath.Join(base, "mainnet", "coinnews-sync.log"), coinnewsLogPath(conf))
}
