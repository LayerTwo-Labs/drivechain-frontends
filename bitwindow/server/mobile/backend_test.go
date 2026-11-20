package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/daemon"
	orchconfig "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

func fakeBackend(run func(ctx context.Context, args []string) error) *backend {
	return &backend{run: run}
}

func TestParseStartConfigReadsArgsAndEnv(t *testing.T) {
	cfg, err := parseStartConfig(`{"args":["--owner-pid=7"],"env":{"BITWINDOW_HOME":"/data"}}`)
	require.NoError(t, err)
	require.Equal(t, startConfig{Args: []string{"--owner-pid=7"}, Env: map[string]string{"BITWINDOW_HOME": "/data"}}, cfg)
}

func TestParseStartConfigRefusesBadJSON(t *testing.T) {
	_, err := parseStartConfig(`{"args":`)
	require.ErrorContains(t, err, "parse start config")
}

func TestStartSetsTheEnvAndPassesTheArgs(t *testing.T) {
	got := make(chan []string, 1)
	b := fakeBackend(func(ctx context.Context, args []string) error {
		got <- args
		<-ctx.Done()
		return nil
	})
	t.Setenv("BITWINDOW_TEST_KEY", "")

	require.NoError(t, b.start(`{"args":["--a","--b"],"env":{"BITWINDOW_TEST_KEY":"set"}}`))
	require.Equal(t, []string{"--a", "--b"}, <-got)
	require.Equal(t, "set", getenv(t, "BITWINDOW_TEST_KEY"))
	require.Equal(t, status{Running: true}, b.status())

	b.stop()
	require.NoError(t, b.wait(5*time.Second))
	require.Equal(t, status{}, b.status())
}

func TestStartRefusesASecondBackend(t *testing.T) {
	b := fakeBackend(func(ctx context.Context, _ []string) error {
		<-ctx.Done()
		return nil
	})
	require.NoError(t, b.start(`{}`))
	t.Cleanup(func() {
		b.stop()
		require.NoError(t, b.wait(5*time.Second))
	})

	require.ErrorContains(t, b.start(`{}`), "already runs")
}

func TestStatusReportsTheExitError(t *testing.T) {
	b := fakeBackend(func(context.Context, []string) error { return errors.New("listen refused") })

	require.NoError(t, b.start(`{}`))
	require.NoError(t, b.wait(5*time.Second))
	require.Equal(t, status{Error: "listen refused"}, b.status())

	require.NoError(t, b.start(`{}`), "an exited backend can start again")
	require.NoError(t, b.wait(5*time.Second))
}

func TestStatusBeforeAStartIsStopped(t *testing.T) {
	require.Equal(t, status{}, fakeBackend(nil).status())
}

func TestOrchestratorConfigMatchesTheChildProcessFlags(t *testing.T) {
	p := daemon.OrchestratorParams{BitwindowDir: "/data/bitwindow", ListenAddr: "localhost:30400", OwnerPID: 9}
	env := map[string]string{}
	cfg := orchestratorConfig(p, &bytes.Buffer{}, func(k string) string { return env[k] })

	require.Equal(t, "/data/bitwindow", cfg.DataDir)
	require.Equal(t, "/data/bitwindow", cfg.BitwindowDir)
	require.Equal(t, "localhost:30400", cfg.ListenAddr)
	require.Equal(t, orchconfig.DefaultNetwork, cfg.Network)
	require.Equal(t, 9, cfg.OwnerPID)
	require.True(t, cfg.LocalAuth)
	require.Nil(t, cfg.Exit, "an exit would end the app")

	require.Equal(t, orchconfig.RegtestEndpoints{}, cfg.Regtest)

	env["ORCHESTRATOR_LOCAL_AUTH"] = "0"
	require.False(t, orchestratorConfig(p, &bytes.Buffer{}, func(k string) string { return env[k] }).LocalAuth)
}

func TestOrchestratorConfigReadsTheRegtestServers(t *testing.T) {
	env := map[string]string{
		"ORCHESTRATOR_REGTEST_ESPLORA_URL":  "http://10.0.2.2:19460",
		"ORCHESTRATOR_REGTEST_ENFORCER_URL": "http://10.0.2.2:19450",
	}
	cfg := orchestratorConfig(daemon.OrchestratorParams{}, &bytes.Buffer{}, func(k string) string { return env[k] })

	require.Equal(t, orchconfig.RegtestEndpoints{
		EsploraURL:  "http://10.0.2.2:19460",
		EnforcerURL: "http://10.0.2.2:19450",
	}, cfg.Regtest)
}

func freePortOffset(t *testing.T) int {
	t.Helper()
	for offset := 6000; offset < 7500; offset += 37 {
		if portFree(30301+offset) && portFree(30400+offset) {
			return offset
		}
	}
	t.Fatal("no free port offset")
	return 0
}

func portFree(port int) bool {
	lis, err := net.Listen("tcp", net.JoinHostPort("127.0.0.1", strconv.Itoa(port)))
	if err != nil {
		return false
	}
	return lis.Close() == nil
}

func TestBitwindowdAndDrivechaindServeInOneProcess(t *testing.T) {
	if testing.Short() {
		t.Skip("boots the real daemons")
	}
	home := t.TempDir()
	offset := freePortOffset(t)
	t.Setenv("HOME", home)
	b := newBackend()

	raw := fmt.Sprintf(`{"args":["--datadir=%s"],"env":{"BITWINDOW_HOME":%q,"BITWINDOW_PORT_OFFSET":"%d"}}`,
		filepath.Join(home, "bitwindow"), home, offset)
	require.NoError(t, b.start(raw))

	for _, port := range []int{30400 + offset, 30301 + offset} {
		addr := net.JoinHostPort("localhost", strconv.Itoa(port))
		require.Eventually(t, func() bool {
			conn, err := net.DialTimeout("tcp", addr, 200*time.Millisecond)
			if err != nil {
				return false
			}
			return conn.Close() == nil
		}, 60*time.Second, 100*time.Millisecond, "nothing serves %s: %+v", addr, b.status())
	}
	require.Equal(t, status{Running: true}, b.status())

	b.stop()
	require.NoError(t, b.wait(60*time.Second))
	require.Equal(t, status{}, b.status())
	require.True(t, portFree(30400+offset), "drivechaind must free its port")
	require.True(t, portFree(30301+offset), "bitwindowd must free its port")
}

func getenv(t *testing.T, key string) string {
	t.Helper()
	value, ok := os.LookupEnv(key)
	require.True(t, ok)
	return value
}
