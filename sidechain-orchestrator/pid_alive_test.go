//go:build !windows

package orchestrator

import (
	"os"
	"os/exec"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestIsPidAliveSpawnsNoProcess(t *testing.T) {
	t.Setenv("PATH", "")
	require.True(t, isPidAlive(os.Getpid()))
}

func TestIsPidAliveSeesAZombieAndAReapedChild(t *testing.T) {
	cmd := exec.Command("/bin/sh", "-c", "exit 0")
	require.NoError(t, cmd.Start())
	pid := cmd.Process.Pid
	require.Eventually(t, func() bool { return !isPidAlive(pid) }, 5*time.Second, 10*time.Millisecond, "zombie reads as alive")
	require.NoError(t, cmd.Wait())
	require.False(t, isPidAlive(pid))
}
