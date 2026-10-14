package zside

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

type recordedCall struct {
	Method string
	Params []any
}

// recordingHandler answers every call with result and records what it got.
func recordingHandler(t *testing.T, result any) (*Handler, *[]recordedCall) {
	t.Helper()
	var calls []recordedCall
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			ID     json.RawMessage `json:"id"`
			Method string          `json:"method"`
			Params []any           `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&request))
		calls = append(calls, recordedCall{Method: request.Method, Params: request.Params})
		w.Header().Set("Content-Type", "application/json")
		require.NoError(t, json.NewEncoder(w).Encode(map[string]any{"jsonrpc": "2.0", "id": request.ID, "result": result}))
	}))
	t.Cleanup(srv.Close)

	host, portText, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	port, err := strconv.Atoi(portText)
	require.NoError(t, err)
	return NewHandler(sidechain.NewJSONRPCProxy(host, port)), &calls
}

// The method names and argument order are those of thunder-orchard 0.18.1.
func TestHandlerCallsTheZSideWalletMethods(t *testing.T) {
	ctx := context.Background()
	for _, test := range []struct {
		name string
		call func(*Handler) error
		want recordedCall
	}{
		{
			name: "withdraw",
			call: func(h *Handler) error {
				_, err := h.Withdraw(ctx, connect.NewRequest(&pb.WithdrawRequest{Address: "bc1q", AmountSats: 5000, SideFeeSats: 10, MainFeeSats: 20}))
				return err
			},
			want: recordedCall{Method: "create_withdrawal", Params: []any{"bc1q", 5000.0, 10.0, 20.0}},
		},
		{
			name: "transfer",
			call: func(h *Handler) error {
				_, err := h.Transfer(ctx, connect.NewRequest(&pb.TransferRequest{Address: "t-addr", AmountSats: 700, FeeSats: 3}))
				return err
			},
			want: recordedCall{Method: "create_transparent_transfer", Params: []any{"t-addr", 700.0, 3.0}},
		},
		{
			name: "transparent transfer",
			call: func(h *Handler) error {
				_, err := h.TransparentTransfer(ctx, connect.NewRequest(&pb.TransparentTransferRequest{Address: "t-addr", AmountSats: 700, FeeSats: 3}))
				return err
			},
			want: recordedCall{Method: "create_transparent_transfer", Params: []any{"t-addr", 700.0, 3.0}},
		},
		{
			name: "shielded transfer",
			call: func(h *Handler) error {
				_, err := h.ShieldedTransfer(ctx, connect.NewRequest(&pb.ShieldedTransferRequest{Address: "z-addr", AmountSats: 800, FeeSats: 4}))
				return err
			},
			want: recordedCall{Method: "create_shielded_transfer", Params: []any{"z-addr", 800.0, 4.0}},
		},
		{
			name: "shield",
			call: func(h *Handler) error {
				_, err := h.Shield(ctx, connect.NewRequest(&pb.ShieldRequest{AmountSats: 900, FeeSats: 5}))
				return err
			},
			want: recordedCall{Method: "create_shield", Params: []any{900.0, 5.0}},
		},
		{
			name: "unshield",
			call: func(h *Handler) error {
				_, err := h.Unshield(ctx, connect.NewRequest(&pb.UnshieldRequest{AmountSats: 900, FeeSats: 5}))
				return err
			},
			want: recordedCall{Method: "create_unshield", Params: []any{900.0, 5.0}},
		},
	} {
		t.Run(test.name, func(t *testing.T) {
			handler, calls := recordingHandler(t, "txid")
			require.NoError(t, test.call(handler))
			assert.Equal(t, []recordedCall{test.want}, *calls)
		})
	}
}

// get_bmm_inclusions answers a list of mainchain block hashes.
func TestHandlerReturnsTheBmmInclusions(t *testing.T) {
	handler, calls := recordingHandler(t, []string{"aa", "bb"})
	resp, err := handler.GetBmmInclusions(context.Background(), connect.NewRequest(&pb.GetBmmInclusionsRequest{BlockHash: "cc"}))
	require.NoError(t, err)
	assert.JSONEq(t, `["aa","bb"]`, resp.Msg.Inclusions)
	assert.Equal(t, []recordedCall{{Method: "get_bmm_inclusions", Params: []any{"cc"}}}, *calls)
}

func utxoJSON(txid, address string, sats int) map[string]any {
	return map[string]any{
		"outpoint": map[string]any{"Regular": map[string]any{"txid": txid, "vout": 0}},
		"output":   map[string]any{"address": address, "content": map[string]any{"Value": sats}},
	}
}

// Until the next block, a coin a mempool transaction spends must not show as
// spendable, and the unconfirmed change must show as unconfirmed.
func TestHandlerListsCoinsAsTheMempoolLeavesThem(t *testing.T) {
	node := nodeServer(t, map[string]any{
		"get_wallet_utxos":             []any{utxoJSON("aa", "t-one", 1000), utxoJSON("bb", "t-two", 2000)},
		"get_wallet_utxos_unconfirmed": []any{utxoJSON("cc", "t-three", 1500)},
		"get_wallet_stxos_unconfirmed": []any{map[string]any{
			"output":  utxoJSON("bb", "t-two", 2000),
			"inpoint": map[string]any{"Regular": map[string]any{"txid": "cc", "vin": 0}},
		}},
	})

	resp, err := NewHandler(node.JSONRPCProxy).GetWalletUtxos(context.Background(), connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	require.NoError(t, err)

	var got []map[string]any
	require.NoError(t, json.Unmarshal([]byte(resp.Msg.UtxosJson), &got))
	require.Len(t, got, 2)
	assert.Equal(t, "t-one", got[0]["output"].(map[string]any)["address"])
	assert.Nil(t, got[0]["confirmed"])
	assert.Equal(t, "t-three", got[1]["output"].(map[string]any)["address"])
	assert.Equal(t, false, got[1]["confirmed"])
}
