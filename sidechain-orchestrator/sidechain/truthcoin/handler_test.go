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

// capturingRPC returns a Handler wired to a JSON-RPC server that replies with a
// fixed result and records the params of every request it receives.
func capturingRPC(t *testing.T, result string) (*Handler, *[]json.RawMessage) {
	t.Helper()

	var params []json.RawMessage
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		params = append(params, req.Params)

		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(srv.Close)

	host, port, err := net.SplitHostPort(srv.Listener.Addr().String())
	require.NoError(t, err)
	portNum, err := strconv.Atoi(port)
	require.NoError(t, err)

	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, portNum)}), &params
}

func TestMarketCreateSendsRequestObject(t *testing.T) {
	h, params := capturingRPC(t, `{"txid":"txid123","market_id":"market1","claimed_decisions":[]}`)

	beta := 7.0
	tradingFee := 0.005
	resp, err := h.MarketCreate(context.Background(), connect.NewRequest(&pb.MarketCreateRequest{
		Title:       "Will it rain?",
		Description: "weather market",
		Dimensions:  `[{"type":"existing","id":"deadbeef"}]`,
		FeeSats:     1000,
		Beta:        &beta,
		TradingFee:  &tradingFee,
		Tags:        []string{"weather"},
	}))
	require.NoError(t, err)
	assert.Equal(t, "txid123", resp.Msg.Txid)

	require.Len(t, *params, 1)
	assert.JSONEq(t, `[{
		"title": "Will it rain?",
		"description": "weather market",
		"dimensions": [{"type":"existing","id":"deadbeef"}],
		"tx_fee_sats": 1000,
		"beta": 7.0,
		"trading_fee": 0.005
	}]`, string((*params)[0]))
}

func TestMarketCreateRejectsNonJSONDimensions(t *testing.T) {
	h, _ := capturingRPC(t, `{"txid":"txid123","market_id":"market1","claimed_decisions":[]}`)

	_, err := h.MarketCreate(context.Background(), connect.NewRequest(&pb.MarketCreateRequest{
		Title:       "Will it rain?",
		Description: "weather market",
		Dimensions:  "[deadbeef]",
		FeeSats:     1000,
	}))
	require.Error(t, err)
	assert.Contains(t, err.Error(), "unmarshal dimensions")
}

func TestMarketBuySendsRequestObject(t *testing.T) {
	h, params := capturingRPC(t, `{"cost_sats":100,"trading_fee_sats":1,"new_price":0.6}`)

	dryRun := true
	feeSats := int64(1000)
	maxCost := int64(5000)
	// A fractional share count must be coerced to the integer the RPC expects.
	_, err := h.MarketBuy(context.Background(), connect.NewRequest(&pb.MarketBuyRequest{
		MarketId:     "market1",
		OutcomeIndex: 2,
		SharesAmount: 7.5,
		DryRun:       &dryRun,
		FeeSats:      &feeSats,
		MaxCost:      &maxCost,
	}))
	require.NoError(t, err)

	require.Len(t, *params, 1)
	assert.JSONEq(t, `[{
		"market_id": "market1",
		"outcome_index": 2,
		"shares_amount": 7,
		"dry_run": true,
		"max_cost": 5000
	}]`, string((*params)[0]))
}

func TestMarketSellSendsRequestObject(t *testing.T) {
	h, params := capturingRPC(t, `{"proceeds_sats":100,"trading_fee_sats":1,"net_proceeds_sats":99,"new_price":0.4}`)

	dryRun := false
	feeSats := int64(1000)
	minProceeds := int64(50)
	_, err := h.MarketSell(context.Background(), connect.NewRequest(&pb.MarketSellRequest{
		MarketId:      "market1",
		OutcomeIndex:  2,
		SharesAmount:  7,
		SellerAddress: "tNaddr",
		DryRun:        &dryRun,
		FeeSats:       &feeSats,
		MinProceeds:   &minProceeds,
	}))
	require.NoError(t, err)

	require.Len(t, *params, 1)
	assert.JSONEq(t, `[{
		"market_id": "market1",
		"outcome_index": 2,
		"shares_amount": 7,
		"seller_address": "tNaddr",
		"dry_run": false,
		"min_proceeds": 50
	}]`, string((*params)[0]))
}
