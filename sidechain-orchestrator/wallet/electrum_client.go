package wallet

import (
	"bufio"
	"bytes"
	"context"
	"crypto/sha256"
	"crypto/tls"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	neturl "net/url"
	"strings"
	"sync"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"golang.org/x/net/proxy"
)

const electrumClientTipTTL = 20 * time.Second

// ElectrumClient implements ChainDataSource over the Electrum wire protocol
// (newline-delimited JSON-RPC over TCP or TLS), for servers that expose Electrum
// but not a full Esplora REST API (e.g. mempool-electrs). It maps Electrum's
// scripthash/transaction methods into the same Esplora* shapes EsploraClient
// produces, so the wallet backend is identical regardless of which serves it.
//
// Electrum has no verbose-transaction call, so transactions are fetched as raw
// hex, decoded with btcd/wire, and each input's prevout is resolved by fetching
// its funding transaction (cached). Requests are serialised over one connection.
type ElectrumClient struct {
	network *chaincfg.Params
	log     zerolog.Logger

	// mu serialises a full request→response round-trip on the connection and
	// guards conn/reader/nextID. Never held across a call() so the tx-building
	// helpers can issue their own calls.
	mu     sync.Mutex
	conn   net.Conn
	reader *bufio.Reader
	nextID int

	urlMu     sync.RWMutex
	serverURL string // tcp://host:port or ssl://host:port
	proxyOn   bool
	proxyAddr string

	cacheMu    sync.Mutex
	txCache    map[string]*wire.MsgTx // decoded txs, reused for prevout resolution
	heightByTx map[string]int         // txid -> confirmed height (from history/utxos)
	headerTime map[int]int64          // height -> block timestamp

	tipMu      sync.Mutex
	tipVal     int
	tipFetched time.Time
}

var (
	_ ChainDataSource      = (*ElectrumClient)(nil)
	_ SwappableChainSource = (*ElectrumClient)(nil)
)

// NewChainDataSource builds the wallet's chain source from an endpoint list: an
// ssl:// or tcp:// primary selects the Electrum-protocol client; anything else
// (https://…/api) selects the Esplora HTTP client, which also handles the
// multi-provider failover an endpoint list implies.
func NewChainDataSource(urls []string, log zerolog.Logger, network *chaincfg.Params) ChainDataSource {
	if len(urls) > 0 && (strings.HasPrefix(urls[0], "ssl://") || strings.HasPrefix(urls[0], "tcp://")) {
		return NewElectrumClient(urls[0], log, network)
	}
	return NewEsploraClient(urls, log)
}

// NewElectrumClient creates an Electrum-protocol chain source. serverURL is
// tcp://host:port (plaintext) or ssl://host:port (TLS).
func NewElectrumClient(serverURL string, log zerolog.Logger, network *chaincfg.Params) *ElectrumClient {
	return &ElectrumClient{
		network:    network,
		log:        log.With().Str("component", "electrum-client").Logger(),
		serverURL:  serverURL,
		txCache:    map[string]*wire.MsgTx{},
		heightByTx: map[string]int{},
		headerTime: map[int]int64{},
	}
}

// connError marks a transport-level failure so call() knows to reconnect once.
type connError struct{ err error }

func (e connError) Error() string { return e.err.Error() }
func ioErr(e error) error         { return connError{e} }
func isConnErr(e error) bool {
	var ce connError
	return errors.As(e, &ce)
}

func parseElectrumURL(raw string) (scheme, hostport string, err error) {
	u, err := neturl.Parse(raw)
	if err != nil {
		return "", "", err
	}
	if (u.Scheme != "ssl" && u.Scheme != "tcp") || u.Host == "" {
		return "", "", fmt.Errorf("electrum url must be ssl://host:port or tcp://host:port, got %q", raw)
	}
	return u.Scheme, u.Host, nil
}

