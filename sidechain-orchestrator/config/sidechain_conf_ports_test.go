package config

import (
	"slices"
	"strconv"
	"strings"
	"testing"
)

// provedChainFlags holds every flag a chain's own `--help` lists, for the
// binaries that ship with BitWindow. A flag outside this set stops the daemon
// on its first boot.
var provedChainFlags = map[string][]string{
	"thunder":   {"datadir", "headless", "log-dir", "log-level-file", "log-level", "mainchain-grpc-url", "mnemonic-seed-phrase-path", "net-addr", "network", "network-magic", "private-rpc-addr", "rpc-addr"},
	"bitassets": {"datadir", "file-log-level", "headless", "log-dir", "log-level", "mainchain-grpc-host", "mainchain-grpc-port", "mnemonic-seed-phrase-path", "net-addr", "network", "rpc-host", "rpc-port", "zmq-addr"},
	"bitnames":  {"datadir", "file-log-level", "headless", "log-dir", "log-level", "mainchain-grpc-host", "mainchain-grpc-port", "mnemonic-seed-phrase-path", "net-addr", "network", "network-magic", "private-rpc-addr", "rpc-addr", "zmq-addr"},
	"photon":    {"datadir", "headless", "log-dir", "log-level-file", "log-level", "mainchain-grpc-url", "mnemonic-seed-phrase-path", "net-addr", "network", "network-magic", "rpc-addr"},
	"coinshift": {"datadir", "headless", "log-dir", "log-level-file", "log-level", "mainchain-grpc-url", "mnemonic-seed-phrase-path", "net-addr", "network", "rpc-addr", "l1-signet", "l1-bch-testnet4"},
}

// unprovedChains ship no binary here, so nobody read their flags.
var unprovedChains = []string{"zside", "truthcoin", "liquid-signet"}

// A flag the daemon does not know stops it on the first boot.
func TestCliArgKeysNameOnlyFlagsTheBinaryAccepts(t *testing.T) {
	for name, flags := range provedChainFlags {
		spec, ok := KnownSidechainSpecs[name]
		if !ok {
			t.Fatalf("%s is missing from the known sidechain specs", name)
		}
		for _, key := range spec.CliArgKeys {
			if !slices.Contains(flags, key) {
				t.Errorf("%s passes --%s, which its binary does not accept", name, key)
			}
		}
	}
}

// The conf key must be the flag name the binary reads, so a hand edit reaches
// the daemon.
func TestEveryEndpointKeyIsAFlagTheBinaryAccepts(t *testing.T) {
	for name, flags := range provedChainFlags {
		m := sidechainConfFor(t, name, NetworkSignet, nil)
		for key := range m.getNetworkPorts("signet") {
			if !slices.Contains(flags, key) {
				t.Errorf("%s writes the key %q, which its binary does not accept", name, key)
			}
		}
	}
}

// bitassets takes a bare port, and every other proved chain takes a socket
// address.
func TestRpcEndpointFollowsTheBinary(t *testing.T) {
	for name, want := range map[string]string{
		"thunder":   "127.0.0.1:36009",
		"bitassets": "36004",
		"bitnames":  "127.0.0.1:36002",
		"photon":    "127.0.0.1:36099",
		"coinshift": "127.0.0.1:36255",
	} {
		m := sidechainConfFor(t, name, NetworkSignet, nil)
		key := KnownSidechainSpecs[name].rpcEndpointKey()
		if got := m.getNetworkPorts("signet")[key]; got != want {
			t.Errorf("%s %s = %q, want %q", name, key, got, want)
		}
	}
}

// bitassets and bitnames bind a ZMQ publisher, and two daemons that bind one
// address cannot both run.
func TestOnlyTheZmqChainsPassAZmqAddress(t *testing.T) {
	for name, spec := range KnownSidechainSpecs {
		wantZmq := spec.PortStyle == "zmq"
		if got := slices.Contains(spec.CliArgKeys, "zmq-addr"); got != wantZmq {
			t.Errorf("%s passes zmq-addr = %v, want %v", name, got, wantZmq)
		}
		if got := writesEndpointKey(t, name, "zmq-addr"); got != wantZmq {
			t.Errorf("%s writes a zmq-addr = %v, want %v", name, got, wantZmq)
		}
	}
}

