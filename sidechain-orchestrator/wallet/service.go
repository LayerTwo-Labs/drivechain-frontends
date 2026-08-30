package wallet

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47send"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/walletfile"
	"github.com/btcsuite/btcd/chaincfg"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/tyler-smith/go-bip32"
	"github.com/tyler-smith/go-bip39"
)

// Service manages wallet lifecycle: load, save, encrypt, decrypt, generate, starters.
type Service struct {
	mu sync.RWMutex

	bitwindowDir string
	log          zerolog.Logger

	// Electrum chain state (addresses, UTXOs, txs), one database per network
	// under <bitwindowDir>/<network>/. nil when it could not be opened.
	dbMu       sync.RWMutex
	network    string
	electrumDB *sql.DB

	// In-memory state
	wallets         []WalletData
	activeWalletID  string
	starterWalletID string
	encryptionKey   []byte
	unlockedPass    string

	// The wallet file content this process last read. Every write compares
	// against it, so a write can never drop a change made behind our back.
	lastWalletDigest      walletfile.Digest
	lastWalletDigestKnown bool

	// Callbacks
	// Dart: deleteAllWallets stops all binaries before wiping (L560-575)
	OnStopAllBinaries func() error
	// Dart: deleteAllWallets deletes per-binary wallet paths (L600-608)
	// Returns list of wallet file paths for all managed binaries
	GetBinaryWalletPaths func() []string
	// Dart: _deleteCoreMultisigWallets (L534) — path to Bitcoin Core datadir
	CoreDataDir string

	// File watcher
	watcher   *fsnotify.Watcher
	done      chan struct{}
	closeOnce sync.Once

	// Per-subscriber fan-out for wallet state-change notifications. See
	// Subscribe. The legacy single-buffered-channel design used to live here
	// and broke whenever two consumers raced for the same buffered value —
	// e.g. multiple WatchWalletData streams would steal each other's events.
	subsMu sync.Mutex
	subs   map[chan struct{}]struct{}

	// Electrum scan progress, surfaced to the GUI via GetSyncStatus.
	syncReporter *syncReporter
}

// NewService creates a new wallet service.
func NewService(bitwindowDir string, log zerolog.Logger) *Service {
	return &Service{
		bitwindowDir: bitwindowDir,
		log:          log.With().Str("component", "wallet").Logger(),
		done:         make(chan struct{}),
		subs:         make(map[chan struct{}]struct{}),
		syncReporter: newSyncReporter(),
	}
}

// SyncSnapshot returns the latest electrum scan progress for a wallet.
func (s *Service) SyncSnapshot(walletID string) SyncProgress {
	return s.syncReporter.snapshot(walletID)
}

// ActiveSyncStatus returns the active wallet's scan progress, for GetSyncStatus.
func (s *Service) ActiveSyncStatus() SyncProgress {
	return s.syncReporter.snapshot(s.ActiveWalletID())
}

// Subscribe returns a per-caller channel that receives a notification every
// time the wallet state changes (wallet created, deleted, switched,
// encrypted, …). The channel is buffered to 1; notifyChanged drops on full
// buffer rather than blocking, so a wedged consumer just misses intermediate
// updates and picks up the next one.
//
// The subscription is unwound when ctx cancels. Always pass a ctx scoped to
// the consumer's lifetime (per-stream for a Watch handler, the binary's
// boot ctx for a one-shot wait).
func (s *Service) Subscribe(ctx context.Context) <-chan struct{} {
	ch := make(chan struct{}, 1)
	s.subsMu.Lock()
	s.subs[ch] = struct{}{}
	s.subsMu.Unlock()

	go func() {
		<-ctx.Done()
		s.subsMu.Lock()
		defer s.subsMu.Unlock()
		if _, ok := s.subs[ch]; ok {
			delete(s.subs, ch)
			close(ch)
		}
	}()

	return ch
}

// moveToBackup relocates `path` under `<parent>/wallet_backups/<ts>/<base>`,
// keeping the backup local to the original binary's data tree (Bitcoin
// Core wallets stay under the bitcoind datadir, the enforcer's wallet stays
// under bip300301_enforcer, etc.). Same-fs rename keeps it atomic and
// avoids cross-device move pitfalls. No-ops cleanly when `path` doesn't
// exist. Used in lieu of os.Remove anywhere a wallet-bearing file or
// directory could be touched: deletion is irreversible, but a renamed copy
// is always a `mv` away from recovery.
func (s *Service) moveToBackup(path string) (string, error) {
	parent := filepath.Dir(path)
	return s.moveToBackupRoot(path, filepath.Join(parent, "wallet_backups", time.Now().UTC().Format("20060102-150405")))
}

func (s *Service) moveMasterWalletFilesToBackup() error {
	backupRoot := filepath.Join(s.bitwindowDir, "wallet_backups", time.Now().UTC().Format("20060102-150405"))
	// Take the write lock across the move. A writer that already passed its
	// compare would otherwise put the wallet back after the wipe ran.
	return walletfile.WithLock(s.walletFilePath(), func() error {
		for _, p := range s.MasterWalletPaths() {
			if _, err := s.moveToBackupRoot(p, backupRoot); err != nil {
				return fmt.Errorf("back up current wallet path %s: %w", p, err)
			}
		}
		return nil
	})
}

func (s *Service) moveToBackupRoot(path, backupRoot string) (string, error) {
	if path == "" {
		return "", nil
	}
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return "", nil
	} else if err != nil {
		return "", fmt.Errorf("stat %s: %w", path, err)
	}

	if err := os.MkdirAll(backupRoot, 0o700); err != nil {
		return "", fmt.Errorf("create backup root: %w", err)
	}

	dest := filepath.Join(backupRoot, filepath.Base(path))
	// Tag against second-resolution timestamp collisions (two backups
	// inside the same parent within the same second).
	if _, err := os.Stat(dest); err == nil {
		dest = filepath.Join(backupRoot, fmt.Sprintf("%s-%s", filepath.Base(path), shortHash(path+time.Now().Format(".999999999"))))
	}

	if err := os.Rename(path, dest); err != nil {
		// Same-parent rename should be in-fs; this branch only fires if a
		// future caller redirects backupRoot to a different mount.
		if err := copyTreeAndRemove(path, dest); err != nil {
			return "", fmt.Errorf("backup-move %s -> %s: %w", path, dest, err)
		}
	}
	s.log.Info().Str("from", path).Str("to", dest).Msg("wallet path moved to backup")
	return dest, nil
}

// BackupPath soft-deletes a single wallet path by moving it under its parent's
// wallet_backups/<ts>/. Exported wrapper around moveToBackup for the reset flow,
// which classifies wallet paths and backs them up instead of removing them.
func (s *Service) BackupPath(path string) (string, error) {
	return s.moveToBackup(path)
}

// MasterWalletPaths returns the shared bitwindow wallet files (wallet.json +
// wallet_encryption.json + metadata.json) at their flat <bitwindowDir> location.
func (s *Service) MasterWalletPaths() []string {
	return []string{s.walletFilePath(), s.metadataFilePath(), s.WalletMetadataFilePath()}
}

// ClearInMemoryState drops the loaded wallet set so the service reflects a
// post-wipe empty state. Called after the master wallet has been moved aside.
func (s *Service) ClearInMemoryState() {
	s.mu.Lock()
	s.wallets = nil
	s.activeWalletID = ""
	s.encryptionKey = nil
	s.unlockedPass = ""
	s.setWalletDigestLocked(nil)
	s.mu.Unlock()
}

// shortHash produces a deterministic 8-char fingerprint of `s` for use as a
// disambiguator when two paths share a basename in the same backup dir.
func shortHash(s string) string {
	sum := sha256.Sum256([]byte(s))
	return hex.EncodeToString(sum[:4])
}

// copyTreeAndRemove copies src to dst and removes src on success.
func copyTreeAndRemove(src, dst string) error {
	info, err := os.Stat(src)
	if err != nil {
		return err
	}
	if info.IsDir() {
		if err := copyDir(src, dst); err != nil {
			return err
		}
	} else {
		if err := copyFile(src, dst, info.Mode()); err != nil {
			return err
		}
	}
	return os.RemoveAll(src)
}

func copyDir(src, dst string) error {
	if err := os.MkdirAll(dst, 0o700); err != nil {
		return err
	}
	entries, err := os.ReadDir(src)
	if err != nil {
		return err
	}
	for _, e := range entries {
		sp := filepath.Join(src, e.Name())
		dp := filepath.Join(dst, e.Name())
		info, err := e.Info()
		if err != nil {
			return err
		}
		if info.IsDir() {
			if err := copyDir(sp, dp); err != nil {
				return err
			}
			continue
		}
		if err := copyFile(sp, dp, info.Mode()); err != nil {
			return err
		}
	}
	return nil
}

func copyFile(src, dst string, mode os.FileMode) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close() //nolint:errcheck // read-only
	out, err := os.OpenFile(dst, os.O_RDWR|os.O_CREATE|os.O_TRUNC, mode.Perm())
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		_ = out.Close()
		return err
	}
	return out.Close()
}