func (c *ElectrumClient) dial() (net.Conn, error) {
	c.urlMu.RLock()
	raw, proxyOn, proxyAddr := c.serverURL, c.proxyOn, c.proxyAddr
	c.urlMu.RUnlock()

	scheme, host, err := parseElectrumURL(raw)
	if err != nil {
		return nil, err
	}

	var dialer proxy.Dialer = &net.Dialer{Timeout: 15 * time.Second}
	if proxyOn && proxyAddr != "" {
		d, err := proxy.SOCKS5("tcp", proxyAddr, nil, &net.Dialer{Timeout: 20 * time.Second})
		if err != nil {
			return nil, fmt.Errorf("electrum socks5 dialer: %w", err)
		}
		dialer = d
	}

	conn, err := dialer.Dial("tcp", host)
	if err != nil {
		return nil, fmt.Errorf("electrum dial %s: %w", host, err)
	}
	if scheme == "ssl" {
		hostname, _, _ := net.SplitHostPort(host)
		tconn := tls.Client(conn, &tls.Config{ServerName: hostname})
		if err := tconn.Handshake(); err != nil {
			_ = conn.Close()
			return nil, fmt.Errorf("electrum tls handshake %s: %w", host, err)
		}
		conn = tconn
	}
	return conn, nil
}

// call issues one JSON-RPC request and decodes its result into out (nil to
// ignore). It reconnects once on a transport error.
func (c *ElectrumClient) call(ctx context.Context, out interface{}, method string, params ...interface{}) error {
	c.mu.Lock()
	defer c.mu.Unlock()

	var lastErr error
	for attempt := 0; attempt < 2; attempt++ {
		if c.conn == nil {
			conn, err := c.dial()
			if err != nil {
				return err
			}
			c.conn = conn
			c.reader = bufio.NewReaderSize(conn, 1<<20)
			c.nextID = 0
			_ = c.rpc(ctx, nil, "server.version", "bitwindow", "1.4") // best-effort handshake
		}
		err := c.rpc(ctx, out, method, params...)
		if err == nil {
			return nil
		}
		lastErr = err
		if isConnErr(err) {
			c.dropConnLocked()
			continue
		}
		return err
	}
	return lastErr
}

// rpc writes one request and reads until the matching response, skipping
// subscription pushes. Assumes c.mu is held and c.conn is live.
func (c *ElectrumClient) rpc(ctx context.Context, out interface{}, method string, params ...interface{}) error {
	if params == nil {
		params = []interface{}{}
	}
	c.nextID++
	id := c.nextID
	req, err := json.Marshal(map[string]interface{}{"id": id, "method": method, "params": params})
	if err != nil {
		return err
	}

	deadline := time.Now().Add(30 * time.Second)
	if dl, ok := ctx.Deadline(); ok {
		deadline = dl
	}
	_ = c.conn.SetDeadline(deadline)

	if _, err := c.conn.Write(append(req, '\n')); err != nil {
		return ioErr(err)
	}
	for {
		line, err := c.reader.ReadBytes('\n')
		if err != nil {
			return ioErr(err)
		}
		var resp struct {
			ID     *int            `json:"id"`
			Result json.RawMessage `json:"result"`
			Error  *struct {
				Message string `json:"message"`
			} `json:"error"`
		}
		if err := json.Unmarshal(line, &resp); err != nil {
			continue // malformed line — skip
		}
		if resp.ID == nil || *resp.ID != id {
			continue // subscription push or stale id — skip
		}
		if resp.Error != nil {
			return fmt.Errorf("electrum %s: %s", method, resp.Error.Message)
		}
		if out == nil {
			return nil
		}
		return json.Unmarshal(resp.Result, out)
	}
}

func (c *ElectrumClient) dropConnLocked() {
	if c.conn != nil {
		_ = c.conn.Close()
		c.conn = nil
		c.reader = nil
	}
}

