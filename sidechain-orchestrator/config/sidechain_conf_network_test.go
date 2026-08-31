package config

import (
	"path/filepath"
	"slices"
	"strings"
	"testing"

	"github.com/rs/zerolog"
)

func sidechainConfFor(t *testing.T, name string, network Network, settings map[string]string) *SidechainConfManager {
	t.Helper()
	spec, ok := KnownSidechainSpecs[name]
	if !ok {
		t.Fatalf("%s is missing from the known sidechain specs", name)
	}
	return &SidechainConfManager{
		Spec:        spec,
		Config:      &GenericAppConfig{Settings: settings},
		bitcoinConf: &BitcoinConfManager{Network: network, log: zerolog.Nop()},
		log:         zerolog.Nop(),
	}
}

// Thunder knows alphanet, signet, regtest and forknet. It knows no mainnet, so
// a mainnet box gets no flag rather than a name that makes clap exit.
func TestCusfNetworkName(t *testing.T) {
	for network, want := range map[Network]string{
		NetworkRegtest: "regtest",
		NetworkForknet: "forknet",
		NetworkECash:   "alphanet",
		NetworkSignet:  "signet",
		NetworkMainnet: "",
		NetworkTestnet: "",
	} {
		if got := CusfNetworkName(network, "alphanet"); got != want {
			t.Errorf("CusfNetworkName(%q) = %q, want %q", network, got, want)
		}
	}
}

// eCash carries a generation. drynet4 runs its own thunder build with its own
// magic, and the daemon's enum has no name for it, so it takes no flag.
func TestCusfNetworkNameWithholdsAnUnknownECashGeneration(t *testing.T) {
	for _, id := range []string{"drynet4", "drynet3", ""} {
		if got := CusfNetworkName(NetworkECash, id); got != "" {
			t.Errorf("CusfNetworkName(ecash, %q) = %q, want no name", id, got)
		}
	}
	if got := CusfNetworkName(NetworkECash, "alphanet"); got != "alphanet" {
		t.Errorf("CusfNetworkName(ecash, alphanet) = %q, want alphanet", got)
	}
}

// The conf on an eCash box says network=mainnet, because that value picks the
// +20000 port group. Thunder has no mainnet, so passing that value stops the
// daemon at once. The flag must carry the daemon's own name instead.
func TestGetCliArgsGivesThunderTheDaemonNetworkName(t *testing.T) {
	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr": "0.0.0.0:24009",
		"network":  "mainnet",
	})

	args := m.GetCliArgs()

	// The embedded catalog picks the generation, so read the name it gives.
	want := CusfNetworkName(NetworkECash, ECashNetworkID())
	if want != "" && !slices.Contains(args, "--network="+want) {
		t.Errorf("args = %v, want --network=%s", args, want)
	}
	if slices.Contains(args, "--network=mainnet") {
		t.Errorf("args = %v, passed the port group as a network name", args)
	}
	if !slices.Contains(args, "--net-addr=0.0.0.0:24009") {
		t.Errorf("args = %v, want the conf net-addr", args)
	}
}

// A signet box keeps the signet name, and the port group value never doubles
// as the flag.
func TestGetCliArgsPassesNetworkOnce(t *testing.T) {
	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr": "0.0.0.0:4009",
		"network":  "signet",
	})

	var seen int
	for _, arg := range m.GetCliArgs() {
		if len(arg) >= 10 && arg[:10] == "--network=" {
			seen++
		}
	}
	if seen != 1 {
		t.Errorf("passed --network %d times, want 1", seen)
	}
}

// Only thunder names CLI keys. The generic template writes flags the other
// daemons do not know, so it must never reach them.
func TestOnlyThunderNamesCliArgKeys(t *testing.T) {
	for name, spec := range KnownSidechainSpecs {
		if len(spec.CliArgKeys) > 0 && name != "thunder" {
			t.Errorf("%s names CLI keys, but its flags are not checked", name)
		}
	}
	if len(KnownSidechainSpecs["thunder"].CliArgKeys) == 0 {
		t.Error("thunder must name its CLI keys")
	}
}

