package orchestrator

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/elements"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

// Downloads the published artifact; the parent relay permits no wallet or spending RPCs.
func TestElementsPublishedOneClickInstall(t *testing.T) {
	if os.Getenv("ELEMENTS_ALPHA_TEST_INSTALL") != "1" {
		t.Skip("set ELEMENTS_ALPHA_TEST_INSTALL=1 and local parent credentials")
	}
	candidate, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	require.NoError(t, checkElementsSetup(candidate), "this platform needs a published, pinned Alpha release")
	testElementsOneClickInstall(t, candidate)
}

// Qualify a release candidate through the installer before publishing it. This
// supplies test-only metadata; it never changes the production download pins.
func TestElementsCandidateOneClickInstall(t *testing.T) {
	archivePath := os.Getenv("ELEMENTS_ALPHA_TEST_ARCHIVE")
	if archivePath == "" {
		t.Skip("set ELEMENTS_ALPHA_TEST_ARCHIVE, ELEMENTS_ALPHA_TEST_EXECUTABLE_SHA256 and local parent credentials")
	}
	payload, err := os.ReadFile(archivePath)
	require.NoError(t, err)
	digest := sha256.Sum256(payload)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(payload) }))
	defer server.Close()
	candidate, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	candidate.DownloadURLs = map[string]string{"default": server.URL + "/"}
	candidate.Files = map[string]string{currentPlatform(): filepath.Base(archivePath)}
	candidate.ArtifactPins = map[string]ArtifactPin{currentPlatform(): {
		ArchiveSHA256:    hex.EncodeToString(digest[:]),
		ExecutableSHA256: os.Getenv("ELEMENTS_ALPHA_TEST_EXECUTABLE_SHA256"),
	}}
	require.NoError(t, checkElementsSetup(candidate))
	testElementsOneClickInstall(t, candidate)
}

func testElementsOneClickInstall(t *testing.T, candidate BinaryConfig) {
	t.Helper()
	old := config.ECashNetworkID()
	config.SetECashNetworkID("alphanet")
	t.Cleanup(func() { config.SetECashNetworkID(old) })
	o := planFixture(t, "ecash")
	o.configs[candidate.Name] = candidate
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeFull))
	require.NoError(t, o.BitcoinConf.UpdateDataDir(t.TempDir(), config.NetworkECash))
	port, cookie := elementsReadOnlyParent(t)
	o.BitcoinConf.Config.SetSetting("rpcport", strconv.Itoa(port), "main")
	o.BitcoinConf.Config.SetSetting("rpccookiefile", cookie, "main")
	require.Equal(t, port, o.BitcoinConf.GetRPCPort())
	require.Equal(t, cookie, o.BitcoinConf.GetRPCCookiePath())
	core := o.configs["bitcoind"]
	core.Port = port
	o.configs["bitcoind"] = core
	delete(o.configs, "enforcer")
	cfg := o.configs["liquid-signet"]
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	cfg.Port = listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())
	o.configs[cfg.Name] = cfg
	o.WalletSvc = wallet.NewService(o.BitwindowDir, testLogger(t))
	_, err = o.WalletSvc.GenerateWallet("Unfunded installer test", "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", "", []wallet.SidechainSlot{{Slot: 24, Name: "Elements Alpha"}})
	require.NoError(t, err)
	// Cold parent replay on Windows can take several minutes, especially under
	// filesystem scanning. Keep a finite budget without treating it as a crash.
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	t.Cleanup(func() {
		o.StopAllMonitors()
		stopCtx, stopCancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer stopCancel()
		require.NoError(t, o.Stop(stopCtx, cfg.Name, true))
		cancel()
	})
	finish := func(ch <-chan StartupProgress, err error) {
		t.Helper()
		require.NoError(t, err)
		done := false
		for p := range ch {
			require.NoError(t, p.Error, p.Stage)
			done = done || p.Done
		}
		require.True(t, done)
	}
	finish(o.StartWithL1(ctx, cfg.Name, StartOpts{}))
	require.False(t, o.process.IsRunning("enforcer"))
	dirs, ok := config.DirConfigByName(cfg.Name)
	require.True(t, ok)
	node := elements.NewNode("127.0.0.1", cfg.Port, filepath.Join(dirs.DatadirNetwork(config.NetworkECash, ""), config.ElementsAlphaChainDir, ".cookie"))
	require.NoError(t, node.VerifyAlpha(ctx))
	address, err := node.GetNewAddress(ctx)
	require.NoError(t, err)
	require.Contains(t, address, "elements1")
	total, available, err := node.GetBalance(ctx)
	require.NoError(t, err)
	require.Zero(t, total)
	require.Zero(t, available)
	finish(o.StartWithL1(ctx, cfg.Name, StartOpts{}))
	finish(o.RestartDaemon(ctx, cfg.Name))
	require.NoError(t, node.VerifyAlpha(ctx))
	raw, err := node.Call(ctx, "getaddressinfo", []any{address})
	require.NoError(t, err)
	var info struct {
		IsMine bool `json:"ismine"`
	}
	require.NoError(t, json.Unmarshal(raw, &info))
	require.True(t, info.IsMine, "restart must preserve the installed wallet")
}

func elementsReadOnlyParent(t *testing.T) (int, string) {
	t.Helper()
	port, err := strconv.Atoi(os.Getenv("ELEMENTS_ALPHA_TEST_PARENT_PORT"))
	require.NoError(t, err)
	require.Positive(t, port)
	user, password, err := config.ReadCookieFile(os.Getenv("ELEMENTS_ALPHA_TEST_PARENT_CREDENTIAL_FILE"))
	require.NoError(t, err)
	var secret [32]byte
	_, err = rand.Read(secret[:])
	require.NoError(t, err)
	localPassword := hex.EncodeToString(secret[:])
	client := &http.Client{Timeout: 30 * time.Second}
	proxy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		u, p, ok := r.BasicAuth()
		if !ok || u != "__cookie__" || p != localPassword {
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
			t.Logf("read-only relay rejected %s", request.Method)
			w.WriteHeader(http.StatusForbidden)
			return
		}
		req, err := http.NewRequestWithContext(r.Context(), http.MethodPost, "http://127.0.0.1:"+strconv.Itoa(port), bytes.NewReader(body))
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		req.SetBasicAuth(user, password)
		req.Header.Set("Content-Type", "application/json")
		response, err := client.Do(req)
		if err != nil {
			w.WriteHeader(http.StatusBadGateway)
			return
		}
		defer response.Body.Close()
		w.WriteHeader(response.StatusCode)
		_, _ = io.Copy(w, response.Body)
	}))
	t.Cleanup(proxy.Close)
	cookie := filepath.Join(t.TempDir(), "parent.cookie")
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:"+localPassword), 0600))
	return proxy.Listener.Addr().(*net.TCPAddr).Port, cookie
}
