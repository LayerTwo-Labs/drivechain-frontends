package blockfile

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/binary"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

var sourceMagic = Magic{0xec, 0xa5, 0xa1, 0x04}
var targetMagic = Magic{0xbe, 0x7a, 0xa2, 0x05}

func testOptions(t *testing.T, key [8]byte) Options {
	t.Helper()
	dir := t.TempDir()
	blocks := filepath.Join(dir, "blocks")
	require.NoError(t, os.Mkdir(blocks, 0700))
	if key != ([8]byte{}) {
		require.NoError(t, os.WriteFile(filepath.Join(blocks, "xor.dat"), key[:], 0600))
	}
	return Options{DataDir: dir, BlocksDir: blocks, From: sourceMagic, To: targetMagic}
}

func blockPayload(t *testing.T) []byte {
	t.Helper()
	var payload bytes.Buffer
	require.NoError(t, chaincfg.MainNetParams.GenesisBlock.Serialize(&payload))
	return payload.Bytes()
}

func undoPayload() []byte {
	payload := []byte{0}
	data := append(make([]byte, 32), payload...)
	first := sha256.Sum256(data)
	checksum := sha256.Sum256(first[:])
	return append(payload, checksum[:]...)
}

func dataRecord(magic Magic, payload []byte, undo bool) []byte {
	header := make([]byte, 8)
	copy(header, magic[:])
	size := len(payload)
	if undo {
		size -= 32
	}
	binary.LittleEndian.PutUint32(header[4:], uint32(size))
	return append(header, payload...)
}

func putRecords(t *testing.T, opts Options, name string, key [8]byte, tail int, records ...[]byte) []byte {
	t.Helper()
	data := bytes.Join(records, nil)
	xor(data, key, 0)
	data = append(data, make([]byte, tail)...)
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, name), data, 0600))
	return bytes.Clone(data)
}

func readData(t *testing.T, opts Options, name string) []byte {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(opts.BlocksDir, name))
	require.NoError(t, err)
	return data
}

func TestParseMagic(t *testing.T) {
	for _, value := range []string{"eca5a104", "ECA5A104"} {
		magic, err := ParseMagic(value)
		require.NoError(t, err)
		require.Equal(t, sourceMagic, magic)
	}
	for _, value := range []string{"", "eca5a1", "eca5a10400", "0xeca5a104", "zzzzzzzz", "00000000"} {
		_, err := ParseMagic(value)
		require.Error(t, err)
	}
}

func TestConvertKeepsPayloadsAndPositions(t *testing.T) {
	for _, key := range [][8]byte{{}, {0x39, 0x01, 0xfe, 0xa0, 0x65, 0x72, 0x99, 0x47}} {
		t.Run(fmt.Sprintf("xor_%x", key), func(t *testing.T) {
			opts := testOptions(t, key)
			payload := blockPayload(t)
			copy(payload[76:80], sourceMagic[:])
			block := dataRecord(sourceMagic, payload, false)
			undo := dataRecord(sourceMagic, undoPayload(), true)
			oldBlock := putRecords(t, opts, "blk00005.dat", key, 1001, block, block, block)
			oldUndo := putRecords(t, opts, "rev00005.dat", key, 71, undo, undo)
			lastBlock := putRecords(t, opts, "blk00027.dat", key, 0, block)
			preview, err := Preview(context.Background(), opts)
			require.NoError(t, err)
			require.EqualValues(t, 6, preview.Records)
			require.EqualValues(t, 24, preview.Bytes)
			require.EqualValues(t, 4*len(payload)+2*len(undoPayload()), preview.DataBytes)
			require.Equal(t, oldBlock, readData(t, opts, "blk00005.dat"))
			require.NoFileExists(t, preview.JournalPath)
			report, err := Convert(context.Background(), opts)
			require.NoError(t, err)
			require.True(t, report.Complete)
			require.EqualValues(t, 6, report.ConvertedRecords)
			require.Equal(t, 2, report.BlockFiles)
			require.Equal(t, 1, report.UndoFiles)
			for _, item := range []struct {
				name string
				old  []byte
				size int
				num  int
			}{{"blk00005.dat", oldBlock, len(block), 3}, {"rev00005.dat", oldUndo, len(undo), 2}, {"blk00027.dat", lastBlock, len(block), 1}} {
				expected := bytes.Clone(item.old)
				for i := range item.num {
					offset := i * item.size
					magic := encodedMagic(targetMagic, key, int64(offset))
					copy(expected[offset:offset+4], magic[:])
				}
				require.Equal(t, expected, readData(t, opts, item.name), item.name)
			}
			second, err := Convert(context.Background(), opts)
			require.NoError(t, err)
			require.Equal(t, report, second)
			preview, err = Preview(context.Background(), opts)
			require.NoError(t, err)
			require.True(t, preview.Complete)
		})
	}
}

