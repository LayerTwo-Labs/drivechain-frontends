package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// ---------------------------------------------------------------------------
// Migration system
// ---------------------------------------------------------------------------

func TestRunBitcoinConfMigrationsFresh(t *testing.T) {
	config := NewBitcoinConfig()
	migrated, wipeNetworks := RunBitcoinConfMigrations(config)

	if !migrated {
		t.Fatal("expected migrations to run on fresh config")
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

	// Migration 3 should have set signet values
	signet := config.NetworkSettings["signet"]
	if signet["addnode"] != "172.105.148.135:38333" {
		t.Errorf("signet addnode = %q, want 172.105.148.135:38333", signet["addnode"])
	}
	if signet["signetblocktime"] != "600" {
		t.Errorf("signet signetblocktime = %q, want 600", signet["signetblocktime"])
	}
	if signet["signetchallenge"] != "00148835832e28c816b7acd8fdb19772ab2199603a56" {
		t.Errorf("signet signetchallenge = %q", signet["signetchallenge"])
	}

	// Migration 4 should have set global uacomment
	if config.GlobalSettings["uacomment"] != "BitWindow-0.2" {
		t.Errorf("uacomment = %q, want BitWindow-0.2", config.GlobalSettings["uacomment"])
	}

	// Migration 10 changed the signet challenge, so signet data is stale
	if len(wipeNetworks) != 1 || wipeNetworks[0] != NetworkSignet {
		t.Errorf("wipeNetworks = %v, want [signet]", wipeNetworks)
	}
}

func TestRunBitcoinConfMigrationsSkipsApplied(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = BitcoinConfMigrationsVersion

	migrated, wipeNetworks := RunBitcoinConfMigrations(config)
	if migrated {
		t.Error("should not migrate when already at current version")
	}
	if len(wipeNetworks) != 0 {
		t.Errorf("wipeNetworks = %v, want none", wipeNetworks)
	}
}

func TestRunBitcoinConfMigrationsPartial(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 2 // skip migrations 1 and 2

	migrated, _ := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("expected migrations 3+ to run")
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}

	if config.NetworkSettings["signet"]["signetblocktime"] != "600" {
		t.Errorf("signetblocktime = %q, want 600", config.NetworkSettings["signet"]["signetblocktime"])
	}
}

// A config that was live on the old signet challenge must get its signet
// chain data wiped — the network was reset, the old blocks are dead.
func TestRunBitcoinConfMigrationsWipesOnChallengeChange(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 9
	config.SetSetting("signetchallenge", "a91484fa7c2460891fe5212cb08432e21a4207909aa987", "signet")

	migrated, wipeNetworks := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("expected migration 10 to run on a v9 config")
	}
	if len(wipeNetworks) != 1 || wipeNetworks[0] != NetworkSignet {
		t.Errorf("wipeNetworks = %v, want [signet]", wipeNetworks)
	}
	if got := config.GetSetting("signetchallenge", "signet"); got != "00148835832e28c816b7acd8fdb19772ab2199603a56" {
		t.Errorf("signetchallenge = %q", got)
	}
}

// WipeChainData must remove chain state but leave wallets alone.
func TestWipeChainDataPreservesWallets(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	bcNet := BitcoinCoreDirs.DatadirNetwork(NetworkSignet, "")
	seed := func(path string) {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
	}
	seed(filepath.Join(bcNet, "blocks", "blk00000.dat"))
	seed(filepath.Join(bcNet, "chainstate", "CURRENT"))
	seed(filepath.Join(bcNet, "indexes", "txindex", "CURRENT"))
	seed(filepath.Join(bcNet, "mempool.dat"))
	seed(filepath.Join(bcNet, "fee_estimates.dat"))
	seed(filepath.Join(bcNet, "peers.dat"))
	seed(filepath.Join(bcNet, "wallets", "wallet.dat"))

	WipeChainData(NetworkSignet, "", zerolog.Nop())

	require.Eventually(t, func() bool {
		for _, gone := range []string{"blocks", "chainstate", "indexes", "mempool.dat", "fee_estimates.dat", "peers.dat"} {
			if _, err := os.Stat(filepath.Join(bcNet, gone)); !os.IsNotExist(err) {
				return false
			}
		}
		return true
	}, 5*time.Second, 20*time.Millisecond)

	if _, err := os.Stat(filepath.Join(bcNet, "wallets", "wallet.dat")); err != nil {
		t.Error("wallets must survive a chain data wipe")
	}
}

// Regression: a migration armed for forknet, applied while the user is sitting
// on mainnet, must not touch mainnet's chain. CoreSectionForNetwork(forknet) is
// "main", so resolving the datadir from the live `datadir=` line handed the
// wipe mainnet's directory and deleted its blocks/ and chainstate/.
func TestWipeStaleChainDataNeverTouchesAnotherNetworksDatadir(t *testing.T) {
	tmpDir := t.TempDir()
	t.Setenv("HOME", tmpDir)
	t.Setenv("USERPROFILE", tmpDir)
	mainnetDir := filepath.Join(tmpDir, "mainnet-chain")
	seed := func(path string) {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
	}
	seed(filepath.Join(mainnetDir, "blocks", "blk00000.dat"))
	seed(filepath.Join(mainnetDir, "chainstate", "CURRENT"))

	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", mainnetDir)
	m.Config.SetGroupDatadir(DatadirGroupDefault, mainnetDir)

	require.NoError(t, m.wipeStaleChainData(m.Config, []Network{NetworkForknet}))

	// The wipe is asynchronous; give a buggy one time to land.
	require.Never(t, func() bool {
		_, err := os.Stat(filepath.Join(mainnetDir, "blocks", "blk00000.dat"))
		return os.IsNotExist(err)
	}, 500*time.Millisecond, 50*time.Millisecond, "mainnet chain data must survive a forknet-targeted wipe")

	_, err := os.Stat(filepath.Join(mainnetDir, "chainstate", "CURRENT"))
	require.NoError(t, err, "mainnet chainstate must survive a forknet-targeted wipe")
}

