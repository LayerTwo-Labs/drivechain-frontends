package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func TestECashWalletOnlySwitchKeepsIdentityUntilConversion(t *testing.T) {
	o := migrationTestNode(t)
	o.coreReachable = func() bool { return false }
	path := filepath.Join(o.BitcoinConf.DataDir(), "wallets", "cold", "wallet.dat")
	createMigrationFixtureWallet(t, path, []byte{0xec, 0xa5, 0xa1, 0x04})
	before, err := os.ReadFile(path)
	require.NoError(t, err)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "fixture download unavailable", http.StatusServiceUnavailable)
	}))
	defer server.Close()
	raw := o.rawConfigs["bitcoind"]
	for id, variant := range raw.Variants {
		variant.BaseURL = server.URL + "/"
		raw.Variants[id] = variant
	}
	o.rawConfigs["bitcoind"] = raw
	err = o.ApplyECashSwitch(context.Background(), "betanet")
	t.Logf("switch error: %v; disk identity: %s", err, o.Settings.ECashChainID())
	require.Error(t, err)
	require.Equal(t, "alphanet", o.Settings.ECashChainID())
	after, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, before, after)
}

func TestECashWalletOnlyFilesUseMigrationPlan(t *testing.T) {
	o := migrationTestNode(t)
	path := filepath.Join(o.BitcoinConf.DataDir(), "wallets", "cold", "wallet.dat")
	createMigrationFixtureWallet(t, path, []byte{0xec, 0xa5, 0xa1, 0x04})
	plan, err := o.PlanECashSwitch("betanet")
	require.NoError(t, err)
	require.True(t, plan.HasChainData)
	require.Equal(t, "alphanet", plan.ChainID)
}

func TestECashWalletOnlyKeepsAutoLoadWallet(t *testing.T) {
	o, fixture, _ := prepareWalletOnlyEngineTest(t, false)
	root, err := filepath.EvalSymlinks(t.TempDir())
	require.NoError(t, err)
	fixture.ExternalWallet = filepath.Join(root, "external")
	fixture.AutoLoadWallet = true
	path := filepath.Join(fixture.ExternalWallet, "wallet.dat")
	createMigrationFixtureWallet(t, path, []byte{0xec, 0xa5, 0xa1, 0x04})
	before, err := os.ReadFile(path)
	require.NoError(t, err)
	data, err := json.Marshal(fixture)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(os.Getenv(migrationCoreFixtureEnv), data, 0o600))
	_, err = o.StartECashMigration(t.Context(), "alphanet", "betanet")
	require.NoError(t, err)
	status := waitMigrationEngineTest(t, o)
	t.Logf("external wallet migration: %+v", status)
	require.Empty(t, status.Error)
	require.True(t, status.Complete)
	state, err := o.readMigration()
	require.NoError(t, err)
	require.Contains(t, state.WalletPaths, fixture.ExternalWallet)
	after, err := os.ReadFile(path)
	require.NoError(t, err)
	want := bytes.Clone(before)
	copy(want[68:72], []byte{0xec, 0xa5, 0xa1, 0x05})
	require.Equal(t, want, after)
	client, err := o.CoreStatusClient()
	require.NoError(t, err)
	var loaded []string
	require.NoError(t, migrationRPC(t.Context(), client, "listwallets", &loaded))
	require.Contains(t, loaded, fixture.ExternalWallet)
}

func TestECashWalletOnlyKeepsLocalWalletName(t *testing.T) {
	o, fixture, wallet := prepareWalletOnlyEngineTest(t, false)
	fixture.AutoLoadLocal = true
	data, err := json.Marshal(fixture)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(os.Getenv(migrationCoreFixtureEnv), data, 0o600))
	_, err = o.StartECashMigration(t.Context(), "alphanet", "betanet")
	require.NoError(t, err)
	status := waitMigrationEngineTest(t, o)
	t.Logf("local wallet migration: %+v", status)
	requireWalletOnlyEngineResult(t, o, fixture, status, wallet, false, true)
	client, err := o.CoreStatusClient()
	require.NoError(t, err)
	var loaded []string
	require.NoError(t, migrationRPC(t.Context(), client, "listwallets", &loaded))
	require.Equal(t, []string{"migration"}, loaded)
	state, err := o.readMigration()
	require.NoError(t, err)
	state.Status.Complete = false
	state.Step = 4
	require.NoError(t, o.saveMigration(state))
	_, err = o.StartECashMigration(t.Context(), "alphanet", "betanet")
	require.NoError(t, err)
	status = waitMigrationEngineTest(t, o)
	require.Empty(t, status.Error)
	require.True(t, status.Complete)
	require.NoError(t, migrationRPC(t.Context(), client, "listwallets", &loaded))
	require.Equal(t, []string{"migration"}, loaded)
}

func TestECashWalletOnlyMigrationStarts(t *testing.T) {
	for _, genesis := range []bool{false, true} {
		name := "wallet files"
		if genesis {
			name = "source genesis"
		}
		t.Run(name, func(t *testing.T) {
			o, fixture, wallet := prepareWalletOnlyEngineTest(t, genesis)
			preview, err := o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			require.True(t, preview.WalletOnly)
			require.Zero(t, preview.CommonHeight)
			require.Equal(t, config.ChainParamsFor(config.NetworkECash).GenesisHash.String(), preview.CommonHash)
			require.Equal(t, "alphanet", o.Settings.ECashChainID())
			require.NoFileExists(t, o.migrationPath())
			status, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			require.True(t, status.WalletOnly)
			complete := waitMigrationEngineTest(t, o)
			requireWalletOnlyEngineResult(t, o, fixture, complete, wallet, genesis, true)
		})
	}
}

