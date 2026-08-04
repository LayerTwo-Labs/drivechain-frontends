package wallet

import (
	"bytes"
	"crypto/sha512"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFreshEntropySizes(t *testing.T) {
	t.Parallel()

	for strength, size := range map[Strength]int{Strength128: 16, Strength256: 32} {
		out, err := FreshEntropy(strength)
		require.NoError(t, err)
		assert.Len(t, out, size)
		assert.Equal(t, size, strength.Bytes())
	}
}

func TestFreshEntropyRejectsUnknownStrength(t *testing.T) {
	t.Parallel()

	for _, s := range []Strength{0, 64, 127, 160, 512} {
		_, err := FreshEntropy(s)
		require.Error(t, err, "strength=%d", int(s))
	}
}

func TestFreshEntropyNeverRepeats(t *testing.T) {
	t.Parallel()

	seen := make(map[string]struct{}, 20)
	for i := 0; i < 20; i++ {
		out, err := FreshEntropy(Strength256)
		require.NoError(t, err)
		require.False(t, bytes.Equal(out, make([]byte, 32)), "entropy must not be all zeroes")

		_, dup := seen[string(out)]
		require.False(t, dup, "repeated entropy on draw %d", i)
		seen[string(out)] = struct{}{}
	}
}

// The extra sources must not flatten the output. A byte-value histogram over a
// large sample should cover most of the range.
func TestFreshEntropyLooksUniform(t *testing.T) {
	t.Parallel()

	counts := make(map[byte]int)
	for i := 0; i < 60; i++ {
		out, err := FreshEntropy(Strength256)
		require.NoError(t, err)
		for _, b := range out {
			counts[b]++
		}
	}

	assert.Greater(t, len(counts), 240, "byte values should span nearly the whole range")
}

func TestSanityCheckPasses(t *testing.T) {
	t.Parallel()

	require.NoError(t, SanityCheck())
}

// The timings drive the output, so two runs on the same seed must differ.
func TestStrengthenVariesBetweenRuns(t *testing.T) {
	t.Parallel()

	seed := make([]byte, 32)
	run := func() []byte {
		hasher := sha512.New()
		strengthen(seed, time.Millisecond, hasher)
		return hasher.Sum(nil)
	}

	assert.NotEqual(t, run(), run())
}
