package blockfile

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
)

// ErrNoBlocks says the directory holds no block a walk can read: a datadir
// that never synced, or one the user emptied. It names no network.
var ErrNoBlocks = errors.New("blocks directory holds no block record")

// Detect reads the network magic that a Core blocks directory holds. It takes
// the newest block file, because that one carries the network the node ran
// last, and it walks back over a file that holds nothing yet.
func Detect(ctx context.Context, blocksDir string) (Magic, error) {
	entries, err := os.ReadDir(blocksDir)
	if err != nil {
		return Magic{}, err
	}
	var names []string
	for _, entry := range entries {
		name := entry.Name()
		if dataName.MatchString(name) && name[:3] == "blk" {
			names = append(names, name)
		}
	}
	if len(names) == 0 {
		return Magic{}, ErrNoBlocks
	}
	sort.Sort(sort.Reverse(sort.StringSlice(names)))

	key, err := readKey(blocksDir)
	if err != nil {
		return Magic{}, err
	}
	for _, name := range names {
		if err := ctx.Err(); err != nil {
			return Magic{}, err
		}
		magic, ok, err := firstMagic(filepath.Join(blocksDir, name), key)
		if err != nil {
			return Magic{}, fmt.Errorf("read %s: %w", name, err)
		}
		if ok {
			return magic, nil
		}
	}
	return Magic{}, ErrNoBlocks
}

// firstMagic reads the magic of a file's first record. ok is false for a file
// Core reserved but never wrote.
func firstMagic(path string, key [8]byte) (Magic, bool, error) {
	file, err := openRegular(path, os.O_RDONLY)
	if err != nil {
		return Magic{}, false, err
	}
	defer file.Close() //nolint:errcheck

	var header [8]byte
	// Core reserves a file before it writes one, so a short or empty file holds
	// no record yet and the walk goes back to the file before it.
	if _, err := file.ReadAt(header[:], 0); errors.Is(err, io.EOF) {
		return Magic{}, false, nil
	} else if err != nil {
		return Magic{}, false, err
	}
	// An obfuscation key whose first bytes match the magic writes a record that
	// reads as zeros on disk, so a zero header alone does not name a reserved
	// file. Core writes a block behind every record, and a block holds no run
	// of zeros this long, so the head of the file decides.
	if allZero(header[:]) {
		empty, err := zeroHead(file)
		if err != nil {
			return Magic{}, false, err
		}
		if empty {
			return Magic{}, false, nil
		}
	}
	xor(header[:], key, 0)
	return Magic(header[:4]), true, nil
}

// zeroHead reports whether the first bytes of a file hold nothing but zeros.
func zeroHead(file *os.File) (bool, error) {
	var data [64 * 1024]byte
	n, err := file.ReadAt(data[:], 0)
	if err != nil && !errors.Is(err, io.EOF) {
		return false, err
	}
	return allZero(data[:n]), nil
}
