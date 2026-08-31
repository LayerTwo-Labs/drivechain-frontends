//go:build integration

package thunderwallet_test

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"crypto/tls"
	"net"

	"connectrpc.com/connect"
	bip39 "github.com/tyler-smith/go-bip39"
	"golang.org/x/net/http2"
	"google.golang.org/protobuf/types/known/wrapperspb"

	mainchainpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
	tw "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// These tests drive the whole light wallet against a real thunder node: derive
// a key, take a payment, read the coin back, then spend it and see the node
// accept and mine the result.
//
// Set THUNDER_RPC_ADDR to a node that can mine, such as a regtest node with an
// enforcer under it. Set THUNDER_ESPLORA_URL to also read coins through the
// index, which is what light mode does.
//
//	THUNDER_RPC_ADDR=127.0.0.1:6109 \
//	THUNDER_ESPLORA_URL=http://127.0.0.1:3009 \
//	go test -tags integration -timeout 10m ./sidechain/thunderwallet/

const (
	// fundingSats is what the node pays the wallet to start.
	fundingSats = 100_000_000
	// paymentSats is what the wallet then pays back.
	paymentSats = 40_000_000
	// feeSats is what the wallet leaves for the miner.
	feeSats = 1000
	// bmmBidSats is what one sidechain block costs on the mainchain.
	bmmBidSats = 100_000
)

type node struct {
	t      *testing.T
	client *rpc.Client
}

func dialNode(t *testing.T) *node {
	t.Helper()
	addr := os.Getenv("THUNDER_RPC_ADDR")
	if addr == "" {
		t.Skip("set THUNDER_RPC_ADDR to run the thunder wallet integration tests")
	}
	host, port, ok := splitAddr(addr)
	if !ok {
		t.Fatalf("THUNDER_RPC_ADDR %q is not host:port", addr)
	}
	return &node{t: t, client: rpc.New(host, port)}
}

func splitAddr(addr string) (string, int, bool) {
	host, portText, found := strings.Cut(addr, ":")
	if !found {
		return "", 0, false
	}
	var port int
	for _, r := range portText {
		if r < '0' || r > '9' {
			return "", 0, false
		}
		port = port*10 + int(r-'0')
	}
	return host, port, true
}

func (n *node) call(method string, params any, out any) {
	n.t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()
	if err := n.client.Call(ctx, method, params, out); err != nil {
		n.t.Fatalf("%s: %v", method, err)
	}
}

// mine makes one sidechain block.
//
// The node's mine call publishes a BMM request and then waits for a mainchain
// block to carry it, so the test makes that mainchain block at the same time.
// Without one, mine waits forever.
func (n *node) mine() {
	n.t.Helper()

	done := make(chan error, 1)
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 150*time.Second)
		defer cancel()
		var out json.RawMessage
		done <- n.client.Call(ctx, "mine", []any{bmmBidSats}, &out)
	}()

	// Give the bid time to reach the mainchain mempool, then confirm it.
	time.Sleep(6 * time.Second)
	n.generateMainchainBlocks(2)

	if err := <-done; err != nil {
		n.t.Fatalf("mine: %v", err)
	}
}

// generateMainchainBlocks asks the enforcer to make mainchain blocks, which is
// what confirms a BMM request.
func (n *node) generateMainchainBlocks(count uint32) {
	n.t.Helper()
	addr := os.Getenv("MAINCHAIN_ADDRESS")
	if addr == "" {
		n.t.Skip("set MAINCHAIN_ADDRESS and ENFORCER_URL so the test can confirm a BMM request")
	}
	client := mainchainv1connect.NewMiningServiceClient(
		h2cClient(), enforcerURL(n.t), connect.WithGRPC(),
	)
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	_, err := client.GenerateToAddress(ctx, connect.NewRequest(
		&mainchainpb.GenerateToAddressRequest{
			Blocks:  wrapperspb.UInt32(count),
			Address: addr,
		},
	))
	if err != nil {
		n.t.Fatalf("generate mainchain blocks: %v", err)
	}
}

// h2cClient speaks HTTP/2 without TLS, which is what the enforcer serves.
func h2cClient() *http.Client {
	return &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLSContext: func(
				ctx context.Context, network, addr string, _ *tls.Config,
			) (net.Conn, error) {
				var d net.Dialer
				return d.DialContext(ctx, network, addr)
			},
		},
	}
}

