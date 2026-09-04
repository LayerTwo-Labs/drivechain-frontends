// Package sidechainesplora reads a sidechain address index over the Esplora
// REST API. A wallet that uses it runs no sidechain node of its own.
package sidechainesplora

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// requestTimeout bounds one call to the index.
const requestTimeout = 20 * time.Second

// Client talks to one chain's Esplora index.
type Client struct {
	baseURL string
	http    *http.Client
}

// New points a client at an index. The URL takes the form http://host:port.
func New(baseURL string) *Client {
	return &Client{
		baseURL: strings.TrimRight(baseURL, "/"),
		http:    &http.Client{Timeout: requestTimeout},
	}
}

// BaseURL is the index address.
func (c *Client) BaseURL() string { return c.baseURL }

// TxoStats counts what one address funded and spent.
type TxoStats struct {
	FundedTxoCount int   `json:"funded_txo_count"`
	FundedTxoSum   int64 `json:"funded_txo_sum"`
	SpentTxoCount  int   `json:"spent_txo_count"`
	SpentTxoSum    int64 `json:"spent_txo_sum"`
	TxCount        int   `json:"tx_count"`
}

// AddressStats is what /address/{a} returns.
type AddressStats struct {
	Address      string   `json:"address"`
	ChainStats   TxoStats `json:"chain_stats"`
	MempoolStats TxoStats `json:"mempool_stats"`
}

// Balance is what the address holds, in sats.
func (s AddressStats) Balance() int64 {
	return s.ChainStats.FundedTxoSum - s.ChainStats.SpentTxoSum
}

// Status is where a transaction sits in the chain.
type Status struct {
	Confirmed   bool   `json:"confirmed"`
	BlockHeight uint32 `json:"block_height"`
	BlockHash   string `json:"block_hash"`
	BlockTime   int64  `json:"block_time"`
}

// UTXO is one unspent output.
type UTXO struct {
	Txid   string `json:"txid"`
	Vout   uint32 `json:"vout"`
	Value  int64  `json:"value"`
	Status Status `json:"status"`
	// OutpointKind reads "regular", "coinbase", or "deposit". A deposit txid
	// is a mainchain txid, so it names no sidechain transaction.
	OutpointKind string `json:"outpoint_kind"`
	// ContentType reads "value" for a plain coin, and "withdrawal" for one
	// that is leaving the chain. Only a plain coin is spendable.
	ContentType string `json:"content_type"`
}

// ContentValue names a plain spendable coin.
const ContentValue = "value"

// Spendable is true for a plain coin. A withdrawal output belongs to the
// chain's payout, and a wallet that spends it builds a transaction no node
// accepts.
//
// An older index sends no content type. Such a row reads as spendable, which
// is what every row was before the field arrived.
func (u UTXO) Spendable() bool {
	return u.ContentType == "" || u.ContentType == ContentValue
}

// Vout is one output of a transaction.
type Vout struct {
	ScriptPubKeyAddress string `json:"scriptpubkey_address"`
	Value               int64  `json:"value"`
	OutpointKind        string `json:"outpoint_kind"`
	// ContentType reads "value" or "withdrawal", and Content carries the
	// chain-specific payload a withdrawal names.
	ContentType string          `json:"content_type"`
	Content     json.RawMessage `json:"content"`
}

// Vin is one input of a transaction.
type Vin struct {
	Txid       string `json:"txid"`
	Vout       uint32 `json:"vout"`
	Prevout    *Vout  `json:"prevout"`
	IsCoinbase bool   `json:"is_coinbase"`
}

// Tx is one transaction.
type Tx struct {
	Txid   string `json:"txid"`
	Size   int    `json:"size"`
	Fee    int64  `json:"fee"`
	Vin    []Vin  `json:"vin"`
	Vout   []Vout `json:"vout"`
	Status Status `json:"status"`
}

// NetValueFor returns what one address gained or lost in this transaction.
// FirstOutputFor names the index of the first output that pays an address, and
// says whether the transaction pays it at all.
func (t Tx) FirstOutputFor(address string) (uint32, bool) {
	for i, out := range t.Vout {
		if out.ScriptPubKeyAddress == address {
			return uint32(i), true
		}
	}
	return 0, false
}

func (t Tx) NetValueFor(address string) int64 {
	var net int64
	for _, out := range t.Vout {
		if out.ScriptPubKeyAddress == address {
			net += out.Value
		}
	}
	for _, in := range t.Vin {
		if in.Prevout != nil && in.Prevout.ScriptPubKeyAddress == address {
			net -= in.Prevout.Value
		}
	}
	return net
}

// AddressStats reads the funded and spent totals for one address.
func (c *Client) AddressStats(ctx context.Context, address string) (AddressStats, error) {
	var out AddressStats
	err := c.get(ctx, "/address/"+address, &out)
	return out, err
}

// AddressUTXOs lists the unspent outputs of one address.
func (c *Client) AddressUTXOs(ctx context.Context, address string) ([]UTXO, error) {
	var out []UTXO
	err := c.get(ctx, "/address/"+address+"/utxo", &out)
	return out, err
}

// AddressTxs lists the transactions that touched one address, newest first.
// Pass an empty lastSeen for the first page, then the last txid of that page.
func (c *Client) AddressTxs(ctx context.Context, address, lastSeen string) ([]Tx, error) {
	path := "/address/" + address + "/txs"
	if lastSeen != "" {
		path += "/chain/" + lastSeen
	}
	var out []Tx
	err := c.get(ctx, path, &out)
	return out, err
}

// AddressDeposits lists the mainchain deposits that paid one address.
func (c *Client) AddressDeposits(ctx context.Context, address string) ([]UTXO, error) {
	var out []UTXO
	err := c.get(ctx, "/address/"+address+"/deposits", &out)
	return out, err
}

// ErrEmptyIndex says the index holds no blocks. A chain reads this way until
// its first block arrives.
var ErrEmptyIndex = errors.New("the index holds no blocks")

// statusError carries the status an index answered with, so a caller can tell
// an empty index from a broken one.
type statusError struct {
	path   string
	status int
	body   string
}

func (e statusError) Error() string {
	return fmt.Sprintf("%s answered %d: %s", e.path, e.status, e.body)
}

// TipHeight is the height of the highest indexed block. An index with no
// blocks answers ErrEmptyIndex.
func (c *Client) TipHeight(ctx context.Context) (uint32, error) {
	body, err := c.getText(ctx, "/blocks/tip/height")
	if err != nil {
		var status statusError
		if errors.As(err, &status) && status.status == http.StatusNotFound {
			return 0, ErrEmptyIndex
		}
		return 0, err
	}
	height, err := strconv.ParseUint(strings.TrimSpace(body), 10, 32)
	if err != nil {
		return 0, fmt.Errorf("tip height %q is not a number", body)
	}
	return uint32(height), nil
}

func (c *Client) get(ctx context.Context, path string, out any) error {
	body, err := c.getText(ctx, path)
	if err != nil {
		return err
	}
	if err := json.Unmarshal([]byte(body), out); err != nil {
		return fmt.Errorf("decode %s: %w", path, err)
	}
	return nil
}

func (c *Client) getText(ctx context.Context, path string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+path, nil)
	if err != nil {
		return "", fmt.Errorf("build request for %s: %w", path, err)
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return "", fmt.Errorf("call %s%s: %w", c.baseURL, path, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("read %s: %w", path, err)
	}
	if resp.StatusCode != http.StatusOK {
		return "", statusError{path: path, status: resp.StatusCode, body: strings.TrimSpace(string(body))}
	}
	return string(body), nil
}
