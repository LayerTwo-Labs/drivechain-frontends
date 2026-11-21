package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/jessevdk/go-flags"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/instance"
)

// The GUI (and the e2e harness) isolate runs via the BITWINDOWD_DATADIR env
// var. bitwindowd must honor it so its datadir — and thus the .auth.cookie the
// orchestrator writes beside wallet.json — lands where the frontend reads it.
func TestDatadirFromEnv(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("BITWINDOWD_DATADIR", dir)

	var conf Config
	_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{})
	require.NoError(t, err)
	require.Equal(t, dir, conf.Datadir)
}

func TestBitwindowDirSurvivesFinalize(t *testing.T) {
	base := t.TempDir()
	conf := Config{Datadir: base}

	require.Equal(t, base, conf.BitwindowDir())
	require.NoError(t, conf.Finalize(NetworkSignet))
	require.Equal(t, filepath.Join(base, string(NetworkSignet)), conf.Datadir)
	require.Equal(t, base, conf.BitwindowDir())
}

func TestPprofAddr(t *testing.T) {
	t.Run("off by default", func(t *testing.T) {
		var conf Config
		_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{})
		require.NoError(t, err)
		require.Empty(t, conf.PprofAddr)
	})

	t.Run("set by flag", func(t *testing.T) {
		var conf Config
		_, err := flags.NewParser(&conf, flags.Default).ParseArgs([]string{"--pprof.addr=localhost:6060"})
		require.NoError(t, err)
		require.Equal(t, "localhost:6060", conf.PprofAddr)
	})
}

func TestAddressesWithNoPortOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "")
	unsetEnv(t, "API_HOST")
	conf, err := ParseArgs(nil)
	require.NoError(t, err)
	require.Equal(t, "localhost:30301", conf.APIHost)
	require.Equal(t, "http://localhost:30400", conf.OrchestratorAddr)
	require.Equal(t, "localhost:50051", conf.EnforcerHost)
	require.Equal(t, "localhost:8122", conf.EnforcerJSONRPCAddr)
	require.Equal(t, "localhost:6009", conf.ThunderAddr)
	require.Equal(t, "localhost:6255", conf.CoinshiftAddr)
}

func TestAddressesWithPortOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	unsetEnv(t, "API_HOST")
	conf, err := ParseArgs(nil)
	require.NoError(t, err)
	require.Equal(t, "localhost:31301", conf.APIHost)
	require.Equal(t, "http://localhost:31400", conf.OrchestratorAddr)
	require.Equal(t, "localhost:51051", conf.EnforcerHost)
	require.Equal(t, "localhost:9122", conf.EnforcerJSONRPCAddr)
	require.Equal(t, "localhost:7009", conf.ThunderAddr)
	require.Equal(t, "localhost:7002", conf.BitnamesAddr)
	require.Equal(t, "localhost:7004", conf.BitassetsAddr)
	require.Equal(t, "localhost:7013", conf.TruthcoinAddr)
	require.Equal(t, "localhost:7099", conf.PhotonAddr)
	require.Equal(t, "localhost:7255", conf.CoinshiftAddr)
}

// A flag wins over the offset.
func TestAddressFlagWithPortOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	unsetEnv(t, "API_HOST")
	conf, err := ParseArgs([]string{"--api.host=localhost:40000"})
	require.NoError(t, err)
	require.Equal(t, "localhost:40000", conf.APIHost)
}

func TestBadPortOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "many")
	_, err := ParseArgs(nil)
	require.ErrorContains(t, err, instance.PortOffsetEnv)
}

func TestDatadirFollowsBitwindowHome(t *testing.T) {
	home := t.TempDir()
	t.Setenv(instance.HomeEnv, home)
	unsetEnv(t, "BITWINDOWD_DATADIR")
	unsetEnv(t, "XDG_DATA_HOME")
	conf, err := ParseArgs(nil)
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(conf.Datadir, home+string(filepath.Separator)), conf.Datadir)
}

func unsetEnv(t *testing.T, key string) {
	t.Helper()
	t.Setenv(key, "")
	require.NoError(t, os.Unsetenv(key))
}

func TestLinuxDatadirIgnoresXDGWithBitwindowHome(t *testing.T) {
	home := t.TempDir()
	t.Setenv(instance.HomeEnv, home)
	t.Setenv("XDG_DATA_HOME", t.TempDir())
	unsetEnv(t, "BITWINDOWD_DATADIR")
	conf, err := ParseArgs(nil)
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(conf.Datadir, home+string(filepath.Separator)), conf.Datadir)
}