// With a forknet slot recorded, the wipe resolves to that path — not the live
// mainnet one — and does delete forknet's chain.
func TestWipeStaleChainDataUsesTargetNetworkSlot(t *testing.T) {
	tmpDir := t.TempDir()
	mainnetDir := filepath.Join(tmpDir, "mainnet-chain")
	forknetDir := filepath.Join(tmpDir, "forknet-chain", "forknet")
	seed := func(path string) {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
	}
	seed(filepath.Join(mainnetDir, "blocks", "blk00000.dat"))
	seed(filepath.Join(forknetDir, "blocks", "blk00000.dat"))

	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", mainnetDir)
	m.Config.SetGroupDatadir(DatadirGroupDefault, mainnetDir)
	m.Config.SetGroupDatadir(DatadirGroupForknet, forknetDir)

	require.NoError(t, m.wipeStaleChainData(m.Config, []Network{NetworkForknet}))

	require.Eventually(t, func() bool {
		_, err := os.Stat(filepath.Join(forknetDir, "blocks"))
		return os.IsNotExist(err)
	}, 5*time.Second, 20*time.Millisecond, "forknet chain data should be wiped")

	_, err := os.Stat(filepath.Join(mainnetDir, "blocks", "blk00000.dat"))
	require.NoError(t, err, "mainnet chain data must be untouched")
}

// On the boot that runs migrations m.Network is still the CLI/build seed, so
// trusting it pointed a signet wipe at the live forknet datadir.
func TestWipeStaleChainDataResolvesActiveGroupFromConfig(t *testing.T) {
	tmpDir := t.TempDir()
	t.Setenv("HOME", tmpDir)
	t.Setenv("USERPROFILE", tmpDir)
	forknetDir := filepath.Join(tmpDir, "forknet-chain")
	signetDir := filepath.Join(tmpDir, "signet-slot")
	seed := func(path string) {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
	}
	seed(filepath.Join(forknetDir, "blocks", "blk00000.dat"))
	seed(filepath.Join(signetDir, "signet", "blocks", "blk00000.dat"))

	m := newTestManager(tmpDir)
	m.Network = NetworkSignet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("drivechain", "1", "main")
	m.Config.SetSetting("datadir", forknetDir)
	m.Config.SetGroupDatadir(DatadirGroupForknet, forknetDir)
	m.Config.SetGroupDatadir(DatadirGroupDefault, signetDir)

	require.NoError(t, m.wipeStaleChainData(m.Config, []Network{NetworkSignet}))

	require.Eventually(t, func() bool {
		_, err := os.Stat(filepath.Join(signetDir, "signet", "blocks"))
		return os.IsNotExist(err)
	}, 5*time.Second, 20*time.Millisecond, "signet's recorded slot should be wiped")

	_, err := os.Stat(filepath.Join(forknetDir, "blocks", "blk00000.dat"))
	require.NoError(t, err, "the live forknet datadir must be untouched")
}

// For the active group the live datadir= is what bitcoind is running on. A
// hand-edited live path with a stale slot left behind must wipe the chain the
// node actually booted, not the one the slot remembers.
func TestWipeStaleChainDataPrefersLiveDatadirForActiveGroup(t *testing.T) {
	tmpDir := t.TempDir()
	staleDir := filepath.Join(tmpDir, "stale-slot")
	liveDir := filepath.Join(tmpDir, "hand-edited")
	seed := func(path string) {
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
		require.NoError(t, os.WriteFile(path, []byte("stub"), 0o644))
	}
	seed(filepath.Join(staleDir, "signet", "blocks", "blk00000.dat"))
	seed(filepath.Join(liveDir, "signet", "blocks", "blk00000.dat"))

	m := newTestManager(tmpDir)
	m.Network = NetworkSignet
	m.Config.SetSetting("chain", "signet")
	m.Config.SetGroupDatadir(DatadirGroupDefault, staleDir)
	m.Config.SetSetting("datadir", liveDir)

	require.NoError(t, m.wipeStaleChainData(m.Config, []Network{NetworkSignet}))

	require.Eventually(t, func() bool {
		_, err := os.Stat(filepath.Join(liveDir, "signet", "blocks"))
		return os.IsNotExist(err)
	}, 5*time.Second, 20*time.Millisecond, "the chain bitcoind actually booted must be wiped")

	_, err := os.Stat(filepath.Join(staleDir, "signet", "blocks", "blk00000.dat"))
	require.NoError(t, err, "the stale slot's directory must be left alone")
}

