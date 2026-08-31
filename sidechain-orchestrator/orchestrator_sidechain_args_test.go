package orchestrator

import (
	"testing"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

func thunderOrchestrator(t *testing.T, settings map[string]string) *Orchestrator {
	t.Helper()
	spec, ok := config.KnownSidechainSpecs["thunder"]
	if !ok {
		t.Fatal("thunder is missing from the known sidechain specs")
	}
	return &Orchestrator{
		log: zerolog.Nop(),
		SidechainConfs: map[string]*config.SidechainConfManager{
			"thunder": {
				Spec:   spec,
				Config: &config.GenericAppConfig{Settings: settings},
			},
		},
	}
}

// The daemon reads its own datadir, never the conf the orchestrator writes. So
// the launch path has to pass net-addr, or the sidechain never listens for a
// peer and never syncs.
func TestPrepareSidechainArgsPassesTheConf(t *testing.T) {
	orch := thunderOrchestrator(t, map[string]string{
		"headless":           "true",
		"net-addr":           "0.0.0.0:4009",
		"rpc-addr":           "127.0.0.1:6009",
		"mainchain-grpc-url": "http://localhost:50051",
		"network":            "signet",
	})

	var opts StartOpts
	orch.prepareSidechainArgs(BinaryConfig{Name: "thunder", ChainLayer: 2}, &opts)

	want := []string{
		"--headless",
		"--mainchain-grpc-url=http://localhost:50051",
		"--net-addr=0.0.0.0:4009",
		"--rpc-addr=127.0.0.1:6009",
	}
	if len(opts.TargetArgs) != len(want) {
		t.Fatalf("args = %v, want %v", opts.TargetArgs, want)
	}
	for i, arg := range want {
		if opts.TargetArgs[i] != arg {
			t.Errorf("arg %d = %q, want %q", i, opts.TargetArgs[i], arg)
		}
	}
}

// A flag an earlier step set wins. Passing mainchain-grpc-url twice would undo
// the remote mainchain path, which points a sidechain away from localhost.
func TestPrepareSidechainArgsKeepsAnExistingFlag(t *testing.T) {
	orch := thunderOrchestrator(t, map[string]string{
		"mainchain-grpc-url": "http://localhost:50051",
		"net-addr":           "0.0.0.0:4009",
	})

	opts := StartOpts{TargetArgs: []string{"--mainchain-grpc-url=https://remote.example/grpc"}}
	orch.prepareSidechainArgs(BinaryConfig{Name: "thunder", ChainLayer: 2}, &opts)

	var seen int
	for _, arg := range opts.TargetArgs {
		if len(arg) >= 21 && arg[:21] == "--mainchain-grpc-url=" {
			seen++
			if arg != "--mainchain-grpc-url=https://remote.example/grpc" {
				t.Errorf("kept %q, want the remote value", arg)
			}
		}
	}
	if seen != 1 {
		t.Errorf("passed mainchain-grpc-url %d times, want 1", seen)
	}
}

// Core exits on an unknown option, so a Core derived sidechain takes none of
// these flags.
func TestPrepareSidechainArgsSkipsCoreAndLayerOne(t *testing.T) {
	orch := thunderOrchestrator(t, map[string]string{"net-addr": "0.0.0.0:4009"})

	for _, cfg := range []BinaryConfig{
		{Name: "thunder", ChainLayer: 2, IsBitcoinCore: true},
		{Name: "thunder", ChainLayer: 1},
	} {
		var opts StartOpts
		orch.prepareSidechainArgs(cfg, &opts)
		if len(opts.TargetArgs) != 0 {
			t.Errorf("%+v got args %v, want none", cfg, opts.TargetArgs)
		}
	}
}

func TestHasCLIFlagMatchesOnName(t *testing.T) {
	args := []string{"--headless", "--net-addr=0.0.0.0:4009"}
	for _, arg := range []string{"--net-addr=1.2.3.4:1", "--headless"} {
		if !hasCLIFlag(args, arg) {
			t.Errorf("hasCLIFlag(%q) = false, want true", arg)
		}
	}
	if hasCLIFlag(args, "--rpc-addr=127.0.0.1:6009") {
		t.Error("hasCLIFlag reported a flag that is not there")
	}
}
