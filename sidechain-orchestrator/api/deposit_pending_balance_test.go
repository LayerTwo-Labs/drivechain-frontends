package api

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// depositNodeState is what the fake sidechain answers right now.
type depositNodeState struct {
	balanceSats int64
	coins       string
	addresses   []string
}

// newDepositTestHandler starts a fake sidechain node and wires a handler with
// a real wallet service to it.
func newDepositTestHandler(t *testing.T, state *depositNodeState) (*Handler, *wallet.Service) {
	t.Helper()

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
			response["result"] = map[string]int64{
				"total_sats": state.balanceSats, "available_sats": state.balanceSats,
			}
		case "get_wallet_addresses":
			response["result"] = state.addresses
		case "get_wallet_utxos":
			response["result"] = json.RawMessage(state.coins)
		case "list_mempool":
			response["result"] = json.RawMessage("[]")
		default:
			response["error"] = map[string]any{"code": -32601, "message": "method not found"}
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			t.Error(err)
		}
	}))
	t.Cleanup(node.Close)

	host, port := hostPort(t, node)
	cfg := orchestrator.BinaryConfig{
		Name: "thunder", DisplayName: "Thunder", Host: host, Port: port,
		ChainLayer: 2, Slot: 9,
	}
	orch := orchestrator.New(
		t.TempDir(), string(config.NetworkECash), t.TempDir(),
		[]orchestrator.BinaryConfig{cfg}, zerolog.New(io.Discard),
	)

	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork(string(config.NetworkECash))
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	_, err := svc.GenerateWallet("depositor", "", "", nil)
	require.NoError(t, err)
	require.NotEmpty(t, svc.ActiveWalletID())
	orch.WalletSvc = svc

	handler := NewHandler(orch)
	handler.SetSidechainBalance("thunder", sidechain.NewJSONRPCProxy(host, port).GetBalance)
	return handler, svc
}

func thunderBalance(t *testing.T, handler *Handler) (confirmed, pending uint64) {
	t.Helper()
	response, err := handler.GetSidechainBalance(context.Background(), connect.NewRequest(
		&pb.GetSidechainBalanceRequest{Sidechain: pb.BinaryType_BINARY_TYPE_THUNDER},
	))
	require.NoError(t, err)
	return response.Msg.ConfirmedSats, response.Msg.PendingSats
}

// depositCoins writes the coin listing a sidechain answers for these deposit
// txids, each paying the same address.
func depositCoins(destination string, txids ...string) string {
	rows := make([]string, 0, len(txids))
	for _, txid := range txids {
		rows = append(rows, `{"outpoint":{"Deposit":"`+txid+`:0"},`+
			`"output":{"address":"`+destination+`","content":{"Value":1000000}}}`)
	}
	return "[" + strings.Join(rows, ",") + "]"
}

// A deposit is a mainchain transaction, so the sidechain node reads zero for
// hours after the broadcast. The money must read as unconfirmed the whole
// time, then move to confirmed exactly once, and never count twice.
func TestSidechainBalanceCountsAPendingDeposit(t *testing.T) {
	const (
		depositTxid = "280a3c6e7e5c6f272e43df3aaece690c94d50b321d24f55f1e46abe8124e7cc3"
		destination = "2yxqLNxuYiLRMWATFQcqf3iV3nKh"
		amountSats  = 1_000_000
	)
	ctx := context.Background()
	state := &depositNodeState{coins: "[]", addresses: []string{destination}}
	handler, svc := newDepositTestHandler(t, state)

	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: depositTxid, WalletID: svc.ActiveWalletID(), Slot: 9,
		Destination: destination, AmountSats: amountSats, FeeSats: 10_000,
	}))

	confirmed, pending := thunderBalance(t, handler)
	assert.Zero(t, confirmed, "the sidechain has not seen the deposit yet")
	assert.Equal(t, uint64(amountSats), pending, "the deposit reads as unconfirmed while it waits")

	// The sidechain connects the mainchain block and pays the coin.
	state.balanceSats = amountSats
	state.coins = depositCoins(destination, depositTxid)

	confirmed, pending = thunderBalance(t, handler)
	assert.Equal(t, uint64(amountSats), confirmed)
	assert.Zero(t, pending, "a credited deposit leaves the unconfirmed count")
	assert.Equal(t, uint64(amountSats), confirmed+pending, "the deposit counts once, not twice")

	// The user spends the deposit coin, so it leaves the listing. The stamp is
	// permanent, so the deposit never reads as pending again.
	state.balanceSats = 0
	state.coins = "[]"

	confirmed, pending = thunderBalance(t, handler)
	assert.Zero(t, confirmed)
	assert.Zero(t, pending, "a spent deposit never returns to the unconfirmed count")
}