func TestPreflightStopsBeforeAnyDataWrite(t *testing.T) {
	tests := []struct {
		name  string
		file  string
		data  func(*testing.T) []byte
		error string
	}{
		{"wrong_magic", "blk00001.dat", func(t *testing.T) []byte { return dataRecord(targetMagic, blockPayload(t), false) }, "unexpected magic"},
		{"short_header", "blk00001.dat", func(*testing.T) []byte { return sourceMagic[:] }, "partial record header"},
		{"short_payload", "blk00001.dat", func(t *testing.T) []byte { return dataRecord(sourceMagic, blockPayload(t), false)[:100] }, "partial record data"},
		{"small_block", "blk00001.dat", func(*testing.T) []byte { return dataRecord(sourceMagic, make([]byte, 79), false) }, "invalid block size"},
		{"large_block", "blk00001.dat", func(t *testing.T) []byte {
			data := dataRecord(sourceMagic, blockPayload(t), false)
			binary.LittleEndian.PutUint32(data[4:], 4_000_001)
			return data
		}, "invalid block size"},
		{"empty_undo", "rev00001.dat", func(*testing.T) []byte { return dataRecord(sourceMagic, make([]byte, 32), true) }, "invalid undo size"},
		{"large_undo", "rev00001.dat", func(*testing.T) []byte {
			data := dataRecord(sourceMagic, undoPayload(), true)
			binary.LittleEndian.PutUint32(data[4:], 0x02000001)
			return data
		}, "invalid undo size"},
		{"short_checksum", "rev00001.dat", func(*testing.T) []byte {
			data := dataRecord(sourceMagic, undoPayload(), true)
			return data[:len(data)-1]
		}, "partial record data"},
		{"nonzero_tail", "blk00001.dat", func(t *testing.T) []byte {
			data := dataRecord(sourceMagic, blockPayload(t), false)
			return append(data, append(make([]byte, 20), 1)...)
		}, "unexpected magic"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			opts := testOptions(t, [8]byte{})
			old := putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
			bad := test.data(t)
			require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, test.file), bad, 0600))
			report, err := Convert(context.Background(), opts)
			require.ErrorContains(t, err, test.error)
			require.Equal(t, old, readData(t, opts, "blk00000.dat"))
			require.Equal(t, bad, readData(t, opts, test.file))
			require.NoFileExists(t, report.JournalPath)
		})
	}
}

func TestPhysicalZeroTails(t *testing.T) {
	for _, key := range [][8]byte{{}, {3, 7, 8, 91, 52, 19, 22, 200}} {
		for _, size := range []int{1, 7, 8, 65537} {
			t.Run(fmt.Sprintf("xor_%x_tail_%d", key, size), func(t *testing.T) {
				opts := testOptions(t, key)
				putRecords(t, opts, "blk00000.dat", key, size, dataRecord(sourceMagic, blockPayload(t), false))
				putRecords(t, opts, "rev00000.dat", key, size)
				report, err := Convert(context.Background(), opts)
				require.NoError(t, err)
				require.EqualValues(t, 1, report.Records)
				data := readData(t, opts, "blk00000.dat")
				require.Equal(t, make([]byte, size), data[len(data)-size:])
			})
		}
	}
}

