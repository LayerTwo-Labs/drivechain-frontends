//go:build !windows

package orchestrator

import (
	"context"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// The bug: a reset skipped every adopted binary, so it wiped the datadir under
// a daemon that stayed alive, and started no replacement.
func TestResetPlan_RestartsAnAdoptedOrphanThisInstallOwns(t *testing.T) {
	o := newResetTestOrchestrator(t)
	ownThisInstall(t, o)
	adoptSleeper(t, o, true)

	plan := o.buildResetPlan([]GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})

	require.Equal(t, []ResetBinary{ResetBinaryBitcoind}, resetRestartBinaries(plan))
}

// The deletion runs the moment this returns, so an orphan this install owns
// must be dead by then.
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

// A daemon this install never started is not ours to stop, and deleting under
// it would corrupt a live node. The reset refuses instead.
func TestDeleteFiles_RefusesToWipeUnderAForeignAdoptedProcess(t *testing.T) {
	o := newResetTestOrchestrator(t)
	pid := adoptSleeper(t, o, false)

	blocks := filepath.Join(o.BitwindowDir, "signet", "blocks", "blk00000.dat")
	seedFile(t, blocks)

	_, err := o.DeleteFiles(context.Background(), []string{blocks}, []GatherSpec{
		{Binary: ResetBinaryBitcoind, Categories: []ResetCategory{catData}},
	})
	require.ErrorContains(t, err, "not started by this install")

	require.FileExists(t, blocks, "a refused reset must leave the datadir alone")
	require.True(t, alive(t, pid), "a daemon this install never started must survive the reset")
}
