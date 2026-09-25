package blockfile

import (
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
)

// ErrNoBlocks says the directory holds no block a walk can read: a datadir
// that never synced, or one the user emptied. It names no network.
var ErrNoBlocks = errors.New("blocks directory holds no block record")

// Ends names the network at both ends of a blocks directory.
type Ends struct {
	// First is the magic of the first record the oldest file holds.
	First Magic
	// Last is the magic of the last record the newest file holds.
	Last Magic
}

// Uniform reports whether one network wrote both ends.
func (e Ends) Uniform() bool { return e.First == e.Last }

// Detect reads the network magic that a Core blocks directory holds. It takes
// the last record of the newest file, because that one carries the network the
// node ran last.
func Detect(ctx context.Context, blocksDir string) (Magic, error) {
	ends, err := ReadEnds(ctx, blocksDir)
	if err != nil {
		return Magic{}, err
	}
	return ends.Last, nil
}

// ReadEnds reads the network at both ends of a Core blocks directory. A
// conversion that stopped part way, and a datadir that two networks wrote,
// answer with two magics.
func ReadEnds(ctx context.Context, blocksDir string) (Ends, error) {
	entries, err := os.ReadDir(blocksDir)
	if errors.Is(err, os.ErrNotExist) {
		// A datadir the user just picked holds no blocks directory at all, and
		// a wipe takes it away again. Both name no network.
		return Ends{}, ErrNoBlocks
	}
	if err != nil {
		return Ends{}, err
	}
	var names []string
	for _, entry := range entries {
		name := entry.Name()
		if dataName.MatchString(name) && name[:3] == "blk" {
			names = append(names, name)
		}
	}
	if len(names) == 0 {
		return Ends{}, ErrNoBlocks
	}
	sort.Strings(names)

	key, err := readKey(blocksDir)
	if err != nil {
		return Ends{}, err
	}

	last, err := endMagic(ctx, blocksDir, reversed(names), key, true)
	if err != nil {
		return Ends{}, err
	}
	first, err := endMagic(ctx, blocksDir, names, key, false)
	if err != nil {
		return Ends{}, err
	}
	if last == (Magic{}) || first == (Magic{}) {
		return Ends{}, ErrNoBlocks
	}
	return Ends{First: first, Last: last}, nil
}

// endMagic takes the first file of the list that holds a record, and reads the
// magic of that file's first or last one. Core reserves a file before it
// writes one, so the walk goes on over a file that holds nothing yet.
func endMagic(ctx context.Context, blocksDir string, names []string, key [8]byte, wantLast bool) (Magic, error) {
	for _, name := range names {
		if err := ctx.Err(); err != nil {
			return Magic{}, err
		}
		magic, ok, err := magicAt(ctx, filepath.Join(blocksDir, name), key, wantLast)
		if err != nil {
			return Magic{}, fmt.Errorf("read %s: %w", name, err)
		}
		if ok {
			return magic, nil
		}
	}
	return Magic{}, nil
}

func reversed(names []string) []string {
	out := make([]string, len(names))
	for i, name := range names {
		out[len(names)-1-i] = name
	}
	return out
}

// magicAt reads the magic of a file's first record, or of its last complete
// one. Core appends, so the last record names the network the node ran last,
// and a file that holds two networks answers with a different magic at each
// end. ok is false for a file Core reserved but never wrote.
func magicAt(ctx context.Context, path string, key [8]byte, wantLast bool) (Magic, bool, error) {
	file, err := openRegular(path, os.O_RDONLY)
	if err != nil {
		return Magic{}, false, err
	}
	defer file.Close() //nolint:errcheck

	info, err := file.Stat()
	if err != nil {
		return Magic{}, false, err
	}
	end := info.Size()

	var (
		last  Magic
		found bool
	)
	for offset := int64(0); offset+8 <= end; {
		if err := ctx.Err(); err != nil {
			return Magic{}, false, err
		}
		var header [8]byte
		if _, err := file.ReadAt(header[:], offset); err != nil {
			return Magic{}, false, err
		}
		// An obfuscation key whose bytes match a header writes a record that
		// reads as zeros on disk, so a zero header alone names no reserved
		// tail. Core writes a block behind every record, and a block holds no
		// run of zeros this long, so the rest of the file decides.
		if allZero(header[:]) {
			tail, err := zeroTail(ctx, file, offset, end)
			if err != nil {
				return Magic{}, false, err
			}
			if tail {
				break
			}
		}
		xor(header[:], key, offset)
		last, found = Magic(header[:4]), true
		if !wantLast {
			break
		}
		payload := int64(binary.LittleEndian.Uint32(header[4:]))
		if payload <= 0 || offset+8+payload > end {
			// A record Core cut short ends the walk, and the magic it carries
			// still names the network that wrote it.
			break
		}
		offset += 8 + payload
	}
	return last, found, nil
}
