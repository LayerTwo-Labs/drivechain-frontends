package orchestrator

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpchealth"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/stretchr/testify/require"
)

func remoteValidatorServer(t *testing.T, height uint32, failure *atomic.Bool) *httptest.Server {
	t.Helper()
	mux := http.NewServeMux()
	mux.Handle(enforcerrpc.ValidatorServiceGetChainTipProcedure, connect.NewUnaryHandler(
		enforcerrpc.ValidatorServiceGetChainTipProcedure,
		func(context.Context, *connect.Request[enforcerpb.GetChainTipRequest]) (*connect.Response[enforcerpb.GetChainTipResponse], error) {
			if failure != nil && failure.Load() {
				return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("validator is offline"))
			}
			return connect.NewResponse(&enforcerpb.GetChainTipResponse{BlockHeaderInfo: &enforcerpb.BlockHeaderInfo{Height: height}}), nil
		},
	))
	healthPath, healthHandler := grpchealth.NewHandler(grpchealth.NewStaticChecker("cusf.mainchain.v1.ValidatorService"))
	mux.Handle(healthPath, healthHandler)
	server := httptest.NewUnstartedServer(mux)
	server.Config.Protocols = new(http.Protocols)
	server.Config.Protocols.SetHTTP1(true)
	server.Config.Protocols.SetUnencryptedHTTP2(true)
	server.Start()
	t.Cleanup(server.Close)
	return server
}

func setRemoteTestEndpoint(t *testing.T, network config.Network, endpoint string) {
	t.Helper()
	old := config.PublishedEndpoints(network)
	entry := old
	entry.Services.Enforcer.URL = endpoint
	config.SetNetworkEndpoints(network, entry)
	t.Cleanup(func() { config.SetNetworkEndpoints(network, old) })
}

func remoteTestOrchestrator(t *testing.T, endpoint string) *Orchestrator {
	t.Helper()
	useTempHome(t)
	o := newTestOrchestrator(t)
	setRemoteTestEndpoint(t, config.NetworkSignet, endpoint)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	t.Cleanup(func() {
		o.StopAllMonitors()
		require.NoError(t, o.closeRemoteEnforcer())
	})
	return o
}

