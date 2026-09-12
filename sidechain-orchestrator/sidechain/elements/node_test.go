package elements

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/stretchr/testify/require"
)

func TestAlphaNodeCookieRotationIdentityAndAssetBalance(t *testing.T) {
	cookie := filepath.Join(t.TempDir(), ".cookie")
	password := "first"
	genesis := config.ElementsAlphaGenesis
	balance := `{"mine":{"trusted":{"ECX":0.00000003,"other":999},"untrusted_pending":{"ECX":0.00000002},"immature":{"ECX":0}}}`
	explicitAddress := "elements1-test-explicit"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, pass, ok := r.BasicAuth()
		if !ok || user != "__cookie__" || pass != password {
			w.WriteHeader(401)
			return
		}
		var request struct {
			Method string `json:"method"`
			Params []any  `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Error(err)
			w.WriteHeader(400)
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
		case "getblockhash":
			result = genesis
		case "dumpassetlabels":
			result = map[string]string{"ECX": config.ElementsAlphaPolicyAsset, "bitcoin": "unrelated"}
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
	node := NewNode(host, port, cookie)
	_, mining := any(node).(sidechain.BMMNode)
	require.False(t, mining)
	ctx := context.Background()
	require.Error(t, node.VerifyAlpha(ctx))
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:"+password), 0o600))
	require.NoError(t, node.VerifyAlpha(ctx))
	password = "rotated"
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:"+password), 0o600))
	require.NoError(t, node.VerifyAlpha(ctx))
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
	genesis = "wrong-network"
	require.ErrorContains(t, node.VerifyAlpha(ctx), "genesis mismatch")
	for _, invalid := range []string{`{}`, `{"mine":{"trusted":1}}`, `{"mine":{"trusted":{"ECX":0.000000001},"untrusted_pending":{"ECX":0},"immature":{"ECX":0}}}`} {
		balance = invalid
		_, _, err = node.GetBalance(ctx)
		require.Error(t, err)
	}
}
