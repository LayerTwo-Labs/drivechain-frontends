package wallet

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/tyler-smith/go-bip39"
)

// CopyMasterWalletFilesToBackup snapshots wallet.json, wallet_encryption.json
// and metadata.json into a fresh <bitwindowDir>/wallet_backups/<ts>/ and
// returns that directory. Unlike the move used by wipes, the originals stay in
// place: the wallets that are not being swapped keep living in wallet.json.
// The layout matches what ListWalletBackups reads, so the snapshot is
// restorable through the normal restore flow.
func (s *Service) CopyMasterWalletFilesToBackup() (string, error) {
	// Under the read lock for the whole copy: encryption changes rewrite
	// wallet.json and wallet_encryption.json in separate writes, and a snapshot
	// straddling one of them would pair a plaintext wallet with encryption
	// metadata — listed as encrypted, impossible to restore.
	s.mu.RLock()
	defer s.mu.RUnlock()

	root := filepath.Join(s.bitwindowDir, "wallet_backups")
	stamp := time.Now().UTC().Format("20060102-150405")

	// Built under a hidden name and published by rename, so a listing never
	// sees a half-copied snapshot: wallet.json alone is enough for one to read
	// as a valid plaintext backup, encryption metadata and all.
	staging, err := uniqueBackupRoot(filepath.Join(root, "."+stamp+".incomplete"))
	if err != nil {
		return "", err
	}
	for _, p := range s.MasterWalletPaths() {
		if !fileExists(p) {
			continue
		}
		if err := copyExistingFile(p, filepath.Join(staging, filepath.Base(p))); err != nil {
			if rmErr := os.RemoveAll(staging); rmErr != nil {
				s.log.Error().Err(rmErr).Str("backup", staging).Msg("could not remove a partial wallet snapshot")
			}
			return "", fmt.Errorf("snapshot %s: %w", p, err)
		}
	}

	backupRoot, err := publishBackupRoot(staging, filepath.Join(root, stamp))
	if err != nil {
		if rmErr := os.RemoveAll(staging); rmErr != nil {
			s.log.Error().Err(rmErr).Str("backup", staging).Msg("could not remove an unpublished wallet snapshot")
		}
		return "", err
	}

	s.log.Info().Str("backup", backupRoot).Msg("master wallet files snapshotted")
	return backupRoot, nil
}

// publishBackupRoot renames a finished snapshot to the first free name at or
// after base, making it visible to ListWalletBackups in one step.
func publishBackupRoot(staging, base string) (string, error) {
	for attempt := 1; attempt < 100; attempt++ {
		candidate := base
		if attempt > 1 {
			candidate = fmt.Sprintf("%s-%d", base, attempt)
		}
		if _, err := os.Stat(candidate); err == nil {
			continue
		}
		if err := os.Rename(staging, candidate); err != nil {
			if os.IsExist(err) {
				continue
			}
			return "", fmt.Errorf("publish wallet snapshot: %w", err)
		}
		return candidate, nil
	}
	return "", fmt.Errorf("could not find a free backup directory next to %s", base)
}

// uniqueBackupRoot creates and returns a directory that did not exist yet.
// Timestamps only resolve to the second, so two backups taken in the same
// second would otherwise merge and overwrite each other's wallet.json.
func uniqueBackupRoot(base string) (string, error) {
	if err := os.MkdirAll(filepath.Dir(base), 0o700); err != nil {
		return "", fmt.Errorf("create backup root: %w", err)
	}
	for attempt := 1; attempt < 100; attempt++ {
		candidate := base
		if attempt > 1 {
			candidate = fmt.Sprintf("%s-%d", base, attempt)
		}
		err := os.Mkdir(candidate, 0o700)
		if err == nil {
			return candidate, nil
		}
		if !os.IsExist(err) {
			return "", fmt.Errorf("create backup root: %w", err)
		}
	}
	return "", fmt.Errorf("could not find a free backup directory next to %s", base)
}

// EnforcerWalletSwap is a swap that has been derived but not yet installed.
type EnforcerWalletSwap struct {
	// Replacement is the wallet that will become the enforcer wallet.
	Replacement *WalletData
	// PreviousID is the enforcer wallet the swap was derived against. The
	// commit refuses if that is no longer the enforcer wallet on record.
	PreviousID string
	// RequestedName is the name the caller asked for, empty to keep whatever
	// the enforcer wallet is called when the swap commits.
	RequestedName string
}

