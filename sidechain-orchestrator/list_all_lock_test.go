package orchestrator

import (
	"testing"
	"time"
)

// TestListAllDuringConfigReload guards against a recursive-RLock deadlock:
// ListAll must not hold o.mu while Status→getConfig re-acquires it, or a
// queued UpdateConfigs writer (config file watcher) wedges both forever.
func TestListAllDuringConfigReload(t *testing.T) {
	cfgs := AllDefaults()
	for i := range cfgs {
		cfgs[i].Port = 0 // skip Status's port probe so iterations stay fast
	}
	o := New(t.TempDir(), "signet", t.TempDir(), cfgs, testLogger(t))

	done := make(chan struct{})
	go func() {
		defer close(done)
		for range 5000 {
			o.ListAll()
		}
	}()
	stop := make(chan struct{})
	defer close(stop)
	go func() {
		for {
			select {
			case <-stop:
				return
			default:
				o.UpdateConfigs(cfgs)
			}
		}
	}()

	select {
	case <-done:
	case <-time.After(60 * time.Second):
		t.Fatal("ListAll deadlocked against UpdateConfigs")
	}
}
