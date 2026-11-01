package orchestrator

import (
	"context"
	"maps"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

const staleECashReleaseURL = "https://releases.ecash.com/L1-ecash-bitcoin/ecash/latest/"

// saveStuckMigration writes the record an older build left after its download
// returned HTTP 404: a job in its prepare step, with the release folder named
// after the network id.
func saveStuckMigration(t *testing.T, o *Orchestrator, step int) {
	t.Helper()
	state, err := o.newMigration(context.Background(), "betanet", "ecash")
	require.NoError(t, err)
	variants := maps.Clone(state.ToConfig.Variants)
	stale := variants["ecash"]
	stale.BaseURL = staleECashReleaseURL
	variants["ecash"] = stale
	state.ToConfig.Variants = variants
	state.Status.JobID = "STUCKJOB"
	state.Status.Phase = "prepare"
	state.Status.Error = "prepare: download returned HTTP 404"
	state.Status.StartedAt = time.Now().Unix()
	state.Step = step
	require.NoError(t, saveMigrationFile(o.migrationPath(), state))
	o.migrationState = nil
}

func TestDropUnstartedMigrationLetsBetanetStart(t *testing.T) {
	o := migrationTestNodeFor(t, "betanet", "ecash")
	saveStuckMigration(t, o, 0)
	core := BinaryConfig{IsBitcoinCore: true, ChainLayer: 1}
	require.ErrorContains(t, o.checkECashMigrationStart(context.Background(), core), "resume ECX migration STUCKJOB")

	for range 2 {
		require.NoError(t, o.DropUnstartedECashMigration())
	}
	require.NoFileExists(t, o.migrationPath())
	require.NoError(t, o.checkECashMigrationStart(context.Background(), core))
	status, err := o.ECashMigrationStatus()
	require.NoError(t, err)
	require.Empty(t, status.JobID)
	require.Equal(t, "betanet", o.ecashID)

	fresh, err := o.newMigration(context.Background(), "betanet", "ecash")
	require.NoError(t, err)
	require.Equal(t, ecashMainnetReleaseURL, fresh.ToConfig.Variants["ecash"].BaseURL)
	require.Equal(t, "ecash", fresh.ToConfig.Variants["ecash"].Subfolder)
}

func TestDropUnstartedMigrationKeepsAJobThatMovedFiles(t *testing.T) {
	o := migrationTestNodeFor(t, "betanet", "ecash")
	saveStuckMigration(t, o, 1)
	require.NoError(t, o.DropUnstartedECashMigration())
	require.FileExists(t, o.migrationPath())
	status, err := o.ECashMigrationStatus()
	require.NoError(t, err)
	require.Equal(t, "STUCKJOB", status.JobID)
}

func TestFailedDownloadLeavesTheInstallOnTheSource(t *testing.T) {
	o := migrationTestNodeFor(t, "betanet", "ecash")
	o.coreReachable = func() bool { return false }
	srv := httptest.NewServer(http.NotFoundHandler())
	t.Cleanup(srv.Close)
	raw := o.rawConfigs["bitcoind"]
	raw.Variants = maps.Clone(raw.Variants)
	variant := raw.Variants["ecash"]
	variant.BaseURL = srv.URL + "/{ecash}/latest/"
	raw.Variants["ecash"] = variant
	o.rawConfigs["bitcoind"] = raw

	for range 2 {
		started, err := o.StartECashMigration(context.Background(), "betanet", "ecash")
		require.NoError(t, err)
		require.NotEmpty(t, started.JobID)
		var status ECashMigrationStatus
		require.Eventually(t, func() bool {
			status, err = o.ECashMigrationStatus()
			require.NoError(t, err)
			return !status.Running && status.Error != ""
		}, 10*time.Second, 20*time.Millisecond)
		require.Empty(t, status.JobID)
		require.Equal(t, "betanet", status.FromID)
		require.Equal(t, "ecash", status.ToID)
		require.Contains(t, status.Error, "HTTP 404")
		require.NoFileExists(t, o.migrationPath())
		require.NoError(t, o.checkECashMigrationStart(context.Background(), BinaryConfig{IsBitcoinCore: true, ChainLayer: 1}))
		require.Equal(t, "betanet", o.ecashID)
		require.Equal(t, "betanet", o.Settings.ECashChainID())
	}
}
