package orchestrator

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/blockfile"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/corewalletfile"
)

// ECashMigrationStatus reports the local migration and subsequent chain sync.
type ECashMigrationStatus struct {
	JobID        string `json:"job_id"`
	FromID       string `json:"from_id"`
	ToID         string `json:"to_id"`
	Phase        string `json:"phase"`
	DataDir      string `json:"data_dir"`
	CommonHash   string `json:"common_hash"`
	SourceMagic  string `json:"source_magic"`
	TargetMagic  string `json:"target_magic"`
	Error        string `json:"error,omitempty"`
	SyncState    string `json:"sync_state"`
	CommonHeight int64  `json:"common_height"`
	PruneHeight  int64  `json:"prune_height"`
	BlockFiles   uint64 `json:"block_files"`
	UndoFiles    uint64 `json:"undo_files"`
	RecordsDone  uint64 `json:"records_done"`
	RecordsTotal uint64 `json:"records_total"`
	StartedAt    int64  `json:"started_at_unix"`
	RecordStage  string `json:"record_stage"`
	Running      bool   `json:"running"`
	Complete     bool   `json:"complete"`
	Pruned       bool   `json:"pruned"`
	WalletOnly   bool   `json:"wallet_only"`
}

type ecashMigration struct {
	Status         ECashMigrationStatus `json:"status"`
	Step           int                  `json:"step"`
	RootDir        string               `json:"root_dir"`
	BlocksDir      string               `json:"blocks_dir"`
	FromConfig     BinaryConfig         `json:"from_config"`
	ToConfig       BinaryConfig         `json:"to_config"`
	FromEntry      netcatalog.Network   `json:"from_entry"`
	ToEntry        netcatalog.Network   `json:"to_entry"`
	FromDigest     string               `json:"from_digest"`
	ToDigest       string               `json:"to_digest"`
	RejectedHash   string               `json:"rejected_hash"`
	RejectedHashes []string             `json:"rejected_hashes,omitempty"`
	WalletDir      string               `json:"wallet_dir"`
	WalletPaths    []string             `json:"wallet_paths"`
}

type ecashMigrationKey struct{}

func (o *Orchestrator) migrationPath() string {
	return filepath.Join(o.BitwindowDir, "ecash-migration.json")
}

func (o *Orchestrator) readMigration() (*ecashMigration, error) {
	if o.migrationState != nil {
		return o.migrationState, nil
	}
	data, err := os.ReadFile(o.migrationPath())
	if os.IsNotExist(err) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read ECX migration: %w", err)
	}
	var state ecashMigration
	if err := json.Unmarshal(data, &state); err != nil {
		return nil, fmt.Errorf("decode ECX migration: %w", err)
	}
	if state.Status.JobID == "" || state.Status.JobID == "." || state.Status.JobID == ".." || filepath.Base(state.Status.JobID) != state.Status.JobID || state.Step < 0 || state.Step > 5 {
		return nil, fmt.Errorf("invalid ECX migration record")
	}
	state.Status.Running = false
	o.migrationState = &state
	return o.migrationState, nil
}

func saveMigrationFile(path string, value any) error {
	data, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return err
	}
	file, err := os.OpenFile(path+".tmp", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o600)
	if err != nil {
		return err
	}
	_, writeErr := file.Write(data)
	var syncErr error
	if writeErr == nil {
		syncErr = file.Sync()
	}
	if err := errors.Join(writeErr, syncErr, file.Close()); err != nil {
		return err
	}
	if err := os.Rename(path+".tmp", path); err != nil {
		return err
	}
	if runtime.GOOS != "windows" {
		dir, err := os.Open(filepath.Dir(path))
		if err != nil {
			return err
		}
		return errors.Join(dir.Sync(), dir.Close())
	}
	return nil
}

func (o *Orchestrator) saveMigration(state *ecashMigration) error {
	o.migrationMu.Lock()
	defer o.migrationMu.Unlock()
	if err := saveMigrationFile(o.migrationPath(), state); err != nil {
		return fmt.Errorf("save ECX migration: %w", err)
	}
	copy := *state
	o.migrationState = &copy
	return nil
}

// ECashMigrationStatus reads the saved migration without access to Core.
func (o *Orchestrator) ECashMigrationStatus() (ECashMigrationStatus, error) {
	o.migrationMu.Lock()
	defer o.migrationMu.Unlock()
	state, err := o.readMigration()
	if err != nil {
		return ECashMigrationStatus{}, err
	}
	if state == nil {
		return ECashMigrationStatus{}, nil
	}
	status := state.Status
	status.Running = o.migrationBusy
	return status, nil
}

// EditBitcoinConfig applies an edit when no ECX migration is active.
func (o *Orchestrator) EditBitcoinConfig(edit func() error) error {
	o.migrationMu.Lock()
	defer o.migrationMu.Unlock()
	if o.migrationBusy {
		return fmt.Errorf("ECX migration is active; wait before a configuration change")
	}
	return edit()
}

