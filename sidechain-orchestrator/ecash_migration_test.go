package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

func migrationTestNode(t *testing.T) *Orchestrator {
	t.Helper()
	endpoints, id := config.ECashEndpoints(), config.ECashNetworkID()
	height := config.PublishedForkHeight(config.NetworkECash)
	name := config.PublishedDisplayName(config.NetworkECash)
	t.Cleanup(func() {
		config.SetECashEndpoints(endpoints)
		config.SetECashNetworkID(id)
		config.SetForkHeight(config.NetworkECash, height)
		config.SetNetworkDisplayName(config.NetworkECash, name)
	})
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, ForkHeight: 101, NetworkMagic: "eca5a104", ForkParentHash: strings.Repeat("a", 64)},
		{ID: "betanet", Family: netcatalog.FamilyECash, ForkHeight: 121, NetworkMagic: "eca5a105"},
	}}
	cat.Networks[0].P2P.Address = "old.example:8301"
	cat.Networks[1].P2P.Address = "new.example:8301"
	o.adoptCatalog(cat, "alphanet")
	require.NoError(t, o.recordECashChain("alphanet"))
	return o
}

func TestECashMigrationChecksPublishedIdentity(t *testing.T) {
	o := migrationTestNode(t)
	state, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	require.EqualValues(t, 100, state.Status.CommonHeight)
	require.Equal(t, strings.Repeat("a", 64), state.Status.CommonHash)
	require.Equal(t, filepath.Join(state.Status.DataDir, "blocks"), state.BlocksDir)

	o.Catalog.Networks[0].ForkParentHash = ""
	_, err = o.newMigration("alphanet", "betanet")
	require.ErrorContains(t, err, "fork_parent_hash")
	o.Catalog.Networks[0].ForkParentHash = strings.Repeat("a", 64)
	o.Catalog.Networks[1].NetworkMagic = "eca5a104"
	_, err = o.newMigration("alphanet", "betanet")
	require.ErrorContains(t, err, "must differ")
	_, err = o.newMigration("../../alphanet", "betanet")
	require.Error(t, err)
}

func TestECashMigrationUsesRecordedSourceAfterSelection(t *testing.T) {
	o := migrationTestNode(t)
	o.ecashID = "betanet"
	_, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	_, err = o.newMigration("betanet", "alphanet")
	require.ErrorContains(t, err, "does not match")
	blocks := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(blocks, "blk00000.dat"), []byte("unchanged"), 0o600))
	err = o.checkECashMigrationStart(context.Background(), BinaryConfig{IsBitcoinCore: true, ChainLayer: 1})
	require.ErrorContains(t, err, "--from alphanet --to betanet")
	data, err := os.ReadFile(filepath.Join(blocks, "blk00000.dat"))
	require.NoError(t, err)
	require.Equal(t, "unchanged", string(data))
}

func TestECashMigrationStatusSurvivesDaemonExit(t *testing.T) {
	o := migrationTestNode(t)
	state, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	state.Status.JobID = "saved-job"
	state.Status.Running = true
	state.Status.Error = "interrupted"
	state.Step = 2
	require.NoError(t, o.saveMigration(state))
	o.migrationState = nil
	status, err := o.ECashMigrationStatus()
	require.NoError(t, err)
	require.False(t, status.Running)
	require.Equal(t, "interrupted", status.Error)
	_, err = o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	_, err = o.StartECashMigration(context.Background(), "alphanet", "another")
	require.ErrorContains(t, err, "another ECX migration")
	require.Error(t, o.checkECashMigrationStart(context.Background(), BinaryConfig{ChainLayer: 2}))
	ctx := context.WithValue(context.Background(), ecashMigrationKey{}, o)
	require.NoError(t, o.checkECashMigrationStart(ctx, BinaryConfig{IsBitcoinCore: true, ChainLayer: 1}))
}

func TestECashMigrationRejectsInvalidState(t *testing.T) {
	o := migrationTestNode(t)
	for _, id := range []string{".", "..", "../other"} {
		state := ecashMigration{Status: ECashMigrationStatus{JobID: id}}
		require.NoError(t, saveMigrationFile(o.migrationPath(), state))
		_, err := o.ECashMigrationStatus()
		require.ErrorContains(t, err, "invalid ECX migration record")
	}
}

