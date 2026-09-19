package orchestrator

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/require"
)

func TestPrepareCoreArgs_AddsTheMainchainReader(t *testing.T) {
	o := newTestOrchestrator(t)
	var opts StartOpts
	require.NoError(t, o.prepareCoreArgs(&opts))
	require.Contains(t, opts.CoreArgs, "-rpcwhitelistdefault=0")
	require.Contains(t, opts.CoreArgs, "-rpcwhitelist="+config.MainchainReaderUser+":"+strings.Join(config.MainchainReaderRPCs, ","))
	var auth []string
	for _, arg := range opts.CoreArgs {
		if strings.HasPrefix(arg, "-rpcauth="+config.MainchainReaderUser+":") {
			auth = append(auth, arg)
		}
	}
	require.Len(t, auth, 1)
}

// readerCore answers getblockcount with status, and records the credentials.
func readerCore(t *testing.T, o *Orchestrator, status int) *[]string {
	t.Helper()
	var users []string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, _, _ := r.BasicAuth()
		users = append(users, user)
		w.WriteHeader(status)
		if status == http.StatusOK {
			_, _ = w.Write([]byte(`{"result":1,"error":null}`))
		}
	}))
	t.Cleanup(server.Close)
	_, port, err := net.SplitHostPort(server.Listener.Addr().String())
	require.NoError(t, err)
	o.BitcoinConf.Config.SetSetting("rpcport", port, config.CoreSectionForNetwork(o.BitcoinConf.Network))
	return &users
}

func TestMainchainReaderHandsOutTheReaderCookie(t *testing.T) {
	o := newTestOrchestrator(t)
	users := readerCore(t, o, http.StatusOK)
	cookie, err := bootHost{orch: o}.MainchainReader(context.Background())
	require.NoError(t, err)
	user, _, err := config.ReadCookieFile(cookie)
	require.NoError(t, err)
	require.Equal(t, config.MainchainReaderUser, user)
	require.Equal(t, []string{config.MainchainReaderUser}, *users)
}

func TestCallBitcoindRPCReportsRejectedCredentials(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
	}))
	defer server.Close()
	_, err := CallBitcoindRPC(context.Background(), server.URL, "user", "wrong", "getblockcount", nil)
	require.ErrorIs(t, err, ErrRPCUnauthorized)
}

func TestMainchainReaderLeavesAnUnmanagedCoreAlone(t *testing.T) {
	o := newTestOrchestrator(t)
	users := readerCore(t, o, http.StatusUnauthorized)
	_, err := bootHost{orch: o}.MainchainReader(context.Background())
	require.ErrorContains(t, err, "restart Bitcoin Core from BitWindow")
	require.Len(t, *users, 1, "no restart and no second probe")
}

func TestMainchainRPCNamesTheLocalCore(t *testing.T) {
	o := newTestOrchestrator(t)
	host, port, err := bootHost{orch: o}.MainchainRPC()
	require.NoError(t, err)
	require.Equal(t, o.BitcoinConf.GetRPCHost(), host)
	require.Equal(t, o.BitcoinConf.GetRPCPort(), port)
	require.Equal(t, o.BitcoinConf.GetRPCCookiePath(), bootHost{orch: o}.MainchainCookie())
}

func TestMainchainRPCRefusesLightMode(t *testing.T) {
	o := newTestOrchestrator(t)
	require.NoError(t, WriteNodeMode(o.BitwindowDir, NodeModeLight))
	_, _, err := bootHost{orch: o}.MainchainRPC()
	require.ErrorContains(t, err, "local mainchain node")
	_, err = bootHost{orch: o}.MainchainReader(context.Background())
	require.ErrorContains(t, err, "local mainchain node")
}

func TestMainchainReaderReportsAnUnreachableCore(t *testing.T) {
	o := newTestOrchestrator(t)
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := l.Addr().(*net.TCPAddr).Port
	require.NoError(t, l.Close())
	o.BitcoinConf.Config.SetSetting("rpcport", strconv.Itoa(port), config.CoreSectionForNetwork(o.BitcoinConf.Network))
	_, err = bootHost{orch: o}.MainchainReader(context.Background())
	require.ErrorContains(t, err, "getblockcount")
	require.NotContains(t, err.Error(), "restart")
}

func TestOnlyASidechainWithoutTheEnforcerSkipsIt(t *testing.T) {
	for _, name := range []string{"bitcoind", "enforcer", "thunder", "freebank"} {
		cfg, ok := BinaryConfigByName(name)
		require.True(t, ok, name)
		require.True(t, startsEnforcer(cfg), name)
	}
	elements, ok := BinaryConfigByName("liquid-signet")
	require.True(t, ok)
	require.False(t, startsEnforcer(elements))
}
