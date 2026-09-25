package blockfile

import (
	"context"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
)

// Magic is the four-byte network identifier in each disk record.
type Magic [4]byte

// String writes the four bytes in hexadecimal order, as the catalog names them.
func (m Magic) String() string {
	return hex.EncodeToString(m[:])
}

// ParseMagic reads four bytes in hexadecimal order.
func ParseMagic(value string) (Magic, error) {
	var magic Magic
	if len(value) != 8 {
		return magic, errors.New("network magic must contain eight hexadecimal characters")
	}
	data, err := hex.DecodeString(value)
	if err != nil {
		return magic, fmt.Errorf("decode network magic: %w", err)
	}
	copy(magic[:], data)
	if magic == (Magic{}) {
		return magic, errors.New("network magic cannot equal zero")
	}
	return magic, nil
}

// Options selects the Core directories and the conversion identity.
type Options struct {
	// DataDir is Core's network data directory; Core must stop before conversion.
	DataDir     string
	BlocksDir   string
	JournalPath string
	From        Magic
	To          Magic
	Progress    func(Progress) error
}

// Progress reports record counts during preflight and conversion.
type Progress struct {
	Stage            string
	File             string
	Records          int64
	ConvertedRecords int64
}

// Report describes the files and record counts in one conversion.
type Report struct {
	Files            int
	BlockFiles       int
	UndoFiles        int
	Records          int64
	ConvertedRecords int64
	// Bytes counts the four-byte magic fields in block and undo records.
	Bytes int64
	// DataBytes counts payload and checksum bytes; the converter skips these bytes.
	DataBytes   int64
	Complete    bool
	JournalPath string
}

type record struct {
	Offset   int64
	Size     uint32
	Original Magic
}

type filePlan struct {
	Name    string
	Size    int64
	Records []record
}

type journal struct {
	Version   int
	DataDir   string
	BlocksDir string
	From      Magic
	To        Magic
	Key       [8]byte
	Files     []filePlan
}

var dataName = regexp.MustCompile(`^(blk|rev)[0-9]{5}\.dat$`)

// Preview checks every record without a data write; it takes both Core directory locks.
func Preview(ctx context.Context, opts Options) (Report, error) {
	return run(ctx, opts, false)
}

// Convert changes only record magic and resumes partial writes through its durable journal.
func Convert(ctx context.Context, opts Options) (Report, error) {
	return run(ctx, opts, true)
}

func run(ctx context.Context, opts Options, write bool) (report Report, err error) {
	if err = ctx.Err(); err != nil {
		return report, err
	}
	opts, err = prepare(opts)
	if err != nil {
		return report, err
	}
	report.JournalPath = opts.JournalPath
	lock, err := lockDirectories(opts.DataDir, opts.BlocksDir)
	if err != nil {
		return report, err
	}
	defer func() { err = errors.Join(err, lock.close()) }()
	key, err := readKey(opts.BlocksDir)
	if err != nil {
		return report, err
	}
	plan, err := readJournal(opts.JournalPath)
	if err != nil {
		return report, err
	}
	resume := plan != nil
	if resume {
		if plan.Version != 1 || plan.DataDir != opts.DataDir || plan.BlocksDir != opts.BlocksDir ||
			plan.From != opts.From || plan.To != opts.To || plan.Key != key {
			return report, errors.New("conversion identity differs from the saved journal")
		}
	} else {
		plan = &journal{Version: 1, DataDir: opts.DataDir, BlocksDir: opts.BlocksDir, From: opts.From, To: opts.To, Key: key}
	}
	if err = preflight(ctx, opts, plan, resume, write, &report); err != nil {
		return report, err
	}
	if !write {
		report.Complete = report.Records == report.ConvertedRecords
		return report, nil
	}
	// A prior process can stop after the journal rename but before the directory flush.
	if err = saveJournal(opts.JournalPath, plan); err != nil {
		return report, err
	}
	if err = progress(ctx, opts, report, "convert", ""); err != nil {
		return report, err
	}
	report.ConvertedRecords = 0
	for _, file := range plan.Files {
		if err = convertFile(ctx, opts, plan, file, &report); err != nil {
			return report, err
		}
	}
	if err = progress(ctx, opts, report, "complete", ""); err != nil {
		return report, err
	}
	report.Complete = true
	return report, nil
}

func prepare(opts Options) (Options, error) {
	if opts.From == (Magic{}) || opts.To == (Magic{}) || opts.From == opts.To {
		return opts, errors.New("source and target magic must differ and cannot equal zero")
	}
	if opts.DataDir == "" {
		return opts, errors.New("the Core data directory is empty")
	}
	var err error
	opts.DataDir, err = directoryPath(opts.DataDir)
	if err != nil {
		return opts, err
	}
	if opts.BlocksDir == "" {
		opts.BlocksDir = filepath.Join(opts.DataDir, "blocks")
	}
	opts.BlocksDir, err = directoryPath(opts.BlocksDir)
	if err != nil {
		return opts, err
	}
	if opts.JournalPath == "" {
		opts.JournalPath = filepath.Join(opts.DataDir, ".ecash-magic-journal")
	}
	parent, err := directoryPath(filepath.Dir(opts.JournalPath))
	if err != nil {
		return opts, err
	}
	name := filepath.Base(opts.JournalPath)
	if name == ".lock" || name == "xor.dat" || dataName.MatchString(name) {
		return opts, errors.New("journal path conflicts with a Core data file")
	}
	opts.JournalPath = filepath.Join(parent, name)
	return opts, nil
}

