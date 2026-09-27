package orchestrator

import (
	"context"
	"encoding/hex"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

// writeBlockFile puts one record of a network magic into a blocks directory.
func writeBlockFile(t *testing.T, root, magic string) {
	t.Helper()
	writeBlockFileAs(t, root, "blk00000.dat", magic)
}

func writeBlockFileAs(t *testing.T, root, name, magic string) {
	t.Helper()
	blocks := filepath.Join(root, "blocks")
	require.NoError(t, os.MkdirAll(blocks, 0o700))
	header, err := hex.DecodeString(magic)
	require.NoError(t, err)
	record := append(header, 80, 0, 0, 0)
	record = append(record, make([]byte, 80)...)
	require.NoError(t, os.WriteFile(filepath.Join(blocks, name), record, 0o600))
}

// The blocks name the chain, so a datadir from another network says so before a
// rollback throws the balance away.
func TestReadDatadirNetworkNamesTheBlocks(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), alphanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, alphanet.NetworkMagic, out.Magic)
	require.Equal(t, "alphanet", out.DetectedID)
	require.Equal(t, "betanet", out.SelectedID)
	require.True(t, out.Mismatch)
}

// The blocks of the network the app runs report no mismatch.
func TestReadDatadirNetworkAgreesWithThePick(t *testing.T) {
	cat := netcatalog.Embedded()
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), betanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.False(t, out.Mismatch)
	require.Equal(t, "betanet", out.DetectedID)
}

// The slot and its catalog row carry different names. A mainnet install must
// not read its own blocks as another network.
func TestReadDatadirNetworkAcceptsMainnetBlocks(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkMainnet))
	o.BitcoinConf.Network = config.NetworkMainnet
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
	require.False(t, out.Mismatch, "mainnet blocks under a mainnet pick agree")
}

// Core keeps the blocks of every other network under that network's directory.
func TestReadDatadirNetworkReadsTheNetworkDirectory(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID, "the walk must read <root>/signet/blocks")
	require.True(t, out.Mismatch, "mainnet blocks under a signet pick disagree")
}

// Core adds the network subdirectory under an explicit blocksdir, so the walk
// must read <blocksdir>/signet/blocks.
func TestReadDatadirNetworkObeysBlocksdir(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = cat
	blocksdir := t.TempDir()
	o.BitcoinConf.Config.SetSetting("blocksdir", blocksdir, "signet")
	writeBlockFile(t, filepath.Join(blocksdir, "signet"), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "bitcoin", out.DetectedID)
}

// A datadir with no blocks names no network, so the answer carries no mismatch
// and the app clears whatever it said before.
func TestReadDatadirNetworkReportsAnEmptyDatadir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = netcatalog.Embedded()
	require.NoError(t, os.MkdirAll(filepath.Join(o.BitcoinConf.DataDir(), "blocks"), 0o700))

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Empty(t, out.Magic)
	require.Empty(t, out.DetectedID)
	require.False(t, out.Mismatch)
}

// A user can point two datadir groups at one place through a link, and the
// names then differ although Core reads the same blocks.
func TestSameDirReadsThroughALink(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("a link needs a privilege on windows")
	}
	real := t.TempDir()
	link := filepath.Join(t.TempDir(), "blocks")
	require.NoError(t, os.Symlink(real, link))

	require.True(t, sameDir(real, link))
	require.True(t, sameDir(real, real))
	require.False(t, sameDir(real, t.TempDir()))
	require.False(t, sameDir(real, filepath.Join(real, "nothing")), "a path that is absent stays apart")
}

// The catalog lists no regtest row, because nothing is deployed for it. The
// picker offers regtest, so its blocks name it.
func TestReadDatadirNetworkNamesRegtestBlocks(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.BitcoinConf.DataDir(), regtestMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "regtest", out.DetectedID)
	require.Equal(t, "Regtest", out.DetectedName)
	require.True(t, out.Mismatch)
}

// A regtest install reads its own blocks, so it gets no warning.
func TestReadDatadirNetworkAgreesWithRegtest(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkRegtest))
	o.BitcoinConf.Network = config.NetworkRegtest
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.BitcoinConf.DataDir(), regtestMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.Equal(t, "regtest", out.SelectedID)
	require.False(t, out.Mismatch)
}

