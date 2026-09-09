package api

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

func TestThunderBalanceTracksMempoolSpendAndReceipt(t *testing.T) {
	const payment = `[{"txid":"payment","size":240,"tx":{
		"inputs":[[{"Regular":{"txid":"old","vout":0}},"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]],
		"outputs":[
			{"address":"receiver","content":{"Value":3000}},
			{"address":"sender","content":{"Value":6000}}
		]}}]`
	const senderCoins = `[{"outpoint":{"Regular":{"txid":"old","vout":0}},"output":{"address":"sender","content":{"Value":10000}}}]`
	const receiverCoins = `[{"outpoint":{"Regular":{"txid":"saved","vout":0}},"output":{"address":"receiver","content":{"Value":2000}}}]`

	for _, wallet := range []struct {
		address       string
		balance       int64
		coins         string
		minedBalance  int64
		minedCoins    string
		wantConfirmed uint64
		wantPending   uint64
	}{
		{
			address: "sender", balance: 10000, coins: senderCoins,
			minedBalance: 6000,
			minedCoins:   `[{"outpoint":{"Regular":{"txid":"payment","vout":1}},"output":{"address":"sender","content":{"Value":6000}}}]`,
			wantPending:  6000,
		},
		{
			address: "receiver", balance: 2000, coins: receiverCoins,
			minedBalance: 5000,
			minedCoins: `[
				{"outpoint":{"Regular":{"txid":"saved","vout":0}},"output":{"address":"receiver","content":{"Value":2000}}},
				{"outpoint":{"Regular":{"txid":"payment","vout":0}},"output":{"address":"receiver","content":{"Value":3000}}}
			]`,
			wantConfirmed: 2000, wantPending: 3000,
		},
	} {
		t.Run(wallet.address, func(t *testing.T) {
			for _, state := range []struct {
				name          string
				balance       int64
				coins         string
				mempool       string
				wantConfirmed uint64
				wantPending   uint64
			}{
				{name: "before", balance: wallet.balance, coins: wallet.coins, mempool: "[]", wantConfirmed: uint64(wallet.balance)},
				{name: "pending", balance: wallet.balance, coins: wallet.coins, mempool: payment, wantConfirmed: wallet.wantConfirmed, wantPending: wallet.wantPending},
				{name: "mined", balance: wallet.minedBalance, coins: wallet.minedCoins, mempool: "[]", wantConfirmed: uint64(wallet.minedBalance)},
			} {
				t.Run(state.name, func(t *testing.T) {
					node := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
						var request struct {
							ID     json.RawMessage `json:"id"`
							Method string          `json:"method"`
						}
						if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
							t.Error(err)
							http.Error(w, err.Error(), http.StatusBadRequest)
							return
						}
						response := map[string]any{"jsonrpc": "2.0", "id": request.ID}
						switch request.Method {
						case "balance":
							response["result"] = map[string]int64{"total_sats": state.balance, "available_sats": state.balance}
						case "get_wallet_addresses":
							response["result"] = []string{wallet.address}
						case "get_wallet_utxos":
							response["result"] = json.RawMessage(state.coins)
						case "list_mempool":
							response["result"] = json.RawMessage(state.mempool)
						default:
							response["error"] = map[string]any{"code": -32601, "message": "method not found"}
						}
						w.Header().Set("Content-Type", "application/json")
						if err := json.NewEncoder(w).Encode(response); err != nil {
							t.Error(err)
							return
						}
					}))
					defer node.Close()
					host, port := hostPort(t, node)
					cfg := orchestrator.BinaryConfig{Name: "thunder", DisplayName: "Thunder", Host: host, Port: port}
					orch := orchestrator.New(t.TempDir(), "regtest", t.TempDir(), []orchestrator.BinaryConfig{cfg}, zerolog.New(io.Discard))
					handler := NewHandler(orch)
					handler.SetSidechainBalance("thunder", sidechain.NewJSONRPCProxy(host, port).GetBalance)

					response, err := handler.GetSidechainBalance(context.Background(), connect.NewRequest(&pb.GetSidechainBalanceRequest{
						Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER,
					}))
					require.NoError(t, err)
					assert.Equal(t, state.wantConfirmed, response.Msg.ConfirmedSats)
					assert.Equal(t, state.wantPending, response.Msg.PendingSats)
				})
			}
		})
	}
}
