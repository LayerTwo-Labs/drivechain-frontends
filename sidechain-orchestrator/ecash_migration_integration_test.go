package orchestrator

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"slices"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

const migrationCoreFixtureEnv = "ECASH_MIGRATION_CORE_FIXTURE"

type migrationCoreFixture struct {
	Address        string `json:"address"`
	DataDir        string `json:"data_dir"`
	ExternalWallet string `json:"external_wallet,omitempty"`
	AutoLoadWallet bool   `json:"auto_load_wallet,omitempty"`
	AutoLoadLocal  bool   `json:"auto_load_local,omitempty"`
	TwoBranches    bool   `json:"two_branches,omitempty"`
	WalletOnly     bool   `json:"wallet_only,omitempty"`
}

type migrationCoreEvent struct {
	Network string            `json:"network"`
	Method  string            `json:"method"`
	Params  []json.RawMessage `json:"params,omitempty"`
	Args    []string          `json:"args,omitempty"`
	Wallets []string          `json:"wallets,omitempty"`
}

func init() {
	if path := os.Getenv(migrationCoreFixtureEnv); path != "" {
		if err := runMigrationCoreFixture(path); err != nil {
			panic(err)
		}
		os.Exit(0)
	}
}

func TestECashMigrationCompletesAfterClientCancellation(t *testing.T) {
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", false)
	preview, err := o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.EqualValues(t, 100, preview.CommonHeight)
	require.EqualValues(t, 1, preview.BlockFiles)
	require.EqualValues(t, 1, preview.UndoFiles)
	_, err = os.Stat(o.migrationPath())
	require.True(t, os.IsNotExist(err))
	ctx, cancel := context.WithCancel(context.Background())
	status, err := o.StartECashMigration(ctx, "alphanet", "betanet")
	cancel()
	require.NoError(t, err)
	require.True(t, status.Running)
	complete := waitMigrationEngineTest(t, o)
	requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
	repeat, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.True(t, repeat.Complete)
	require.Equal(t, complete.JobID, repeat.JobID)
	requireMigrationEngineEvents(t, fixture)
}

func TestECashMigrationResumesSavedConversion(t *testing.T) {
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", false)
	blockPath := filepath.Join(fixture.DataDir, "blocks", "blk00000.dat")
	require.NoError(t, os.Chmod(blockPath, 0o400))
	status, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.NotZero(t, status.StartedAt)
	failed := waitMigrationEngineTest(t, o)
	require.False(t, failed.Complete)
	require.Equal(t, "convert", failed.Phase)
	require.NotEmpty(t, failed.Error)
	require.False(t, o.process.IsRunning("bitcoind"))
	var saved ecashMigration
	data, err := os.ReadFile(o.migrationPath())
	require.NoError(t, err)
	require.NoError(t, json.Unmarshal(data, &saved))
	require.Equal(t, 2, saved.Step)
	require.Equal(t, strings.Repeat("b", 64), saved.RejectedHash)
	require.NoError(t, os.Chmod(blockPath, 0o600))

	next := New(o.DataDir, "ecash", o.BitwindowDir, AllDefaults(), testLogger(t))
	registerMigrationEngineCleanup(t, next)
	next.adoptCatalog(o.Catalog, "alphanet")
	require.Equal(t, o.BitcoinConf.GetRPCPort(), next.BitcoinConf.GetRPCPort())
	user, password, err := next.BitcoinConf.GetRPCCredentials()
	require.NoError(t, err)
	require.Equal(t, "migration", user)
	require.Equal(t, "migration", password)
	resumed, err := next.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.Equal(t, status.JobID, resumed.JobID)
	require.Equal(t, status.StartedAt, resumed.StartedAt)
	complete := waitMigrationEngineTest(t, next)
	requireMigrationEngineResult(t, next, fixture, complete, block, undo, wallet)
	requireMigrationEngineEvents(t, fixture)
}

