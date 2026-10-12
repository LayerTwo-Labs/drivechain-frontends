package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"slices"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

const (
	solanaCritical  = "00112233445566778899aabbccddeeff102132435465768798a9bacbdcedfe0f"
	solanaPrevMain  = "00000000000000000001f00dbabe0000000000000000000000000000000000ff"
	solanaMainBlock = "0000000000000000000000000000000000000000000000000000000000c0ffee"
	solanaBlock     = `{"prev_main_hash":"` + solanaPrevMain + `","height":12,"bank_hash":"9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin","payee":"4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T","slot":8}`
)

// solanaNode answers the contract of the Solana sidechain node, and records
// the params of each call.
func solanaNode(t *testing.T) (host string, port int, seen map[string]json.RawMessage) {
	t.Helper()
	seen = map[string]json.RawMessage{}
	results := map[string]string{
		"get_block_template": `{"critical_hash":"` + solanaCritical + `","block":` + solanaBlock + `,"fees_sats":7000}`,
		"connect_block":      `true`,
		"get_bmm_inclusions": `["` + solanaMainBlock + `"]`,
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string          `json:"method"`
			Params json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		seen[req.Method] = req.Params
		result, ok := results[req.Method]
		if !ok {
			t.Errorf("unexpected method: %s", req.Method)
		}
		_, _ = w.Write([]byte(`{"jsonrpc":"2.0","id":1,"result":` + result + `}`))
	}))
	t.Cleanup(srv.Close)
	host, port = hostPort(t, srv)
	return host, port, seen
}

func solanaHandler(t *testing.T, host string, port int, wallet *fakeBidWallet) *BMMHandler {
	t.Helper()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir("") })
	orch := orchestrator.New(t.TempDir(), string(config.NetworkSignet), t.TempDir(), []orchestrator.BinaryConfig{
		{Name: "solana", ChainLayer: 2, Slot: 8, Host: host, Port: port, External: true},
	}, zerolog.New(io.Discard))
	t.Cleanup(orch.StopAllMonitors)
	h := NewBMMHandler(orch, nil)
	h.wallet = wallet
	h.SetCoreCaller((&fakeSlotMempool{}).call)
	h.syncStatus = func(context.Context) (*orchestrator.SyncStatus, error) {
		return &orchestrator.SyncStatus{
			Mainchain: &orchestrator.ChainSyncResult{Blocks: 100, Headers: 100},
			Enforcer:  &orchestrator.ChainSyncResult{Blocks: 100, Headers: 100},
		}, nil
	}
	return h
}

// The bid commits to the template's critical hash as the node gives it, and to
// the mainchain block the template builds on, in slot 8.
func TestSolanaBidCommitsToTheTemplate(t *testing.T) {
	host, port, _ := solanaNode(t)
	const coin = "1111111111111111111111111111111111111111111111111111111111111111"
	wallet := &fakeBidWallet{
		sendTxid: "2222222222222222222222222222222222222222222222222222222222222222",
		utxos:    []*wpb.UnspentOutput{{Txid: coin, AmountSats: 1_000_000, Spendable: true, Confirmations: 6}},
	}
	h := solanaHandler(t, host, port, wallet)

	resp, err := h.CreateBid(context.Background(), connect.NewRequest(&bmmpb.CreateBidRequest{
		Sidechain:  pb.BinaryType_BINARY_TYPE_SOLANA,
		WalletId:   "bidder",
		BidSats:    1_000,
		MaxBidSats: 30_000,
	}))
	require.NoError(t, err)

	assert.Equal(t, solanaCritical, resp.Msg.CriticalHash)
	assert.Equal(t, solanaPrevMain, resp.Msg.PrevMainHash)
	assert.Equal(t, int64(7000), resp.Msg.FeesSats)
	assert.JSONEq(t, solanaBlock, resp.Msg.BlockJson)

	require.Len(t, wallet.sends, 1)
	send := wallet.sends[0]
	assert.Equal(t, "bidder", send.WalletId)
	require.Len(t, send.RawOutputs, 1)
	script, err := hex.DecodeString(send.RawOutputs[0].ScriptHex)
	require.NoError(t, err)

	request := orchestrator.ParseM8BmmRequestScript(script)
	require.NotNil(t, request)
	assert.Equal(t, uint8(8), request.Slot)

	critical, err := hex.DecodeString(solanaCritical)
	require.NoError(t, err)
	assert.Equal(t, critical, script[6:38], "the critical hash goes in as the node gives it")
	prevMain, err := hex.DecodeString(solanaPrevMain)
	require.NoError(t, err)
	slices.Reverse(prevMain)
	assert.Equal(t, prevMain, script[38:70], "the mainchain hash goes in internal byte order")
}

// A won bid hands the template block back with the mainchain block that took
// the bid.
func TestSolanaConnectBidSendsTheBlockAndTheMainBlock(t *testing.T) {
	host, port, seen := solanaNode(t)
	h := solanaHandler(t, host, port, &fakeBidWallet{})

	resp, err := h.ConnectBid(context.Background(), connect.NewRequest(&bmmpb.ConnectBidRequest{
		Sidechain:    pb.BinaryType_BINARY_TYPE_SOLANA,
		CriticalHash: solanaCritical,
		BlockJson:    solanaBlock,
	}))
	require.NoError(t, err)

	assert.True(t, resp.Msg.Connected)
	assert.Equal(t, solanaMainBlock, resp.Msg.MainBlockHash)
	assert.JSONEq(t, `["`+solanaCritical+`"]`, string(seen["get_bmm_inclusions"]))
	assert.JSONEq(t, `[`+solanaBlock+`,"`+solanaMainBlock+`"]`, string(seen["connect_block"]))
}
