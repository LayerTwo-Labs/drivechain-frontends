package wallet

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/samber/lo"

	orchestratorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

const walletMetadataVersion = 1

type BalanceSnapshot struct {
	Binary        orchestratorpb.BinaryType `json:"binary"`
	DisplayName   string                    `json:"displayName"`
	ConfirmedSats uint64                    `json:"confirmedSats"`
	PendingSats   uint64                    `json:"pendingSats"`
	UpdatedAt     time.Time                 `json:"updatedAt"`
}

type WalletSummary struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	WalletType WalletType `json:"walletType"`
}

type WalletMetadataFile struct {
	Version            int                        `json:"version"`
	UpdatedAt          time.Time                  `json:"updatedAt"`
	ActiveWalletID     string                     `json:"activeWalletId,omitempty"`
	Wallets            []WalletSummary            `json:"wallets,omitempty"`
	LatestKnownBalance map[string]BalanceSnapshot `json:"latestKnownBalance,omitempty"`
}

type WalletBackupInfo struct {
	ID                 string
	Path               string
	SourceName         string
	CreatedAt          time.Time
	Encrypted          bool
	HasMetadata        bool
	Valid              bool
	ErrorMessage       string
	ActiveWalletID     string
	Wallets            []WalletSummary
	LatestKnownBalance []BalanceSnapshot
}

type RestoreWalletBackupStep struct {
	ID   string
	Name string
}

type RestoreWalletBackupStepStatus string

const (
	RestoreWalletBackupStepStarted   RestoreWalletBackupStepStatus = "started"
	RestoreWalletBackupStepCompleted RestoreWalletBackupStepStatus = "completed"
	RestoreWalletBackupStepFailed    RestoreWalletBackupStepStatus = "failed"
)

const (
	restoreStepValidate      = "validate-backup"
	restoreStepVerifyPass    = "verify-password"
	restoreStepBackupCurrent = "backup-current-wallet"
	restoreStepRestoreFiles  = "restore-wallet-files"
	restoreStepLoadWallet    = "load-restored-wallet"
	restoreStepComplete      = "restore-complete"
)

type RestoreWalletBackupProgressFunc func(stepID string, status RestoreWalletBackupStepStatus, err error)

func (s *Service) WalletMetadataFilePath() string {
	return filepath.Join(s.bitwindowDir, "metadata.json")
}

func (s *Service) SyncBalance(binary orchestratorpb.BinaryType, walletID string, confirmedSats, pendingSats uint64, displayName string) error {
	if binary == orchestratorpb.BinaryType_BINARY_TYPE_UNSPECIFIED {
		return fmt.Errorf("binary type is required")
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	meta, err := s.loadWalletMetadataFile()
	if err != nil {
		return err
	}
	if meta.Version == 0 {
		meta.Version = walletMetadataVersion
	}
	if meta.LatestKnownBalance == nil {
		meta.LatestKnownBalance = map[string]BalanceSnapshot{}
	}

	dirty := false
	if walletID != "" {
		if meta.ActiveWalletID != walletID {
			meta.ActiveWalletID = walletID
			dirty = true
		}
	} else if s.activeWalletID != "" {
		if meta.ActiveWalletID != s.activeWalletID {
			meta.ActiveWalletID = s.activeWalletID
			dirty = true
		}
	}
	if len(s.wallets) > 0 {
		summaries := walletSummaries(s.wallets)
		if !walletSummariesEqual(meta.Wallets, summaries) {
			meta.Wallets = summaries
			dirty = true
		}
	}
	if displayName == "" {
		displayName = binaryDisplayName(binary)
	}

	key := balanceKey(binary)
	now := time.Now().UTC()
	next := BalanceSnapshot{
		Binary:        binary,
		DisplayName:   displayName,
		ConfirmedSats: confirmedSats,
		PendingSats:   pendingSats,
		UpdatedAt:     now,
	}
	prev, ok := meta.LatestKnownBalance[key]
	balanceUnchanged := ok &&
		prev.Binary == next.Binary &&
		prev.DisplayName == next.DisplayName &&
		prev.ConfirmedSats == next.ConfirmedSats &&
		prev.PendingSats == next.PendingSats
	if balanceUnchanged && !dirty {
		return nil
	}

	meta.UpdatedAt = now
	if !balanceUnchanged {
		meta.LatestKnownBalance[key] = next
	}
	return s.writeWalletMetadataFile(meta)
}

func (s *Service) ListWalletBackups() ([]WalletBackupInfo, error) {
	root := filepath.Join(s.bitwindowDir, "wallet_backups")
	entries, err := os.ReadDir(root)
	if os.IsNotExist(err) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read wallet backups: %w", err)
	}

	var backups []WalletBackupInfo
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		dir := filepath.Join(root, entry.Name())
		info := s.readWalletBackupInfo(dir)
		backups = append(backups, info)
	}

	sort.SliceStable(backups, func(i, j int) bool {
		return backups[i].CreatedAt.After(backups[j].CreatedAt)
	})
	return backups, nil
}

