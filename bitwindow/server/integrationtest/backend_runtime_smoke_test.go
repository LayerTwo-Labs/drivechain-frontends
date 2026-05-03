//go:build integration && !windows

package integrationtest

import (
	"bufio"
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"testing"
	"time"

	"connectrpc.com/connect"
	healthv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1"
	healthv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	orchconfig "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	walletpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	walletrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"
)

const testEnforcerMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

func TestBackendRuntimeOwnershipSmoke(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 4*time.Minute)
	defer cancel()

	node := newOrchestratorOnlyNode(t)
	defer node.Close(t)

	_, err := node.WalletClient.GenerateWallet(ctx, connect.NewRequest(&walletpb.GenerateWalletRequest{
		Name:           "backend-runtime-enforcer",
		CustomMnemonic: testEnforcerMnemonic,
	}))
	require.NoError(t, err)

	bitwindowdBin := buildBitwindowd(t, t.TempDir())
	apiHost := pickLocalhostAddr(t)
	bitwindowdURL := "http://" + apiHost
	logDir := prepareLogDir(t)

	proc := startBitwindowd(t, bitwindowdBin, node, apiHost, logDir)
	defer stopCmdProcess(t, proc)

	healthClient := healthv1connect.NewHealthServiceClient(http.DefaultClient, bitwindowdURL)
	orchClient := orchrpc.NewOrchestratorServiceClient(http.DefaultClient, fmt.Sprintf("http://127.0.0.1:%d", node.OrchdGRPCPort), connect.WithGRPC())

	waitForBitwindowdHealth(t, ctx, healthClient)
	waitForBinaryReady(t, ctx, orchClient, "bitcoind")
	waitForEnforcerBlockchainInfo(t, ctx, orchClient)

	mainchainInfo, err := orchClient.GetMainchainBlockchainInfo(ctx, connect.NewRequest(&orchpb.GetMainchainBlockchainInfoRequest{}))
	require.NoError(t, err)
	require.Equal(t, "regtest", mainchainInfo.Msg.GetChain())

	enforcerInfo, err := orchClient.GetEnforcerBlockchainInfo(ctx, connect.NewRequest(&orchpb.GetEnforcerBlockchainInfoRequest{}))
	require.NoError(t, err)
	require.GreaterOrEqual(t, enforcerInfo.Msg.GetBlocks(), int32(0))

	statusResp, err := healthClient.Check(ctx, connect.NewRequest(&emptypb.Empty{}))
	require.NoError(t, err)
	require.Equal(t, healthv1.CheckResponse_STATUS_SERVING, serviceStatus(statusResp.Msg, "bitcoind"))
}

func buildBitwindowd(t *testing.T, outDir string) string {
	t.Helper()

	binName := "bitwindowd"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	binPath := filepath.Join(outDir, binName)

	cmd := exec.Command("go", "build", "-o", binPath, ".")
	cmd.Dir = filepath.Join(repoRoot(t), "bitwindow", "server")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	require.NoError(t, cmd.Run())

	return binPath
}

func repoRoot(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	require.True(t, ok)
	return filepath.Clean(filepath.Join(filepath.Dir(thisFile), "..", "..", ".."))
}

func pickLocalhostAddr(t *testing.T) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	addr := ln.Addr().String()
	require.NoError(t, ln.Close())
	return addr
}

func prepareLogDir(t *testing.T) string {
	t.Helper()
	base := os.Getenv("BITWINDOW_TEST_LOG_DIR")
	if base == "" {
		base = t.TempDir()
	}
	logDir := filepath.Join(base, t.Name())
	require.NoError(t, os.MkdirAll(logDir, 0o755))
	return logDir
}

