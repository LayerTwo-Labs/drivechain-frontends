package orchestrator

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/rs/zerolog"
)

func catalogWithDrynet(t *testing.T, id string) netcatalog.Catalog {
	t.Helper()
	c, _ := netcatalog.Load(t.TempDir())
	for i := range c.Networks {
		if c.Networks[i].Family == netcatalog.FamilyECash {
			c.Networks[i].ID = id
		}
	}
	return c
}

// The cache must always describe the data on disk. A promotion that cannot
// wipe has to leave both the cache and the served generation alone, or the
// next start trusts a rollover that never happened.
func TestPendingNotPromotedWhenWipeCannotRun(t *testing.T) {
	dir := t.TempDir()
	current := catalogWithDrynet(t, "drynet2")
	pending := catalogWithDrynet(t, "drynet3")
	if err := netcatalog.SavePending(dir, pending); err != nil {
		t.Fatal(err)
	}

	// No BitcoinConf, so the wipe cannot run.
	o := &Orchestrator{BitwindowDir: dir, log: zerolog.Nop()}
	got := o.promotePendingCatalog(current, pending, true)

	if got.DrynetID() != "drynet2" {
		t.Errorf("served generation = %q, want the unchanged drynet2", got.DrynetID())
	}
	if _, ok := netcatalog.LoadPending(dir); !ok {
		t.Error("pending catalog must survive so the next start retries")
	}
	if cached, fromDisk := netcatalog.Load(dir); fromDisk && cached.DrynetID() == "drynet3" {
		t.Error("cache must not record a generation whose data was never wiped")
	}
}

// An unchanged generation clears any stale pending file rather than leaving it
// to be re-applied forever.
func TestPromotionIsANoOpForTheSameGeneration(t *testing.T) {
	dir := t.TempDir()
	same := catalogWithDrynet(t, "drynet2")

	o := &Orchestrator{BitwindowDir: dir, log: zerolog.Nop()}
	got := o.promotePendingCatalog(same, same, true)
	if got.DrynetID() != "drynet2" {
		t.Errorf("generation = %q, want drynet2", got.DrynetID())
	}
}