// scriptHash returns the Electrum scripthash for an address: sha256 of its
// scriptPubKey, byte-reversed, hex-encoded.
func (c *ElectrumClient) scriptHash(address string) (string, error) {
	addr, err := btcutil.DecodeAddress(address, c.network)
	if err != nil {
		return "", fmt.Errorf("decode address %q: %w", address, err)
	}
	spk, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return "", err
	}
	h := sha256.Sum256(spk)
	for i, j := 0, len(h)-1; i < j; i, j = i+1, j-1 {
		h[i], h[j] = h[j], h[i]
	}
	return hex.EncodeToString(h[:]), nil
}

type electrumHistoryItem struct {
	TxHash string `json:"tx_hash"`
	Height int    `json:"height"`
}

// AddressStats synthesises Esplora address stats from get_balance + get_history.
// Electrum has no funded/spent breakdown, so the funded sums carry the balance
// (spent 0) — the wallet backend only reads net balance, tx counts, and whether
// the address has any history, all of which this preserves.
func (c *ElectrumClient) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	sh, err := c.scriptHash(address)
	if err != nil {
		return EsploraAddressStats{}, err
	}
	var bal struct {
		Confirmed   int64 `json:"confirmed"`
		Unconfirmed int64 `json:"unconfirmed"`
	}
	if err := c.call(ctx, &bal, "blockchain.scripthash.get_balance", sh); err != nil {
		return EsploraAddressStats{}, err
	}
	var hist []electrumHistoryItem
	if err := c.call(ctx, &hist, "blockchain.scripthash.get_history", sh); err != nil {
		return EsploraAddressStats{}, err
	}
	confirmed, mempool := 0, 0
	for _, h := range hist {
		if h.Height > 0 {
			confirmed++
			c.rememberHeight(h.TxHash, h.Height)
		} else {
			mempool++
		}
	}
	stats := EsploraAddressStats{Address: address}
	stats.ChainStats.TxCount = confirmed
	stats.ChainStats.FundedTxoCount = confirmed
	stats.ChainStats.FundedTxoSum = bal.Confirmed
	stats.MempoolStats.TxCount = mempool
	stats.MempoolStats.FundedTxoCount = mempool
	stats.MempoolStats.FundedTxoSum = bal.Unconfirmed
	return stats, nil
}

func (c *ElectrumClient) AddressUTXOs(ctx context.Context, address string) ([]EsploraUTXO, error) {
	sh, err := c.scriptHash(address)
	if err != nil {
		return nil, err
	}
	var unspent []struct {
		TxHash string `json:"tx_hash"`
		TxPos  int    `json:"tx_pos"`
		Height int    `json:"height"`
		Value  int64  `json:"value"`
	}
	if err := c.call(ctx, &unspent, "blockchain.scripthash.listunspent", sh); err != nil {
		return nil, err
	}
	out := make([]EsploraUTXO, 0, len(unspent))
	for _, u := range unspent {
		c.rememberHeight(u.TxHash, u.Height)
		st := EsploraStatus{Confirmed: u.Height > 0, BlockHeight: u.Height}
		if u.Height > 0 {
			st.BlockTime = c.blockTime(ctx, u.Height)
		}
		out = append(out, EsploraUTXO{TxID: u.TxHash, Vout: u.TxPos, Value: u.Value, Status: st})
	}
	return out, nil
}

func (c *ElectrumClient) AddressTxs(ctx context.Context, address string) ([]EsploraTx, error) {
	sh, err := c.scriptHash(address)
	if err != nil {
		return nil, err
	}
	var hist []electrumHistoryItem
	if err := c.call(ctx, &hist, "blockchain.scripthash.get_history", sh); err != nil {
		return nil, err
	}
	out := make([]EsploraTx, 0, len(hist))
	for _, h := range hist {
		c.rememberHeight(h.TxHash, h.Height)
		tx, err := c.buildTx(ctx, h.TxHash)
		if err != nil {
			return nil, err
		}
		out = append(out, tx)
	}
	return out, nil
}

func (c *ElectrumClient) Tx(ctx context.Context, txid string) (EsploraTx, error) {
	return c.buildTx(ctx, txid)
}

