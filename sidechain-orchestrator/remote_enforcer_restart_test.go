//go:build !windows

package orchestrator

import (
	"context"
	"net"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	"github.com/stretchr/testify/require"
)

func TestRemoteSidechainRestartsOwnedOrphans(t *testing.T) {
	for _, test := range []struct {
		name    string
		mode    NodeMode
		adopted bool
		orphan  bool
		owner   bool
		restart bool
		target  string
	}{
		{name: "owned light orphan", mode: NodeModeLight, adopted: true, orphan: true, owner: true, restart: true},
		{name: "same process", mode: NodeModeLight, owner: true},
		{name: "full mode", mode: NodeModeFull, adopted: true, orphan: true, owner: true},
		{name: "external process", mode: NodeModeLight, adopted: true, owner: true},
		{name: "no owner lock", mode: NodeModeLight, adopted: true, orphan: true},
		{name: "enforcer recovers owned orphan", mode: NodeModeLight, adopted: true, orphan: true, owner: true, restart: true, target: "enforcer"},
		{name: "enforcer keeps same process", mode: NodeModeLight, owner: true, target: "enforcer"},
		{name: "enforcer keeps external process", mode: NodeModeLight, adopted: true, owner: true, target: "enforcer"},
		{name: "enforcer has no owner lock", mode: NodeModeLight, adopted: true, orphan: true, target: "enforcer"},
	} {
		t.Run(test.name, func(t *testing.T) {
			server := remoteValidatorServer(t, 42, nil)
			o := remoteTestOrchestrator(t, server.URL)
			require.NoError(t, WriteNodeMode(o.BitwindowDir, test.mode))
			if test.owner {
				ownThisInstall(t, o)
			}
			cfg, env, argsPath := installRemoteTestDaemon(t, o)
			oldBridge, err := enforcerproxy.NewRemote(server.URL)
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, oldBridge.Close()) })
			oldArgs := []string{"--headless", "--mainchain-grpc-url=" + oldBridge.URL()}
			pid, err := o.process.StartWithOptions(context.Background(), cfg, oldArgs, env, ProcessStartOptions{ForceBackend: true})
			require.NoError(t, err)
			proc := o.process.Get(cfg.Name)
			o.process.mu.Lock()
			proc.Adopted = test.adopted
			proc.Orphan = test.orphan
			if test.adopted {
				proc.Cmd = nil
			}
			o.process.mu.Unlock()
			require.NoError(t, oldBridge.Close())

			listener, err := net.Listen("tcp", "127.0.0.1:0")
			require.NoError(t, err)
			guiEnv := make(map[string]string, len(env))
			for key, value := range env {
				guiEnv[key] = value
			}
			guiEnv["REMOTE_DAEMON_ADDR"] = listener.Addr().String()
			guiEnv["REMOTE_DAEMON_ARGS"] = filepath.Join(t.TempDir(), "gui-args")
			require.NoError(t, listener.Close())
			guiName := sidechainGUIProcessName(cfg.Name)
			guiPID, err := o.process.StartWithOptions(context.Background(), cfg, nil, guiEnv, ProcessStartOptions{
				ForceBackend: true,
				ProcessName:  guiName,
				PidName:      guiName,
			})
			require.NoError(t, err)
			t.Cleanup(func() {
				if o.process.IsRunning(guiName) {
					require.NoError(t, o.process.Stop(context.Background(), guiName, false))
				}
			})

			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			target := cfg.Name
			if test.target != "" {
				target = test.target
				saveRemoteTestEnv(t, o, cfg, env)
			}
			ch, err := o.StartWithL1(ctx, target, StartOpts{
				Immediate:    true,
				ForceBackend: true,
				TargetArgs:   oldArgs,
				TargetEnv:    env,
			})
			require.NoError(t, err)
			var complete int
			for progress := range ch {
				require.NoError(t, progress.Error)
				if progress.Done {
					complete++
				}
			}
			require.Equal(t, 1, complete)
			if target == cfg.Name || test.restart {
				require.True(t, o.Status(cfg.Name).Connected)
			}
			current := o.process.Get(cfg.Name)
			require.NotNil(t, current)
			if test.restart {
				require.NotEqual(t, pid, current.Pid)
				require.False(t, current.Adopted)
				endpoint, err := o.EnforcerURL()
				require.NoError(t, err)
				args, err := os.ReadFile(argsPath)
				require.NoError(t, err)
				require.Contains(t, string(args), "--mainchain-grpc-url="+endpoint)
				require.NotContains(t, string(args), oldBridge.URL())
			} else {
				require.Equal(t, pid, current.Pid)
			}
			require.Equal(t, guiPID, o.process.Get(guiName).Pid)
			require.True(t, alive(t, guiPID))
		})
	}
}

func saveRemoteTestEnv(t *testing.T, o *Orchestrator, cfg BinaryConfig, env map[string]string) {
	t.Helper()
	path := BinaryPath(o.DataDir, cfg.BinaryName)
	body, err := os.ReadFile(path)
	require.NoError(t, err)
	script := "#!/bin/sh\n"
	for key, value := range env {
		script += "export " + key + "='" + strings.ReplaceAll(value, "'", "'\\''") + "'\n"
	}
	script += strings.TrimPrefix(string(body), "#!/bin/sh\n")
	require.NoError(t, os.WriteFile(path, []byte(script), 0o755))
}

func TestRemoteEnforcerReportsOrphanRestartError(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	ownThisInstall(t, o)
	cfg, env, _ := installRemoteTestDaemon(t, o)
	_, err := o.process.StartWithOptions(context.Background(), cfg, []string{"--headless"}, env, ProcessStartOptions{ForceBackend: true})
	require.NoError(t, err)
	o.process.mu.Lock()
	proc := o.process.processes[cfg.Name]
	proc.Adopted = true
	proc.Orphan = true
	proc.Cmd = nil
	o.process.mu.Unlock()
	require.NoError(t, os.WriteFile(BinaryPath(o.DataDir, cfg.BinaryName), []byte("#!/bin/sh\nprintf 'test daemon failed\\n' >&2\nexit 1\n"), 0o755))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ch, err := o.StartWithL1(ctx, "enforcer", StartOpts{})
	require.NoError(t, err)
	var startErr error
	for progress := range ch {
		require.False(t, progress.Done)
		if progress.Error != nil {
			startErr = progress.Error
		}
	}
	require.ErrorContains(t, startErr, "thunder")
	require.ErrorContains(t, startErr, "test daemon failed")
	require.Contains(t, o.Status(cfg.Name).ConnectionError, "test daemon failed")
	require.True(t, o.Status("enforcer").Connected)
}
