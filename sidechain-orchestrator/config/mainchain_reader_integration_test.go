//go:build integration

package config

import (
	"bytes"
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// Run: BITCOIND=/path/to/bitcoind go test -tags integration -run TestMainchainReader ./config/
func TestMainchainReaderIsReadOnlyOnCore(t *testing.T) {
	bin := os.Getenv("BITCOIND")
	if bin == "" {
		t.Skip("set BITCOIND to run")
	}
	dir := t.TempDir()
	cookie, err := MainchainReaderCookie(dir)
	require.NoError(t, err)
	args, err := MainchainReaderArgs(cookie, false)
	require.NoError(t, err)

	port := freePort(t)
	cmd := exec.Command(bin, append([]string{
		"-regtest", "-datadir=" + dir, "-daemon=0", "-printtoconsole=0",
		"-listen=0", fmt.Sprintf("-rpcport=%d", port),
	}, args...)...)
	require.NoError(t, cmd.Start())
	t.Cleanup(func() {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
	})

	user, password, err := ReadCookieFile(cookie)
	require.NoError(t, err)
	require.Eventually(t, func() bool {
		return rpcStatus(port, user, password, "getblockcount") == http.StatusOK
	}, 30*time.Second, 200*time.Millisecond)

	for _, method := range MainchainReaderRPCs {
		require.NotEqual(t, http.StatusForbidden, rpcStatus(port, user, password, method), method)
	}
	for _, method := range []string{"listdescriptors", "sendtoaddress", "stop", "getbalances"} {
		require.Equal(t, http.StatusForbidden, rpcStatus(port, user, password, method), method)
	}

	coreUser, corePassword, err := ReadCookieFile(filepath.Join(dir, "regtest", ".cookie"))
	require.NoError(t, err)
	require.Equal(t, http.StatusOK, rpcStatus(port, coreUser, corePassword, "listwallets"))
}

func rpcStatus(port int, user, password, method string) int {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	body := fmt.Sprintf(`{"jsonrpc":"1.0","id":1,"method":%q,"params":[]}`, method)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, fmt.Sprintf("http://127.0.0.1:%d", port), bytes.NewBufferString(body))
	if err != nil {
		return 0
	}
	req.SetBasicAuth(user, password)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return 0
	}
	_ = resp.Body.Close()
	return resp.StatusCode
}

func freePort(t *testing.T) int {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer func() { _ = l.Close() }()
	return l.Addr().(*net.TCPAddr).Port
}
