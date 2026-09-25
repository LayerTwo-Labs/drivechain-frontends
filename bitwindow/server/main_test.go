package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
	"time"

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
func startedCommand(t *testing.T, script string) *exec.Cmd {
	t.Helper()
	cmd := exec.Command("sh", "-c", script)
	require.NoError(t, cmd.Start())
	return cmd
}

func testSupervisor(log *zerolog.Logger, start func(context.Context) (*exec.Cmd, error)) drivechaindSupervisor {
	return drivechaindSupervisor{
		start:       start,
		watchPort:   func(ctx context.Context) { <-ctx.Done() },
		restartWait: time.Millisecond,
		maxRestarts: 2,
		log:         log,
	}
}

func TestSupervisorLogsTheExitCode(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) { return nil, nil })
	supervisor.maxRestarts = 0
	supervisor.run(context.Background(), startedCommand(t, "exit 7"))

	require.Contains(t, out.String(), `"exit_code":7`)
	require.Contains(t, out.String(), "drivechaind exited")
}

// A kill must not leave the RPC port dead for the rest of the session.
func TestSupervisorStartsDrivechaindAgainAfterAKill(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	starts := 0
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) {
		starts++
		return startedCommand(t, "exit 0"), nil
	})
	supervisor.run(context.Background(), startedCommand(t, "kill -9 $$"))

	require.Equal(t, 2, starts, "the supervisor gave up before it reached the restart limit")
	require.Contains(t, out.String(), "its RPC port stays dead until BitWindow restarts")
}

// A shutdown bitwindowd asks for is not a crash.
func TestSupervisorLeavesADeliberateShutdownAlone(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	starts := 0
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) {
		starts++
		return startedCommand(t, "exit 0"), nil
	})
	supervisor.run(ctx, startedCommand(t, "exit 0"))

	require.Zero(t, starts, "the supervisor restarted drivechaind on a shutdown")
	require.Contains(t, out.String(), "bitwindowd stopped watching drivechaind")
}

// An adopted daemon has no handle to reap, so the port reports its exit.
func TestSupervisorWatchesThePortOfAnAdoptedDaemon(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	polls := 0
	starts := 0
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) {
		starts++
		return startedCommand(t, "exit 0"), nil
	})
	supervisor.watchPort = func(context.Context) { polls++ }
	supervisor.run(context.Background(), nil)

	require.Positive(t, polls, "the supervisor never watched the port of the adopted daemon")
	require.Positive(t, starts, "the supervisor never started drivechaind after the adopted one died")
	require.Contains(t, out.String(), `"owner":"adopted"`)
}

// An adoption during a restart keeps the watch alive on the port.
func TestSupervisorKeepsWatchingAfterItAdoptsAnotherInstance(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	polls := 0
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) { return nil, nil })
	supervisor.watchPort = func(context.Context) { polls++ }
	supervisor.run(context.Background(), startedCommand(t, "exit 1"))

	require.Positive(t, polls, "the supervisor dropped the watch after it adopted another instance")
}

func TestOrchestratorPortWatcherReturnsOnADeadPort(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	addr := "http://" + listener.Addr().String()
	require.NoError(t, listener.Close())

	done := make(chan struct{})
	go func() {
		orchestratorPortWatcher(addr, time.Millisecond)(context.Background())
		close(done)
	}()

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("the watcher never saw the dead port")
	}
}

func TestOrchestratorPortWatcherStaysOnALivePort(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	t.Cleanup(func() { _ = listener.Close() })
	go func() {
		for {
			conn, acceptErr := listener.Accept()
			if acceptErr != nil {
				return
			}
			_ = conn.Close()
		}
	}()

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()
	orchestratorPortWatcher("http://"+listener.Addr().String(), time.Millisecond)(ctx)

	require.Error(t, ctx.Err(), "the watcher gave up on a live port")
}

// A shutdown mid-start must not leave a detached daemon behind.
func TestSupervisorStopsADrivechaindStartedDuringAShutdown(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	ctx, cancel := context.WithCancel(context.Background())
	var orphan *exec.Cmd
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) {
		cancel()
		orphan = startedCommand(t, "sleep 30")
		return orphan, nil
	})
	supervisor.run(ctx, startedCommand(t, "exit 1"))

	require.NotNil(t, orphan)
	require.Contains(t, out.String(), "stopped the drivechaind started during the shutdown")
	require.False(t, orphan.ProcessState.Success(), "the supervisor left the detached daemon alive")
}

// The supervisor must return on a cancel, so realMain can join it before it
// relays the Shutdown RPC.
func TestSupervisorReturnsWhileDrivechaindStillRuns(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	ctx, cancel := context.WithCancel(context.Background())
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) { return nil, nil })
	alive := startedCommand(t, "sleep 30")

	done := make(chan struct{})
	go func() {
		defer close(done)
		supervisor.run(ctx, alive)
	}()
	cancel()

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("the supervisor blocked on a drivechaind that keeps running")
	}
	require.Contains(t, out.String(), "bitwindowd stopped watching drivechaind")
	require.NoError(t, alive.Process.Kill())
}

func TestSupervisorStopsOnAStartError(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test command is a POSIX shell")
	}
	out := &strings.Builder{}
	log := zerolog.New(out)

	starts := 0
	supervisor := testSupervisor(&log, func(context.Context) (*exec.Cmd, error) {
		starts++
		return nil, errors.New("drivechaind not found")
	})
	supervisor.run(context.Background(), startedCommand(t, "exit 1"))

	require.Equal(t, 1, starts)
	require.Contains(t, out.String(), "drivechaind restart failed")
}