func TestECashMigrationKeepsExternalLoadedWallet(t *testing.T) {
	for _, test := range []struct {
		name   string
		wallet string
	}{
		{name: "plain", wallet: "outside"},
		{name: "fragment", wallet: "outside#wallet"},
		{name: "query", wallet: "outside?wallet"},
	} {
		t.Run(test.name, func(t *testing.T) {
			if runtime.GOOS == "windows" && strings.Contains(test.wallet, "?") {
				t.Skip("Windows does not permit ? in file names")
			}
			o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, test.wallet, false)
			_, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			complete := waitMigrationEngineTest(t, o)
			requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
			events := requireMigrationEngineEvents(t, fixture)
			var loaded [][]string
			for _, event := range events {
				if event.Network == "alphanet" && event.Method == "listwallets" {
					loaded = append(loaded, event.Wallets)
				}
			}
			require.Len(t, loaded, 2)
			require.Contains(t, loaded[0], fixture.ExternalWallet)
			require.NotContains(t, loaded[1], fixture.ExternalWallet)
			data, err := os.ReadFile(o.migrationPath())
			require.NoError(t, err)
			var saved ecashMigration
			require.NoError(t, json.Unmarshal(data, &saved))
			require.Contains(t, saved.WalletPaths, fixture.ExternalWallet)
		})
	}
}

func TestECashMigrationRejectsEachSourceBranch(t *testing.T) {
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", true)
	_, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	complete := waitMigrationEngineTest(t, o)
	requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
	events := requireMigrationEngineEvents(t, fixture)
	var hashes []string
	for _, event := range events {
		if event.Method == "invalidateblock" {
			var hash string
			require.NoError(t, json.Unmarshal(event.Params[0], &hash))
			hashes = append(hashes, hash)
		}
	}
	rejected := []string{strings.Repeat("b", 64), strings.Repeat("c", 64)}
	require.Equal(t, rejected, hashes)
	data, err := os.ReadFile(o.migrationPath())
	require.NoError(t, err)
	var saved struct {
		RejectedHashes []string `json:"rejected_hashes"`
	}
	require.NoError(t, json.Unmarshal(data, &saved))
	require.Equal(t, rejected, saved.RejectedHashes)
}

func TestECashMigrationSkipsRollbackBelowFork(t *testing.T) {
	o, fixture, block, undo, wallet := prepareMigrationEngineTest(t, "", false)
	require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, "fixture-height"), []byte("90"), 0o600))
	preview, err := o.PreviewECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	require.True(t, preview.BelowFork)
	require.EqualValues(t, 90, preview.CommonHeight)
	require.Equal(t, strings.Repeat("d", 64), preview.CommonHash)
	_, err = o.StartECashMigration(context.Background(), "alphanet", "betanet")
	require.NoError(t, err)
	complete := waitMigrationEngineTest(t, o)
	requireMigrationEngineResult(t, o, fixture, complete, block, undo, wallet)
	require.True(t, complete.BelowFork)
	require.EqualValues(t, 90, complete.CommonHeight)
	events := requireMigrationEngineEvents(t, fixture)
	var hashes []string
	for _, event := range events {
		if event.Method == "invalidateblock" {
			var hash string
			require.NoError(t, json.Unmarshal(event.Params[0], &hash))
			hashes = append(hashes, hash)
		}
	}
	require.Equal(t, []string{strings.Repeat("b", 64)}, hashes)
}

