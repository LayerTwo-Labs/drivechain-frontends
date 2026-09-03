package config

import (
	"os"
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
		BitcoinConf: &BitcoinConfManager{Network: network, log: zerolog.Nop()},
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

// An eCash box runs the +20000 port group, which the old conf called
// "mainnet". Thunder has no mainnet, so the flag carries the daemon's own name.
func TestGetCliArgsGivesThunderTheDaemonNetworkName(t *testing.T) {
	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr": "0.0.0.0:24009",
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

// A signet box passes the signet name exactly one time.
func TestGetCliArgsPassesNetworkOnce(t *testing.T) {
	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr": "0.0.0.0:4009",
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
		})
		for _, arg := range m.GetCliArgs() {
			if len(arg) >= 10 && arg[:10] == "--network=" {
				t.Errorf("%s got %q, want no network flag", name, arg)
			}
		}
	}
}

// Every network reads its own port group, and the live chain reads the base
// port a daemon listens on with no arguments.
func TestEachNetworkReadsItsOwnPortGroup(t *testing.T) {
	for _, test := range []struct {
		network Network
		group   string
		rpcAddr string
		netAddr string
	}{
		{NetworkECash, "ecash", "127.0.0.1:6009", "0.0.0.0:4009"},
		{NetworkRegtest, "regtest", "127.0.0.1:16009", "0.0.0.0:14009"},
		{NetworkSignet, "signet", "127.0.0.1:36009", "0.0.0.0:34009"},
	} {
		m := sidechainConfFor(t, "thunder", test.network, nil)
		if got := m.resolveNetwork(); got != test.group {
			t.Errorf("resolveNetwork() on %q = %q, want %q", test.network, got, test.group)
		}
		ports := m.getNetworkPorts(test.group)
		if got := ports["net-addr"]; got != test.netAddr {
			t.Errorf("net-addr on %q = %q, want %q", test.network, got, test.netAddr)
		}
		if got := ports["rpc-addr"]; got != test.rpcAddr {
			t.Errorf("rpc-addr on %q = %q, want %q", test.network, got, test.rpcAddr)
		}
	}
}

// The offsets copy the ones Bitcoin Core gives its own chains, so a reader who
// knows 8332 and 18332 can guess these.
func TestPortOffsetsFollowBitcoinCore(t *testing.T) {
	for group, want := range map[string]int{
		"ecash":   0,
		"regtest": 10000,
		"signet":  30000,
	} {
		if got := networkPortOffset(group); got != want {
			t.Errorf("networkPortOffset(%q) = %d, want %d", group, got, want)
		}
	}
}

// A node made before the live chain took the base port holds the retired
// +20000 value. The next sync moves it, so the node answers where its peers
// look for it.
func TestSyncMovesTheLiveChainOffTheRetiredPort(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr":           "0.0.0.0:24009",
		"rpc-addr":           "127.0.0.1:26009",
		"mainchain-grpc-url": "http://localhost:50051",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}
	for key, want := range map[string]string{
		"net-addr": "0.0.0.0:4009",
		"rpc-addr": "127.0.0.1:6009",
	} {
		if got := m.Config.GetSetting(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
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

	m.BitcoinConf.Network = NetworkRegtest
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

// The network is always downstream of the mainchain conf. A network key in the
// sidechain file is a second source, and a user edit there would fight it.
func TestDefaultConfigHoldsNoNetworkKey(t *testing.T) {
	for name := range KnownSidechainSpecs {
		m := sidechainConfFor(t, name, NetworkSignet, map[string]string{})
		for _, line := range strings.Split(m.GetDefaultConfig(), "\n") {
			if strings.HasPrefix(strings.TrimSpace(line), legacyNetworkKey+"=") {
				t.Errorf("%s default config carries %q", name, line)
			}
		}
	}
}

// An install from an older build carries the key. The sync drops it, so the UI
// never shows a value the launch path ignores.
func TestSyncDropsTheLegacyNetworkKey(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr": "0.0.0.0:4009",
		"rpc-addr": "127.0.0.1:6009",
		"network":  "mainnet",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}
	if got := m.Config.GetSetting(legacyNetworkKey); got != "" {
		t.Errorf("the conf kept network=%q", got)
	}
}

// A network switch reloads the mainchain conf alone. The ports carry the
// offset, so the sync moves them to the network the mainchain now runs.
func TestSyncMovesThePortsToTheMainchainNetwork(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkRegtest, map[string]string{
		"net-addr": "0.0.0.0:4009",
		"rpc-addr": "127.0.0.1:6009",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}
	if got := m.Config.GetSetting("net-addr"); got != "0.0.0.0:14009" {
		t.Errorf("net-addr = %q, want the regtest port", got)
	}
}

// The mainchain conf owns the network. Nothing reads a value out of the
// sidechain file, so the two can never disagree.
func TestGetNetworkReadsTheMainchainConf(t *testing.T) {
	for network, want := range map[Network]string{
		NetworkSignet:  "signet",
		NetworkRegtest: "regtest",
		NetworkECash:   "ecash",
	} {
		m := sidechainConfFor(t, "thunder", network, map[string]string{"network": "nonsense"})
		if got := m.GetNetwork(); got != want {
			t.Errorf("GetNetwork on %s = %q, want %q", network, got, want)
		}
	}
}

// prepareSidechainArgs syncs before every start. A user who points thunder at a
// remote enforcer would lose that URL on the next start.
func TestSyncKeepsACustomEndpoint(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr":           "0.0.0.0:9999",
		"rpc-addr":           "127.0.0.1:36009",
		"mainchain-grpc-url": "https://remote.example/grpc",
		"config-version":     "1",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}
	for key, want := range map[string]string{
		"net-addr":           "0.0.0.0:9999",
		"mainchain-grpc-url": "https://remote.example/grpc",
	} {
		if got := m.Config.GetSetting(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
		}
	}
	if _, err := os.Stat(m.getConfigPath()); !os.IsNotExist(err) {
		t.Error("the sync saved the file, but it changed nothing")
	}
}

// A port from another network came from an earlier sync, so a network change
// replaces it.
func TestSyncReplacesAnotherNetworksPort(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkSignet, map[string]string{
		"net-addr":           "0.0.0.0:24009",
		"rpc-addr":           "127.0.0.1:26009",
		"mainchain-grpc-url": "http://localhost:50051",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}
	for key, want := range map[string]string{
		"net-addr": "0.0.0.0:34009",
		"rpc-addr": "127.0.0.1:36009",
	} {
		if got := m.Config.GetSetting(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
		}
	}
}