func startBitwindowd(t *testing.T, binPath string, node *orchestratorOnlyNode, apiHost, logDir string) *exec.Cmd {
	t.Helper()

	stdoutFile, err := os.Create(filepath.Join(logDir, "bitwindowd.stdout.log"))
	require.NoError(t, err)
	stderrFile, err := os.Create(filepath.Join(logDir, "bitwindowd.stderr.log"))
	require.NoError(t, err)

	// bitcoincore.* flags were removed when bitwindowd started sourcing
	// Bitcoin Core config from the orchestrator (see commit caff0cb0). The
	// orchestrator owns bitcoin.conf; bitwindowd looks it up via the
	// orchestrator gRPC connection.
	cmd := exec.Command(
		binPath,
		"--datadir", node.BitwindowDir,
		"--api.host", apiHost,
		"--enforcer.host", fmt.Sprintf("127.0.0.1:%d", node.EnforcerGRPCPort),
		"--orchestrator.addr", fmt.Sprintf("http://127.0.0.1:%d", node.OrchdGRPCPort),
	)
	cmd.Stdout = stdoutFile
	cmd.Stderr = stderrFile

	require.NoError(t, cmd.Start())

	go streamLogFileToTest(t, "bitwindowd.stdout", stdoutFile)
	go streamLogFileToTest(t, "bitwindowd.stderr", stderrFile)

	t.Cleanup(func() {
		_ = stdoutFile.Close()
		_ = stderrFile.Close()
	})

	return cmd
}

type orchestratorOnlyNode struct {
	RootDir          string
	BitwindowDir     string
	BitcoinDataDir   string
	BitcoindRPCPort  int
	BitcoindP2PPort  int
	OrchdGRPCPort    int
	OrchdCmd         *exec.Cmd
	EnforcerGRPCPort int
	WalletClient     walletrpc.WalletManagerServiceClient
}

func newOrchestratorOnlyNode(t *testing.T) *orchestratorOnlyNode {
	t.Helper()

	rootDir := t.TempDir()
	bitcoindBin := findBitcoind(t)
	orchBin := buildOrchestratord(t, rootDir)
	basePort := randomPortBase(t)
	rpcPort := basePort
	p2pPort := basePort + 100
	grpcPort := basePort + 200
	prepareEnforcerConfigForSmokeTest(t, basePort+210, basePort+211, basePort+212)

	nodeDir := filepath.Join(rootDir, "node0")
	bitwindowDir := filepath.Join(nodeDir, "bitwindow")
	bitcoinDataDir := filepath.Join(nodeDir, "bitcoin")
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o700))
	require.NoError(t, os.MkdirAll(bitcoinDataDir, 0o700))
	// Pin the orchestrator under test to the core variant so we can
	// drop the locally-built bitcoind into its variant subfolder.
	require.NoError(t, os.WriteFile(
		filepath.Join(bitwindowDir, "orchestrator_settings.json"),
		[]byte(`{"core_variant":"core"}`),
		0o600,
	))
	smokeConfigs := orchestrator.AllDefaults()
	bitcoindDestPath := orchestrator.ActiveCoreBinaryPath(bitwindowDir, bitwindowDir, smokeConfigs, "bitcoind")
	copyManagedBinary(t, bitcoindBin, bitcoindDestPath)
	enforcerBin := findEnforcer(t)
	copyManagedBinary(t, enforcerBin, orchestrator.BinaryPath(bitwindowDir, "bip300301-enforcer"))

	bitwindowBitcoinConf := fmt.Sprintf(`# Generated by backend smoke test
regtest=1
server=1
daemon=0
printtoconsole=0
txindex=1
rest=1
zmqpubsequence=tcp://127.0.0.1:29000
fallbackfee=0.00001
rpcuser=test
rpcpassword=test
datadir=%s
[regtest]
rpcport=%d
port=%d
`, bitcoinDataDir, rpcPort, p2pPort)
	require.NoError(t, os.WriteFile(filepath.Join(bitwindowDir, "bitwindow-bitcoin.conf"), []byte(bitwindowBitcoinConf), 0o600))

	// `--binary=enforcer` auto-boots the L1 stack (bitcoind → enforcer)
	// once orchestratord comes up, since the smoke test asserts both are
	// running. Production normally triggers this via StartWithL1; the
	// orchestratord CLI flag is the same code path, just kicked from main.
	orchCmd := exec.Command(orchBin,
		"--datadir", bitwindowDir,
		"--bitwindow-dir", bitwindowDir,
		"--network", "regtest",
		"--rpclisten", fmt.Sprintf("127.0.0.1:%d", grpcPort),
		"--loglevel", "info",
		"--binary=enforcer",
	)
	orchStdout, err := orchCmd.StdoutPipe()
	require.NoError(t, err)
	orchStderr, err := orchCmd.StderrPipe()
	require.NoError(t, err)
	require.NoError(t, orchCmd.Start())

	ready := make(chan struct{})
	go watchForReadyLine(t, orchStdout, ready)
	go logScanner(t, "orchd.stderr", orchStderr)

	select {
	case <-ready:
	case <-time.After(20 * time.Second):
		t.Fatal("orchestratord did not start serving within 20s")
	}

	node := &orchestratorOnlyNode{
		RootDir:          rootDir,
		BitwindowDir:     bitwindowDir,
		BitcoinDataDir:   bitcoinDataDir,
		BitcoindRPCPort:  rpcPort,
		BitcoindP2PPort:  p2pPort,
		OrchdGRPCPort:    grpcPort,
		OrchdCmd:         orchCmd,
		EnforcerGRPCPort: basePort + 212,
		WalletClient: walletrpc.NewWalletManagerServiceClient(
			http.DefaultClient,
			fmt.Sprintf("http://127.0.0.1:%d", grpcPort),
			connect.WithGRPC(),
		),
	}

	_ = bitcoindBin
	return node
}