func TestRemoteEnforcerKeepsOneBridge(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	var wg sync.WaitGroup
	endpoints := make(chan string, 12)
	for range cap(endpoints) {
		wg.Go(func() {
			endpoint, err := o.EnforcerURL()
			if err != nil {
				t.Error(err)
				return
			}
			endpoints <- endpoint
		})
	}
	wg.Wait()
	close(endpoints)
	first := <-endpoints
	require.NotEmpty(t, first)
	for endpoint := range endpoints {
		require.Equal(t, first, endpoint)
	}
	client, err := o.EnforcerValidator()
	require.NoError(t, err)
	tip, err := client.GetChainTip(context.Background(), connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
	require.NoError(t, err)
	require.EqualValues(t, 42, tip.Msg.BlockHeaderInfo.Height)
	status, err := (&enforcerSyncConnection{o: o}).Fetch(context.Background())
	require.NoError(t, err)
	require.EqualValues(t, 42, status.Blocks)
}

func TestRemoteEnforcerKeepsClientAfterEndpointChange(t *testing.T) {
	firstServer := remoteValidatorServer(t, 42, nil)
	secondServer := remoteValidatorServer(t, 56, nil)
	o := remoteTestOrchestrator(t, firstServer.URL)
	first, err := o.EnforcerURL()
	require.NoError(t, err)
	client := enforcerrpc.NewValidatorServiceClient(o.enforcerHTTP(), first, connect.WithGRPC())
	tip, err := client.GetChainTip(context.Background(), connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
	require.NoError(t, err)
	require.EqualValues(t, 42, tip.Msg.BlockHeaderInfo.Height)
	entry := config.PublishedEndpoints(config.NetworkSignet)
	entry.Services.Enforcer.URL = secondServer.URL
	config.SetNetworkEndpoints(config.NetworkSignet, entry)
	second, err := o.EnforcerURL()
	require.NoError(t, err)
	tip, err = client.GetChainTip(context.Background(), connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
	require.NoError(t, err)
	require.EqualValues(t, 56, tip.Msg.BlockHeaderInfo.Height)
	require.Equal(t, first, second)
	status, err := (&enforcerSyncConnection{o: o}).Fetch(context.Background())
	require.NoError(t, err)
	require.EqualValues(t, 56, status.Blocks)
}

func TestRemoteEnforcerClosesWithShutdown(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	ch, err := o.ShutdownAll(context.Background(), true)
	require.NoError(t, err)
	for p := range ch {
		require.NoError(t, p.Error)
	}
	u, err := url.Parse(endpoint)
	require.NoError(t, err)
	conn, err := net.DialTimeout("tcp", u.Host, time.Second)
	if conn != nil {
		require.NoError(t, conn.Close())
	}
	require.Error(t, err)
	require.Nil(t, o.remoteEnforcer)
}

func TestRemoteEnforcerStartsWithoutLocalL1(t *testing.T) {
	var failure atomic.Bool
	server := remoteValidatorServer(t, 42, &failure)
	o := remoteTestOrchestrator(t, server.URL)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	ch, err := o.StartWithL1(ctx, "enforcer", StartOpts{})
	require.NoError(t, err)
	var complete bool
	for p := range ch {
		require.NoError(t, p.Error)
		complete = complete || p.Done
	}
	require.True(t, complete)
	status := o.Status("enforcer")
	require.True(t, status.Connected)
	require.False(t, status.Running)
	require.Empty(t, o.process.ListRunning())
	failure.Store(true)
	require.Eventually(t, func() bool { return !o.Status("enforcer").Connected }, 4*time.Second, 20*time.Millisecond)
}

func TestRemoteEnforcerReturnsAfterNetworkSwap(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	previous := config.ECashEndpoints()
	entry := netcatalog.EmbeddedECash()
	entry.Services.Enforcer.URL = server.URL
	config.SetECashEndpoints(entry)
	t.Cleanup(func() { config.SetECashEndpoints(previous) })
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	ch, err := o.StartWithL1(context.Background(), "enforcer", StartOpts{})
	require.NoError(t, err)
	for progress := range ch {
		require.NoError(t, progress.Error)
	}
	require.True(t, o.Status("enforcer").Connected)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkMainnet))
	require.False(t, o.Status("enforcer").Connected)
	require.Nil(t, o.remoteEnforcer)
	require.NoError(t, o.SwapNetwork(context.Background(), config.NetworkECash))
	require.Eventually(t, func() bool { return o.Status("enforcer").Connected }, 3*time.Second, 10*time.Millisecond)
	require.False(t, o.Status("enforcer").Running)
	require.Empty(t, o.process.ListRunning())
}

func TestRemoteSidechainArgsMatchEachDaemon(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	u, err := url.Parse(endpoint)
	require.NoError(t, err)
	for _, name := range []string{"thunder", "bitnames", "bitassets", "photon", "coinshift", "truthcoin"} {
		t.Run(name, func(t *testing.T) {
			cfg, err := o.getConfig(name)
			require.NoError(t, err)
			opts := StartOpts{ForceBackend: true, TargetArgs: []string{
				"--mainchain-grpc-url=http://localhost:50051", "--mainchain-grpc-host", "localhost", "--mainchain-grpc-port", "50051", "--network=regtest",
			}}
			require.NoError(t, o.prepareSidechainArgs(cfg, &opts))
			require.Contains(t, opts.TargetArgs, "--network=signet")
			require.NotContains(t, strings.Join(opts.TargetArgs, " "), "localhost")
			switch name {
			case "bitnames", "bitassets", "truthcoin":
				require.Contains(t, opts.TargetArgs, "--mainchain-grpc-host="+u.Hostname())
				require.Contains(t, opts.TargetArgs, "--mainchain-grpc-port="+u.Port())
				require.False(t, hasCLIFlag(opts.TargetArgs, "--mainchain-grpc-url"))
			default:
				require.Contains(t, opts.TargetArgs, "--mainchain-grpc-url="+endpoint)
				require.False(t, hasCLIFlag(opts.TargetArgs, "--mainchain-grpc-host"))
			}
		})
	}
}

// A light node binds the same sockets as a full one. Without the ZMQ address
// two daemons on two networks bind one publisher, and the second one stops.
func TestRemoteSidechainArgsPassTheBoundPorts(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	for name, want := range map[string][]string{
		"bitnames":  {"--net-addr=0.0.0.0:34002", "--zmq-addr=127.0.0.1:58002"},
		"bitassets": {"--net-addr=0.0.0.0:34004", "--zmq-addr=127.0.0.1:58004"},
		"photon":    {"--net-addr=0.0.0.0:34099"},
	} {
		t.Run(name, func(t *testing.T) {
			cfg, err := o.getConfig(name)
			require.NoError(t, err)
			opts := StartOpts{ForceBackend: true}
			require.NoError(t, o.prepareSidechainArgs(cfg, &opts))
			for _, arg := range want {
				require.Contains(t, opts.TargetArgs, arg)
			}
			if name == "photon" {
				require.False(t, hasCLIFlag(opts.TargetArgs, "--zmq-addr"))
			}
		})
	}
}

func TestRemoteSidechainRejectsMissingEndpoint(t *testing.T) {
	o := remoteTestOrchestrator(t, "")
	_, err := o.EnforcerURL()
	require.ErrorContains(t, err, "signet has no remote enforcer endpoint")
	var opts StartOpts
	cfg, err := o.getConfig("thunder")
	require.NoError(t, err)
	require.ErrorContains(t, o.prepareSidechainArgs(cfg, &opts), "no remote enforcer endpoint")
}

func TestRemoteSidechainRejectsUnknownNetwork(t *testing.T) {
	o := remoteTestOrchestrator(t, "http://127.0.0.1:1")
	o.setNetwork("mainnet")
	var opts StartOpts
	cfg, err := o.getConfig("thunder")
	require.NoError(t, err)
	require.ErrorIs(t, o.prepareSidechainArgs(cfg, &opts), errSidechainNetworkUnknown)
}

func TestNodeModeChangeClosesTheRemoteBridge(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeFull))
	require.Nil(t, o.remoteEnforcer)
	u, err := url.Parse(endpoint)
	require.NoError(t, err)
	conn, err := net.DialTimeout("tcp", u.Host, time.Second)
	if conn != nil {
		require.NoError(t, conn.Close())
	}
	require.Error(t, err)
	local, err := o.EnforcerURL()
	require.NoError(t, err)
	require.Equal(t, o.Configs()["enforcer"].RPCURL(), local)
	require.Equal(t, NodeModeFull, o.NodeMode())
}

