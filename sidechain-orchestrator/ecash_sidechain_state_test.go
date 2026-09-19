package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func writeState(t *testing.T, dir, content string) {
	t.Helper()
	require.NoError(t, os.MkdirAll(dir, 0o755))
	for _, name := range []string{"data.mdb", "wallet.mdb"} {
		require.NoError(t, os.WriteFile(filepath.Join(dir, name), []byte(content), 0o644))
	}
}

func readState(t *testing.T, path string) string {
	t.Helper()
	raw, err := os.ReadFile(path)
	require.NoError(t, err)
	return string(raw)
}

// Both eCash networks share one datadir, so the new release opened the
// previous network's database and stopped with a wallet error.
func TestECashSwitchParksTheSidechainStateOfTheOtherNetwork(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignECashState(dir, "alphanet"))
	writeState(t, dir, "alphanet state")

	require.NoError(t, alignECashState(dir, "betanet"))

	for _, name := range []string{"data.mdb", "wallet.mdb"} {
		require.NoFileExists(t, filepath.Join(dir, name), "betanet must start without the alphanet state")
		require.Equal(t, "alphanet state", readState(t, filepath.Join(dir, name+".network-ecash-alphanet")))
	}
	require.Equal(t, "betanet\n", readState(t, filepath.Join(dir, ecashStampFile)))
}

// A switch back brings the parked state home and parks the other one.
func TestECashSwitchBackRestoresTheParkedState(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignECashState(dir, "alphanet"))
	writeState(t, dir, "alphanet state")
	require.NoError(t, alignECashState(dir, "betanet"))
	writeState(t, dir, "betanet state")

	require.NoError(t, alignECashState(dir, "alphanet"))

	require.Equal(t, "alphanet state", readState(t, filepath.Join(dir, "data.mdb")))
	require.Equal(t, "alphanet state", readState(t, filepath.Join(dir, "wallet.mdb")))
	require.Equal(t, "betanet state", readState(t, filepath.Join(dir, "data.mdb.network-ecash-betanet")))
	require.NoFileExists(t, filepath.Join(dir, "data.mdb.network-ecash-alphanet"))
}

// State from before the stamp names no network, so it moves aside rather than
// open under a network it may not belong to.
func TestUnstampedSidechainStateIsParked(t *testing.T) {
	dir := t.TempDir()
	writeState(t, dir, "old state")

	require.NoError(t, alignECashState(dir, "betanet"))

	require.NoFileExists(t, filepath.Join(dir, "data.mdb"))
	require.Equal(t, "old state", readState(t, filepath.Join(dir, "data.mdb.network-"+ecashUnstampedKey)))
	require.Equal(t, "betanet\n", readState(t, filepath.Join(dir, ecashStampFile)))
}

// A start on the network the stamp names leaves the state where it is.
func TestSameECashNetworkKeepsTheState(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, alignECashState(dir, "betanet"))
	writeState(t, dir, "betanet state")

	require.NoError(t, alignECashState(dir, "betanet"))

	require.Equal(t, "betanet state", readState(t, filepath.Join(dir, "data.mdb")))
}

// A slot an earlier park filled is never overwritten.
func TestECashParkKeepsAnEarlierParkedCopy(t *testing.T) {
	dir := t.TempDir()
	writeState(t, dir, "new state")
	require.NoError(t, os.WriteFile(filepath.Join(dir, ".ecash-network"), []byte("alphanet\n"), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "data.mdb.network-ecash-alphanet"), []byte("earlier copy"), 0o644))

	require.NoError(t, alignECashState(dir, "betanet"))

	require.Equal(t, "earlier copy", readState(t, filepath.Join(dir, "data.mdb.network-ecash-alphanet")))
	require.Equal(t, "new state", readState(t, filepath.Join(dir, "data.mdb.network-ecash-alphanet.1")))
}

// Only eCash has several networks behind one name. Signet state stays put.
func TestAlignLeavesOtherNetworksAlone(t *testing.T) {
	o := parkInstall(t)
	require.Equal(t, string(config.NetworkSignet), o.Network)
	o.ecashID = "betanet"
	chain := thunderChainPath(t)
	require.NoError(t, os.WriteFile(chain, []byte("signet state"), 0o644))

	require.NoError(t, o.alignECashSidechainState(BinaryConfig{Name: "thunder", ChainLayer: 2}))

	require.Equal(t, "signet state", readState(t, chain))
	require.NoFileExists(t, filepath.Join(filepath.Dir(chain), ecashStampFile))
}

// The start step reads the eCash network the install runs and parks the
// thunder state of the one it left.
func TestAlignParksThunderStateOnECash(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.ecashID = "betanet"
	dc, ok := config.DirConfigByName("thunder")
	require.True(t, ok)
	dir := dc.DatadirNetwork(config.NetworkECash, o.BitcoinConf.DetectedDataDir)
	writeState(t, dir, "alphanet state")
	require.NoError(t, os.WriteFile(filepath.Join(dir, ecashStampFile), []byte("alphanet\n"), 0o644))

	require.NoError(t, o.alignECashSidechainState(BinaryConfig{Name: "thunder", ChainLayer: 2}))

	require.NoFileExists(t, filepath.Join(dir, "data.mdb"))
	require.Equal(t, "alphanet state", readState(t, filepath.Join(dir, "data.mdb.network-ecash-alphanet")))
	require.Equal(t, "betanet\n", readState(t, filepath.Join(dir, ecashStampFile)))
}

// A restore that stopped halfway leaves the stamp on the new network with some
// state still parked. The next start brings the rest home.
func TestECashAlignFinishesAnInterruptedRestore(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, ecashStampFile), []byte("alphanet\n"), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "data.mdb"), []byte("alphanet data"), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.mdb.network-ecash-alphanet"), []byte("alphanet wallet"), 0o644))

	require.NoError(t, alignECashState(dir, "alphanet"))

	require.Equal(t, "alphanet data", readState(t, filepath.Join(dir, "data.mdb")))
	require.Equal(t, "alphanet wallet", readState(t, filepath.Join(dir, "wallet.mdb")))
}

// StartBinary launches the daemon directly, so it parks the state of the eCash
// network the install left before the daemon opens it.
func TestStartParksTheStateOfTheOtherECashNetwork(t *testing.T) {
	o := parkInstall(t)
	o.setNetwork(string(config.NetworkECash))
	o.ecashID = "betanet"
	dc, ok := config.DirConfigByName("thunder")
	require.True(t, ok)
	dir := dc.DatadirNetwork(config.NetworkECash, o.BitcoinConf.DetectedDataDir)
	writeState(t, dir, "alphanet state")
	require.NoError(t, os.WriteFile(filepath.Join(dir, ecashStampFile), []byte("alphanet\n"), 0o644))

	// No window app, so Start launches the daemon itself.
	o.process.SidechainVariant = nil
	_, _ = o.Start(t.Context(), "thunder", nil, nil)

	require.NoFileExists(t, filepath.Join(dir, "data.mdb"))
	require.Equal(t, "alphanet state", readState(t, filepath.Join(dir, "data.mdb.network-ecash-alphanet")))
}
