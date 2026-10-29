package orchestrator

import (
	"context"
	"os"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// olderSwitchSettings is what a release before the stranded release left on
// disk after a switch from betanet to mainnet.
const olderSwitchSettings = `{
  "core_variant": "drivechain",
  "ecash_network_id": "ecash",
  "ecash_chain_id": "ecash",
  "seen_network_ids": ["betanet", "ecash"],
  "rewound_block_hash": "00000000000000000001a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f7",
  "electrum_server_url": "",
  "tor_enabled": false,
  "tor_proxy": "",
  "stratum": {}
}`

type strandedBackend struct {
	wallet.Backend
	synced bool
	calls  int
	locks  []uint32
}

func (b *strandedBackend) ReleaseStranded(_ context.Context, retiredLockTimes []uint32) (bool, error) {
	b.calls++
	b.locks = retiredLockTimes
	return b.synced, nil
}

var strandedCatalog = netcatalog.Catalog{Networks: []netcatalog.Network{
	{ID: "signet", Family: "signet"},
	{ID: "betanet", Family: netcatalog.FamilyECash, ReplayLockTime: 499999999},
	{ID: "ecash", Family: netcatalog.FamilyECash, ReplayLockTime: 499999998},
}}

func newStrandedOrchestrator(t *testing.T, bitwindowDir string, chain wallet.Backend) *Orchestrator {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	_, err := svc.GenerateWallet("Full", "", "", nil)
	require.NoError(t, err)
	require.Equal(t, wallet.StateUnlocked, svc.State())

	settings, err := NewSettingsStore(bitwindowDir)
	require.NoError(t, err)

	router := wallet.NewBackendRouter(svc, chain, nil)
	o := &Orchestrator{
		BitwindowDir: bitwindowDir,
		Settings:     settings,
		WalletSvc:    svc,
		Catalog:      strandedCatalog,
		ecashID:      settings.ECashNetworkID(),
		log:          log,
	}
	o.setNetwork(string(config.NetworkECash))
	o.SetWalletEngine(wallet.NewWalletEngine(svc, router, wallet.StaticParams(&chaincfg.MainNetParams), log))
	return o
}

func TestReleaseStrandedTxsRunsOnceAfterAnOlderSwitch(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: true}
	o := newStrandedOrchestrator(t, dir, chain)
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Equal(t, 1, chain.calls)
	assert.Equal(t, []uint32{499999999}, chain.locks)

	saved, err := LoadSettings(dir)
	require.NoError(t, err)
	assert.Equal(t, "ecash", saved.StrandedReleasedFor)
	assert.Equal(t, "00000000000000000001a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f7", saved.RewoundBlockHash)

	next := &strandedBackend{synced: true}
	restarted := newStrandedOrchestrator(t, dir, next)
	require.NoError(t, restarted.ReleaseStrandedTxs(context.Background()))
	assert.Zero(t, next.calls)
}

func TestReleaseStrandedTxsWaitsForASyncedChain(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: false}
	o := newStrandedOrchestrator(t, dir, chain)
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Empty(t, o.Settings.StrandedReleasedFor())

	chain.synced = true
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Equal(t, 2, chain.calls)
	assert.Equal(t, "ecash", o.Settings.StrandedReleasedFor())
}

func TestReleaseStrandedTxsRunsAgainAfterTheNextSwitch(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: true}
	o := newStrandedOrchestrator(t, dir, chain)
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))

	o.ecashID = "betanet"
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Equal(t, 2, chain.calls)
	assert.Equal(t, []uint32{499999998}, chain.locks)
	assert.Equal(t, "betanet", o.Settings.StrandedReleasedFor())
}

func TestReleaseStrandedTxsSkipsOtherNetworks(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: true}
	o := newStrandedOrchestrator(t, dir, chain)
	o.setNetwork(string(config.NetworkSignet))
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Zero(t, chain.calls)
	assert.Empty(t, o.Settings.StrandedReleasedFor())
}

func TestReleaseStrandedTxsWaitsForAMigration(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: true}
	o := newStrandedOrchestrator(t, dir, chain)
	o.migrationState = &ecashMigration{Status: ECashMigrationStatus{JobID: "job", FromID: "betanet", ToID: "ecash"}}
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Zero(t, chain.calls)

	o.migrationState.Status.Complete = true
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Equal(t, 1, chain.calls)
}

func TestReleaseStrandedTxsWaitsForASwitch(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(SettingsPath(dir), []byte(olderSwitchSettings), 0o644))

	chain := &strandedBackend{synced: true}
	o := newStrandedOrchestrator(t, dir, chain)
	o.swapNetworkMu.Lock()
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	o.swapNetworkMu.Unlock()
	assert.Zero(t, chain.calls)

	o.pendingSwap = &pendingNetworkSwap{network: config.NetworkECash}
	require.NoError(t, o.ReleaseStrandedTxs(context.Background()))
	assert.Zero(t, chain.calls)
	assert.Empty(t, o.Settings.StrandedReleasedFor())
}

func TestRetiredLockTimesKeepsTheDefault(t *testing.T) {
	onlyMainnet := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "ecash", Family: netcatalog.FamilyECash, ReplayLockTime: 499999998},
	}}
	assert.Equal(t, []uint32{499999999}, retiredLockTimes(onlyMainnet, "ecash"))
	assert.Equal(t, []uint32{499999998}, retiredLockTimes(strandedCatalog, "betanet"))
}
