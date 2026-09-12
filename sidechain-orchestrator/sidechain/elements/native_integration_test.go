package elements_test

import (
	"context"
	"encoding/json"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/elements"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// This opt-in test creates only an isolated, unfunded wallet with a public test seed.
func TestElementsNativeWalletIntegration(t *testing.T) {
	binary := os.Getenv("ELEMENTS_ALPHA_TEST_BINARY")
	if binary == "" {
		t.Skip("set ELEMENTS_ALPHA_TEST_BINARY and local parent credentials")
	}
	parentPort, err := strconv.Atoi(os.Getenv("ELEMENTS_ALPHA_TEST_PARENT_PORT"))
	require.NoError(t, err)
	require.Greater(t, parentPort, 0)
	credential := os.Getenv("ELEMENTS_ALPHA_TEST_PARENT_CREDENTIAL_FILE")
	require.True(t, filepath.IsAbs(credential))
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())
	datadir := t.TempDir()
	ctx, cancel := context.WithTimeout(context.Background(), 180*time.Second)
	t.Cleanup(cancel)
	peer := os.Getenv("ELEMENTS_ALPHA_TEST_PEER")
	if peer == "" {
		peer = "0"
	}
	cmd := exec.CommandContext(ctx, binary,
		"-datadir="+datadir, "-chain=elements", "-server=1", "-listen=0", "-connect="+peer,
		"-rpcbind=127.0.0.1", "-rpcallowip=127.0.0.1", "-rpcport="+strconv.Itoa(port),
		"-mainchainrpchost=127.0.0.1", "-mainchainrpcport="+strconv.Itoa(parentPort),
		"-mainchainrpccredentialfile="+credential, "-drivechainl1blocksync=0")
	require.NoError(t, cmd.Start())
	t.Cleanup(func() {
		_ = cmd.Process.Signal(os.Interrupt)
		_ = cmd.Wait()
	})
	cookie := filepath.Join(datadir, config.ElementsAlphaChainDir, ".cookie")
	node := elements.NewNode("127.0.0.1", port, cookie)
	require.Eventually(t, func() bool { return node.VerifyAlpha(ctx) == nil }, 60*time.Second, 250*time.Millisecond)
	user, password, err := config.ReadCookieFile(cookie)
	require.NoError(t, err)
	rpc := wallet.NewCoreRPCClient(wallet.StaticCoreEndpoint("127.0.0.1", port, user, password))
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	for range 2 {
		require.NoError(t, wallet.EnsureCoreWalletFromMnemonic(ctx, rpc, zerolog.Nop(), sidechain.CoreWalletName, mnemonic, config.ElementsAlphaWalletParams()))
	}
	address, err := node.GetNewAddress(ctx)
	require.NoError(t, err)
	require.Contains(t, address, "elements1")
	total, available, err := node.GetBalance(ctx)
	require.NoError(t, err)
	require.Zero(t, total)
	require.Zero(t, available)
	if minimum := os.Getenv("ELEMENTS_ALPHA_TEST_MIN_HEIGHT"); minimum != "" {
		height, err := strconv.Atoi(minimum)
		require.NoError(t, err)
		require.Positive(t, height)
		require.Eventually(t, func() bool {
			raw, err := node.Call(ctx, "getblockchaininfo", nil)
			if err != nil {
				return false
			}
			var info struct {
				Blocks int `json:"blocks"`
			}
			return json.Unmarshal(raw, &info) == nil && info.Blocks >= height
		}, 120*time.Second, time.Second)
	}
}
