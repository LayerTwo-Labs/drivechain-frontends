package instance

import (
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestHomeUnset(t *testing.T) {
	t.Setenv(HomeEnv, "")
	require.Empty(t, Home())

	want, err := os.UserHomeDir()
	require.NoError(t, err)
	got, err := UserHome()
	require.NoError(t, err)
	require.Equal(t, want, got)
}

func TestHomeSet(t *testing.T) {
	dir := t.TempDir()
	t.Setenv(HomeEnv, dir)
	require.Equal(t, dir, Home())

	got, err := UserHome()
	require.NoError(t, err)
	require.Equal(t, dir, got)
}

func TestPortUnset(t *testing.T) {
	t.Setenv(PortOffsetEnv, "")
	offset, err := PortOffset()
	require.NoError(t, err)
	require.Zero(t, offset)
	require.Equal(t, 30301, Port(30301))
	require.Equal(t, "localhost:30400", Addr("localhost", 30400))
}

func TestPortSet(t *testing.T) {
	t.Setenv(PortOffsetEnv, "1000")
	offset, err := PortOffset()
	require.NoError(t, err)
	require.Equal(t, 1000, offset)
	require.Equal(t, 31301, Port(30301))
	require.Equal(t, 51051, Port(50051))
	require.Equal(t, "127.0.0.1:19443", Addr("127.0.0.1", 18443))
}

func TestPortZeroBaseStaysZero(t *testing.T) {
	t.Setenv(PortOffsetEnv, "1000")
	require.Zero(t, Port(0))
}

func TestPortOffsetBadValue(t *testing.T) {
	for _, raw := range []string{"abc", "-1", "7501", "1.5"} {
		t.Run(raw, func(t *testing.T) {
			t.Setenv(PortOffsetEnv, raw)
			_, err := PortOffset()
			require.ErrorContains(t, err, PortOffsetEnv)
			require.Panics(t, func() { Port(30301) })
		})
	}
}

func TestIsolated(t *testing.T) {
	t.Setenv(HomeEnv, "")
	t.Setenv(PortOffsetEnv, "")
	require.False(t, Isolated())

	t.Setenv(PortOffsetEnv, "1")
	require.True(t, Isolated())

	t.Setenv(PortOffsetEnv, "")
	t.Setenv(HomeEnv, t.TempDir())
	require.True(t, Isolated())
}

func TestEnvironNoHome(t *testing.T) {
	t.Setenv("HOME", "/home/user")
	require.Equal(t, os.Environ(), Environ(""))
}

func TestEnvironHome(t *testing.T) {
	t.Setenv("HOME", "/home/user")
	t.Setenv(HomeEnv, "/old")
	t.Setenv("XDG_DATA_HOME", "/xdg")
	env := Environ("/instance")
	require.NotContains(t, env, "XDG_DATA_HOME=/xdg")
	require.Contains(t, env, "APPDATA="+filepath.Join("/instance", "AppData", "Roaming"))
	require.Contains(t, env, "HOME=/instance")
	require.Contains(t, env, HomeEnv+"=/instance")
	require.NotContains(t, env, "HOME=/home/user")
	require.NotContains(t, env, HomeEnv+"=/old")
}

const childEnv = "INSTANCE_TEST_CHILD"

// TestChildProcess runs this test binary as a child and reads the settings there.
func TestChildProcess(t *testing.T) {
	if os.Getenv(childEnv) == "1" {
		home, err := UserHome()
		if err != nil {
			os.Exit(2)
		}
		if _, err := os.Stdout.WriteString(home + " " + Addr("127.0.0.1", 30400) + " " + os.Getenv("HOME")); err != nil {
			os.Exit(3)
		}
		os.Exit(0)
	}

	home := t.TempDir()
	t.Setenv(PortOffsetEnv, "2000")
	cmd := exec.Command(os.Args[0], "-test.run=^TestChildProcess$")
	cmd.Env = append(Environ(home), childEnv+"=1")
	out, err := cmd.Output()
	require.NoError(t, err)
	require.Equal(t, []string{home, "127.0.0.1:32400", home}, strings.Fields(string(out)))
	require.True(t, slices.Contains(cmd.Env, PortOffsetEnv+"=2000"))
}