func (o *Orchestrator) migrationCoreConfig(cfg BinaryConfig) (BinaryConfig, error) {
	o.migrationMu.Lock()
	defer o.migrationMu.Unlock()
	state, err := o.readMigration()
	if err != nil {
		return BinaryConfig{}, err
	}
	if state != nil && !state.Status.Complete {
		if state.Step < 4 {
			return state.FromConfig, nil
		}
		return state.ToConfig, nil
	}
	return expandECashPlaceholder(cfg, o.RunningECashID(netcatalog.Embedded())), nil
}

func (o *Orchestrator) checkECashMigrationStart(ctx context.Context, cfg BinaryConfig) error {
	if ctx.Value(ecashMigrationKey{}) == o {
		return nil
	}
	if !cfg.IsMainchainCore() && cfg.Name != "enforcer" && cfg.ChainLayer != 2 {
		return nil
	}
	status, err := o.ECashMigrationStatus()
	if err != nil {
		return err
	}
	if status.JobID != "" && !status.Complete {
		return fmt.Errorf("resume ECX migration %s before a node start", status.JobID)
	}
	if o.NodeMode() == NodeModeLight && !cfg.IsMainchainCore() {
		return nil
	}
	if o.Settings != nil && o.CurrentNetwork() == string(config.NetworkECash) {
		fromID := o.Settings.ECashChainID()
		o.mu.RLock()
		toID := o.ecashID
		o.mu.RUnlock()
		if fromID != "" && fromID != toID {
			files, err := o.hasECashData()
			if err != nil {
				return err
			}
			if files {
				return fmt.Errorf("ECX files belong to %s; use drivechain-cli ecash migrate --from %s --to %s --yes", fromID, fromID, toID)
			}
		}
	}
	return nil
}

func validMigrationID(id string) bool {
	if id == "" {
		return false
	}
	for _, ch := range id {
		if (ch < 'a' || ch > 'z') && (ch < '0' || ch > '9') && ch != '-' && ch != '_' {
			return false
		}
	}
	return true
}

func (o *Orchestrator) newMigration(fromID, toID string) (*ecashMigration, error) {
	if !validMigrationID(fromID) || !validMigrationID(toID) || fromID == toID {
		return nil, fmt.Errorf("select distinct source and target ECX networks")
	}
	if o.BitcoinConf == nil || o.BitcoinConf.Config == nil || o.Settings == nil {
		return nil, fmt.Errorf("ECX migration configuration is unavailable")
	}
	if o.CurrentNetwork() != string(config.NetworkECash) {
		return nil, fmt.Errorf("select the source ECX network before the migration")
	}
	if o.BitcoinConf.HasPrivateConf {
		return nil, fmt.Errorf("the private Core configuration controls this data directory; use a managed configuration for migration")
	}
	if err := o.checkMigrationRPC(); err != nil {
		return nil, err
	}
	o.mu.RLock()
	id := o.ecashID
	cat := o.Catalog
	raw, ok := o.rawConfigs["bitcoind"]
	o.mu.RUnlock()
	if recorded := o.Settings.ECashChainID(); recorded != "" {
		id = recorded
	}
	if fromID != id {
		return nil, fmt.Errorf("source %s does not match the active ECX network %s", fromID, id)
	}
	if !ok {
		return nil, fmt.Errorf("the Core binary configuration is unavailable")
	}
	from, fromOK := cat.ByID(fromID)
	to, toOK := cat.ByID(toID)
	if !fromOK || !toOK || from.Family != netcatalog.FamilyECash || to.Family != netcatalog.FamilyECash {
		return nil, fmt.Errorf("the catalog must include both ECX networks")
	}
	for _, entry := range []netcatalog.Network{from, to} {
		if _, err := blockfile.ParseMagic(entry.NetworkMagic); err != nil {
			return nil, fmt.Errorf("network %s magic: %w", entry.ID, err)
		}
		if entry.ForkHeight <= 1 {
			return nil, fmt.Errorf("network %s has no valid fork height", entry.ID)
		}
	}
	if strings.EqualFold(from.NetworkMagic, to.NetworkMagic) {
		return nil, fmt.Errorf("source and target network magic must differ")
	}
	if to.ForkHeight <= from.ForkHeight {
		return nil, fmt.Errorf("the target must fork BTC after the source network")
	}
	first := from
	if data, err := hex.DecodeString(first.ForkParentHash); err != nil || len(data) != 32 {
		return nil, fmt.Errorf("network %s must publish fork_parent_hash in /config", first.ID)
	}
	root, err := filepath.Abs(o.BitcoinConf.RootDataDir())
	if err != nil {
		return nil, err
	}
	dataDir, err := filepath.Abs(o.BitcoinConf.DataDir())
	if err != nil {
		return nil, err
	}
	blocksDir := o.BitcoinConf.Config.GetEffectiveSetting("blocksdir", "main")
	if blocksDir == "" {
		blocksDir = root
	}
	if !filepath.IsAbs(blocksDir) {
		blocksDir = filepath.Join(root, blocksDir)
	}
	state := &ecashMigration{
		Status: ECashMigrationStatus{FromID: fromID, ToID: toID, Phase: "preview", DataDir: dataDir,
			CommonHeight: int64(first.ForkHeight - 1), CommonHash: strings.ToLower(first.ForkParentHash),
			SourceMagic: strings.ToLower(from.NetworkMagic), TargetMagic: strings.ToLower(to.NetworkMagic), SyncState: "waiting"},
		RootDir: root, BlocksDir: filepath.Join(blocksDir, "blocks"), FromEntry: from, ToEntry: to,
		FromConfig: expandECashPlaceholder(raw, fromID), ToConfig: expandECashPlaceholder(raw, toID),
	}
	chainFiles, err := o.hasECashChainFiles()
	if err != nil {
		return nil, err
	}
	paths, err := o.ecashWalletFiles()
	if err != nil {
		return nil, err
	}
	if !chainFiles && len(paths) > 0 {
		o.setWalletOnlyMigration(state, paths)
	}
	return state, nil
}

