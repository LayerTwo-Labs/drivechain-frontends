package truthcoin

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

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

type recordedCall struct {
	Method string          `json:"method"`
	Params json.RawMessage `json:"params"`
}

// callRecorder answers every method with result and keeps each call it read.
func callRecorder(t *testing.T, result string) (string, int, *[]recordedCall) {
	t.Helper()

	var calls []recordedCall
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var call recordedCall
		if err := json.NewDecoder(r.Body).Decode(&call); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		calls = append(calls, call)

		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`)); err != nil {
			t.Errorf("write response: %v", err)
		}
	}))
	t.Cleanup(srv.Close)

	host, port, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	portNum, err := strconv.Atoi(port)
	require.NoError(t, err)
	return host, portNum, &calls
}

func recordingHandler(t *testing.T, result string) (*Handler, *[]recordedCall) {
	t.Helper()
	host, port, calls := callRecorder(t, result)
	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, port)}), calls
}

// Truthcoin 0.20 dropped transfer and withdraw. create_transfer and
// create_withdrawal sign, send and return the txid.
func TestHandlerSendsTheCreateMethods(t *testing.T) {
	h, calls := recordingHandler(t, `"txid1"`)

	transfer, err := h.Transfer(context.Background(), connect.NewRequest(&pb.TransferRequest{
		Address: "dest", AmountSats: 5000, FeeSats: 100,
	}))
	require.NoError(t, err)
	assert.Equal(t, "txid1", transfer.Msg.Txid)

	withdraw, err := h.Withdraw(context.Background(), connect.NewRequest(&pb.WithdrawRequest{
		Address: "bc1qmain", AmountSats: 7000, SideFeeSats: 100, MainFeeSats: 200,
	}))
	require.NoError(t, err)
	assert.Equal(t, "txid1", withdraw.Msg.Txid)

	require.Len(t, *calls, 2)
	assert.Equal(t, "create_transfer", (*calls)[0].Method)
	assert.JSONEq(t, `["dest",5000,100]`, string((*calls)[0].Params))
	assert.Equal(t, "create_withdrawal", (*calls)[1].Method)
	assert.JSONEq(t, `["bc1qmain",7000,100,200]`, string((*calls)[1].Params))
}

func TestClientSendsTheCreateMethods(t *testing.T) {
	host, port, calls := callRecorder(t, `"txid1"`)
	c := NewClient(host, port)

	_, err := c.Transfer(context.Background(), "dest", 5000, 100)
	require.NoError(t, err)
	_, err = c.Withdraw(context.Background(), "bc1qmain", 7000, 100, 200)
	require.NoError(t, err)

	require.Len(t, *calls, 2)
	assert.Equal(t, "create_transfer", (*calls)[0].Method)
	assert.JSONEq(t, `["dest",5000,100]`, string((*calls)[0].Params))
	assert.Equal(t, "create_withdrawal", (*calls)[1].Method)
	assert.JSONEq(t, `["bc1qmain",7000,100,200]`, string((*calls)[1].Params))
}

// transfer_votecoin takes no memo since truthcoin 0.20.
func TestVotecoinTransferSendsNoMemo(t *testing.T) {
	h, calls := recordingHandler(t, `"txid1"`)
	memo := "hello"

	_, err := h.VotecoinTransfer(context.Background(), connect.NewRequest(&pb.VotecoinTransferRequest{
		Dest: "dest", Amount: 3, FeeSats: 100, Memo: &memo,
	}))
	require.NoError(t, err)
	_, err = h.TransferVotecoin(context.Background(), connect.NewRequest(&pb.TransferVotecoinRequest{
		Dest: "dest", Amount: 3, FeeSats: 100, Memo: &memo,
	}))
	require.NoError(t, err)

	require.Len(t, *calls, 2)
	for _, call := range *calls {
		assert.Equal(t, "transfer_votecoin", call.Method)
		assert.JSONEq(t, `["dest",3,100]`, string(call.Params))
	}
}

// get_block answers null for a block the node does not hold.
func TestGetBlockMapsAMissingBlockToEmpty(t *testing.T) {
	h, _ := recordingHandler(t, `null`)

	resp, err := h.GetBlock(context.Background(), connect.NewRequest(&pb.GetBlockRequest{Hash: "aa"}))
	require.NoError(t, err)
	assert.Empty(t, resp.Msg.BlockJson)
}