// BinaryConfig.Port is a fixed 6009, and NewHealthChecker polls it. A conf
// rpc-addr of 16009 or 26009 would leave the health check on a dead port.
func TestThunderNeverPassesTheRpcPort(t *testing.T) {
	for _, key := range KnownSidechainSpecs["thunder"].CliArgKeys {
		if key == "rpc-addr" || key == "rpc-port" {
			t.Errorf("thunder passes %q, which hides it from the health check", key)
		}
	}
	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr": "0.0.0.0:24009",
		"rpc-addr": "127.0.0.1:26009",
	})
	for _, arg := range m.GetCliArgs() {
		if strings.HasPrefix(arg, "--rpc-addr") {
			t.Errorf("args carry %q, want no rpc flag", arg)
		}
	}
}

// A chain with no proof takes no network flag, because a daemon stops on an
// option it does not know.
func TestGetCliArgsWithholdsNetworkFromUnprovedChains(t *testing.T) {
	for _, name := range []string{"bitnames", "bitassets", "zside", "photon", "truthcoin", "coinshift", "liquid-signet"} {
		m := sidechainConfFor(t, name, NetworkECash, map[string]string{
			"net-addr": "0.0.0.0:24009",
			"network":  "mainnet",
		})
		for _, arg := range m.GetCliArgs() {
			if len(arg) >= 10 && arg[:10] == "--network=" {
				t.Errorf("%s got %q, want no network flag", name, arg)
			}
		}
	}
}

// The eCash and forknet boxes both keep the +20000 port group. The daemon name
// changes; the ports do not.
func TestNetworkFlagLeavesThePortGroupAlone(t *testing.T) {
	for _, network := range []Network{NetworkECash, NetworkForknet} {
		m := sidechainConfFor(t, "thunder", network, nil)
		if got := m.resolveNetwork(); got != "mainnet" {
			t.Errorf("resolveNetwork() on %q = %q, want mainnet", network, got)
		}
		if got := m.getNetworkPorts("mainnet")["net-addr"]; got != "0.0.0.0:24009" {
			t.Errorf("net-addr on %q = %q, want 0.0.0.0:24009", network, got)
		}
	}
}

func TestSidechainConfByName(t *testing.T) {
	confs := map[string]*SidechainConfManager{
		"thunder":       {Spec: KnownSidechainSpecs["thunder"]},
		"liquid-signet": {Spec: KnownSidechainSpecs["liquid-signet"]},
	}
	for _, name := range []string{"Thunder", "thunder", "THUNDER"} {
		if SidechainConfByName(confs, name) == nil {
			t.Errorf("SidechainConfByName(%q) = nil, want the thunder conf", name)
		}
	}
	if SidechainConfByName(confs, "Liquid Signet") == nil {
		t.Error("a display name with a space found no conf")
	}
	if SidechainConfByName(confs, "bitnames") != nil {
		t.Error("SidechainConfByName invented a conf that is not there")
	}
}

// A network swap reloads BitcoinConf alone. Without a resync the args would
// carry the new network and the ports of the network the node just left.
func TestSyncNetworkRealignsThePortsAfterASwap(t *testing.T) {
	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr":           "0.0.0.0:4009",
		"mainchain-grpc-url": "http://localhost:50051",
		"network":            "signet",
	})
	m.ConfigPath = filepath.Join(t.TempDir(), "thunder.conf")

	m.bitcoinConf.Network = NetworkRegtest
	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatal(err)
	}

	args := m.GetCliArgs()
	if !slices.Contains(args, "--network=regtest") {
		t.Errorf("args = %v, want --network=regtest", args)
	}
	if !slices.Contains(args, "--net-addr=0.0.0.0:14009") {
		t.Errorf("args = %v, want the regtest net-addr", args)
	}
	if slices.Contains(args, "--net-addr=0.0.0.0:4009") {
		t.Errorf("args = %v, still carry the signet port", args)
	}
}
