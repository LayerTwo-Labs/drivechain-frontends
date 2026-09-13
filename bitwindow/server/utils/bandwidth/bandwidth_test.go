package bandwidth

import (
	"os"
	"sync"
	"testing"
)

// GetStats is called from concurrent gRPC handlers, so it must be race-free.
func TestGetStatsConcurrent(t *testing.T) {
	tracker := NewTracker()
	pid := os.Getpid()

	var wg sync.WaitGroup
	for i := 0; i < 8; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 20; j++ {
				stats, err := tracker.GetStats(pid, "test")
				if err != nil {
					// Platform may not expose per-process stats; only races matter here.
					continue
				}
				if stats.PID != pid {
					t.Errorf("got PID %d, want %d", stats.PID, pid)
					return
				}
			}
		}()
	}
	wg.Wait()
}
