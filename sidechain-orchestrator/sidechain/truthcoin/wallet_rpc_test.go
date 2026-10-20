package truthcoin

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

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

	transfer, err := h.Transfer(context.Background(), &pb.TransferRequest{
		Address: "dest", AmountSats: 5000, FeeSats: 100,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid1", transfer.Txid)

	withdraw, err := h.Withdraw(context.Background(), &pb.WithdrawRequest{
		Address: "bc1qmain", AmountSats: 7000, SideFeeSats: 100, MainFeeSats: 200,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid1", withdraw.Txid)

	require.Len(t, *calls, 2)
	assert.Equal(t, "create_transfer", (*calls)[0].Method)
	assert.JSONEq(t, `["dest",5000,100]`, string((*calls)[0].Params))
	assert.Equal(t, "create_withdrawal", (*calls)[1].Method)
	assert.JSONEq(t, `["bc1qmain",7000,100,200]`, string((*calls)[1].Params))
}

func TestClientSendsTheCreateMethods(t *testing.T) {
	host, port, calls := callRecorder(t, `"txid1"`)
	c := NewClient(host, port, "")

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

	_, err := h.VotecoinTransfer(context.Background(), &pb.VotecoinTransferRequest{
		Dest: "dest", Amount: 3, FeeSats: 100, Memo: &memo, //nolint:staticcheck // old clients send Amount
	})
	require.NoError(t, err)
	_, err = h.TransferVotecoin(context.Background(), &pb.TransferVotecoinRequest{
		Dest: "dest", Amount: 3, FeeSats: 100, Memo: &memo, //nolint:staticcheck // old clients send Amount
	})
	require.NoError(t, err)

	require.Len(t, *calls, 2)
	for _, call := range *calls {
		assert.Equal(t, "transfer_votecoin", call.Method)
		assert.JSONEq(t, `["dest",3,100]`, string(call.Params))
	}
}

// transfer_votecoin takes an f64 amount.
func TestVotecoinTransferSendsTheFractionalAmount(t *testing.T) {
	h, calls := recordingHandler(t, `"txid1"`)
	amount := 0.25

	_, err := h.VotecoinTransfer(context.Background(), &pb.VotecoinTransferRequest{
		Dest: "dest", VotecoinAmount: &amount, FeeSats: 100,
	})
	require.NoError(t, err)
	_, err = h.TransferVotecoin(context.Background(), &pb.TransferVotecoinRequest{
		Dest: "dest", VotecoinAmount: &amount, FeeSats: 100,
	})
	require.NoError(t, err)

	require.Len(t, *calls, 2)
	for _, call := range *calls {
		assert.Equal(t, "transfer_votecoin", call.Method)
		assert.JSONEq(t, `["dest",0.25,100]`, string(call.Params))
	}
}

// votecoin_balance answers an f64.
func TestVotecoinBalanceReadsAFraction(t *testing.T) {
	h, _ := recordingHandler(t, `0.75`)

	resp, err := h.VotecoinBalance(context.Background(), &pb.VotecoinBalanceRequest{Address: "voter"})
	require.NoError(t, err)
	assert.InDelta(t, 0.75, resp.VotecoinBalance, 0)
	assert.Equal(t, int64(0), resp.Balance) //nolint:staticcheck // old clients read Balance
}

// get_bmm_inclusions answers a list of mainchain block hashes.
func TestGetBmmInclusionsReadsAList(t *testing.T) {
	const inclusions = `["000000000000000007677bb6ca40424eb40afe6979f52f98579ba7ed1ddbac79"]`
	h, _ := recordingHandler(t, inclusions)

	resp, err := h.GetBmmInclusions(context.Background(), &pb.GetBmmInclusionsRequest{BlockHash: "aa"})
	require.NoError(t, err)
	assert.JSONEq(t, inclusions, resp.Inclusions)

	host, port, _ := callRecorder(t, inclusions)
	hashes, err := NewClient(host, port, "").GetBMMInclusions(context.Background(), "aa")
	require.NoError(t, err)
	assert.Equal(t, []string{"000000000000000007677bb6ca40424eb40afe6979f52f98579ba7ed1ddbac79"}, hashes)
}

// get_block answers null for a block the node does not hold.
func TestGetBlockMapsAMissingBlockToEmpty(t *testing.T) {
	h, _ := recordingHandler(t, `null`)

	resp, err := h.GetBlock(context.Background(), &pb.GetBlockRequest{Hash: "aa"})
	require.NoError(t, err)
	assert.Empty(t, resp.BlockJson)
}

// get_voter_address answers the base58 address of wallet index 0.
func TestGetVoterAddressReadsTheAddress(t *testing.T) {
	h, calls := recordingHandler(t, `"Xc3D7ZjNez3ReowLm1yz1zSvYe1"`)

	resp, err := h.GetVoterAddress(context.Background(), &pb.GetVoterAddressRequest{})
	require.NoError(t, err)
	assert.Equal(t, "Xc3D7ZjNez3ReowLm1yz1zSvYe1", resp.Address)

	require.Len(t, *calls, 1)
	assert.Equal(t, "get_voter_address", (*calls)[0].Method)
}

// market_amplify_beta takes one request object and answers the txid.
func TestMarketAmplifyBetaSendsTheRequest(t *testing.T) {
	h, calls := recordingHandler(t, `"txid1"`)

	resp, err := h.MarketAmplifyBeta(context.Background(), &pb.MarketAmplifyBetaRequest{
		MarketId: "5e5ed0d19c4f", AmountSats: 50000,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid1", resp.Txid)

	require.Len(t, *calls, 1)
	assert.Equal(t, "market_amplify_beta", (*calls)[0].Method)
	assert.JSONEq(t, `[{"market_id":"5e5ed0d19c4f","amount_sats":50000}]`, string((*calls)[0].Params))
}
