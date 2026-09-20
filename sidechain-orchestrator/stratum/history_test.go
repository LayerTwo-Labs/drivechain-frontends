package stratum

import (
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestHistoryBucketsRollOver(t *testing.T) {
	now := time.Unix(1_800_000_000, 0).UTC()
	h := NewHistory(filepath.Join(t.TempDir(), "hashrate.json"))

	// Two readings in one minute give the bucket their mean.
	h.Record(100, now)
	h.Record(300, now.Add(20*time.Second))
	// The next minute opens a bucket of its own.
	h.Record(700, now.Add(time.Minute))
	require.NoError(t, h.Flush(now.Add(2*time.Minute)))

	points, peak := h.Read(RangeHour, now.Add(time.Minute))
	require.Len(t, points, 60)
	assert.Equal(t, 700.0, peak)
	assert.Equal(t, 200.0, points[58].Hashrate)
	assert.Equal(t, 700.0, points[59].Hashrate)
	assert.Zero(t, points[0].Hashrate)

	t.Run("a day reads ten minute buckets", func(t *testing.T) {
		points, peak := h.Read(RangeDay, now.Add(time.Minute))
		require.Len(t, points, 144)
		assert.Equal(t, 450.0, peak)
		assert.Equal(t, 450.0, points[143].Hashrate)
	})

	t.Run("a week reads one hour buckets", func(t *testing.T) {
		points, _ := h.Read(RangeWeek, now.Add(time.Minute))
		require.Len(t, points, 168)
		assert.Equal(t, 450.0, points[167].Hashrate)
	})
}

func TestHistorySurvivesARestart(t *testing.T) {
	path := filepath.Join(t.TempDir(), "hashrate.json")
	now := time.Unix(1_800_000_000, 0).UTC()

	first := NewHistory(path)
	first.Record(1200, now)
	require.NoError(t, first.Flush(now.Add(2*time.Minute)))

	second := NewHistory(path)
	points, peak := second.Read(RangeHour, now)
	assert.Equal(t, 1200.0, peak)
	assert.Equal(t, 1200.0, points[59].Hashrate)

	t.Run("a rebind reads what the other network recorded", func(t *testing.T) {
		other := filepath.Join(t.TempDir(), "hashrate.json")
		elsewhere := NewHistory(other)
		elsewhere.Record(700, now)
		require.NoError(t, elsewhere.Flush(now.Add(2*time.Minute)))

		second.Rebind(other)
		_, peak := second.Read(RangeHour, now)
		assert.Equal(t, 700.0, peak)

		// The network that ran before keeps its own file.
		second.Rebind(path)
		_, peak = second.Read(RangeHour, now)
		assert.Equal(t, 1200.0, peak)
	})

	t.Run("a rebind to a network with no history starts empty", func(t *testing.T) {
		second.Rebind(filepath.Join(t.TempDir(), "hashrate.json"))
		_, peak := second.Read(RangeHour, now)
		assert.Zero(t, peak)
	})
}

// A bucket older than the span leaves the history.
func TestHistoryDropsOldBuckets(t *testing.T) {
	now := time.Unix(1_800_000_000, 0).UTC()
	h := NewHistory(filepath.Join(t.TempDir(), "hashrate.json"))
	h.Record(500, now.Add(-8*24*time.Hour))
	h.Record(900, now)
	require.NoError(t, h.Flush(now.Add(time.Minute)))

	_, peak := h.Read(RangeWeek, now)
	assert.Equal(t, 900.0, peak)
	assert.Len(t, h.buckets, 1)
}