func migrationFileCounts(state *ecashMigration) error {
	entries, err := os.ReadDir(state.BlocksDir)
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return err
	}
	state.Status.BlockFiles, state.Status.UndoFiles = 0, 0
	for _, entry := range entries {
		name := entry.Name()
		if len(name) != 12 || !strings.HasSuffix(name, ".dat") || entry.IsDir() {
			continue
		}
		if strings.HasPrefix(name, "blk") {
			state.Status.BlockFiles++
		}
		if strings.HasPrefix(name, "rev") {
			state.Status.UndoFiles++
		}
	}
	return nil
}

// PreviewECashMigration reads the plan without a process or data change.
func (o *Orchestrator) PreviewECashMigration(ctx context.Context, fromID, toID string) (ECashMigrationStatus, error) {
	if status, err := o.ECashMigrationStatus(); err != nil {
		return status, err
	} else if status.JobID != "" && !status.Complete {
		if status.FromID != fromID || status.ToID != toID {
			return status, fmt.Errorf("another ECX migration is incomplete")
		}
		return status, nil
	}
	state, err := o.newMigration(fromID, toID)
	if err != nil {
		return ECashMigrationStatus{}, err
	}
	if err := migrationFileCounts(state); err != nil {
		return state.Status, err
	}
	if o.coreRPCReachable() {
		client, err := o.CoreStatusClient()
		if err != nil {
			return state.Status, err
		}
		if err := o.checkWalletOnlySource(ctx, client, state); err != nil {
			return state.Status, err
		}
		if err := checkMigrationChain(ctx, client, state, state.Status.WalletOnly); err != nil {
			return state.Status, err
		}
	}
	return state.Status, nil
}

// StartECashMigration starts or resumes a daemon-owned migration.
func (o *Orchestrator) StartECashMigration(ctx context.Context, fromID, toID string) (ECashMigrationStatus, error) {
	o.migrationMu.Lock()
	previous, err := o.readMigration()
	if err != nil {
		o.migrationMu.Unlock()
		return ECashMigrationStatus{}, err
	}
	if o.migrationBusy || previous != nil && !previous.Status.Complete {
		if previous == nil || previous.Status.FromID != fromID || previous.Status.ToID != toID {
			o.migrationMu.Unlock()
			return ECashMigrationStatus{}, fmt.Errorf("another ECX migration is incomplete")
		}
		if o.migrationBusy {
			result := previous.Status
			result.Running = true
			o.migrationMu.Unlock()
			return result, nil
		}
	}
	var state ecashMigration
	if previous != nil && previous.Status.FromID == fromID && previous.Status.ToID == toID {
		if previous.Status.Complete {
			result := previous.Status
			o.migrationMu.Unlock()
			return result, nil
		}
		state = *previous
	} else {
		fresh, err := o.newMigration(fromID, toID)
		if err != nil {
			o.migrationMu.Unlock()
			return ECashMigrationStatus{}, err
		}
		state = *fresh
		if o.coreRPCReachable() {
			client, err := o.CoreStatusClient()
			if err == nil {
				err = o.checkWalletOnlySource(ctx, client, &state)
			}
			if err != nil {
				o.migrationMu.Unlock()
				return ECashMigrationStatus{}, err
			}
		}
		state.Status.JobID = rand.Text()
		state.Status.Phase = "prepare"
		state.Status.StartedAt = time.Now().Unix()
	}
	if err := ctx.Err(); err != nil {
		o.migrationMu.Unlock()
		return state.Status, err
	}
	state.Status.Error = ""
	state.Status.Running = true
	if err := saveMigrationFile(o.migrationPath(), &state); err != nil {
		o.migrationMu.Unlock()
		return state.Status, err
	}
	copy := state
	o.migrationState = &copy
	o.migrationBusy = true
	release := func() {}
	if o.clients != nil {
		release = o.clients.Hold()
	}
	o.migrationMu.Unlock()
	go func() {
		defer release()
		o.runECashMigration(state)
	}()
	return state.Status, nil
}

