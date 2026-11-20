package wallet

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// TestHWIDaemonSmoke drives a real daemon over the pipe protocol. Against the
// frozen binary, enumerate is what proves libusb loads out of the bundle.
func TestHWIDaemonSmoke(t *testing.T) {
	if os.Getenv("ORCHESTRATOR_HWI_DAEMON") == "" {
		t.Skip("set ORCHESTRATOR_HWI_DAEMON to the daemon to run this")
	}
	t.Cleanup(func() {
		daemonMu.Lock()
		defer daemonMu.Unlock()
		if daemon != nil {
			daemon.close()
			daemon = nil
		}
	})

	// A onefile bundle unpacks itself on first start.
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	runner := NewHWIRunner(&chaincfg.SigNetParams)

	devices, err := runner.Enumerate(ctx, "")
	require.NoError(t, err)
	t.Logf("enumerate found %d devices", len(devices))

	_, err = hwiCall(ctx, map[string]any{"cmd": "nonsense"})
	require.ErrorContains(t, err, "unknown command")

	_, err = runner.GetXpub(ctx, HardwareSelector{Fingerprint: "deadbeef"}, "m/84'/1'/0'")
	require.Error(t, err)

	_, err = runner.Enumerate(ctx, "")
	require.NoError(t, err, "daemon did not survive the failed commands")
}

func TestWarmHWIDaemonLeavesTheFirstLookupNoStart(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the fake daemon is a shell script")
	}
	dir := t.TempDir()
	starts := filepath.Join(dir, "starts")
	fake := filepath.Join(dir, "hwi-daemon")
	script := "#!/bin/sh\necho start >> '" + starts + "'\nwhile read line; do echo '[]'; done\n"
	require.NoError(t, os.WriteFile(fake, []byte(script), 0o755))
	t.Setenv("ORCHESTRATOR_HWI_DAEMON", fake)
	t.Cleanup(func() {
		daemonMu.Lock()
		defer daemonMu.Unlock()
		if daemon != nil {
			daemon.close()
			daemon = nil
		}
	})

	require.NoError(t, WarmHWIDaemon(t.Context(), &chaincfg.RegressionNetParams))

	devices, err := NewHWIRunner(&chaincfg.RegressionNetParams).Enumerate(t.Context(), "")
	require.NoError(t, err)
	require.Empty(t, devices)

	got, err := os.ReadFile(starts)
	require.NoError(t, err)
	require.Equal(t, "start\n", string(got))
}
