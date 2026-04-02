package testharness

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
	"syscall"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

// Node represents a single test node: bitcoind + wallet stack + gRPC server.
type Node struct {
	Name            string
	Datadir         string
	BitcoindProcess *os.Process
	BitcoindRPCPort int
	BitcoindP2PPort int
	GRPCPort        int

	// In-process components
	WalletService *wallet.Service
	WalletEngine  *wallet.WalletEngine
	CoreRPC       *wallet.CoreRPCClient

	// gRPC client to this node's wallet manager
	WalletClient rpc.WalletManagerServiceClient

	log        zerolog.Logger
	httpServer *http.Server
	closeOnce  sync.Once
}

// newNode creates and starts a fully-wired Node.
func newNode(
	t *testing.T,
	name, datadir, bitcoindBin string,
	rpcPort, p2pPort int,
	log zerolog.Logger,
) *Node {
	t.Helper()

	nlog := log.With().Str("node", name).Logger()

	n := &Node{
		Name:            name,
		Datadir:         datadir,
		BitcoindRPCPort: rpcPort,
		BitcoindP2PPort: p2pPort,
		log:             nlog,
	}

	// 1. Write bitcoin.conf
	confDir := filepath.Join(datadir, "bitcoin")
	if err := os.MkdirAll(confDir, 0700); err != nil {
		t.Fatalf("testharness[%s]: mkdir bitcoin conf: %v", name, err)
	}
	conf := fmt.Sprintf(`regtest=1
server=1
rpcuser=test
rpcpassword=test
rpcport=%d
port=%d
txindex=1
fallbackfee=0.00001
[regtest]
rpcport=%d
port=%d
`, rpcPort, p2pPort, rpcPort, p2pPort)

	confPath := filepath.Join(confDir, "bitcoin.conf")
	if err := os.WriteFile(confPath, []byte(conf), 0600); err != nil {
		t.Fatalf("testharness[%s]: write bitcoin.conf: %v", name, err)
	}

	// 2. Start bitcoind
	cmd := exec.Command(
		bitcoindBin,
		"-regtest",
		fmt.Sprintf("-datadir=%s", confDir),
		"-daemon=0",
		"-printtoconsole=0",
	)
	cmd.Stdout = nil
	cmd.Stderr = nil
	if err := cmd.Start(); err != nil {
		t.Fatalf("testharness[%s]: start bitcoind: %v", name, err)
	}
	n.BitcoindProcess = cmd.Process
	nlog.Info().Int("pid", cmd.Process.Pid).Int("rpc", rpcPort).Int("p2p", p2pPort).Msg("bitcoind started")

	// Register cleanup to kill bitcoind even on panic.
	t.Cleanup(func() {
		if n.BitcoindProcess != nil {
			_ = n.BitcoindProcess.Signal(syscall.SIGTERM)
			_, _ = n.BitcoindProcess.Wait()
		}
	})

	// Wait for background process to exit (so we don't orphan).
	go func() {
		_ = cmd.Wait()
	}()

	// 3. Poll getblockchaininfo until ready.
	n.CoreRPC = wallet.NewCoreRPCClient("127.0.0.1", rpcPort, "test", "test")
	waitForBitcoind(t, n.CoreRPC, name)

	// 4. Create wallet.Service with a temp wallet dir.
	walletDir := filepath.Join(datadir, "wallets")
	if err := os.MkdirAll(walletDir, 0700); err != nil {
		t.Fatalf("testharness[%s]: mkdir wallets: %v", name, err)
	}
	n.WalletService = wallet.NewService(walletDir, nlog)
	if err := n.WalletService.Init(); err != nil {
		t.Fatalf("testharness[%s]: init wallet service: %v", name, err)
	}

	// 5. Create WalletEngine.
	n.WalletEngine = wallet.NewWalletEngine(n.WalletService, n.CoreRPC, "regtest", nlog)

	// 6. Start ConnectRPC server in-process.
	walletHandler := api.NewWalletHandler(n.WalletService)
	walletHandler.SetEngine(n.WalletEngine)
	svcPath, svcHandler := rpc.NewWalletManagerServiceHandler(walletHandler)
	mux := http.NewServeMux()
	mux.Handle(svcPath, svcHandler)

	// Bind a listener now to avoid port races — let the OS pick the port.
	lis, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("testharness[%s]: listen grpc: %v", name, err)
	}
	n.GRPCPort = lis.Addr().(*net.TCPAddr).Port

	n.httpServer = &http.Server{
		Handler: h2c.NewHandler(mux, &http2.Server{}),
	}
	go func() {
		if srvErr := n.httpServer.Serve(lis); srvErr != nil && srvErr != http.ErrServerClosed {
			nlog.Error().Err(srvErr).Msg("gRPC server error")
		}
	}()
	nlog.Info().Int("port", n.GRPCPort).Msg("gRPC server started")

	// 7. Create ConnectRPC client (uses Connect protocol over h2c).
	n.WalletClient = rpc.NewWalletManagerServiceClient(
		http.DefaultClient,
		fmt.Sprintf("http://127.0.0.1:%d", n.GRPCPort),
	)

	return n
}

// close shuts down the node's gRPC server, wallet service, and bitcoind.
func (n *Node) close() {
	n.closeOnce.Do(func() {
		if n.httpServer != nil {
			ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
			defer cancel()
			_ = n.httpServer.Shutdown(ctx)
		}
		if n.WalletService != nil {
			n.WalletService.Close()
		}
		if n.BitcoindProcess != nil {
			_ = n.BitcoindProcess.Signal(syscall.SIGTERM)
			_, _ = n.BitcoindProcess.Wait()
			n.BitcoindProcess = nil
		}
	})
}

// waitForBitcoind polls getblockchaininfo until the node responds or times out.
func waitForBitcoind(t *testing.T, rpcClient *wallet.CoreRPCClient, nodeName string) {
	t.Helper()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	for {
		select {
		case <-ctx.Done():
			t.Fatalf("testharness[%s]: bitcoind did not become ready within 30s", nodeName)
		default:
		}

		result, err := rpcClient.GetBlockchainInfo(ctx)
		if err == nil && result != nil {
			return
		}
		time.Sleep(250 * time.Millisecond)
	}
}

// GenerateToAddress mines blocks to the given address using the raw RPC client.
func (n *Node) GenerateToAddress(ctx context.Context, blocks int, addr string) ([]string, error) {
	return n.CoreRPC.GenerateToAddress(ctx, blocks, addr)
}
