package orchestrator

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

// thunderChainPath is the flat store a sidechain keeps across every network.
func thunderChainPath(t *testing.T) string {
	t.Helper()
	dc, ok := config.DirConfigByName("thunder")
	require.True(t, ok)
	datadir := dc.DatadirNetwork(config.NetworkSignet, "")
	require.NoError(t, os.MkdirAll(datadir, 0o755))
	return filepath.Join(datadir, "data.mdb")
}

func parkInstall(t *testing.T) *Orchestrator {
	t.Helper()
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	o.coreReachable = func() bool { return false }
	return o
}

// Sidechains keep one flat datadir across every network, so a swap used to
// delete the only copy. The state is parked under the network it belongs to and
// comes back on the swap home.
func TestNetworkSwapParksSidechainStateAndBringsItBack(t *testing.T) {
	o := parkInstall(t)
	require.Equal(t, string(config.NetworkSignet), o.Network)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("signet sidechain state"), 0o644))

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))

	require.NoFileExists(t, chain, "the outgoing state must move out of the way")
	parked, err := os.ReadFile(chain + ".network-signet")
	require.NoError(t, err, "the outgoing state must be parked, never deleted")
	require.Equal(t, "signet sidechain state", string(parked))

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkSignet))

	back, err := os.ReadFile(chain)
	require.NoError(t, err, "the swap home must bring the state back")
	require.Equal(t, "signet sidechain state", string(back))
}

// A swap that dies between the park and the conf write leaves the state parked
// under a network the conf no longer names. The next start brings it back.
func TestStartRestoresStateAnInterruptedSwapParked(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("stranded"), 0o644))

	require.NoError(t, o.RestoreParkedSwapState())

	back, err := os.ReadFile(chain)
	require.NoError(t, err, "a start must bring back what the conf's network parked")
	require.Equal(t, "stranded", string(back))
}

// A live path is the newer state by definition. Restoring over it would swap in
// a copy the user already moved past.
func TestRestoreNeverOverwritesLiveState(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("live"), 0o644))
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("older"), 0o644))

	require.NoError(t, o.RestoreParkedSwapState())

	live, err := os.ReadFile(chain)
	require.NoError(t, err)
	require.Equal(t, "live", string(live))
	require.FileExists(t, chain+".network-signet", "the parked copy stays on disk")
}

// An interrupted swap leaves a parked copy behind. Parking again must not
// overwrite it: that copy is the only one of its network.
func TestParkNeverOverwritesAnEarlierPark(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("live"), 0o644))
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("stranded"), 0o644))

	require.NoError(t, o.parkOutgoingSwapState())

	stranded, err := os.ReadFile(chain + ".network-signet")
	require.NoError(t, err)
	require.Equal(t, "stranded", string(stranded), "the earlier park must survive untouched")
	live, err := os.ReadFile(chain + ".network-signet.1")
	require.NoError(t, err)
	require.Equal(t, "live", string(live))
}

// The newest park is the state that was live, so that is the one to bring back.
func TestRestoreTakesTheNewestSlot(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("older"), 0o644))
	require.NoError(t, os.WriteFile(chain+".network-signet.1", []byte("newest"), 0o644))

	require.NoError(t, o.RestoreParkedSwapState())

	live, err := os.ReadFile(chain)
	require.NoError(t, err)
	require.Equal(t, "newest", string(live))
	require.FileExists(t, chain+".network-signet", "the older copy stays on disk")
}

// parkedPathsFor drives the restore, so a numbered slot it cannot see is a
// numbered slot nothing ever brings back.
func TestParkedPathsForFindsNumberedSlots(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "data.mdb.network-signet.1"), []byte("x"), 0o644))

	require.Equal(t, []string{filepath.Join(dir, "data.mdb")}, parkedPathsFor(dir, config.NetworkSignet))
}

// A restore that fails leaves the network durable but the state parked. The
// retry must resume there, not read the network as swapped and report success.
func TestSwapKeepsRetryStateWhenTheRestoreFails(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("signet sidechain state"), 0o644))

	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	require.Nil(t, o.pendingSwap, "a swap that finished leaves nothing to resume")

	// Back home, but the parked copy is unreadable, so the restore fails.
	parked := chain + ".network-signet"
	require.NoError(t, os.Remove(parked))
	require.NoError(t, os.MkdirAll(parked, 0o000))
	t.Cleanup(func() { _ = os.Chmod(parked, 0o755) })

	err := o.SwapNetwork(context.Background(), config.NetworkSignet)
	if err == nil {
		t.Skip("this filesystem allows the rename, so the failure cannot be staged")
	}
	require.Contains(t, err.Error(), "restore the state", "the swap must fail on the restore, not elsewhere")
	require.NotNil(t, o.pendingSwap, "a failed tail must leave a swap to resume")
	require.Equal(t, config.NetworkSignet, o.pendingSwap.network)
}

// A swap that could not bring its state back leaves the live path absent.
// Starting a daemon there builds fresh state, and the restore then refuses to
// overwrite it — so the real copy strands. The start refuses instead.
func TestDaemonStartsRefuseWhileStateIsParked(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("parked"), 0o644))

	_, err := o.StartWithL1(context.Background(), "bitcoind", StartOpts{})
	require.Error(t, err, "a start over an absent live path must refuse")
	require.Contains(t, err.Error(), "restart BitWindow")

	_, err = o.RestartDaemon(context.Background(), "bitcoind")
	require.Error(t, err, "the restart button must refuse too")
}

// Once the state is back, starts go through again.
func TestDaemonStartsResumeOnceTheStateIsBack(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain+".network-signet", []byte("parked"), 0o644))

	require.NoError(t, o.RestoreParkedSwapState())

	require.Empty(t, o.parkedStateOutstanding(), "nothing is aside any more")
}

// GetBlockchainDataPaths omits a path it cannot read, and an omitted path never
// reaches the fail-closed check. The swap has to see it and refuse.
func TestASwapRefusesAnUnreadableSidechainPath(t *testing.T) {
	o := parkInstall(t)
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("signet sidechain state"), 0o644))
	require.NoError(t, os.Chmod(filepath.Dir(chain), 0o000))
	t.Cleanup(func() { _ = os.Chmod(filepath.Dir(chain), 0o755) })

	if _, err := os.Stat(chain); err == nil {
		t.Skip("this filesystem reads the path anyway, so the failure cannot be staged")
	}

	err := o.SwapNetwork(context.Background(), config.NetworkECash)
	require.Error(t, err, "a swap that cannot see the outgoing state must refuse")
	require.Contains(t, err.Error(), "before parking it")
}