func prepareEnforcerConfigForSmokeTest(t *testing.T, rpcPort, jsonRPCPort, grpcPort int) {
	t.Helper()
	confDir := orchconfig.EnforcerDirs.RootDir()
	confPath := filepath.Join(confDir, "bitwindow-enforcer.conf")
	require.NoError(t, os.MkdirAll(confDir, 0o755))

	var original []byte
	if data, err := os.ReadFile(confPath); err == nil {
		original = data
	} else {
		require.True(t, os.IsNotExist(err), "read enforcer config: %v", err)
	}

	content := fmt.Sprintf(`# bitwindow-enforcer-conf-version=2

enable-wallet=false
enable-mempool=true
wallet-esplora-url=
serve-rpc-addr=127.0.0.1:%d
serve-json-rpc-addr=127.0.0.1:%d
serve-grpc-addr=127.0.0.1:%d
`, rpcPort, jsonRPCPort, grpcPort)
	require.NoError(t, os.WriteFile(confPath, []byte(content), 0o644))

	t.Cleanup(func() {
		if original == nil {
			_ = os.Remove(confPath)
			return
		}
		_ = os.WriteFile(confPath, original, 0o644)
	})
}

func copyManagedBinary(t *testing.T, srcPath, dstPath string) {
	t.Helper()
	data, err := os.ReadFile(srcPath)
	require.NoError(t, err)
	require.NoError(t, os.MkdirAll(filepath.Dir(dstPath), 0o755))
	require.NoError(t, os.WriteFile(dstPath, data, 0o755))
}

func homeDir(t *testing.T) string {
	t.Helper()
	home, err := os.UserHomeDir()
	require.NoError(t, err)
	return home
}

func (n *orchestratorOnlyNode) Close(t *testing.T) {
	t.Helper()
	if n.OrchdCmd != nil {
		stopCmdProcess(t, n.OrchdCmd)
	}
}

