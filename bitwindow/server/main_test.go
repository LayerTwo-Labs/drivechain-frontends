package main

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExitError(t *testing.T) {
	assert.NoError(t, exitError(nil))
	assert.NoError(t, exitError(http.ErrServerClosed))
	assert.NoError(t, exitError(fmt.Errorf("serve: %w", http.ErrServerClosed)))

	boom := errors.New("listen on \"127.0.0.1:8080\": address already in use")
	assert.ErrorIs(t, exitError(boom), boom)
}

// A user who passes --log.path gets the whole merged stream in that file.
func TestDrivechaindLogPathFollowsTheConfiguredPath(t *testing.T) {
	chosen := filepath.Join("/data", "my.log")

	require.Equal(t, chosen, drivechaindLogPath(config.Config{LogPath: chosen}, "/data/bitwindow"))
	require.Equal(t,
		filepath.Join("/data/bitwindow", "bitwindow.log"),
		drivechaindLogPath(config.Config{}, "/data/bitwindow"),
	)
}

// The spawn of drivechaind happens before initLogger, and a user who sends us
// the log file must get the reason it failed.
func TestBootLogWriterTagsTheSharedFile(t *testing.T) {
	path := filepath.Join(t.TempDir(), "sub", "bitwindow.log")

	log := zerolog.New(bootLogWriter(path, io.Discard)).With().Timestamp().Logger()
	log.Info().Msg("starting drivechaind (detached)")

	written, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Contains(t, string(written), "[bitwindowd]")
	require.Contains(t, string(written), "starting drivechaind (detached)")
}

func TestBootLogWriterKeepsTheConsoleOnAnUnwritablePath(t *testing.T) {
	dir := t.TempDir()
	blocker := filepath.Join(dir, "file")
	require.NoError(t, os.WriteFile(blocker, nil, 0o644))
	console := &strings.Builder{}

	log := zerolog.New(bootLogWriter(filepath.Join(blocker, "deeper.log"), console))
	log.Info().Msg("boot line")

	require.Contains(t, console.String(), "boot line")
}

// A dead drivechaind leaves bitwindowd serving on a port nothing answers, so
// the exit code is the one clue the log holds.
func TestWatchDrivechaindLogsTheExitCode(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	cmd := exec.Command("sh", "-c", "exit 7")
	require.NoError(t, cmd.Start())
	watchDrivechaind(cmd, &log)

	require.Contains(t, out.String(), `"exit_code":7`)
	require.Contains(t, out.String(), "drivechaind exited")
}
