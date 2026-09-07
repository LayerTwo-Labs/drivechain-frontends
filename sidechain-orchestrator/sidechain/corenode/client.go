// Package corenode is the RPC client every Bitcoin Core derived sidechain
// shares. It speaks Core's JSON-RPC with cookie auth, unlike the CUSF
// sidechains. A fork states its differences in Options and writes no client of
// its own.
package corenode

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ sidechain.Node = (*Client)(nil)

// Options are the ways one Core fork differs from another.
type Options struct {
	// WalletPath is the endpoint a wallet RPC goes to. Empty takes
	// /wallet/<CoreWalletName>, the wallet the orchestrator seeds. A fork that
	// keeps a wallet of its own takes "/", where Core answers for the one
	// wallet it loaded.
	WalletPath string

	// LegacyBalance reads getwalletinfo in place of getbalances, for a fork
	// that predates getbalances.
	LegacyBalance bool

	// AddressType is the getnewaddress argument, one of "legacy",
	// "p2sh-segwit" or "bech32". Empty takes the node default.
	AddressType string
}

// Client talks to one Core derived sidechain node.
type Client struct {
	name       string
	baseURL    string
	opts       Options
	cookiePath string
	http       *http.Client
}

// New creates a client pointed at host:port. name prefixes an RPC error, so a
// log names the chain that failed. cookiePath is the node's .cookie, read on
// every call because Core rewrites it on each restart.
func New(name, host string, port int, cookiePath string, opts Options) *Client {
	if opts.WalletPath == "" {
		opts.WalletPath = "/wallet/" + sidechain.CoreWalletName
	}
	return &Client{
		name:       name,
		baseURL:    fmt.Sprintf("http://%s:%d", host, port),
		opts:       opts,
		cookiePath: cookiePath,
		http:       &http.Client{Timeout: 30 * time.Second},
	}
}

type rpcRequest struct {
	JSONRPC string `json:"jsonrpc"`
	ID      string `json:"id"`
	Method  string `json:"method"`
	Params  any    `json:"params"`
}

type rpcResponse struct {
	Result json.RawMessage `json:"result"`
	Error  *rpcError       `json:"error"`
}

type rpcError struct {
	chain   string
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *rpcError) Error() string {
	return fmt.Sprintf("%s RPC error %d: %s", e.chain, e.Code, e.Message)
}

// WalletCall sends one wallet RPC to the endpoint this fork keeps its wallet at.
func (c *Client) WalletCall(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.callAt(ctx, c.opts.WalletPath, method, params)
}

// Call sends one node RPC to the root endpoint.
func (c *Client) Call(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.callAt(ctx, "", method, params)
}