// PrepareEnforcerWalletSwap derives the wallet that would replace the enforcer
// wallet, without touching any state. Everything that can reject a swap — a
// locked wallet, a bad mnemonic, a missing enforcer wallet — fails here, before
// the caller stops the daemon or moves anything on disk.
func (s *Service) PrepareEnforcerWalletSwap(name, mnemonic string, slots []SidechainSlot) (*EnforcerWalletSwap, error) {
	if mnemonic == "" {
		return nil, fmt.Errorf("mnemonic is required")
	}
	if !bip39.IsMnemonicValid(mnemonic) {
		return nil, fmt.Errorf("invalid mnemonic")
	}

	s.mu.RLock()
	defer s.mu.RUnlock()

	if s.locked() {
		return nil, fmt.Errorf("wallet is locked, unlock before swapping the enforcer wallet")
	}

	current := s.enforcerWallet()
	if current == nil {
		return nil, fmt.Errorf("no enforcer wallet to swap")
	}

	replacement, err := GenerateFullWallet(name, mnemonic, "", slots, WalletTypeEnforcer)
	if err != nil {
		return nil, fmt.Errorf("derive enforcer wallet: %w", err)
	}
	// A fresh ID: the old one's derived addresses and cached chain state belong
	// to the old seed. Everything that is not seed-derived — name, gradient,
	// sidechain starters — is carried over at commit time, from whatever the
	// wallet looks like then.
	replacement.ID = generateWalletID()
	replacement.CreatedAt = time.Now()
	return &EnforcerWalletSwap{Replacement: replacement, PreviousID: current.ID, RequestedName: name}, nil
}

// CommitEnforcerWalletSwap installs a wallet prepared by
// PrepareEnforcerWalletSwap as the enforcer wallet. In-memory state only
// changes if wallet.json was written, so a failed save leaves the process
// serving the wallet that is still on disk.
//
// The commit refuses if the enforcer wallet changed after the swap was
// prepared — a restore landing in between would otherwise be overwritten by a
// replacement derived from a wallet that is no longer there.
func (s *Service) CommitEnforcerWalletSwap(swap *EnforcerWalletSwap) error {
	if swap == nil || swap.Replacement == nil {
		return fmt.Errorf("no prepared wallet to commit")
	}
	replacement := swap.Replacement

	s.mu.Lock()
	defer s.mu.Unlock()

	index := -1
	for i := range s.wallets {
		if s.wallets[i].WalletType == WalletTypeEnforcer {
			index = i
			break
		}
	}
	if index < 0 {
		return fmt.Errorf("no enforcer wallet to swap")
	}

	previous := s.wallets[index]
	if previous.ID != swap.PreviousID {
		return fmt.Errorf("the enforcer wallet changed while the swap was in progress; retry the swap")
	}
	previousActiveID := s.activeWalletID

	// Carry the non-seed-derived fields from the wallet as it stands now, not as
	// it stood when the swap was prepared: a rename, a gradient change or a
	// starter derived on demand in between must survive the swap.
	if swap.RequestedName == "" {
		replacement.Name = previous.Name
	}
	replacement.Gradient = previous.Gradient
	// Sidechain starters stay on the seed their daemons and Core wallets were
	// built from. Re-deriving them would re-key every sidechain while only the
	// enforcer is stopped and backed up, stranding each on keys nothing records.
	replacement.Sidechains = append([]SidechainWallet(nil), previous.Sidechains...)

	s.wallets[index] = *replacement
	if s.activeWalletID == previous.ID {
		s.activeWalletID = replacement.ID
	}

	if err := s.saveWalletFile(); err != nil {
		s.wallets[index] = previous
		s.activeWalletID = previousActiveID
		return fmt.Errorf("save wallet: %w", err)
	}

	s.deleteElectrumScan(previous.ID)
	s.log.Info().
		Str("previous_id", previous.ID).
		Str("wallet_id", replacement.ID).
		Str("name", replacement.Name).
		Msg("enforcer wallet swapped")
	return nil
}
