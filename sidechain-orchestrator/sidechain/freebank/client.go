// Package freebank is the RPC client for the FreeBank sidechain, a Bitcoin Core
// fork carrying the credit-creation layer (discount houses, redeemable notes,
// bills of exchange). It speaks Core's JSON-RPC with cookie auth, like the other
// Core-derived sidechains. FreeBank produces its blocks with its own refreshbmm
// ticker rather than the orchestrator's BMM engine, so the mining and withdrawal
// methods report that they are not driven from here.
package freebank

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

var _ sidechain.SidechainRPCProxy = (*Client)(nil)

// Client talks to a FreeBank node.
type Client struct {
	baseURL    string
	cookiePath string
	http       *http.Client
}

// NewClient creates a client pointed at host:port. cookiePath is the node's
// .cookie, read on every call because Core rewrites it on each restart.
func NewClient(host string, port int, cookiePath string) *Client {
	return &Client{
		baseURL:    fmt.Sprintf("http://%s:%d", host, port),
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
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *rpcError) Error() string {
	return fmt.Sprintf("freebank RPC error %d: %s", e.Code, e.Message)
}

// walletCall addresses the node's single legacy wallet at the root endpoint,
// which Core routes to the one loaded wallet.
func (c *Client) walletCall(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.callAt(ctx, "/", method, params)
}

func (c *Client) call(ctx context.Context, method string, params any) (json.RawMessage, error) {
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
		return nil, rpcResp.Error
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%s: http %s: %s", method, resp.Status, bytes.TrimSpace(respBody))
	}
	return rpcResp.Result, nil
}

func unmarshal[T any](c *Client, ctx context.Context, method string, params any) (T, error) {
	raw, err := c.call(ctx, method, params)
	return decode[T](method, raw, err)
}

func unmarshalWallet[T any](c *Client, ctx context.Context, method string, params any) (T, error) {
	raw, err := c.walletCall(ctx, method, params)
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

func btcToSats(btc float64) int64 { return int64(math.Round(btc * 1e8)) }

// ---------------------------------------------------------------------------
// Wallet
// ---------------------------------------------------------------------------

// GetBalance returns the wallet balance in satoshis. FreeBank is an older Core
// fork that predates getbalances, so getwalletinfo carries the split: trusted
// spendable, plus unconfirmed and immature that count as pending.
func (c *Client) GetBalance(ctx context.Context) (totalSats, availableSats int64, err error) {
	info, err := unmarshalWallet[WalletInfo](c, ctx, "getwalletinfo", nil)
	if err != nil {
		return 0, 0, err
	}
	available := btcToSats(info.Balance)
	total := available + btcToSats(info.UnconfirmedBalance+info.ImmatureBalance)
	return total, available, nil
}

func (c *Client) GetNewAddress(ctx context.Context) (string, error) {
	// Legacy P2PKH: freebankd's default type is p2sh-segwit, but every
	// FreeBank path that takes an address - deposits, note transfers,
	// withdrawal destinations - is documented and tested against legacy.
	return unmarshalWallet[string](c, ctx, "getnewaddress", []any{"", "legacy"})
}

func (c *Client) GetWalletUtxos(ctx context.Context) (json.RawMessage, error) {
	return c.walletCall(ctx, "listunspent", nil)
}

func (c *Client) ListUtxos(ctx context.Context) (json.RawMessage, error) {
	return c.walletCall(ctx, "listunspent", nil)
}

// ListUnspent returns the wallet's UTXOs.
func (c *Client) ListUnspent(ctx context.Context) ([]Unspent, error) {
	return unmarshalWallet[[]Unspent](c, ctx, "listunspent", nil)
}

// ListTransactions returns the wallet's most recent transactions.
func (c *Client) ListTransactions(ctx context.Context, count int) ([]WalletTransaction, error) {
	return unmarshalWallet[[]WalletTransaction](c, ctx, "listtransactions", []any{"*", count})
}

// SendToAddress sends amountSats on the sidechain and returns the txid.
func (c *Client) SendToAddress(ctx context.Context, address string, amountSats int64, subtractFeeFromAmount bool) (string, error) {
	amountBTC := float64(amountSats) / 1e8
	return unmarshalWallet[string](c, ctx, "sendtoaddress",
		[]any{address, amountBTC, "", "", subtractFeeFromAmount})
}

// Transfer sends amountSats to address. Core sets the fee from its own
// estimator, so feeSats is ignored rather than applied as something it is not.
func (c *Client) Transfer(ctx context.Context, address string, amountSats, _ int64) (string, error) {
	return c.SendToAddress(ctx, address, amountSats, false)
}

// FallbackFeeRate is what a chain with no fee history estimates at, in BTC/kvB.
const FallbackFeeRate = 0.00001

// EstimateSmartFee returns the fee rate in BTC/kvB for a six block target.
// A chain with no fee history returns zero, which builds an unrelayable
// transaction, so an unanswered estimate falls back to a usable default.
func (c *Client) EstimateSmartFee(ctx context.Context) (float64, error) {
	result, err := unmarshal[struct {
		FeeRate float64 `json:"feerate"`
	}](c, ctx, "estimatesmartfee", []any{6})
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

func (c *Client) GetBlockCount(ctx context.Context) (int64, error) {
	return unmarshal[int64](c, ctx, "getblockcount", nil)
}

// GetBlockchainInfo returns the node's chain state.
func (c *Client) GetBlockchainInfo(ctx context.Context) (json.RawMessage, error) {
	return c.call(ctx, "getblockchaininfo", nil)
}

// ---------------------------------------------------------------------------
// Mining — FreeBank blocks are blind merge mined by its own refreshbmm ticker,
// not by the orchestrator's BMM engine, so these report that they are not driven
// from here rather than returning a value that reads as a working chain.
// ---------------------------------------------------------------------------

func (c *Client) Mine(context.Context, int64) (json.RawMessage, error) {
	return nil, errBMMExternal
}

func (c *Client) GetBlockTemplate(context.Context) (*sidechain.BlockTemplate, error) {
	return nil, errBMMExternal
}

func (c *Client) ConnectBlock(context.Context, json.RawMessage, string) (bool, error) {
	return false, errBMMExternal
}

func (c *Client) GetBmmInclusions(context.Context, string) ([]string, error) {
	return nil, errBMMExternal
}

var errBMMExternal = fmt.Errorf("freebank blocks are blind merge mined by its own refreshbmm ticker, not the orchestrator BMM engine")

// ---------------------------------------------------------------------------
// Withdrawals — FreeBank settles withdrawals through its own paths, not wired
// into the orchestrator here. Reporting "none" would be indistinguishable from
// a working chain with nothing pending.
// ---------------------------------------------------------------------------

func (c *Client) Withdraw(context.Context, string, int64, int64, int64) (string, error) {
	return "", errWithdrawalsUnwired
}

func (c *Client) GetPendingWithdrawalBundle(context.Context) (json.RawMessage, error) {
	return nil, errWithdrawalsUnwired
}

func (c *Client) GetLatestFailedWithdrawalBundleHeight(context.Context) (int64, error) {
	return 0, errWithdrawalsUnwired
}

var errWithdrawalsUnwired = fmt.Errorf("freebank withdrawals are not wired into the orchestrator")

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

func (c *Client) Stop(ctx context.Context) error {
	_, err := c.call(ctx, "stop", nil)
	return err
}

func (c *Client) CallRaw(ctx context.Context, method string, params any) (json.RawMessage, error) {
	return c.call(ctx, method, params)
}