func enforcerURL(t *testing.T) string {
	t.Helper()
	url := os.Getenv("ENFORCER_URL")
	if url == "" {
		t.Skip("set ENFORCER_URL so the test can confirm a BMM request")
	}
	return url
}

// fund pays an address from the node's own wallet and mines it in.
//
// A transaction another run left in the mempool holds the same coins, so the
// first refusal mines that one in and the payment goes again.
func (n *node) fund(address tw.Address, sats uint64) {
	n.t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	var txid string
	params := []any{address.String(), sats, feeSats, nil}
	if err := n.client.Call(ctx, "create_transfer", params, &txid); err != nil {
		n.t.Logf("the wallet is busy, mining what is pending: %v", err)
		n.mine()
		n.call("create_transfer", params, &txid)
	}
	n.mine()
}

// awaitCoins waits for a coin source to see the wallet's money. An index lags
// the node by one sync pass, so this gives it time.
func awaitCoins(t *testing.T, source tw.CoinSource, addresses []tw.Address) []tw.Coin {
	t.Helper()
	deadline := time.Now().Add(60 * time.Second)
	for {
		coins, err := source.Coins(context.Background(), addresses)
		if err == nil && len(coins) > 0 {
			return coins
		}
		if time.Now().After(deadline) {
			t.Fatalf("the coin source never saw the payment (last error: %v)", err)
		}
		time.Sleep(2 * time.Second)
	}
}

// testKeyring derives a fresh wallet, so one run never spends another's coins.
func testKeyring(t *testing.T) (*tw.MemoryKeyring, tw.Address) {
	t.Helper()
	entropy, err := bip39.NewEntropy(128)
	if err != nil {
		t.Fatalf("entropy: %v", err)
	}
	mnemonic, err := bip39.NewMnemonic(entropy)
	if err != nil {
		t.Fatalf("mnemonic: %v", err)
	}
	ring, err := tw.DeriveKeyring(bip39.NewSeed(mnemonic, ""), 2)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	return ring, ring.Addresses()[0]
}

// The whole flow, reading coins from the node: fund, read, spend, confirm.
func TestWalletSpendsThroughTheNode(t *testing.T) {
	n := dialNode(t)
	ring, mine := testKeyring(t)
	source := tw.NewNodeCoins(n.client)

	n.fund(mine, fundingSats)
	coins := awaitCoins(t, source, []tw.Address{mine})
	if coins[0].ValueSats != fundingSats {
		t.Fatalf("the wallet holds %d sats, want %d", coins[0].ValueSats, fundingSats)
	}

	var payTo string
	n.call("get_new_address", nil, &payTo)
	recipient, err := tw.ParseAddress(payTo)
	if err != nil {
		t.Fatalf("parse %q: %v", payTo, err)
	}

	wallet := tw.New(source, ring, source)
	txid, err := wallet.Send(context.Background(), []tw.Address{mine},
		[]tw.Recipient{{Address: recipient, ValueSats: paymentSats}}, feeSats, mine)
	if err != nil {
		t.Fatalf("send: %v", err)
	}
	t.Logf("the node accepted %s", txid)

	n.mine()

	// The node reads the transaction back, so it reached a block.
	var got struct {
		BlockHash *string `json:"block_hash"`
	}
	n.call("get_transaction", []any{txid.String()}, &got)
	if got.BlockHash == nil {
		t.Fatal("the node accepted the transaction but never mined it")
	}
	t.Logf("mined in %s", *got.BlockHash)

	// The change comes back, and it spends again.
	after := awaitCoins(t, source, []tw.Address{mine})
	var change uint64
	for _, coin := range after {
		change += coin.ValueSats
	}
	if want := uint64(fundingSats - paymentSats - feeSats); change != want {
		t.Errorf("the change is %d sats, want %d", change, want)
	}
}