// The deposit page hands out one address, so two deposits pay the same one.
// The coin the first deposit made must not credit the second.
func TestSidechainBalanceCountsASecondDepositToOneAddress(t *testing.T) {
	const (
		firstTxid   = "280a3c6e7e5c6f272e43df3aaece690c94d50b321d24f55f1e46abe8124e7cc3"
		secondTxid  = "d6584dc6145a7c7d219ba1cd2e333bfe8288055965636bbc5c405ed5394bdd8c"
		destination = "2yxqLNxuYiLRMWATFQcqf3iV3nKh"
		amountSats  = 1_000_000
	)
	ctx := context.Background()
	state := &depositNodeState{
		balanceSats: amountSats,
		coins:       depositCoins(destination, firstTxid),
		addresses:   []string{destination},
	}
	handler, svc := newDepositTestHandler(t, state)

	for _, txid := range []string{firstTxid, secondTxid} {
		require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
			Txid: txid, WalletID: svc.ActiveWalletID(), Slot: 9,
			Destination: destination, AmountSats: amountSats, FeeSats: 10_000,
		}))
	}

	confirmed, pending := thunderBalance(t, handler)
	assert.Equal(t, uint64(amountSats), confirmed)
	assert.Equal(t, uint64(amountSats), pending, "the second deposit is still on its way")

	// The sidechain pays the second deposit too.
	state.balanceSats = 2 * amountSats
	state.coins = depositCoins(destination, firstTxid, secondTxid)

	confirmed, pending = thunderBalance(t, handler)
	assert.Equal(t, uint64(2*amountSats), confirmed)
	assert.Zero(t, pending, "both deposits count once")
}

// The balance answers for one chain. A deposit to another slot pays another
// treasury, so it would report money this view never holds.
func TestSidechainBalanceIgnoresAnotherSlot(t *testing.T) {
	const destination = "2yxqLNxuYiLRMWATFQcqf3iV3nKh"
	ctx := context.Background()
	state := &depositNodeState{coins: "[]", addresses: []string{destination}}
	handler, svc := newDepositTestHandler(t, state)

	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "other-slot", WalletID: svc.ActiveWalletID(), Slot: 2,
		Destination: destination, AmountSats: 700_000,
	}))

	confirmed, pending := thunderBalance(t, handler)
	assert.Zero(t, confirmed)
	assert.Zero(t, pending, "another slot never reaches this balance")
}

// One starter seeds the sidechain wallet for the whole install. A switch of
// the mainchain wallet leaves the sidechain balance alone, so a deposit
// another mainchain wallet paid for still lands here.
func TestSidechainBalanceKeepsADepositFromAnotherMainchainWallet(t *testing.T) {
	const destination = "2yxqLNxuYiLRMWATFQcqf3iV3nKh"
	ctx := context.Background()
	state := &depositNodeState{coins: "[]", addresses: []string{destination}}
	handler, svc := newDepositTestHandler(t, state)

	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "other-wallet", WalletID: "SOMEOTHERWALLET", Slot: 9,
		Destination: destination, AmountSats: 400_000,
	}))

	confirmed, pending := thunderBalance(t, handler)
	assert.Zero(t, confirmed)
	assert.Equal(t, uint64(400_000), pending, "the coins land in this sidechain wallet")
}

// A deposit paid to somebody else's address never becomes our money, so it
// must not read as our unconfirmed balance.
func TestSidechainBalanceIgnoresADepositToAForeignAddress(t *testing.T) {
	ctx := context.Background()
	state := &depositNodeState{coins: "[]", addresses: []string{"mine"}}
	handler, svc := newDepositTestHandler(t, state)

	require.NoError(t, svc.RecordSidechainDeposit(ctx, wallet.SidechainDeposit{
		Txid: "gift", WalletID: svc.ActiveWalletID(), Slot: 9,
		Destination: "a-friends-address", AmountSats: 900_000,
	}))

	confirmed, pending := thunderBalance(t, handler)
	assert.Zero(t, confirmed)
	assert.Zero(t, pending)
}