// Core keeps one blocks directory per chain, so a switch to another chain
// reads another one and leaves these blocks where they are.
func TestReadDatadirNetworkReportsAnUnreadableSwitch(t *testing.T) {
	cat := netcatalog.Embedded()
	bitcoin, ok := cat.ByID("bitcoin")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkSignet))
	o.BitcoinConf.Network = config.NetworkSignet
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), bitcoin.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.True(t, out.Mismatch)
	require.False(t, out.SwitchReadsBlocks, "bitcoin reads <root>/blocks, and these sit under signet")
}

// The eCash networks share one directory, so a switch between them reads these
// same blocks.
func TestReadDatadirNetworkReportsAReadableSwitch(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFile(t, o.BitcoinConf.DataDir(), alphanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.True(t, out.Mismatch)
	require.True(t, out.SwitchReadsBlocks)
}

// The switch adopts a chain the records already name: it converts no block,
// and a rewind would bar a block that chain holds.
func TestChainAtTargetReadsTheRecord(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	require.NoError(t, o.Settings.SetECashChainID("betanet"))

	require.True(t, o.chainAtTarget("betanet"))
	require.False(t, o.chainAtTarget("alphanet"), "an alphanet switch converts the betanet files")
}

// A datadir with no ECX files takes the ordinary switch, which reads the chain
// from Core itself.
func TestChainAtTargetAnswersForAnEmptyDatadir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()

	require.False(t, o.chainAtTarget("betanet"))
}

// A job that stopped part way owes work, and the saved id can already name the
// target. The conversion finishes first.
func TestChainAtTargetWaitsForAConversion(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	require.NoError(t, o.Settings.SetECashChainID("betanet"))
	o.migrationState = &ecashMigration{
		Status: ECashMigrationStatus{JobID: "job1", FromID: "alphanet", ToID: "betanet"},
		Step:   2,
	}

	require.False(t, o.chainAtTarget("betanet"))
}

// Files that no record names take the conversion, which reads them itself.
func TestChainAtTargetRefusesUnnamedFiles(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "alphanet"
	o.Catalog = netcatalog.Embedded()
	writeBlockFile(t, o.ecashDatadir(), netcatalog.Embedded().Networks[0].NetworkMagic)
	o.BitcoinConf.Config.RemoveSetting("uacomment", "main")
	o.BitcoinConf.Config.RemoveSetting("uacomment")

	require.False(t, o.chainAtTarget("betanet"))
}

// A datadir with no blocks directory names no network, so the app shows no
// warning and the caller reads an empty answer.
func TestReadDatadirNetworkAcceptsAnAbsentBlocksDir(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = netcatalog.Embedded()

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.False(t, out.Mismatch)
	require.Empty(t, out.DetectedID)
}

// A conversion that stopped part way leaves one network at each end of the
// directory. No node reads every block then, so it warns even when the newest
// record agrees with the app.
func TestReadDatadirNetworkNamesAHalfConvertedStore(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00000.dat", alphanet.NetworkMagic)
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00001.dat", betanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.True(t, out.Mixed)
	require.True(t, out.Mismatch, "the app reads one half of the blocks only")
	require.Equal(t, "alphanet", out.FirstID)
	require.Equal(t, "betanet", out.DetectedID)
	require.Equal(t, "betanet", out.SelectedID)
	require.Equal(t, "alphanet", out.ConvertFromID, "the records that still have to move")
}

// The conversion ran the other way: the newest records carry the old network and
// the oldest ones already moved. The source is still the end that disagrees.
func TestReadDatadirNetworkNamesTheHalfThatHasToMove(t *testing.T) {
	cat := netcatalog.Embedded()
	alphanet, ok := cat.ByID("alphanet")
	require.True(t, ok)
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00000.dat", betanet.NetworkMagic)
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00001.dat", alphanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.True(t, out.Mixed)
	require.Equal(t, "alphanet", out.ConvertFromID)
}