func (o *Orchestrator) runECashMigration(state ecashMigration) {
	o.swapNetworkMu.Lock()
	o.coreVariantMu.Lock()
	ctx := context.WithValue(context.Background(), ecashMigrationKey{}, o)
	err := o.runMigrationSteps(ctx, &state)
	o.coreVariantMu.Unlock()
	o.swapNetworkMu.Unlock()
	state.Status.Running = false
	if err != nil {
		state.Status.Error = err.Error()
	}
	if saveErr := o.saveMigration(&state); saveErr != nil {
		state.Status.Error = errors.Join(err, saveErr).Error()
		state.Status.Complete = false
	}
	if state.Status.Complete {
		o.restoreMigrationCoreMonitor()
	}
	o.migrationMu.Lock()
	o.migrationState = &state
	o.migrationBusy = false
	o.migrationMu.Unlock()
}

func (o *Orchestrator) restoreMigrationCoreMonitor() {
	o.mu.RLock()
	cfg := o.configs["bitcoind"]
	o.mu.RUnlock()
	if cfg.Port == 0 {
		cfg.Port = o.BitcoinConf.GetRPCPort()
	}
	checker := NewHealthChecker(cfg, HealthCheckOpts{Credentials: o.BitcoinConf.GetRPCCredentials})
	monitor := o.getOrCreateMonitor("bitcoind", checker, bitcoindStartupPatterns)
	ctx := context.Background()
	monitor.StartConnectionTimer(ctx)
	// Migration completion proves RPC startup before presync ends.
	monitor.mu.Lock()
	monitor.completedStartup = true
	monitor.mu.Unlock()
	var opts StartOpts
	o.prepareCoreArgs(&opts)
	o.startCoreRestartTimer(ctx, monitor, opts.CoreArgs)
}

func (o *Orchestrator) runMigrationSteps(ctx context.Context, state *ecashMigration) error {
	if err := o.checkMigrationRPC(); err != nil {
		return err
	}
	root, err := filepath.Abs(o.BitcoinConf.RootDataDir())
	if err != nil {
		return err
	}
	if root != state.RootDir || o.CurrentNetwork() != string(config.NetworkECash) {
		return fmt.Errorf("restore the saved ECX data directory and network before migration resume")
	}
	blocks := o.BitcoinConf.Config.GetEffectiveSetting("blocksdir", "main")
	if blocks == "" {
		blocks = root
	}
	if !filepath.IsAbs(blocks) {
		blocks = filepath.Join(root, blocks)
	}
	if filepath.Join(blocks, "blocks") != state.BlocksDir {
		return fmt.Errorf("restore the saved blocksdir before migration resume")
	}
	if state.Step > 1 && o.BitcoinConf.Config.GetEffectiveSetting("walletdir", "main") != state.WalletDir {
		return fmt.Errorf("restore the saved walletdir before migration resume")
	}
	phases := []string{"prepare", "rewind", "convert", "select", "check"}
	for state.Step < len(phases) {
		state.Status.Phase = phases[state.Step]
		if err := o.saveMigration(state); err != nil {
			return err
		}
		var err error
		switch state.Step {
		case 0:
			err = o.prepareMigration(ctx, state)
		case 1:
			err = o.rewindMigration(ctx, state)
		case 2:
			err = o.convertMigration(ctx, state)
		case 3:
			err = o.selectMigration(state)
		case 4:
			err = o.checkMigration(ctx, state)
		}
		if err != nil {
			return fmt.Errorf("%s: %w", state.Status.Phase, err)
		}
		state.Step++
		if err := o.saveMigration(state); err != nil {
			return err
		}
	}
	state.Status.Phase = "complete"
	state.Status.Complete = true
	state.Status.SyncState = "syncing"
	return nil
}

func (o *Orchestrator) checkMigrationRPC() error {
	host := o.BitcoinConf.GetRPCHost()
	if host == "localhost" {
		return nil
	}
	if ip := net.ParseIP(strings.Trim(host, "[]")); ip != nil && ip.IsLoopback() {
		return nil
	}
	return fmt.Errorf("ECX migration uses a Core process on the daemon host; rpcconnect is %s", host)
}

func (o *Orchestrator) migrationBinary(ctx context.Context, cfg BinaryConfig) (string, error) {
	variant, ok := ResolveCoreVariant(cfg, "ecash", string(config.NetworkECash))
	if !ok {
		return "", fmt.Errorf("ECX Core variant is unavailable")
	}
	download := NewDownloadManager(o.DataDir, o.download.configFilePath, o.log)
	download.CoreVariant = func() (CoreVariantSpec, bool) { return variant, true }
	progress, err := download.Download(ctx, cfg, string(config.NetworkECash), false)
	if err != nil {
		return "", err
	}
	for item := range progress {
		if item.Error != nil {
			return "", item.Error
		}
	}
	return CoreBinaryPath(o.DataDir, variant, cfg.BinaryName), nil
}

func migrationDigest(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	hash := sha256.New()
	_, readErr := io.Copy(hash, file)
	if err := errors.Join(readErr, file.Close()); err != nil {
		return "", err
	}
	return hex.EncodeToString(hash.Sum(nil)), nil
}