// The wipe runs entirely in the background and returns immediately so a large,
// slow, or unresponsive datadir can't block orchestrator startup — that stall
// is what kept the RPC listener down past the frontend's readiness timeout. The
// data (and any renamed-aside .wiping copy) is gone once the background work
// completes.
func TestWipeChainDataDeletesInBackground(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	bcNet := BitcoinCoreDirs.DatadirNetwork(NetworkSignet, "")
	blocks := filepath.Join(bcNet, "blocks", "blk00000.dat")
	require.NoError(t, os.MkdirAll(filepath.Dir(blocks), 0o755))
	require.NoError(t, os.WriteFile(blocks, []byte("stub"), 0o644))

	WipeChainData(NetworkSignet, "", zerolog.Nop())

	require.Eventually(t, func() bool {
		_, err := os.Stat(filepath.Join(bcNet, "blocks"))
		_, wErr := os.Stat(filepath.Join(bcNet, "blocks"+wipingSuffix))
		return os.IsNotExist(err) && os.IsNotExist(wErr)
	}, 5*time.Second, 20*time.Millisecond)
}

// A user-set datadir= must be honoured so the wipe hits the real chain data.
func TestWipeChainDataHonoursDatadirOverride(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	custom := t.TempDir()
	blocks := filepath.Join(custom, "signet", "blocks", "blk00000.dat")
	require.NoError(t, os.MkdirAll(filepath.Dir(blocks), 0o755))
	require.NoError(t, os.WriteFile(blocks, []byte("stub"), 0o644))

	WipeChainData(NetworkSignet, custom, zerolog.Nop())

	require.Eventually(t, func() bool {
		_, err := os.Stat(filepath.Join(custom, "signet", "blocks"))
		return os.IsNotExist(err)
	}, 5*time.Second, 20*time.Millisecond)
}

// A config that already carries the new challenge gets the version bump but
// no wipe — nothing on disk is invalidated.
func TestRunBitcoinConfMigrationsNoWipeWhenChallengeCurrent(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 9
	config.SetSetting("signetchallenge", "00148835832e28c816b7acd8fdb19772ab2199603a56", "signet")

	migrated, wipeNetworks := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("expected version bump to 10")
	}
	if len(wipeNetworks) != 0 {
		t.Errorf("wipeNetworks = %v, want none", wipeNetworks)
	}
}

// Existing mainnet/signet/regtest configs that predate migration 5 must get
// rest=1 added to their global settings — the enforcer requires it on every
// network. Regression guard for the bug where mainnet conf shipped without
// rest=1, the enforcer crashed at boot, and the UI lost its enforcer chain
// tip.
func TestRunBitcoinConfMigrationsBackfillsRest(t *testing.T) {
	config := NewBitcoinConfig()
	config.ConfigVersion = 4
	config.GlobalSettings["rpcuser"] = "user"
	config.GlobalSettings["rpcpassword"] = "password"
	config.GlobalSettings["server"] = "1"
	config.GlobalSettings["txindex"] = "1"
	config.GlobalSettings["chain"] = "main"

	migrated, _ := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("expected migration 5 to run on a v4 config")
	}
	if got := config.GlobalSettings["rest"]; got != "1" {
		t.Errorf("rest = %q, want 1", got)
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}
}

// ---------------------------------------------------------------------------
// Default config
// ---------------------------------------------------------------------------

func TestGetDefaultConfigHasVersionPrefix(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkSignet}
	conf := m.GetDefaultConfig()

	prefix := fmt.Sprintf("# bitwindow-bitcoin-conf-version=%d", BitcoinConfMigrationsVersion)
	if !strings.HasPrefix(conf, prefix) {
		first := conf
		if len(first) > 80 {
			first = first[:80]
		}
		t.Errorf("default config should start with %q, got %q...", prefix, first)
	}
}

// The mainnet template ships rest=1 — without it the enforcer crashes at
// boot. Regression guard for the bug where mainnet was carved out into a
// "minimal" template that dropped the setting.
func TestGetDefaultConfigMainnetIncludesRest(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	if !strings.Contains(conf, "\nrest=1\n") {
		t.Errorf("mainnet default config must include rest=1, got:\n%s", conf)
	}
}

// Mainnet runs the enforcer too, so it must ship the same enforcer-required
// settings (zmqpubsequence) and perf knobs (rpcthreads, rpcworkqueue) as
// signet/drynet. Regression guard for the unify-template change.
func TestGetDefaultConfigMainnetMatchesEnforcerExpectations(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	required := []string{
		"\nzmqpubsequence=tcp://127.0.0.1:29000\n",
		"\nrpcthreads=10\n",
		"\nrpcworkqueue=50\n",
		"\nuacomment=BitWindow-0.2\n",
	}
	for _, line := range required {
		if !strings.Contains(conf, line) {
			t.Errorf("mainnet default config missing %q, got:\n%s", strings.TrimSpace(line), conf)
		}
	}
}

// Bitcoin Core rejects a non-zero fallbackfee on real mainnet. The setting
// can still appear in [signet]/[test]/[regtest] sections (bitcoind only
// applies the matching section), but must NOT be in the global block or
// [main] section.
func TestGetDefaultConfigFallbackfeeNotOnMainnet(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkMainnet}
	conf := m.GetDefaultConfig()

	headerIdx := strings.Index(conf, "\n[")
	globalBlock := conf
	rest := ""
	if headerIdx >= 0 {
		globalBlock = conf[:headerIdx]
		rest = conf[headerIdx:]
	}
	if strings.Contains(globalBlock, "fallbackfee=") {
		t.Errorf("mainnet global block must not include fallbackfee, got:\n%s", globalBlock)
	}

	if mainIdx := strings.Index(rest, "\n[main]"); mainIdx >= 0 {
		mainBlock := rest[mainIdx:]
		if next := strings.Index(mainBlock[1:], "\n["); next >= 0 {
			mainBlock = mainBlock[:next+1]
		}
		if strings.Contains(mainBlock, "fallbackfee=") {
			t.Errorf("mainnet [main] section must not include fallbackfee, got:\n%s", mainBlock)
		}
	}
}

