package api

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/thunder/server/rpc"
)

// fakeThunderNode starts a fake JSON-RPC server and returns a ThunderHandler wired to it.
func fakeThunderNode(t *testing.T, handler func(method string, params json.RawMessage) (any, error)) *ThunderHandler {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
			ID     int64           `json:"id"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode request: %v", err)
		}

		result, err := handler(req.Method, req.Params)
		resp := map[string]any{"jsonrpc": "2.0", "id": req.ID}
		if err != nil {
			resp["error"] = map[string]any{"code": -1, "message": err.Error()}
		} else {
			resp["result"] = result
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			t.Fatalf("encode response: %v", err)
		}
	}))
	t.Cleanup(srv.Close)

	parts := strings.Split(srv.URL, ":")
	port, _ := strconv.Atoi(parts[len(parts)-1])
	host := strings.TrimPrefix(strings.Join(parts[:len(parts)-1], ":"), "http://")
	client := rpc.New(host, port)
	return NewThunderHandler(client)
}

func TestGetBalance(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "balance", method)
		return map[string]any{"total_sats": 100000, "available_sats": 90000}, nil
	})

	resp, err := h.GetBalance(context.Background(), connect.NewRequest(&pb.GetBalanceRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(100000), resp.Msg.TotalSats)
	assert.Equal(t, int64(90000), resp.Msg.AvailableSats)
}

func TestGetBlockCount(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "getblockcount", method)
		return 42, nil
	})

	resp, err := h.GetBlockCount(context.Background(), connect.NewRequest(&pb.GetBlockCountRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(42), resp.Msg.Count)
}

func TestGetNewAddress(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "get_new_address", method)
		return "tb1qtest", nil
	})

	resp, err := h.GetNewAddress(context.Background(), connect.NewRequest(&pb.GetNewAddressRequest{}))
	require.NoError(t, err)
	assert.Equal(t, "tb1qtest", resp.Msg.Address)
}

func TestWithdraw(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "withdraw", method)
		var p []json.RawMessage
		require.NoError(t, json.Unmarshal(params, &p))
		assert.Len(t, p, 4)
		return "withdraw_txid", nil
	})

	resp, err := h.Withdraw(context.Background(), connect.NewRequest(&pb.WithdrawRequest{
		Address:     "mainaddr",
		AmountSats:  50000,
		SideFeeSats: 100,
		MainFeeSats: 200,
	}))
	require.NoError(t, err)
	assert.Equal(t, "withdraw_txid", resp.Msg.Txid)
}

func TestTransfer(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "transfer", method)
		var p []json.RawMessage
		require.NoError(t, json.Unmarshal(params, &p))
		assert.Len(t, p, 3)
		return "transfer_txid", nil
	})

	resp, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address:    "sideaddr",
		AmountSats: 10000,
		FeeSats:    100,
	}))
	require.NoError(t, err)
	assert.Equal(t, "transfer_txid", resp.Msg.Txid)
}

func TestGetSidechainWealth(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "sidechain_wealth_sats", method)
		return 500000, nil
	})

	resp, err := h.GetSidechainWealth(context.Background(), connect.NewRequest(&pb.GetSidechainWealthRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(500000), resp.Msg.Sats)
}

func TestCreateDeposit(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "create_deposit", method)
		var p map[string]any
		require.NoError(t, json.Unmarshal(params, &p))
		assert.Equal(t, "depaddr", p["address"])
		return "dep_txid", nil
	})

	resp, err := h.CreateDeposit(context.Background(), connect.NewRequest(&pb.CreateDepositRequest{
		Address:  "depaddr",
		ValueSats: 25000,
		FeeSats:  500,
	}))
	require.NoError(t, err)
	assert.Equal(t, "dep_txid", resp.Msg.Txid)
}

func TestGetPendingWithdrawalBundle(t *testing.T) {
	bundle := map[string]any{
		"spend_utxos":    []any{},
		"tx":             map[string]any{"txid": "abc", "hash": "abc", "version": 1, "locktime": 0, "inputs": []any{}, "outputs": []any{}},
		"height_created": 100,
	}

	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "pending_withdrawal_bundle", method)
		return bundle, nil
	})

	resp, err := h.GetPendingWithdrawalBundle(context.Background(), connect.NewRequest(&pb.GetPendingWithdrawalBundleRequest{}))
	require.NoError(t, err)
	assert.NotEmpty(t, resp.Msg.BundleJson)

	var parsed map[string]any
	require.NoError(t, json.Unmarshal([]byte(resp.Msg.BundleJson), &parsed))
	assert.Equal(t, float64(100), parsed["height_created"])
}

func TestMine(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "mine", method)
		return map[string]any{
			"hash_last_main_block": "deadbeef",
			"ntxn":                 3,
			"nfees":                1000,
			"txid":                 "mine_txid",
		}, nil
	})

	resp, err := h.Mine(context.Background(), connect.NewRequest(&pb.MineRequest{FeeSats: 500}))
	require.NoError(t, err)

	var parsed map[string]any
	require.NoError(t, json.Unmarshal([]byte(resp.Msg.BmmResultJson), &parsed))
	assert.Equal(t, "deadbeef", parsed["hash_last_main_block"])
}

func TestGetBlock(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "get_block", method)
		return map[string]any{"header": map[string]any{"version": 1}, "txdata": []any{}}, nil
	})

	resp, err := h.GetBlock(context.Background(), connect.NewRequest(&pb.GetBlockRequest{Hash: "blockhash"}))
	require.NoError(t, err)
	assert.Contains(t, resp.Msg.BlockJson, "header")
}

func TestGetBestHashes(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		switch method {
		case "get_best_mainchain_block_hash":
			return "mainhash", nil
		case "get_best_sidechain_block_hash":
			return "sidehash", nil
		default:
			t.Fatalf("unexpected method: %s", method)
			return nil, nil
		}
	})

	mainResp, err := h.GetBestMainchainBlockHash(context.Background(), connect.NewRequest(&pb.GetBestMainchainBlockHashRequest{}))
	require.NoError(t, err)
	assert.Equal(t, "mainhash", mainResp.Msg.Hash)

	sideResp, err := h.GetBestSidechainBlockHash(context.Background(), connect.NewRequest(&pb.GetBestSidechainBlockHashRequest{}))
	require.NoError(t, err)
	assert.Equal(t, "sidehash", sideResp.Msg.Hash)
}

func TestListPeers(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "list_peers", method)
		return []any{map[string]any{"addr": "127.0.0.1:8333"}}, nil
	})

	resp, err := h.ListPeers(context.Background(), connect.NewRequest(&pb.ListPeersRequest{}))
	require.NoError(t, err)
	assert.Contains(t, resp.Msg.PeersJson, "127.0.0.1")
}

func TestConnectPeer(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "connect_peer", method)
		return nil, nil
	})

	_, err := h.ConnectPeer(context.Background(), connect.NewRequest(&pb.ConnectPeerRequest{Address: "127.0.0.1:8333"}))
	require.NoError(t, err)
}

func TestStop(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "stop", method)
		return nil, nil
	})

	_, err := h.Stop(context.Background(), connect.NewRequest(&pb.StopRequest{}))
	require.NoError(t, err)
}

func TestGetWalletUtxos(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "get_wallet_utxos", method)
		return []any{map[string]any{"outpoint": "txid:0", "value": 1000}}, nil
	})

	resp, err := h.GetWalletUtxos(context.Background(), connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	require.NoError(t, err)
	assert.NotEmpty(t, resp.Msg.UtxosJson)
}

func TestListUtxos(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "list_utxos", method)
		return []any{}, nil
	})

	resp, err := h.ListUtxos(context.Background(), connect.NewRequest(&pb.ListUtxosRequest{}))
	require.NoError(t, err)
	assert.NotEmpty(t, resp.Msg.UtxosJson)
}

func TestRemoveFromMempool(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "remove_from_mempool", method)
		return nil, nil
	})

	_, err := h.RemoveFromMempool(context.Background(), connect.NewRequest(&pb.RemoveFromMempoolRequest{Txid: "sometxid"}))
	require.NoError(t, err)
}

func TestGetLatestFailedWithdrawalBundleHeight_Null(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "latest_failed_withdrawal_bundle_height", method)
		return nil, nil
	})

	resp, err := h.GetLatestFailedWithdrawalBundleHeight(context.Background(), connect.NewRequest(&pb.GetLatestFailedWithdrawalBundleHeightRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(0), resp.Msg.Height)
}

func TestGetLatestFailedWithdrawalBundleHeight_Value(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		return 150, nil
	})

	resp, err := h.GetLatestFailedWithdrawalBundleHeight(context.Background(), connect.NewRequest(&pb.GetLatestFailedWithdrawalBundleHeightRequest{}))
	require.NoError(t, err)
	assert.Equal(t, int64(150), resp.Msg.Height)
}

func TestGenerateMnemonic(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "generate_mnemonic", method)
		return "abandon abandon abandon", nil
	})

	resp, err := h.GenerateMnemonic(context.Background(), connect.NewRequest(&pb.GenerateMnemonicRequest{}))
	require.NoError(t, err)
	assert.Equal(t, "abandon abandon abandon", resp.Msg.Mnemonic)
}

func TestSetSeedFromMnemonic(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "set_seed_from_mnemonic", method)
		return nil, nil
	})

	_, err := h.SetSeedFromMnemonic(context.Background(), connect.NewRequest(&pb.SetSeedFromMnemonicRequest{Mnemonic: "test mnemonic"}))
	require.NoError(t, err)
}

func TestCallRaw(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "custom_method", method)
		return map[string]any{"custom": true}, nil
	})

	resp, err := h.CallRaw(context.Background(), connect.NewRequest(&pb.CallRawRequest{
		Method:     "custom_method",
		ParamsJson: `{"key": "value"}`,
	}))
	require.NoError(t, err)
	assert.Contains(t, resp.Msg.ResultJson, "custom")
}

func TestGetBmmInclusions(t *testing.T) {
	h := fakeThunderNode(t, func(method string, params json.RawMessage) (any, error) {
		assert.Equal(t, "get_bmm_inclusions", method)
		return "included", nil
	})

	resp, err := h.GetBmmInclusions(context.Background(), connect.NewRequest(&pb.GetBmmInclusionsRequest{BlockHash: "somehash"}))
	require.NoError(t, err)
	assert.Equal(t, "included", resp.Msg.Inclusions)
}
