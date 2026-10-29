package orchestrator

import (
	"context"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"slices"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

const (
	ecashMainnetID           = "ecash-mainnet"
	ecashMainnetForkHeight   = 973728
	ecashMainnetLockTime     = 499999998
	ecashMainnetReleaseURL   = "https://releases.ecash.com/L1-ecash-bitcoin/mainnet/latest/"
	fixtureReleaseURL        = "https://releases.ecash.com/L1-ecash-bitcoin/ecash-mainnet/latest/"
	betanetReleaseURL        = "https://releases.ecash.com/L1-ecash-bitcoin/betanet/latest/"
	betanetAndMainnetShared  = 967679
	alphanetAndMainnetShared = 963647
)

// ecashMainnetFixture is the published document once the real eCash network
// lands: bitcoin, signet, alphanet, betanet, ecash-mainnet.
func ecashMainnetFixture(t *testing.T) netcatalog.Catalog {
	t.Helper()
	raw, err := os.ReadFile(filepath.Join("config", "netcatalog", "testdata", "ecash-mainnet.json"))
	require.NoError(t, err)
	var c netcatalog.Catalog
	require.NoError(t, json.Unmarshal(raw, &c))
	_, ok := c.ByID(ecashMainnetID)
	require.True(t, ok)
	return c
}

// withoutRow is the document as it reads before a row lands.
func withoutRow(c netcatalog.Catalog, id string) netcatalog.Catalog {
	c.Networks = slices.DeleteFunc(slices.Clone(c.Networks), func(n netcatalog.Network) bool { return n.ID == id })
	return c
}

func keepNetworkGlobals(t *testing.T) {
	t.Helper()
	endpoints, id := config.ECashEndpoints(), config.ECashNetworkID()
	height := config.PublishedForkHeight(config.NetworkECash)
	name := config.PublishedDisplayName(config.NetworkECash)
	bitcoin := config.PublishedEndpoints(config.NetworkMainnet)
	t.Cleanup(func() {
		config.SetECashEndpoints(endpoints)
		config.SetECashNetworkID(id)
		config.SetForkHeight(config.NetworkECash, height)
		config.SetNetworkDisplayName(config.NetworkECash, name)
		config.SetNetworkEndpoints(config.NetworkMainnet, bitcoin)
	})
}

// ecashInstallOn puts an eCash install on id, with the document that has no
// ecash-mainnet row yet, then takes the document that lists it last.
func ecashInstallOn(t *testing.T, id string) *Orchestrator {
	t.Helper()
	keepNetworkGlobals(t)
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupDefault, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.coreReachable = func() bool { return false }
	o.adoptCatalog(withoutRow(ecashMainnetFixture(t), ecashMainnetID), id)
	require.Equal(t, id, o.installedECashNetwork())
	o.adoptCatalogRows(ecashMainnetFixture(t), id)
	return o
}

func TestTheECashMainnetRowNeverMapsToBitcoinMainnet(t *testing.T) {
	keepNetworkGlobals(t)
	cat := ecashMainnetFixture(t)
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)
	o := newTestOrchestrator(t)

	o.adoptCatalog(cat, ecashMainnetID)

	require.Zero(t, config.PublishedForkHeight(config.NetworkMainnet), "BTC mainnet has no fork")
	require.Equal(t, bitcoin, config.PublishedEndpoints(config.NetworkMainnet))
	require.Equal(t, "Bitcoin", config.PublishedDisplayName(config.NetworkMainnet))
	require.Equal(t, "https://esplora.mainnet.drivechain.info", config.EsploraURLForNetwork(config.NetworkMainnet))
	host, port := config.ElectrumHostPortForNetwork(config.NetworkMainnet)
	require.Equal(t, "ssl://explorer.mainnet.drivechain.info", host)
	require.EqualValues(t, 50002, port)

	for id, want := range map[string]config.Network{
		"bitcoin":      config.NetworkMainnet,
		"mainnet":      config.NetworkMainnet,
		ecashMainnetID: config.NetworkECash,
		"betanet":      config.NetworkECash,
	} {
		got, ok := o.NetworkForOption(id)
		require.True(t, ok, id)
		require.Equal(t, want, got, id)
	}
	_, ok = config.LookupNetwork(ecashMainnetID)
	require.False(t, ok, "an eCash id names no network slot")

	slots := map[string]config.Network{}
	for _, opt := range o.ListNetworks() {
		slots[opt.ID] = opt.Network
	}
	require.Equal(t, config.NetworkECash, slots[ecashMainnetID])
	require.Equal(t, config.NetworkMainnet, slots["bitcoin"])

	require.Equal(t, ecashMainnetID, config.ECashNetworkID())
	require.Equal(t, ecashMainnetForkHeight, config.PublishedForkHeight(config.NetworkECash))
	require.Equal(t, "eCash Mainnet", config.PublishedDisplayName(config.NetworkECash))
	require.EqualValues(t, ecashMainnetLockTime, liveReplayLockTime(t))
	require.Equal(t, "https://esplora.mainnet.ecash.example", config.EsploraURLForNetwork(config.NetworkECash))
}