func findEnforcer(t *testing.T) string {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()
	dataDir := orchestrator.DefaultDataDir()
	orchPath := orchestrator.BinaryPath(dataDir, "bip300301-enforcer")

	if _, err := os.Stat(orchPath); err == nil {
		log.Info().Str("path", orchPath).Msg("found bip300301-enforcer binary")
		return orchPath
	}

	configPath := orchestrator.ConfigFilePath(orchestrator.DefaultBitwindowDir())
	configs := orchestrator.LoadConfigFile(configPath, log)
	var enforcerConfig *orchestrator.BinaryConfig
	for i := range configs {
		if configs[i].Name == "enforcer" {
			enforcerConfig = &configs[i]
			break
		}
	}
	require.NotNil(t, enforcerConfig)

	dm := orchestrator.NewDownloadManager(dataDir, configPath, log)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	progressCh, err := dm.Download(ctx, *enforcerConfig, "regtest", true)
	require.NoError(t, err)
	for p := range progressCh {
		require.NoError(t, p.Error)
	}

	require.FileExists(t, orchPath)
	return orchPath
}

func findBitcoind(t *testing.T) string {
	t.Helper()
	log := zerolog.New(zerolog.NewTestWriter(t)).With().Timestamp().Logger()
	dataDir := orchestrator.DefaultDataDir()
	bitwindowDir := orchestrator.DefaultBitwindowDir()
	configPath := orchestrator.ConfigFilePath(bitwindowDir)
	configs := orchestrator.LoadConfigFile(configPath, log)
	orchPath := orchestrator.ActiveCoreBinaryPath(dataDir, bitwindowDir, configs, "bitcoind")

	if _, err := os.Stat(orchPath); err == nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := exec.CommandContext(ctx, orchPath, "--version").Run(); err == nil {
			log.Info().Str("path", orchPath).Msg("found working bitcoind via orchestrator")
			return orchPath
		}
	}

	var bitcoindConfig *orchestrator.BinaryConfig
	for i := range configs {
		if configs[i].Name == "bitcoind" {
			bitcoindConfig = &configs[i]
			break
		}
	}
	require.NotNil(t, bitcoindConfig)

	dm := orchestrator.NewDownloadManager(dataDir, configPath, log)
	// bitcoind downloads are now variant-keyed; pick a regtest-compatible
	// variant explicitly since we don't have a full Orchestrator here.
	variant := bitcoindConfig.Variants["core"]
	dm.CoreVariant = func() (orchestrator.CoreVariantSpec, bool) { return variant, true }
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	progressCh, err := dm.Download(ctx, *bitcoindConfig, "regtest", true)
	require.NoError(t, err)
	for p := range progressCh {
		require.NoError(t, p.Error)
	}

	downloadedPath := orchestrator.CoreBinaryPath(dataDir, variant, "bitcoind")
	verifyCtx, verifyCancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer verifyCancel()
	require.NoError(t, exec.CommandContext(verifyCtx, downloadedPath, "--version").Run())
	return downloadedPath
}

func buildOrchestratord(t *testing.T, outDir string) string {
	t.Helper()
	binName := "orchestratord"
	if runtime.GOOS == "windows" {
		binName += ".exe"
	}
	binPath := filepath.Join(outDir, binName)
	cmd := exec.Command("go", "build", "-o", binPath, ".")
	cmd.Dir = filepath.Join(repoRoot(t), "sidechain-orchestrator", "cmd", "orchestratord")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	require.NoError(t, cmd.Run())
	return binPath
}

func randomPortBase(t *testing.T) int {
	t.Helper()
	b := make([]byte, 2)
	_, err := rand.Read(b)
	require.NoError(t, err)
	return 40000 + int(b[0])%190*100
}

func watchForReadyLine(t *testing.T, r io.ReadCloser, ready chan<- struct{}) {
	t.Helper()
	scanner := bufio.NewScanner(r)
	readyClosed := false
	for scanner.Scan() {
		line := scanner.Text()
		t.Logf("orchd.stdout: %s", line)
		if !readyClosed && strings.Contains(line, "serving gRPC") {
			close(ready)
			readyClosed = true
		}
	}
}

func logScanner(t *testing.T, prefix string, r io.ReadCloser) {
	t.Helper()
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		t.Logf("%s: %s", prefix, scanner.Text())
	}
}

