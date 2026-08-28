// Package walletfile owns every write to the bitwindow wallet file.
//
// The wallet file holds the seeds. Two processes once shared one, each wrote
// the whole file from its own memory, and a wallet create took away the
// wallets the other process held. [Write] is the single way in, and it is the
// place every safeguard lives.
package walletfile

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
)

// Name of the wallet file inside the bitwindow directory.
const Name = "wallet.json"

// LockSuffix names the lock file [Write] takes before it touches the wallet
// file. PreviousSuffix names the copy of the file each write replaces.
const (
	LockSuffix     = ".lock"
	PreviousSuffix = ".prev"
)

// ErrChanged reports that the wallet file on disk no longer holds what the
// caller read. Another writer changed or removed it.
var ErrChanged = errors.New("wallet file changed on disk since it was last read")

// ErrUnread reports a write over a wallet file the caller never read. Every
// caller reads the file first, so this is a bug in the caller.
var ErrUnread = errors.New("wallet file was never read, refusing to overwrite it")

// ErrDropsWallets reports a write that would take away a wallet the file on
// disk holds. Only a delete and a restore may do that.
var ErrDropsWallets = errors.New("refusing a write that drops wallets")

// Digest identifies wallet file content for the compare before a write.
type Digest [sha256.Size]byte

// DigestOf returns the mark a reader keeps. A reader that finds no file marks
// it with DigestOf(nil), and [Write] takes that as an expected absence.
func DigestOf(content []byte) Digest { return sha256.Sum256(content) }

// Options carries what the caller knows about the file it replaces.
type Options struct {
	// Expected is the content the caller read off disk, and ExpectedKnown says
	// the caller read it at all.
	Expected      Digest
	ExpectedKnown bool
	// AllowDrop lets the write remove wallets the current file holds.
	AllowDrop bool
}

// Validate reports whether content reads back as a wallet file: the encrypted
// form (base64 iv, colon, base64 ciphertext), the current shape with a
// `wallets` list, or the legacy shape with `master` and `l1`.
func Validate(content []byte) error {
	if len(content) == 0 {
		return errors.New("wallet file is empty")
	}
	if IsEncrypted(content) {
		return nil
	}

	var raw map[string]json.RawMessage
	if err := json.Unmarshal(content, &raw); err != nil {
		return fmt.Errorf("wallet file does not parse: %w", err)
	}
	if wallets, ok := raw["wallets"]; ok {
		if !isArrayOrNull(wallets) {
			return errors.New("wallet file carries no wallet list")
		}
		return nil
	}
	_, hasMaster := raw["master"]
	_, hasL1 := raw["l1"]
	if hasMaster && hasL1 {
		return nil
	}
	return errors.New("wallet file carries neither a wallet list nor a master key")
}

// IsEncrypted reports whether content is the encrypted wallet form.
func IsEncrypted(content []byte) bool {
	iv, ciphertext, found := strings.Cut(string(content), ":")
	if !found || iv == "" || ciphertext == "" {
		return false
	}
	if _, err := base64.StdEncoding.DecodeString(iv); err != nil {
		return false
	}
	_, err := base64.StdEncoding.DecodeString(ciphertext)
	return err == nil
}

func isArrayOrNull(value json.RawMessage) bool {
	trimmed := bytes.TrimSpace(value)
	return bytes.Equal(trimmed, []byte("null")) || (len(trimmed) > 0 && trimmed[0] == '[')
}

// WalletIDs returns the wallet ids in content. It reports false when content
// is not plaintext wallet JSON, so an encrypted file compares against nothing.
func WalletIDs(content []byte) ([]string, bool) {
	if IsEncrypted(content) {
		return nil, false
	}
	var parsed struct {
		Wallets []struct {
			ID string `json:"id"`
		} `json:"wallets"`
	}
	if err := json.Unmarshal(content, &parsed); err != nil {
		return nil, false
	}
	ids := make([]string, 0, len(parsed.Wallets))
	for _, w := range parsed.Wallets {
		ids = append(ids, w.ID)
	}
	return ids, true
}