func TestGetDefaultConfigDrynetHasPeerAndFallbackfee(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkDrynet, DrynetID: "drynet4"}
	conf := m.GetDefaultConfig()
	for _, want := range []string{
		"drivechain=1", "fallbackfee=0.00021",
		"addnode=drynet4.drivechain.dev:8533", "uacomment=drynet4", "rpcport=18302",
	} {
		if !strings.Contains(conf, want) {
			t.Errorf("drynet default config must include %q, got:\n%s", want, conf)
		}
	}
}

func TestGetDefaultConfigForknetKeepsFallbackfee(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkForknet}
	conf := m.GetDefaultConfig()
	for _, want := range []string{"drivechain=1", "fallbackfee=0.00021", "rpcport=18301"} {
		if !strings.Contains(conf, want) {
			t.Errorf("forknet default config must include %q, got:\n%s", want, conf)
		}
	}
}

// Forknet and drynet run on mainnet params, so a swap must write chain=main.
// Writing anything else boots the wrong network while [main] still carries the
// fork's ports and drivechain=1.
func TestUpdateNetworkWritesChainMainForForks(t *testing.T) {
	for _, n := range []Network{NetworkMainnet, NetworkForknet, NetworkDrynet} {
		t.Run(string(n), func(t *testing.T) {
			m := newTestManager(t.TempDir())
			m.Config = NewBitcoinConfig()
			m.Config.SetGroupDatadir(DatadirGroupForNetwork(n), "/some/path")
			require.NoError(t, m.UpdateNetwork(n))
			require.Equal(t, "main", m.Config.GetSetting("chain"), "%s must run on chain=main", n)
		})
	}
}

// The generation drives the peer and the sentinel, so a new drynet needs an
// endpoint change rather than a code change.
func TestDrynetGenerationDrivesPeerAndSentinel(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkDrynet, DrynetID: "drynet3"}
	conf := m.GetDefaultConfig()
	for _, want := range []string{"addnode=drynet3.drivechain.dev:8337", "uacomment=drynet3"} {
		if !strings.Contains(conf, want) {
			t.Errorf("drynet3 config must include %q, got:\n%s", want, conf)
		}
	}
	if strings.Contains(conf, "drynet2") {
		t.Errorf("drynet3 config must not mention drynet2, got:\n%s", conf)
	}

	// applyMainSectionDefaults writes the same values on a network swap.
	m2 := &BitcoinConfManager{Config: NewBitcoinConfig(), DrynetID: "drynet3", log: zerolog.Nop()}
	m2.applyMainSectionDefaults(NetworkDrynet)
	if got := m2.Config.GetSetting("addnode", "main"); got != "drynet3.drivechain.dev:8337" {
		t.Errorf("addnode = %q, want the drynet3 peer", got)
	}
	if got := m2.Config.GetSetting("uacomment", "main"); got != "drynet3" {
		t.Errorf("uacomment = %q, want drynet3", got)
	}
}

// With no resolved catalog the embedded generation is used, so a first boot
// still writes a reachable peer instead of an empty addnode.
func TestDrynetFallsBackToEmbeddedGeneration(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkDrynet}
	generation := m.Generation()
	if generation == "" {
		t.Fatal("Generation() must fall back to the embedded catalog")
	}
	if got := m.DrynetPeer(); got != netcatalog.EmbeddedPeer(generation) || got == "" {
		t.Errorf("DrynetPeer() = %q, want the embedded seed address for %s", got, generation)
	}
}

// A generation nothing has published an address for gets no addnode at all.
// Guessing the port sent bitcoind somewhere nothing listens.
func TestDrynetWithoutPublishedPeerWritesNoAddnode(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkDrynet, DrynetID: "drynet99"}
	if got := m.DrynetPeer(); got != "" {
		t.Errorf("DrynetPeer() = %q, want empty for an unpublished generation", got)
	}
	if conf := m.GetDefaultConfig(); strings.Contains(conf, "addnode=drynet") {
		t.Errorf("unpublished generation must not write an addnode line, got:\n%s", conf)
	}

	m2 := &BitcoinConfManager{Config: NewBitcoinConfig(), DrynetID: "drynet99", log: zerolog.Nop()}
	m2.applyMainSectionDefaults(NetworkDrynet)
	if got := m2.Config.GetSetting("addnode", "main"); got != "" {
		t.Errorf("addnode = %q, want it left unset", got)
	}
}

// The forknet and drynet configs both say chain=main + drivechain=1; only the
// uacomment sentinel tells them apart. Round-trip each generated config back
// through the detector to prove they don't collide.
func TestNetworkFromConfigDistinguishesDrynetFromForknet(t *testing.T) {
	forknet := ParseBitcoinConfig((&BitcoinConfManager{Network: NetworkForknet}).GetDefaultConfig())
	if got := NetworkFromConfig(forknet); got != NetworkForknet {
		t.Errorf("forknet config detected as %q, want forknet", got)
	}
	drynet := ParseBitcoinConfig((&BitcoinConfManager{Network: NetworkDrynet}).GetDefaultConfig())
	if got := NetworkFromConfig(drynet); got != NetworkDrynet {
		t.Errorf("drynet config detected as %q, want drynet", got)
	}
}

