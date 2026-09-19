package elements

import (
	"context"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/stretchr/testify/require"
)

type fakeHost struct {
	sidechain.Host
	reader    string
	readerErr error
	rpcErr    error
}

func (h fakeHost) MainchainRPC() (string, int, error) { return "127.0.0.1", 18302, h.rpcErr }
func (h fakeHost) MainchainCookie() string            { return "/core.cookie" }
func (h fakeHost) MainchainReader(context.Context) (string, error) {
	return h.reader, h.readerErr
}

func onAlphanet(t *testing.T) {
	old := config.ECashNetworkID()
	config.SetECashNetworkID("alphanet")
	t.Cleanup(func() { config.SetECashNetworkID(old) })
}

func TestArgsReadTheMainchainAsTheReader(t *testing.T) {
	onAlphanet(t)
	datadir := t.TempDir()
	args, err := NewNode("127.0.0.1", 29443, datadir, config.NetworkECash).
		Args(context.Background(), fakeHost{reader: "/reader.cookie"})
	require.NoError(t, err)
	require.Contains(t, args, "-datadir="+datadir)
	require.Contains(t, args, "-rpccookiefile="+filepath.Join(datadir, ".cookie"))
	require.Contains(t, args, "-debuglogfile="+filepath.Join(datadir, "debug.log"))
	require.Contains(t, args, "-rpcport=29443")
	require.Contains(t, args, "-mainchainrpchost=127.0.0.1")
	require.Contains(t, args, "-mainchainrpcport=18302")
	if runtime.GOOS != "windows" {
		require.Contains(t, args, "-mainchainrpccredentialfile=/reader.cookie")
	}
}

func TestParentAuthUsesTheReaderExceptOnWindows(t *testing.T) {
	ctx := context.Background()
	host := fakeHost{reader: "/reader.cookie"}
	for _, goos := range []string{"darwin", "linux"} {
		auth, err := parentAuth(ctx, goos, host)
		require.NoError(t, err)
		require.Equal(t, "-mainchainrpccredentialfile=/reader.cookie", auth)
	}
	auth, err := parentAuth(ctx, "windows", fakeHost{readerErr: errors.New("never asked")})
	require.NoError(t, err)
	require.Equal(t, "-mainchainrpccookiefile=/core.cookie", auth)

	_, err = parentAuth(ctx, "linux", fakeHost{readerErr: errors.New("reader refused")})
	require.ErrorContains(t, err, "reader refused")
}

func TestArgsRefuseAnotherNetwork(t *testing.T) {
	onAlphanet(t)
	_, err := NewNode("127.0.0.1", 29443, t.TempDir(), config.NetworkSignet).
		Args(context.Background(), fakeHost{})
	require.ErrorContains(t, err, "Alphanet")

	config.SetECashNetworkID("betanet")
	_, err = NewNode("127.0.0.1", 29443, t.TempDir(), config.NetworkECash).
		Args(context.Background(), fakeHost{})
	require.ErrorContains(t, err, "Alphanet")
}

func TestArgsFailWithoutAMainchain(t *testing.T) {
	onAlphanet(t)
	_, err := NewNode("127.0.0.1", 29443, t.TempDir(), config.NetworkECash).
		Args(context.Background(), fakeHost{rpcErr: errors.New("no mainchain")})
	require.ErrorContains(t, err, "no mainchain")
}

func TestNodeReloadsItsCookieAndCountsThePolicyAsset(t *testing.T) {
	datadir := t.TempDir()
	cookie := filepath.Join(datadir, ".cookie")
	password := "first"
	balance := `{"mine":{"trusted":{"ECX":0.00000003,"other":999},"untrusted_pending":{"ECX":0.00000002},"immature":{"ECX":0}}}`
	explicitAddress := "elements1-test-explicit"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, pass, ok := r.BasicAuth()
		if !ok || user != "__cookie__" || pass != password {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		var request struct {
			Method string `json:"method"`
			Params []any  `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Error(err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		var result any
		switch request.Method {
		case "getnewaddress":
			require.Equal(t, []any{"", "bech32"}, request.Params)
			result = "confidential-test-address"
		case "getaddressinfo":
			require.Equal(t, []any{"confidential-test-address"}, request.Params)
			result = map[string]any{"ismine": true, "unconfidential": explicitAddress}
		case "getblockcount":
			result = 86
		case "dumpassetlabels":
			result = map[string]string{"ECX": PolicyAsset, "bitcoin": "unrelated"}
		case "getbalances":
			if r.URL.Path != "/wallet/"+sidechain.CoreWalletName || len(request.Params) != 0 {
				t.Error("incorrect native wallet RPC")
			}
			result = json.RawMessage(balance)
		default:
			t.Errorf("unexpected RPC: %s", request.Method)
		}
		_ = json.NewEncoder(w).Encode(map[string]any{"result": result, "error": nil})
	}))
	defer server.Close()
	host, portString, err := net.SplitHostPort(server.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portString)
	require.NoError(t, err)
	node := NewNode(host, port, datadir, config.NetworkECash)
	_, mining := any(node).(sidechain.BMMNode)
	require.False(t, mining)

	ctx := context.Background()
	_, err = node.GetBlockCount(ctx)
	require.Error(t, err)
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:"+password), 0o600))
	_, err = node.GetBlockCount(ctx)
	require.NoError(t, err)
	password = "rotated"
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:"+password), 0o600))
	count, err := node.GetBlockCount(ctx)
	require.NoError(t, err)
	require.EqualValues(t, 86, count)

	total, available, err := node.GetBalance(ctx)
	require.NoError(t, err)
	require.EqualValues(t, 5, total)
	require.EqualValues(t, 3, available)
	address, err := node.GetNewAddress(ctx)
	require.NoError(t, err)
	require.Equal(t, explicitAddress, address)
	explicitAddress = ""
	_, err = node.GetNewAddress(ctx)
	require.ErrorContains(t, err, "owned explicit address")
	for _, invalid := range []string{`{}`, `{"mine":{"trusted":1}}`, `{"mine":{"trusted":{"ECX":0.000000001},"untrusted_pending":{"ECX":0},"immature":{"ECX":0}}}`} {
		balance = invalid
		_, _, err = node.GetBalance(ctx)
		require.Error(t, err)
	}
}