// Init loads the wallet file and starts the file watcher.
func (s *Service) Init() error {
	s.log.Info().Str("dir", s.bitwindowDir).Msg("initializing wallet service")

	if err := os.MkdirAll(s.bitwindowDir, 0700); err != nil {
		return fmt.Errorf("create bitwindow dir: %w", err)
	}

	if err := s.openElectrumDB(); err != nil {
		return err
	}

	s.mu.Lock()
	err := s.loadWalletFile()
	s.mu.Unlock()
	if err != nil {
		s.log.Warn().Err(err).Msg("initial wallet load failed (may not exist yet)")
	} else {
		s.log.Info().
			Int("wallet_count", len(s.wallets)).
			Str("active_id", s.activeWalletID).
			Bool("encrypted", s.isEncrypted()).
			Msg("wallet service initialized")
	}

	s.startWatcher()
	return nil
}

// NetworkDir is where per-network wallet state lives. Seeds stay at the flat
// <bitwindowDir> root — they are network-agnostic.
func (s *Service) NetworkDir() string {
	s.dbMu.RLock()
	defer s.dbMu.RUnlock()
	return s.networkDirLocked()
}

func (s *Service) networkDirLocked() string {
	if s.network == "" {
		return s.bitwindowDir
	}
	return filepath.Join(s.bitwindowDir, s.network)
}

// SetNetwork records the boot network. Call before Init; afterwards use
// RebindNetwork, which also moves the open database.
func (s *Service) SetNetwork(network string) {
	s.dbMu.Lock()
	defer s.dbMu.Unlock()
	s.network = network
}

// db returns the electrum handle. A rebind swaps the pointer, so callers must
// read it through here rather than caching it.
func (s *Service) db() *sql.DB {
	s.dbMu.RLock()
	defer s.dbMu.RUnlock()
	return s.electrumDB
}

func (s *Service) openElectrumDB() error {
	if err := os.MkdirAll(s.bitwindowDir, 0700); err != nil {
		return fmt.Errorf("create bitwindow dir: %w", err)
	}
	// the BIP47 and BMM stores write JSON straight into this directory
	if err := os.MkdirAll(s.NetworkDir(), 0700); err != nil {
		return fmt.Errorf("create network dir: %w", err)
	}
	db, err := OpenElectrumDB(context.Background(), filepath.Join(s.bitwindowDir, "electrum.db"))
	if err != nil {
		return fmt.Errorf("open electrum db: %w", err)
	}

	s.dbMu.Lock()
	s.electrumDB = db
	s.dbMu.Unlock()
	return nil
}

// Network returns the network wallet chain state is scoped to right now.
func (s *Service) Network() string {
	s.dbMu.RLock()
	defer s.dbMu.RUnlock()
	return s.network
}

// RebindNetwork points wallet state at another network. Rows are keyed by
// network, so this is a field change rather than a database swap.
func (s *Service) RebindNetwork(network string) error {
	s.dbMu.Lock()
	unchanged := network == s.network
	s.network = network
	reopen := s.electrumDB == nil
	s.dbMu.Unlock()

	if reopen {
		if err := s.openElectrumDB(); err != nil {
			return err
		}
	}
	if unchanged {
		return nil
	}
	s.syncReporter.reset()
	s.log.Info().Str("network", network).Msg("wallet state rebound to network")
	return nil
}

// Close stops the file watcher and cleans up starter files.
func (s *Service) Close() {
	s.closeOnce.Do(func() {
		s.log.Info().Msg("closing wallet service")
		close(s.done)
		if s.watcher != nil {
			_ = s.watcher.Close()
		}
		if db := s.db(); db != nil {
			_ = db.Close()
		}
		s.CleanupStarterFiles()
	})
}

// --- Status ---

func (s *Service) HasWallet() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	has := len(s.wallets) > 0 || s.walletFileExists()
	s.log.Debug().Bool("has_wallet", has).Int("loaded_count", len(s.wallets)).Msg("HasWallet check")
	return has
}

func (s *Service) IsEncrypted() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	enc := s.isEncrypted()
	s.log.Debug().Bool("encrypted", enc).Msg("IsEncrypted check")
	return enc
}

func (s *Service) IsUnlocked() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	unlocked := len(s.wallets) > 0
	s.log.Debug().Bool("unlocked", unlocked).Int("loaded_count", len(s.wallets)).Msg("IsUnlocked check")
	return unlocked
}

func (s *Service) ActiveWalletID() string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	s.log.Debug().Str("active_id", s.activeWalletID).Msg("ActiveWalletID")
	return s.activeWalletID
}

func (s *Service) ActiveWalletName() string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, w := range s.wallets {
		if w.ID == s.activeWalletID {
			s.log.Debug().Str("active_name", w.Name).Msg("ActiveWalletName")
			return w.Name
		}
	}
	s.log.Debug().Msg("ActiveWalletName: no active wallet found")
	return ""
}

// ActiveWallet returns the currently active wallet, or nil.
// Dart: WalletReaderProvider.activeWallet (L27-29)
func (s *Service) ActiveWallet() *WalletData {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.activeWallet()
}

// PrimaryWallet returns the wallet that carries the starter material, or nil.
func (s *Service) PrimaryWallet() *WalletData {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.primaryWallet()
}

// Log returns a pointer to the service's logger so consumers in the api
// package can surface wallet-tied errors (e.g. BIP47 derivation failures)
// without allocating a separate logger or smuggling one through every
// handler. Pointer-returned because zerolog's level methods (Error/Warn/...)
// have pointer receivers and can't be called on a returned-by-value Logger.
func (s *Service) Log() *zerolog.Logger {
	return &s.log
}

// primaryWallet returns the wallet whose seed derives the L1 and sidechain
// starters. It holds the recorded id: each wallet carries its own seed, so
// promoting the next one would restart every sidechain against coins the user
// does not hold. Falls back to the first seeded wallet only before an id is
// recorded. Must be called with mu held.
func (s *Service) primaryWallet() *WalletData {
	if s.starterWalletID != "" {
		for i := range s.wallets {
			if s.wallets[i].ID == s.starterWalletID {
				return &s.wallets[i]
			}
		}
	}
	for i := range s.wallets {
		if s.wallets[i].Master.Mnemonic != "" {
			return &s.wallets[i]
		}
	}
	return nil
}

// adoptStarterWallet pins the starter wallet when none is recorded yet, so the
// first seeded wallet holds that role for the life of the install. Reports
// whether it changed anything. Must be called with mu held.
func (s *Service) adoptStarterWallet() bool {
	for i := range s.wallets {
		if s.wallets[i].ID == s.starterWalletID {
			return false
		}
	}
	for i := range s.wallets {
		if s.wallets[i].Master.Mnemonic == "" {
			continue
		}
		s.starterWalletID = s.wallets[i].ID
		s.log.Info().Str("id", s.starterWalletID).Msg("pinned the wallet that derives the starters")
		return true
	}
	return false
}

// ClearState clears all in-memory wallet state (used after reset/wipe).
// Dart: WalletReaderProvider.clearState (L69-76)
func (s *Service) ClearState() {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.log.Info().Msg("clearState: clearing all wallet state")
	s.wallets = nil
	s.encryptionKey = nil
	s.unlockedPass = ""
	s.activeWalletID = ""
}

// GetWalletByID returns a wallet by ID, or the active wallet if id is empty.
func (s *Service) GetWalletByID(id string) *WalletData {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if id == "" {
		return s.activeWallet()
	}
	for i := range s.wallets {
		if s.wallets[i].ID == id {
			return &s.wallets[i]
		}
	}
	return nil
}

// GetL1Mnemonic returns the L1 mnemonic from the starter wallet.
func (s *Service) GetL1Mnemonic() string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	w := s.primaryWallet()
	if w == nil {
		return ""
	}
	return w.L1.Mnemonic
}

// GetSidechainMnemonic returns the sidechain mnemonic from the starter wallet.
func (s *Service) GetSidechainMnemonic(slot int) string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	w := s.primaryWallet()
	if w == nil {
		return ""
	}
	for _, sc := range w.Sidechains {
		if sc.Slot == slot {
			return sc.Mnemonic
		}
	}
	return ""
}

// GetOrDeriveSidechainStarter returns a slot's sidechain mnemonic, deriving one
// only when the slot has none yet.
//
// A stored starter is authoritative. The migration rewrites a passphrase
// wallet's seed, so re-deriving would hand the sidechain a different seed and
// strand the user's L2 coins on keys nothing records.
func (s *Service) GetOrDeriveSidechainStarter(slot int, slotName string) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	w := s.primaryWallet()
	if w == nil {
		return "", fmt.Errorf("no wallet holds a seed to derive the sidechain starter from")
	}

	for _, sc := range w.Sidechains {
		if sc.Slot == slot && sc.Mnemonic != "" {
			return sc.Mnemonic, nil
		}
	}

	mnemonic, err := DeriveStarter(w.Master.SeedHex, fmt.Sprintf("m/44'/0'/%d'", slot))
	if err != nil {
		return "", fmt.Errorf("derive sidechain starter: %w", err)
	}

	for i := range w.Sidechains {
		if w.Sidechains[i].Slot == slot {
			w.Sidechains[i].Mnemonic = mnemonic
			if err := s.saveWalletFile(); err != nil {
				return "", fmt.Errorf("save wallet after sidechain derivation: %w", err)
			}
			return mnemonic, nil
		}
	}

	w.Sidechains = append(w.Sidechains, SidechainWallet{Slot: slot, Name: slotName, Mnemonic: mnemonic})
	if err := s.saveWalletFile(); err != nil {
		return "", fmt.Errorf("save wallet after sidechain derivation: %w", err)
	}
	s.log.Info().Int("slot", slot).Msg("derived a sidechain starter for a new slot")
	return mnemonic, nil
}

