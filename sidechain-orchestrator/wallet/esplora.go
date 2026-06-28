package wallet

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// Esplora is the chain-data surface an electrum wallet needs. ElectrumBackend
// depends on this interface so tests can supply an in-memory backend instead of
// a live REST endpoint; *EsploraClient is the production implementation.
type Esplora interface {
	AddressStats(ctx context.Context, address string) (EsploraAddressStats, error)
	AddressUTXOs(ctx context.Context, address string) ([]EsploraUTXO, error)
	AddressTxs(ctx context.Context, address string) ([]EsploraTx, error)
	Tx(ctx context.Context, txid string) (EsploraTx, error)
	TxHex(ctx context.Context, txid string) (string, error)
	Broadcast(ctx context.Context, rawHex string) (string, error)
	TipHeight(ctx context.Context) (int, error)
	FeeRateForTarget(ctx context.Context, target int, fallback float64) float64
}

// EsploraClient talks to a Blockstream-style Esplora REST API. It serves the
// Bitcoin chain data an electrum wallet needs — address history, UTXOs, raw
// transactions, fee estimates, broadcast — without a local Core or enforcer.
type EsploraClient struct {
	// baseURLs is an ordered provider list, primary first. A request rotates to
	// the next provider on each retry, so a rate-limited or unreachable primary
	// (e.g. mempool.space 429s) fails over to the fallback (e.g. blockstream.info)
	// on the very next attempt instead of stalling on one host. Guarded by urlMu
	// so SetBaseURLs can swap the endpoint at runtime without racing in-flight do().
	urlMu    sync.RWMutex
	baseURLs []string
	client   *http.Client
	log      zerolog.Logger

	// Pacing keeps a gap-limit scan under public rate limits (mempool.space
	// 429s a fast sequential burst). nextReq is the earliest the next request
	// may start; guarded by mu so concurrent callers serialise their slots.
	mu          sync.Mutex
	nextReq     time.Time
	minInterval time.Duration

	// TipHeight is read on every wallet poll (balance, utxos, txs, stats), so
	// cache it briefly — otherwise each read makes its own /blocks/tip/height
	// call and the combined rate alone trips public Esplora 429 limits.
	tipMu      sync.Mutex
	tipVal     int
	tipFetched time.Time
}

var _ Esplora = (*EsploraClient)(nil)

const (
	esploraMaxAttempts = 6
	esploraBackoffBase = 500 * time.Millisecond
	esploraBackoffMax  = 8 * time.Second
	esploraMinInterval = 120 * time.Millisecond
	esploraTipTTL      = 30 * time.Second
	// esploraUserAgent presents a browser identity so providers that reject
	// non-browser clients (mempool.space) still serve us.
	esploraUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)

// NewEsploraClient creates an Esplora REST client over an ordered list of API
// roots (e.g. https://mempool.space/api, https://blockstream.info/api), primary
// first; trailing slashes optional. Requests rotate to the next root on retry,
// so a single rate-limited host fails over instead of stalling the wallet.
func NewEsploraClient(baseURLs []string, log zerolog.Logger) *EsploraClient {
	roots := lo.Map(baseURLs, func(u string, _ int) string { return strings.TrimRight(u, "/") })
	return &EsploraClient{
		baseURLs:    roots,
		client:      &http.Client{Timeout: 30 * time.Second},
		log:         log.With().Str("component", "esplora").Logger(),
		minInterval: esploraMinInterval,
	}
}

// BaseURLs returns the current provider list, primary first.
func (c *EsploraClient) BaseURLs() []string {
	c.urlMu.RLock()
	defer c.urlMu.RUnlock()
	return append([]string(nil), c.baseURLs...)
}

// SetBaseURLs atomically swaps the provider list. In-flight requests that
// already captured the old list complete against it; subsequent requests use
// the new list. The tip cache is dropped so the next read reflects the new
// server's chain immediately.
func (c *EsploraClient) SetBaseURLs(baseURLs []string) {
	roots := lo.Map(baseURLs, func(u string, _ int) string { return strings.TrimRight(u, "/") })
	c.urlMu.Lock()
	c.baseURLs = roots
	c.urlMu.Unlock()

	c.tipMu.Lock()
	c.tipFetched = time.Time{}
	c.tipMu.Unlock()
}

