package bitnames

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeRPC returns an httptest.Server that dispatches on the JSON-RPC method.
func fakeRPC(t *testing.T, handlers map[string]interface{}) *httptest.Server {
	t.Helper()
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req rpcRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode request: %v", err)
		}

		result, ok := handlers[req.Method]
		if !ok {
			t.Fatalf("unexpected method: %s", req.Method)
		}

		resp := rpcResponse{}
		raw, err := json.Marshal(result)
		require.NoError(t, err)
		resp.Result = raw

		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(resp))
	}))
}

func clientFromServer(srv *httptest.Server) *Client {
	return &Client{baseURL: srv.URL, http: srv.Client()}
}

type recordedClientRPCRequest struct {
	Method string          `json:"method"`
	Params json.RawMessage `json:"params"`
}

func recordingClientRPC(
	t *testing.T,
	result any,
) (*httptest.Server, <-chan recordedClientRPCRequest) {
	t.Helper()
	requests := make(chan recordedClientRPCRequest, 1)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer r.Body.Close() //nolint:errcheck
		var request recordedClientRPCRequest
		require.NoError(t, json.NewDecoder(r.Body).Decode(&request))
		requests <- request

		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(map[string]any{
			"jsonrpc": "2.0",
			"id":      "orchestrator",
			"result":  result,
		}))
	}))
	return server, requests
}

func requireClientRPCRequest(
	t *testing.T,
	requests <-chan recordedClientRPCRequest,
	method string,
	paramsJSON string,
) {
	t.Helper()
	request := <-requests
	assert.Equal(t, method, request.Method)
	assert.JSONEq(t, paramsJSON, string(request.Params))
}

func TestBalance(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"balance": BalanceResponse{TotalSats: 100_000, AvailableSats: 80_000},
	})
	defer srv.Close()

	c := clientFromServer(srv)
	bal, err := c.Balance(context.Background())
	require.NoError(t, err)
	assert.Equal(t, int64(100_000), bal.TotalSats)
	assert.Equal(t, int64(80_000), bal.AvailableSats)
}

func TestGetBlockCount(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"getblockcount": 42,
	})
	defer srv.Close()

	c := clientFromServer(srv)
	count, err := c.GetBlockCount(context.Background())
	require.NoError(t, err)
	assert.Equal(t, 42, count)
}

func TestListBitNames(t *testing.T) {
	// The node returns [[hash, details], ...].
	raw := json.RawMessage(`[["abc123",{"seq_id":"1","commitment":"deadbeef"}]]`)

	srv := fakeRPC(t, map[string]interface{}{
		"bitnames": raw,
	})
	defer srv.Close()

	c := clientFromServer(srv)
	entries, err := c.ListBitNames(context.Background())
	require.NoError(t, err)
	require.Len(t, entries, 1)
	assert.Equal(t, "abc123", entries[0].Hash)
	assert.Equal(t, "1", entries[0].Details.SeqID)
	require.NotNil(t, entries[0].Details.Commitment)
	assert.Equal(t, "deadbeef", *entries[0].Details.Commitment)
}

func TestListPeers(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"list_peers": []PeerInfo{{Address: "1.2.3.4:8333", Status: "connected"}},
	})
	defer srv.Close()

	c := clientFromServer(srv)
	peers, err := c.ListPeers(context.Background())
	require.NoError(t, err)
	require.Len(t, peers, 1)
	assert.Equal(t, "1.2.3.4:8333", peers[0].Address)
}

func TestGetNewAddress(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"get_new_address": "sNxyz123",
	})
	defer srv.Close()

	c := clientFromServer(srv)
	addr, err := c.GetNewAddress(context.Background())
	require.NoError(t, err)
	assert.Equal(t, "sNxyz123", addr)
}

func TestRPCError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":null,"error":{"code":-1,"message":"not ready"}}`))
	}))
	defer srv.Close()

	c := clientFromServer(srv)
	_, err := c.GetBlockCount(context.Background())
	require.Error(t, err)
	assert.Contains(t, err.Error(), "not ready")
}

func TestBitnameEntryJSON(t *testing.T) {
	entry := BitnameEntry{
		Hash:    "abc",
		Details: BitnameDetails{SeqID: "1"},
	}
	data, err := json.Marshal(entry)
	require.NoError(t, err)

	var decoded BitnameEntry
	require.NoError(t, json.Unmarshal(data, &decoded))
	assert.Equal(t, entry.Hash, decoded.Hash)
	assert.Equal(t, entry.Details.SeqID, decoded.Details.SeqID)
}

func TestNullableResults(t *testing.T) {
	srv := fakeRPC(t, map[string]interface{}{
		"get_best_mainchain_block_hash":          nil,
		"get_best_sidechain_block_hash":          "deadbeef",
		"latest_failed_withdrawal_bundle_height": nil,
	})
	defer srv.Close()

	c := clientFromServer(srv)

	mainHash, err := c.GetBestMainchainBlockHash(context.Background())
	require.NoError(t, err)
	assert.Nil(t, mainHash)

	sideHash, err := c.GetBestSidechainBlockHash(context.Background())
	require.NoError(t, err)
	require.NotNil(t, sideHash)
	assert.Equal(t, "deadbeef", *sideHash)

	height, err := c.LatestFailedWithdrawalBundleHeight(context.Background())
	require.NoError(t, err)
	assert.Nil(t, height)
}