func TestECashMigrationSkipsRollbackAtTarget(t *testing.T) {
	for _, test := range []struct {
		name   string
		height int64
		below  bool
	}{
		{name: "above the fork", height: 110},
		{name: "below the fork", height: 90, below: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			o, fixture, block, undo, _ := prepareMigrationEngineTest(t, "", false)
			require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, "fixture-height"), []byte(strconv.FormatInt(test.height, 10)), 0o600))
			target := []byte{0xec, 0xa5, 0xa1, 0x05}
			files := map[string][]byte{"blocks/blk00000.dat": bytes.Clone(block), "blocks/rev00000.dat": bytes.Clone(undo)}
			for name, data := range files {
				copy(data, target)
				require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, filepath.FromSlash(name)), data, 0o600))
			}

			_, err := o.StartECashMigration(context.Background(), "alphanet", "betanet")
			require.NoError(t, err)
			complete := waitMigrationEngineTest(t, o)

			require.Empty(t, complete.Error)
			require.True(t, complete.Complete)
			require.Equal(t, test.below, complete.BelowFork)
			if test.below {
				require.Equal(t, test.height, complete.CommonHeight)
			}
			require.Equal(t, "betanet", o.Settings.ECashChainID())
			require.True(t, o.process.IsRunning("bitcoind"))
			for name, want := range files {
				got, err := os.ReadFile(filepath.Join(fixture.DataDir, filepath.FromSlash(name)))
				require.NoError(t, err)
				require.Equal(t, want, got, name)
			}
			steps, _ := readMigrationEngineEvents(t, fixture)
			require.Equal(t, []string{
				"alphanet:start", "alphanet:stop", "betanet:start", "betanet:stop", "betanet:start", "betanet:getblock",
				"betanet:loadwallet", "betanet:getwalletinfo", "betanet:setnetworkactive",
			}, steps)
		})
	}
}

func prepareMigrationEngineTest(t *testing.T, externalName string, twoBranches bool) (*Orchestrator, migrationCoreFixture, []byte, []byte, []byte) {
	t.Helper()
	o := migrationTestNode(t)
	registerMigrationEngineCleanup(t, o)
	port, err := net.Listen("tcp4", "127.0.0.1:0")
	require.NoError(t, err)
	address := port.Addr().String()
	_, number, err := net.SplitHostPort(address)
	require.NoError(t, err)
	require.NoError(t, port.Close())
	for name, value := range map[string]string{"rpcport": number, "rpcuser": "migration", "rpcpassword": "migration", "rpcconnect": "127.0.0.1"} {
		o.BitcoinConf.Config.SetSetting(name, value, "main")
	}
	require.NoError(t, o.BitcoinConf.SaveConfig())
	fixture := migrationCoreFixture{Address: address, DataDir: o.BitcoinConf.DataDir(), TwoBranches: twoBranches}
	if externalName != "" {
		fixture.ExternalWallet = filepath.Join(t.TempDir(), externalName)
	}
	fixturePath := filepath.Join(t.TempDir(), "fixture.json")
	data, err := json.Marshal(fixture)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(fixturePath, data, 0o600))
	t.Setenv(migrationCoreFixtureEnv, fixturePath)

	path, err := os.Executable()
	require.NoError(t, err)
	executable, err := os.ReadFile(path)
	require.NoError(t, err)
	raw := o.rawConfigs["bitcoind"]
	for _, id := range []string{"alphanet", "betanet"} {
		cfg := expandECashPlaceholder(raw, id)
		variant, ok := ResolveCoreVariant(cfg, "ecash", "ecash")
		require.True(t, ok)
		path := CoreBinaryPath(o.DataDir, variant, cfg.BinaryName)
		require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o700))
		require.NoError(t, os.WriteFile(path, executable, 0o700))
	}
	magic := []byte{0xec, 0xa5, 0xa1, 0x04}
	block := make([]byte, 8+81)
	copy(block, magic)
	binary.LittleEndian.PutUint32(block[4:8], 81)
	copy(block[8:], bytes.Repeat([]byte{0x37}, 81))
	undo := make([]byte, 8+1+32)
	copy(undo, magic)
	binary.LittleEndian.PutUint32(undo[4:8], 1)
	blocksDir := filepath.Join(fixture.DataDir, "blocks")
	require.NoError(t, os.MkdirAll(blocksDir, 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(blocksDir, "blk00000.dat"), block, 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(blocksDir, "rev00000.dat"), undo, 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(blocksDir, "xor.dat"), make([]byte, 8), 0o600))
	walletPath := filepath.Join(fixture.DataDir, "wallets", "migration", "wallet.dat")
	createMigrationFixtureWallet(t, walletPath, magic)
	if externalName != "" {
		createMigrationFixtureWallet(t, filepath.Join(fixture.ExternalWallet, "wallet.dat"), magic)
	}
	wallet, err := os.ReadFile(walletPath)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, "fixture-height"), []byte("110"), 0o600))
	for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
		require.NoError(t, os.WriteFile(filepath.Join(fixture.DataDir, name), []byte(name), 0o600))
	}
	cfg, err := o.getConfig("bitcoind")
	require.NoError(t, err)
	_, err = o.process.Start(context.Background(), cfg, []string{"-datadir=" + fixture.DataDir, "-networkactive=1"}, nil)
	require.NoError(t, err)
	require.Eventually(t, o.coreRPCReachable, 10*time.Second, 25*time.Millisecond)
	return o, fixture, block, undo, wallet
}