// EsploraStatus is the confirmation context shared by txs and UTXOs.
type EsploraStatus struct {
	Confirmed   bool   `json:"confirmed"`
	BlockHeight int    `json:"block_height"`
	BlockHash   string `json:"block_hash"`
	BlockTime   int64  `json:"block_time"`
}

// EsploraTxoStats aggregates funded/spent outputs for an address, split by
// EsploraAddressStats into confirmed (chain) and mempool buckets.
type EsploraTxoStats struct {
	FundedTxoCount int   `json:"funded_txo_count"`
	FundedTxoSum   int64 `json:"funded_txo_sum"`
	SpentTxoCount  int   `json:"spent_txo_count"`
	SpentTxoSum    int64 `json:"spent_txo_sum"`
	TxCount        int   `json:"tx_count"`
}

// EsploraAddressStats is GET /address/:addr — funded/spent totals used for
// balance and gap-limit "has this address ever been used" checks.
type EsploraAddressStats struct {
	Address      string          `json:"address"`
	ChainStats   EsploraTxoStats `json:"chain_stats"`
	MempoolStats EsploraTxoStats `json:"mempool_stats"`
}

// Used reports whether the address has any on-chain or mempool history.
func (s EsploraAddressStats) Used() bool {
	return s.ChainStats.TxCount > 0 || s.MempoolStats.TxCount > 0
}

// EsploraUTXO is one entry of GET /address/:addr/utxo.
type EsploraUTXO struct {
	TxID   string        `json:"txid"`
	Vout   int           `json:"vout"`
	Value  int64         `json:"value"`
	Status EsploraStatus `json:"status"`
}

// EsploraVout is one transaction output.
type EsploraVout struct {
	ScriptPubKey        string `json:"scriptpubkey"`
	ScriptPubKeyAsm     string `json:"scriptpubkey_asm"`
	ScriptPubKeyType    string `json:"scriptpubkey_type"`
	ScriptPubKeyAddress string `json:"scriptpubkey_address"`
	Value               int64  `json:"value"`
}

// EsploraVin is one transaction input, with the prevout it spends inlined.
type EsploraVin struct {
	TxID       string       `json:"txid"`
	Vout       int          `json:"vout"`
	Prevout    *EsploraVout `json:"prevout"`
	ScriptSig  string       `json:"scriptsig"`
	Witness    []string     `json:"witness"`
	IsCoinbase bool         `json:"is_coinbase"`
	Sequence   int64        `json:"sequence"`
}

// EsploraTx is GET /tx/:txid (also the shape returned in address tx lists).
type EsploraTx struct {
	TxID     string        `json:"txid"`
	Version  int32         `json:"version"`
	Locktime int32         `json:"locktime"`
	Size     int32         `json:"size"`
	Weight   int32         `json:"weight"`
	Fee      int64         `json:"fee"`
	Vin      []EsploraVin  `json:"vin"`
	Vout     []EsploraVout `json:"vout"`
	Status   EsploraStatus `json:"status"`
}

func (c *EsploraClient) get(ctx context.Context, path string, out interface{}) error {
	body, err := c.do(ctx, http.MethodGet, path, nil)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(body, out); err != nil {
		return fmt.Errorf("decode %s: %w", path, err)
	}
	return nil
}