func TestClientMessageRPCParameterOrder(t *testing.T) {
	t.Run("decrypt", func(t *testing.T) {
		server, requests := recordingClientRPC(t, "68656c6c6f")
		defer server.Close()

		plaintext, err := clientFromServer(server).DecryptMsg(
			context.Background(),
			"recipient-key",
			"ciphertext",
		)
		require.NoError(t, err)
		assert.Equal(t, "68656c6c6f", plaintext)
		requireClientRPCRequest(t, requests, "decrypt_msg", `["recipient-key","ciphertext"]`)
	})

	t.Run("sign with BitName key", func(t *testing.T) {
		server, requests := recordingClientRPC(t, "signature")
		defer server.Close()

		signature, err := clientFromServer(server).SignArbitraryMsg(
			context.Background(),
			"message",
			"verifying-key",
		)
		require.NoError(t, err)
		assert.Equal(t, "signature", signature)
		requireClientRPCRequest(t, requests, "sign_arbitrary_msg", `["verifying-key","message"]`)
	})

	t.Run("sign with address key", func(t *testing.T) {
		server, requests := recordingClientRPC(t, map[string]any{
			"verifying_key": "verifying-key",
			"signature":     "signature",
		})
		defer server.Close()

		authorization, err := clientFromServer(server).SignArbitraryMsgAsAddr(
			context.Background(),
			"message",
			"address",
		)
		require.NoError(t, err)
		assert.Equal(t, "verifying-key", authorization.VerifyingKey)
		assert.Equal(t, "signature", authorization.Signature)
		requireClientRPCRequest(t, requests, "sign_arbitrary_msg_as_addr", `["address","message"]`)
	})

	t.Run("verify", func(t *testing.T) {
		server, requests := recordingClientRPC(t, true)
		defer server.Close()

		valid, err := clientFromServer(server).VerifySignature(
			context.Background(),
			"signature",
			"verifying-key",
			"arbitrary",
			"message",
		)
		require.NoError(t, err)
		assert.True(t, valid)
		requireClientRPCRequest(
			t,
			requests,
			"verify_signature",
			`["signature","verifying-key","arbitrary","message"]`,
		)
	})
}

func TestClientBitNameMailboxRPCs(t *testing.T) {
	t.Run("resolve unregistered name", func(t *testing.T) {
		server, requests := recordingClientRPC(t, nil)
		defer server.Close()

		resolution, err := clientFromServer(server).ResolveBitName(
			context.Background(),
			"bitname-hash",
		)
		require.NoError(t, err)
		assert.Nil(t, resolution)
		requireClientRPCRequest(t, requests, "resolve_bitname", `["bitname-hash"]`)
	})

	t.Run("update mutable data", func(t *testing.T) {
		server, requests := recordingClientRPC(t, "update-txid")
		defer server.Close()

		updates := BitNameDataUpdates{
			Commitment:       json.RawMessage(`"Retain"`),
			SocketAddrV4:     json.RawMessage(`"Retain"`),
			SocketAddrV6:     json.RawMessage(`"Retain"`),
			EncryptionPubkey: json.RawMessage(`"Retain"`),
			SigningPubkey:    json.RawMessage(`{"Set":"verifying-key"}`),
			PaymailFeeSats:   json.RawMessage(`"Retain"`),
		}
		txid, err := clientFromServer(server).UpdateBitName(
			context.Background(),
			"bitname-hash",
			updates,
			100,
		)
		require.NoError(t, err)
		assert.Equal(t, "update-txid", txid)
		requireClientRPCRequest(
			t,
			requests,
			"update_bitname",
			`[
				"bitname-hash",
				{
					"commitment":"Retain",
					"socket_addr_v4":"Retain",
					"socket_addr_v6":"Retain",
					"encryption_pubkey":"Retain",
					"signing_pubkey":{"Set":"verifying-key"},
					"paymail_fee_sats":"Retain"
				},
				100
			]`,
		)
	})

	t.Run("decode ordered entries", func(t *testing.T) {
		server, _ := recordingClientRPC(t, []any{
			map[string]any{
				"outpoint":     map[string]any{"Regular": map[string]any{"txid": "txid", "vout": 0}},
				"output":       map[string]any{"address": "address", "content": map[string]any{"Bitcoin": map[string]any{"value": 1}}, "memo": "aabb"},
				"value_sats":   1,
				"block_hash":   "block-hash",
				"block_height": 5,
				"tx_index":     6,
				"recipients": []any{
					map[string]any{
						"bitname":           "bitname-hash",
						"required_fee_sats": 1000,
						"data":              map[string]any{"seq_id": "0791-0362", "paymail_fee_sats": 1000},
					},
				},
			},
		})
		defer server.Close()

		entries, err := clientFromServer(server).GetPaymailEntries(context.Background())
		require.NoError(t, err)
		require.Len(t, entries, 1)
		assert.Equal(t, uint64(1), entries[0].ValueSats)
		assert.Equal(t, "aabb", entries[0].Output.Memo)
		require.Len(t, entries[0].Recipients, 1)
		require.NotNil(t, entries[0].Recipients[0].RequiredFeeSats)
		assert.Equal(t, uint64(1000), *entries[0].Recipients[0].RequiredFeeSats)
	})
}
