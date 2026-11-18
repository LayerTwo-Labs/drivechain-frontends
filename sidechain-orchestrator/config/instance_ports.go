package config

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/instance"
)

// Ports the enforcer serves on when no flag moves them.
const (
	enforcerGRPCPort    = 50051
	enforcerJSONRPCPort = 8122
)

// EnforcerJSONRPCAddr is the enforcer's JSON-RPC listen address.
func EnforcerJSONRPCAddr() string {
	return instance.Addr("127.0.0.1", enforcerJSONRPCPort)
}

// EnforcerGRPCURL is the URL of the enforcer's gRPC endpoint.
func EnforcerGRPCURL() string {
	return "http://" + instance.Addr("localhost", enforcerGRPCPort)
}

// enforcerListenArgs are the enforcer flags that move its listen ports by the
// port offset. They are empty when the offset is 0.
func enforcerListenArgs() map[string]string {
	if instance.Port(enforcerGRPCPort) == enforcerGRPCPort {
		return nil
	}
	return map[string]string{
		"serve-grpc-addr": instance.Addr("127.0.0.1", enforcerGRPCPort),
		"serve-rpc-addr":  EnforcerJSONRPCAddr(),
	}
}

// generatedZMQPorts are the ZMQ publisher ports the generated conf writes.
var generatedZMQPorts = map[string]int{
	"zmqpubsequence":  29000,
	"zmqpubhashblock": 29001,
	"zmqpubhashtx":    29002,
	"zmqpubrawtx":     29004,
}

func zmqEndpoint(port int) string {
	return "tcp://" + instance.Addr("127.0.0.1", port)
}

// moveGeneratedZMQPublishers moves each ZMQ endpoint the generated conf wrote
// to the current port offset. Core joins a flag with the conf values, so the
// conf itself must hold the moved endpoint. An endpoint that an earlier offset
// moved counts as generated too, and a value the user typed stays. A default
// install keeps its conf as it is.
func moveGeneratedZMQPublishers(config *BitcoinConfig) bool {
	if !instance.Isolated() {
		return false
	}
	changed := false
	for key, base := range generatedZMQPorts {
		moved := zmqEndpoint(base)
		for _, section := range []string{"", "main", "test", "signet", "regtest"} {
			value := config.GetSetting(key, section)
			if value == moved || !isGeneratedZMQEndpoint(value, base) {
				continue
			}
			config.SetSetting(key, moved, section)
			changed = true
		}
	}
	return changed
}

// isGeneratedZMQEndpoint reports whether endpoint is the local publisher at
// base, moved by any valid port offset.
func isGeneratedZMQEndpoint(endpoint string, base int) bool {
	raw, found := strings.CutPrefix(endpoint, "tcp://127.0.0.1:")
	if !found {
		return false
	}
	port, err := strconv.Atoi(raw)
	return err == nil && port >= base && port <= base+instance.MaxPortOffset
}

// P2PPortForNetwork returns the default P2P port for a given network.
func P2PPortForNetwork(n Network) int {
	switch n {
	case NetworkMainnet:
		return 8333
	case NetworkECash:
		return 8301
	case NetworkTestnet:
		return 18333
	case NetworkRegtest:
		return 18444
	default:
		return 38333
	}
}

// effectivePort reads a port from the conf, or gives fallback when the conf
// does not set it.
func (m *BitcoinConfManager) effectivePort(key string, fallback int) int {
	if m.Config == nil {
		return fallback
	}
	raw := m.Config.GetEffectiveSetting(key, CoreSectionForNetwork(m.Network))
	if port, err := strconv.Atoi(raw); err == nil {
		return port
	}
	return fallback
}

// ZMQSequenceAddress returns the endpoint bitcoind publishes its sequence on.
func (m *BitcoinConfManager) ZMQSequenceAddress() string {
	if m.Config != nil {
		if v := m.Config.GetEffectiveSetting("zmqpubsequence", CoreSectionForNetwork(m.Network)); v != "" {
			return v
		}
	}
	return zmqEndpoint(generatedZMQPorts["zmqpubsequence"])
}

// InstancePortArgs are the bitcoind flags that move its RPC and P2P ports by
// the port offset. They are empty when the offset is 0. -port also moves the
// onion bind to the P2P port plus 1.
func (m *BitcoinConfManager) InstancePortArgs() []string {
	p2p := m.effectivePort("port", P2PPortForNetwork(m.Network))
	if instance.Port(p2p) == p2p {
		return nil
	}
	return []string{
		fmt.Sprintf("-rpcport=%d", m.GetRPCPort()),
		fmt.Sprintf("-port=%d", instance.Port(p2p)),
	}
}