// The same flow, reading coins from the index. This is what a wallet with no
// node of its own runs.
func TestWalletSpendsThroughTheIndex(t *testing.T) {
	indexURL := os.Getenv("THUNDER_ESPLORA_URL")
	if indexURL == "" {
		t.Skip("set THUNDER_ESPLORA_URL to run the light mode test")
	}
	n := dialNode(t)
	ring, mine := testKeyring(t)

	// Light mode reads coins from the index, and broadcasts through a node.
	source := tw.NewIndexCoins(sidechainesplora.New(indexURL))
	broadcaster := tw.NewNodeCoins(n.client)

	n.fund(mine, fundingSats)
	coins := awaitCoins(t, source, []tw.Address{mine})
	if coins[0].ValueSats != fundingSats {
		t.Fatalf("the index reports %d sats, want %d", coins[0].ValueSats, fundingSats)
	}

	var payTo string
	n.call("get_new_address", nil, &payTo)
	recipient, err := tw.ParseAddress(payTo)
	if err != nil {
		t.Fatalf("parse %q: %v", payTo, err)
	}

	wallet := tw.New(source, ring, broadcaster)
	txid, err := wallet.Send(context.Background(), []tw.Address{mine},
		[]tw.Recipient{{Address: recipient, ValueSats: paymentSats}}, feeSats, mine)
	if err != nil {
		t.Fatalf("send through the index: %v", err)
	}
	n.mine()
	t.Logf("light mode sent %s", txid)
}

// A withdrawal asks coins to leave the sidechain. The node accepts it as an
// ordinary transaction, and the enforcer pays it out later.
func TestWalletWithdraws(t *testing.T) {
	n := dialNode(t)
	ring, mine := testKeyring(t)
	source := tw.NewNodeCoins(n.client)

	n.fund(mine, fundingSats)
	awaitCoins(t, source, []tw.Address{mine})

	// A mainchain payout target. The signature covers its script, and the RPC
	// takes its text form.
	mainAddress := os.Getenv("THUNDER_MAIN_ADDRESS")
	if mainAddress == "" {
		t.Skip("set THUNDER_MAIN_ADDRESS to a mainchain address to run the withdrawal test")
	}
	script, err := mainScriptPubKey(mainAddress)
	if err != nil {
		t.Fatalf("read the mainchain script: %v", err)
	}

	wallet := tw.New(source, ring, source)
	txid, err := wallet.Withdraw(context.Background(), []tw.Address{mine},
		tw.WithdrawalRequest{
			MainScriptPubKey: script,
			MainAddress:      mainAddress,
			ValueSats:        paymentSats,
			MainFeeSats:      10000,
		}, feeSats, mine)
	if err != nil {
		t.Fatalf("withdraw: %v", err)
	}
	n.mine()

	var got struct {
		BlockHash *string `json:"block_hash"`
	}
	n.call("get_transaction", []any{txid.String()}, &got)
	if got.BlockHash == nil {
		t.Fatal("the node accepted the withdrawal but never mined it")
	}
	t.Logf("the withdrawal is in %s", *got.BlockHash)
}

// mainScriptPubKey reads the script of a mainchain address from a local
// Bitcoin Core, which is the only party that knows the network rules.
func mainScriptPubKey(address string) ([]byte, error) {
	url := os.Getenv("BITCOIN_RPC_URL")
	if url == "" {
		return nil, errors.New("set BITCOIN_RPC_URL to read a mainchain script")
	}
	body := fmt.Sprintf(
		`{"jsonrpc":"1.0","id":1,"method":"validateaddress","params":["%s"]}`, address)
	resp, err := http.Post(url, "application/json", strings.NewReader(body))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() //nolint:errcheck

	var parsed struct {
		Result struct {
			ScriptPubKey string `json:"scriptPubKey"`
		} `json:"result"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return nil, err
	}
	if parsed.Result.ScriptPubKey == "" {
		return nil, fmt.Errorf("Bitcoin Core knows no script for %s", address)
	}
	return decodeHex(parsed.Result.ScriptPubKey)
}

func decodeHex(s string) ([]byte, error) {
	out := make([]byte, 0, len(s)/2)
	for i := 0; i+1 < len(s); i += 2 {
		var v int
		for _, r := range s[i : i+2] {
			v <<= 4
			switch {
			case r >= '0' && r <= '9':
				v |= int(r - '0')
			case r >= 'a' && r <= 'f':
				v |= int(r-'a') + 10
			case r >= 'A' && r <= 'F':
				v |= int(r-'A') + 10
			default:
				return nil, fmt.Errorf("%q is not hex", s)
			}
		}
		out = append(out, byte(v))
	}
	return out, nil
}
