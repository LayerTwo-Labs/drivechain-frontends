//go:build !windows

package orchestrator

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestECashMigrationChecksDependentOwnership(t *testing.T) {
	for _, owner := range []bool{false, true} {
		for _, name := range []string{"thunder", "enforcer", "thunder-gui"} {
			t.Run(fmt.Sprintf("%s/owned=%t", name, owner), func(t *testing.T) {
				o := migrationTestNode(t)
				ownThisInstall(t, o)
				o.coreReachable = func() bool { return false }
				cfg, env, _ := installRemoteTestDaemon(t, o)
				owned, err := o.getConfig("bitnames")
				require.NoError(t, err)
				body, err := os.ReadFile(BinaryPath(o.DataDir, cfg.BinaryName))
				require.NoError(t, err)
				path := BinaryPath(o.DataDir, owned.BinaryName)
				require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
				require.NoError(t, os.WriteFile(path, body, 0o755))
				ownedPID, err := o.process.StartWithOptions(context.Background(), owned, nil, env, ProcessStartOptions{ForceBackend: true})
				require.NoError(t, err)
				t.Cleanup(func() {
					if o.process.IsRunning(owned.Name) {
						require.NoError(t, o.process.Stop(context.Background(), owned.Name, true))
					}
					require.True(t, o.process.WaitForExit(owned.Name, 5*time.Second))
				})
				if name == "enforcer" {
					var err error
					cfg, err = o.getConfig(name)
					require.NoError(t, err)
				}
				cfg, child, _ := adoptModeTestDaemon(t, o, cfg, env)
				if name == "thunder-gui" {
					o.process.Remove(cfg.Name)
					cfg.Name = name
					o.process.AdoptProcessResolved(cfg, child.Pid, child.BinPath, child.PidName, true)
					t.Cleanup(func() { o.process.Remove(name) })
				}
				if owner {
					o.process.Remove(name)
					require.NoError(t, o.pidManager.WritePidFile(name, child.Pid))
					o.process.AdoptProcessResolved(cfg, child.Pid, child.BinPath, name, true)
				}
				require.True(t, o.process.IsAdopted(name))
				require.Equal(t, owner, o.mayStopAdopted(name))
				ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
				defer cancel()

				err = o.stopMigrationNodes(ctx)

				if owner {
					require.NoError(t, err)
					require.Eventually(t, func() bool {
						return !alive(t, child.Pid) && !alive(t, ownedPID)
					}, 5*time.Second, 25*time.Millisecond)
				} else {
					require.ErrorContains(t, err, "its own launcher")
					require.True(t, alive(t, child.Pid))
					require.True(t, alive(t, ownedPID))
				}
			})
		}
	}
}
