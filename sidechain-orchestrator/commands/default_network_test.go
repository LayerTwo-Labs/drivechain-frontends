package commands

import (
	"testing"

	"github.com/urfave/cli/v2"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// The control CLI picks the paths that wipe deletes. A default of its own would
// let it stop the running daemon and erase another network's data.
func TestControlCLIDefaultsToTheSharedNetwork(t *testing.T) {
	for _, f := range GlobalFlags {
		sf, ok := f.(*cli.StringFlag)
		if !ok || sf.Name != "network" {
			continue
		}
		if sf.Value != config.DefaultNetwork {
			t.Fatalf("network flag defaults to %q, want the shared %q", sf.Value, config.DefaultNetwork)
		}
		return
	}
	t.Fatal("GlobalFlags carries no network flag")
}
