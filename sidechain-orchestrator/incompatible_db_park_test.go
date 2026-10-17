package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// refusal is the startup error of truthcoin-dc 0.20.0 for a 0.19 database.
func refusal(dbPath string) error {
	return fmt.Errorf("truthcoin exited with code 1: Error: Incompatible DB version (0.19.0). Please clear the DB (`%s`) and re-sync", dbPath)
}

func TestParkIncompatibleDBParksTheRefusedDatabase(t *testing.T) {
	dir := t.TempDir()
	for _, name := range []string{"data.mdb", "wallet.mdb"} {
		db := filepath.Join(dir, name)
		require.NoError(t, os.MkdirAll(db, 0o755))
		require.NoError(t, os.WriteFile(filepath.Join(db, "data.mdb"), []byte("0.19 "+name), 0o644))

		target, ok, err := parkIncompatibleDB(dir, refusal(db), map[string]bool{})
		require.NoError(t, err)
		require.True(t, ok)

		assert.Equal(t, db+".network-version-0.19.0", target)
		assert.NoDirExists(t, db)
		assert.Equal(t, "0.19 "+name, readState(t, filepath.Join(target, "data.mdb")))
	}
}

func TestParkIncompatibleDBKeepsAnEarlierPark(t *testing.T) {
	dir := t.TempDir()
	db := filepath.Join(dir, "data.mdb")
	require.NoError(t, os.MkdirAll(db+".network-version-0.19.0", 0o755))
	require.NoError(t, os.MkdirAll(db, 0o755))

	target, ok, err := parkIncompatibleDB(dir, refusal(db), map[string]bool{})
	require.NoError(t, err)
	require.True(t, ok)

	assert.Equal(t, db+".network-version-0.19.0.1", target)
	assert.DirExists(t, db+".network-version-0.19.0")
}

func TestParkIncompatibleDBLeavesOtherExitsAlone(t *testing.T) {
	dir := t.TempDir()
	db := filepath.Join(dir, "data.mdb")
	require.NoError(t, os.MkdirAll(db, 0o755))
	outside := filepath.Join(t.TempDir(), "data.mdb")
	require.NoError(t, os.MkdirAll(outside, 0o755))

	for name, exitErr := range map[string]error{
		"another error":       errors.New("truthcoin exited with code 2: error: unexpected argument '--mainchain-grpc-host' found"),
		"a crash":             errors.New("truthcoin exited with code -1: INFO truthcoin_dc_app::app: Instantiating node struct"),
		"a path outside":      refusal(outside),
		"an unknown database": refusal(filepath.Join(dir, "logs")),
	} {
		t.Run(name, func(t *testing.T) {
			_, ok, err := parkIncompatibleDB(dir, exitErr, map[string]bool{})
			require.NoError(t, err)
			assert.False(t, ok)
			assert.DirExists(t, db)
			assert.DirExists(t, outside)
		})
	}
}

// A node that refuses the database it just made would otherwise loop forever.
func TestParkIncompatibleDBParksOnePathOnce(t *testing.T) {
	dir := t.TempDir()
	db := filepath.Join(dir, "data.mdb")
	parked := map[string]bool{}
	require.NoError(t, os.MkdirAll(db, 0o755))
	_, ok, err := parkIncompatibleDB(dir, refusal(db), parked)
	require.NoError(t, err)
	require.True(t, ok)

	require.NoError(t, os.MkdirAll(db, 0o755))
	_, ok, err = parkIncompatibleDB(dir, refusal(db), parked)
	require.NoError(t, err)
	assert.False(t, ok)
	assert.DirExists(t, db)
}

// fileChecker reports healthy once the fake node writes its marker.
type fileChecker struct{ path string }

func (c fileChecker) Check(context.Context) error {
	if _, err := os.Stat(c.path); err != nil {
		return errors.New("not up")
	}
	return nil
}

// fakeTruthcoin refuses each database that holds an "old" file, as 0.20.0
// refuses a 0.19 database, and serves when none does.
const fakeTruthcoin = `#!/bin/sh
TICK=$(printf '\140')
sleep "${TC_DELAY:-0}"
for db in wallet.mdb data.mdb; do
  if [ -f "$TC_DATADIR/$db/old" ]; then
    printf 'Error: Incompatible DB version (0.19.0). Please clear the DB (%s%s/%s%s) and re-sync\n' "$TICK" "$TC_DATADIR" "$db" "$TICK" >&2
    exit 1
  fi
done
mkdir -p "$TC_DATADIR/wallet.mdb" "$TC_DATADIR/data.mdb"
touch "$TC_DATADIR/up"
exec sleep 30
`

