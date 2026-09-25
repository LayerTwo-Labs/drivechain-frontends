package blockfile

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// The newest file names the network the node ran last, so a datadir that
// changed network reads as the one it holds now.
func TestDetectReadsTheNewestFile(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	payload := blockPayload(t)
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, payload, false))
	putRecords(t, opts, "blk00001.dat", [8]byte{}, 0, dataRecord(targetMagic, payload, false))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, targetMagic, magic)
}

// Core reserves a file before it writes one, so the walk goes back a file.
func TestDetectWalksPastAnEmptyFile(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00001.dat"), make([]byte, 128), 0600))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, sourceMagic, magic)
}

// An obfuscated datadir reads the same, because the key undoes the xor.
func TestDetectReadsThroughTheXorKey(t *testing.T) {
	key := [8]byte{0x39, 0x01, 0xfe, 0xa0, 0x65, 0x72, 0x99, 0x47}
	opts := testOptions(t, key)
	putRecords(t, opts, "blk00000.dat", key, 0, dataRecord(targetMagic, blockPayload(t), false))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, targetMagic, magic)
}

// A datadir that never synced names no network, and the caller reads that
// answer rather than a failure.
func TestDetectReportsAnEmptyDirectory(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	_, err := Detect(context.Background(), opts.BlocksDir)
	require.ErrorIs(t, err, ErrNoBlocks)
}

// Core appends, so a file that holds two networks names the one the node ran
// last. A conversion that stopped part way leaves such a file.
func TestDetectReadsTheLastRecord(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0,
		dataRecord(sourceMagic, blockPayload(t), false),
		dataRecord(targetMagic, blockPayload(t), false),
	)

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, targetMagic, magic)
}

// Core reserves the tail of a file, and an obfuscation key hides every record.
// The walk reads past the key and stops at the reserved tail.
func TestDetectReadsTheLastRecordUnderAKey(t *testing.T) {
	key := [8]byte{1, 2, 3, 4, 5, 6, 7, 8}
	opts := testOptions(t, key)
	putRecords(t, opts, "blk00000.dat", key, 4096,
		dataRecord(targetMagic, blockPayload(t), false),
		dataRecord(sourceMagic, blockPayload(t), false),
	)

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, sourceMagic, magic)
}

// A datadir that two networks wrote holds the older one in its first file. A
// reader of the newest record alone would call the directory uniform.
func TestReadEndsNamesBothNetworks(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
	putRecords(t, opts, "blk00001.dat", [8]byte{}, 0, dataRecord(targetMagic, blockPayload(t), false))

	ends, err := ReadEnds(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, sourceMagic, ends.First)
	require.Equal(t, targetMagic, ends.Last)
	require.False(t, ends.Uniform())
}

// One network wrote every file, so both ends name it.
func TestReadEndsNamesOneNetwork(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(targetMagic, blockPayload(t), false))
	putRecords(t, opts, "blk00001.dat", [8]byte{}, 0, dataRecord(targetMagic, blockPayload(t), false))

	ends, err := ReadEnds(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.True(t, ends.Uniform())
	require.Equal(t, targetMagic, ends.Last)
}

// Core reserves a file before it writes one, so the walk reads past it at both
// ends.
func TestReadEndsWalksPastReservedFiles(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00000.dat"), make([]byte, 128), 0600))
	putRecords(t, opts, "blk00001.dat", [8]byte{}, 0, dataRecord(targetMagic, blockPayload(t), false))
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00002.dat"), make([]byte, 128), 0600))

	ends, err := ReadEnds(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.True(t, ends.Uniform())
	require.Equal(t, targetMagic, ends.First)
}

// A datadir the user just picked holds no blocks directory at all, and a wipe
// takes it away again. The caller reads that as an answer, not as a failure.
func TestDetectReportsAnAbsentDirectory(t *testing.T) {
	_, err := Detect(context.Background(), filepath.Join(t.TempDir(), "nothing", "blocks"))
	require.ErrorIs(t, err, ErrNoBlocks)
}

// Core reserves a file before it writes one, so a directory of reserved files
// names no network either.
func TestDetectReportsOnlyReservedFiles(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00000.dat"), make([]byte, 128), 0600))

	_, err := Detect(context.Background(), opts.BlocksDir)
	require.ErrorIs(t, err, ErrNoBlocks)
}

// Core reserves a file before it writes one, so a zero byte file holds no
// record and the walk goes back.
func TestDetectWalksPastAZeroByteFile(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00001.dat"), nil, 0600))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, sourceMagic, magic)
}

// The directory holds whatever the user put there, so a short name must not
// end the walk.
func TestDetectSkipsAStrayFile(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(targetMagic, blockPayload(t), false))
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "x"), []byte("stray"), 0600))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, targetMagic, magic)
}

// An obfuscation key whose first bytes match the magic writes a record that
// reads as zeros on disk. The decoded size tells it apart from a reserved file.
func TestDetectReadsARecordThatEncodesToZeros(t *testing.T) {
	key := [8]byte{targetMagic[0], targetMagic[1], targetMagic[2], targetMagic[3], 0, 0, 0, 0}
	opts := testOptions(t, key)
	putRecords(t, opts, "blk00000.dat", key, 0, dataRecord(targetMagic, blockPayload(t), false))

	data := readData(t, opts, "blk00000.dat")
	require.Equal(t, []byte{0, 0, 0, 0}, data[:4], "the record must encode to zeros for this test")

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, targetMagic, magic)
}

// A reserved file holds zeros whatever the key decodes them to, so a key whose
// bytes name a plausible block size must not read as a record.
func TestDetectSkipsAReservedFileWhateverTheKeyDecodes(t *testing.T) {
	// The key's size bytes decode to 1000, inside the block size range.
	key := [8]byte{0x11, 0x22, 0x33, 0x44, 0xe8, 0x03, 0x00, 0x00}
	opts := testOptions(t, key)
	putRecords(t, opts, "blk00000.dat", key, 0, dataRecord(sourceMagic, blockPayload(t), false))
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00001.dat"), make([]byte, 128*1024), 0600))

	magic, err := Detect(context.Background(), opts.BlocksDir)
	require.NoError(t, err)
	require.Equal(t, sourceMagic, magic, "the walk must pass the reserved file")
}
