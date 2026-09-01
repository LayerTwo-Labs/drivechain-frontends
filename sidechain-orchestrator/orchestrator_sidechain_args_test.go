package orchestrator

import (
	"errors"
	"os"
	"slices"
	"strings"
	"testing"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

func thunderOrchestrator(t *testing.T, settings map[string]string) *Orchestrator {
	t.Helper()
	return thunderOrchestratorOn(t, config.NetworkSignet, settings)
}

// useTempHome points every conf path at a temp directory. A conf sync writes
// the file it reads, so without this a test overwrites the user's own conf.
func useTempHome(t *testing.T) {
	t.Helper()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir("") })
}

func thunderOrchestratorOn(t *testing.T, network config.Network, settings map[string]string) *Orchestrator {
	t.Helper()
	useTempHome(t)
	spec, ok := config.KnownSidechainSpecs["thunder"]
	if !ok {
		t.Fatal("thunder is missing from the known sidechain specs")
	}
	return &Orchestrator{
		log:     zerolog.Nop(),
		Network: string(network),
		SidechainConfs: map[string]*config.SidechainConfManager{
			"thunder": {
				Spec:        spec,
				Config:      &config.GenericAppConfig{Settings: settings},
				BitcoinConf: &config.BitcoinConfManager{Network: network},
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
		"--net-addr=0.0.0.0:4009",
		"--mainchain-grpc-url=http://localhost:50051",
		"--network=signet",
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

// chains_config.json calls the binary "Thunder", and the specs are keyed
// "thunder". A lookup on the raw name finds nothing and passes no flag at all.
func TestPrepareSidechainArgsFindsTheConfByDisplayName(t *testing.T) {
	orch := thunderOrchestrator(t, map[string]string{"net-addr": "0.0.0.0:4009"})

	var opts StartOpts
	orch.prepareSidechainArgs(BinaryConfig{Name: "Thunder", ChainLayer: 2}, &opts)

	if len(opts.TargetArgs) == 0 {
		t.Fatal("Thunder got no args; the conf lookup missed the display name")
	}
}

// BitNames and BitAssets read rpc-addr and a split mainchain host and port. The
// generic zmq template writes rpc-port and no mainchain field, so passing it
// would give the daemon an argv it cannot read.
func TestPrepareSidechainArgsLeavesTheZmqChainsAlone(t *testing.T) {
	useTempHome(t)
	for _, name := range []string{"bitnames", "bitassets"} {
		spec, ok := config.KnownSidechainSpecs[name]
		if !ok {
			t.Fatalf("%s is missing from the known sidechain specs", name)
		}
		orch := &Orchestrator{
			log: zerolog.Nop(),
			SidechainConfs: map[string]*config.SidechainConfManager{
				name: {
					Spec: spec,
					Config: &config.GenericAppConfig{Settings: map[string]string{
						"net-addr": "0.0.0.0:24002",
						"rpc-port": "26002",
						"network":  "mainnet",
					}},
				},
			},
		}
		var opts StartOpts
		orch.prepareSidechainArgs(BinaryConfig{Name: spec.Name, ChainLayer: 2}, &opts)
		if len(opts.TargetArgs) != 0 {
			t.Errorf("%s got args %v, want none", name, opts.TargetArgs)
		}
	}
}

// StartWithL1 returns on the immediate branch, so the args must exist before
// it. Without that order thunder starts on its default network.
func TestStartWithL1BuildsArgsBeforeTheImmediateBranch(t *testing.T) {
	src, err := os.ReadFile("orchestrator.go")
	if err != nil {
		t.Fatal(err)
	}
	body := string(src)
	prepare := strings.Index(body, "o.prepareSidechainArgs(config, &opts)")
	immediate := strings.Index(body, "if opts.Immediate {")
	if prepare < 0 || immediate < 0 {
		t.Fatal("could not find the start path")
	}
	if prepare > immediate {
		t.Error("prepareSidechainArgs runs after the immediate branch returns")
	}
}

// A reset restarts the daemon through startTargetOnly. Without the args that
// path starts the freshly reset thunder on its default network.
func TestResetRestartPreparesSidechainArgs(t *testing.T) {
	src, err := os.ReadFile("reset.go")
	if err != nil {
		t.Fatal(err)
	}
	body := string(src)
	prepare := strings.Index(body, "o.prepareSidechainArgs(cfg, &opts)")
	if prepare < 0 {
		t.Fatal("the reset path never prepares the sidechain args")
	}
	if start := strings.Index(body[prepare:], "o.startTargetOnly("); start < 0 {
		t.Error("the reset path prepares args after it starts the target")
	}
}

// Thunder has no mainnet. Nothing names a network there, and with no flag the
// daemon takes its own default and syncs a chain the mainchain never carries.
// The spawn stops instead.
func TestCheckSidechainNetworkArgStopsWithNoFlag(t *testing.T) {
	orch := thunderOrchestratorOn(t, config.NetworkMainnet, map[string]string{
		"net-addr": "0.0.0.0:4009",
	})
	cfg := BinaryConfig{Name: "thunder", ChainLayer: 2}

	var opts StartOpts
	orch.prepareSidechainArgs(cfg, &opts)

	if err := orch.checkSidechainNetworkArg(cfg, opts); !errors.Is(err, errSidechainNetworkUnknown) {
		t.Errorf("err = %v, want errSidechainNetworkUnknown", err)
	}
}

// A chain the daemon knows passes its own name, and the spawn goes ahead.
func TestCheckSidechainNetworkArgPassesAKnownNetwork(t *testing.T) {
	orch := thunderOrchestratorOn(t, config.NetworkSignet, map[string]string{
		"net-addr": "0.0.0.0:4009",
	})
	cfg := BinaryConfig{Name: "thunder", ChainLayer: 2}

	var opts StartOpts
	orch.prepareSidechainArgs(cfg, &opts)

	if err := orch.checkSidechainNetworkArg(cfg, opts); err != nil {
		t.Errorf("err = %v, want none", err)
	}
}

// A chain that names no CLI keys takes no flag, so the check never stops it.
func TestCheckSidechainNetworkArgSkipsTheOtherChains(t *testing.T) {
	orch := thunderOrchestratorOn(t, config.NetworkMainnet, map[string]string{})

	for _, cfg := range []BinaryConfig{
		{Name: "bitnames", ChainLayer: 2},
		{Name: "thunder", ChainLayer: 2, IsBitcoinCore: true},
		{Name: "bitcoind", ChainLayer: 1},
	} {
		if err := orch.checkSidechainNetworkArg(cfg, StartOpts{}); err != nil {
			t.Errorf("%s: err = %v, want none", cfg.Name, err)
		}
	}
}

// An earlier step can name the network itself. That flag reaches the daemon, so
// the launch path lets the daemon start.
func TestPrepareSidechainArgsAcceptsAnEarlierNetworkFlag(t *testing.T) {
	orch := thunderOrchestratorOn(t, config.NetworkMainnet, map[string]string{
		"net-addr": "0.0.0.0:4009",
		"network":  "signet",
	})

	opts := StartOpts{TargetArgs: []string{"--network=forknet"}}
	orch.prepareSidechainArgs(BinaryConfig{Name: "thunder", ChainLayer: 2}, &opts)

	if !hasCLIFlag(opts.TargetArgs, "--net-addr") {
		t.Errorf("args = %v, want the conf keys", opts.TargetArgs)
	}
}

// Every network the daemon knows must reach it as a flag. A silent fall back to
// the daemon's default runs the sidechain on a chain the mainchain does not
// carry, and no health check reports that.
func TestPrepareSidechainArgsPassesEveryKnownNetwork(t *testing.T) {
	for network, want := range map[config.Network]string{
		config.NetworkSignet:  "--network=signet",
		config.NetworkRegtest: "--network=regtest",
		config.NetworkForknet: "--network=forknet",
	} {
		orch := thunderOrchestratorOn(t, network, map[string]string{
			"net-addr": "0.0.0.0:4009",
			"network":  "signet",
		})

		var opts StartOpts
		orch.prepareSidechainArgs(BinaryConfig{Name: "thunder", ChainLayer: 2}, &opts)

		if !slices.Contains(opts.TargetArgs, want) {
			t.Errorf("thunder on %s: args = %v, want %s", network, opts.TargetArgs, want)
		}
	}
}

// NewSidechainConfManager can fail, and the constructor then leaves thunder out
// of the map. A start with no conf gives the daemon no flags at all.
func TestCheckSidechainNetworkArgStopsWithNoConfManager(t *testing.T) {
	orch := thunderOrchestratorOn(t, config.NetworkSignet, map[string]string{
		"net-addr": "0.0.0.0:4009",
	})
	orch.SidechainConfs = map[string]*config.SidechainConfManager{}
	cfg := BinaryConfig{Name: "thunder", ChainLayer: 2}

	var opts StartOpts
	orch.prepareSidechainArgs(cfg, &opts)

	if len(opts.TargetArgs) != 0 {
		t.Errorf("args = %v, want none", opts.TargetArgs)
	}
	if err := orch.checkSidechainNetworkArg(cfg, opts); !errors.Is(err, errSidechainNetworkUnknown) {
		t.Errorf("err = %v, want errSidechainNetworkUnknown", err)
	}
}

// A window, an adoption and a wait all start nothing. The check sits at the
// spawn alone, so none of them reports a missing flag.
func TestCheckSidechainNetworkArgGuardsTheSpawnAlone(t *testing.T) {
	src, err := os.ReadFile("orchestrator.go")
	if err != nil {
		t.Fatal(err)
	}
	body := string(src)
	check := strings.Index(body, "o.checkSidechainNetworkArg(config, opts)")
	spawn := strings.Index(body, `ch <- StartupProgress{Stage: "starting-" + config.Name`)
	adopt := strings.Index(body, "adopted externally-running target process")
	if check < 0 || spawn < 0 || adopt < 0 {
		t.Fatal("could not find the start path")
	}
	if check > spawn {
		t.Error("the check runs after the spawn")
	}
	if check < adopt {
		t.Error("the check runs before the adoption, so it stops a live daemon")
	}
}