// mixedSource names the half that has to move. Neither end is the network the
// app runs in the last row, so no single conversion reaches it.
func TestDatadirNetworkMixedSource(t *testing.T) {
	for _, row := range []struct {
		name   string
		in     DatadirNetwork
		wantID string
	}{
		{
			name:   "one network, another than the app",
			in:     DatadirNetwork{DetectedID: "alphanet", DetectedName: "Alphanet", SelectedID: "betanet"},
			wantID: "alphanet",
		},
		{
			name:   "the newest records already moved",
			in:     DatadirNetwork{Mixed: true, FirstID: "alphanet", DetectedID: "betanet", SelectedID: "betanet"},
			wantID: "alphanet",
		},
		{
			name:   "the oldest records already moved",
			in:     DatadirNetwork{Mixed: true, FirstID: "betanet", DetectedID: "alphanet", SelectedID: "betanet"},
			wantID: "alphanet",
		},
		{
			name:   "both ends differ from the app",
			in:     DatadirNetwork{Mixed: true, FirstID: "alphanet", DetectedID: "betanet", SelectedID: "drynet4"},
			wantID: "",
		},
	} {
		t.Run(row.name, func(t *testing.T) {
			require.Equal(t, row.wantID, row.in.mixedSource())
		})
	}
}

// A conversion rewinds to the block both networks share and replays the target,
// so it moves a chain forward only. The offer stands for one direction.
func TestDatadirNetworkConversionRunsOneWay(t *testing.T) {
	cat := netcatalog.Embedded()

	forward := DatadirNetwork{DetectedID: "alphanet", SelectedID: "betanet"}
	forward.setConversion(cat, ECashMigrationStatus{})
	require.Equal(t, "alphanet", forward.ConvertFromID)
	require.Equal(t, "betanet", forward.ConvertToID)
	require.Equal(t, "Alphanet", forward.ConvertFromName)

	// Betanet blocks while the app runs alphanet: the backend refuses this
	// direction, so the answer offers no conversion at all.
	backward := DatadirNetwork{DetectedID: "betanet", SelectedID: "alphanet"}
	backward.setConversion(cat, ECashMigrationStatus{})
	require.Empty(t, backward.ConvertFromID)
	require.Empty(t, backward.ConvertToID)

	// Bitcoin blocks share no fork height with an eCash network.
	family := DatadirNetwork{DetectedID: "bitcoin", SelectedID: "betanet"}
	family.setConversion(cat, ECashMigrationStatus{})
	require.Empty(t, family.ConvertFromID)
}

// A job that stops during the conversion leaves the app on the source while the
// oldest records already carry the target. The ends alone read as the reverse
// move, so the saved direction decides.
func TestDatadirNetworkResumesTheSavedDirection(t *testing.T) {
	cat := netcatalog.Embedded()
	interrupted := DatadirNetwork{
		Mixed:      true,
		FirstID:    "betanet",
		DetectedID: "alphanet",
		SelectedID: "alphanet",
	}

	// With no saved job the ends name a move no conversion can make.
	guess := interrupted
	guess.setConversion(cat, ECashMigrationStatus{})
	require.Empty(t, guess.ConvertFromID)

	interrupted.setConversion(cat, ECashMigrationStatus{JobID: "job-1", FromID: "alphanet", ToID: "betanet"})
	require.Equal(t, "alphanet", interrupted.ConvertFromID)
	require.Equal(t, "betanet", interrupted.ConvertToID)
}

// A job that finished says nothing about the directory today, so the ends decide.
func TestDatadirNetworkIgnoresAFinishedJob(t *testing.T) {
	cat := netcatalog.Embedded()
	out := DatadirNetwork{DetectedID: "alphanet", SelectedID: "betanet"}
	out.setConversion(cat, ECashMigrationStatus{JobID: "job-1", FromID: "betanet", ToID: "alphanet", Complete: true})
	require.Equal(t, "alphanet", out.ConvertFromID)
	require.Equal(t, "betanet", out.ConvertToID)
}