func createMigrationFixtureWallet(t *testing.T, walletPath string, magic []byte) {
	t.Helper()
	require.NoError(t, os.MkdirAll(filepath.Dir(walletPath), 0o700))
	uri := url.URL{Scheme: "file", Path: filepath.ToSlash(walletPath)}
	db, err := sql.Open("sqlite3", uri.String())
	require.NoError(t, err)
	_, err = db.Exec("CREATE TABLE main(key BLOB PRIMARY KEY NOT NULL, value BLOB NOT NULL)")
	require.NoError(t, err)
	_, err = db.Exec(fmt.Sprintf("PRAGMA application_id=%d", int32(binary.BigEndian.Uint32(magic))))
	require.NoError(t, err)
	_, err = db.Exec("INSERT INTO main VALUES (x'010203', x'040506')")
	require.NoError(t, err)
	require.NoError(t, db.Close())
}

func registerMigrationEngineCleanup(t *testing.T, o *Orchestrator) {
	t.Helper()
	t.Cleanup(func() {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		o.StopAllMonitors()
		names := o.process.ListRunning()
		require.NoError(t, o.process.StopAll(ctx, true))
		for _, name := range names {
			require.True(t, o.process.WaitForExit(name, 5*time.Second))
		}
		require.NoError(t, o.closeRemoteEnforcer())
	})
}

func waitMigrationEngineTest(t *testing.T, o *Orchestrator) ECashMigrationStatus {
	t.Helper()
	var status ECashMigrationStatus
	require.Eventually(t, func() bool {
		var err error
		status, err = o.ECashMigrationStatus()
		return err == nil && !status.Running
	}, 45*time.Second, 25*time.Millisecond)
	return status
}

func requireMigrationEngineResult(t *testing.T, o *Orchestrator, fixture migrationCoreFixture, status ECashMigrationStatus, block, undo, wallet []byte) {
	t.Helper()
	require.Empty(t, status.Error)
	require.True(t, status.Complete)
	require.Equal(t, "complete", status.Phase)
	require.Equal(t, "syncing", status.SyncState)
	require.EqualValues(t, 2, status.RecordsTotal)
	require.Equal(t, status.RecordsTotal, status.RecordsDone)
	require.Equal(t, "betanet", o.Settings.ECashChainID())
	require.True(t, o.process.IsRunning("bitcoind"))
	files := map[string][]byte{
		"blocks/blk00000.dat": block, "blocks/rev00000.dat": undo, "wallets/migration/wallet.dat": wallet,
	}
	if fixture.ExternalWallet != "" {
		files[filepath.Join(fixture.ExternalWallet, "wallet.dat")] = wallet
	}
	for path, original := range files {
		want := bytes.Clone(original)
		offset := 0
		if filepath.Base(path) == "wallet.dat" {
			offset = 68
		}
		copy(want[offset:offset+4], []byte{0xec, 0xa5, 0xa1, 0x05})
		readPath := path
		if !filepath.IsAbs(readPath) {
			readPath = filepath.Join(fixture.DataDir, filepath.FromSlash(path))
		}
		got, err := os.ReadFile(readPath)
		require.NoError(t, err)
		require.Equal(t, want, got, path)
	}
	backup := filepath.Join(fixture.DataDir, "ecash-migrations", status.JobID)
	for _, prefix := range []string{"source-", "target-"} {
		for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
			_, err := os.Stat(filepath.Join(backup, prefix+name))
			require.NoError(t, err)
		}
	}
	client, err := o.CoreStatusClient()
	require.NoError(t, err)
	var network struct {
		Active bool `json:"networkactive"`
	}
	require.NoError(t, migrationRPC(context.Background(), client, "getnetworkinfo", &network))
	require.True(t, network.Active)
}