func (c *EsploraClient) do(ctx context.Context, method, path string, reqBody io.Reader) ([]byte, error) {
	// Buffer the body so each retry can resend it (broadcast POSTs a body).
	var bodyBytes []byte
	if reqBody != nil {
		b, err := io.ReadAll(reqBody)
		if err != nil {
			return nil, fmt.Errorf("read request body %s: %w", path, err)
		}
		bodyBytes = b
	}

	roots := c.BaseURLs()
	if len(roots) == 0 {
		return nil, fmt.Errorf("esplora %s %s: no server configured", method, path)
	}

	var lastErr error
	for attempt := 0; attempt < esploraMaxAttempts; attempt++ {
		if err := c.pace(ctx); err != nil {
			return nil, err
		}

		var rdr io.Reader
		if bodyBytes != nil {
			rdr = bytes.NewReader(bodyBytes)
		}
		// Rotate providers across retries: attempt 0 hits the primary, and each
		// retry advances to the next root so a 429/outage on one host fails over
		// to the next instead of backing off against the same dead provider.
		base := roots[attempt%len(roots)]
		req, err := http.NewRequestWithContext(ctx, method, base+path, rdr)
		if err != nil {
			return nil, fmt.Errorf("build request %s: %w", path, err)
		}
		// mempool.space drops requests from non-browser clients, so present a
		// browser User-Agent; other public Esplora hosts accept it too.
		req.Header.Set("User-Agent", esploraUserAgent)
		c.log.Info().Str("method", method).Str("path", path).Str("base", base).Int("attempt", attempt).Msg("esplora request")

		resp, err := c.client.Do(req)
		if err != nil {
			lastErr = fmt.Errorf("esplora %s %s: %w", method, path, err)
			if !backoff(ctx, attempt, 0) {
				return nil, lastErr
			}
			continue
		}
		body, readErr := io.ReadAll(resp.Body)
		_ = resp.Body.Close()
		if readErr != nil {
			return nil, fmt.Errorf("read %s: %w", path, readErr)
		}

		if resp.StatusCode == http.StatusOK {
			return body, nil
		}

		lastErr = fmt.Errorf("esplora %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(body)))
		if !retryableStatus(resp.StatusCode) {
			return nil, lastErr
		}
		if !backoff(ctx, attempt, parseRetryAfter(resp.Header.Get("Retry-After"))) {
			return nil, lastErr
		}
	}
	return nil, fmt.Errorf("esplora %s %s: exhausted retries: %w", method, path, lastErr)
}

// pace reserves the next request slot so sequential calls stay minInterval
// apart, keeping a gap-limit scan under public Esplora rate limits.
func (c *EsploraClient) pace(ctx context.Context) error {
	if c.minInterval <= 0 {
		return nil
	}
	c.mu.Lock()
	now := time.Now()
	wait := time.Duration(0)
	if c.nextReq.After(now) {
		wait = c.nextReq.Sub(now)
	}
	c.nextReq = now.Add(wait).Add(c.minInterval)
	c.mu.Unlock()

	if wait <= 0 {
		return nil
	}
	select {
	case <-time.After(wait):
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

func retryableStatus(code int) bool {
	switch code {
	case http.StatusTooManyRequests, http.StatusBadGateway, http.StatusServiceUnavailable, http.StatusGatewayTimeout:
		return true
	default:
		return false
	}
}

func parseRetryAfter(h string) time.Duration {
	if secs, err := strconv.Atoi(strings.TrimSpace(h)); err == nil && secs >= 0 {
		return time.Duration(secs) * time.Second
	}
	return 0
}

// backoff waits before the next attempt (honouring Retry-After when set, else
// exponential), returning false if ctx is cancelled first.
func backoff(ctx context.Context, attempt int, retryAfter time.Duration) bool {
	wait := retryAfter
	if wait <= 0 {
		wait = esploraBackoffBase << attempt
		if wait > esploraBackoffMax {
			wait = esploraBackoffMax
		}
	}
	select {
	case <-time.After(wait):
		return true
	case <-ctx.Done():
		return false
	}
}

// AddressStats returns funded/spent totals for an address.
func (c *EsploraClient) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	var s EsploraAddressStats
	err := c.get(ctx, "/address/"+address, &s)
	return s, err
}

// AddressUTXOs returns the unspent outputs of an address.
func (c *EsploraClient) AddressUTXOs(ctx context.Context, address string) ([]EsploraUTXO, error) {
	var u []EsploraUTXO
	err := c.get(ctx, "/address/"+address+"/utxo", &u)
	return u, err
}

// AddressTxs returns the confirmed + mempool transaction history of an
// address. Esplora pages confirmed history 25 at a time keyed by the last
// seen txid; this walks every page so history is complete.
func (c *EsploraClient) AddressTxs(ctx context.Context, address string) ([]EsploraTx, error) {
	var all []EsploraTx
	var lastSeen string
	for {
		path := "/address/" + address + "/txs"
		if lastSeen != "" {
			path = "/address/" + address + "/txs/chain/" + lastSeen
		}
		var page []EsploraTx
		if err := c.get(ctx, path, &page); err != nil {
			return nil, err
		}
		all = append(all, page...)
		// Only confirmed history paginates. Advance the cursor by the oldest
		// confirmed tx in this page — the chain endpoint rejects a mempool
		// txid, so we can't blindly use the last element. A short confirmed
		// batch means we've reached the end.
		confirmed := 0
		cursor := ""
		for _, tx := range page {
			if tx.Status.Confirmed {
				confirmed++
				cursor = tx.TxID
			}
		}
		if confirmed < 25 || cursor == "" {
			break
		}
		lastSeen = cursor
	}
	return all, nil
}

// Tx returns a single decoded transaction.
func (c *EsploraClient) Tx(ctx context.Context, txid string) (EsploraTx, error) {
	var tx EsploraTx
	err := c.get(ctx, "/tx/"+txid, &tx)
	return tx, err
}

// TxHex returns the raw transaction hex.
func (c *EsploraClient) TxHex(ctx context.Context, txid string) (string, error) {
	body, err := c.do(ctx, http.MethodGet, "/tx/"+txid+"/hex", nil)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(body)), nil
}

// Broadcast submits a raw transaction and returns its txid.
func (c *EsploraClient) Broadcast(ctx context.Context, rawHex string) (string, error) {
	body, err := c.do(ctx, http.MethodPost, "/tx", bytes.NewBufferString(rawHex))
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(body)), nil
}