// GenerateWalletFromEntropy creates a wallet from specific entropy bytes.
// Dart: WalletWriterProvider.generateWalletFromEntropy (L241-280)
func (s *Service) GenerateWalletFromEntropy(entropy []byte, passphrase string, doNotSave bool, slots []SidechainSlot) (*WalletData, error) {
	// Create mnemonic from entropy
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		return nil, fmt.Errorf("create mnemonic from entropy: %w", err)
	}

	// Generate seed (bip39 library uses PBKDF2-HMAC-SHA512 internally)
	seed := bip39.NewSeed(mnemonic, passphrase)
	seedHex := hex.EncodeToString(seed)

	// Create master key
	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return nil, fmt.Errorf("create master key: %w", err)
	}

	bip39Binary := bytesToBinary(entropy)
	bip39Checksum := calculateChecksumBits(entropy)
	checksumByte := byte(0)
	for _, c := range bip39Checksum {
		checksumByte = checksumByte<<1 | byte(c-'0')
	}
	bip39ChecksumHex := hex.EncodeToString([]byte{checksumByte})

	wallet := &WalletData{
		Version: 1,
		Master: MasterWallet{
			Mnemonic:         mnemonic,
			SeedHex:          seedHex,
			MasterKey:        serializedPrivateKeyHex(masterKey.Key),
			ChainCode:        hex.EncodeToString(masterKey.ChainCode),
			BIP39Binary:      bip39Binary,
			BIP39Checksum:    bip39Checksum,
			BIP39ChecksumHex: bip39ChecksumHex,
			Name:             "Master",
		},
	}

	if !doNotSave {
		// Derive L1 + sidechains and save
		fullWallet, err := s.GenerateWallet("My Wallet", mnemonic, passphrase, slots)
		if err != nil {
			return nil, err
		}
		return fullWallet, nil
	}

	return wallet, nil
}

// LoadMasterStarter returns the active wallet's master data.
// Dart: WalletWriterProvider.loadMasterStarter (L454-469)
func (s *Service) LoadMasterStarter() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()
	w := s.activeWallet()
	if w == nil {
		return nil
	}
	return map[string]interface{}{
		"mnemonic":           w.Master.Mnemonic,
		"seed_hex":           w.Master.SeedHex,
		"master_key":         w.Master.MasterKey,
		"chain_code":         w.Master.ChainCode,
		"bip39_binary":       w.Master.BIP39Binary,
		"bip39_checksum":     w.Master.BIP39Checksum,
		"bip39_checksum_hex": w.Master.BIP39ChecksumHex,
		"name":               w.Master.Name,
	}
}

// DeleteCoreMultisigWallets deletes multisig_* directories from Bitcoin Core datadir.
// Dart: WalletWriterProvider._deleteCoreMultisigWallets (L533-552)
// DeleteCoreMultisigWallets is retained for backwards compatibility but is
// now a soft-delete: each `multisig_*` directory is moved to
// `<coreDataDir>/wallet_backups/<ts>/` rather than removed. Multisig keys
// are user-level secrets we can't reconstruct, so we never `os.RemoveAll`
// them.
func DeleteCoreMultisigWallets(coreDataDir string, log zerolog.Logger) {
	entries, err := os.ReadDir(coreDataDir)
	if err != nil {
		log.Error().Err(err).Msg("error reading core data dir for multisig cleanup")
		return
	}
	backupRoot := filepath.Join(coreDataDir, "wallet_backups", time.Now().UTC().Format("20060102-150405"))
	for _, entry := range entries {
		if !entry.IsDir() || !strings.HasPrefix(entry.Name(), "multisig_") {
			continue
		}
		if err := os.MkdirAll(backupRoot, 0o700); err != nil {
			log.Warn().Err(err).Str("backup", backupRoot).Msg("could not create multisig backup root")
			return
		}
		src := filepath.Join(coreDataDir, entry.Name())
		dst := filepath.Join(backupRoot, entry.Name())
		if err := os.Rename(src, dst); err != nil {
			log.Warn().Err(err).Str("path", src).Msg("could not back up multisig wallet")
		} else {
			log.Info().Str("from", src).Str("to", dst).Msg("multisig wallet moved to backup")
		}
	}
}

// softDeleteCoreMultisigWallets is the method form used by DeleteAllWallets
// so the same backup logic flows through Service's logger context.
func (s *Service) softDeleteCoreMultisigWallets() {
	DeleteCoreMultisigWallets(s.CoreDataDir, s.log)
}

// CreateBitcoinCoreWallet creates a new Bitcoin Core wallet.
// Dart: WalletWriterProvider.createBitcoinCoreWallet (L134-153)
func (s *Service) CreateBitcoinCoreWallet(name string, gradientJSON json.RawMessage, slots []SidechainSlot) error {
	wallet, err := s.GenerateWallet(name, "", "", slots)
	if err != nil {
		return err
	}
	// Update with user-selected gradient
	return s.UpdateWalletMetadata(wallet.ID, name, gradientJSON)
}

// CreateElectrumWallet creates an electrum wallet — chain data comes from a
// remote Esplora backend, but it runs neither Bitcoin Core nor the enforcer
// locally, so no local daemon callbacks fire. The new wallet becomes active.
//
// customMnemonic imports an existing seed (empty = generate a new one).
// xpubOrDescriptor instead creates a watch-only electrum wallet with no
// private keys; it is mutually exclusive with customMnemonic.
func (s *Service) CreateElectrumWallet(name string, gradient json.RawMessage, slots []uint32, customMnemonic, passphrase, xpubOrDescriptor, scriptType string, accountIndex uint32, derivationPath string) (*WalletData, error) {
	st, err := validateHotScriptType(scriptType)
	if err != nil {
		return nil, err
	}

	if xpubOrDescriptor != "" {
		return s.createElectrumWatchOnly(name, gradient, xpubOrDescriptor, HotScriptKind(st))
	}

	sidechainSlots := make([]SidechainSlot, len(slots))
	for i, slot := range slots {
		sidechainSlots[i] = SidechainSlot{Slot: int(slot)}
	}

	s.mu.Lock()
	if s.locked() {
		s.mu.Unlock()
		return nil, fmt.Errorf("wallet is locked, unlock before creating a wallet")
	}
	wallet, err := s.generateWalletOfType(name, customMnemonic, passphrase, accountIndex, derivationPath, st, sidechainSlots, WalletTypeElectrum)
	s.mu.Unlock()
	if err != nil {
		return nil, err
	}

	if len(gradient) > 0 {
		if err := s.UpdateWalletMetadata(wallet.ID, name, gradient); err != nil {
			return nil, err
		}
	}
	return wallet, nil
}

// validateHotScriptType normalizes a requested hot-wallet address type, mapping
// the default to "" (native segwit). Multisig is created through its own path.
func validateHotScriptType(s string) (string, error) {
	switch s {
	case "", "native-segwit":
		return "", nil
	case "legacy", "nested-segwit", "taproot":
		return s, nil
	default:
		return "", fmt.Errorf("unsupported script type %q", s)
	}
}