func requireMigrationEngineEvents(t *testing.T, fixture migrationCoreFixture) []migrationCoreEvent {
	t.Helper()
	steps, events := readMigrationEngineEvents(t, fixture)
	want := []string{
		"alphanet:start", "alphanet:stop", "alphanet:start", "alphanet:invalidateblock",
	}
	if fixture.TwoBranches {
		want = append(want, "alphanet:invalidateblock")
	}
	want = append(want, "alphanet:stop", "betanet:start", "betanet:getblock", "betanet:loadwallet", "betanet:getwalletinfo")
	if fixture.ExternalWallet != "" {
		want = append(want, "betanet:loadwallet", "betanet:getwalletinfo")
	}
	want = append(want, "betanet:setnetworkactive")
	require.Equal(t, want, steps)
	return events
}

func readMigrationEngineEvents(t *testing.T, fixture migrationCoreFixture) ([]string, []migrationCoreEvent) {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(fixture.DataDir, "fixture-events"))
	require.NoError(t, err)
	decoder := json.NewDecoder(bytes.NewReader(data))
	var steps []string
	var events []migrationCoreEvent
	for {
		var event migrationCoreEvent
		err := decoder.Decode(&event)
		if errors.Is(err, io.EOF) {
			break
		}
		require.NoError(t, err)
		events = append(events, event)
		switch event.Method {
		case "start", "stop", "invalidateblock", "setnetworkactive", "getblock", "loadwallet", "getwalletinfo":
			steps = append(steps, event.Network+":"+event.Method)
		}
		if event.Method == "start" && (event.Network == "betanet" || len(steps) > 2) {
			require.Contains(t, event.Args, "-networkactive=0")
			require.Contains(t, event.Args, "-walletbroadcast=0")
		}
	}
	return steps, events
}

func runMigrationCoreFixture(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	var fixture migrationCoreFixture
	if err := json.Unmarshal(data, &fixture); err != nil {
		return err
	}
	network := filepath.Base(filepath.Dir(os.Args[0]))
	magic := []byte{0xec, 0xa5, 0xa1, 0x04}
	if network == "betanet" {
		magic[3] = 0x05
	} else if network != "alphanet" {
		return fmt.Errorf("unexpected fixture network %s", network)
	}
	files := map[string]int{"blocks/blk00000.dat": 0, "blocks/rev00000.dat": 0, "wallets/migration/wallet.dat": 68}
	if fixture.ExternalWallet != "" {
		files[filepath.Join(fixture.ExternalWallet, "wallet.dat")] = 68
	}
	walletless := slices.Contains(os.Args[1:], "-disablewallet=1")
	for name, offset := range files {
		if walletless && offset != 0 {
			continue
		}
		readPath := name
		if !filepath.IsAbs(readPath) {
			readPath = filepath.Join(fixture.DataDir, filepath.FromSlash(name))
		}
		data, err := os.ReadFile(readPath)
		if os.IsNotExist(err) && fixture.WalletOnly && offset == 0 {
			continue
		}
		if err != nil {
			return err
		}
		if len(data) < offset+4 || !bytes.Equal(data[offset:offset+4], magic) {
			return fmt.Errorf("fixture %s has incorrect magic", name)
		}
	}
	if err := appendMigrationCoreEvent(fixture.DataDir, migrationCoreEvent{Network: network, Method: "start", Args: os.Args[1:]}); err != nil {
		return err
	}
	listener, err := net.Listen("tcp4", fixture.Address)
	if err != nil {
		return err
	}
	var mu sync.Mutex
	var once sync.Once
	stop := make(chan struct{})
	active := true
	for _, arg := range os.Args[1:] {
		if arg == "-networkactive=0" {
			active = false
		}
	}
	loaded := make(map[string]bool)
	if fixture.AutoLoadLocal {
		loaded["migration"] = true
	}
	if network == "alphanet" {
		loaded["migration"] = true
		if fixture.ExternalWallet != "" && (active || fixture.AutoLoadWallet) {
			loaded[fixture.ExternalWallet] = true
		}
	}
	server := &http.Server{ReadHeaderTimeout: 5 * time.Second}
	server.Handler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		var request struct {
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
			ID     json.RawMessage   `json:"id"`
		}
		err := json.NewDecoder(r.Body).Decode(&request)
		if err == nil && request.Method == "getwalletinfo" && !strings.HasPrefix(r.URL.Path, "/wallet/") {
			err = fmt.Errorf("unexpected wallet RPC path %s", r.URL.Path)
		}
		if err == nil {
			event := migrationCoreEvent{Network: network, Method: request.Method, Params: request.Params}
			if request.Method == "listwallets" {
				event.Wallets = migrationFixtureWalletNames(loaded)
			}
			err = appendMigrationCoreEvent(fixture.DataDir, event)
		}
		var result any
		if err == nil {
			result, err = migrationCoreFixtureRPC(fixture, request.Method, strings.TrimPrefix(r.URL.Path, "/wallet/"), request.Params, &active, loaded)
		}
		var rpcError any
		if err != nil {
			rpcError = map[string]any{"code": -1, "message": err.Error()}
		}
		if err := json.NewEncoder(w).Encode(map[string]any{"id": request.ID, "result": result, "error": rpcError}); err != nil {
			panic(err)
		}
		if request.Method == "stop" && err == nil {
			once.Do(func() { close(stop) })
		}
	})
	served := make(chan error, 1)
	go func() { served <- server.Serve(listener) }()
	select {
	case err := <-served:
		return err
	case <-stop:
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		return err
	}
	if err := <-served; !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