func writesEndpointKey(t *testing.T, name, key string) bool {
	t.Helper()
	m := sidechainConfFor(t, name, NetworkSignet, nil)
	_, ok := m.getNetworkPorts("signet")[key]
	return ok
}

// The launch path passes what the daemon binds, so a start on one network
// never takes a port another network already holds.
func TestTheZmqChainsPassEveryPortTheyBind(t *testing.T) {
	for _, name := range []string{"bitassets", "bitnames"} {
		m := sidechainConfFor(t, name, NetworkRegtest, map[string]string{
			"net-addr": "0.0.0.0:14004",
			"zmq-addr": "127.0.0.1:38004",
		})
		args := m.GetCliArgs()
		for _, want := range []string{"--net-addr=0.0.0.0:14004", "--zmq-addr=127.0.0.1:38004"} {
			if !slices.Contains(args, want) {
				t.Errorf("%s args = %v, want %s", name, args, want)
			}
		}
	}
}

// Every network holds its own ports, so a regtest daemon and an eCash daemon
// run beside each other. mainchain-grpc-url stays out: the daemon dials it,
// and one enforcer serves every network in turn.
func TestTwoNetworksShareNoPort(t *testing.T) {
	for name, spec := range KnownSidechainSpecs {
		m := sidechainConfFor(t, name, NetworkSignet, nil)
		bound := []string{"net-addr", "zmq-addr", spec.rpcEndpointKey()}
		seen := map[int]string{}
		for _, group := range portGroups {
			for key, value := range m.getNetworkPorts(group) {
				if !slices.Contains(bound, key) {
					continue
				}
				port := portOf(t, value)
				if port == 0 {
					t.Errorf("%s: %s on %s = %q, which names no port", name, key, group, value)
					continue
				}
				if held, taken := seen[port]; taken {
					t.Errorf("%s: %s on %s takes port %d, which %s already holds", name, key, group, port, held)
				}
				seen[port] = group + " " + key
			}
		}
	}
}

// The live chain answers at the base port, which is the port the daemon binds
// with no arguments and the port its seed peers name.
func TestECashKeepsTheDaemonDefaults(t *testing.T) {
	for name, want := range map[string]map[string]string{
		"thunder":   {"rpc-addr": "127.0.0.1:6009", "net-addr": "0.0.0.0:4009"},
		"bitassets": {"rpc-port": "6004", "net-addr": "0.0.0.0:4004", "zmq-addr": "127.0.0.1:28004"},
		"bitnames":  {"rpc-addr": "127.0.0.1:6002", "net-addr": "0.0.0.0:4002", "zmq-addr": "127.0.0.1:28002"},
		"photon":    {"rpc-addr": "127.0.0.1:6099", "net-addr": "0.0.0.0:4099"},
		"coinshift": {"rpc-addr": "127.0.0.1:6255", "net-addr": "0.0.0.0:4255"},
	} {
		m := sidechainConfFor(t, name, NetworkECash, nil)
		ports := m.getNetworkPorts("ecash")
		for key, value := range want {
			if got := ports[key]; got != value {
				t.Errorf("%s %s on eCash = %q, want the daemon default %q", name, key, got, value)
			}
		}
	}
}

// A default conf names the RPC key its own binary reads.
func TestDefaultConfigNamesTheRpcKey(t *testing.T) {
	for name, spec := range KnownSidechainSpecs {
		m := sidechainConfFor(t, name, NetworkSignet, nil)
		want := spec.rpcEndpointKey() + "="
		if !strings.Contains(m.GetDefaultConfig(), want) {
			t.Errorf("%s default config holds no %q line", name, want)
		}
	}
}

func portOf(t *testing.T, endpoint string) int {
	t.Helper()
	value := endpoint
	if at := strings.LastIndex(endpoint, ":"); at >= 0 {
		value = endpoint[at+1:]
	}
	port, err := strconv.Atoi(value)
	if err != nil {
		return 0
	}
	return port
}
