package elements_test

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
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
	parentCookie := os.Getenv("ELEMENTS_ALPHA_TEST_PARENT_COOKIE")
	require.NotEqual(t, credential == "", parentCookie == "", "select exactly one parent authentication mode")
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())
	datadir := t.TempDir()
	if os.Getenv("ELEMENTS_ALPHA_TEST_COOKIE_PROXY") == "1" {
		require.NotEmpty(t, credential)
		user, password, err := config.ReadCookieFile(credential)
		require.NoError(t, err)
		var secret [32]byte
		_, err = rand.Read(secret[:])
		require.NoError(t, err)
		cookiePassword := hex.EncodeToString(secret[:])
		endpoint := "http://127.0.0.1:" + strconv.Itoa(parentPort)
		proxy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			u, p, ok := r.BasicAuth()
			if !ok || u != "__cookie__" || p != cookiePassword {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}
			body, err := io.ReadAll(io.LimitReader(r.Body, 1<<20))
			var request struct {
				Method string `json:"method"`
			}
			if err != nil || json.Unmarshal(body, &request) != nil {
				w.WriteHeader(http.StatusBadRequest)
				return
			}
			switch request.Method {
			case "getnetworkinfo", "getblockchaininfo", "getblockhash", "getblockheader", "getblock", "getrawtransaction", "gettxout", "gettxoutproof", "getbestblockhash", "getblockcount":
			default:
				t.Logf("read-only parent proxy rejected RPC method %q", request.Method)
				w.WriteHeader(http.StatusForbidden)
				return
			}
			req, err := http.NewRequestWithContext(r.Context(), http.MethodPost, endpoint, bytes.NewReader(body))
			if err != nil {
				w.WriteHeader(http.StatusBadRequest)
				return
			}
			req.SetBasicAuth(user, password)
			req.Header.Set("Content-Type", "application/json")
			response, err := http.DefaultClient.Do(req)
			if err != nil {
				w.WriteHeader(http.StatusBadGateway)
				return
			}
			defer func() { _ = response.Body.Close() }()
			w.WriteHeader(response.StatusCode)
			_, _ = io.Copy(w, response.Body)
		}))
		t.Cleanup(proxy.Close)
		parentPort = proxy.Listener.Addr().(*net.TCPAddr).Port
		parentCookie = filepath.Join(datadir, "parent.cookie")
		require.NoError(t, os.WriteFile(parentCookie, []byte("__cookie__:"+cookiePassword), 0600))
		credential = ""
	}
	ctx, cancel := context.WithTimeout(context.Background(), 180*time.Second)
	t.Cleanup(cancel)
	peer := os.Getenv("ELEMENTS_ALPHA_TEST_PEER")
	if peer == "" {
		peer = "0"
	}
	args := []string{
		"-datadir=" + datadir, "-chain=elements", "-server=1", "-listen=0", "-connect=" + peer,
		"-rpcbind=127.0.0.1", "-rpcallowip=127.0.0.1", "-rpcport=" + strconv.Itoa(port),
		"-mainchainrpchost=127.0.0.1", "-mainchainrpcport=" + strconv.Itoa(parentPort),
		"-drivechainl1blocksync=0"}
	if parentCookie != "" {
		oldNetwork := config.ECashNetworkID()
		config.SetECashNetworkID("alphanet")
		t.Cleanup(func() { config.SetECashNetworkID(oldNetwork) })
		options := config.ElementsAlphaOptions{Network: config.NetworkECash, DataDir: datadir, ParentHost: "127.0.0.1", ParentPort: parentPort, ParentCookie: parentCookie, RPCPort: port, P2PPort: 7066}
		args, err = options.Install()
		require.NoError(t, err)
		again, err := options.Install()
		require.NoError(t, err)
		require.Equal(t, args, again)
		args = append(args, "-listen=0", "-connect="+peer)
	} else {
		require.True(t, filepath.IsAbs(credential))
		args = append(args, "-mainchainrpccredentialfile="+credential)
	}
	cmd := exec.CommandContext(ctx, binary, args...)
	var diagnostics bytes.Buffer
	cmd.Stdout, cmd.Stderr = &diagnostics, &diagnostics
	require.NoError(t, cmd.Start())
	t.Cleanup(func() {
		if cmd.Process != nil {
			_ = cmd.Process.Signal(os.Interrupt)
			_ = cmd.Wait()
		}
		if t.Failed() {
			t.Log(diagnostics.String())
		}
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
	// Restart the same datadir and confirm the wallet and rotated RPC cookie work.
	require.NoError(t, cmd.Process.Signal(os.Interrupt))
	require.NoError(t, cmd.Wait())
	cmd = exec.CommandContext(ctx, binary, args...)
	cmd.Stdout, cmd.Stderr = &diagnostics, &diagnostics
	require.NoError(t, cmd.Start())
	require.Eventually(t, func() bool { return node.VerifyAlpha(ctx) == nil }, 60*time.Second, 250*time.Millisecond)
	user, password, err = config.ReadCookieFile(cookie)
	require.NoError(t, err)
	rpc = wallet.NewCoreRPCClient(wallet.StaticCoreEndpoint("127.0.0.1", port, user, password))
	require.NoError(t, wallet.EnsureCoreWalletFromMnemonic(ctx, rpc, zerolog.Nop(), sidechain.CoreWalletName, mnemonic, config.ElementsAlphaWalletParams()))
	address, err = node.GetNewAddress(ctx)
	require.NoError(t, err)
	require.Contains(t, address, "elements1")
}