func appendMigrationCoreEvent(dir string, event migrationCoreEvent) error {
	file, err := os.OpenFile(filepath.Join(dir, "fixture-events"), os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0o600)
	if err != nil {
		return err
	}
	return errors.Join(json.NewEncoder(file).Encode(event), file.Close())
}

func migrationFixtureWalletNames(loaded map[string]bool) []string {
	names := make([]string, 0, len(loaded))
	for name := range loaded {
		names = append(names, name)
	}
	slices.Sort(names)
	return names
}

func migrationCoreFixtureRPC(fixture migrationCoreFixture, method, wallet string, params []json.RawMessage, active *bool, loaded map[string]bool) (any, error) {
	switch method {
	case "getblockchaininfo":
		data, err := os.ReadFile(filepath.Join(fixture.DataDir, "fixture-height"))
		if err != nil {
			return nil, err
		}
		height, err := strconv.Atoi(string(data))
		return map[string]any{"chain": "main", "blocks": height, "headers": height, "pruned": false}, err
	case "getblockhash":
		var height int
		if len(params) != 1 {
			return nil, errors.New("getblockhash uses one height")
		}
		if err := json.Unmarshal(params[0], &height); err != nil {
			return nil, err
		}
		if height == 100 {
			return strings.Repeat("a", 64), nil
		}
		if height == 90 {
			return strings.Repeat("d", 64), nil
		}
		if height == 0 && fixture.WalletOnly {
			return config.ChainParamsFor(config.NetworkECash).GenesisHash.String(), nil
		}
		if height == 101 {
			if fixture.TwoBranches {
				data, err := os.ReadFile(filepath.Join(fixture.DataDir, "fixture-height"))
				if err != nil {
					return nil, err
				}
				if string(data) == "109" {
					return strings.Repeat("c", 64), nil
				}
			}
			return strings.Repeat("b", 64), nil
		}
		return nil, fmt.Errorf("unexpected fixture height %d", height)
	case "getchaintips":
		return []map[string]any{
			{"height": 90, "hash": strings.Repeat("d", 64), "status": "active"},
			{"height": 102, "hash": strings.Repeat("f", 64), "status": "headers-only"},
		}, nil
	case "getblockheader":
		var hash string
		if len(params) != 1 {
			return nil, errors.New("getblockheader uses one hash")
		}
		if err := json.Unmarshal(params[0], &hash); err != nil {
			return nil, err
		}
		if hash != strings.Repeat("f", 64) {
			return nil, fmt.Errorf("unexpected fixture header %s", hash)
		}
		return map[string]any{"height": 102, "previousblockhash": strings.Repeat("b", 64)}, nil
	case "listwallets":
		return migrationFixtureWalletNames(loaded), nil
	case "loadwallet":
		var name string
		if len(params) != 1 {
			return nil, errors.New("loadwallet uses one name")
		}
		if err := json.Unmarshal(params[0], &name); err != nil {
			return nil, err
		}
		allowed := name == "migration" || fixture.ExternalWallet != "" && name == fixture.ExternalWallet
		if !allowed && fixture.WalletOnly {
			path, err := filepath.EvalSymlinks(filepath.Join(fixture.DataDir, "wallets", "migration"))
			if err != nil {
				return nil, err
			}
			allowed = name == path
			if allowed && loaded["migration"] {
				return nil, errors.New("the wallet is already loaded")
			}
		}
		if !allowed {
			return nil, fmt.Errorf("unexpected wallet name %s", name)
		}
		loaded[name] = true
		return map[string]any{"name": name}, nil
	case "getwalletinfo":
		if !loaded[wallet] {
			return nil, errors.New("the fixture wallet is not loaded")
		}
		return map[string]any{"walletname": wallet}, nil
	case "invalidateblock":
		var hash string
		if len(params) != 1 {
			return nil, errors.New("invalidateblock uses one hash")
		}
		if err := json.Unmarshal(params[0], &hash); err != nil {
			return nil, err
		}
		heightPath := filepath.Join(fixture.DataDir, "fixture-height")
		if fixture.TwoBranches {
			data, err := os.ReadFile(heightPath)
			if err != nil {
				return nil, err
			}
			switch hash {
			case strings.Repeat("b", 64):
				if string(data) == "110" {
					data = []byte("109")
				}
				return nil, os.WriteFile(heightPath, data, 0o600)
			case strings.Repeat("c", 64):
				if string(data) != "109" {
					return nil, errors.New("the second fixture branch is not active")
				}
			default:
				return nil, errors.New("the fixture rejected an unexpected branch")
			}
		} else if hash != strings.Repeat("b", 64) {
			return nil, errors.New("the fixture rejected an unexpected block")
		}
		data, err := os.ReadFile(heightPath)
		if err != nil {
			return nil, err
		}
		if height, err := strconv.Atoi(string(data)); err != nil || height < 100 {
			return nil, err
		}
		return nil, os.WriteFile(heightPath, []byte("100"), 0o600)
	case "getblock":
		var hash string
		var verbosity int
		if len(params) != 2 {
			return nil, errors.New("getblock uses a hash and verbosity")
		}
		if err := errors.Join(json.Unmarshal(params[0], &hash), json.Unmarshal(params[1], &verbosity)); err != nil {
			return nil, err
		}
		if fixture.WalletOnly && hash == config.ChainParamsFor(config.NetworkECash).GenesisHash.String() && verbosity == 0 {
			var block bytes.Buffer
			if err := config.ChainParamsFor(config.NetworkECash).GenesisBlock.Serialize(&block); err != nil {
				return nil, err
			}
			return hex.EncodeToString(block.Bytes()), nil
		}
		if hash != strings.Repeat("a", 64) && hash != strings.Repeat("d", 64) || verbosity != 0 {
			return nil, errors.New("the fixture expects the raw common block")
		}
		data, err := os.ReadFile(filepath.Join(fixture.DataDir, "blocks", "blk00000.dat"))
		if err != nil {
			return nil, err
		}
		return hex.EncodeToString(data[8:]), nil
	case "setnetworkactive":
		if len(params) != 1 {
			return nil, errors.New("setnetworkactive uses one value")
		}
		return nil, json.Unmarshal(params[0], active)
	case "getnetworkinfo":
		return map[string]any{"networkactive": *active}, nil
	case "stop":
		for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
			if err := os.WriteFile(filepath.Join(fixture.DataDir, name), []byte(name), 0o600); err != nil {
				return nil, err
			}
		}
		return "Core stopped", nil
	default:
		return nil, fmt.Errorf("unexpected fixture RPC %s", method)
	}
}
