package blockfile

import (
	"crypto/sha256"
	"encoding/gob"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

func readJournal(path string) (plan *journal, err error) {
	file, err := openRegular(path, os.O_RDONLY)
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	defer func() { err = errors.Join(err, file.Close()) }()
	info, err := file.Stat()
	if err != nil {
		return nil, err
	}
	if info.Size() < sha256.Size {
		return nil, errors.New("conversion journal is incomplete")
	}
	length := info.Size() - sha256.Size
	var expected [sha256.Size]byte
	if _, err := file.ReadAt(expected[:], length); err != nil {
		return nil, err
	}
	hash := sha256.New()
	if _, err := io.Copy(hash, io.NewSectionReader(file, 0, length)); err != nil {
		return nil, err
	}
	if [sha256.Size]byte(hash.Sum(nil)) != expected {
		return nil, errors.New("conversion journal checksum differs")
	}
	plan = new(journal)
	decoder := gob.NewDecoder(io.NewSectionReader(file, 0, length))
	if err := decoder.Decode(plan); err != nil {
		return nil, fmt.Errorf("decode conversion journal: %w", err)
	}
	var extra journal
	if err := decoder.Decode(&extra); !errors.Is(err, io.EOF) {
		return nil, errors.Join(errors.New("conversion journal contains extra data"), err)
	}
	return plan, nil
}

func saveJournal(path string, plan *journal) (err error) {
	file, err := os.CreateTemp(filepath.Dir(path), ".magic-journal-*")
	if err != nil {
		return err
	}
	name := file.Name()
	closed := false
	keep := false
	defer func() {
		if !closed {
			err = errors.Join(err, file.Close())
		}
		if !keep {
			if removeErr := os.Remove(name); !errors.Is(removeErr, os.ErrNotExist) {
				err = errors.Join(err, removeErr)
			}
		}
	}()
	hash := sha256.New()
	if err := gob.NewEncoder(io.MultiWriter(file, hash)).Encode(plan); err != nil {
		return err
	}
	if _, err := file.Write(hash.Sum(nil)); err != nil {
		return err
	}
	if err := file.Sync(); err != nil {
		return err
	}
	closed = true
	if err := file.Close(); err != nil {
		return err
	}
	if err := moveJournal(name, path); err != nil {
		return err
	}
	keep = true
	return nil
}
