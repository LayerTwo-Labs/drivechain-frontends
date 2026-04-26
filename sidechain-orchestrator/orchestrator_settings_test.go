package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSettingsStore_UseTestSidechains_RoundTrip(t *testing.T) {
	dir := t.TempDir()

	s, err := NewSettingsStore(dir)
	require.NoError(t, err)
	assert.False(t, s.UseTestSidechains(), "default must be off")

	prev, err := s.SetUseTestSidechains(true)
	require.NoError(t, err)
	assert.False(t, prev)
	assert.True(t, s.UseTestSidechains())

	// Persisted across reload.
	s2, err := NewSettingsStore(dir)
	require.NoError(t, err)
	assert.True(t, s2.UseTestSidechains())

	// CoreVariant default still intact: the new field doesn't trash old fields.
	assert.Equal(t, DefaultCoreVariantID, s2.CoreVariant())

	// Same-value set is a no-op.
	prev, err = s2.SetUseTestSidechains(true)
	require.NoError(t, err)
	assert.True(t, prev)

	// Toggle back off.
	prev, err = s2.SetUseTestSidechains(false)
	require.NoError(t, err)
	assert.True(t, prev)
	assert.False(t, s2.UseTestSidechains())
}
