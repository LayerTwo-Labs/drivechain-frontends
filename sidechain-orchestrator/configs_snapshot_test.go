package orchestrator

import (
	"testing"
	"time"
)

// TestConfigsSnapshotDuringConfigReload guards against handing out the live
// config map: a reader ranging over it while the config file watcher runs
// UpdateConfigs trips Go's fatal "concurrent map iteration and map write",
// which no recover() catches.
func TestConfigsSnapshotDuringConfigReload(t *testing.T) {
	cfgs := []BinaryConfig{
		{Name: "bitcoind", Port: 38332},
		{Name: "enforcer", Port: 50051},
		{Name: "thunder", Port: 6009},
	}
	o := &Orchestrator{configs: map[string]BinaryConfig{}}
	o.UpdateConfigs(cfgs)

	done := make(chan struct{})
	go func() {
		defer close(done)
		for range 5000 {
			for _, c := range o.Configs() {
				_ = c.Port
			}
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
		t.Fatal("Configs reader wedged against UpdateConfigs")
	}
}