func (o *Orchestrator) prepareMigration(ctx context.Context, state *ecashMigration) error {
	for _, item := range []struct {
		cfg    BinaryConfig
		digest *string
	}{{state.FromConfig, &state.FromDigest}, {state.ToConfig, &state.ToDigest}} {
		path, err := o.migrationBinary(ctx, item.cfg)
		if err != nil {
			return err
		}
		digest, err := migrationDigest(path)
		if err != nil {
			return err
		}
		if *item.digest != "" && *item.digest != digest {
			return fmt.Errorf("the Core binary changed at %s", path)
		}
		*item.digest = digest
	}
	return nil
}

func (o *Orchestrator) stopMigrationNodes(ctx context.Context) error {
	configs := o.Configs()
	for _, cfg := range configs {
		if cfg.ChainLayer != 2 && cfg.Name != "bitcoind" && cfg.Name != "enforcer" {
			continue
		}
		names := []string{cfg.Name}
		if cfg.ChainLayer == 2 {
			names = append(names, sidechainGUIProcessName(cfg.Name))
		}
		for _, name := range names {
			if o.process.IsAdopted(name) && !o.mayStopAdopted(name) {
				return fmt.Errorf("stop external %s in its own launcher before migration", name)
			}
		}
	}
	if !o.process.IsRunning("bitcoind") && o.coreRPCReachable() {
		return fmt.Errorf("the Core is external to this daemon; stop it before migration")
	}
	for _, cfg := range configs {
		if cfg.ChainLayer == 2 {
			if err := o.Stop(ctx, cfg.Name, false); err != nil {
				return err
			}
		}
	}
	if o.process.IsRunning("enforcer") {
		if err := o.Stop(ctx, "enforcer", false); err != nil {
			return err
		}
	}
	if err := o.closeRemoteEnforcer(); err != nil {
		return err
	}
	return o.stopMigrationCore(ctx)
}

func (o *Orchestrator) stopMigrationCore(ctx context.Context) error {
	proc := o.process.Get("bitcoind")
	if proc == nil {
		return nil
	}
	if proc.Adopted && !o.mayStopAdopted("bitcoind") {
		return fmt.Errorf("the Core is external to this daemon; stop it before migration")
	}
	client, err := o.CoreStatusClient()
	if err != nil {
		return err
	}
	if err := client.Stop(ctx); err != nil {
		return err
	}
	timer := time.NewTimer(10 * time.Minute)
	defer timer.Stop()
	select {
	case <-proc.ExitCh():
		o.monitorsMu.Lock()
		if mon := o.monitors["bitcoind"]; mon != nil {
			mon.MarkStopped()
		}
		o.monitorsMu.Unlock()
		return nil
	case <-ctx.Done():
		return ctx.Err()
	case <-timer.C:
		return fmt.Errorf("the Core did not stop within ten minutes; wait for its exit before the next migration request")
	}
}

func (o *Orchestrator) startMigrationCore(ctx context.Context, state *ecashMigration, target bool) (*CoreStatusClient, error) {
	cfg, digest := state.FromConfig, state.FromDigest
	if target {
		cfg, digest = state.ToConfig, state.ToDigest
	}
	variant, ok := ResolveCoreVariant(cfg, "ecash", string(config.NetworkECash))
	if !ok {
		return nil, fmt.Errorf("ECX Core variant is unavailable")
	}
	path := CoreBinaryPath(o.DataDir, variant, cfg.BinaryName)
	actual, err := migrationDigest(path)
	if err != nil {
		return nil, err
	}
	if actual != digest {
		return nil, fmt.Errorf("the Core binary changed at %s", path)
	}
	if proc := o.process.Get("bitcoind"); proc != nil && proc.BinPath != path {
		return nil, fmt.Errorf("the Core process uses %s; the migration expects %s", proc.BinPath, path)
	}
	if !o.process.IsRunning("bitcoind") {
		args := []string{"-conf=" + o.BitcoinConf.GetConfFilePath(), "-datadir=" + state.RootDir, "-networkactive=0", "-walletbroadcast=0"}
		if _, err := o.process.Start(ctx, cfg, args, nil); err != nil {
			return nil, err
		}
	}
	deadline := time.NewTimer(10 * time.Minute)
	defer deadline.Stop()
	tick := time.NewTicker(time.Second)
	defer tick.Stop()
	for {
		client, err := o.CoreStatusClient()
		if err == nil {
			if _, err := client.call(ctx, "getblockchaininfo"); err == nil {
				return client, nil
			}
		}
		if !o.process.IsRunning("bitcoind") {
			return nil, fmt.Errorf("the Core exited before its RPC became available")
		}
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		case <-deadline.C:
			return nil, fmt.Errorf("the Core RPC did not start within ten minutes")
		case <-tick.C:
		}
	}
}