// TipHeight returns the height of the chain tip.
func (c *EsploraClient) TipHeight(ctx context.Context) (int, error) {
	c.tipMu.Lock()
	if !c.tipFetched.IsZero() && time.Since(c.tipFetched) < esploraTipTTL {
		v := c.tipVal
		c.tipMu.Unlock()
		return v, nil
	}
	c.tipMu.Unlock()

	body, err := c.do(ctx, http.MethodGet, "/blocks/tip/height", nil)
	if err != nil {
		return 0, err
	}
	h, err := strconv.Atoi(strings.TrimSpace(string(body)))
	if err != nil {
		return 0, fmt.Errorf("parse tip height %q: %w", body, err)
	}
	c.tipMu.Lock()
	c.tipVal = h
	c.tipFetched = time.Now()
	c.tipMu.Unlock()
	return h, nil
}

// FeeEstimates returns a confirmation-target → sat/vB fee-rate map.
func (c *EsploraClient) FeeEstimates(ctx context.Context) (map[string]float64, error) {
	est := map[string]float64{}
	err := c.get(ctx, "/fee-estimates", &est)
	return est, err
}

// FeeRateForTarget returns the sat/vB fee rate for the given confirmation
// target, falling back to the nearest available estimate, then to fallback.
func (c *EsploraClient) FeeRateForTarget(ctx context.Context, target int, fallback float64) float64 {
	est, err := c.FeeEstimates(ctx)
	if err != nil || len(est) == 0 {
		return fallback
	}
	if rate, ok := est[strconv.Itoa(target)]; ok && rate > 0 {
		return rate
	}
	best, bestDelta := 0.0, 1<<30
	for k, rate := range est {
		blocks, err := strconv.Atoi(k)
		if err != nil {
			continue
		}
		if delta := abs(blocks - target); delta < bestDelta {
			best, bestDelta = rate, delta
		}
	}
	if best > 0 {
		return best
	}
	return fallback
}

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}