func TestReadDatadirNetworkKeepsBitcoinAndECashMainnetApart(t *testing.T) {
	keepNetworkGlobals(t)
	cat := ecashMainnetFixture(t)
	bitcoin, _ := cat.ByID("bitcoin")
	ecash, _ := cat.ByID(ecashMainnetID)

	o := fullModeInstall(t)
	o.setNetwork(string(config.NetworkMainnet))
	o.BitcoinConf.Network = config.NetworkMainnet
	o.Catalog = cat
	o.ecashID = ecashMainnetID
	require.Equal(t, "mainnet", o.SelectedNetworkID(cat))
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)
	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
	require.Equal(t, "bitcoin", out.SelectedID)
	require.False(t, out.Mismatch)

	o = fullModeInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.Catalog = cat
	o.ecashID = ecashMainnetID
	require.Equal(t, ecashMainnetID, o.SelectedNetworkID(cat))
	writeBlockFile(t, o.BitcoinConf.DataDir(), ecash.NetworkMagic)
	out, err = o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, ecashMainnetID, out.DetectedID)
	require.Equal(t, "eCash Mainnet", out.SelectedName)
	require.False(t, out.Mismatch)

	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)
	out, err = o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
	require.True(t, out.Mismatch, "BTC blocks under an eCash Mainnet pick disagree")
}

func TestTheReleaseChannelPicksTheL1Download(t *testing.T) {
	keepNetworkGlobals(t)
	o := newTestOrchestrator(t)
	o.adoptCatalogRows(ecashMainnetFixture(t), ecashMainnetID)

	published := o.configs["bitcoind"].Variants["ecash"]
	require.Equal(t, fixtureReleaseURL, published.BaseURL,
		"a published release channel never picks the download")
	require.Equal(t, ecashMainnetID, published.Subfolder, "the install folder keeps the id")

	v := expandECashPlaceholder(o.rawConfigs["bitcoind"], "ecash").Variants["ecash"]
	require.Equal(t, ecashMainnetReleaseURL, v.BaseURL)
	require.Equal(t, "ecash", v.Subfolder)
	require.Equal(t, "L1-ecash-bitcoin-latest-aarch64-apple-darwin.zip", v.Files["macos-arm64"])
	require.Equal(t, "L1-ecash-bitcoin-latest-x86_64-apple-darwin.zip", v.Files["macos-x86_64"])
	require.Equal(t, "L1-ecash-bitcoin-latest-x86_64-unknown-linux-gnu.zip", v.Files["linux-x86_64"])
	require.Equal(t, "L1-ecash-bitcoin-latest-x86_64-w64-msvc.zip", v.Files["windows-x86_64"])

	betanet := expandECashPlaceholder(o.rawConfigs["bitcoind"], "betanet").Variants["ecash"]
	require.Equal(t, betanetReleaseURL, betanet.BaseURL)
	require.Equal(t, "betanet", betanet.Subfolder)

	unlisted := expandECashPlaceholder(o.rawConfigs["bitcoind"], "drynet9").Variants["ecash"]
	require.Equal(t, "https://releases.ecash.com/L1-ecash-bitcoin/drynet9/latest/", unlisted.BaseURL)

	o.adoptCatalogRows(withoutRow(ecashMainnetFixture(t), ecashMainnetID), "betanet")
	require.Equal(t, betanetReleaseURL, o.configs["bitcoind"].Variants["ecash"].BaseURL)
}

func TestBetanetIsOfferedECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "betanet")

	pending := o.PendingECashUpgrade()
	require.Equal(t, ecashMainnetID, pending.ID, "973728 is above 967680, so it is newer")
	require.Equal(t, "seed.mainnet.ecash.example:8533", pending.Peer)
	require.False(t, pending.UserManagedConf)
	require.Equal(t, "betanet", config.ECashNetworkID(), "the offer moves nothing")
}

func TestAlphanetIsOfferedECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "alphanet")

	require.Equal(t, ecashMainnetID, o.PendingECashUpgrade().ID)
}

func requireOnECashMainnet(t *testing.T, o *Orchestrator) {
	t.Helper()
	require.Empty(t, o.PendingECashUpgrade().ID, "the prompt clears once confirmed")
	require.Equal(t, ecashMainnetID, config.ECashNetworkID())
	require.Equal(t, ecashMainnetID, o.installedECashNetwork())
	require.Equal(t, ecashMainnetID, o.Settings.ECashChainID())
	require.Equal(t, ecashMainnetID, o.Settings.ECashNetworkID())
	require.Equal(t, "ecash-ecash-mainnet", o.BitcoinConf.Config.GetEffectiveSetting("uacomment", "main"))
	require.Equal(t, "seed.mainnet.ecash.example:8533", o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"))
	require.Equal(t, ecashMainnetForkHeight, config.PublishedForkHeight(config.NetworkECash))
	require.Equal(t, fixtureReleaseURL, o.configs["bitcoind"].Variants["ecash"].BaseURL)

	lockTime := liveReplayLockTime(t)
	require.EqualValues(t, ecashMainnetLockTime, lockTime)
	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{}, nil, nil))
	replay.ApplyLockTime(tx, lockTime)
	require.EqualValues(t, ecashMainnetLockTime, tx.LockTime)
	require.True(t, replay.Protected(ecashMainnetLockTime, tx.LockTime, []uint32{tx.TxIn[0].Sequence}))
	require.False(t, replay.Protected(netcatalog.DefaultReplayLockTime, tx.LockTime, []uint32{tx.TxIn[0].Sequence}),
		"a betanet node reads the eCash Mainnet stamp as non-final")
}

func TestConfirmMovesBetanetOntoECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "betanet")
	require.EqualValues(t, netcatalog.DefaultReplayLockTime, liveReplayLockTime(t))

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	requireOnECashMainnet(t, o)
}

func TestConfirmMovesAlphanetOntoECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "alphanet")

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	requireOnECashMainnet(t, o)
}

func TestConfirmOffECashRecordsTheECashMainnetMove(t *testing.T) {
	o := ecashInstallOn(t, "betanet")
	ecashDir := o.BitcoinConf.Config.GetGroupDatadir(config.DatadirGroupECash)
	blocks := filepath.Join(ecashDir, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o755))
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.Equal(t, ecashMainnetID, o.PendingECashUpgrade().ID)

	require.NoError(t, o.ConfirmPendingECashNetwork(context.Background()))

	require.DirExists(t, blocks, "the blocks below the fork survive the confirm")
	require.Equal(t, ecashMainnetID, o.Settings.ECashNetworkID())
	require.Equal(t, string(config.NetworkMainnet), o.Network)
	require.Zero(t, config.PublishedForkHeight(config.NetworkMainnet))
}

func TestPlanECashMainnetSwitchRewindsToTheSharedBlock(t *testing.T) {
	for _, tc := range []struct {
		from, to string
		height   uint32
	}{
		{"betanet", ecashMainnetID, betanetAndMainnetShared},
		{"alphanet", ecashMainnetID, alphanetAndMainnetShared},
		{ecashMainnetID, "betanet", betanetAndMainnetShared},
		{ecashMainnetID, "alphanet", alphanetAndMainnetShared},
	} {
		t.Run(tc.from+"->"+tc.to, func(t *testing.T) {
			keepNetworkGlobals(t)
			o := newTestOrchestrator(t)
			o.adoptCatalog(ecashMainnetFixture(t), tc.from)

			plan, err := o.PlanECashSwitch(tc.to)

			require.NoError(t, err)
			require.False(t, plan.Blocked)
			require.True(t, plan.NeedsRollback)
			require.Equal(t, tc.from, plan.FromID)
			require.Equal(t, tc.to, plan.ToID)
			require.EqualValues(t, tc.height, plan.RewindHeight)
		})
	}
}