// The sentinel carries the generation, so detection must match on the prefix:
// a future drynet3 conf has to stay drynet rather than falling through to
// forknet, which would silently drop the drynet datadir slot.
func TestNetworkFromConfigDetectsFutureDrynetGeneration(t *testing.T) {
	conf := ParseBitcoinConfig((&BitcoinConfManager{Network: NetworkDrynet}).GetDefaultConfig())
	conf.SetSetting("uacomment", "drynet3", "main")
	if got := NetworkFromConfig(conf); got != NetworkDrynet {
		t.Errorf("drynet3 config detected as %q, want drynet", got)
	}
}

// Drynet's config says chain=main + drivechain=1. Round-trip the generated
// config back through the detector to prove it is not read as mainnet.
func TestNetworkFromConfigDetectsDrynet(t *testing.T) {
	drynet := ParseBitcoinConfig((&BitcoinConfManager{Network: NetworkDrynet}).GetDefaultConfig())
	if got := NetworkFromConfig(drynet); got != NetworkDrynet {
		t.Errorf("drynet config detected as %q, want drynet", got)
	}
}

// ---------------------------------------------------------------------------
// Copy config downstream
// ---------------------------------------------------------------------------

func TestCopyConfigDownstream(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkSignet

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	if err := m.CopyConfigDownstream(); err != nil {
		t.Fatal(err)
	}

	destPath := m.getDownstreamConfigPath()
	data, err := os.ReadFile(destPath)
	if err != nil {
		t.Fatalf("downstream file not created: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "READ-ONLY COPY") {
		t.Error("downstream should contain read-only header")
	}
	if !strings.Contains(content, "chain=signet") {
		t.Error("downstream should contain original config content")
	}
}

// ---------------------------------------------------------------------------
// HasDatadirForNetwork
// ---------------------------------------------------------------------------

func TestHasDatadirForNetwork(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Config = NewBitcoinConfig()

	// No datadir anywhere — mainnet/drynet should be false
	if m.HasDatadirForNetwork(NetworkDrynet) {
		t.Error("drynet should be false when slot is empty")
	}
	if m.HasDatadirForNetwork(NetworkMainnet) {
		t.Error("mainnet should be false when slot/datadir is empty")
	}

	// Non-mainnet/drynet — always true (signet/test/regtest use bitcoind defaults).
	if !m.HasDatadirForNetwork(NetworkSignet) {
		t.Error("signet should always return true")
	}

	// Drynet only honours its own slot, not the live datadir or default slot.
	m.Config.SetSetting("datadir", "/some/path")
	m.Config.SetGroupDatadir(DatadirGroupDefault, "/some/path")
	if m.HasDatadirForNetwork(NetworkDrynet) {
		t.Error("drynet should ignore default-group datadir")
	}
	m.Config.SetGroupDatadir(DatadirGroupDrynet, "/drynet/path")
	if !m.HasDatadirForNetwork(NetworkDrynet) {
		t.Error("drynet should be true when drynet slot is set")
	}

	// Forknet has its own slot, independent of drynet's.
	if m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("forknet should ignore drynet-group datadir")
	}
	m.Config.SetGroupDatadir(DatadirGroupForknet, "/forknet/path")
	if !m.HasDatadirForNetwork(NetworkForknet) {
		t.Error("forknet should be true when forknet slot is set")
	}

	// Section-scoped datadir is ignored — Bitcoin Core only honours the
	// top-level value.
	m3 := newTestManager(tmpDir)
	m3.Config = NewBitcoinConfig()
	m3.Config.SetSetting("datadir", "/section/only", "main")
	if m3.HasDatadirForNetwork(NetworkMainnet) {
		t.Error("section-scoped datadir must not satisfy HasDatadirForNetwork")
	}
}

// A hand-edited conf carries a top-level datadir= but no slot comment. The
// load must adopt it, or the app sends the user to the datadir picker again.
func TestLoadAdoptsTopLevelDatadirIntoActiveSlot(t *testing.T) {
	for _, tc := range []struct {
		name  string
		conf  string
		group DatadirGroup
	}{
		{"drynet", "chain=main\ndatadir=/vol/drynet\n[main]\ndrivechain=1\nuacomment=drynet4\n", DatadirGroupDrynet},
		{"mainnet", "chain=main\ndatadir=/vol/mainnet\n", DatadirGroupDefault},
		{"signet", "chain=signet\ndatadir=/vol/shared\n", DatadirGroupDefault},
	} {
		t.Run(tc.name, func(t *testing.T) {
			m := newTestManager(t.TempDir())
			m.parseAndApplyConfig(tc.conf)

			require.Equal(t, tc.group, DatadirGroupForNetwork(m.Network))
			require.Equal(t, m.DetectedDataDir, m.Config.GetGroupDatadir(tc.group))
			require.True(t, m.HasDatadirForNetwork(m.Network))
		})
	}
}