// createElectrumWatchOnly creates a watch-only electrum wallet from an xpub or
// descriptor. Addresses derive from the public key material; with no seed the
// ElectrumBackend can read balances/history but cannot sign or send. requested
// is the kind to record when the key states none of its own.
func (s *Service) createElectrumWatchOnly(name string, gradient json.RawMessage, xpubOrDescriptor string, requested ScriptKind) (*WalletData, error) {
	// Parse-validate the descriptor and record its script kind so derivation
	// scans the addresses the descriptor actually owns.
	desc, err := ParseDescriptorAs(xpubOrDescriptor, requested)
	if err != nil {
		return nil, fmt.Errorf("invalid watch-only descriptor: %w", err)
	}
	// Watch-only stays public-only; reject any private extended key so the
	// wallet can never store or sign with private material.
	for _, k := range desc.Keys {
		if k.Account.IsPrivate() {
			return nil, errors.New("watch-only import must not contain private keys")
		}
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if s.locked() {
		return nil, fmt.Errorf("wallet is locked, unlock before creating a wallet")
	}

	walletID := generateWalletID()
	watchOnly := map[string]string{}
	if strings.Contains(xpubOrDescriptor, "(") && strings.Contains(xpubOrDescriptor, ")") {
		watchOnly["descriptor"] = xpubOrDescriptor
	} else {
		watchOnly["xpub"] = xpubOrDescriptor
	}
	watchOnlyJSON, _ := json.Marshal(watchOnly)

	wallet := WalletData{
		Version:    1,
		Master:     MasterWallet{SeedHex: ""},
		L1:         L1Wallet{Mnemonic: ""},
		Sidechains: []SidechainWallet{},
		ID:         walletID,
		Name:       name,
		Gradient:   gradient,
		CreatedAt:  time.Now(),
		WalletType: WalletTypeElectrum,
		WatchOnly:  json.RawMessage(watchOnlyJSON),
		ScriptType: desc.Kind.String(),
	}

	s.wallets = append(s.wallets, wallet)
	s.activeWalletID = walletID
	s.adoptStarterWallet()
	if err := s.saveWalletFile(); err != nil {
		return nil, fmt.Errorf("save watch-only electrum wallet: %w", err)
	}
	s.log.Info().Str("id", walletID).Msg("watch-only electrum wallet created")
	return &wallet, nil
}

// CreateElectrumMultisig creates an m-of-n multisig electrum wallet. Cosigners
// carrying a mnemonic or xprv are held on disk and can sign; the rest are
// watch-only legs. scriptType is "wsh" (native P2WSH, default), "sh-wsh"
// (nested), or "sh" (legacy P2SH). The wallet monitors and signs through the
// same descriptor + PSBT path as any other electrum wallet.
func (s *Service) CreateElectrumMultisig(
	name string,
	gradient json.RawMessage,
	m, n int,
	scriptType string,
	cosigners []MultisigCosigner,
) (*WalletData, error) {
	if m < 1 || m > n {
		return nil, fmt.Errorf("invalid threshold %d-of-%d", m, n)
	}
	if len(cosigners) != n {
		return nil, fmt.Errorf("expected %d cosigners, got %d", n, len(cosigners))
	}
	for i, c := range cosigners {
		if c.Xpub == "" {
			return nil, fmt.Errorf("cosigner %d has no xpub", i)
		}
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if s.locked() {
		return nil, fmt.Errorf("wallet is locked, unlock before creating a wallet")
	}

	walletID := generateWalletID()
	wallet := WalletData{
		Version:    1,
		Master:     MasterWallet{SeedHex: ""},
		L1:         L1Wallet{Mnemonic: ""},
		Sidechains: []SidechainWallet{},
		ID:         walletID,
		Name:       name,
		Gradient:   gradient,
		CreatedAt:  time.Now(),
		WalletType: WalletTypeElectrum,
		ScriptType: multisigScriptKind(scriptType).String(),
		Multisig:   &MultisigWalletData{M: m, N: n, Cosigners: cosigners},
	}

	s.wallets = append(s.wallets, wallet)
	s.activeWalletID = walletID
	s.adoptStarterWallet()
	if err := s.saveWalletFile(); err != nil {
		return nil, fmt.Errorf("save multisig electrum wallet: %w", err)
	}
	s.log.Info().Str("id", walletID).Int("m", m).Int("n", n).Msg("multisig electrum wallet created")
	return &wallet, nil
}

// CreateWatchOnlyWallet creates a watch-only wallet from an xpub or descriptor.
// Dart: WalletWriterProvider.createWatchOnlyWallet (L156-214)
func (s *Service) CreateWatchOnlyWallet(name, xpubOrDescriptor, gradientJSON string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.locked() {
		return fmt.Errorf("wallet is locked, unlock before creating a wallet")
	}

	s.log.Info().Str("name", name).Msg("creating watch-only wallet")

	walletID := generateWalletID()

	// Detect if descriptor (contains '(' and ')')
	isDescriptor := strings.Contains(xpubOrDescriptor, "(") && strings.Contains(xpubOrDescriptor, ")")

	watchOnly := map[string]string{}
	if isDescriptor {
		watchOnly["descriptor"] = xpubOrDescriptor
	} else {
		watchOnly["xpub"] = xpubOrDescriptor
	}
	watchOnlyJSON, _ := json.Marshal(watchOnly)

	wallet := WalletData{
		Version:    1,
		Master:     MasterWallet{SeedHex: ""},
		L1:         L1Wallet{Mnemonic: ""},
		Sidechains: []SidechainWallet{},
		ID:         walletID,
		Name:       name,
		Gradient:   json.RawMessage(gradientJSON),
		CreatedAt:  time.Now(),
		WalletType: WalletTypeBitcoinCore,
		WatchOnly:  json.RawMessage(watchOnlyJSON),
	}

	s.wallets = append(s.wallets, wallet)
	s.activeWalletID = walletID
	s.adoptStarterWallet()

	if err := s.saveWalletFile(); err != nil {
		return fmt.Errorf("save watch-only wallet: %w", err)
	}

	s.log.Info().Str("id", walletID).Msg("watch-only wallet created")
	return nil
}

// SetWalletHardwareDevice tags a watch-only wallet to sign on a USB device.
func (s *Service) SetWalletHardwareDevice(walletID, deviceType, fingerprint string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.locked() {
		return fmt.Errorf("wallet is locked")
	}
	for i := range s.wallets {
		if s.wallets[i].ID != walletID {
			continue
		}
		m := map[string]string{}
		if len(s.wallets[i].WatchOnly) > 0 {
			_ = json.Unmarshal(s.wallets[i].WatchOnly, &m)
		}
		m["hardware_device_type"] = deviceType
		m["hardware_fingerprint"] = fingerprint
		blob, _ := json.Marshal(m)
		s.wallets[i].WatchOnly = json.RawMessage(blob)
		return s.saveWalletFile()
	}
	return fmt.Errorf("wallet %s not found", walletID)
}

// UpdateWallet updates or adds a wallet and saves to file.
// Dart: WalletReaderProvider.updateWallet (L570-591)
func (s *Service) UpdateWallet(wallet WalletData) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.locked() {
		return fmt.Errorf("wallet is locked, unlock before updating a wallet")
	}

	found := false
	for i, w := range s.wallets {
		if w.ID == wallet.ID {
			s.wallets[i] = wallet
			found = true
			s.log.Info().Str("id", wallet.ID).Str("name", wallet.Name).Msg("updated existing wallet")
			break
		}
	}
	if !found {
		s.wallets = append(s.wallets, wallet)
		s.adoptStarterWallet()
		s.log.Info().Str("id", wallet.ID).Str("name", wallet.Name).Msg("added new wallet")
	}

	return s.saveWalletFile()
}

// --- Generate ---

func (s *Service) GenerateWallet(name, customMnemonic, passphrase string, slots []SidechainSlot) (*WalletData, error) {
	return s.GenerateWalletWithPath(name, customMnemonic, passphrase, 0, "", "", slots)
}

// GenerateWalletWithPath is GenerateWallet with an optional account-index/
// derivation-path override stored on the wallet so descriptor derivation honors
// it. Both override args must be pre-validated (see ResolveCreateDerivationPath).
func (s *Service) GenerateWalletWithPath(name, customMnemonic, passphrase string, accountIndex uint32, derivationPath, scriptType string, slots []SidechainSlot) (*WalletData, error) {
	st, err := validateHotScriptType(scriptType)
	if err != nil {
		return nil, err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if s.locked() {
		return nil, fmt.Errorf("wallet is locked, unlock before generating a wallet")
	}

	return s.generateWalletOfType(name, customMnemonic, passphrase, accountIndex, derivationPath, st, slots, WalletTypeBitcoinCore)
}

// generateWalletOfType derives a full local wallet of the given type, appends
// it as the new active wallet, and persists. Keys are always generated locally;
// walletType only controls which daemon callbacks fire afterwards. Must be
// called with mu held.
func (s *Service) generateWalletOfType(name, customMnemonic, passphrase string, accountIndex uint32, derivationPath, scriptType string, slots []SidechainSlot, walletType WalletType) (*WalletData, error) {
	s.log.Info().
		Str("name", name).
		Str("wallet_type", string(walletType)).
		Bool("custom_mnemonic", customMnemonic != "").
		Bool("has_passphrase", passphrase != "").
		Int("slot_count", len(slots)).
		Int("existing_wallets", len(s.wallets)).
		Msg("generating wallet")

	wallet, err := GenerateFullWallet(name, customMnemonic, passphrase, slots, walletType)
	if err != nil {
		s.log.Error().Err(err).Msg("failed to generate wallet")
		return nil, fmt.Errorf("generate wallet: %w", err)
	}

	s.log.Debug().
		Str("l1_mnemonic_words", fmt.Sprintf("%d words", len(strings.Fields(wallet.L1.Mnemonic)))).
		Int("sidechain_count", len(wallet.Sidechains)).
		Msg("wallet keys derived")

	// Set ID and timestamp. Leave Gradient nil so the Dart side derives a
	// deterministic visual via WalletGradient.fromWalletId; storing a stub
	// like {"background_svg":""} would round-trip as an unrenderable avatar.
	wallet.ID = generateWalletID()
	wallet.CreatedAt = time.Now()
	wallet.Gradient = nil
	wallet.AccountIndex = accountIndex
	wallet.DerivationPath = derivationPath
	wallet.ScriptType = scriptType

	// Add to list and set as active
	s.wallets = append(s.wallets, *wallet)
	s.activeWalletID = wallet.ID
	s.adoptStarterWallet()

	if err := s.saveWalletFile(); err != nil {
		s.log.Error().Err(err).Msg("failed to save wallet file after generation")
		return nil, fmt.Errorf("save wallet: %w", err)
	}

	s.log.Info().
		Str("id", wallet.ID).
		Str("name", name).
		Str("type", string(walletType)).
		Str("file", s.walletFilePath()).
		Msg("wallet generated and saved successfully")

	// A new wallet starts no daemon. electrum wallets run nothing local, and
	// bitcoinCore wallets are created lazily by the backend on first access
	// (Backend.Ensure).

	return wallet, nil
}

// --- Unlock/Lock ---

func (s *Service) UnlockWallet(password string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Msg("attempting to unlock wallet")

	meta, err := s.loadMetadata()
	if err != nil || !meta.Encrypted {
		s.log.Warn().Err(err).Bool("encrypted", meta.Encrypted).Msg("unlock failed: wallet is not encrypted")
		return fmt.Errorf("wallet is not encrypted")
	}

	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	if err != nil {
		s.log.Error().Err(err).Msg("failed to decode salt from metadata")
		return fmt.Errorf("decode salt: %w", err)
	}

	s.log.Debug().Int("iterations", meta.Iterations).Int("salt_len", len(salt)).Msg("deriving key for unlock")
	key := DeriveKey(password, salt, meta.Iterations)

	// Test password by trying to decrypt
	data, err := os.ReadFile(s.walletFilePath())
	if err != nil {
		s.log.Error().Err(err).Str("path", s.walletFilePath()).Msg("failed to read wallet file for unlock")
		return fmt.Errorf("read wallet file: %w", err)
	}

	s.log.Debug().Int("encrypted_data_len", len(data)).Msg("attempting decryption")
	if _, decErr := Decrypt(string(data), key); decErr != nil {
		// The wallet may hold ciphertext from an interrupted ChangePassword,
		// described by the staged salt rather than by the live metadata.
		stagedKey, err := s.promoteStagedMetadataLocked(password, data)
		if err != nil {
			return err
		}
		if stagedKey == nil {
			s.log.Warn().Msg("unlock failed: incorrect password (decryption failed)")
			return fmt.Errorf("incorrect password")
		}
		key = stagedKey
	} else {
		// The live metadata opens the wallet, so any staged salt belongs to a
		// password change that never reached the wallet file.
		s.removeStagedMetadataLocked()
	}

	s.encryptionKey = key
	s.unlockedPass = password

	// Reload with decryption
	if err := s.loadWalletFile(); err != nil {
		s.log.Error().Err(err).Msg("failed to reload wallet after unlock")
		return fmt.Errorf("reload wallet: %w", err)
	}

	s.log.Info().Int("wallet_count", len(s.wallets)).Str("active_id", s.activeWalletID).Msg("wallet unlocked successfully")
	return nil
}

func (s *Service) LockWallet() {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Int("wallet_count", len(s.wallets)).Msg("locking wallet")
	s.wallets = nil
	s.encryptionKey = nil
	s.unlockedPass = ""
	s.CleanupStarterFiles()

	s.log.Info().Msg("wallet locked, starter files cleaned up")
}

// --- Encrypt/Decrypt ---

func (s *Service) EncryptWallet(password string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Msg("encrypting wallet")

	if s.isEncrypted() {
		s.log.Warn().Msg("encrypt failed: wallet is already encrypted")
		return fmt.Errorf("wallet is already encrypted")
	}

	if len(s.wallets) == 0 {
		s.log.Warn().Msg("encrypt failed: no wallet loaded")
		return fmt.Errorf("no wallet to encrypt")
	}

	salt, err := GenerateSalt()
	if err != nil {
		s.log.Error().Err(err).Msg("failed to generate salt")
		return fmt.Errorf("generate salt: %w", err)
	}

	s.log.Debug().Int("iterations", DefaultIterations).Msg("deriving encryption key")
	key := DeriveKey(password, salt, DefaultIterations)

	// Read current plaintext file for backup
	walletPath := s.walletFilePath()
	plaintext, err := os.ReadFile(walletPath)
	if err != nil {
		s.log.Error().Err(err).Str("path", walletPath).Msg("failed to read wallet file for encryption")
		return fmt.Errorf("read wallet file: %w", err)
	}

	// Backup
	backupPath := fmt.Sprintf("%s.backup_before_encryption_%d", walletPath, time.Now().UnixMilli())
	if err := os.WriteFile(backupPath, plaintext, 0600); err != nil {
		s.log.Error().Err(err).Str("backup_path", backupPath).Msg("failed to backup wallet")
		return fmt.Errorf("backup wallet: %w", err)
	}
	s.log.Debug().Str("backup_path", backupPath).Msg("wallet backed up before encryption")

	// Encrypt
	encrypted, err := Encrypt(string(plaintext), key)
	if err != nil {
		s.log.Error().Err(err).Msg("encryption failed")
		return fmt.Errorf("encrypt: %w", err)
	}

	s.setWalletDigestLocked(plaintext)
	if err := s.writeWalletFileLocked([]byte(encrypted)); err != nil {
		s.log.Error().Err(err).Msg("failed to write encrypted wallet")
		return fmt.Errorf("write encrypted wallet: %w", err)
	}

	// Save metadata
	meta := EncryptionMetadata{
		Salt:       base64.StdEncoding.EncodeToString(salt),
		Iterations: DefaultIterations,
		Encrypted:  true,
		Version:    "1.0",
	}
	metaBytes, _ := meta.Marshal()
	if err := os.WriteFile(s.metadataFilePath(), metaBytes, 0600); err != nil {
		s.log.Error().Err(err).Msg("failed to write encryption metadata")
		return fmt.Errorf("write metadata: %w", err)
	}

	// Encryption fully succeeded — remove the plaintext backup so the
	// unencrypted seed doesn't linger on disk after the user encrypted.
	if err := os.Remove(backupPath); err != nil {
		s.log.Warn().Err(err).Str("backup_path", backupPath).Msg("could not remove plaintext wallet backup; delete it manually")
	}

	s.encryptionKey = key
	s.unlockedPass = password

	s.log.Info().Str("metadata_path", s.metadataFilePath()).Msg("wallet encrypted successfully")
	return nil
}

func (s *Service) ChangePassword(oldPassword, newPassword string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Msg("changing wallet password")

	meta, err := s.loadMetadata()
	if err != nil || !meta.Encrypted {
		s.log.Warn().Err(err).Msg("change password failed: wallet is not encrypted")
		return fmt.Errorf("wallet is not encrypted")
	}

	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	if err != nil {
		return fmt.Errorf("decode salt: %w", err)
	}

	oldKey := DeriveKey(oldPassword, salt, meta.Iterations)
	data, err := os.ReadFile(s.walletFilePath())
	if err != nil {
		return fmt.Errorf("read wallet file: %w", err)
	}

	plaintext, err := Decrypt(string(data), oldKey)
	if err != nil {
		s.log.Warn().Msg("change password failed: incorrect old password")
		return fmt.Errorf("incorrect old password")
	}

	newSalt, err := GenerateSalt()
	if err != nil {
		return fmt.Errorf("generate salt: %w", err)
	}

	newKey := DeriveKey(newPassword, newSalt, DefaultIterations)
	encrypted, err := Encrypt(plaintext, newKey)
	if err != nil {
		return fmt.Errorf("encrypt: %w", err)
	}

	newMeta := EncryptionMetadata{
		Salt:       base64.StdEncoding.EncodeToString(newSalt),
		Iterations: DefaultIterations,
		Encrypted:  true,
		Version:    "1.0",
	}
	metaBytes, _ := newMeta.Marshal()

	// Stage the new salt before the wallet write. The wallet file and the
	// metadata cannot change in one step, and a crash in between would otherwise
	// leave new-key ciphertext described by the old salt, which no password
	// unlocks. UnlockWallet finishes the change from the staging file.
	if err := atomicWrite(s.stagedMetadataFilePath(), metaBytes); err != nil {
		return fmt.Errorf("stage metadata: %w", err)
	}

	// Backup
	walletPath := s.walletFilePath()
	backupPath := fmt.Sprintf("%s.backup_before_password_change_%d", walletPath, time.Now().UnixMilli())
	if err := os.WriteFile(backupPath, data, 0600); err != nil {
		return fmt.Errorf("backup wallet: %w", err)
	}
	s.log.Debug().Str("backup_path", backupPath).Msg("wallet backed up before password change")

	s.setWalletDigestLocked(data)
	if err := s.writeWalletFileLocked([]byte(encrypted)); err != nil {
		return fmt.Errorf("write wallet: %w", err)
	}

	if err := os.Rename(s.stagedMetadataFilePath(), s.metadataFilePath()); err != nil {
		return fmt.Errorf("write metadata: %w", err)
	}

	// The change committed, so the old ciphertext is one more copy of the seed
	// the old password opens.
	if err := os.Remove(backupPath); err != nil {
		s.log.Warn().Err(err).Str("backup_path", backupPath).Msg("could not remove the wallet backup taken before the password change; delete it manually")
	}

	// Adopt the new key only if we already held one. While locked there is no
	// key, and taking one would leave the service holding a key with no wallets.
	if s.encryptionKey != nil {
		s.encryptionKey = newKey
		s.unlockedPass = newPassword
	}

	s.log.Info().Msg("password changed successfully")
	return nil
}

func (s *Service) RemoveEncryption(password string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Msg("removing wallet encryption")

	if !s.isEncrypted() {
		s.log.Warn().Msg("remove encryption failed: wallet is not encrypted")
		return fmt.Errorf("wallet is not encrypted")
	}

	meta, err := s.loadMetadata()
	if err != nil {
		return fmt.Errorf("load metadata: %w", err)
	}

	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	if err != nil {
		return fmt.Errorf("decode salt: %w", err)
	}

	key := DeriveKey(password, salt, meta.Iterations)
	data, err := os.ReadFile(s.walletFilePath())
	if err != nil {
		return fmt.Errorf("read wallet file: %w", err)
	}

	plaintext, err := Decrypt(string(data), key)
	if err != nil {
		// An earlier attempt may have written the plaintext and then failed to
		// delete the metadata; finish that instead of blaming the password. A
		// removal error must surface: it is not a wrong password.
		stale, dropErr := s.dropStaleEncryptionMetadata(data)
		if dropErr != nil {
			return dropErr
		}
		if stale {
			if err := s.loadWalletFile(); err != nil {
				return err
			}
			// The watcher ignores metadata events, and it already consumed the
			// plaintext write, so subscribers stay on the locked state without
			// this.
			s.notifyChanged()
			return nil
		}
		s.log.Warn().Msg("remove encryption failed: incorrect password")
		return fmt.Errorf("incorrect password")
	}

	// Backup
	walletPath := s.walletFilePath()
	backupPath := fmt.Sprintf("%s.backup_before_decryption_%d", walletPath, time.Now().UnixMilli())
	if err := os.WriteFile(backupPath, data, 0600); err != nil {
		return fmt.Errorf("backup wallet: %w", err)
	}
	s.log.Debug().Str("backup_path", backupPath).Msg("wallet backed up before decryption")

	// Write plaintext
	s.setWalletDigestLocked(data)
	if err := s.writeWalletFileLocked([]byte(plaintext)); err != nil {
		return fmt.Errorf("write wallet: %w", err)
	}

	// Remove metadata file. Until it is gone the wallet is plaintext on disk while
	// the metadata still claims encryption, so a failure here must not report success.
	if err := os.Remove(s.metadataFilePath()); err != nil && !os.IsNotExist(err) {
		s.log.Error().Err(err).Str("path", s.metadataFilePath()).Msg("failed to remove encryption metadata")
		return fmt.Errorf("remove encryption metadata: %w", err)
	}

	s.encryptionKey = nil
	s.unlockedPass = ""

	// Reload
	if err := s.loadWalletFile(); err != nil {
		return fmt.Errorf("reload wallet: %w", err)
	}

	s.log.Info().Int("wallet_count", len(s.wallets)).Msg("encryption removed successfully")
	return nil
}

// --- List/Switch/Update/Delete ---

// GetAllWallets returns a copy of all loaded wallet data.
func (s *Service) GetAllWallets() []WalletData {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]WalletData, len(s.wallets))
	copy(out, s.wallets)
	return out
}