func checkMigrationChain(ctx context.Context, client *CoreStatusClient, state *ecashMigration, atParent bool) error {
	var chain struct {
		Chain       string `json:"chain"`
		Blocks      int64  `json:"blocks"`
		Pruned      bool   `json:"pruned"`
		PruneHeight int64  `json:"pruneheight"`
	}
	if err := migrationRPC(ctx, client, "getblockchaininfo", &chain); err != nil {
		return err
	}
	state.Status.Pruned, state.Status.PruneHeight = chain.Pruned, chain.PruneHeight
	if chain.Chain != "main" {
		return fmt.Errorf("the Core reports chain %s; ECX uses main", chain.Chain)
	}
	if chain.Blocks < state.Status.CommonHeight {
		return fmt.Errorf("the Core must reach the common height %d before migration", state.Status.CommonHeight)
	}
	if chain.Pruned && chain.PruneHeight > state.Status.CommonHeight {
		return fmt.Errorf("pruning removed the rollback interval; keep the files and restore an earlier chainstate")
	}
	if atParent && chain.Blocks != state.Status.CommonHeight {
		return fmt.Errorf("the Core tip %d differs from common height %d", chain.Blocks, state.Status.CommonHeight)
	}
	var hash string
	if err := migrationRPC(ctx, client, "getblockhash", &hash, state.Status.CommonHeight); err != nil {
		return err
	}
	if hash != state.Status.CommonHash {
		return fmt.Errorf("the Core common block %s differs from catalog %s", hash, state.Status.CommonHash)
	}
	return nil
}

func migrationRPC(ctx context.Context, client *CoreStatusClient, method string, out any, args ...any) error {
	data, err := client.call(ctx, method, args...)
	if err != nil {
		return err
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(data, out); err != nil {
		return fmt.Errorf("decode %s: %w", method, err)
	}
	return nil
}

func (o *Orchestrator) migrationBackup(state *ecashMigration) string {
	return filepath.Join(state.Status.DataDir, "ecash-migrations", state.Status.JobID)
}

func moveMigrationFile(source, target string) error {
	_, sourceErr := os.Stat(source)
	if os.IsNotExist(sourceErr) {
		return nil
	}
	if sourceErr != nil {
		return sourceErr
	}
	base := target
	for index := 1; ; index++ {
		if _, err := os.Stat(target); os.IsNotExist(err) {
			break
		} else if err != nil {
			return err
		}
		target = base + "." + strconv.Itoa(index)
	}
	if err := os.MkdirAll(filepath.Dir(target), 0o700); err != nil {
		return err
	}
	return os.Rename(source, target)
}

func (o *Orchestrator) rewindMigration(ctx context.Context, state *ecashMigration) error {
	sourceActive := o.process.IsRunning("bitcoind")
	if sourceActive {
		client, err := o.CoreStatusClient()
		if err != nil {
			return err
		}
		if err := o.saveMigrationWallets(ctx, client, state); err != nil {
			return err
		}
		if state.Status.WalletOnly {
			if err := checkMigrationChain(ctx, client, state, true); err != nil {
				return err
			}
		}
	}
	if err := o.stopMigrationNodes(ctx); err != nil {
		return err
	}
	if state.Status.WalletOnly && sourceActive {
		return nil
	}
	for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
		if err := moveMigrationFile(filepath.Join(state.Status.DataDir, name), filepath.Join(o.migrationBackup(state), "source-"+name)); err != nil {
			return err
		}
	}
	client, err := o.startMigrationCore(ctx, state, false)
	if err != nil {
		return err
	}
	if err := o.checkWalletOnlySource(ctx, client, state); err != nil {
		return err
	}
	if err := checkMigrationChain(ctx, client, state, false); err != nil {
		return err
	}
	if err := o.saveMigrationWallets(ctx, client, state); err != nil {
		return err
	}
	if state.RejectedHash != "" && !slices.Contains(state.RejectedHashes, state.RejectedHash) {
		state.RejectedHashes = append(state.RejectedHashes, state.RejectedHash)
	}
	for _, hash := range state.RejectedHashes {
		if err := migrationRPC(ctx, client, "invalidateblock", nil, hash); err != nil {
			return err
		}
	}
	for {
		var chain struct {
			Blocks int64 `json:"blocks"`
		}
		if err := migrationRPC(ctx, client, "getblockchaininfo", &chain); err != nil {
			return err
		}
		if chain.Blocks <= state.Status.CommonHeight {
			break
		}
		if err := migrationRPC(ctx, client, "getblockhash", &state.RejectedHash, state.Status.CommonHeight+1); err != nil {
			return err
		}
		if slices.Contains(state.RejectedHashes, state.RejectedHash) {
			return fmt.Errorf("source block %s remains active after invalidation", state.RejectedHash)
		}
		state.RejectedHashes = append(state.RejectedHashes, state.RejectedHash)
		if err := o.saveMigration(state); err != nil {
			return err
		}
		if err := migrationRPC(ctx, client, "invalidateblock", nil, state.RejectedHash); err != nil {
			return err
		}
		if err := o.Settings.CommitRewind(state.RejectedHash); err != nil {
			return err
		}
	}
	if err := checkMigrationChain(ctx, client, state, true); err != nil {
		return err
	}
	if err := o.stopMigrationCore(ctx); err != nil {
		return err
	}
	return nil
}