// Bitcoin Core ignores a section-scoped datadir, so adopting one would let the
// picker pass while Core writes the chain into the platform default folder.
func TestLoadIgnoresSectionScopedDatadir(t *testing.T) {
	m := newTestManager(t.TempDir())
	m.parseAndApplyConfig("chain=main\n[main]\ndatadir=/section/only\n")

	require.Equal(t, NetworkMainnet, m.Network)
	require.Empty(t, m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.False(t, m.HasDatadirForNetwork(NetworkMainnet))
}

// A section that overrides the top-level line points DetectedDataDir somewhere
// Bitcoin Core does not use, so the picker must still run.
func TestLoadIgnoresConflictingSectionDatadir(t *testing.T) {
	m := newTestManager(t.TempDir())
	m.parseAndApplyConfig("chain=main\ndatadir=/global/path\n[main]\ndatadir=/section/path\n")

	require.Equal(t, "/section/path", m.DetectedDataDir)
	require.Empty(t, m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.False(t, m.HasDatadirForNetwork(NetworkMainnet))
}

// Signet shares the default group's root, so a swap to mainnet must reuse the
// path the user already picked instead of asking for it again.
func TestSignetDatadirSatisfiesMainnet(t *testing.T) {
	m := newTestManager(t.TempDir())
	m.parseAndApplyConfig("chain=signet\ndatadir=/vol/shared\n")

	require.Equal(t, NetworkSignet, m.Network)
	require.True(t, m.HasDatadirForNetwork(NetworkMainnet))
	require.False(t, m.HasDatadirForNetwork(NetworkDrynet), "drynet keeps its own slot")
}

// Regression: UpdateDataDir writes datadir to the global section (Bitcoin
// Core only honours top-level datadir), so loadStateFromConfig must read
// the global value too. Reading only [main] left DetectedDataDir empty
// after reload, which made DataDirGuard re-prompt and reject the resulting
// navigation — symptom: blank white screen on mainnet boot.
func TestDetectedDataDirSurvivesReloadAfterUpdate(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	chosen := filepath.Join(tmpDir, "blocks")
	require.NoError(t, m.UpdateDataDir(chosen, NetworkMainnet))
	require.Equal(t, chosen, m.DetectedDataDir, "datadir must be visible immediately after UpdateDataDir")

	m2 := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkMainnet,
		log:          zerolog.Nop(),
	}
	require.NoError(t, m2.LoadConfig(true))
	require.Equal(t, chosen, m2.DetectedDataDir, "datadir written to global must be detected after reload")
}

// Per-section datadir still wins when present — covers users with their own
// bitcoin.conf that scopes datadir under [main].
func TestDetectedDataDirPrefersPerNetworkSection(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/global/path")
	m.Config.SetSetting("datadir", "/main/path", "main")

	m.loadStateFromConfig()

	require.Equal(t, NetworkMainnet, m.Network)
	require.Equal(t, "/main/path", m.DetectedDataDir)
}

// ---------------------------------------------------------------------------
// UpdateDataDir + materialize/snapshot semantics
// ---------------------------------------------------------------------------

// UpdateDataDir for the inactive group must NOT touch the active datadir=
// line — only the slot is recorded.
func TestUpdateDataDirInactiveGroupLeavesActiveAlone(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkDrynet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("drivechain", "1", "main")
	m.Config.SetSetting("datadir", "/drynet/live")
	m.Config.SetGroupDatadir(DatadirGroupDrynet, "/drynet/live")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	picked := filepath.Join(tmpDir, "picked", "for", "mainnet")
	require.NoError(t, m.UpdateDataDir(picked, NetworkMainnet))

	require.Equal(t, picked, m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/drynet/live", m.Config.GetSetting("datadir"), "active datadir must not change when setting inactive group")
}

// UpdateDataDir for the active group must update both the slot AND the live
// datadir= line so bitcoind sees the new path.
func TestUpdateDataDirActiveGroupUpdatesLive(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	picked := filepath.Join(tmpDir, "picked", "for", "mainnet")
	require.NoError(t, m.UpdateDataDir(picked, NetworkMainnet))

	require.Equal(t, picked, m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, picked, m.Config.GetSetting("datadir"))
}

// Manual edit: rewrite datadir= directly on disk, reload, swap to drynet —
// default slot must reflect the manual value (snapshot adopts the live edit).
func TestSwapAdoptsManuallyEditedDatadirIntoSlot(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/manually/edited")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	// Pre-stage drynet path so the swap is allowed.
	m.Config.SetGroupDatadir(DatadirGroupDrynet, "/drynet/path")
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))
	require.NoError(t, m.LoadConfig(false))

	require.NoError(t, m.UpdateNetwork(NetworkDrynet))

	require.Equal(t, "/manually/edited", m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/drynet/path", m.Config.GetSetting("datadir"))
}

// Within-group swap (mainnet ↔ signet) leaves datadir= alone — Bitcoin Core's
// chain subdirs partition the four default networks under the same folder.
func TestUpdateNetworkWithinDefaultGroupKeepsDatadir(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkMainnet
	m.Config.SetSetting("chain", "main")
	m.Config.SetSetting("datadir", "/shared/default")

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte(m.Config.Serialize()), 0644))

	require.NoError(t, m.UpdateNetwork(NetworkSignet))

	require.Equal(t, "/shared/default", m.Config.GetSetting("datadir"))
	require.Equal(t, "/shared/default", m.Config.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "", m.Config.GetGroupDatadir(DatadirGroupDrynet), "the drynet slot stays its own")
}