func (c *Client) callAt(ctx context.Context, path, method string, params any) (json.RawMessage, error) {
	if params == nil {
		params = []any{}
	}
	body, err := json.Marshal(rpcRequest{JSONRPC: "1.0", ID: "orchestrator", Method: method, Params: params})
	if err != nil {
		return nil, fmt.Errorf("marshal %s request: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+path, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("create %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")

	// An unauthenticated call comes back as an empty 401, which surfaces as an
	// opaque decode error further up. Fail on the cookie itself instead.
	user, password, err := config.ReadCookieFile(c.cookiePath)
	if err != nil {
		return nil, err
	}
	req.SetBasicAuth(user, password)

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%s call: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read %s response: %w", method, err)
	}

	// Core answers a failed call with a non-200 and a JSON-RPC error body, so
	// the status only decides anything when the body is not one.
	var rpcResp rpcResponse
	if err := json.Unmarshal(respBody, &rpcResp); err != nil {
		return nil, fmt.Errorf("%s: http %s: %s", method, resp.Status, bytes.TrimSpace(respBody))
	}
	if rpcResp.Error != nil {
		rpcResp.Error.chain = c.name
		return nil, rpcResp.Error
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%s: http %s: %s", method, resp.Status, bytes.TrimSpace(respBody))
	}
	return rpcResp.Result, nil
}

// Decode calls a node RPC and unmarshals the result into T.
func Decode[T any](ctx context.Context, c *Client, method string, params any) (T, error) {
	raw, err := c.Call(ctx, method, params)
	return decode[T](method, raw, err)
}

// DecodeWallet calls a wallet RPC and unmarshals the result into T.
func DecodeWallet[T any](ctx context.Context, c *Client, method string, params any) (T, error) {
	raw, err := c.WalletCall(ctx, method, params)
	return decode[T](method, raw, err)
}

func decode[T any](method string, raw json.RawMessage, err error) (T, error) {
	var zero T
	if err != nil {
		return zero, err
	}
	var v T
	if err := json.Unmarshal(raw, &v); err != nil {
		return zero, fmt.Errorf("decode %s result: %w", method, err)
	}
	return v, nil
}

// BTCToSats converts a Core amount in BTC to satoshis.
func BTCToSats(btc float64) int64 { return int64(math.Round(btc * 1e8)) }

// ---------------------------------------------------------------------------
// Wallet
// ---------------------------------------------------------------------------

// GetBalance returns the wallet balance in satoshis. Peg-ins arrive in the
// coinbase, so immature counts as pending rather than as missing.
func (c *Client) GetBalance(ctx context.Context) (totalSats, availableSats int64, err error) {
	if c.opts.LegacyBalance {
		info, err := DecodeWallet[WalletInfo](ctx, c, "getwalletinfo", nil)
		if err != nil {
			return 0, 0, err
		}
		available := BTCToSats(info.Balance)
		return available + BTCToSats(info.UnconfirmedBalance+info.ImmatureBalance), available, nil
	}
	balances, err := DecodeWallet[Balances](ctx, c, "getbalances", nil)
	if err != nil {
		return 0, 0, err
	}
	available := BTCToSats(balances.Mine.Trusted)
	return available + BTCToSats(balances.Mine.UntrustedPending+balances.Mine.Immature), available, nil
}

// GetNewAddress returns a fresh address of the type this fork takes.
func (c *Client) GetNewAddress(ctx context.Context) (string, error) {
	if c.opts.AddressType == "" {
		return DecodeWallet[string](ctx, c, "getnewaddress", nil)
	}
	return DecodeWallet[string](ctx, c, "getnewaddress", []any{"", c.opts.AddressType})
}

// ListUnspent returns the wallet's UTXOs.
func (c *Client) ListUnspent(ctx context.Context) ([]Unspent, error) {
	return DecodeWallet[[]Unspent](ctx, c, "listunspent", nil)
}

// ListTransactions returns the wallet's most recent transactions.
func (c *Client) ListTransactions(ctx context.Context, count int) ([]WalletTransaction, error) {
	return DecodeWallet[[]WalletTransaction](ctx, c, "listtransactions", []any{"*", count})
}

// SendToAddress sends amountSats on the sidechain and returns the txid.
func (c *Client) SendToAddress(ctx context.Context, address string, amountSats int64, subtractFeeFromAmount bool) (string, error) {
	amountBTC := float64(amountSats) / 1e8
	return DecodeWallet[string](ctx, c, "sendtoaddress",
		[]any{address, amountBTC, "", "", subtractFeeFromAmount})
}

// FallbackFeeRate is what a chain with no fee history estimates at, in BTC/kvB.
const FallbackFeeRate = 0.00001

// EstimateSmartFee returns the fee rate in BTC/kvB for a six block target.
// Regtest has no fee history, and a zero rate builds an unrelayable
// transaction, so an unanswered estimate falls back to a usable default.
func (c *Client) EstimateSmartFee(ctx context.Context) (float64, error) {
	result, err := Decode[struct {
		FeeRate float64 `json:"feerate"`
	}](ctx, c, "estimatesmartfee", []any{6})
	if err != nil {
		return 0, err
	}
	if result.FeeRate <= 0 {
		return FallbackFeeRate, nil
	}
	return result.FeeRate, nil
}

// ---------------------------------------------------------------------------
// Chain
// ---------------------------------------------------------------------------

// GetBlockCount returns the height of the chain tip.
func (c *Client) GetBlockCount(ctx context.Context) (int64, error) {
	return Decode[int64](ctx, c, "getblockcount", nil)
}

// GetBlockchainInfo returns the node's chain state.
func (c *Client) GetBlockchainInfo(ctx context.Context) (json.RawMessage, error) {
	return c.Call(ctx, "getblockchaininfo", nil)
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

// Stop asks the node to shut down.
func (c *Client) Stop(ctx context.Context) error {
	_, err := c.Call(ctx, "stop", nil)
	return err
}

// CallRaw sends one node RPC and returns the undecoded result.
func (c *Client) CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.Call(ctx, method, params)
}

// Args is empty for a Core fork. --headless is a Rust backend flag, and a Core
// daemon exits on it. A fork that boots with more overrides this.
func (c *Client) Args(context.Context, sidechain.Host) ([]string, error) {
	return nil, nil
}

// ---------------------------------------------------------------------------
// Replies
// ---------------------------------------------------------------------------

// Balances is Core's getbalances reply, amounts in BTC.
type Balances struct {
	Mine struct {
		Trusted          float64 `json:"trusted"`
		UntrustedPending float64 `json:"untrusted_pending"`
		Immature         float64 `json:"immature"`
	} `json:"mine"`
}

// WalletInfo is Core's getwalletinfo reply, amounts in BTC. A fork that
// predates getbalances carries the same split here.
type WalletInfo struct {
	Balance            float64 `json:"balance"`
	UnconfirmedBalance float64 `json:"unconfirmed_balance"`
	ImmatureBalance    float64 `json:"immature_balance"`
}

// Unspent is one wallet UTXO from listunspent, amount in BTC.
type Unspent struct {
	Txid          string  `json:"txid"`
	Vout          int64   `json:"vout"`
	Address       string  `json:"address"`
	Amount        float64 `json:"amount"`
	Confirmations int64   `json:"confirmations"`
}

// WalletTransaction is one entry from listtransactions, amount in BTC.
type WalletTransaction struct {
	Txid          string  `json:"txid"`
	Amount        float64 `json:"amount"`
	Confirmations int64   `json:"confirmations"`
	Time          int64   `json:"time"`
	Address       string  `json:"address"`
	Category      string  `json:"category"`
}