func TestApplyECashSwitchRewindsBetanetOntoECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "betanet")
	core := &fakeCore{tips: []int64{980000}, hashes: map[int64]string{980000: tipBlock, 967680: forkBlock}}
	attachFakeCore(t, o, core)
	o.process.AdoptProcess(o.configs["bitcoind"], 1)
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		o.process.Remove(name)
		return nil
	}
	for _, name := range []string{"bitcoind", "enforcer"} {
		cfg := o.rawConfigs[name]
		cfg.DownloadURLs = nil
		o.rawConfigs[name] = cfg
	}
	o.download.CoreVariant = nil
	restarted := make(chan struct{})
	o.log = zerolog.New(io.Discard).Hook(zerolog.HookFunc(func(_ *zerolog.Event, _ zerolog.Level, message string) {
		if message == "L1 stack restart after network swap failed" {
			close(restarted)
		}
	}))

	require.NoError(t, o.ApplyECashSwitch(context.Background(), ecashMainnetID))

	require.Equal(t, []string{"invalidateblock"}, marks(core))
	require.Equal(t, []string{forkBlock}, markParams(core), "the first betanet block above 967679 goes")
	require.Equal(t, forkBlock, o.Settings.RewoundBlockHash())
	require.Equal(t, ecashMainnetID, o.installedECashNetwork())
	require.EqualValues(t, ecashMainnetLockTime, liveReplayLockTime(t))
	select {
	case <-restarted:
	case <-time.After(5 * time.Second):
		t.Fatal("the fixture restart did not finish")
	}
}

// betanet -> alphanet is no upgrade today, and the move back from eCash
// Mainnet obeys the same rule: no offer, but the picker still reaches it.
func TestECashMainnetOffersNoMoveBack(t *testing.T) {
	for _, tc := range []struct{ from, back string }{
		{ecashMainnetID, "betanet"},
		{"betanet", "alphanet"},
	} {
		t.Run(tc.from+"->"+tc.back, func(t *testing.T) {
			keepNetworkGlobals(t)
			o := newTestOrchestrator(t)
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
			require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
			o.coreReachable = func() bool { return false }
			o.adoptCatalog(ecashMainnetFixture(t), tc.from)
			backLast := ecashMainnetFixture(t)
			back, _ := backLast.ByID(tc.back)
			backLast = withoutRow(backLast, tc.back)
			backLast.Networks = append(backLast.Networks, back)
			o.adoptCatalogRows(backLast, tc.from)
			require.Equal(t, tc.back, o.Catalog.ECashID())

			require.Empty(t, o.PendingECashUpgrade().ID, "a lower fork height is no upgrade")
			require.Error(t, o.ConfirmPendingECashNetwork(context.Background()))
			require.Equal(t, tc.from, config.ECashNetworkID())

			require.NoError(t, o.SelectECashNetwork(tc.back))
			require.Equal(t, tc.back, o.Settings.ECashNetworkID())
			require.Equal(t, tc.back, o.Settings.PendingEnforcerWipe())
		})
	}
}

func TestECashMigrationOntoECashMainnetNeedsNoTargetParentHash(t *testing.T) {
	cat := ecashMainnetFixture(t)
	for _, from := range []string{"betanet", "alphanet"} {
		require.NoError(t, CheckECashConversion(cat, from, ecashMainnetID), from)
	}
	require.ErrorContains(t, CheckECashConversion(cat, ecashMainnetID, "betanet"), "must fork BTC after the source")

	for i := range cat.Networks {
		if cat.Networks[i].ID == "betanet" {
			cat.Networks[i].ForkParentHash = ""
		}
	}
	require.ErrorContains(t, CheckECashConversion(cat, "betanet", ecashMainnetID), "fork_parent_hash")
}