func (o *Orchestrator) saveMigrationWallets(ctx context.Context, client *CoreStatusClient, state *ecashMigration) error {
	state.WalletDir = o.BitcoinConf.Config.GetEffectiveSetting("walletdir", "main")
	if o.BitcoinConf.Config.GetEffectiveSetting("disablewallet", "main") != "1" {
		var paths []string
		if err := migrationRPC(ctx, client, "listwallets", &paths); err != nil {
			return err
		}
		state.WalletPaths = mergeMigrationWallets(state.WalletPaths, paths)
		if state.Status.WalletOnly {
			if err := o.normalizeWalletOnlyPaths(state); err != nil {
				return err
			}
		}
	}
	return o.saveMigration(state)
}

func mergeMigrationWallets(saved, loaded []string) []string {
	for _, path := range loaded {
		if !slices.Contains(saved, path) {
			saved = append(saved, path)
		}
	}
	return saved
}

func (o *Orchestrator) convertMigration(ctx context.Context, state *ecashMigration) error {
	if o.process.IsRunning("bitcoind") || o.coreRPCReachable() {
		return fmt.Errorf("stop Core before file conversion")
	}
	from, err := blockfile.ParseMagic(state.Status.SourceMagic)
	if err != nil {
		return err
	}
	to, err := blockfile.ParseMagic(state.Status.TargetMagic)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(o.migrationBackup(state), 0o700); err != nil {
		return err
	}
	wallets := corewalletfile.Options{
		DataDir: state.Status.DataDir, WalletDir: state.WalletDir, WalletPaths: state.WalletPaths,
		From: from, To: to, JournalPath: filepath.Join(o.migrationBackup(state), "wallets.json"),
	}
	if _, err := corewalletfile.Preview(ctx, wallets); err != nil {
		return err
	}
	chainFiles, err := o.hasECashChainFiles()
	if err != nil {
		return err
	}
	var report blockfile.Report
	if !state.Status.WalletOnly || chainFiles {
		lastSave := time.Time{}
		report, err = blockfile.Convert(ctx, blockfile.Options{DataDir: state.Status.DataDir, BlocksDir: state.BlocksDir,
			JournalPath: filepath.Join(o.migrationBackup(state), "blocks.json"), From: from, To: to,
			Progress: func(progress blockfile.Progress) error {
				state.Status.RecordsDone = uint64(progress.ConvertedRecords)
				state.Status.RecordsTotal = uint64(progress.Records)
				state.Status.RecordStage = progress.Stage
				if time.Since(lastSave) < time.Second {
					return nil
				}
				lastSave = time.Now()
				return o.saveMigration(state)
			}})
		if err != nil {
			return err
		}
	}
	if _, err := corewalletfile.Convert(ctx, wallets); err != nil {
		return err
	}
	state.Status.BlockFiles = uint64(report.BlockFiles)
	state.Status.UndoFiles = uint64(report.UndoFiles)
	state.Status.RecordsDone = uint64(report.ConvertedRecords)
	state.Status.RecordsTotal = uint64(report.Records)
	for _, name := range []string{"peers.dat", "anchors.dat", "mempool.dat"} {
		if err := moveMigrationFile(filepath.Join(state.Status.DataDir, name), filepath.Join(o.migrationBackup(state), "target-"+name)); err != nil {
			return err
		}
	}
	return nil
}

func (o *Orchestrator) selectMigration(state *ecashMigration) error {
	for path := range o.swapStatePaths(config.NetworkECash) {
		if err := moveMigrationFile(path, path+".ecash-"+state.Status.FromID+"-"+state.Status.JobID); err != nil {
			return err
		}
	}
	o.BitcoinConf.ECashID = state.Status.ToID
	o.BitcoinConf.Config.SetSetting("uacomment", config.ECashUAComment(state.Status.ToID), "main")
	o.BitcoinConf.Config.SetSetting("walletbroadcast", "0", "main")
	if peer := o.BitcoinConf.Config.GetEffectiveSetting("addnode", "main"); peer == state.FromEntry.P2P.Address {
		if state.ToEntry.P2P.Address != "" {
			o.BitcoinConf.Config.SetSetting("addnode", state.ToEntry.P2P.Address, "main")
		} else {
			o.BitcoinConf.Config.RemoveSetting("addnode", "main")
		}
	}
	if err := o.BitcoinConf.SaveConfig(); err != nil {
		return err
	}
	config.SetECashEndpoints(state.ToEntry)
	if o.EnforcerConf != nil {
		if _, err := o.EnforcerConf.RetargetECashNetwork(state.Status.FromID, state.Status.ToID); err != nil {
			return err
		}
	}
	if err := o.recordECashChain(state.Status.ToID); err != nil {
		return err
	}
	if err := o.Settings.SetPendingEnforcerWipe(""); err != nil {
		return err
	}
	if _, err := o.Settings.SetECashNetworkID(state.Status.ToID); err != nil {
		return err
	}
	o.mu.Lock()
	o.ecashID = state.Status.ToID
	for name, raw := range o.rawConfigs {
		o.configs[name] = expandECashPlaceholder(raw, state.Status.ToID)
	}
	o.mu.Unlock()
	config.SetECashNetworkID(state.Status.ToID)
	config.SetForkHeight(config.NetworkECash, state.ToEntry.ForkHeight)
	config.SetNetworkDisplayName(config.NetworkECash, state.ToEntry.DisplayName)
	config.SetECashEndpoints(state.ToEntry)
	if o.WalletSvc != nil {
		o.WalletSvc.ClearNetworkScans(string(config.NetworkECash))
	}
	o.clearNetworkSwapCaches()
	return nil
}