func TestNodeModeChangeStopsLocalL1BeforeTheModeWrite(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	for _, name := range []string{"bitcoind", "enforcer"} {
		o.process.processes[name] = &ManagedProcess{Config: o.Configs()[name]}
	}
	var stopped []string
	o.stopBinary = func(_ context.Context, name string, _ bool, _ ...StopOptions) error {
		require.Equal(t, NodeModeFull, o.NodeMode())
		stopped = append(stopped, name)
		o.process.Remove(name)
		return nil
	}
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeLight))
	require.Equal(t, []string{"enforcer", "bitcoind"}, stopped)
	require.Equal(t, NodeModeLight, o.NodeMode())
}

func TestNodeModeChangeKeepsTheModeWhenAStopFails(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	o.process.processes["enforcer"] = &ManagedProcess{Config: o.Configs()["enforcer"]}
	o.stopBinary = func(context.Context, string, bool, ...StopOptions) error {
		return fmt.Errorf("test stop error")
	}
	require.ErrorContains(t, o.SetNodeMode(context.Background(), NodeModeLight), "test stop error")
	require.Equal(t, NodeModeFull, o.NodeMode())
	o.process.Remove("enforcer")
}

func TestRemoteSidechainProcess(t *testing.T) {
	if os.Getenv("REMOTE_DAEMON_HELPER") != "1" {
		return
	}
	listener, err := net.Listen("tcp", os.Getenv("REMOTE_DAEMON_ADDR"))
	if err != nil {
		os.Exit(1)
	}
	for {
		conn, err := listener.Accept()
		if err != nil {
			os.Exit(1)
		}
		if err := conn.Close(); err != nil {
			os.Exit(1)
		}
	}
}

func installRemoteTestDaemon(t *testing.T, o *Orchestrator) (BinaryConfig, map[string]string, string) {
	t.Helper()
	if runtime.GOOS == "windows" {
		t.Skip("this process test uses a shell")
	}
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())
	cfg, err := o.getConfig("thunder")
	require.NoError(t, err)
	cfg.Port = port
	o.UpdateConfigs([]BinaryConfig{cfg})
	executable, err := os.Executable()
	require.NoError(t, err)
	argsPath := filepath.Join(t.TempDir(), "args")
	env := map[string]string{
		"REMOTE_DAEMON_HELPER": "1",
		"REMOTE_DAEMON_ADDR":   cfg.RPCAddr(),
		"REMOTE_DAEMON_ARGS":   argsPath,
		"REMOTE_DAEMON_TEST":   executable,
	}
	path := BinaryPath(o.DataDir, cfg.BinaryName)
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$REMOTE_DAEMON_ARGS\"\nexec \"$REMOTE_DAEMON_TEST\" -test.run=^TestRemoteSidechainProcess$\n"), 0o755))
	t.Cleanup(func() {
		o.StopAllMonitors()
		if o.process.IsRunning(cfg.Name) {
			require.NoError(t, o.Stop(context.Background(), cfg.Name, true, StopOptions{ForceBackend: true}))
		}
	})
	return cfg, env, argsPath
}

