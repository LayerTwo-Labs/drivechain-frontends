//go:build !windows

package orchestrator

import (
	"context"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestResetPlan_RestartsAnAdoptedOrphanThisInstallOwns(t *testing.T) {
	o := newResetTestOrchestrator(t)
	ownThisInstall(t, o)
	adoptSleeper(t, o, true)

	plan := o.buildResetPlan([]GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})

	require.Equal(t, []ResetBinary{ResetBinaryBitcoind}, resetRestartBinaries(plan))
}

func TestStopResetPlan_StopsAnAdoptedOrphanBeforeTheWipe(t *testing.T) {
	o := newResetTestOrchestrator(t)
	ownThisInstall(t, o)
	pid := adoptSleeper(t, o, true)

	plan := o.buildResetPlan([]GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})
	require.NoError(t, o.stopResetPlan(context.Background(), plan))

	require.True(t, waitGone(t, pid, 30*time.Second), "the reset must stop an orphan this install owns")
}

func TestDeleteFiles_RefusesToWipeUnderAForeignAdoptedProcess(t *testing.T) {
	o := newResetTestOrchestrator(t)
	pid := adoptSleeper(t, o, false)

	blocks := filepath.Join(o.BitwindowDir, "signet", "blocks", "blk00000.dat")
	seedFile(t, blocks)

	_, err := o.DeleteFiles(context.Background(), []string{blocks}, []GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})
	require.ErrorContains(t, err, "this install did not start it")

	require.FileExists(t, blocks, "a refused reset must leave the datadir alone")
	require.True(t, alive(t, pid), "a daemon this install never started must survive the reset")
}

func TestStopResetPlan_ForeignProcessStopsNothing(t *testing.T) {
	o := newResetTestOrchestrator(t)
	ownThisInstall(t, o)
	adoptSleeper(t, o, false)

	enforcerPid := startSleeper(t)
	cfg, err := o.getConfig("enforcer")
	require.NoError(t, err)
	require.NoError(t, o.pidManager.WritePidFile(cfg.BinaryName, enforcerPid))
	o.process.AdoptProcess(cfg, enforcerPid)

	plan := o.buildResetPlan([]GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})
	require.Error(t, o.stopResetPlan(context.Background(), plan))

	require.True(t, alive(t, enforcerPid), "a refused reset must stop nothing")
	require.True(t, o.process.IsRunning("enforcer"))
}
