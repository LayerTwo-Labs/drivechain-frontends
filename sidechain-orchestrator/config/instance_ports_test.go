package config

import (
	"net"
	"os"
	"strconv"
	"strings"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/instance"
)

func regtestCoreConf(t *testing.T) *BitcoinConfManager {
	t.Helper()
	conf := NewBitcoinConfig()
	conf.GlobalSettings["zmqpubsequence"] = "tcp://127.0.0.1:29000"
	conf.GlobalSettings["zmqpubrawtx"] = "tcp://127.0.0.1:29004"
	return &BitcoinConfManager{BitwindowDir: t.TempDir(), Network: NetworkRegtest, Config: conf, log: zerolog.Nop()}
}

func TestCorePortsWithNoOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "")
	m := regtestCoreConf(t)

	require.Equal(t, 18443, m.GetRPCPort())
	require.Equal(t, "tcp://127.0.0.1:29000", m.ZMQSequenceAddress())
	require.Empty(t, m.InstancePortArgs())
	require.False(t, moveGeneratedZMQPublishers(m.Config))
}

func TestCorePortsWithOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	m := regtestCoreConf(t)

	require.Equal(t, 19443, m.GetRPCPort())
	require.Equal(t, []string{"-rpcport=19443", "-port=19444"}, m.InstancePortArgs())
}

// Core joins a flag with the conf values, so the conf holds the moved endpoints.
func TestOffsetMovesGeneratedZMQPublishers(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	m := regtestCoreConf(t)
	m.Config.SetSetting("zmqpubhashblock", "tcp://127.0.0.1:29001", "regtest")
	m.Config.GlobalSettings["zmqpubhashtx"] = "tcp://127.0.0.1:40000"

	require.True(t, moveGeneratedZMQPublishers(m.Config))
	require.Equal(t, "tcp://127.0.0.1:30000", m.Config.GetSetting("zmqpubsequence", ""))
	require.Equal(t, "tcp://127.0.0.1:30004", m.Config.GetSetting("zmqpubrawtx", ""))
	require.Equal(t, "tcp://127.0.0.1:30001", m.Config.GetSetting("zmqpubhashblock", "regtest"))
	require.Equal(t, "tcp://127.0.0.1:40000", m.Config.GetSetting("zmqpubhashtx", ""), "a typed value stays")
	require.Equal(t, "tcp://127.0.0.1:30000", m.ZMQSequenceAddress())
	require.False(t, moveGeneratedZMQPublishers(m.Config), "a second run changes nothing")
}

// A conf from a run with another offset, such as a restored snapshot, moves to this offset.
func TestOffsetMovesZMQPublishersOfAnotherOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "2000")
	m := regtestCoreConf(t)
	m.Config.GlobalSettings["zmqpubsequence"] = "tcp://127.0.0.1:30000"
	m.Config.GlobalSettings["zmqpubhashtx"] = "tcp://10.0.0.2:30002"

	require.True(t, moveGeneratedZMQPublishers(m.Config))
	require.Equal(t, "tcp://127.0.0.1:31000", m.Config.GetSetting("zmqpubsequence", ""))
	require.Equal(t, "tcp://127.0.0.1:31004", m.Config.GetSetting("zmqpubrawtx", ""))
	require.Equal(t, "tcp://10.0.0.2:30002", m.Config.GetSetting("zmqpubhashtx", ""), "a remote publisher stays")

	t.Setenv(instance.PortOffsetEnv, "")
	t.Setenv(instance.HomeEnv, t.TempDir())
	require.True(t, moveGeneratedZMQPublishers(m.Config))
	require.Equal(t, "tcp://127.0.0.1:29000", m.Config.GetSetting("zmqpubsequence", ""))
}

func TestDefaultInstallKeepsZMQPublishers(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "")
	t.Setenv(instance.HomeEnv, "")
	m := regtestCoreConf(t)
	m.Config.GlobalSettings["zmqpubsequence"] = "tcp://127.0.0.1:29500"

	require.False(t, moveGeneratedZMQPublishers(m.Config))
	require.Equal(t, "tcp://127.0.0.1:29500", m.Config.GetSetting("zmqpubsequence", ""))
}

func TestOffsetMovesZMQPublishersOfANewConf(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	m := &BitcoinConfManager{BitwindowDir: t.TempDir(), Network: NetworkRegtest, log: zerolog.Nop()}

	content, err := m.loadOrCreateConfigContent()
	require.NoError(t, err)
	require.Contains(t, content, "zmqpubsequence=tcp://127.0.0.1:30000")
	require.NotContains(t, content, "127.0.0.1:2900")
}

func TestOffsetMovesZMQPublishersOfAnOldConf(t *testing.T) {
	dir := t.TempDir()
	m := &BitcoinConfManager{BitwindowDir: dir, Network: NetworkRegtest, log: zerolog.Nop()}
	t.Setenv(instance.PortOffsetEnv, "")
	_, err := m.loadOrCreateConfigContent()
	require.NoError(t, err)

	t.Setenv(instance.PortOffsetEnv, "2000")
	content, err := m.loadOrCreateConfigContent()
	require.NoError(t, err)
	require.Contains(t, content, "zmqpubsequence=tcp://127.0.0.1:31000")
	onDisk, err := os.ReadFile(m.getBitWindowConfigPath())
	require.NoError(t, err)
	require.Equal(t, content, string(onDisk))
}