// DroppedWalletIDs returns the wallet ids current holds and next does not.
func DroppedWalletIDs(current, next []byte) []string {
	currentIDs, ok := WalletIDs(current)
	if !ok {
		return nil
	}
	nextIDs, ok := WalletIDs(next)
	if !ok {
		return nil
	}
	kept := make(map[string]struct{}, len(nextIDs))
	for _, id := range nextIDs {
		kept[id] = struct{}{}
	}
	var dropped []string
	for _, id := range currentIDs {
		if _, ok := kept[id]; !ok {
			dropped = append(dropped, id)
		}
	}
	return dropped
}

// Write replaces the wallet file at path. It is the only way to write that
// file, and it holds every safeguard:
//
//  1. content reads back as a wallet file.
//  2. A lock covers the read, the compare, and the replacement, so two
//     processes take turns.
//  3. The file on disk still holds what the caller read, and a file another
//     process removed counts as a change.
//  4. The write keeps every wallet the current file holds, unless the caller
//     asks to drop one.
//  5. The replaced file stays at path+[PreviousSuffix], and never as plaintext
//     beside an encrypted wallet.
//  6. The written file parses; a file that does not is rolled back.
func Write(path string, content []byte, opts Options) error {
	if err := Validate(content); err != nil {
		return fmt.Errorf("refusing to write wallet file: %w", err)
	}

	unlock, err := lock(path)
	if err != nil {
		return err
	}
	defer unlock()

	current, err := os.ReadFile(path)
	switch {
	case err == nil:
		currentValid := Validate(current) == nil
		if !opts.ExpectedKnown && currentValid {
			return ErrUnread
		}
		if opts.ExpectedKnown && DigestOf(current) != opts.Expected {
			return ErrChanged
		}
		if dropped := DroppedWalletIDs(current, content); !opts.AllowDrop && len(dropped) > 0 {
			return fmt.Errorf("%w: %s", ErrDropsWallets, strings.Join(dropped, ", "))
		}
		if err := keepPrevious(path, current, content, currentValid); err != nil {
			return err
		}
	case os.IsNotExist(err):
		// A file this process read and another process removed is a change. A
		// write here would bring back the wallets a wipe took away.
		if opts.ExpectedKnown && opts.Expected != DigestOf(nil) {
			return ErrChanged
		}
	default:
		return fmt.Errorf("read the wallet file before the write: %w", err)
	}

	if err := atomicWrite(path, content); err != nil {
		return err
	}

	written, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("read the wallet file back: %w", err)
	}
	// Content that differs is a later writer's work, and it is valid, so it
	// stays. Only an unreadable file calls for the copy to go back.
	if err := Validate(written); err != nil {
		return rollback(path, fmt.Errorf("the wallet file does not read back: %w", err))
	}
	return nil
}

// keepPrevious stores the file the write replaces, so a bad write leaves a way
// back. It stores nothing that would leave a seed in the clear.
func keepPrevious(path string, current, content []byte, currentValid bool) error {
	if !currentValid {
		return nil
	}
	if IsEncrypted(content) && !IsEncrypted(current) {
		// Encryption starts here. A plaintext copy beside the encrypted file
		// hands the seed to anyone who reads the disk.
		if err := os.Remove(path + PreviousSuffix); err != nil && !os.IsNotExist(err) {
			return fmt.Errorf("remove the plaintext wallet copy: %w", err)
		}
		return nil
	}
	if err := atomicWrite(path+PreviousSuffix, current); err != nil {
		return fmt.Errorf("keep the previous wallet file: %w", err)
	}
	return nil
}

// rollback puts the kept copy back and reports cause. A missing copy leaves
// cause alone: there is nothing better to put in place.
func rollback(path string, cause error) error {
	previous, err := os.ReadFile(path + PreviousSuffix)
	if err != nil || Validate(previous) != nil {
		return cause
	}
	if err := atomicWrite(path, previous); err != nil {
		return fmt.Errorf("%w, and the previous file did not go back: %v", cause, err)
	}
	return fmt.Errorf("%w, the previous wallet file went back in place", cause)
}

func atomicWrite(path string, content []byte) error {
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, content, 0600); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

// WithLock runs fn while this process holds the wallet file lock. A caller
// that moves, renames, or removes the wallet file takes the lock the same way
// [Write] does, so a wipe and a save never overlap.
//
// Do not call [Write] inside fn: the lock is not reentrant.
func WithLock(path string, fn func() error) error {
	unlock, err := lock(path)
	if err != nil {
		return err
	}
	defer unlock()
	return fn()
}