func (c *ElectrumClient) TxHex(ctx context.Context, txid string) (string, error) {
	var raw string
	err := c.call(ctx, &raw, "blockchain.transaction.get", txid, false)
	return strings.TrimSpace(raw), err
}

func (c *ElectrumClient) Broadcast(ctx context.Context, rawHex string) (string, error) {
	var txid string
	err := c.call(ctx, &txid, "blockchain.transaction.broadcast", rawHex)
	return strings.TrimSpace(txid), err
}

func (c *ElectrumClient) TipHeight(ctx context.Context) (int, error) {
	c.tipMu.Lock()
	if !c.tipFetched.IsZero() && time.Since(c.tipFetched) < electrumClientTipTTL {
		v := c.tipVal
		c.tipMu.Unlock()
		return v, nil
	}
	c.tipMu.Unlock()

	var head struct {
		Height int `json:"height"`
	}
	if err := c.call(ctx, &head, "blockchain.headers.subscribe"); err != nil {
		return 0, err
	}
	c.tipMu.Lock()
	c.tipVal = head.Height
	c.tipFetched = time.Now()
	c.tipMu.Unlock()
	return head.Height, nil
}

// FeeRateForTarget maps Electrum's estimatefee (BTC/kB) to sat/vB, falling back
// when the server has no estimate (it returns a negative number).
func (c *ElectrumClient) FeeRateForTarget(ctx context.Context, target int, fallback float64) float64 {
	var btcPerKB float64
	if err := c.call(ctx, &btcPerKB, "blockchain.estimatefee", target); err != nil || btcPerKB <= 0 {
		return fallback
	}
	return btcPerKB * 1e8 / 1000.0
}

// buildTx fetches a raw transaction, decodes it, resolves each input's prevout,
// and maps it into the Esplora tx shape the wallet backend consumes.
func (c *ElectrumClient) buildTx(ctx context.Context, txid string) (EsploraTx, error) {
	msg, err := c.fetchTx(ctx, txid)
	if err != nil {
		return EsploraTx{}, err
	}
	et := EsploraTx{
		TxID:     txid,
		Version:  msg.Version,
		Locktime: int32(msg.LockTime),
		Size:     int32(msg.SerializeSize()),
		Weight:   int32(msg.SerializeSizeStripped()*3 + msg.SerializeSize()),
	}

	var totalIn, totalOut int64
	inputsResolved := true
	for _, ti := range msg.TxIn {
		vin := EsploraVin{
			TxID:      ti.PreviousOutPoint.Hash.String(),
			Vout:      int(ti.PreviousOutPoint.Index),
			ScriptSig: hex.EncodeToString(ti.SignatureScript),
			Sequence:  int64(ti.Sequence),
		}
		for _, w := range ti.Witness {
			vin.Witness = append(vin.Witness, hex.EncodeToString(w))
		}
		if isCoinbaseInput(ti.PreviousOutPoint) {
			vin.IsCoinbase = true
			inputsResolved = false
		} else {
			prev, err := c.fetchTx(ctx, vin.TxID)
			if err != nil {
				return EsploraTx{}, err
			}
			if vin.Vout < len(prev.TxOut) {
				po := prev.TxOut[vin.Vout]
				vin.Prevout = &EsploraVout{
					Value:               po.Value,
					ScriptPubKey:        hex.EncodeToString(po.PkScript),
					ScriptPubKeyAddress: scriptAddress(po.PkScript, c.network),
				}
				totalIn += po.Value
			} else {
				inputsResolved = false
			}
		}
		et.Vin = append(et.Vin, vin)
	}
	for _, to := range msg.TxOut {
		et.Vout = append(et.Vout, EsploraVout{
			Value:               to.Value,
			ScriptPubKey:        hex.EncodeToString(to.PkScript),
			ScriptPubKeyAddress: scriptAddress(to.PkScript, c.network),
		})
		totalOut += to.Value
	}
	if inputsResolved && totalIn >= totalOut {
		et.Fee = totalIn - totalOut
	}

	if h := c.knownHeight(txid); h > 0 {
		et.Status = EsploraStatus{Confirmed: true, BlockHeight: h, BlockTime: c.blockTime(ctx, h)}
	}
	return et, nil
}