func TestCorePortsWithOffsetMoveConfPorts(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	m := regtestCoreConf(t)
	m.Config.SetSetting("rpcport", "20443", "regtest")
	m.Config.SetSetting("port", "20444", "regtest")

	require.Equal(t, 21443, m.GetRPCPort())
	require.Equal(t, []string{"-rpcport=21443", "-port=21444"}, m.InstancePortArgs())
}

func TestCorePortsWithOffsetKeepRemoteRPCPort(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	m := regtestCoreConf(t)
	m.Config.SetSetting("rpcconnect", "10.0.0.2", "regtest")

	require.Equal(t, 18443, m.GetRPCPort())
}

func TestEnforcerArgsWithNoOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "")
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()
	require.Contains(t, args, "--node-rpc-addr=127.0.0.1:38332")
	require.Contains(t, args, "--node-zmq-addr-sequence=tcp://127.0.0.1:29000")
	rejectArgPrefix(t, args, "--serve-grpc-addr")
	rejectArgPrefix(t, args, "--serve-rpc-addr")
	require.Equal(t, "127.0.0.1:8122", EnforcerJSONRPCAddr())
	require.Equal(t, "http://localhost:50051", EnforcerGRPCURL())
}

func TestEnforcerArgsWithOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "2000")
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())

	args := m.GetCliArgs()
	require.Contains(t, args, "--node-rpc-addr=127.0.0.1:40332")
	require.Contains(t, args, "--node-zmq-addr-sequence=tcp://127.0.0.1:31000")
	require.Contains(t, args, "--serve-grpc-addr=127.0.0.1:52051")
	require.Contains(t, args, "--serve-rpc-addr=127.0.0.1:10122")
	require.Equal(t, "127.0.0.1:10122", EnforcerJSONRPCAddr())
	require.Equal(t, "http://localhost:52051", EnforcerGRPCURL())
}

// A listen address in the enforcer conf wins over the offset.
func TestEnforcerArgsWithOffsetKeepConfListenAddr(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "2000")
	m, _ := newTestEnforcerManager(t)
	require.NoError(t, m.LoadConfig())
	m.Config.Settings["serve-grpc-addr"] = "127.0.0.1:60051"

	args := m.GetCliArgs()
	require.Contains(t, args, "--serve-grpc-addr=127.0.0.1:60051")
	require.NotContains(t, args, "--serve-grpc-addr=127.0.0.1:52051")
}

func TestSidechainArgsWithNoOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "")
	for name := range KnownSidechainSpecs {
		require.Empty(t, KnownSidechainSpecs[name].InstanceRPCArgs(), name)
	}
	m := sidechainConfFor(t, "thunder", NetworkRegtest, nil)
	m.Config = ParseGenericAppConfig(m.GetDefaultConfig())
	args := m.GetCliArgs()
	require.Contains(t, args, "--net-addr=0.0.0.0:14009")
	require.Contains(t, args, "--mainchain-grpc-url=http://localhost:50051")
	rejectArgPrefix(t, args, "--rpc-addr")
}

func TestSidechainArgsWithOffset(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, "1000")
	for name, want := range map[string][]string{
		"thunder":   {"--rpc-addr=127.0.0.1:7009", "--private-rpc-addr=127.0.0.1:7009", "--net-addr=0.0.0.0:15009", "--mainchain-grpc-url=http://localhost:51051"},
		"bitassets": {"--rpc-port=7004", "--net-addr=0.0.0.0:15004", "--zmq-addr=127.0.0.1:39004", "--mainchain-grpc-port=51051"},
		"bitnames":  {"--rpc-addr=127.0.0.1:7002", "--private-rpc-addr=127.0.0.1:7002", "--net-addr=0.0.0.0:15002", "--zmq-addr=127.0.0.1:39002", "--mainchain-grpc-port=51051"},
	} {
		m := sidechainConfFor(t, name, NetworkRegtest, nil)
		m.Config = ParseGenericAppConfig(m.GetDefaultConfig())
		args := m.GetCliArgs()
		for _, arg := range want {
			require.Contains(t, args, arg, name)
		}
	}
}

func TestHomeDirFollowsBitwindowHome(t *testing.T) {
	dir := t.TempDir()
	t.Setenv(instance.HomeEnv, dir)
	require.Equal(t, dir, HomeDir())
	require.Equal(t, dir, AppHome())

	override := t.TempDir()
	SetHomeDir(override)
	t.Cleanup(func() { SetHomeDir("") })
	require.Equal(t, override, HomeDir())
}

func TestHomeDirWithNoBitwindowHome(t *testing.T) {
	t.Setenv(instance.HomeEnv, "")
	require.Empty(t, AppHome())
	require.Equal(t, UserHomeDir(), HomeDir())
}

// The highest offset keeps every generated port a valid port.
func TestMaxPortOffsetKeepsEveryPortValid(t *testing.T) {
	t.Setenv(instance.PortOffsetEnv, strconv.Itoa(instance.MaxPortOffset))
	for name := range KnownSidechainSpecs {
		m := sidechainConfFor(t, name, NetworkSignet, nil)
		for _, group := range portGroups {
			for key, value := range m.getNetworkPorts(group) {
				_, raw, err := net.SplitHostPort(strings.TrimPrefix(strings.TrimPrefix(value, "http://"), "tcp://"))
				if err != nil {
					raw = value
				}
				port, err := strconv.Atoi(raw)
				require.NoError(t, err, "%s %s %s", name, group, key)
				require.LessOrEqual(t, port, 65535, "%s %s %s", name, group, key)
			}
		}
	}
	for _, base := range []int{30301, 30400, enforcerGRPCPort, enforcerJSONRPCPort, 18443, 38333} {
		require.LessOrEqual(t, instance.Port(base), 65535)
	}
}
