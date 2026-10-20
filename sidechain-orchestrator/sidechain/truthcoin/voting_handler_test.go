package truthcoin

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

func votingStubNode(t *testing.T, result string, method, params *string) *Handler {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Errorf("decode request: %v", err)
			return
		}
		*method, *params = req.Method, string(req.Params)
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
	return NewHandler(&sidechain.JSONRPCProxy{Client: rpc.New(host, portNum)})
}

func TestVotingHandlersCallNodeMethods(t *testing.T) {
	raw, err := os.ReadFile("testdata/openapi_schema.json")
	require.NoError(t, err)
	var schema struct {
		Paths map[string]json.RawMessage `json:"paths"`
	}
	require.NoError(t, json.Unmarshal(raw, &schema))

	period := int32(3)
	status := "Claimed"
	isScaled := true
	minValue, maxValue := int32(0), int32(100)
	voter := "tNvoter"

	cases := []struct {
		name       string
		result     string
		call       func(context.Context, *Handler) (string, error)
		wantMethod string
		wantParams string
		wantResult string
	}{
		{
			name:   "SlotStatus",
			result: `{"is_testing_mode":true,"blocks_per_period":10,"current_period":3,"current_period_name":"P3"}`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.SlotStatus(ctx, &pb.SlotStatusRequest{})
				if err != nil {
					return "", err
				}
				return resp.StatusJson, nil
			},
			wantMethod: "decision_status",
			wantParams: ``,
			wantResult: `{"is_testing_mode":true,"blocks_per_period":10,"current_period":3,"current_period_name":"P3"}`,
		},
		{
			name:   "SlotList",
			result: `[]`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.SlotList(ctx, &pb.SlotListRequest{Period: &period, Status: &status})
				if err != nil {
					return "", err
				}
				return resp.SlotsJson, nil
			},
			wantMethod: "decision_list",
			wantParams: `[{"period":3,"status":"Claimed"}]`,
			wantResult: `[]`,
		},
		{
			name:   "SlotGet",
			result: `null`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.SlotGet(ctx, &pb.SlotGetRequest{SlotId: "002a0001"})
				if err != nil {
					return "", err
				}
				return resp.SlotJson, nil
			},
			wantMethod: "decision_get",
			wantParams: `["002a0001"]`,
			wantResult: ``,
		},
		{
			name:   "SlotClaim",
			result: `{"txid":"claimtx","decision_ids":["002a0001"],"listing_fee_paid_sats":100}`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.SlotClaim(ctx, &pb.SlotClaimRequest{
					FeeSats:     1000,
					PeriodIndex: 3,
					Question:    "Inflation?",
					IsScaled:    &isScaled,
					Min:         &minValue,
					Max:         &maxValue,
				})
				if err != nil {
					return "", err
				}
				return resp.Txid, nil
			},
			wantMethod: "decision_claim",
			wantParams: `[{"decision_type":"scaled","decisions":[{"period_index":3,"header":"Inflation?"}],"min":0,"max":100,"tx_fee_sats":1000}]`,
			wantResult: `claimtx`,
		},
		{
			name:   "SlotClaimCategory",
			result: `{"txid":"cattx","decision_ids":[],"listing_fee_paid_sats":0}`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.SlotClaimCategory(ctx, &pb.SlotClaimCategoryRequest{
					SlotsJson: `[{"period_index":3,"header":"Winner?","option_labels":["A","B"]}]`,
					FeeSats:   1000,
				})
				if err != nil {
					return "", err
				}
				return resp.Txid, nil
			},
			wantMethod: "decision_claim",
			wantParams: `[{"decision_type":"category","decisions":[{"period_index":3,"header":"Winner?","option_labels":["A","B"]}],"tx_fee_sats":1000}]`,
			wantResult: `cattx`,
		},
		{
			name:   "VoteSubmit",
			result: `"votetx"`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.VoteSubmit(ctx, &pb.VoteSubmitRequest{
					VotesJson: `[{"decision_id":"002a0001","vote_value":1.0}]`,
					FeeSats:   1000,
				})
				if err != nil {
					return "", err
				}
				return resp.Txid, nil
			},
			wantMethod: "vote_submit",
			wantParams: `[[{"decision_id":"002a0001","vote_value":1.0}],1000]`,
			wantResult: `votetx`,
		},
		{
			name:   "VoteList",
			result: `[]`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.VoteList(ctx, &pb.VoteListRequest{Voter: &voter, PeriodId: &period})
				if err != nil {
					return "", err
				}
				return resp.VotesJson, nil
			},
			wantMethod: "vote_list",
			wantParams: `[{"voter":"tNvoter","decision_id":null,"period_id":3}]`,
			wantResult: `[]`,
		},
		{
			name:   "MyUtxos",
			result: `[]`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.MyUtxos(ctx, &pb.MyUtxosRequest{})
				if err != nil {
					return "", err
				}
				return resp.UtxosJson, nil
			},
			wantMethod: "get_wallet_utxos",
			wantParams: ``,
			wantResult: `[]`,
		},
		{
			name:   "VotecoinTransfer",
			result: `"vctx"`,
			call: func(ctx context.Context, h *Handler) (string, error) {
				resp, err := h.VotecoinTransfer(ctx, &pb.VotecoinTransferRequest{
					Dest:    "tNdest",
					Amount:  5, //nolint:staticcheck // old clients send Amount
					FeeSats: 1000,
				})
				if err != nil {
					return "", err
				}
				return resp.Txid, nil
			},
			wantMethod: "transfer_votecoin",
			wantParams: `["tNdest",5,1000]`,
			wantResult: `vctx`,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var method, params string
			h := votingStubNode(t, tc.result, &method, &params)

			got, err := tc.call(context.Background(), h)
			require.NoError(t, err)

			assert.Equal(t, tc.wantMethod, method)
			assert.Contains(t, schema.Paths, method)
			if tc.wantParams == "" {
				assert.Empty(t, params)
			} else {
				assert.JSONEq(t, tc.wantParams, params)
			}
			assert.Equal(t, tc.wantResult, got)
		})
	}
}

// A missing decision, voter or period comes back as JSON null, which the
// clients must read as absent.
func TestVotingHandlersMapNullToEmpty(t *testing.T) {
	calls := map[string]func(context.Context, *Handler) (string, error){
		"SlotGet": func(ctx context.Context, h *Handler) (string, error) {
			resp, err := h.SlotGet(ctx, &pb.SlotGetRequest{SlotId: "004008"})
			if err != nil {
				return "", err
			}
			return resp.SlotJson, nil
		},
		"VoteVoter": func(ctx context.Context, h *Handler) (string, error) {
			resp, err := h.VoteVoter(ctx, &pb.VoteVoterRequest{Address: "tNvoter"})
			if err != nil {
				return "", err
			}
			return resp.VoterJson, nil
		},
		"VotePeriod": func(ctx context.Context, h *Handler) (string, error) {
			resp, err := h.VotePeriod(ctx, &pb.VotePeriodRequest{})
			if err != nil {
				return "", err
			}
			return resp.PeriodJson, nil
		},
	}
	for name, call := range calls {
		t.Run(name, func(t *testing.T) {
			var method, params string
			got, err := call(context.Background(), votingStubNode(t, "null", &method, &params))
			require.NoError(t, err)
			assert.Empty(t, got)
		})
	}
}
