package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEnvUintUnsetReturnsFallback(t *testing.T) {
	n, err := envUint("COINNEWS_TEST_HEIGHT", 963648)
	require.NoError(t, err)
	assert.Equal(t, uint64(963648), n)
}

func TestEnvUintReadsValue(t *testing.T) {
	t.Setenv("COINNEWS_TEST_HEIGHT", "963648")
	n, err := envUint("COINNEWS_TEST_HEIGHT", 0)
	require.NoError(t, err)
	assert.Equal(t, uint64(963648), n)
}

// A set-but-unparsable value must never fall back to 0 — that silently sends
// the scanner to genesis, which is what the setting exists to avoid.
func TestEnvUintRejectsInvalidValues(t *testing.T) {
	for _, v := range []string{"96364a", "-1", "4294967296", "", " 963648", "963_648", "1.5"} {
		t.Run(v, func(t *testing.T) {
			t.Setenv("COINNEWS_TEST_HEIGHT", v)
			_, err := envUint("COINNEWS_TEST_HEIGHT", 963648)
			require.Error(t, err)
			assert.Contains(t, err.Error(), "COINNEWS_TEST_HEIGHT")
		})
	}
}

func TestEnvUintAcceptsMaxUint32(t *testing.T) {
	t.Setenv("COINNEWS_TEST_HEIGHT", "4294967295")
	n, err := envUint("COINNEWS_TEST_HEIGHT", 0)
	require.NoError(t, err)
	assert.Equal(t, uint64(4294967295), n)
}