func (s *Service) ListWallets() []WalletMetadata {
	s.mu.RLock()
	defer s.mu.RUnlock()

	out := lo.Map(s.wallets, func(w WalletData, _ int) WalletMetadata {
		return WalletMetadata{
			ID:         w.ID,
			Name:       w.Name,
			WalletType: w.WalletType,
			Gradient:   w.Gradient,
			CreatedAt:  w.CreatedAt,
		}
	})
	s.log.Debug().Int("count", len(out)).Msg("listed wallets")
	return out
}

func (s *Service) SwitchWallet(walletID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Str("wallet_id", walletID).Msg("switching wallet")

	if !lo.ContainsBy(s.wallets, func(w WalletData) bool { return w.ID == walletID }) {
		s.log.Warn().Str("wallet_id", walletID).Msg("switch failed: wallet not found")
		return fmt.Errorf("wallet %s not found", walletID)
	}

	s.activeWalletID = walletID
	s.log.Info().Str("wallet_id", walletID).Msg("switched active wallet")
	return s.saveWalletFile()
}

func (s *Service) UpdateWalletMetadata(walletID, name string, gradientJSON json.RawMessage) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	for i, w := range s.wallets {
		if w.ID == walletID {
			s.wallets[i].Name = name
			if len(gradientJSON) > 0 {
				s.wallets[i].Gradient = gradientJSON
			}
			return s.saveWalletFile()
		}
	}
	return fmt.Errorf("wallet %s not found", walletID)
}