// applyMainSectionDefaults: signet → drynet adds drivechain=1 + alt ports
// under [main]; drynet → mainnet strips them.
func TestApplyMainSectionDefaultsDrynetThenMainnet(t *testing.T) {
	m := &BitcoinConfManager{Config: NewBitcoinConfig(), DrynetID: "drynet4", log: zerolog.Nop()}
	m.Config.SetSetting("chain", "signet")

	m.applyMainSectionDefaults(NetworkDrynet)
	require.Equal(t, "1", m.Config.GetSetting("drivechain", "main"))
	require.Equal(t, "8301", m.Config.GetSetting("port", "main"))
	require.Equal(t, "18302", m.Config.GetSetting("rpcport", "main"))
	require.Equal(t, "0.00021", m.Config.GetSetting("fallbackfee", "main"))
	require.Equal(t, "drynet4.drivechain.dev:8533", m.Config.GetSetting("addnode", "main"))
	require.Equal(t, "drynet4", m.Config.GetSetting("uacomment", "main"))

	m.applyMainSectionDefaults(NetworkMainnet)
	require.Equal(t, "", m.Config.GetSetting("drivechain", "main"))
	require.Equal(t, "", m.Config.GetSetting("port", "main"))
	require.Equal(t, "", m.Config.GetSetting("rpcport", "main"))
	require.Equal(t, "", m.Config.GetSetting("fallbackfee", "main"))
	require.Equal(t, "", m.Config.GetSetting("addnode", "main"))
	require.Equal(t, "", m.Config.GetSetting("uacomment", "main"))
}

// ---------------------------------------------------------------------------
// UpdateNetwork
// ---------------------------------------------------------------------------

func TestUpdateNetworkCallsCallback(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	called := false
	m.OnNetworkChanged = func() { called = true }

	if err := m.UpdateNetwork(NetworkRegtest); err != nil {
		t.Fatal(err)
	}

	if !called {
		t.Error("OnNetworkChanged callback should have been called")
	}
}

func TestUpdateNetworkNoCallbackWhenSameNetwork(t *testing.T) {
	tmpDir := t.TempDir()
	m := newTestManager(tmpDir)
	m.Network = NetworkSignet

	masterPath := m.getBitWindowConfigPath()
	require.NoError(t, os.MkdirAll(filepath.Dir(masterPath), 0755))
	require.NoError(t, os.WriteFile(masterPath, []byte("chain=signet\n"), 0644))

	called := false
	m.OnNetworkChanged = func() { called = true }

	if err := m.UpdateNetwork(NetworkSignet); err != nil {
		t.Fatal(err)
	}

	if called {
		t.Error("OnNetworkChanged should not be called when network unchanged")
	}
}

// ---------------------------------------------------------------------------
// Full LoadConfig
// ---------------------------------------------------------------------------

func TestLoadConfigFromScratch(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(true); err != nil {
		t.Fatal(err)
	}

	if m.Config == nil {
		t.Fatal("config should not be nil after load")
	}
	if m.Network != NetworkSignet {
		t.Errorf("network = %s, want signet", m.Network)
	}

	if m.Config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("config version = %d, want %d", m.Config.ConfigVersion, BitcoinConfMigrationsVersion)
	}
}

func TestLoadConfigIdempotent(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}
	v1 := m.Config.ConfigVersion

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	if m.Config.ConfigVersion != v1 {
		t.Errorf("version changed from %d to %d on reload", v1, m.Config.ConfigVersion)
	}
}

// ---------------------------------------------------------------------------
// File watching
// ---------------------------------------------------------------------------

func TestFileWatchingTriggersReload(t *testing.T) {
	tmpDir := t.TempDir()
	m := &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		log:          zerolog.Nop(),
	}

	if err := m.LoadConfig(false); err != nil {
		t.Fatal(err)
	}

	if err := m.StartWatching(); err != nil {
		t.Fatal(err)
	}
	defer m.StopWatching()

	confPath := m.getBitWindowConfigPath()
	newConfig := NewBitcoinConfig()
	newConfig.ConfigVersion = BitcoinConfMigrationsVersion
	newConfig.GlobalSettings["chain"] = "regtest"
	newConfig.GlobalSettings["uacomment"] = "BitWindow-0.2"
	if err := os.WriteFile(confPath, []byte(newConfig.Serialize()), 0644); err != nil {
		t.Fatal(err)
	}

	time.Sleep(300 * time.Millisecond)

	if m.Network != NetworkRegtest {
		t.Errorf("network = %s, want regtest (should have reloaded)", m.Network)
	}
}

// ---------------------------------------------------------------------------
// Datadir slot accessors + round-trip
// ---------------------------------------------------------------------------