func (s *Service) RestoreWalletBackup(backupID, password string) error {
	return s.restoreWalletBackup(backupID, password, nil)
}

func (s *Service) RestoreWalletBackupPlan(backupID string) ([]RestoreWalletBackupStep, error) {
	_, _, _, encrypted, err := s.resolveWalletBackupForRestore(backupID)
	if err != nil {
		return nil, err
	}
	return restoreWalletBackupSteps(encrypted), nil
}

func (s *Service) RestoreWalletBackupWithProgress(backupID, password string, progress RestoreWalletBackupProgressFunc) error {
	return s.restoreWalletBackup(backupID, password, progress)
}

func (s *Service) restoreWalletBackup(backupID, password string, progress RestoreWalletBackupProgressFunc) error {
	runStep := func(stepID string, fn func() error) error {
		emitRestoreProgress(progress, stepID, RestoreWalletBackupStepStarted, nil)
		if err := fn(); err != nil {
			emitRestoreProgress(progress, stepID, RestoreWalletBackupStepFailed, err)
			return err
		}
		emitRestoreProgress(progress, stepID, RestoreWalletBackupStepCompleted, nil)
		return nil
	}

	var selected *WalletBackupInfo
	var walletSrc string
	var encryptionSrc string
	var encrypted bool

	if err := runStep(restoreStepValidate, func() error {
		var err error
		selected, walletSrc, encryptionSrc, encrypted, err = s.resolveWalletBackupForRestore(backupID)
		return err
	}); err != nil {
		return err
	}

	var unlockKey []byte
	if encrypted {
		if err := runStep(restoreStepVerifyPass, func() error {
			if password == "" {
				return fmt.Errorf("password is required for encrypted wallet backup")
			}
			key, err := verifyEncryptedWalletBackup(walletSrc, encryptionSrc, password)
			if err != nil {
				return err
			}
			unlockKey = key
			return nil
		}); err != nil {
			return err
		}
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if err := runStep(restoreStepBackupCurrent, func() error {
		return s.moveMasterWalletFilesToBackup()
	}); err != nil {
		return err
	}

	if err := runStep(restoreStepRestoreFiles, func() error {
		if err := copyExistingFile(walletSrc, s.walletFilePath()); err != nil {
			return fmt.Errorf("restore wallet.json: %w", err)
		}
		if fileExists(encryptionSrc) {
			if err := copyExistingFile(encryptionSrc, s.metadataFilePath()); err != nil {
				return fmt.Errorf("restore wallet_encryption.json: %w", err)
			}
		}
		metadataSrc := filepath.Join(selected.Path, "metadata.json")
		if fileExists(metadataSrc) {
			if err := copyExistingFile(metadataSrc, s.WalletMetadataFilePath()); err != nil {
				return fmt.Errorf("restore metadata.json: %w", err)
			}
		}
		return nil
	}); err != nil {
		return err
	}

	if err := runStep(restoreStepLoadWallet, func() error {
		s.wallets = nil
		s.activeWalletID = ""
		s.encryptionKey = unlockKey
		s.unlockedPass = ""
		if encrypted {
			s.unlockedPass = password
		}
		if err := s.loadWalletFile(); err != nil {
			return fmt.Errorf("load restored wallet: %w", err)
		}
		return nil
	}); err != nil {
		return err
	}

	if err := runStep(restoreStepComplete, func() error {
		s.notifyChanged()
		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (s *Service) resolveWalletBackupForRestore(backupID string) (*WalletBackupInfo, string, string, bool, error) {
	if backupID == "" {
		return nil, "", "", false, fmt.Errorf("backup_id is required")
	}

	backups, err := s.ListWalletBackups()
	if err != nil {
		return nil, "", "", false, err
	}

	var selected *WalletBackupInfo
	for i := range backups {
		if backups[i].ID == backupID {
			selected = &backups[i]
			break
		}
	}
	if selected == nil {
		return nil, "", "", false, fmt.Errorf("wallet backup not found")
	}
	if !selected.Valid {
		if selected.ErrorMessage != "" {
			return nil, "", "", false, fmt.Errorf("wallet backup is invalid: %s", selected.ErrorMessage)
		}
		return nil, "", "", false, fmt.Errorf("wallet backup is invalid")
	}

	walletSrc := backupWalletPath(selected.Path)
	if walletSrc == "" {
		return nil, "", "", false, fmt.Errorf("wallet backup is missing wallet.json")
	}
	encryptionSrc := filepath.Join(selected.Path, "wallet_encryption.json")
	encrypted := fileExists(encryptionSrc)

	return selected, walletSrc, encryptionSrc, encrypted, nil
}

func restoreWalletBackupSteps(encrypted bool) []RestoreWalletBackupStep {
	steps := []RestoreWalletBackupStep{
		{ID: restoreStepValidate, Name: "Validating wallet backup"},
	}
	if encrypted {
		steps = append(steps, RestoreWalletBackupStep{ID: restoreStepVerifyPass, Name: "Verifying wallet password"})
	}
	steps = append(steps,
		RestoreWalletBackupStep{ID: restoreStepBackupCurrent, Name: "Backing up current wallet"},
		RestoreWalletBackupStep{ID: restoreStepRestoreFiles, Name: "Restoring wallet files"},
		RestoreWalletBackupStep{ID: restoreStepLoadWallet, Name: "Loading restored wallet"},
		RestoreWalletBackupStep{ID: restoreStepComplete, Name: "Restore complete"},
	)
	return steps
}

func emitRestoreProgress(progress RestoreWalletBackupProgressFunc, stepID string, status RestoreWalletBackupStepStatus, err error) {
	if progress != nil {
		progress(stepID, status, err)
	}
}

func (s *Service) loadWalletMetadataFile() (WalletMetadataFile, error) {
	data, err := os.ReadFile(s.WalletMetadataFilePath())
	if os.IsNotExist(err) {
		return WalletMetadataFile{Version: walletMetadataVersion}, nil
	}
	if err != nil {
		return WalletMetadataFile{}, fmt.Errorf("read metadata.json: %w", err)
	}
	var meta WalletMetadataFile
	if err := json.Unmarshal(data, &meta); err != nil {
		return WalletMetadataFile{}, fmt.Errorf("parse metadata.json: %w", err)
	}
	return meta, nil
}

func (s *Service) writeWalletMetadataFile(meta WalletMetadataFile) error {
	data, err := json.MarshalIndent(meta, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal metadata.json: %w", err)
	}
	return atomicWrite(s.WalletMetadataFilePath(), data)
}

func (s *Service) readWalletBackupInfo(dir string) WalletBackupInfo {
	info := WalletBackupInfo{
		Path:       dir,
		SourceName: filepath.Base(dir),
		CreatedAt:  backupTimestamp(dir),
		Valid:      true,
	}
	info.ID = backupID(dir)

	walletPath := backupWalletPath(dir)
	if walletPath == "" {
		info.Valid = false
		info.ErrorMessage = "missing wallet.json"
	}

	encryptionPath := filepath.Join(dir, "wallet_encryption.json")
	info.Encrypted = fileExists(encryptionPath)

	metadataPath := filepath.Join(dir, "metadata.json")
	if data, err := os.ReadFile(metadataPath); err == nil {
		var meta WalletMetadataFile
		if err := json.Unmarshal(data, &meta); err == nil {
			info.HasMetadata = true
			info.ActiveWalletID = meta.ActiveWalletID
			info.Wallets = meta.Wallets
			for _, b := range meta.LatestKnownBalance {
				info.LatestKnownBalance = append(info.LatestKnownBalance, b)
			}
			sort.Slice(info.LatestKnownBalance, func(i, j int) bool {
				return info.LatestKnownBalance[i].Binary < info.LatestKnownBalance[j].Binary
			})
			if !meta.UpdatedAt.IsZero() && info.CreatedAt.IsZero() {
				info.CreatedAt = meta.UpdatedAt
			}
		}
	}

	if len(info.Wallets) == 0 && walletPath != "" && !info.Encrypted {
		if summaries, activeID, err := readPlainWalletSummary(walletPath); err == nil {
			info.Wallets = summaries
			info.ActiveWalletID = activeID
		}
	}
	return info
}

func walletSummaries(wallets []WalletData) []WalletSummary {
	return lo.Map(wallets, func(w WalletData, _ int) WalletSummary {
		return WalletSummary{ID: w.ID, Name: w.Name, WalletType: w.WalletType}
	})
}

func walletSummariesEqual(a, b []WalletSummary) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

func readPlainWalletSummary(path string) ([]WalletSummary, string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, "", err
	}
	var wf WalletFile
	if err := json.Unmarshal(data, &wf); err != nil {
		return nil, "", err
	}
	return walletSummaries(wf.Wallets), wf.ActiveWalletID, nil
}

func verifyEncryptedWalletBackup(walletPath, encryptionPath, password string) ([]byte, error) {
	metaData, err := os.ReadFile(encryptionPath)
	if err != nil {
		return nil, fmt.Errorf("read wallet encryption metadata: %w", err)
	}
	meta, err := UnmarshalEncryptionMetadata(metaData)
	if err != nil {
		return nil, fmt.Errorf("parse wallet encryption metadata: %w", err)
	}
	if !meta.Encrypted {
		return nil, fmt.Errorf("wallet backup encryption metadata is not encrypted")
	}
	salt, err := base64.StdEncoding.DecodeString(meta.Salt)
	if err != nil {
		return nil, fmt.Errorf("decode wallet encryption salt: %w", err)
	}
	key := DeriveKey(password, salt, meta.Iterations)
	data, err := os.ReadFile(walletPath)
	if err != nil {
		return nil, fmt.Errorf("read encrypted wallet: %w", err)
	}
	if _, err := Decrypt(string(data), key); err != nil {
		return nil, fmt.Errorf("incorrect password")
	}
	return key, nil
}

func backupWalletPath(dir string) string {
	path := filepath.Join(dir, "wallet.json")
	if fileExists(path) {
		return path
	}
	entries, err := os.ReadDir(dir)
	if err != nil {
		return ""
	}
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		if strings.HasPrefix(entry.Name(), "wallet.json-") {
			return filepath.Join(dir, entry.Name())
		}
	}
	return ""
}

func backupTimestamp(dir string) time.Time {
	if ts, err := time.ParseInLocation("20060102-150405", filepath.Base(dir), time.UTC); err == nil {
		return ts
	}
	if st, err := os.Stat(dir); err == nil {
		return st.ModTime().UTC()
	}
	return time.Time{}
}

func backupID(dir string) string {
	abs, err := filepath.Abs(dir)
	if err != nil {
		abs = dir
	}
	st, err := os.Stat(dir)
	marker := abs
	if err == nil {
		marker = fmt.Sprintf("%s:%d:%d", abs, st.ModTime().UnixNano(), st.Size())
	}
	sum := sha256.Sum256([]byte(marker))
	return hex.EncodeToString(sum[:16])
}

func copyExistingFile(src, dst string) error {
	st, err := os.Stat(src)
	if err != nil {
		return err
	}
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return atomicWriteWithMode(dst, data, st.Mode().Perm())
}

func atomicWriteWithMode(path string, data []byte, mode os.FileMode) error {
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, mode); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func balanceKey(binary orchestratorpb.BinaryType) string {
	name := binary.String()
	name = strings.TrimPrefix(name, "BINARY_TYPE_")
	return strings.ToLower(name)
}

func binaryDisplayName(binary orchestratorpb.BinaryType) string {
	switch binary {
	case orchestratorpb.BinaryType_BINARY_TYPE_BITCOIND:
		return "Bitcoin"
	case orchestratorpb.BinaryType_BINARY_TYPE_THUNDER:
		return "Thunder"
	case orchestratorpb.BinaryType_BINARY_TYPE_ZSIDE:
		return "ZSide"
	case orchestratorpb.BinaryType_BINARY_TYPE_BITNAMES:
		return "BitNames"
	case orchestratorpb.BinaryType_BINARY_TYPE_BITASSETS:
		return "BitAssets"
	case orchestratorpb.BinaryType_BINARY_TYPE_TRUTHCOIN:
		return "Truthcoin"
	case orchestratorpb.BinaryType_BINARY_TYPE_PHOTON:
		return "Photon"
	case orchestratorpb.BinaryType_BINARY_TYPE_COINSHIFT:
		return "CoinShift"
	default:
		return binary.String()
	}
}