func (s *Service) DeleteWallet(walletID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Str("wallet_id", walletID).Msg("deleting wallet")

	// The starter wallet's seed derives every sidechain's starter. Delete it
	// while another wallet remains and the pin moves to a different seed, so
	// every sidechain restarts against coins the user does not hold. Deleting
	// the last wallet is fine: nothing is left to derive from either way.
	if s.starterWalletID == walletID && len(s.wallets) > 1 {
		return fmt.Errorf("wallet %s derives the sidechain starters and cannot be deleted", walletID)
	}

	newWallets := make([]WalletData, 0, len(s.wallets))
	for _, w := range s.wallets {
		if w.ID != walletID {
			newWallets = append(newWallets, w)
		}
	}
	if len(newWallets) == len(s.wallets) {
		s.log.Warn().Str("wallet_id", walletID).Msg("delete failed: wallet not found")
		return fmt.Errorf("wallet %s not found", walletID)
	}

	s.wallets = newWallets
	if s.starterWalletID == walletID {
		s.starterWalletID = ""
	}
	if s.activeWalletID == walletID {
		if len(s.wallets) > 0 {
			s.activeWalletID = s.wallets[0].ID
		} else {
			s.activeWalletID = ""
		}
	}

	s.deleteElectrumScan(walletID)
	s.log.Info().Str("wallet_id", walletID).Int("remaining", len(s.wallets)).Msg("wallet deleted")
	return s.saveWalletFileAllowingDrop()
}

// DeleteAllWallets performs a full wallet wipe matching Dart's deleteAllWallets (L554-653).
// Stops binaries, deletes all wallet files, clears multisig wallets, clears state.
func (s *Service) DeleteAllWallets(onStatusUpdate func(string), beforeBoot func() error) error {
	// Dart L560: onStatusUpdate?.call('Stopping binaries')
	if onStatusUpdate != nil {
		onStatusUpdate("Stopping binaries")
	}

	// Dart L562-575: stop all binaries
	if s.OnStopAllBinaries != nil {
		if err := s.OnStopAllBinaries(); err != nil {
			s.log.Error().Err(err).Msg("could not stop binaries")
		}
	}

	// Dart L577-578: wait for processes to stop
	if onStatusUpdate != nil {
		onStatusUpdate("Waiting for processes to stop")
	}
	time.Sleep(5 * time.Second)

	// Dart L580: onStatusUpdate?.call('Backing up wallet files')
	if onStatusUpdate != nil {
		onStatusUpdate("Backing up wallet files")
	}

	// Soft-delete wallet.json + wallet_encryption.json + metadata.json under
	// one <bitwindowDir>/wallet_backups/<ts>/ directory. Keeping the three
	// master wallet files together is what makes the restore listing reliable.
	if err := s.moveMasterWalletFilesToBackup(); err != nil {
		s.log.Error().Err(err).Msg("could not back up master wallet files")
	}

	// Soft-delete per-binary wallet paths the same way: each lands under
	// its own parent's wallet_backups/<ts>/, keeping bitcoind's wallets
	// in the bitcoind datadir, the enforcer's under bip300301_enforcer,
	// etc., and never touching the user's keys destructively.
	if s.GetBinaryWalletPaths != nil {
		paths := s.GetBinaryWalletPaths()
		for _, p := range paths {
			if _, err := s.moveToBackup(p); err != nil {
				s.log.Warn().Err(err).Str("path", p).Msg("could not back up binary wallet path")
			}
		}
	}

	// Dart L610: onStatusUpdate?.call('Backing up multisig wallets')
	if onStatusUpdate != nil {
		onStatusUpdate("Backing up multisig wallets")
	}

	// Dart L618: soft-delete the per-network multisig dirs under Bitcoin
	// Core's datadir. Same backup-not-delete rule: a multisig wallet may
	// be mid-coordination and we can't recover keys we shred.
	if s.CoreDataDir != "" {
		s.softDeleteCoreMultisigWallets()
	}

	// Dart L623: onStatusUpdate?.call('Clearing wallet state')
	if onStatusUpdate != nil {
		onStatusUpdate("Clearing wallet state")
	}

	// Dart L626: _walletReader.clearState()
	s.mu.Lock()
	s.wallets = nil
	s.activeWalletID = ""
	s.encryptionKey = nil
	s.unlockedPass = ""
	s.setWalletDigestLocked(nil)
	s.mu.Unlock()
	s.wipeElectrumScans()

	// Dart L642-648: beforeBoot callback
	if beforeBoot != nil {
		if err := beforeBoot(); err != nil {
			s.log.Error().Err(err).Msg("could not run beforeBoot")
		}
	}

	// Dart L650
	if onStatusUpdate != nil {
		onStatusUpdate("Reset complete")
	}

	s.log.Info().Msg("all wallets deleted")
	return nil
}

// --- Starter Files ---

// WriteL1Starter writes the starter wallet's L1 mnemonic to a temp file.
func (s *Service) WriteL1Starter() (string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	s.log.Info().Msg("writing L1 starter file")

	var mnemonic string
	if w := s.primaryWallet(); w != nil {
		mnemonic = w.L1.Mnemonic
		s.log.Debug().Str("wallet_id", w.ID).Msg("found the primary wallet for the L1 starter")
	}
	if mnemonic == "" {
		s.log.Warn().Int("wallet_count", len(s.wallets)).Msg("L1 starter: no wallet holds an L1 mnemonic")
		return "", fmt.Errorf("no wallet holds an L1 mnemonic")
	}

	dir := s.starterDir()
	if err := os.MkdirAll(dir, 0700); err != nil {
		return "", fmt.Errorf("create starter dir: %w", err)
	}

	path := filepath.Join(dir, "l1_starter.txt")
	if err := os.WriteFile(path, []byte(mnemonic), 0600); err != nil {
		return "", fmt.Errorf("write L1 starter: %w", err)
	}

	s.log.Info().Str("path", path).Msg("L1 starter file written")
	return path, nil
}

