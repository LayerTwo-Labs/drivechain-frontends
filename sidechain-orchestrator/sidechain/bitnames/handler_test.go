package bitnames

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

type recordedRPCRequest struct {
	Method string          `json:"method"`
	Params json.RawMessage `json:"params"`
}

func recordingHandler(
	t *testing.T,
	result any,
) (*Handler, <-chan recordedRPCRequest, func()) {
	t.Helper()
	requests := make(chan recordedRPCRequest, 1)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer r.Body.Close() //nolint:errcheck
		var request recordedRPCRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		requests <- request

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(map[string]any{
			"jsonrpc": "2.0",
			"id":      1,
			"result":  result,
		}); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}))

	parsed, err := url.Parse(srv.URL)
	require.NoError(t, err)
	host, portString, err := net.SplitHostPort(parsed.Host)
	require.NoError(t, err)
	port, err := strconv.Atoi(portString)
	require.NoError(t, err)

	proxy := sidechain.NewJSONRPCProxy(host, port)
	return NewHandler(proxy), requests, srv.Close
}

func requireRPCRequest(
	t *testing.T,
	requests <-chan recordedRPCRequest,
	method string,
	paramsJSON string,
) {
	t.Helper()
	request := <-requests
	assert.Equal(t, method, request.Method)
	if paramsJSON == "" {
		assert.Empty(t, request.Params)
		return
	}
	assert.JSONEq(t, paramsJSON, string(request.Params))
}

func TestHandlerMessageRPCParameterOrder(t *testing.T) {
	t.Run("decrypt", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, "68656c6c6f")
		defer closeServer()

		response, err := handler.DecryptMsg(
			context.Background(),
			connect.NewRequest(&pb.DecryptMsgRequest{
				EncryptionPubkey: "recipient-key",
				Ciphertext:       "ciphertext",
			}),
		)
		require.NoError(t, err)
		assert.Equal(t, "68656c6c6f", response.Msg.Plaintext)
		requireRPCRequest(
			t,
			requests,
			"decrypt_msg",
			`["recipient-key","ciphertext"]`,
		)
	})

	t.Run("sign with BitName key", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, "signature")
		defer closeServer()

		response, err := handler.SignArbitraryMsg(
			context.Background(),
			connect.NewRequest(&pb.SignArbitraryMsgRequest{
				VerifyingKey: "verifying-key",
				Msg:          "message",
			}),
		)
		require.NoError(t, err)
		assert.Equal(t, "signature", response.Msg.Signature)
		requireRPCRequest(
			t,
			requests,
			"sign_arbitrary_msg",
			`["verifying-key","message"]`,
		)
	})

	t.Run("sign with address key", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, map[string]any{
			"verifying_key": "verifying-key",
			"signature":     "signature",
		})
		defer closeServer()

		response, err := handler.SignArbitraryMsgAsAddr(
			context.Background(),
			connect.NewRequest(&pb.SignArbitraryMsgAsAddrRequest{
				Address: "address",
				Msg:     "message",
			}),
		)
		require.NoError(t, err)
		assert.Equal(t, "verifying-key", response.Msg.VerifyingKey)
		assert.Equal(t, "signature", response.Msg.Signature)
		requireRPCRequest(
			t,
			requests,
			"sign_arbitrary_msg_as_addr",
			`["address","message"]`,
		)
	})

	t.Run("verify", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, true)
		defer closeServer()

		response, err := handler.VerifySignature(
			context.Background(),
			connect.NewRequest(&pb.VerifySignatureRequest{
				Signature:    "signature",
				VerifyingKey: "verifying-key",
				Domain:       "arbitrary",
				Msg:          "message",
			}),
		)
		require.NoError(t, err)
		assert.True(t, response.Msg.Valid)
		requireRPCRequest(
			t,
			requests,
			"verify_signature",
			`["signature","verifying-key","arbitrary","message"]`,
		)
	})
}

func TestHandlerBitNameMailboxRPCs(t *testing.T) {
	t.Run("read transaction confirmation info", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, map[string]any{
			"fee_sats": 100, "txin": map[string]any{"block_hash": "block-hash", "idx": 7},
		})
		defer closeServer()

		response, err := handler.GetTransactionInfo(
			context.Background(), connect.NewRequest(&pb.GetTransactionInfoRequest{Txid: "txid"}),
		)
		require.NoError(t, err)
		assert.Contains(t, response.Msg.TransactionInfoJson, `"txin"`)
		requireRPCRequest(t, requests, "get_transaction_info", `"txid"`)
	})

	t.Run("resolve historical data", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, map[string]any{
			"seq_id": "0.0.0", "signing_pubkey": "historical-key",
		})
		defer closeServer()

		response, err := handler.GetBitNameDataAtPosition(
			context.Background(),
			connect.NewRequest(&pb.GetBitNameDataAtPositionRequest{
				Bitname: "bitname-hash", BlockHash: "block-hash", TxIndex: 7,
			}),
		)
		require.NoError(t, err)
		assert.JSONEq(t, `{"seq_id":"0.0.0","signing_pubkey":"historical-key"}`, response.Msg.DataJson)
		requireRPCRequest(t, requests, "bitname_data_at_position", `["bitname-hash","block-hash",7]`)
	})

	t.Run("resolve current owner", func(t *testing.T) {
		result := map[string]any{
			"bitname":  "bitname-hash",
			"outpoint": map[string]any{"Regular": map[string]any{"txid": "txid", "vout": 0}},
			"address":  "recipient-address",
			"data":     map[string]any{"seq_id": "0.0.0", "paymail_fee_sats": 1000},
		}
		handler, requests, closeServer := recordingHandler(t, result)
		defer closeServer()

		response, err := handler.ResolveBitName(
			context.Background(),
			connect.NewRequest(&pb.ResolveBitNameRequest{Bitname: "bitname-hash"}),
		)
		require.NoError(t, err)
		assert.NotEmpty(t, response.Msg.ResolutionJson)
		requireRPCRequest(
			t,
			requests,
			"resolve_bitname",
			`["bitname-hash"]`,
		)
	})

	t.Run("update mutable data", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, "update-txid")
		defer closeServer()

		response, err := handler.UpdateBitName(
			context.Background(),
			connect.NewRequest(&pb.UpdateBitNameRequest{
				Bitname: "bitname-hash",
				UpdatesJson: `{
					"commitment":"Retain",
					"socket_addr_v4":"Retain",
					"socket_addr_v6":"Retain",
					"encryption_pubkey":"Retain",
					"signing_pubkey":{"Set":"verifying-key"},
					"paymail_fee_sats":"Retain"
				}`,
				FeeSats: 100,
			}),
		)
		require.NoError(t, err)
		assert.Equal(t, "update-txid", response.Msg.Txid)
		requireRPCRequest(
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

	t.Run("list ordered entries", func(t *testing.T) {
		handler, requests, closeServer := recordingHandler(t, []any{})
		defer closeServer()

		response, err := handler.GetPaymailEntries(
			context.Background(),
			connect.NewRequest(&pb.GetPaymailEntriesRequest{}),
		)
		require.NoError(t, err)
		assert.Equal(t, "[]", response.Msg.EntriesJson)
		requireRPCRequest(t, requests, "get_paymail_entries", "")
	})
}