func (o *Orchestrator) checkMigration(ctx context.Context, state *ecashMigration) error {
	client, err := o.startMigrationCore(ctx, state, true)
	if err != nil {
		return err
	}
	if err := checkMigrationChain(ctx, client, state, false); err != nil {
		return err
	}
	var block string
	if err := migrationRPC(ctx, client, "getblock", &block, state.Status.CommonHash, 0); err != nil {
		return err
	}
	if block == "" {
		return fmt.Errorf("the Core returned an empty common block")
	}
	if o.BitcoinConf.Config.GetEffectiveSetting("disablewallet", "main") != "1" {
		var loaded []string
		if err := migrationRPC(ctx, client, "listwallets", &loaded); err != nil {
			return err
		}
		walletNames := make(map[string]string)
		if state.Status.WalletOnly {
			for _, name := range loaded {
				path, err := migrationWalletPath(state, name)
				if err != nil {
					return err
				}
				walletNames[path] = name
			}
		}
		for _, path := range state.WalletPaths {
			name := path
			if state.Status.WalletOnly {
				path, err := migrationWalletPath(state, path)
				if err != nil {
					return err
				}
				if loadedName, ok := walletNames[path]; ok {
					name = loadedName
				}
			}
			if !slices.Contains(loaded, name) {
				if err := migrationRPC(ctx, client, "loadwallet", nil, name); err != nil {
					return err
				}
			}
			if _, err := client.callWallet(ctx, url.PathEscape(name), "getwalletinfo"); err != nil {
				return err
			}
		}
	}
	if err := migrationRPC(ctx, client, "setnetworkactive", nil, true); err != nil {
		return err
	}
	return nil
}

func (o *Orchestrator) hasECashChainFiles() (bool, error) {
	if o.BitcoinConf == nil {
		return false, nil
	}
	root := o.ecashDatadir()
	if root == "" {
		if config.NetworkFromString(o.Network) != config.NetworkECash {
			return false, nil
		}
		root = o.BitcoinConf.RootDataDir()
	}
	blocks := o.BitcoinConf.Config.GetEffectiveSetting("blocksdir", "main")
	if blocks == "" {
		blocks = root
	}
	if !filepath.IsAbs(blocks) {
		blocks = filepath.Join(root, blocks)
	}
	files, err := filepath.Glob(filepath.Join(blocks, "blocks", "blk*.dat"))
	if err != nil {
		return false, err
	}
	if len(files) > 0 {
		return true, nil
	}
	for _, path := range []string{filepath.Join(root, "chainstate", "CURRENT"), filepath.Join(blocks, "blocks", "index", "CURRENT")} {
		if _, err := os.Stat(path); err == nil {
			return true, nil
		} else if !os.IsNotExist(err) {
			return false, err
		}
	}
	return false, nil
}

func (o *Orchestrator) applyDiskECashSwitch(ctx context.Context, toID string) (bool, error) {
	status, err := o.ECashMigrationStatus()
	if err != nil {
		return true, err
	}
	files, err := o.hasECashData()
	if err != nil {
		return true, err
	}
	if !files && (status.JobID == "" || status.Complete) {
		return false, nil
	}
	o.mu.RLock()
	fromID := o.ecashID
	o.mu.RUnlock()
	if status.JobID != "" && !status.Complete {
		fromID = status.FromID
	}
	if recorded := o.Settings.ECashChainID(); recorded != "" && (status.JobID == "" || status.Complete) {
		fromID = recorded
	}
	if fromID == toID && (status.JobID == "" || status.Complete) {
		return true, nil
	}
	status, err = o.StartECashMigration(ctx, fromID, toID)
	if err != nil {
		return true, err
	}
	tick := time.NewTicker(250 * time.Millisecond)
	defer tick.Stop()
	for {
		if !status.Running {
			if status.Error != "" {
				return true, errors.New(status.Error)
			}
			if !status.Complete {
				return true, fmt.Errorf("ECX migration did not complete")
			}
			return true, nil
		}
		select {
		case <-ctx.Done():
			return true, ctx.Err()
		case <-tick.C:
		}
		status, err = o.ECashMigrationStatus()
		if err != nil {
			return true, err
		}
	}
}
