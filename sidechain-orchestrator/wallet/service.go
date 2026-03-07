package wallet

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/rs/zerolog"
)

// Service manages wallet lifecycle: load, save, encrypt, decrypt, generate, starters.
type Service struct {
	mu sync.RWMutex

	bitwindowDir string
	log          zerolog.Logger

	// In-memory state
	wallets        []WalletData
	activeWalletID string
	encryptionKey  []byte
	unlockedPass   string

	// File watcher
	watcher   *fsnotify.Watcher
	done      chan struct{}
	closeOnce sync.Once
}

// NewService creates a new wallet service.
func NewService(bitwindowDir string, log zerolog.Logger) *Service {
	return &Service{
		bitwindowDir: bitwindowDir,
		log:          log.With().Str("component", "wallet").Logger(),
		done:         make(chan struct{}),
	}
}

// Init loads the wallet file and starts the file watcher.
func (s *Service) Init() error {
	s.log.Info().Str("dir", s.bitwindowDir).Msg("initializing wallet service")

	if err := os.MkdirAll(s.bitwindowDir, 0700); err != nil {
		return fmt.Errorf("create bitwindow dir: %w", err)
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

// Close stops the file watcher and cleans up starter files.
func (s *Service) Close() {
	s.closeOnce.Do(func() {
		s.log.Info().Msg("closing wallet service")
		close(s.done)
		if s.watcher != nil {
			s.watcher.Close()
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

// --- Generate ---

func (s *Service) GenerateWallet(name, customMnemonic, passphrase string, slots []SidechainSlot) (*WalletData, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().
		Str("name", name).
		Bool("custom_mnemonic", customMnemonic != "").
		Bool("has_passphrase", passphrase != "").
		Int("slot_count", len(slots)).
		Msg("generating wallet")

	// Determine wallet type: first wallet is enforcer, subsequent are bitcoinCore
	walletType := "bitcoinCore"
	if len(s.wallets) == 0 {
		walletType = "enforcer"
	}
	s.log.Debug().Str("wallet_type", walletType).Int("existing_wallets", len(s.wallets)).Msg("determined wallet type")

	wallet, err := GenerateFullWallet(name, customMnemonic, passphrase, slots, walletType)
	if err != nil {
		s.log.Error().Err(err).Msg("failed to generate wallet")
		return nil, fmt.Errorf("generate wallet: %w", err)
	}

	s.log.Debug().
		Str("l1_mnemonic_words", fmt.Sprintf("%d words", len(strings.Fields(wallet.L1.Mnemonic)))).
		Int("sidechain_count", len(wallet.Sidechains)).
		Msg("wallet keys derived")

	// Set ID, gradient, timestamp
	wallet.ID = generateWalletID()
	wallet.CreatedAt = time.Now()
	wallet.Gradient = defaultGradient(wallet.ID)

	// Add to list and set as active
	s.wallets = append(s.wallets, *wallet)
	s.activeWalletID = wallet.ID

	if err := s.saveWalletFile(); err != nil {
		s.log.Error().Err(err).Msg("failed to save wallet file after generation")
		return nil, fmt.Errorf("save wallet: %w", err)
	}

	s.log.Info().
		Str("id", wallet.ID).
		Str("name", name).
		Str("type", walletType).
		Str("file", s.walletFilePath()).
		Msg("wallet generated and saved successfully")
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
	_, err = Decrypt(string(data), key)
	if err != nil {
		s.log.Warn().Msg("unlock failed: incorrect password (decryption failed)")
		return fmt.Errorf("incorrect password")
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

	if err := atomicWrite(walletPath, []byte(encrypted)); err != nil {
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

	if err := atomicWrite(s.walletFilePath(), []byte(encrypted)); err != nil {
		return fmt.Errorf("write wallet: %w", err)
	}

	newMeta := EncryptionMetadata{
		Salt:       base64.StdEncoding.EncodeToString(newSalt),
		Iterations: DefaultIterations,
		Encrypted:  true,
		Version:    "1.0",
	}
	metaBytes, _ := newMeta.Marshal()
	if err := os.WriteFile(s.metadataFilePath(), metaBytes, 0600); err != nil {
		return fmt.Errorf("write metadata: %w", err)
	}

	s.encryptionKey = newKey
	s.unlockedPass = newPassword

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
	if err := atomicWrite(walletPath, []byte(plaintext)); err != nil {
		return fmt.Errorf("write wallet: %w", err)
	}

	// Remove metadata file
	os.Remove(s.metadataFilePath())

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

func (s *Service) ListWallets() []WalletMetadata {
	s.mu.RLock()
	defer s.mu.RUnlock()

	out := make([]WalletMetadata, len(s.wallets))
	for i, w := range s.wallets {
		out[i] = WalletMetadata{
			ID:         w.ID,
			Name:       w.Name,
			WalletType: w.WalletType,
			Gradient:   w.Gradient,
			CreatedAt:  w.CreatedAt,
		}
	}
	s.log.Debug().Int("count", len(out)).Msg("listed wallets")
	return out
}

func (s *Service) SwitchWallet(walletID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Str("wallet_id", walletID).Msg("switching wallet")

	found := false
	for _, w := range s.wallets {
		if w.ID == walletID {
			found = true
			break
		}
	}
	if !found {
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
	if s.activeWalletID == walletID {
		if len(s.wallets) > 0 {
			s.activeWalletID = s.wallets[0].ID
		} else {
			s.activeWalletID = ""
		}
	}

	s.log.Info().Str("wallet_id", walletID).Int("remaining", len(s.wallets)).Msg("wallet deleted")
	return s.saveWalletFile()
}

func (s *Service) DeleteAllWallets() error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.log.Info().Int("wallet_count", len(s.wallets)).Msg("deleting all wallets")

	s.wallets = nil
	s.activeWalletID = ""
	s.encryptionKey = nil
	s.unlockedPass = ""

	// Delete files
	os.Remove(s.walletFilePath())
	os.Remove(s.metadataFilePath())

	s.log.Info().Msg("all wallets deleted, files removed")
	return nil
}

// --- Starter Files ---

// WriteL1Starter writes the enforcer wallet's L1 mnemonic to a temp file.
func (s *Service) WriteL1Starter() (string, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	s.log.Info().Msg("writing L1 starter file")

	// Find enforcer wallet
	var mnemonic string
	for _, w := range s.wallets {
		if w.WalletType == "enforcer" {
			mnemonic = w.L1.Mnemonic
			s.log.Debug().Str("wallet_id", w.ID).Msg("found enforcer wallet for L1 starter")
			break
		}
	}
	if mnemonic == "" {
		s.log.Warn().Int("wallet_count", len(s.wallets)).Msg("L1 starter: enforcer wallet not found or L1 mnemonic empty")
		return "", fmt.Errorf("enforcer wallet not found or L1 mnemonic empty")
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

	active := s.activeWallet()
	if active == nil {
		s.log.Warn().Str("active_id", s.activeWalletID).Int("wallet_count", len(s.wallets)).Msg("sidechain starter: no active wallet")
		return "", fmt.Errorf("no active wallet")
	}

	var mnemonic string
	for _, sc := range active.Sidechains {
		if sc.Slot == slot {
			mnemonic = sc.Mnemonic
			break
		}
	}
	if mnemonic == "" {
		s.log.Warn().Int("slot", slot).Int("sidechain_count", len(active.Sidechains)).Msg("sidechain starter: slot not found in active wallet")
		return "", fmt.Errorf("sidechain slot %d not found in active wallet", slot)
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
	os.RemoveAll(dir)
}

// --- Internal helpers ---

func (s *Service) walletFilePath() string {
	return filepath.Join(s.bitwindowDir, "wallet.json")
}

func (s *Service) metadataFilePath() string {
	return filepath.Join(s.bitwindowDir, "wallet_encryption.json")
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
			return nil
		}
		return fmt.Errorf("read wallet file: %w", err)
	}

	s.log.Debug().Int("file_size", len(data)).Bool("encrypted", s.isEncrypted()).Msg("wallet file read")

	jsonStr := string(data)

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
	s.log.Debug().Int("wallet_count", len(s.wallets)).Str("active_id", s.activeWalletID).Msg("wallet file loaded")
	return nil
}

// saveWalletFile writes wallet.json atomically. Must be called with mu held.
func (s *Service) saveWalletFile() error {
	wf := WalletFile{
		Version:        1,
		ActiveWalletID: s.activeWalletID,
		Wallets:        s.wallets,
	}

	jsonBytes, err := json.Marshal(wf)
	if err != nil {
		return fmt.Errorf("marshal wallet file: %w", err)
	}

	data := string(jsonBytes)

	if s.isEncrypted() && s.encryptionKey != nil {
		encrypted, err := Encrypt(data, s.encryptionKey)
		if err != nil {
			return fmt.Errorf("encrypt wallet: %w", err)
		}
		data = encrypted
		s.log.Debug().Msg("wallet file encrypted before save")
	}

	s.log.Debug().Str("path", s.walletFilePath()).Int("data_len", len(data)).Msg("saving wallet file")
	return atomicWrite(s.walletFilePath(), []byte(data))
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
				if strings.HasSuffix(event.Name, "wallet.json") &&
					(event.Has(fsnotify.Write) || event.Has(fsnotify.Create)) {
					debounce.Reset(100 * time.Millisecond)
				}
			case <-debounce.C:
				s.mu.Lock()
				if err := s.loadWalletFile(); err != nil {
					s.log.Warn().Err(err).Msg("watcher: reload wallet failed")
				} else {
					s.log.Debug().Msg("watcher: wallet reloaded")
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
	rand.Read(b)
	return strings.ToUpper(hex.EncodeToString(b))
}

// defaultGradient returns a simple default gradient JSON for a wallet.
func defaultGradient(walletID string) json.RawMessage {
	return json.RawMessage(`{"background_svg":""}`)
}
