package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// fakeCoreFixture puts a file where both the download manager and the process
// manager look for bitcoind, so a boot runs that file and downloads nothing.
func fakeCoreFixture(t *testing.T, binary string) *Orchestrator {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skip("the fake Core binary is a shell script")
	}

	o := planFixture(t, "signet")

	// A name of its own keeps the PID lookup by name away from every other
	// bitcoind on the machine.
	cfg := o.configs["bitcoind"]
	cfg.BinaryName = "bitcoind-" + strings.ToLower(strings.ReplaceAll(t.Name(), "/", "-"))
	o.configs["bitcoind"] = cfg

	target := o.download.ResolveTarget(cfg, o.Network, DownloadOptions{})
	require.NoError(t, os.MkdirAll(filepath.Dir(target.BinPath), 0o755))
	require.NoError(t, os.WriteFile(target.BinPath, []byte(binary), 0o755)) //nolint:gosec // a test daemon must be executable

	t.Cleanup(func() {
		_ = o.process.StopAll(context.Background(), true)
		o.StopAllMonitors()
	})
	return o
}

// writeCorePidFile writes the native PID file that discoverPid reads.
func writeCorePidFile(t *testing.T, o *Orchestrator, pid int) {
	t.Helper()
	require.NoError(t, os.MkdirAll(o.BitcoinConf.DataDir(), 0o755))
	pidPath := filepath.Join(o.BitcoinConf.DataDir(), "bitcoind.pid")
	require.NoError(t, os.WriteFile(pidPath, []byte(strconv.Itoa(pid)), 0o644))
}

// coreLookalike starts a live process that carries the Core binary name, so
// the PID checks read it as a bitcoind.
func coreLookalike(t *testing.T, o *Orchestrator) int {
	t.Helper()
	sleepPath, err := exec.LookPath("sleep")
	require.NoError(t, err)
	link := filepath.Join(t.TempDir(), o.configs["bitcoind"].BinaryName)
	require.NoError(t, os.Symlink(sleepPath, link))

	proc := exec.Command(link, "30")
	require.NoError(t, proc.Start())
	t.Cleanup(func() {
		_ = proc.Process.Kill()
		_ = proc.Wait()
	})
	return proc.Process.Pid
}

// externalCore starts a stand-in for the bitcoind another unit runs on our
// datadir, and names it in the native PID file.
func externalCore(t *testing.T, o *Orchestrator) int {
	t.Helper()
	pid := coreLookalike(t, o)
	writeCorePidFile(t, o, pid)
	return pid
}

// coldChecker fails the given number of health checks, then answers healthy.
// It stands for the ping that loses while Core rescans a wallet.
type coldChecker struct{ cold atomic.Int32 }

func (c *coldChecker) Check(_ context.Context) error {
	if c.cold.Add(-1) >= 0 {
		return errors.New("bitcoind answers no RPC yet")
	}
	return nil
}

// bootSink buffers a boot's progress events. Read it with failures once the
// boot returned.
type bootSink chan StartupProgress

func newBootSink() bootSink { return make(bootSink, 64) }

// failures returns the error of every event the boot reported.
func (s bootSink) failures(t *testing.T) []string {
	t.Helper()
	close(s)
	var msgs []string
	for p := range s {
		if p.Error != nil {
			msgs = append(msgs, p.Error.Error())
		}
	}
	return msgs
}

const lockConflictError = "bitcoind exited immediately (code 1): exit status 1\n" +
	"stderr: Error: Cannot obtain a lock on directory /mnt/ecash. " +
	"Bitcoin Core (eCash alphanet) is probably already running."

// TestStartBitcoindOnly_AdoptsExternalCoreWhenThePingLoses is the guard for
// the chain that lost its L1 on every restart. The boot asked the RPC alone
// whether Core ran. Core rescans a wallet and caps its callers, so one ping
// lost, the boot read that as "no node", and the start it made then lost the
// datadir lock to the node that was there all along.
func TestStartBitcoindOnly_AdoptsExternalCoreWhenThePingLoses(t *testing.T) {
	markerPath := filepath.Join(t.TempDir(), "started")
	o := fakeCoreFixture(t, fmt.Sprintf("#!/bin/sh\nprintf 'x' >> %q\nsleep 30\n", markerPath))
	corePid := externalCore(t, o)

	checker := &coldChecker{}
	checker.cold.Store(1)
	o.getOrCreateMonitor("bitcoind", checker, bitcoindStartupPatterns)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	sink := newBootSink()
	require.True(t, o.startBitcoindOnly(ctx, StartOpts{}, sink))
	require.Empty(t, sink.failures(t))

	require.NoFileExists(t, markerPath, "the boot must start no second bitcoind")
	proc := o.process.Get("bitcoind")
	require.NotNil(t, proc)
	require.Equal(t, corePid, proc.Pid)
}