func TestEmptyDataFails(t *testing.T) {
	for _, name := range []string{"", "blk00000.dat", "rev00000.dat"} {
		t.Run(name, func(t *testing.T) {
			opts := testOptions(t, [8]byte{})
			if name != "" {
				putRecords(t, opts, name, [8]byte{}, 0)
			}
			_, err := Convert(context.Background(), opts)
			require.Error(t, err)
		})
	}
	opts := testOptions(t, [8]byte{})
	putRecords(t, opts, "blk00000.dat", [8]byte{}, 0)
	putRecords(t, opts, "rev00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, undoPayload(), true))
	_, err := Convert(context.Background(), opts)
	require.ErrorContains(t, err, "no block records")
}

func TestResumeAfterPartialMagicWrite(t *testing.T) {
	for _, key := range [][8]byte{{}, {4, 92, 33, 70, 1, 240, 21, 87}} {
		for mask := range 16 {
			t.Run(fmt.Sprintf("xor_%x_mask_%d", key, mask), func(t *testing.T) {
				opts := testOptions(t, key)
				block := dataRecord(sourceMagic, blockPayload(t), false)
				old := putRecords(t, opts, "blk00000.dat", key, 0, block, block)
				stop := errors.New("test interruption")
				opts.Progress = func(p Progress) error {
					if p.Stage == "convert" {
						return stop
					}
					return nil
				}
				report, err := Convert(context.Background(), opts)
				require.ErrorIs(t, err, stop)
				require.FileExists(t, report.JournalPath)
				require.Equal(t, old, readData(t, opts, "blk00000.dat"))
				offset := len(block)
				target := encodedMagic(targetMagic, key, int64(offset))
				for i := range 4 {
					if mask&(1<<i) != 0 {
						old[offset+i] = target[i]
					}
				}
				require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00000.dat"), old, 0600))
				opts.Progress = nil
				report, err = Convert(context.Background(), opts)
				require.NoError(t, err)
				require.True(t, report.Complete)
				require.EqualValues(t, 2, report.ConvertedRecords)
				data := readData(t, opts, "blk00000.dat")
				xor(data, key, 0)
				require.Equal(t, targetMagic[:], data[:4])
				require.Equal(t, targetMagic[:], data[offset:offset+4])
				require.Equal(t, block[4:], data[4:offset])
				require.Equal(t, block[4:], data[offset+4:])
			})
		}
	}
}

func TestResumeAfterFileCompletion(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	block := dataRecord(sourceMagic, blockPayload(t), false)
	for _, name := range []string{"blk00000.dat", "blk00001.dat"} {
		putRecords(t, opts, name, [8]byte{}, 0, block)
	}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	opts.Progress = func(p Progress) error {
		if p.Stage == "convert" && p.File == "blk00000.dat" {
			cancel()
		}
		return nil
	}
	report, err := Convert(ctx, opts)
	require.ErrorIs(t, err, context.Canceled)
	require.False(t, report.Complete)
	require.Equal(t, targetMagic[:], readData(t, opts, "blk00000.dat")[:4])
	require.Equal(t, sourceMagic[:], readData(t, opts, "blk00001.dat")[:4])
	opts.Progress = nil
	preview, err := Preview(context.Background(), opts)
	require.NoError(t, err)
	require.EqualValues(t, 1, preview.ConvertedRecords)
	report, err = Convert(context.Background(), opts)
	require.NoError(t, err)
	require.True(t, report.Complete)
}

func TestResumeWithinFile(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	block := dataRecord(sourceMagic, blockPayload(t), false)
	data := bytes.Repeat(block, 4097)
	require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00000.dat"), data, 0600))
	stop := errors.New("test interruption")
	opts.Progress = func(p Progress) error {
		if p.Stage == "convert" && p.ConvertedRecords == 4096 {
			return stop
		}
		return nil
	}
	report, err := Convert(context.Background(), opts)
	require.ErrorIs(t, err, stop)
	require.EqualValues(t, 4096, report.ConvertedRecords)
	data = readData(t, opts, "blk00000.dat")
	require.Equal(t, targetMagic[:], data[4095*len(block):4095*len(block)+4])
	require.Equal(t, sourceMagic[:], data[4096*len(block):4096*len(block)+4])
	opts.Progress = nil
	report, err = Convert(context.Background(), opts)
	require.NoError(t, err)
	require.True(t, report.Complete)
	require.EqualValues(t, 4097, report.ConvertedRecords)
}

func TestResumeRejectsChangedIdentity(t *testing.T) {
	for _, change := range []string{"source", "target", "key", "file_size", "file_list", "journal", "magic", "record_size"} {
		t.Run(change, func(t *testing.T) {
			opts := testOptions(t, [8]byte{})
			putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
			opts.Progress = func(p Progress) error {
				if p.Stage == "convert" {
					return errors.New("test interruption")
				}
				return nil
			}
			report, err := Convert(context.Background(), opts)
			require.Error(t, err)
			opts.Progress = nil
			switch change {
			case "source":
				opts.From[0]++
			case "target":
				opts.To[0]++
			case "key":
				require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "xor.dat"), []byte{1, 2, 3, 4, 5, 6, 7, 8}, 0600))
			case "file_list":
				putRecords(t, opts, "blk00001.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
			case "journal":
				data, err := os.ReadFile(report.JournalPath)
				require.NoError(t, err)
				data[len(data)-1] ^= 0xff
				require.NoError(t, os.WriteFile(report.JournalPath, data, 0600))
			default:
				data := readData(t, opts, "blk00000.dat")
				switch change {
				case "file_size":
					data = append(data, 0)
				case "magic":
					data[0] = 0xff
				case "record_size":
					data[4]++
				}
				require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "blk00000.dat"), data, 0600))
			}
			old := readData(t, opts, "blk00000.dat")
			_, err = Convert(context.Background(), opts)
			require.Error(t, err)
			require.Equal(t, old, readData(t, opts, "blk00000.dat"))
		})
	}
}

