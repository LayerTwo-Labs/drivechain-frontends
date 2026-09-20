package stratum

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

const (
	// bucketSpan is the resolution the history keeps on disk. Every range
	// reads from these buckets.
	bucketSpan = time.Minute
	// historySpan is how far back the history goes.
	historySpan = 7 * 24 * time.Hour
	maxBuckets  = int(historySpan / bucketSpan)
)

// Range is a span of the hashrate history and the width of its buckets.
type Range struct {
	Span   time.Duration
	Bucket time.Duration
}

var (
	RangeHour = Range{Span: time.Hour, Bucket: time.Minute}
	RangeDay  = Range{Span: 24 * time.Hour, Bucket: 10 * time.Minute}
	RangeWeek = Range{Span: historySpan, Bucket: time.Hour}
)

// Point is the hashrate of all miners together over one bucket.
type Point struct {
	At       time.Time `json:"at"`
	Hashrate float64   `json:"hashrate"`
}

// History keeps the total hashrate in one-minute buckets for seven days. It
// writes every bucket to a file, so a restart keeps the chart.
type History struct {
	path string

	mu      sync.Mutex
	buckets []Point
	sum     float64
	samples int
	current time.Time
}

// NewHistory reads the buckets at path. A file that does not read starts an
// empty history.
func NewHistory(path string) *History {
	h := &History{path: path}
	h.mu.Lock()
	h.loadLocked()
	h.mu.Unlock()
	return h
}

// loadLocked reads the buckets of the file. A file that is missing or that
// does not decode means no history, which is a state and not a failure.
func (h *History) loadLocked() {
	raw, err := os.ReadFile(h.path) //nolint:gosec // the caller names the file
	if err != nil {
		return
	}
	var buckets []Point
	if err := json.Unmarshal(raw, &buckets); err != nil {
		return
	}
	h.buckets = trim(buckets, time.Now())
}

// Record adds one reading. The bucket it falls in holds the mean of its
// readings.
func (h *History) Record(hashrate float64, now time.Time) {
	h.mu.Lock()
	defer h.mu.Unlock()
	start := now.Truncate(bucketSpan)
	if !start.Equal(h.current) {
		h.closeBucketLocked()
		h.current = start
	}
	h.sum += hashrate
	h.samples++
}

// closeBucketLocked stores the mean of the open bucket.
func (h *History) closeBucketLocked() {
	if h.samples == 0 {
		return
	}
	h.buckets = append(h.buckets, Point{At: h.current, Hashrate: h.sum / float64(h.samples)})
	if len(h.buckets) > maxBuckets {
		h.buckets = h.buckets[len(h.buckets)-maxBuckets:]
	}
	h.sum, h.samples = 0, 0
}

// Flush closes the open bucket and writes every bucket to the file. The path
// comes from the same lock as the buckets, so a network switch never writes
// the buckets of the chain that ran before to the file of the one that runs.
func (h *History) Flush(now time.Time) error {
	h.mu.Lock()
	if h.samples > 0 && now.Sub(h.current) >= bucketSpan {
		h.closeBucketLocked()
	}
	h.buckets = trim(h.buckets, now)
	raw, err := json.Marshal(h.buckets)
	path := h.path
	h.mu.Unlock()
	if err != nil {
		return fmt.Errorf("encode the hashrate history: %w", err)
	}
	if path == "" {
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return fmt.Errorf("make the history directory: %w", err)
	}
	if err := os.WriteFile(path, raw, 0o644); err != nil {
		return fmt.Errorf("write the hashrate history: %w", err)
	}
	return nil
}

// Read returns one point per bucket of r, oldest first, and the peak of the
// range. A bucket with no reading reads zero.
func (h *History) Read(r Range, now time.Time) (points []Point, peak float64) {
	h.mu.Lock()
	stored := append([]Point(nil), h.buckets...)
	if h.samples > 0 {
		stored = append(stored, Point{At: h.current, Hashrate: h.sum / float64(h.samples)})
	}
	h.mu.Unlock()

	last := now.Truncate(r.Bucket)
	count := int(r.Span / r.Bucket)
	first := last.Add(-time.Duration(count-1) * r.Bucket)

	sums := make([]float64, count)
	counts := make([]int, count)
	for _, p := range stored {
		if p.At.Before(first) || p.At.After(last.Add(r.Bucket)) {
			continue
		}
		i := int(p.At.Sub(first) / r.Bucket)
		if i < 0 || i >= count {
			continue
		}
		sums[i] += p.Hashrate
		counts[i]++
	}

	points = make([]Point, count)
	for i := range points {
		points[i] = Point{At: first.Add(time.Duration(i) * r.Bucket)}
		if counts[i] > 0 {
			points[i].Hashrate = sums[i] / float64(counts[i])
		}
		peak = max(peak, points[i].Hashrate)
	}
	return points, peak
}

// Rebind points the history at the file of the network that runs now, and
// reads what that network already recorded. The file of the network that ran
// before stays where it is.
func (h *History) Rebind(path string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.buckets, h.sum, h.samples = nil, 0, 0
	h.current = time.Time{}
	h.path = path
	h.loadLocked()
}

func trim(buckets []Point, now time.Time) []Point {
	cutoff := now.Add(-historySpan)
	i := 0
	for i < len(buckets) && buckets[i].At.Before(cutoff) {
		i++
	}
	return buckets[i:]
}