func TestECashMigrationKeepsRepeatedPeerBackups(t *testing.T) {
	dir := t.TempDir()
	source, target := filepath.Join(dir, "peers.dat"), filepath.Join(dir, "backup", "peers.dat")
	for _, data := range []string{"first", "second"} {
		require.NoError(t, os.WriteFile(source, []byte(data), 0o600))
		require.NoError(t, moveMigrationFile(source, target))
	}
	first, err := os.ReadFile(target)
	require.NoError(t, err)
	second, err := os.ReadFile(target + ".1")
	require.NoError(t, err)
	require.Equal(t, "first", string(first))
	require.Equal(t, "second", string(second))
	require.NoError(t, moveMigrationFile(source, target))
}

func TestECashMigrationKeepsCustomCoreSettings(t *testing.T) {
	o := migrationTestNode(t)
	state, err := o.newMigration("alphanet", "betanet")
	require.NoError(t, err)
	state.Status.JobID = "config-test"
	o.BitcoinConf.Config.SetSetting("rpcport", "18444", "main")
	o.BitcoinConf.Config.SetSetting("rpcbind", "127.0.0.2", "main")
	o.BitcoinConf.Config.SetSetting("addnode", state.FromEntry.P2P.Address, "main")
	require.NoError(t, o.selectMigration(state))
	require.Equal(t, "18444", o.BitcoinConf.Config.GetEffectiveSetting("rpcport", "main"))
	require.Equal(t, "127.0.0.2", o.BitcoinConf.Config.GetEffectiveSetting("rpcbind", "main"))
	require.Equal(t, state.ToEntry.P2P.Address, o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	require.Equal(t, "0", o.BitcoinConf.Config.GetEffectiveSetting("walletbroadcast", "main"))
	require.NoError(t, o.selectMigration(state))
}

func TestECashMigrationChecksCommonBlockAndPruneLimit(t *testing.T) {
	for _, test := range []struct {
		name, chain, hash, want string
		height, prune           int64
	}{
		{name: "common", chain: "main", hash: "common", height: 100},
		{name: "later", chain: "main", hash: "common", height: 110},
		{name: "prune", chain: "main", hash: "common", height: 110, prune: 101, want: "rollback interval"},
		{name: "hash", chain: "main", hash: "other", height: 110, want: "differs from catalog"},
		{name: "chain", chain: "regtest", hash: "common", height: 110, want: "ECX uses main"},
		{name: "height", chain: "main", hash: "common", height: 99, want: "reach the common height"},
	} {
		t.Run(test.name, func(t *testing.T) {
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				var req struct {
					Method string `json:"method"`
				}
				require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
				var result any
				switch req.Method {
				case "getblockchaininfo":
					result = map[string]any{"chain": test.chain, "blocks": test.height, "pruned": test.prune > 0, "pruneheight": test.prune}
				case "getblockhash":
					result = test.hash
				default:
					t.Errorf("unexpected RPC %s", req.Method)
				}
				require.NoError(t, json.NewEncoder(w).Encode(map[string]any{"result": result, "error": nil, "id": "migration"}))
			}))
			defer srv.Close()
			client := &CoreStatusClient{url: srv.URL}
			state := &ecashMigration{Status: ECashMigrationStatus{CommonHeight: 100, CommonHash: "common"}}
			err := checkMigrationChain(context.Background(), client, state, false)
			if test.want == "" {
				require.NoError(t, err)
			} else {
				require.ErrorContains(t, err, test.want)
			}
		})
	}
}

func TestECashMigrationSameNetworkKeepsBlocks(t *testing.T) {
	o := migrationTestNode(t)
	dir := filepath.Join(o.BitcoinConf.DataDir(), "blocks")
	require.NoError(t, os.MkdirAll(dir, 0o700))
	file := filepath.Join(dir, "blk00000.dat")
	require.NoError(t, os.WriteFile(file, []byte("data"), 0o600))
	require.NoError(t, o.ApplyECashSwitch(context.Background(), "alphanet"))
	data, err := os.ReadFile(file)
	require.NoError(t, err)
	require.Equal(t, "data", string(data))
	_, err = os.Stat(o.migrationPath())
	require.True(t, os.IsNotExist(err), fmt.Sprint(err))
}
