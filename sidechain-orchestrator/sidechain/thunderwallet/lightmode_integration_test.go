//go:build integration

package thunderwallet_test

import (
	"context"
	"os"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	bip39 "github.com/tyler-smith/go-bip39"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
	thundersvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	tw "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// This is the whole of light mode, end to end, with no thunder binary on the
// caller's side. The handler reads an index, derives its own keys, signs in
// this process, and broadcasts through the index.
//
// The node in this test only stands in for the rest of the network: it funds
// the wallet and makes blocks. Nothing the light wallet does asks it anything.
//
//	THUNDER_RPC_ADDR=127.0.0.1:6109 \
//	THUNDER_ESPLORA_URL=http://127.0.0.1:3009 \
//	MAINCHAIN_ADDRESS=... \
//	go test -tags integration -timeout 20m -run LightMode ./sidechain/thunderwallet/
func TestLightModeSpendsWithNoNode(t *testing.T) {
	indexURL := requireEsploraURL(t)
	network := dialNode(t)

	seed := bip39.NewSeed(newMnemonic(t), "")
	// Port 1 accepts nothing. A light user runs no thunder binary, so every
	// call this handler answers must avoid it.
	handler := thundersvc.NewHandlerWithSeed(
		sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() thundersvc.Mode {
			return thundersvc.Mode{IndexURL: indexURL, Params: &chaincfg.RegressionNetParams}
		},
		func() ([]byte, error) { return seed, nil },
	)
	ctx := context.Background()

	// 1. A receive address, derived here.
	addrResp, err := handler.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	mine, err := tw.ParseAddress(addrResp.Msg.Address)
	if err != nil {
		t.Fatalf("read the address the handler gave: %v", err)
	}
	t.Logf("light wallet address: %s", mine)

	// 2. The network pays it, and makes a block.
	network.fund(mine, fundingSats)

	// 3. The balance arrives through the index.
	awaitBalance(t, handler, fundingSats)

	// 4. A second address, which must differ once the first one is paid.
	nextResp, err := handler.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("second address: %v", err)
	}
	if nextResp.Msg.Address == mine.String() {
		t.Fatal("the wallet gave out a paid address again")
	}

	// 5. The UTXO list reads the same shape a node answers with.
	utxos, err := handler.GetWalletUtxos(ctx, connect.NewRequest(&pb.GetWalletUtxosRequest{}))
	if err != nil {
		t.Fatalf("utxos: %v", err)
	}
	if len(utxos.Msg.UtxosJson) < 2 {
		t.Fatalf("the wallet holds no utxos: %q", utxos.Msg.UtxosJson)
	}

	// 6. A payment, signed here and broadcast through the index.
	target := newMnemonic(t)
	otherRing, err := tw.DeriveKeyring(bip39.NewSeed(target, ""), 1)
	if err != nil {
		t.Fatalf("derive the recipient: %v", err)
	}
	recipient := otherRing.Addresses()[0]

	sendResp, err := handler.Transfer(ctx, connect.NewRequest(&pb.TransferRequest{
		Address:    recipient.String(),
		AmountSats: paymentSats,
		FeeSats:    feeSats,
	}))
	if err != nil {
		t.Fatalf("transfer: %v", err)
	}
	t.Logf("light wallet sent %s", sendResp.Msg.Txid)

	// 7. The network mines it, and the recipient reads the coin.
	network.mine()
	coins := awaitCoins(t, tw.NewIndexCoins(indexClient(t, indexURL)), []tw.Address{recipient})
	var got uint64
	for _, coin := range coins {
		got += coin.ValueSats
	}
	if got != paymentSats {
		t.Errorf("the recipient holds %d sats, want %d", got, paymentSats)
	}

	// 8. The history reads back, with the tip the index answered.
	history, err := handler.ListWalletTransactions(ctx,
		connect.NewRequest(&pb.ListWalletTransactionsRequest{}))
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(history.Msg.Transactions) == 0 {
		t.Error("the light wallet reads no history of its own payment")
	}
	if history.Msg.TipHeight == 0 {
		t.Error("the history carries no tip height")
	}
}

// requireEsploraURL names the index, and skips when there is none to read.
func requireEsploraURL(t *testing.T) string {
	t.Helper()
	url := os.Getenv("THUNDER_ESPLORA_URL")
	if url == "" {
		t.Skip("set THUNDER_ESPLORA_URL to run the light mode test")
	}
	return url
}

// newMnemonic makes a fresh wallet, so one run never spends another's coins.
func newMnemonic(t *testing.T) string {
	t.Helper()
	entropy, err := bip39.NewEntropy(128)
	if err != nil {
		t.Fatalf("entropy: %v", err)
	}
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		t.Fatalf("mnemonic: %v", err)
	}
	return mnemonic
}

func indexClient(t *testing.T, url string) *sidechainesplora.Client {
	t.Helper()
	return sidechainesplora.New(url)
}

// awaitBalance waits for the index to carry the payment through.
func awaitBalance(t *testing.T, handler *thundersvc.Handler, want int64) {
	t.Helper()
	deadline := time.Now().Add(90 * time.Second)
	for {
		resp, err := handler.GetBalance(context.Background(),
			connect.NewRequest(&pb.GetBalanceRequest{}))
		if err == nil && resp.Msg.TotalSats == want {
			return
		}
		if time.Now().After(deadline) {
			t.Fatalf("the balance never reached %d (last error: %v)", want, err)
		}
		time.Sleep(3 * time.Second)
	}
}

// A light withdrawal must reach the node through the index, and the node must
// accept the field names the wallet writes.
func TestLightModeWithdrawsWithNoNode(t *testing.T) {
	indexURL := requireEsploraURL(t)
	mainAddress := os.Getenv("THUNDER_MAIN_ADDRESS")
	if mainAddress == "" {
		t.Skip("set THUNDER_MAIN_ADDRESS to run the light withdrawal test")
	}
	network := dialNode(t)

	const (
		lightFunding = 10_000_000
		payout       = 4_000_000
		mainFee      = 1_000_000
	)

	seed := bip39.NewSeed(newMnemonic(t), "")
	handler := thundersvc.NewHandlerWithSeed(
		sidechain.NewJSONRPCProxy("127.0.0.1", 1),
		func() thundersvc.Mode {
			return thundersvc.Mode{IndexURL: indexURL, Params: &chaincfg.RegressionNetParams}
		},
		func() ([]byte, error) { return seed, nil },
	)
	ctx := context.Background()

	addrResp, err := handler.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("new address: %v", err)
	}
	mine, err := tw.ParseAddress(addrResp.Msg.Address)
	if err != nil {
		t.Fatalf("read the address: %v", err)
	}
	network.fund(mine, lightFunding)
	awaitBalance(t, handler, lightFunding)

	resp, err := handler.Withdraw(ctx, connect.NewRequest(&pb.WithdrawRequest{
		Address:     mainAddress,
		AmountSats:  payout,
		SideFeeSats: feeSats,
		MainFeeSats: mainFee,
	}))
	if err != nil {
		t.Fatalf("the node refused the withdrawal: %v", err)
	}
	t.Logf("light wallet withdrew %s", resp.Msg.Txid)

	network.mine()
	awaitBalance(t, handler, lightFunding-payout-mainFee-feeSats)
}