// WriteSidechainStarter writes a sidechain mnemonic to a temp file.
func (s *Service) WriteSidechainStarter(slot int) (string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	s.log.Info().Int("slot", slot).Msg("writing sidechain starter file")

	starter := s.primaryWallet()
	if starter == nil {
		s.log.Warn().Int("wallet_count", len(s.wallets)).Msg("sidechain starter: no starter wallet")
		return "", fmt.Errorf("no starter wallet")
	}

	var mnemonic string
	for _, sc := range starter.Sidechains {
		if sc.Slot == slot {
			mnemonic = sc.Mnemonic
			break
		}
	}
	if mnemonic == "" {
		s.log.Warn().Int("slot", slot).Int("sidechain_count", len(starter.Sidechains)).Msg("sidechain starter: slot not found in starter wallet")
		return "", fmt.Errorf("sidechain slot %d not found in starter wallet", slot)
	}

	dir := s.starterDir()
	if err := os.MkdirAll(dir, 0700); err != nil {
		return "", fmt.Errorf("create starter dir: %w", err)
	}

	path := filepath.Join(dir, fmt.Sprintf("sidechain_%d_starter.txt", slot))
	if err := os.WriteFile(path, []byte(mnemonic), 0600); err != nil {
		return "", fmt.Errorf("write sidechain starter: %w", err)
	}

	s.log.Info().Str("path", path).Int("slot", slot).Msg("sidechain starter file written")
	return path, nil
}

// CleanupStarterFiles removes all temporary starter files.
func (s *Service) CleanupStarterFiles() {
	dir := s.starterDir()
	_ = os.RemoveAll(dir)
}

// --- Internal helpers ---

func (s *Service) walletFilePath() string {
	return filepath.Join(s.bitwindowDir, "wallet.json")
}

func (s *Service) metadataFilePath() string {
	return filepath.Join(s.bitwindowDir, "wallet_encryption.json")
}

// stagedMetadataFilePath holds the new salt ChangePassword writes before it
// rewrites the wallet, until the rename that commits it.
func (s *Service) stagedMetadataFilePath() string {
	return s.metadataFilePath() + ".new"
}

func (s *Service) starterDir() string {
	return filepath.Join(os.TempDir(), fmt.Sprintf("bitwindow_starters_%d", os.Getpid()))
}

func (s *Service) walletFileExists() bool {
	_, err := os.Stat(s.walletFilePath())
	return err == nil
}

func (s *Service) isEncrypted() bool {
	data, err := os.ReadFile(s.metadataFilePath())
	if err != nil {
		return false
	}
	meta, err := UnmarshalEncryptionMetadata(data)
	if err != nil {
		return false
	}
	return meta.Encrypted
}

// dropStaleEncryptionMetadata removes wallet_encryption.json when it claims the
// wallet is encrypted while wallet.json holds readable plaintext. RemoveEncryption
// writes the plaintext before deleting the metadata, so an interrupted run leaves
// exactly that state, and the correct password then fails forever. Reports whether
// the stale metadata was dropped. Must be called with mu held.
func (s *Service) dropStaleEncryptionMetadata(walletData []byte) (bool, error) {
	if !s.isEncrypted() || !isPlaintextWalletFile(walletData) {
		return false, nil
	}
	if err := os.Remove(s.metadataFilePath()); err != nil && !os.IsNotExist(err) {
		s.log.Error().Err(err).Str("path", s.metadataFilePath()).Msg("could not remove stale encryption metadata")
		return true, fmt.Errorf("remove stale encryption metadata: %w", err)
	}
	s.encryptionKey = nil
	s.unlockedPass = ""
	s.log.Warn().Msg("wallet file is plaintext but metadata claimed encrypted; dropped stale encryption metadata")
	return true, nil
}

// promoteStagedMetadataLocked finishes a ChangePassword that died between the
// wallet write and the rename that commits the new salt, leaving a wallet only
// the staged salt opens. Returns the key that salt derives from password, or nil
// when there is no staging file or it does not decrypt walletData — a stale
// staging file from a change that never reached the wallet write. Must be called
// with mu held.
func (s *Service) promoteStagedMetadataLocked(password string, walletData []byte) ([]byte, error) {
	staged, err := os.ReadFile(s.stagedMetadataFilePath())
	if err != nil {
		return nil, nil
	}
	meta, err := UnmarshalEncryptionMetadata(staged)
	if err != nil || !meta.Encrypted {
		return nil, nil
	}
	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	if err != nil {
		return nil, nil
	}
	key := DeriveKey(password, salt, meta.Iterations)
	if _, err := Decrypt(string(walletData), key); err != nil {
		return nil, nil
	}
	if err := os.Rename(s.stagedMetadataFilePath(), s.metadataFilePath()); err != nil {
		s.log.Error().Err(err).Str("path", s.stagedMetadataFilePath()).Msg("could not promote the staged encryption metadata")
		return nil, fmt.Errorf("promote staged encryption metadata: %w", err)
	}
	s.log.Warn().Msg("wallet held ciphertext from an interrupted password change; finished it from the staged metadata")
	return key, nil
}

// removeStagedMetadataLocked drops a staging file left by a password change that
// never reached the wallet write. Must be called with mu held.
func (s *Service) removeStagedMetadataLocked() {
	if err := os.Remove(s.stagedMetadataFilePath()); err != nil && !os.IsNotExist(err) {
		s.log.Warn().Err(err).Str("path", s.stagedMetadataFilePath()).Msg("could not remove stale staged encryption metadata")
	}
}

// isPlaintextWalletFile reports whether data is an unencrypted wallet file.
// Ciphertext is base64(iv):base64(ct), so it never parses as wallet JSON.
func isPlaintextWalletFile(data []byte) bool {
	var wf WalletFile
	if err := json.Unmarshal(data, &wf); err != nil {
		return false
	}
	return wf.Version > 0 || len(wf.Wallets) > 0
}

// locked reports whether the wallet file is encrypted but no key is held, so
// the stored wallets are neither loaded nor writable. Must be called with mu held.
func (s *Service) locked() bool {
	return s.isEncrypted() && s.encryptionKey == nil
}

func (s *Service) loadMetadata() (EncryptionMetadata, error) {
	data, err := os.ReadFile(s.metadataFilePath())
	if err != nil {
		return EncryptionMetadata{}, err
	}
	return UnmarshalEncryptionMetadata(data)
}

func (s *Service) activeWallet() *WalletData {
	for i := range s.wallets {
		if s.wallets[i].ID == s.activeWalletID {
			return &s.wallets[i]
		}
	}
	return nil
}

// loadWalletFile loads wallet.json into memory. Must be called with mu held.
func (s *Service) loadWalletFile() error {
	path := s.walletFilePath()
	s.log.Debug().Str("path", path).Msg("loading wallet file")

	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			s.log.Debug().Msg("wallet file does not exist yet")
			s.wallets = nil
			s.activeWalletID = ""
			s.setWalletDigestLocked(nil)
			return nil
		}
		return fmt.Errorf("read wallet file: %w", err)
	}

	s.log.Debug().Int("file_size", len(data)).Bool("encrypted", s.isEncrypted()).Msg("wallet file read")

	jsonStr := string(data)

	// Recover from an interrupted RemoveEncryption before trusting the metadata.
	if _, err := s.dropStaleEncryptionMetadata(data); err != nil {
		return err
	}

	// If encrypted, try to decrypt
	if s.isEncrypted() {
		if s.encryptionKey == nil {
			s.log.Debug().Msg("wallet is encrypted but no key available, keeping existing state")
			return nil
		}
		decrypted, err := Decrypt(jsonStr, s.encryptionKey)
		if err != nil {
			return fmt.Errorf("decrypt wallet: %w", err)
		}
		jsonStr = decrypted
		s.log.Debug().Msg("wallet file decrypted")
	}

	var wf WalletFile
	if err := json.Unmarshal([]byte(jsonStr), &wf); err != nil {
		s.log.Error().Err(err).Msg("failed to parse wallet JSON")
		return fmt.Errorf("parse wallet file: %w", err)
	}

	s.wallets = wf.Wallets
	s.activeWalletID = wf.ActiveWalletID
	s.starterWalletID = wf.StarterWalletID
	// Only a file this process read, decrypted, and parsed stands as the state
	// a later write compares against.
	s.setWalletDigestLocked(data)

	// Backfill missing wallet_type for wallets created before the field was
	// introduced. Anything with a Master.Mnemonic but no type is the original
	// single-wallet enforcer install; anything without a mnemonic is a
	// watch-only entry. Saves the file again only when something changed so
	// we don't churn the disk on every load.
	migrated := false
	for i := range s.wallets {
		if s.wallets[i].WalletType != "" {
			continue
		}
		if s.wallets[i].Master.Mnemonic != "" {
			s.wallets[i].WalletType = WalletTypeEnforcer
		} else {
			s.wallets[i].WalletType = WalletTypeBitcoinCore
		}
		migrated = true
	}
	enforcerMigrated, err := s.migrateEnforcerWallets()
	if err != nil {
		return err
	}
	if enforcerMigrated {
		migrated = true
	}
	if s.adoptStarterWallet() {
		migrated = true
	}
	if migrated {
		s.log.Info().Msg("backfilled missing wallet_type on legacy wallets")
		if err := s.saveWalletFile(); err != nil {
			s.log.Warn().Err(err).Msg("save after wallet_type backfill failed")
		}
	}
	s.log.Debug().Int("wallet_count", len(s.wallets)).Str("active_id", s.activeWalletID).Msg("wallet file loaded")
	return nil
}

// EnforcerAccountPath is the account the enforcer daemon's BDK wallet derived,
// on every network. It hardcoded the testnet coin type even on mainnet, so a
// mainnet wallet the enforcer served holds its coins here and not under
// m/84'/0'/0'. See bip300301_enforcer lib/wallet/mod.rs.
const EnforcerAccountPath = "m/84'/1'/0'"