func TestStartTargetOnlyParksOldDatabasesAndStartsAgain(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the fake node is a shell script")
	}
	setTestHome(t)
	dataDir := t.TempDir()
	o := New(dataDir, "signet", t.TempDir(), AllDefaults(), testLogger(t))
	t.Cleanup(func() {
		o.StopAllMonitors()
		_ = o.process.StopAll(context.Background(), true)
		o.process.WaitForExit("truthcoin", 5*time.Second)
	})

	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(binDir, "truthcoin"), []byte(fakeTruthcoin), 0o755))

	dc, ok := config.DirConfigByName("truthcoin")
	require.True(t, ok)
	datadir := dc.DatadirNetwork(config.Network(o.CurrentNetwork()), "")
	for _, db := range []string{"wallet.mdb", "data.mdb"} {
		require.NoError(t, os.MkdirAll(filepath.Join(datadir, db), 0o755))
		require.NoError(t, os.WriteFile(filepath.Join(datadir, db, "old"), nil, 0o644))
	}

	cfg := BinaryConfig{Name: "truthcoin", DisplayName: "Truthcoin", BinaryName: "truthcoin"}
	o.getOrCreateMonitor(cfg.Name, fileChecker{path: filepath.Join(datadir, "up")}, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	prefetched := make(chan error)
	close(prefetched)
	ch := make(chan StartupProgress, 32)
	o.startTargetOnly(ctx, cfg, StartOpts{TargetEnv: map[string]string{"TC_DATADIR": datadir}}, ch, prefetched)
	close(ch)

	var last StartupProgress
	for p := range ch {
		require.NoError(t, p.Error)
		last = p
	}
	assert.True(t, last.Done)
	assert.True(t, o.process.IsRunning(cfg.Name))
	for _, db := range []string{"wallet.mdb", "data.mdb"} {
		assert.FileExists(t, filepath.Join(datadir, db+".network-version-0.19.0", "old"))
		assert.NoFileExists(t, filepath.Join(datadir, db, "old"))
	}
}

func TestStartTargetOnlyFailsOnAnotherExitError(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the fake node is a shell script")
	}
	setTestHome(t)
	dataDir := t.TempDir()
	o := New(dataDir, "signet", t.TempDir(), AllDefaults(), testLogger(t))
	t.Cleanup(o.StopAllMonitors)

	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	script := "#!/bin/sh\necho \"error: unexpected argument '--mainchain-grpc-host' found\" >&2\nexit 2\n"
	require.NoError(t, os.WriteFile(filepath.Join(binDir, "truthcoin"), []byte(script), 0o755))

	dc, ok := config.DirConfigByName("truthcoin")
	require.True(t, ok)
	datadir := dc.DatadirNetwork(config.Network(o.CurrentNetwork()), "")
	require.NoError(t, os.MkdirAll(filepath.Join(datadir, "data.mdb"), 0o755))

	cfg := BinaryConfig{Name: "truthcoin", DisplayName: "Truthcoin", BinaryName: "truthcoin"}
	o.getOrCreateMonitor(cfg.Name, fileChecker{path: filepath.Join(datadir, "up")}, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	prefetched := make(chan error)
	close(prefetched)
	ch := make(chan StartupProgress, 32)
	o.startTargetOnly(ctx, cfg, StartOpts{}, ch, prefetched)
	close(ch)

	var bootErr error
	for p := range ch {
		if p.Error != nil {
			bootErr = p.Error
		}
	}
	require.Error(t, bootErr)
	assert.Contains(t, bootErr.Error(), "unexpected argument")
	assert.DirExists(t, filepath.Join(datadir, "data.mdb"))
	entries, err := os.ReadDir(datadir)
	require.NoError(t, err)
	for _, e := range entries {
		assert.NotContains(t, e.Name(), "network-version", "no park after another exit error")
	}
}

// Two starts that wait on one refused process park each database once.
func TestStartTargetOnlyParksOnceForTwoStarts(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the fake node is a shell script")
	}
	setTestHome(t)
	dataDir := t.TempDir()
	o := New(dataDir, "signet", t.TempDir(), AllDefaults(), testLogger(t))
	t.Cleanup(func() {
		o.StopAllMonitors()
		_ = o.process.StopAll(context.Background(), true)
		o.process.WaitForExit("truthcoin", 5*time.Second)
	})

	binDir := BinDir(dataDir)
	require.NoError(t, os.MkdirAll(binDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(binDir, "truthcoin"), []byte(fakeTruthcoin), 0o755))

	dc, ok := config.DirConfigByName("truthcoin")
	require.True(t, ok)
	datadir := dc.DatadirNetwork(config.Network(o.CurrentNetwork()), "")
	for _, db := range []string{"wallet.mdb", "data.mdb"} {
		require.NoError(t, os.MkdirAll(filepath.Join(datadir, db), 0o755))
		require.NoError(t, os.WriteFile(filepath.Join(datadir, db, "old"), nil, 0o644))
	}

	cfg := BinaryConfig{Name: "truthcoin", DisplayName: "Truthcoin", BinaryName: "truthcoin"}
	o.getOrCreateMonitor(cfg.Name, fileChecker{path: filepath.Join(datadir, "up")}, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	results := make(chan StartupProgress, 2)
	for i := range 2 {
		if i == 1 {
			// The second start finds the first process alive and still loading.
			require.Eventually(t, func() bool { return o.process.IsRunning(cfg.Name) }, 5*time.Second, 10*time.Millisecond)
		}
		go func() {
			prefetched := make(chan error)
			close(prefetched)
			ch := make(chan StartupProgress, 32)
			o.startTargetOnly(ctx, cfg, StartOpts{TargetEnv: map[string]string{"TC_DATADIR": datadir, "TC_DELAY": "0.5"}}, ch, prefetched)
			close(ch)
			var last StartupProgress
			for p := range ch {
				if p.Error != nil {
					last = p
					break
				}
				last = p
			}
			results <- last
		}()
	}
	for range 2 {
		last := <-results
		require.NoError(t, last.Error)
		assert.True(t, last.Done)
	}
	for _, db := range []string{"wallet.mdb", "data.mdb"} {
		assert.FileExists(t, filepath.Join(datadir, db+".network-version-0.19.0", "old"))
		assert.NoDirExists(t, filepath.Join(datadir, db+".network-version-0.19.0.1"), "a fresh database must stay")
	}
}