// One end carries a magic no network in hand names. The published catalog names
// the networks that came after this build, so the caller asks again rather than
// warn about a directory it cannot describe.
func TestReadDatadirNetworkKeepsQuietOnAnUnknownEnd(t *testing.T) {
	cat := netcatalog.Embedded()
	betanet, ok := cat.ByID("betanet")
	require.True(t, ok)

	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.BitcoinConf.Network = config.NetworkECash
	o.ecashID = "betanet"
	o.Catalog = cat
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00000.dat", "eca5ff04")
	writeBlockFileAs(t, o.BitcoinConf.DataDir(), "blk00001.dat", betanet.NetworkMagic)

	out, err := o.ReadDatadirNetwork(context.Background())
	require.NoError(t, err)
	require.False(t, out.Mixed)
	require.False(t, out.Mismatch)
	// The caller reads the empty name beside the magic and asks again.
	require.Equal(t, "eca5ff04", out.FirstMagic)
	require.Empty(t, out.FirstID)
}

// A saved job belongs to the files it started on, and a resume refuses any
// others. The offer asks the resume's own rule, so each file the rule names
// takes the job away.
func TestMigrationForThisStore(t *testing.T) {
	for _, row := range []struct {
		name    string
		change  func(t *testing.T, o *Orchestrator)
		wantJob bool
	}{
		{name: "the same files", change: func(*testing.T, *Orchestrator) {}, wantJob: true},
		{
			name: "another blocksdir",
			change: func(t *testing.T, o *Orchestrator) {
				o.BitcoinConf.Config.SetSetting("blocksdir", t.TempDir(), "main")
			},
		},
		{
			name: "another walletdir",
			change: func(t *testing.T, o *Orchestrator) {
				o.BitcoinConf.Config.SetSetting("walletdir", t.TempDir(), "main")
			},
		},
		{
			name: "another network",
			change: func(t *testing.T, o *Orchestrator) {
				o.setNetwork(string(config.NetworkSignet))
			},
		},
	} {
		t.Run(row.name, func(t *testing.T) {
			o := migrationTestNode(t)
			state, err := o.newMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			state.Status.JobID = "job-1"
			// Past the rewind, which is where the walletdir starts to count.
			state.Step = 2
			state.WalletDir = o.BitcoinConf.Config.GetEffectiveSetting("walletdir", "main")
			require.NoError(t, o.saveMigration(state))

			row.change(t, o)

			if row.wantJob {
				require.Equal(t, "job-1", o.migrationForThisStore().JobID)
				return
			}
			require.Empty(t, o.migrationForThisStore().JobID)
		})
	}
}

// A conversion rewrites the magic of every record, so the two networks have to
// carry different ones. A document that publishes a blank magic names no network.
func TestCheckECashConversionReadsBothMagics(t *testing.T) {
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, ForkHeight: 101, NetworkMagic: "eca5a104",
			ForkParentHash: strings.Repeat("a", 64)},
		{ID: "betanet", Family: netcatalog.FamilyECash, ForkHeight: 121, NetworkMagic: "eca5b104"},
	}}
	require.NoError(t, CheckECashConversion(cat, "alphanet", "betanet"))

	cat.Networks[1].NetworkMagic = "eca5a104"
	require.ErrorContains(t, CheckECashConversion(cat, "alphanet", "betanet"), "must differ")

	cat.Networks[1].NetworkMagic = ""
	require.ErrorContains(t, CheckECashConversion(cat, "alphanet", "betanet"), "magic")
}

// The conversion rewinds to the block the source forks from. The published
// document can leave that hash out, and a network this build does not know then
// carries none, so an offer would end in a refusal.
func TestCheckECashConversionNeedsTheForkParent(t *testing.T) {
	cat := netcatalog.Catalog{Networks: []netcatalog.Network{
		{ID: "alphanet", Family: netcatalog.FamilyECash, ForkHeight: 101, NetworkMagic: "eca5a104"},
		{ID: "betanet", Family: netcatalog.FamilyECash, ForkHeight: 121, NetworkMagic: "eca5b104"},
	}}
	require.ErrorContains(t, CheckECashConversion(cat, "alphanet", "betanet"), "fork_parent_hash")

	cat.Networks[0].ForkParentHash = "abcd"
	require.ErrorContains(t, CheckECashConversion(cat, "alphanet", "betanet"), "fork_parent_hash")

	cat.Networks[0].ForkParentHash = strings.Repeat("a", 64)
	require.NoError(t, CheckECashConversion(cat, "alphanet", "betanet"))
}
