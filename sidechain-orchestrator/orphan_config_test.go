package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestFindOrphanConfigPrefersExactNames(t *testing.T) {
	o := &Orchestrator{configs: map[string]BinaryConfig{
		"thunder": {Name: "thunder", BinaryName: "thunder"},
		"zside":   {Name: "zside", BinaryName: "thunder-orchard"},
	}}
	for range 100 {
		for _, test := range []struct{ binary, name string }{
			{binary: "THUNDER", name: "thunder"},
			{binary: "THUNDER-ORCHARD", name: "zside"},
			{binary: "zSide", name: "zside"},
			{binary: "thunder_app", name: "thunder"},
		} {
			cfg, found := o.findConfigByBinaryName(test.binary)
			require.True(t, found)
			require.Equal(t, test.name, cfg.Name, test.binary)
		}
	}
}
