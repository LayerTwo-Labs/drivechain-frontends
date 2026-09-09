//go:build !windows

package orchestrator

import (
	"context"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func adoptModeTestDaemon(t *testing.T, o *Orchestrator, cfg BinaryConfig, env map[string]string) (BinaryConfig, *ManagedProcess, map[string]string) {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	cfg.Port = listener.Addr().(*net.TCPAddr).Port
	childEnv := make(map[string]string, len(env))
	for key, value := range env {
		childEnv[key] = value
	}
	childEnv["REMOTE_DAEMON_ADDR"] = listener.Addr().String()
	childEnv["REMOTE_DAEMON_ARGS"] = filepath.Join(t.TempDir(), "args")
	require.NoError(t, listener.Close())
	o.UpdateConfigs([]BinaryConfig{cfg})

	launcher, dir := newTestProcessManager(t)
	body, err := os.ReadFile(BinaryPath(o.DataDir, "thunder"))
	require.NoError(t, err)
	path := BinaryPath(dir, cfg.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, body, 0o755))
	pid, err := launcher.StartWithOptions(context.Background(), cfg, []string{"--headless"}, childEnv, ProcessStartOptions{ForceBackend: true})
	require.NoError(t, err)
	child := launcher.Get(cfg.Name)
	o.process.AdoptProcessResolved(cfg, pid, path, cfg.BinaryName, true)
	require.True(t, o.process.IsAdopted(cfg.Name))
	require.False(t, o.process.IsOrphan(cfg.Name))
	t.Cleanup(func() {
		if proc := o.process.Get(cfg.Name); proc != nil && proc.Pid == child.Pid {
			o.process.Remove(cfg.Name)
		}
	})
	return cfg, child, childEnv
}

func TestNodeModeKeepsExternalSidechain(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	ownThisInstall(t, o)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	cfg, env, _ := installRemoteTestDaemon(t, o)
	cfg, child, childEnv := adoptModeTestDaemon(t, o, cfg, env)
	saveRemoteTestEnv(t, o, cfg, childEnv)

	err := o.SetNodeMode(context.Background(), NodeModeLight)
	require.ErrorContains(t, err, "its own launcher")
	require.Equal(t, NodeModeFull, o.NodeMode())
	require.True(t, alive(t, child.Pid))
}

func TestNodeModeRejectsExternalStopsBeforeAnyStop(t *testing.T) {
	for _, test := range []struct {
		name string
		from NodeMode
		to   NodeMode
	}{
		{name: "thunder", from: NodeModeLight, to: NodeModeFull},
		{name: "enforcer", from: NodeModeFull, to: NodeModeLight},
		{name: "bitcoind", from: NodeModeFull, to: NodeModeLight},
	} {
		t.Run(test.name, func(t *testing.T) {
			server := remoteValidatorServer(t, 42, nil)
			o := remoteTestOrchestrator(t, server.URL)
			ownThisInstall(t, o)
			require.NoError(t, WriteNodeMode(o.BitwindowDir, test.from))
			require.NoError(t, o.SetDatadirForCurrentNetwork(t.TempDir()))
			cfg, env, _ := installRemoteTestDaemon(t, o)
			if test.name != cfg.Name {
				_, err := o.process.StartWithOptions(context.Background(), cfg, []string{"--headless"}, env, ProcessStartOptions{ForceBackend: true})
				require.NoError(t, err)
			}
			_, child, _ := adoptModeTestDaemon(t, o, o.Configs()[test.name], env)
			var stops int
			o.stopBinary = func(context.Context, string, bool, ...StopOptions) error {
				stops++
				return fmt.Errorf("test stop call")
			}
			err := o.SetNodeMode(context.Background(), test.to)
			require.Zero(t, stops)
			require.ErrorContains(t, err, test.name)
			require.ErrorContains(t, err, "its own launcher")
			require.Equal(t, test.from, o.NodeMode())
			require.True(t, alive(t, child.Pid))
		})
	}
}

func TestNodeModeFullKeepsExternalL1(t *testing.T) {
	for _, name := range []string{"enforcer", "bitcoind"} {
		t.Run(name, func(t *testing.T) {
			o := remoteTestOrchestrator(t, "")
			_, env, _ := installRemoteTestDaemon(t, o)
			_, child, _ := adoptModeTestDaemon(t, o, o.Configs()[name], env)
			require.NoError(t, o.SetNodeMode(context.Background(), NodeModeFull))
			require.Equal(t, NodeModeFull, o.NodeMode())
			require.True(t, alive(t, child.Pid))
		})
	}
}

func TestNodeModeLightStopsOwnedOrphans(t *testing.T) {
	for _, name := range []string{"thunder", "enforcer", "bitcoind"} {
		t.Run(name, func(t *testing.T) {
			server := remoteValidatorServer(t, 42, nil)
			o := remoteTestOrchestrator(t, server.URL)
			ownThisInstall(t, o)
			require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
			_, env, _ := installRemoteTestDaemon(t, o)
			cfg, child, childEnv := adoptModeTestDaemon(t, o, o.Configs()[name], env)
			require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, child.Pid))
			o.process.mu.Lock()
			o.process.processes[name].Orphan = true
			o.process.mu.Unlock()
			var guiPID int
			if cfg.ChainLayer == 2 {
				listener, err := net.Listen("tcp", "127.0.0.1:0")
				require.NoError(t, err)
				guiEnv := make(map[string]string, len(childEnv))
				for key, value := range childEnv {
					guiEnv[key] = value
				}
				guiEnv["REMOTE_DAEMON_ADDR"] = listener.Addr().String()
				guiEnv["REMOTE_DAEMON_ARGS"] = filepath.Join(t.TempDir(), "gui-args")
				require.NoError(t, listener.Close())
				guiName := sidechainGUIProcessName(name)
				guiPID, err = o.process.StartWithOptions(context.Background(), cfg, nil, guiEnv, ProcessStartOptions{
					ForceBackend: true,
					ProcessName:  guiName,
					PidName:      guiName,
				})
				require.NoError(t, err)
				saveRemoteTestEnv(t, o, cfg, childEnv)
				t.Cleanup(func() {
					if o.process.IsRunning(guiName) {
						require.NoError(t, o.process.Stop(context.Background(), guiName, false))
					}
				})
			}
			require.NoError(t, o.SetNodeMode(context.Background(), NodeModeLight))
			require.Equal(t, NodeModeLight, o.NodeMode())
			select {
			case <-child.ExitCh():
			case <-time.After(time.Second):
				t.Fatal("the owned orphan did not stop")
			}
			if cfg.ChainLayer == 2 {
				require.Eventually(t, func() bool {
					proc := o.process.Get(name)
					return proc != nil && proc.Pid != child.Pid && o.Status(name).Connected
				}, 5*time.Second, 10*time.Millisecond)
				require.True(t, alive(t, guiPID))
			}
		})
	}
}
