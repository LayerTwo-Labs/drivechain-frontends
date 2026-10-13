package wallet

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/walletfile"
)

// writeWalletFileLocked writes the wallet file through the one gate and
// records what it wrote. It keeps every wallet the file on disk holds. Must be
// called with mu held.
func (s *Service) writeWalletFileLocked(content []byte) error {
	return s.writeWalletFileWithOptionsLocked(content, false)
}

// writeWalletFileAllowingDropLocked writes the wallet file and lets the write
// take away a wallet the file on disk holds. Only a delete and a restore use
// it. Must be called with mu held.
func (s *Service) writeWalletFileAllowingDropLocked(content []byte) error {
	return s.writeWalletFileWithOptionsLocked(content, true)
}

func (s *Service) writeWalletFileWithOptionsLocked(content []byte, allowDrop bool) error {
	opts := walletfile.Options{
		Expected:      s.lastWalletDigest,
		ExpectedKnown: s.lastWalletDigestKnown,
		AllowDrop:     allowDrop,
	}
	if err := walletfile.Write(s.walletFilePath(), content, opts); err != nil {
		s.log.Error().Err(err).Str("path", s.walletFilePath()).Msg("wallet file write refused")
		return err
	}
	s.setWalletDigestLocked(content)
	return nil
}

// setWalletDigestLocked records the wallet file content this process read or
// wrote. Must be called with mu held.
func (s *Service) setWalletDigestLocked(content []byte) {
	s.lastWalletDigest = walletfile.DigestOf(content)
	s.lastWalletDigestKnown = true
}

// restoreWalletFileLocked puts a backup's wallet file in place. It reads the
// backup and the file it replaces first. Must be called with mu held.
func (s *Service) restoreWalletFileLocked(src string) error {
	content, err := os.ReadFile(src)
	if err != nil {
		return fmt.Errorf("read the backup wallet file: %w", err)
	}
	if err := walletfile.Validate(content); err != nil {
		return fmt.Errorf("backup %s: %w", src, err)
	}

	current, err := os.ReadFile(s.walletFilePath())
	switch {
	case err == nil:
		s.setWalletDigestLocked(current)
	case os.IsNotExist(err):
		s.setWalletDigestLocked(nil)
	default:
		return fmt.Errorf("read the wallet file before the restore: %w", err)
	}
	return s.writeWalletFileAllowingDropLocked(content)
}

const leftoverMetadataSuffix = ".encryption.json"

// protectPlaintextLeftoversLocked encrypts the plaintext copies an older EncryptWallet left beside wallet.json.
func (s *Service) protectPlaintextLeftoversLocked(key []byte) error {
	paths, err := filepath.Glob(s.walletFilePath() + ".backup_before_encryption_*")
	if err != nil {
		return fmt.Errorf("find plaintext wallet copies: %w", err)
	}
	for _, path := range paths {
		if strings.HasSuffix(path, ".tmp") || strings.HasSuffix(path, leftoverMetadataSuffix) {
			continue
		}
		content, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("read %s: %w", path, err)
		}
		if walletfile.IsEncrypted(content) {
			continue
		}
		if err := s.encryptLeftover(path, content, key); err != nil {
			return err
		}
		s.log.Info().Str("path", path).Msg("encrypted a plaintext wallet copy")
	}
	return nil
}

func (s *Service) encryptLeftover(path string, content, key []byte) error {
	meta, err := s.loadMetadata()
	if err != nil {
		return fmt.Errorf("read encryption metadata: %w", err)
	}
	metaBytes, err := meta.Marshal()
	if err != nil {
		return fmt.Errorf("marshal metadata: %w", err)
	}
	// Own metadata, so the copy still opens after a later password change.
	if err := walletfile.AtomicWrite(path+leftoverMetadataSuffix, metaBytes); err != nil {
		return fmt.Errorf("write metadata of %s: %w", path, err)
	}
	encrypted, err := Encrypt(string(content), key)
	if err != nil {
		return fmt.Errorf("encrypt %s: %w", path, err)
	}
	if err := walletfile.AtomicWrite(path, []byte(encrypted)); err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	return nil
}