func TestDatadirSlotsRoundTrip(t *testing.T) {
	src := `# bitwindow-bitcoin-conf-version=8

# bitwindow-datadir-default=/Volumes/SSD/bitcoin
# bitwindow-datadir-drynet=/Volumes/HDD/drynet

datadir=/Volumes/SSD/bitcoin
chain=signet
`
	c := ParseBitcoinConfig(src)
	require.Equal(t, "/Volumes/SSD/bitcoin", c.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/Volumes/HDD/drynet", c.GetGroupDatadir(DatadirGroupDrynet))

	c.SetGroupDatadir(DatadirGroupDrynet, "/new/drynet/path")

	out := c.Serialize()
	require.Contains(t, out, "# bitwindow-datadir-default=/Volumes/SSD/bitcoin\n")
	require.Contains(t, out, "# bitwindow-datadir-drynet=/new/drynet/path\n")

	// Stable order: default before drynet
	defIdx := strings.Index(out, "# bitwindow-datadir-default=")
	fkIdx := strings.Index(out, "# bitwindow-datadir-drynet=")
	require.Greater(t, fkIdx, defIdx, "default slot should serialize before drynet slot")

	// Re-parse, values stable
	c2 := ParseBitcoinConfig(out)
	require.Equal(t, "/Volumes/SSD/bitcoin", c2.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/new/drynet/path", c2.GetGroupDatadir(DatadirGroupDrynet))
}

func TestDatadirSlotsClearedOnEmpty(t *testing.T) {
	c := NewBitcoinConfig()
	c.SetGroupDatadir(DatadirGroupDrynet, "/some/path")
	require.Equal(t, "/some/path", c.GetGroupDatadir(DatadirGroupDrynet))
	c.SetGroupDatadir(DatadirGroupDrynet, "")
	require.Equal(t, "", c.GetGroupDatadir(DatadirGroupDrynet))

	out := c.Serialize()
	require.NotContains(t, out, "# bitwindow-datadir-drynet=")
}

func TestDatadirGroupForNetwork(t *testing.T) {
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkMainnet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkSignet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkTestnet))
	require.Equal(t, DatadirGroupDefault, DatadirGroupForNetwork(NetworkRegtest))
	require.Equal(t, DatadirGroupDrynet, DatadirGroupForNetwork(NetworkDrynet))
}

func TestGroupDatadirForPick(t *testing.T) {
	require.Equal(t, "/x/forknet", GroupDatadirForPick(DatadirGroupForknet, "/x"))
	require.Equal(t, "/x/drynet", GroupDatadirForPick(DatadirGroupDrynet, "/x"))
	require.Equal(t, "/x/forknet", GroupDatadirForPick(DatadirGroupForknet, "/x/"), "trailing slash")
	require.Equal(t, "/x", GroupDatadirForPick(DatadirGroupDefault, "/x"), "default group untouched")
	require.Equal(t, "", GroupDatadirForPick(DatadirGroupForknet, ""))

	// A directory that merely looks normalized still gets its own component,
	// so picking /data/forknet for both mainnet and forknet cannot collide.
	require.Equal(t, "/data/forknet/forknet", GroupDatadirForPick(DatadirGroupForknet, "/data/forknet"))
	require.NotEqual(t,
		GroupDatadirForPick(DatadirGroupDefault, "/data/forknet"),
		GroupDatadirForPick(DatadirGroupForknet, "/data/forknet"),
	)
}

// Slots already on disk record the real Core datadir. Rewriting them on parse
// would point the next swap at a new empty directory and strand the chain and
// wallets at the old path.
func TestParsePreservesExistingSlotPaths(t *testing.T) {
	c := ParseBitcoinConfig(`# bitwindow-datadir-default=/mnt/main
# bitwindow-datadir-forknet=/mnt/fork-chain
# bitwindow-datadir-drynet=/mnt/dry-chain

chain=main
`)
	require.Equal(t, "/mnt/main", c.GetGroupDatadir(DatadirGroupDefault))
	require.Equal(t, "/mnt/fork-chain", c.GetGroupDatadir(DatadirGroupForknet))
	require.Equal(t, "/mnt/dry-chain", c.GetGroupDatadir(DatadirGroupDrynet))

	require.Equal(t, c.Serialize(), ParseBitcoinConfig(c.Serialize()).Serialize(), "round-trip must be stable")
}

// The whole point of the suffix: even when the user points both groups at the
// same folder, forknet and mainnet resolve to different bitcoind datadirs.
func TestSameSlotPathStillSeparatesForknetFromMainnet(t *testing.T) {
	const picked = "/Volumes/BTC"
	c := NewBitcoinConfig()
	for _, g := range []DatadirGroup{DatadirGroupDefault, DatadirGroupForknet, DatadirGroupDrynet} {
		c.SetGroupDatadir(g, GroupDatadirForPick(g, picked))
	}

	mainnet := c.GetGroupDatadir(DatadirGroupDefault)
	forknet := c.GetGroupDatadir(DatadirGroupForknet)
	drynet := c.GetGroupDatadir(DatadirGroupDrynet)

	require.Equal(t, picked, mainnet)
	require.Equal(t, "/Volumes/BTC/forknet", forknet)
	require.Equal(t, "/Volumes/BTC/drynet", drynet)

	resolved := map[string]bool{
		BitcoinCoreDirs.DatadirNetwork(NetworkMainnet, mainnet): true,
		BitcoinCoreDirs.DatadirNetwork(NetworkForknet, forknet): true,
		BitcoinCoreDirs.DatadirNetwork(NetworkDrynet, drynet):   true,
	}
	require.Len(t, resolved, 3, "no two chain=main networks may share bitcoind's datadir")
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func newTestManager(tmpDir string) *BitcoinConfManager {
	log := zerolog.Nop()
	return &BitcoinConfManager{
		BitwindowDir: tmpDir,
		Network:      NetworkSignet,
		Config:       NewBitcoinConfig(),
		log:          log,
	}
}
