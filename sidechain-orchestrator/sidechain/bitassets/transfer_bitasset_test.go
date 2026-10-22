package bitassets

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect/v2"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// paramsNode answers every method with the given result, and records the
// params of each request.
func paramsNode(t *testing.T, result string) (*sidechain.JSONRPCProxy, *[]any) {
	t.Helper()
	params := []any{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Params []any `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		params = req.Params
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(server.Close)

	host, portText, found := strings.Cut(strings.TrimPrefix(server.URL, "http://"), ":")
	require.True(t, found, "cannot split %q", server.URL)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return sidechain.NewJSONRPCProxy(host, port), &params
}

// The node signature is transfer_bitasset(dest, asset_id, amount, fee_sats,
// memo). The wrong order makes the node reject the address.
func TestTransferBitAssetSendsDestBeforeAssetID(t *testing.T) {
	proxy, params := paramsNode(t, `"e3b0c44298fc1c149afbf4c8996fb924"`)

	resp, err := NewHandler(proxy).TransferBitAsset(context.Background(),
		&pb.TransferBitAssetRequest{
			AssetId: "d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076",
			Dest:    "3w3mR6SMpc3irb7etdJbDu5rLyLv",
			Amount:  7000000,
			FeeSats: 1000,
		})
	require.NoError(t, err)
	assert.Equal(t, "e3b0c44298fc1c149afbf4c8996fb924", resp.Txid)

	assert.Equal(t, []any{
		"3w3mR6SMpc3irb7etdJbDu5rLyLv",
		"d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076",
		float64(7000000),
		float64(1000),
		nil,
	}, *params)
}

// The node signature is verify_signature(signature, verifying_key, dst, msg).
func TestVerifySignatureSendsSignatureFirst(t *testing.T) {
	proxy, params := paramsNode(t, `true`)

	resp, err := NewHandler(proxy).VerifySignature(context.Background(),
		&pb.VerifySignatureRequest{
			Msg:          "the message",
			Signature:    "0xsig",
			VerifyingKey: "ba-svk1key",
		})
	require.NoError(t, err)
	assert.True(t, resp.Valid)

	assert.Equal(t, []any{"0xsig", "ba-svk1key", "arbitrary", "the message"}, *params)
}

func TestRegisterBitAssetEncodesCommitment(t *testing.T) {
	for _, test := range []struct {
		name    string
		data    string
		want    string
		invalid bool
	}{
		{
			name: "hex commitment",
			data: `{"commitment":"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f","socket_addr_v4":"8.8.8.8:6002","socket_addr_v6":"[2606:4700:4700::1111]:6002","encryption_pubkey":"encryption-key","signing_pubkey":"sign-key"}`,
			want: `{"commitment":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],"socket_addr_v4":"8.8.8.8:6002","socket_addr_v6":"[2606:4700:4700::1111]:6002","encryption_pubkey":"encryption-key","signing_pubkey":"sign-key"}`,
		},
		{name: "no commitment", data: `{"socket_addr_v4":"8.8.8.8:6002"}`, want: `{"socket_addr_v4":"8.8.8.8:6002"}`},
		{name: "no data", want: `null`},
		{name: "short commitment", data: `{"commitment":"01"}`, invalid: true},
		{name: "invalid hex", data: `{"commitment":"zz"}`, invalid: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			proxy, params := paramsNode(t, `"txid"`)
			resp, err := NewHandler(proxy).RegisterBitAsset(t.Context(), &pb.RegisterBitAssetRequest{
				PlaintextName: "asset", InitialSupply: 7000000, DataJson: test.data,
			})
			if test.invalid {
				require.ErrorContains(t, err, "commitment")
				assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
				assert.Len(t, *params, 0)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, "txid", resp.Txid)
			require.Len(t, *params, 3)
			assert.Equal(t, "asset", (*params)[0])
			assert.Equal(t, float64(7000000), (*params)[1])
			raw, err := json.Marshal((*params)[2])
			require.NoError(t, err)
			assert.JSONEq(t, test.want, string(raw))
		})
	}
}

func TestBitAssetReadsDecodeCommitment(t *testing.T) {
	for _, test := range []struct {
		name string
		data string
		want string
	}{
		{
			name: "byte commitment",
			data: `{"commitment":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],"socket_addr_v4":"8.8.8.8:6002","socket_addr_v6":"[2606:4700:4700::1111]:6002","encryption_pubkey":"encryption-key","signing_pubkey":"sign-key"}`,
			want: `{"commitment":"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f","socket_addr_v4":"8.8.8.8:6002","socket_addr_v6":"[2606:4700:4700::1111]:6002","encryption_pubkey":"encryption-key","signing_pubkey":"sign-key"}`,
		},
		{name: "no commitment", data: `{}`, want: `{}`},
		{name: "null commitment", data: `{"commitment":null}`, want: `{}`},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Run("get", func(t *testing.T) {
				proxy, _ := paramsNode(t, test.data)
				resp, err := NewHandler(proxy).GetBitAssetData(t.Context(), &pb.GetBitAssetDataRequest{AssetId: "asset"})
				require.NoError(t, err)
				assert.JSONEq(t, test.want, resp.DataJson)
			})
			t.Run("list", func(t *testing.T) {
				proxy, _ := paramsNode(t, `[[17,"asset",`+test.data+`]]`)
				resp, err := NewHandler(proxy).ListBitAssets(t.Context(), &pb.ListBitAssetsRequest{})
				require.NoError(t, err)
				assert.JSONEq(t, `[[17,"asset",`+test.want+`]]`, resp.BitassetsJson)
			})
		})
	}
}
