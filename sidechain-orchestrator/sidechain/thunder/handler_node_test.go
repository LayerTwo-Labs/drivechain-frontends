package thunder

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
)

func TestWalletCallsUseNodeWithIndex(t *testing.T) {
	var indexCalls atomic.Int64
	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		indexCalls.Add(1)
		http.Error(w, "index unavailable", http.StatusServiceUnavailable)
	}))
	defer index.Close()
	ctx := context.Background()
	tests := []struct {
		name    string
		method  string
		result  string
		request string
		want    any
		call    func(*Handler) (any, error)
	}{
		{
			name: "balance", method: "balance",
			result: `{"total_sats":7000,"available_sats":6000}`, request: "balance",
			want: [2]int64{7000, 6000},
			call: func(h *Handler) (any, error) {
				resp, err := h.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
				if err != nil {
					return nil, err
				}
				return [2]int64{resp.Msg.TotalSats, resp.Msg.AvailableSats}, nil
			},
		},
		{
			name: "shared balance", method: "balance",
			result: `{"total_sats":7000,"available_sats":6000}`, request: "balance",
			want: [2]int64{7000, 6000},
			call: func(h *Handler) (any, error) {
				total, available, err := h.WalletBalance(ctx)
				return [2]int64{total, available}, err
			},
		},
		{
			name: "address", method: "get_new_address",
			result: `"node-address"`, request: "get_new_address", want: "node-address",
			call: func(h *Handler) (any, error) {
				resp, err := h.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
				if err != nil {
					return nil, err
				}
				return resp.Msg.Address, nil
			},
		},
		{
			name: "transfer", method: "create_transfer",
			result: `"transfer-id"`, request: `create_transfer ["alice",5000,100]`, want: "transfer-id",
			call: func(h *Handler) (any, error) {
				resp, err := h.Transfer(ctx, connect.NewRequest(&pb.TransferRequest{
					Address: "alice", AmountSats: 5000, FeeSats: 100,
				}))
				if err != nil {
					return nil, err
				}
				return resp.Msg.Txid, nil
			},
		},
		{
			name: "transfer many", method: "create_transfer_many",
			result: `"transfers-id"`, request: `create_transfer_many [{"alice":5000},100]`, want: "transfers-id",
			call: func(h *Handler) (any, error) {
				resp, err := h.TransferMany(ctx, connect.NewRequest(&pb.TransferManyRequest{
					Destinations: map[string]int64{"alice": 5000}, FeeSats: 100,
				}))
				if err != nil {
					return nil, err
				}
				return resp.Msg.Txid, nil
			},
		},
		{
			name: "withdrawal", method: "create_withdrawal",
			result: `"withdrawal-id"`, request: `create_withdrawal ["main-address",5000,100,200]`, want: "withdrawal-id",
			call: func(h *Handler) (any, error) {
				resp, err := h.Withdraw(ctx, connect.NewRequest(&pb.WithdrawRequest{
					Address: "main-address", AmountSats: 5000, SideFeeSats: 100, MainFeeSats: 200,
				}))
				if err != nil {
					return nil, err
				}
				return resp.Msg.Txid, nil
			},
		},
		{
			name: "UTXOs", method: "get_wallet_utxos",
			result: `[]`, request: "get_wallet_utxos", want: "[]",
			call: func(h *Handler) (any, error) {
				resp, err := h.GetWalletUtxos(ctx, connect.NewRequest(&pb.GetWalletUtxosRequest{}))
				if err != nil {
					return nil, err
				}
				return resp.Msg.UtxosJson, nil
			},
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Run("success", func(t *testing.T) {
				proxy, seen := sendMethodNode(t, map[string]string{
					test.method: test.result, "get_wallet_addresses": `[]`,
				})
				got, err := test.call(NewHandlerWithIndex(proxy, index.URL))
				require.NoError(t, err)
				assert.Equal(t, test.want, got)
				wantCalls := []string{test.request}
				if test.method == "get_wallet_utxos" {
					wantCalls = append(wantCalls, "get_wallet_addresses")
				}
				assert.Equal(t, wantCalls, *seen)
			})
			t.Run("node error", func(t *testing.T) {
				proxy, seen := sendMethodNode(t, nil)
				_, err := test.call(NewHandlerWithIndex(proxy, index.URL))
				require.ErrorContains(t, err, "Method not found: "+test.method)
				assert.Equal(t, []string{test.request}, *seen)
			})
		})
	}
	assert.Zero(t, indexCalls.Load())
}

func TestWalletUTXOsKeepMempoolWithIndex(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{
		"get_wallet_utxos": `[{"outpoint":{"Regular":{"txid":"old","vout":0}},
			"output":{"address":"mine","content":{"Value":2000}}}]`,
		"get_wallet_addresses": `["mine"]`,
		"list_mempool": `[{"txid":"pending","size":240,"tx":{"outputs":[
			{"address":"mine","content":{"Value":10000}},
			{"address":"theirs","content":{"Value":500}}
		]}}]`,
	})
	h := NewHandlerWithIndex(proxy, "http://127.0.0.1:1")
	resp, err := h.GetWalletUtxos(context.Background(), connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	require.NoError(t, err)
	assert.JSONEq(t, `[
		{"outpoint":{"Regular":{"txid":"old","vout":0}},"output":{"address":"mine","content":{"Value":2000}}},
		{"outpoint":{"Regular":{"txid":"pending","vout":0}},"output":{"address":"mine","content":{"Value":10000}},"confirmed":false}
	]`, resp.Msg.UtxosJson)
	assert.Equal(t, []string{"get_wallet_utxos", "get_wallet_addresses", "list_mempool"}, *seen)
}

func TestListTransactionsReportsIndexError(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{"get_wallet_addresses": `["mine"]`})
	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "index unavailable", http.StatusServiceUnavailable)
	}))
	defer index.Close()
	_, err := NewHandlerWithIndex(proxy, index.URL).ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	require.ErrorContains(t, err, "503")
	assert.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	assert.Equal(t, []string{"get_wallet_addresses"}, *seen)
}

func TestListTransactionsReadsEmptyIndex(t *testing.T) {
	proxy, seen := sendMethodNode(t, map[string]string{"get_wallet_addresses": `["mine"]`})
	index := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/blocks/tip/height" {
			http.Error(w, "no blocks", http.StatusNotFound)
			return
		}
		result := `[]`
		if r.URL.Path == "/address/mine/txs" {
			result = `[{"txid":"pending","vin":[],"vout":[{"scriptpubkey_address":"mine","value":100}],"status":{"confirmed":false}}]`
		}
		_, err := w.Write([]byte(result))
		assert.NoError(t, err)
	}))
	defer index.Close()
	resp, err := NewHandlerWithIndex(proxy, index.URL).ListWalletTransactions(context.Background(),
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	require.NoError(t, err)
	assert.Zero(t, resp.Msg.TipHeight)
	require.Len(t, resp.Msg.Transactions, 1)
	assert.Equal(t, "pending", resp.Msg.Transactions[0].Txid)
	assert.Equal(t, int64(100), resp.Msg.Transactions[0].ValueSats)
	assert.False(t, resp.Msg.Transactions[0].Confirmed)
	assert.Equal(t, []string{"get_wallet_addresses"}, *seen)
}
