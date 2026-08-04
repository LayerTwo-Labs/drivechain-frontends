package wallet

import (
	"crypto/rand"
	"crypto/sha512"
	"encoding/binary"
	"errors"
	"fmt"
	"hash"
	"time"
)

// Strength is the entropy size a BIP39 mnemonic is built from.
type Strength int

const (
	// Strength128 is 16 bytes of entropy, which is 12 words.
	Strength128 Strength = 128
	// Strength256 is 32 bytes of entropy, which is 24 words.
	Strength256 Strength = 256
)

// Bytes is the entropy length this strength needs.
func (s Strength) Bytes() int { return int(s) / 8 }

// FreshEntropy returns entropy of the given strength from crypto/rand, mixed
// with timings as Core does: https://github.com/bitcoin/bitcoin/blob/1ed14c6/src/random.cpp#L607
func FreshEntropy(s Strength) ([]byte, error) {

	switch s {
	case Strength128, Strength256:
	default:
		return nil, fmt.Errorf("unsupported entropy strength %d; 128 or 256 required", int(s))
	}

	hasher := sha512.New()

	buffer := make([]byte, 32)
	_, err := rand.Read(buffer)
	if err != nil {
		// rand.Read never returns an error: it panics the process if the OS fails.
		// the err check is kept for good measure, just in case this is copied into
		// an older go-version
		panic(fmt.Errorf("failed to read entropy: %w", err))
	}
	hasher.Write(buffer)

	strengthen(hasher.Sum(nil), 100*time.Millisecond, hasher)

	return hasher.Sum(nil)[:s.Bytes()], nil
}

// strengthen runs for dur and adds a clock reading to the hasher after each
// batch. The readings are all it contributes: https://github.com/bitcoin/bitcoin/blob/1ed14c6/src/random.cpp#L235
func strengthen(seed []byte, dur time.Duration, hasher hash.Hash) {
	digest := sha512.Sum512(seed)

	stop := time.Now().Add(dur)
	for {
		// Burn time so the clock reading below is unpredictable
		for i := 0; i < 1000; i++ {
			digest = sha512.Sum512(digest[:])
		}

		now := time.Now()
		writeUint64(hasher, uint64(now.UnixNano()))
		if !now.Before(stop) {
			break
		}
	}

	hasher.Write(digest[:])
}

// SanityCheck tests that crypto/rand writes every byte position and that the
// clock advances. https://github.com/bitcoin/bitcoin/blob/1ed14c6/src/random.cpp#L641
func SanityCheck() error {
	start := time.Now()
	overwritten := make([]bool, 32)

	for try := 0; try < 1024; try++ {
		buffer := make([]byte, 32)
		_, err := rand.Read(buffer)
		if err != nil {
			// rand.Read never returns an error: it panics the process if the OS fails.
			// the err check is kept for good measure, just in case this is copied into
			// an older go-version
			panic(fmt.Errorf("failed to read entropy: %w", err))
		}

		remaining := 0
		for i, b := range buffer {
			if b != 0 {
				overwritten[i] = true
			}
			if !overwritten[i] {
				remaining++
			}
		}
		if remaining == 0 {
			break
		}
	}

	for i, ok := range overwritten {
		if !ok {
			return fmt.Errorf("crypto/rand never wrote byte %d", i)
		}
	}

	// Sleep first: the draws above take microseconds, and a Windows clock tick
	// is ~15ms, so both readings would otherwise be the same.
	time.Sleep(time.Millisecond)
	if !time.Now().After(start) {
		return errors.New("the clock does not advance")
	}
	return nil
}

func writeUint64(hasher hash.Hash, value uint64) {
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], value)
	hasher.Write(buf[:])
}