func directoryPath(path string) (string, error) {
	path, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}
	path, err = filepath.EvalSymlinks(path)
	if err != nil {
		return "", err
	}
	info, err := os.Stat(path)
	if err != nil {
		return "", err
	}
	if !info.IsDir() {
		return "", fmt.Errorf("path is not a directory: %s", path)
	}
	return path, nil
}

func openRegular(path string, flags int) (*os.File, error) {
	info, err := os.Lstat(path)
	if err != nil {
		return nil, err
	}
	if !info.Mode().IsRegular() {
		return nil, fmt.Errorf("path is not a regular file: %s", path)
	}
	file, err := os.OpenFile(path, flags, 0)
	if err != nil {
		return nil, err
	}
	opened, err := file.Stat()
	if err != nil {
		return nil, errors.Join(err, file.Close())
	}
	if !os.SameFile(info, opened) {
		return nil, errors.Join(fmt.Errorf("file changed before open: %s", path), file.Close())
	}
	return file, nil
}

func readKey(dir string) (key [8]byte, err error) {
	file, err := openRegular(filepath.Join(dir, "xor.dat"), os.O_RDONLY)
	if errors.Is(err, os.ErrNotExist) {
		return key, nil
	}
	if err != nil {
		return key, err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	info, err := file.Stat()
	if err != nil {
		return key, err
	}
	if info.Size() != int64(len(key)) {
		return key, errors.New("xor.dat must contain eight bytes")
	}
	_, err = io.ReadFull(file, key[:])
	return key, err
}

func preflight(ctx context.Context, opts Options, plan *journal, resume, write bool, report *Report) error {
	entries, err := os.ReadDir(opts.BlocksDir)
	if err != nil {
		return err
	}
	var names []string
	for _, entry := range entries {
		if dataName.MatchString(entry.Name()) {
			names = append(names, entry.Name())
		}
	}
	if len(names) == 0 {
		return errors.New("blocks directory contains no block or undo files")
	}
	if resume && len(names) != len(plan.Files) {
		return errors.New("data file list differs from the saved journal")
	}
	var blockRecords int64
	flags := os.O_RDONLY
	if write {
		flags = os.O_RDWR
	}
	for i, name := range names {
		var saved *filePlan
		if resume {
			saved = &plan.Files[i]
			if saved.Name != name {
				return errors.New("data file list differs from the saved journal")
			}
		}
		before := report.Records
		file, err := scanFile(ctx, opts, plan.Key, name, saved, flags, report)
		if err != nil {
			return fmt.Errorf("check %s: %w", name, err)
		}
		if !resume {
			plan.Files = append(plan.Files, file)
		}
		report.Files++
		if name[:3] == "blk" {
			report.BlockFiles++
			blockRecords += report.Records - before
		} else {
			report.UndoFiles++
		}
		if err := progress(ctx, opts, *report, "preflight", name); err != nil {
			return err
		}
	}
	if blockRecords == 0 {
		return errors.New("blocks directory contains no block records")
	}
	return nil
}

func scanFile(ctx context.Context, opts Options, key [8]byte, name string, saved *filePlan, flags int, report *Report) (plan filePlan, err error) {
	file, err := openRegular(filepath.Join(opts.BlocksDir, name), flags)
	if err != nil {
		return plan, err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	info, err := file.Stat()
	if err != nil {
		return plan, err
	}
	plan.Name, plan.Size = name, info.Size()
	if saved != nil && saved.Size != plan.Size {
		return plan, errors.New("file size differs from the saved journal")
	}
	var offset int64
	var count int
	for offset < plan.Size {
		if err := ctx.Err(); err != nil {
			return plan, err
		}
		var header [8]byte
		n, err := file.ReadAt(header[:], offset)
		if err != nil && !errors.Is(err, io.EOF) {
			return plan, err
		}
		if allZero(header[:n]) {
			tail, err := zeroTail(ctx, file, offset, plan.Size)
			if err != nil {
				return plan, err
			}
			if tail {
				break
			}
		}
		if n != len(header) {
			return plan, fmt.Errorf("partial record header at byte %d", offset)
		}
		raw := Magic(header[:4])
		xor(header[:], key, offset)
		size := binary.LittleEndian.Uint32(header[4:])
		if saved == nil {
			// A record already at the target is a block the datadir wrote on the
			// network we move to, so the swap leaves it alone.
			switch found := Magic(header[:4]); found {
			case opts.From, opts.To:
			default:
				return plan, fmt.Errorf(
					"unexpected magic %s at byte %d: the file holds neither %s nor %s",
					found, offset, opts.From, opts.To)
			}
		} else {
			if count >= len(saved.Records) {
				return plan, fmt.Errorf("record is absent from the journal at byte %d", offset)
			}
			item := saved.Records[count]
			target := encodedMagic(opts.To, key, offset)
			// A record the first pass found at the target keeps that magic in
			// the journal, so a resume reads either one as its original.
			switch item.Original {
			case encodedMagic(opts.From, key, offset), target:
			default:
				return plan, fmt.Errorf("record differs from the journal at byte %d", offset)
			}
			if item.Offset != offset || item.Size != size {
				return plan, fmt.Errorf("record differs from the journal at byte %d", offset)
			}
			if !validPartial(raw, item.Original, target) {
				return plan, fmt.Errorf("unexpected magic at byte %d", offset)
			}
		}
		length, err := recordLength(name, size)
		if err != nil {
			return plan, fmt.Errorf("record at byte %d: %w", offset, err)
		}
		if length > plan.Size-offset {
			return plan, fmt.Errorf("partial record data at byte %d", offset)
		}
		if saved == nil {
			plan.Records = append(plan.Records, record{Offset: offset, Size: size, Original: raw})
		}
		report.Records++
		report.Bytes += 4
		report.DataBytes += length - 8
		if Magic(header[:4]) == opts.To {
			report.ConvertedRecords++
		}
		offset += length
		count++
	}
	if saved != nil && count != len(saved.Records) {
		return plan, errors.New("record count differs from the saved journal")
	}
	return plan, nil
}

func recordLength(name string, size uint32) (int64, error) {
	if name[:3] == "blk" {
		if size < 80 || size > 4_000_000 {
			return 0, fmt.Errorf("invalid block size %d", size)
		}
		return 8 + int64(size), nil
	}
	if size == 0 || size > 0x02000000 {
		return 0, fmt.Errorf("invalid undo size %d", size)
	}
	return 8 + int64(size) + 32, nil
}

func zeroTail(ctx context.Context, file *os.File, offset, end int64) (bool, error) {
	var data [64 * 1024]byte
	for offset < end {
		if err := ctx.Err(); err != nil {
			return false, err
		}
		count := min(int64(len(data)), end-offset)
		if _, err := file.ReadAt(data[:count], offset); err != nil {
			return false, err
		}
		if !allZero(data[:count]) {
			return false, nil
		}
		offset += count
	}
	return true, nil
}

func allZero(data []byte) bool {
	for _, value := range data {
		if value != 0 {
			return false
		}
	}
	return true
}

func xor(data []byte, key [8]byte, offset int64) {
	for i := range data {
		data[i] ^= key[(offset+int64(i))%int64(len(key))]
	}
}

func encodedMagic(magic Magic, key [8]byte, offset int64) Magic {
	xor(magic[:], key, offset)
	return magic
}

func validPartial(actual, from, to Magic) bool {
	for i := range actual {
		if actual[i] != from[i] && actual[i] != to[i] {
			return false
		}
	}
	return true
}

func progress(ctx context.Context, opts Options, report Report, stage, file string) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	if opts.Progress != nil {
		return opts.Progress(Progress{Stage: stage, File: file, Records: report.Records, ConvertedRecords: report.ConvertedRecords})
	}
	return nil
}

func convertFile(ctx context.Context, opts Options, plan *journal, item filePlan, report *Report) (err error) {
	file, err := openRegular(filepath.Join(opts.BlocksDir, item.Name), os.O_RDWR)
	if err != nil {
		return err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	for i, record := range item.Records {
		if err := ctx.Err(); err != nil {
			return err
		}
		var actual Magic
		if _, err := file.ReadAt(actual[:], record.Offset); err != nil {
			return err
		}
		target := encodedMagic(opts.To, plan.Key, record.Offset)
		if !validPartial(actual, record.Original, target) {
			return fmt.Errorf("unexpected magic in %s at byte %d", item.Name, record.Offset)
		}
		if actual != target {
			if _, err := file.WriteAt(target[:], record.Offset); err != nil {
				return err
			}
		}
		report.ConvertedRecords++
		if (i+1)%4096 == 0 {
			if err := progress(ctx, opts, *report, "convert", item.Name); err != nil {
				return err
			}
		}
	}
	if err := file.Sync(); err != nil {
		return err
	}
	for _, record := range item.Records {
		if err := ctx.Err(); err != nil {
			return err
		}
		var header [8]byte
		if _, err := file.ReadAt(header[:], record.Offset); err != nil {
			return err
		}
		xor(header[:], plan.Key, record.Offset)
		if Magic(header[:4]) != opts.To || binary.LittleEndian.Uint32(header[4:]) != record.Size {
			return fmt.Errorf("record check failed in %s at byte %d", item.Name, record.Offset)
		}
	}
	return progress(ctx, opts, *report, "convert", item.Name)
}