// migrateEnforcerWallets moves a wallet the enforcer daemon served onto a
// backend this build still has, and rescues the coins the enforcer left behind.
//
// The enforcer derived somewhere BitWindow never would:
//
//   - The account. It hardcoded m/84'/1'/0' on every network, mainnet
//     included, so the testnet coin type holds mainnet coins.
//   - The seed. BitWindow stores seed(mnemonic, passphrase), but it handed the
//     enforcer the bare mnemonic, and the enforcer uses no BIP39 passphrase.
//
// Rather than pin the wallet to that tree — which would carry the enforcer's
// coin-type bug into BitWindow for every address it ever derives — the wallet
// keeps its own seed and its own per-network path, and a second wallet appears
// beside it holding exactly what the enforcer held. The user sees those coins,
// can spend them, and can move them whenever they like.
func (s *Service) migrateEnforcerWallets() (bool, error) {
	target := WalletTypeElectrum
	if !config.SupportsLightMode(config.Network(s.network)) {
		target = WalletTypeBitcoinCore
	}

	changed := false
	for i := range s.wallets {
		if s.wallets[i].WalletType != WalletTypeEnforcer {
			continue
		}
		s.wallets[i].WalletType = target
		// The enforcer held coins here before BitWindow ever imported it into
		// Core, so Core must rescan rather than start at the tip.
		s.wallets[i].Imported = true
		changed = true

		legacy, err := s.enforcerLegacyWallet(&s.wallets[i], target)
		switch {
		case err != nil:
			return false, fmt.Errorf("rebuild the enforcer wallet %s: %w", s.wallets[i].ID, err)
		case legacy != nil:
			s.wallets = append(s.wallets, *legacy)
			s.log.Info().Str("id", legacy.ID).Str("derivation_path", legacy.DerivationPath).
				Msg("added a wallet holding what the enforcer held")
		}

		s.log.Info().
			Str("id", s.wallets[i].ID).
			Str("wallet_type", string(target)).
			Msg("moved an enforcer wallet onto a supported backend")
	}
	return changed, nil
}

// enforcerLegacyWallet builds the wallet the enforcer daemon actually ran: the
// bare mnemonic with no BIP39 passphrase, on the account it hardcoded.
//
// The seed is what makes a wallet, and the path only says where to look first.
// So this returns nil when both already match what the wallet derives — on a
// network whose coin type is 1, the enforcer's account is the standard one, and
// a companion would be an exact duplicate.
func (s *Service) enforcerLegacyWallet(w *WalletData, target WalletType) (*WalletData, error) {
	if w.Master.Mnemonic == "" {
		return nil, nil
	}
	for i := range s.wallets {
		if s.wallets[i].ImportedFromEnforcer {
			return nil, nil
		}
	}

	seed := MnemonicToSeed(w.Master.Mnemonic, "")
	if hex.EncodeToString(seed) == w.Master.SeedHex && s.derivesEnforcerAccount(w) {
		return nil, nil
	}
	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return nil, fmt.Errorf("rebuild the enforcer master key: %w", err)
	}

	legacy := *w
	legacy.ID = generateWalletID()
	legacy.Name = w.Name + " (enforcer)"
	legacy.WalletType = target
	legacy.DerivationPath = EnforcerAccountPath
	legacy.ImportedFromEnforcer = true
	legacy.Imported = true
	legacy.Gradient = nil
	legacy.CreatedAt = time.Now()
	legacy.Sidechains = nil
	legacy.Master.SeedHex = hex.EncodeToString(seed)
	legacy.Master.MasterKey = masterKey.B58Serialize()
	legacy.Master.ChainCode = hex.EncodeToString(masterKey.ChainCode)
	return &legacy, nil
}

// saveWalletFile writes wallet.json atomically, keeping every wallet the file
// on disk holds. Must be called with mu held.
func (s *Service) saveWalletFile() error { return s.saveWalletFileWithOptions(false) }

// saveWalletFileAllowingDrop writes wallet.json for a caller that takes a
// wallet away on purpose. Must be called with mu held.
func (s *Service) saveWalletFileAllowingDrop() error { return s.saveWalletFileWithOptions(true) }

func (s *Service) saveWalletFileWithOptions(allowDrop bool) error {
	// Locking clears s.wallets and the key, so saving now would write a wallet
	// file missing every locked wallet, in plaintext over the encrypted one.
	if s.locked() {
		return fmt.Errorf("wallet is locked, unlock before saving")
	}

	wf := WalletFile{
		Version:         1,
		ActiveWalletID:  s.activeWalletID,
		StarterWalletID: s.starterWalletID,
		Wallets:         s.wallets,
	}

	jsonBytes, err := json.Marshal(wf)
	if err != nil {
		return fmt.Errorf("marshal wallet file: %w", err)
	}

	data := string(jsonBytes)

	if s.isEncrypted() {
		encrypted, err := Encrypt(data, s.encryptionKey)
		if err != nil {
			return fmt.Errorf("encrypt wallet: %w", err)
		}
		data = encrypted
		s.log.Debug().Msg("wallet file encrypted before save")
	}

	s.log.Debug().Str("path", s.walletFilePath()).Int("data_len", len(data)).Msg("saving wallet file")
	if err := s.writeWalletFileWithOptionsLocked([]byte(data), allowDrop); err != nil {
		return err
	}
	s.notifyChanged()
	return nil
}

// notifyChanged fans out a state-change notification to every Subscribe()
// channel. Each subscriber gets a non-blocking send into its own buffered
// channel; a slow consumer drops intermediate updates rather than blocking
// the producer.
func (s *Service) notifyChanged() {
	s.subsMu.Lock()
	for ch := range s.subs {
		select {
		case ch <- struct{}{}:
		default:
		}
	}
	s.subsMu.Unlock()
}

func (s *Service) startWatcher() {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		s.log.Warn().Err(err).Msg("failed to create file watcher")
		return
	}
	s.watcher = w

	// Watch the bitwindow directory for wallet.json changes
	if err := w.Add(s.bitwindowDir); err != nil {
		s.log.Warn().Err(err).Msg("failed to watch bitwindow dir")
		return
	}

	go func() {
		debounce := time.NewTimer(0)
		if !debounce.Stop() {
			<-debounce.C
		}

		for {
			select {
			case <-s.done:
				debounce.Stop()
				return
			case event, ok := <-w.Events:
				if !ok {
					return
				}
				// Also react to Remove/Rename so a user manually deleting
				// wallet.json clears in-memory state and pushes the no-wallet
				// signal to the frontend WalletGuard.
				if strings.HasSuffix(event.Name, "wallet.json") &&
					(event.Has(fsnotify.Write) || event.Has(fsnotify.Create) ||
						event.Has(fsnotify.Remove) || event.Has(fsnotify.Rename)) {
					debounce.Reset(100 * time.Millisecond)
				}
			case <-debounce.C:
				s.mu.Lock()
				if err := s.loadWalletFile(); err != nil {
					s.log.Warn().Err(err).Msg("watcher: reload wallet failed")
				} else {
					s.log.Debug().Msg("watcher: wallet reloaded")
					s.notifyChanged()
				}
				s.mu.Unlock()
			case err, ok := <-w.Errors:
				if !ok {
					return
				}
				s.log.Warn().Err(err).Msg("watcher error")
			}
		}
	}()
}

// atomicWrite writes data to a temp file then renames it over target.
func atomicWrite(path string, data []byte) error {
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0600); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

// generateWalletID creates a new wallet ID matching Dart's UUID format.
func generateWalletID() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return strings.ToUpper(hex.EncodeToString(b))
}

// StarterWalletID names the wallet whose seed derives the L1 and sidechain
// starters. Empty before any seeded wallet exists.
func (s *Service) StarterWalletID() string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if w := s.primaryWallet(); w != nil {
		return w.ID
	}
	return ""
}

// derivesEnforcerAccount reports whether the wallet already looks at the
// account the enforcer hardcoded. True on a network whose coin type is 1.
func (s *Service) derivesEnforcerAccount(w *WalletData) bool {
	// Forknet and ecash run on mainnet params, so a string compare against
	// mainnet reads their coin type as 1 and skips the companion they need.
	net, err := bip47send.NetworkParams(s.network)
	if err != nil {
		// Testnet params here read the coin type as 1, which is the answer this
		// function exists to avoid. The daemon refuses an unknown network at
		// startup, so this cannot happen.
		panic(fmt.Sprintf("unknown network %q: %v", s.network, err))
	}
	ap, err := accountPathFor(w, walletReceiveKind(w), net)
	if err != nil {
		return false
	}
	return ap.String() == EnforcerAccountPath
}

// CoinbaseRecipient is an address the block reward can pay to, derived from the
// starter wallet. The enforcer runs no wallet, so it cannot make one itself and
// refuses to serve block templates without this.
func (s *Service) CoinbaseRecipient(net *chaincfg.Params) (string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	w := s.primaryWallet()
	if w == nil {
		return "", fmt.Errorf("no wallet to derive a coinbase recipient from")
	}
	addresses, err := DeriveWalletReceiveAddresses(w, net, 0, 1)
	if err != nil {
		return "", fmt.Errorf("derive coinbase recipient: %w", err)
	}
	if len(addresses) == 0 {
		return "", fmt.Errorf("derive coinbase recipient: none derived")
	}
	return addresses[0], nil
}
