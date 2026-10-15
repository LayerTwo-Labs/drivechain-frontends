package api

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
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

func TestRuntimeCloseClosesTheCoinnewsLog(t *testing.T) {
	conf := config.Config{Datadir: t.TempDir(), BitcoinCoreNetwork: config.NetworkRegtest}
	s := &Server{svcs: Services{Database: database.Test(t), WalletDir: t.TempDir()}}

	rt, err := s.buildRuntime(t.Context(), conf, "")
	require.NoError(t, err)
	require.NotNil(t, rt.coinnewsLog)

	rt.ctx = t.Context()
	rt.Close()

	_, err = rt.coinnewsLog.WriteString("x")
	require.ErrorIs(t, err, os.ErrClosed)
}