func TestECashWalletOnlyMigrationResumesConvertedWallet(t *testing.T) {
	o, fixture, wallet := prepareWalletOnlyEngineTest(t, false)
	state, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	require.True(t, state.Status.WalletOnly)
	state.Status.JobID = "wallet-only-resume"
	state.Step = 2
	require.NoError(t, o.prepareMigration(context.Background(), state))
	require.NoError(t, o.saveMigration(state))
	require.NoError(t, o.convertMigration(context.Background(), state))
	require.Equal(t, "alphanet", o.Settings.ECashChainID())

	next := New(o.DataDir, "ecash", o.BitwindowDir, AllDefaults(), testLogger(t))
	registerMigrationEngineCleanup(t, next)
	next.adoptCatalog(o.Catalog, "alphanet")
	status, err := next.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.True(t, status.WalletOnly)
	require.Equal(t, state.Status.JobID, status.JobID)
	complete := waitMigrationEngineTest(t, next)
	requireWalletOnlyEngineResult(t, next, fixture, complete, wallet, false, false)
}

func TestECashWalletOnlyStoppedSourceStarts(t *testing.T) {
	for _, saved := range []bool{false, true} {
		name := "new job"
		if saved {
			name = "saved job"
		}
		t.Run(name, func(t *testing.T) {
			o, fixture, wallet := prepareWalletOnlyEngineTest(t, true)
			require.NoError(t, o.stopMigrationCore(context.Background()))
			require.NoError(t, os.Remove(filepath.Join(fixture.DataDir, "fixture-events")))
			state, err := o.newMigration("alphanet", "betanet")
			require.NoError(t, err)
			require.False(t, state.Status.WalletOnly)
			if saved {
				state.Status.JobID = "stopped-source-resume"
				state.Step = 1
				require.NoError(t, o.prepareMigration(context.Background(), state))
				require.NoError(t, o.saveMigration(state))
			}
			status, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			require.False(t, status.WalletOnly)
			complete := waitMigrationEngineTest(t, o)
			requireWalletOnlyEngineResult(t, o, fixture, complete, wallet, true, true)
			state, err = o.readMigration()
			require.NoError(t, err)
			require.True(t, state.Status.WalletOnly)
			require.Zero(t, state.Status.CommonHeight)
		})
	}
}

func TestECashWalletOnlySourceAboveGenesisSkipsRollback(t *testing.T) {
	o, fixture, wallet := prepareWalletOnlyEngineTest(t, true)
	require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, "fixture-height"), []byte("90"), 0o600))
	preview, err := o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.False(t, preview.WalletOnly)
	require.True(t, preview.BelowFork)
	require.EqualValues(t, 90, preview.CommonHeight)
	require.Equal(t, "alphanet", o.Settings.ECashChainID())
	require.NoFileExists(t, o.migrationPath())
	data, err := os.ReadFile(filepath.Join(fixture.DataDir, "wallets", "migration", "wallet.dat"))
	require.NoError(t, err)
	require.Equal(t, wallet, data)
}

func prepareWalletOnlyEngineTest(t *testing.T, genesis bool) (*Orchestrator, migrationCoreFixture, []byte) {
	t.Helper()
	o, fixture, _, _, wallet := prepareMigrationEngineTest(t, "", false)
	require.NoError(t, o.stopMigrationCore(context.Background()))
	fixture.WalletOnly = true
	data, err := json.Marshal(fixture)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(os.Getenv(migrationCoreFixtureEnv), data, 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, "fixture-height"), []byte("0"), 0o600))
	require.NoError(t, os.Remove(filepath.Join(fixture.DataDir, "fixture-events")))
	if !genesis {
		require.NoError(t, os.RemoveAll(filepath.Join(fixture.DataDir, "blocks")))
	} else {
		cfg, err := o.getConfig("bitcoind")
		require.NoError(t, err)
		_, err = o.process.Start(context.Background(), cfg, []string{"-datadir=" + fixture.DataDir, "-networkactive=0"}, nil)
		require.NoError(t, err)
		require.Eventually(t, o.coreRPCReachable, 10*time.Second, 25*time.Millisecond)
	}
	return o, fixture, wallet
}

func requireWalletOnlyEngineResult(t *testing.T, o *Orchestrator, fixture migrationCoreFixture, status ECashMigrationStatus, wallet []byte, genesis, sourceStart bool) {
	t.Helper()
	require.Empty(t, status.Error)
	require.True(t, status.Complete)
	require.True(t, status.WalletOnly)
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	data, err := os.ReadFile(filepath.Join(fixture.DataDir, "wallets", "migration", "wallet.dat"))
	require.NoError(t, err)
	want := bytes.Clone(wallet)
	copy(want[68:72], []byte{0xec, 0xa5, 0xa1, 0x05})
	require.Equal(t, want, data)
	log, err := os.ReadFile(filepath.Join(fixture.DataDir, "fixture-events"))
	require.NoError(t, err)
	var starts []string
	var wallets []string
	for _, line := range bytes.Split(bytes.TrimSpace(log), []byte("\n")) {
		var event migrationCoreEvent
		require.NoError(t, json.Unmarshal(line, &event))
		require.NotEqual(t, "invalidateblock", event.Method)
		if event.Method == "start" {
			starts = append(starts, event.Network)
		}
		if event.Method == "getwalletinfo" {
			wallets = append(wallets, event.Network)
		}
	}
	expected := []string{"betanet"}
	if sourceStart {
		expected = append([]string{"alphanet"}, expected...)
	}
	require.Equal(t, expected, starts)
	require.Equal(t, []string{"betanet"}, wallets)
	if !genesis {
		require.Zero(t, status.BlockFiles)
		require.Zero(t, status.RecordsTotal)
		require.NoDirExists(t, filepath.Join(fixture.DataDir, "blocks"))
	}
}