// fetchTx returns a decoded transaction, cached so prevout resolution and repeat
// reads don't refetch.
func (c *ElectrumClient) fetchTx(ctx context.Context, txid string) (*wire.MsgTx, error) {
	c.cacheMu.Lock()
	cached := c.txCache[txid]
	c.cacheMu.Unlock()
	if cached != nil {
		return cached, nil
	}

	var rawHex string
	if err := c.call(ctx, &rawHex, "blockchain.transaction.get", txid, false); err != nil {
		return nil, err
	}
	raw, err := hex.DecodeString(strings.TrimSpace(rawHex))
	if err != nil {
		return nil, fmt.Errorf("decode tx hex %s: %w", txid, err)
	}
	msg := wire.NewMsgTx(wire.TxVersion)
	if err := msg.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("deserialize tx %s: %w", txid, err)
	}
	c.cacheMu.Lock()
	c.txCache[txid] = msg
	c.cacheMu.Unlock()
	return msg, nil
}

// blockTime returns a block's timestamp, parsed from its 80-byte header (the
// time field is the little-endian uint32 at offset 68). Cached per height.
func (c *ElectrumClient) blockTime(ctx context.Context, height int) int64 {
	c.cacheMu.Lock()
	t, ok := c.headerTime[height]
	c.cacheMu.Unlock()
	if ok {
		return t
	}
	var hdr string
	if err := c.call(ctx, &hdr, "blockchain.block.header", height); err != nil {
		return 0
	}
	raw, err := hex.DecodeString(strings.TrimSpace(hdr))
	if err != nil || len(raw) < 72 {
		return 0
	}
	ts := int64(binary.LittleEndian.Uint32(raw[68:72]))
	c.cacheMu.Lock()
	c.headerTime[height] = ts
	c.cacheMu.Unlock()
	return ts
}

func (c *ElectrumClient) rememberHeight(txid string, height int) {
	if height <= 0 {
		return
	}
	c.cacheMu.Lock()
	c.heightByTx[txid] = height
	c.cacheMu.Unlock()
}

func (c *ElectrumClient) knownHeight(txid string) int {
	c.cacheMu.Lock()
	defer c.cacheMu.Unlock()
	return c.heightByTx[txid]
}

// SwappableChainSource: runtime endpoint + proxy switching.

func (c *ElectrumClient) BaseURLs() []string {
	c.urlMu.RLock()
	defer c.urlMu.RUnlock()
	return []string{c.serverURL}
}

func (c *ElectrumClient) SetBaseURLs(urls []string) {
	if len(urls) == 0 {
		return
	}
	c.urlMu.Lock()
	c.serverURL = urls[0]
	c.urlMu.Unlock()
	c.resetConn()
}

func (c *ElectrumClient) ProxyConfig() (bool, string) {
	c.urlMu.RLock()
	defer c.urlMu.RUnlock()
	return c.proxyOn, c.proxyAddr
}

func (c *ElectrumClient) SetProxy(enabled bool, proxyAddr string) error {
	c.urlMu.Lock()
	c.proxyOn = enabled
	c.proxyAddr = proxyAddr
	c.urlMu.Unlock()
	c.resetConn()
	return nil
}

// resetConn drops the live connection so the next call reconnects (to a changed
// endpoint or through a changed proxy).
func (c *ElectrumClient) resetConn() {
	c.mu.Lock()
	c.dropConnLocked()
	c.mu.Unlock()
}

func isCoinbaseInput(op wire.OutPoint) bool {
	return op.Index == 0xffffffff && op.Hash == chainhash.Hash{}
}