func TestInvalidOptions(t *testing.T) {
	for _, change := range []string{"same_magic", "zero_magic", "empty_path", "absent_path", "journal_conflict", "short_key"} {
		t.Run(change, func(t *testing.T) {
			opts := testOptions(t, [8]byte{})
			putRecords(t, opts, "blk00000.dat", [8]byte{}, 0, dataRecord(sourceMagic, blockPayload(t), false))
			switch change {
			case "same_magic":
				opts.To = opts.From
			case "zero_magic":
				opts.From = Magic{}
			case "empty_path":
				opts.DataDir = ""
			case "absent_path":
				opts.BlocksDir = filepath.Join(opts.DataDir, "absent")
			case "journal_conflict":
				opts.JournalPath = filepath.Join(opts.BlocksDir, "blk00000.dat")
			case "short_key":
				require.NoError(t, os.WriteFile(filepath.Join(opts.BlocksDir, "xor.dat"), []byte{1, 2}, 0600))
			}
			_, err := Convert(context.Background(), opts)
			require.Error(t, err)
		})
	}
}

func TestCancelBeforePreflight(t *testing.T) {
	opts := testOptions(t, [8]byte{})
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	_, err := Convert(ctx, opts)
	require.ErrorIs(t, err, context.Canceled)
	require.NoFileExists(t, filepath.Join(opts.DataDir, ".lock"))
}

func TestZeroHeaderCanContainARecord(t *testing.T) {
	payload := blockPayload(t)
	var key [8]byte
	copy(key[:], sourceMagic[:])
	binary.LittleEndian.PutUint32(key[4:], uint32(len(payload)))
	opts := testOptions(t, key)
	data := putRecords(t, opts, "blk00000.dat", key, 0, dataRecord(sourceMagic, payload, false))
	require.Equal(t, make([]byte, 8), data[:8])
	_, err := Convert(context.Background(), opts)
	require.NoError(t, err)
}

func TestJournalDecodeErrors(t *testing.T) {
	for _, data := range [][]byte{{1, 2, 3}, bytes.Repeat([]byte{0x7f}, 80)} {
		path := filepath.Join(t.TempDir(), "journal")
		require.NoError(t, os.WriteFile(path, data, 0600))
		_, err := readJournal(path)
		require.Error(t, err)
	}
	path := filepath.Join(t.TempDir(), "journal")
	data := []byte(strings.Repeat("invalid gob data", 8))
	sum := sha256.Sum256(data)
	require.NoError(t, os.WriteFile(path, append(data, sum[:]...), 0600))
	_, err := readJournal(path)
	require.ErrorContains(t, err, "decode conversion journal")
}