func TestRemoteSidechainBootsTheLocalDaemon(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	cfg, env, argsPath := installRemoteTestDaemon(t, o)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ch, err := o.StartWithL1(ctx, cfg.Name, StartOpts{ForceBackend: true, TargetEnv: env})
	require.NoError(t, err)
	var complete bool
	for p := range ch {
		require.NoError(t, p.Error)
		complete = complete || p.Done
	}
	require.True(t, complete)
	require.True(t, o.process.IsRunning(cfg.Name))
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
	args, err := os.ReadFile(argsPath)
	require.NoError(t, err)
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	require.Contains(t, string(args), "--mainchain-grpc-url="+endpoint)
	require.Contains(t, string(args), "--network=signet")
	require.Contains(t, string(args), "--headless")
}

func TestNodeModeChangeRestartsTheLocalDaemon(t *testing.T) {
	server := remoteValidatorServer(t, 42, nil)
	o := remoteTestOrchestrator(t, server.URL)
	cfg, env, argsPath := installRemoteTestDaemon(t, o)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	pid, err := o.process.StartWithOptions(context.Background(), cfg,
		[]string{"--headless", "--rpc-addr=" + cfg.RPCAddr(), "--mainchain-grpc-url=http://127.0.0.1:50051"},
		env, ProcessStartOptions{ForceBackend: true})
	require.NoError(t, err)
	require.Eventually(t, func() bool {
		return NewHealthChecker(cfg).Check(context.Background()) == nil
	}, 3*time.Second, 20*time.Millisecond)
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeLight))
	require.Eventually(t, func() bool {
		proc := o.process.Get(cfg.Name)
		return proc != nil && proc.Pid != pid && o.Status(cfg.Name).Connected
	}, 5*time.Second, 20*time.Millisecond)
	require.Equal(t, NodeModeLight, o.NodeMode())
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
	args, err := os.ReadFile(argsPath)
	require.NoError(t, err)
	endpoint, err := o.EnforcerURL()
	require.NoError(t, err)
	require.Contains(t, string(args), "--mainchain-grpc-url="+endpoint)
	require.Contains(t, string(args), "--rpc-addr="+cfg.RPCAddr())
}

func TestNodeModeChangeKeepsTheRestartError(t *testing.T) {
	var failure atomic.Bool
	failure.Store(true)
	server := remoteValidatorServer(t, 42, &failure)
	o := remoteTestOrchestrator(t, server.URL)
	cfg, env, _ := installRemoteTestDaemon(t, o)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	_, err := o.process.StartWithOptions(context.Background(), cfg, []string{"--headless"}, env,
		ProcessStartOptions{ForceBackend: true})
	require.NoError(t, err)
	require.Eventually(t, func() bool {
		return NewHealthChecker(cfg).Check(context.Background()) == nil
	}, 3*time.Second, 20*time.Millisecond)
	require.NoError(t, o.SetNodeMode(context.Background(), NodeModeLight))
	require.Eventually(t, func() bool {
		return strings.Contains(o.Status(cfg.Name).ConnectionError, "validator is offline")
	}, 5*time.Second, 20*time.Millisecond)
	require.Equal(t, NodeModeLight, o.NodeMode())
	require.False(t, o.process.IsRunning(cfg.Name))
}

func TestRemoteSidechainStopsBeforeAnUnavailableValidator(t *testing.T) {
	var failure atomic.Bool
	failure.Store(true)
	server := remoteValidatorServer(t, 42, &failure)
	o := remoteTestOrchestrator(t, server.URL)
	cfg, env, argsPath := installRemoteTestDaemon(t, o)
	ch, err := o.StartWithL1(context.Background(), cfg.Name, StartOpts{Immediate: true, ForceBackend: true, TargetEnv: env})
	require.NoError(t, err)
	var bootErr error
	for p := range ch {
		if p.Error != nil {
			bootErr = p.Error
		}
	}
	require.ErrorContains(t, bootErr, "validator is offline")
	require.False(t, o.process.IsRunning(cfg.Name))
	_, err = os.Stat(argsPath)
	require.ErrorIs(t, err, os.ErrNotExist)
	require.Contains(t, o.Status(cfg.Name).ConnectionError, "validator is offline")
}