func TestECashMigrationMovesBetanetOntoECashMainnet(t *testing.T) {
	o := ecashInstallOn(t, "betanet")
	require.NoError(t, o.recordECashChain("betanet"))
	betanet, _ := o.Catalog.ByID("betanet")

	state, err := o.newMigration(context.Background(), "betanet", ecashMainnetID)
	require.NoError(t, err)
	require.EqualValues(t, betanetAndMainnetShared, state.Status.CommonHeight)
	require.Equal(t, betanet.ForkParentHash, state.Status.CommonHash)
	require.Equal(t, "eca5b104", state.Status.SourceMagic)
	require.Equal(t, "eca5dcb7", state.Status.TargetMagic)
	require.Equal(t, betanetReleaseURL, state.FromConfig.Variants["ecash"].BaseURL)
	require.Equal(t, fixtureReleaseURL, state.ToConfig.Variants["ecash"].BaseURL)
	require.Equal(t, ecashMainnetID, state.ToConfig.Variants["ecash"].Subfolder)

	paths := slices.Sorted(func(yield func(string) bool) {
		for path := range o.swapStatePaths(config.NetworkECash) {
			if !yield(path) {
				return
			}
		}
	})
	require.NotEmpty(t, paths)
	aside := paths[0]
	require.NoError(t, os.MkdirAll(filepath.Dir(aside), 0o755))
	require.NoError(t, os.WriteFile(aside, []byte("betanet state"), 0o600))
	state.Status.JobID = "mainnet-job"

	require.NoError(t, o.selectMigration(state))

	require.NoFileExists(t, aside)
	require.Equal(t, "betanet state", readState(t, aside+".ecash-betanet-mainnet-job"), "moved aside, never deleted")
	requireOnECashMainnet(t, o)
}

func TestECashMainnetParksTheSidechainStateOfBetanet(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignECashState(dir, "betanet"))
	writeState(t, dir, "betanet state")

	require.NoError(t, alignECashState(dir, ecashMainnetID))

	for _, name := range []string{"data.mdb", "wallet.mdb"} {
		require.NoFileExists(t, filepath.Join(dir, name))
		require.Equal(t, "betanet state", readState(t, filepath.Join(dir, name+".network-ecash-betanet")))
	}
	require.Equal(t, "ecash-mainnet\n", readState(t, filepath.Join(dir, ecashStampFile)))

	writeState(t, dir, "mainnet state")
	require.NoError(t, alignECashState(dir, "betanet"))

	require.Equal(t, "betanet state", readState(t, filepath.Join(dir, "data.mdb")))
	require.Equal(t, "mainnet state", readState(t, filepath.Join(dir, "data.mdb.network-ecash-ecash-mainnet")))
	require.Equal(t, "betanet\n", readState(t, filepath.Join(dir, ecashStampFile)))
}

func TestStartEnforcerWhenReadyRefusesAnECashIDWithNoFork(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil

	err := o.startEnforcerWhenReady(context.Background(), StartOpts{EnforcerArgs: []string{"--fork=ecash-mainnet"}}, nil)

	require.ErrorContains(t, err, `"ecash-mainnet"`)
	mon := o.getOrCreateMonitor("enforcer", &mockChecker{}, enforcerStartupPatterns)
	require.Contains(t, mon.ConnectionError(), `"ecash-mainnet"`)
}

func TestStartEnforcerWhenReadyTakesTheBetanetFork(t *testing.T) {
	o := newTestOrchestrator(t)
	o.BitcoinConf = nil
	prefetched := make(chan error, 1)
	prefetched <- os.ErrNotExist

	err := o.startEnforcerWhenReady(context.Background(), StartOpts{EnforcerArgs: []string{"--fork=ecash-betanet"}}, prefetched)

	require.ErrorIs(t, err, os.ErrNotExist, "the start goes past the fork check")
}

func TestPrepareEnforcerArgsOnECashMainnetNamesItsFork(t *testing.T) {
	keepNetworkGlobals(t)
	o := newTestOrchestrator(t)
	o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, t.TempDir())
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	o.adoptCatalog(ecashMainnetFixture(t), ecashMainnetID)

	var opts StartOpts
	o.prepareEnforcerArgs(&opts)

	require.Contains(t, opts.EnforcerArgs, "--fork=ecash-mainnet")
	require.ErrorContains(t, config.CheckEnforcerFork(opts.EnforcerArgs), `"ecash-mainnet"`)
}

func TestSidechainsGetMainnetOnECashMainnet(t *testing.T) {
	keepNetworkGlobals(t)
	config.SetECashNetworkID("ecash")

	require.Equal(t, "mainnet", config.CusfNetworkName(config.NetworkECash, "ecash"))
	require.Empty(t, config.SidechainSeedPeerForNetwork("thunder", config.NetworkECash))
}

func TestTheEnforcerDownloadsTheStableRelease(t *testing.T) {
	o := newTestOrchestrator(t)

	enforcer := o.configs["enforcer"]
	require.Equal(t, "https://releases.ecash.com/bip300301-enforcer/stable/latest/", enforcer.BaseURL(ecashMainnetID))
	require.Equal(t, "bip300301-enforcer-latest-aarch64-apple-darwin.zip", enforcer.Files["macos-arm64"])
}
