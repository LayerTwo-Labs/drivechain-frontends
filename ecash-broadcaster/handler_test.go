package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	connectv1 "connectrpc.com/connect"

	ecashv1 "github.com/LayerTwo-Labs/sidesail/ecash-broadcaster/gen/ecash/v1"
	"github.com/LayerTwo-Labs/sidesail/ecash-broadcaster/gen/ecash/v1/ecashv1connect"
)

func TestBroadcastV1Client(t *testing.T) {
	node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, password, ok := r.BasicAuth()
		if !ok || user != "user" || password != "password" {
			t.Error("The node did not receive the RPC credentials.")
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		var request struct {
			Method string   `json:"method"`
			Params []string `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Error(err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if request.Method != "sendrawtransaction" || len(request.Params) != 1 {
			t.Error("The node did not receive one transaction.")
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		var result any = map[string]string{"result": "test-txid"}
		if request.Params[0] == "bad" {
			result = map[string]any{"error": map[string]any{"code": -26, "message": "bad transaction"}}
		}
		if err := json.NewEncoder(w).Encode(result); err != nil {
			t.Error(err)
		}
	}))
	t.Cleanup(node.Close)

	server := httptest.NewUnstartedServer(newMux(&handler{bitcoind: &bitcoindClient{
		url: node.URL, user: "user", pass: "password", http: node.Client(),
	}}))
	server.EnableHTTP2 = true
	server.StartTLS()
	t.Cleanup(server.Close)

	protocols := []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect"},
		{name: "JSON", options: []connectv1.ClientOption{connectv1.WithProtoJSON()}},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPCWeb", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	}
	for _, protocol := range protocols {
		t.Run(protocol.name, func(t *testing.T) {
			client := connectv1.NewClient[ecashv1.BroadcastECashTxRequest, ecashv1.BroadcastECashTxResponse](
				server.Client(), server.URL+ecashv1connect.ECashBroadcastServiceBroadcastECashTxProcedure,
				protocol.options...,
			)
			for _, test := range []struct {
				name    string
				hex     string
				code    connectv1.Code
				message string
			}{
				{name: "valid", hex: "00"},
				{name: "large", hex: strings.Repeat("00", 2*1024*1024+1)},
				{name: "empty", code: connectv1.CodeInvalidArgument, message: "signed_hex is required"},
				{name: "node error", hex: "bad", code: connectv1.CodeInternal, message: "broadcast: bitcoind error -26: bad transaction"},
			} {
				t.Run(test.name, func(t *testing.T) {
					response, err := client.CallUnary(t.Context(), connectv1.NewRequest(&ecashv1.BroadcastECashTxRequest{SignedHex: test.hex}))
					if test.code == 0 {
						if err != nil {
							t.Fatal(err)
						}
						if response.Msg.Txid != "test-txid" {
							t.Fatalf("The transaction ID is %q.", response.Msg.Txid)
						}
						return
					}
					var rpcError *connectv1.Error
					if !errors.As(err, &rpcError) {
						t.Fatalf("The RPC did not return a Connect error: %v.", err)
					}
					if rpcError.Code() != test.code || rpcError.Message() != test.message {
						t.Fatalf("The RPC returned %v.", rpcError)
					}
				})
			}
		})
	}
}