func streamLogFileToTest(t *testing.T, prefix string, f *os.File) {
	t.Helper()
	if _, err := f.Seek(0, 0); err != nil {
		return
	}
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		t.Logf("%s: %s", prefix, scanner.Text())
	}
}

func waitForBitwindowdHealth(t *testing.T, ctx context.Context, client healthv1connect.HealthServiceClient) {
	t.Helper()

	var lastErr error
	deadline := time.Now().Add(90 * time.Second)
	for time.Now().Before(deadline) {
		resp, err := client.Check(ctx, connect.NewRequest(&emptypb.Empty{}))
		if err == nil {
			require.NotNil(t, resp.Msg)
			return
		}
		lastErr = err
		time.Sleep(500 * time.Millisecond)
	}

	require.NoError(t, lastErr)
}

func waitForBinaryReady(t *testing.T, ctx context.Context, client orchrpc.OrchestratorServiceClient, name string) *orchpb.BinaryStatusMsg {
	t.Helper()

	var (
		lastStatus *orchpb.BinaryStatusMsg
		lastErr    error
	)

	deadline := time.Now().Add(2 * time.Minute)
	for time.Now().Before(deadline) {
		resp, err := client.GetBinaryStatus(ctx, connect.NewRequest(&orchpb.GetBinaryStatusRequest{Name: name}))
		if err == nil {
			lastStatus = resp.Msg.GetStatus()
			if lastStatus.GetRunning() && lastStatus.GetConnected() && lastStatus.GetHealthy() {
				return lastStatus
			}
		} else {
			lastErr = err
		}
		time.Sleep(1 * time.Second)
	}

	if lastErr != nil {
		require.NoError(t, lastErr)
	}
	require.NotNil(t, lastStatus, "missing %s status", name)
	require.Truef(t, lastStatus.GetRunning(), "%s should be running: %+v", name, lastStatus)
	require.Truef(t, lastStatus.GetConnected(), "%s should be connected: %+v", name, lastStatus)
	require.Truef(t, lastStatus.GetHealthy(), "%s should be healthy: %+v", name, lastStatus)
	return lastStatus
}

func waitForEnforcerBlockchainInfo(t *testing.T, ctx context.Context, client orchrpc.OrchestratorServiceClient) {
	t.Helper()

	var lastErr error
	deadline := time.Now().Add(2 * time.Minute)
	for time.Now().Before(deadline) {
		resp, err := client.GetEnforcerBlockchainInfo(ctx, connect.NewRequest(&orchpb.GetEnforcerBlockchainInfoRequest{}))
		if err == nil {
			require.NotNil(t, resp.Msg)
			return
		}
		lastErr = err
		time.Sleep(1 * time.Second)
	}

	require.NoError(t, lastErr)
}

func serviceStatus(resp *healthv1.CheckResponse, serviceName string) healthv1.CheckResponse_Status {
	for _, status := range resp.GetServiceStatuses() {
		if status.GetServiceName() == serviceName {
			return status.GetStatus()
		}
	}
	return healthv1.CheckResponse_STATUS_SERVICE_UNKNOWN
}

func stopCmdProcess(t *testing.T, cmd *exec.Cmd) {
	t.Helper()
	if cmd == nil || cmd.Process == nil {
		return
	}
	_ = cmd.Process.Signal(syscall.SIGTERM)
	done := make(chan error, 1)
	go func() { done <- cmd.Wait() }()
	select {
	case err := <-done:
		if err != nil && !isExpectedExit(err) {
			t.Logf("bitwindowd exit error: %v", err)
		}
	case <-time.After(10 * time.Second):
		_ = cmd.Process.Kill()
		<-done
	}
}

func isExpectedExit(err error) bool {
	if err == nil {
		return true
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		return exitErr.ExitCode() == 0 || exitErr.ExitCode() == -1
	}
	return strings.Contains(err.Error(), "signal: terminated")
}