// TestAdoptIfCoreOwnsDatadir_LockConflictAdopts covers the start that got past
// the PID file and still lost the lock. The lock names a live owner, so the
// boot adopts it and reports success.
func TestAdoptIfCoreOwnsDatadir_LockConflictAdopts(t *testing.T) {
	for name, startErr := range map[string]string{
		"core lock message":    lockConflictError,
		"process manager slot": "bitcoind is already running",
	} {
		t.Run(name, func(t *testing.T) {
			o := fakeCoreFixture(t, "#!/bin/sh\nsleep 30\n")
			corePid := externalCore(t, o)

			require.NoError(t, o.adoptIfCoreOwnsDatadir(o.configs["bitcoind"], errors.New(startErr)))

			proc := o.process.Get("bitcoind")
			require.NotNil(t, proc)
			require.Equal(t, corePid, proc.Pid)
		})
	}
}

// TestAdoptIfCoreOwnsDatadir_OtherErrorStillFails keeps the adopt narrow.
func TestAdoptIfCoreOwnsDatadir_OtherErrorStillFails(t *testing.T) {
	o := fakeCoreFixture(t, "#!/bin/sh\nsleep 30\n")
	externalCore(t, o)

	startErr := errors.New("binary not found at /bin/bitcoind")
	require.ErrorIs(t, o.adoptIfCoreOwnsDatadir(o.configs["bitcoind"], startErr), startErr)
	require.False(t, o.process.IsRunning("bitcoind"))
}

// TestStartBitcoindOnly_OtherStartErrorStillFails covers the same rule end to
// end: a start that fails for any other reason is still a failed boot.
func TestStartBitcoindOnly_OtherStartErrorStillFails(t *testing.T) {
	o := fakeCoreFixture(t, "this file is no executable image")
	o.getOrCreateMonitor("bitcoind", &mockChecker{}, bitcoindStartupPatterns)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	sink := newBootSink()
	require.False(t, o.startBitcoindOnly(ctx, StartOpts{}, sink))
	require.Contains(t, fmt.Sprint(sink.failures(t)), "start bitcoind")
	require.False(t, o.process.IsRunning("bitcoind"))
}

// TestStartOrAdoptCore_StalePidFileStartsCore holds the restart of a bitcoind
// this install owns and lost. A crashed node leaves its PID file behind, and
// the number in it names a dead process, or the stranger that took it. Both
// answers must let the restart timer start Core.
func TestStartOrAdoptCore_StalePidFileStartsCore(t *testing.T) {
	t.Run("dead pid", func(t *testing.T) {
		o := fakeCoreFixture(t, "#!/bin/sh\nsleep 30\n")

		crashed := exec.Command("sleep", "30")
		require.NoError(t, crashed.Start())
		require.NoError(t, crashed.Process.Kill())
		_ = crashed.Wait()
		writeCorePidFile(t, o, crashed.Process.Pid)

		requireCoreStarted(t, o, crashed.Process.Pid)
	})

	t.Run("a stranger took the number", func(t *testing.T) {
		o := fakeCoreFixture(t, "#!/bin/sh\nsleep 30\n")

		stranger := exec.Command("sleep", "30")
		require.NoError(t, stranger.Start())
		t.Cleanup(func() {
			_ = stranger.Process.Kill()
			_ = stranger.Wait()
		})
		writeCorePidFile(t, o, stranger.Process.Pid)

		requireCoreStarted(t, o, stranger.Process.Pid)
	})
}

// TestStartOrAdoptCore_ForeignCoreDoesNotStopTheStart keeps the ownership test
// on our datadir. A bitcoind that runs on another datadir owns nothing here,
// so the boot must start the Core this chain needs.
func TestStartOrAdoptCore_ForeignCoreDoesNotStopTheStart(t *testing.T) {
	o := fakeCoreFixture(t, "#!/bin/sh\nsleep 30\n")
	foreignPid := coreLookalike(t, o)

	requireCoreStarted(t, o, foreignPid)
}

// requireCoreStarted asserts that startOrAdoptCore started Core rather than
// adopting the process at rejectedPid.
func requireCoreStarted(t *testing.T, o *Orchestrator, rejectedPid int) {
	t.Helper()
	require.NoError(t, o.startOrAdoptCore(context.Background(), nil))

	proc := o.process.Get("bitcoind")
	require.NotNil(t, proc)
	require.False(t, proc.Adopted, "the boot must start Core, not adopt a process that owns no datadir")
	require.NotEqual(t, rejectedPid, proc.Pid)
}
