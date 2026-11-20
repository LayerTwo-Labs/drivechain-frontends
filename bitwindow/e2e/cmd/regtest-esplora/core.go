package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

type coreRPC struct {
	url    string
	user   string
	pass   string
	client *http.Client
}

// rpcError is an error that Bitcoin Core answered.
type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *rpcError) Error() string { return fmt.Sprintf("core error %d: %s", e.Code, e.Message) }

// call runs a Core RPC. A non-empty wallet sends it to that wallet.
func (c *coreRPC) call(ctx context.Context, wallet, method string, params []any, out any) error {
	body, err := json.Marshal(map[string]any{"jsonrpc": "1.0", "id": "esplora", "method": method, "params": params})
	if err != nil {
		return err
	}
	url := c.url
	if wallet != "" {
		url = strings.TrimRight(url, "/") + "/wallet/" + wallet
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.SetBasicAuth(c.user, c.pass)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("%s: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("%s: read reply: %w", method, err)
	}
	var reply struct {
		Result json.RawMessage `json:"result"`
		Error  *rpcError       `json:"error"`
	}
	if err := json.Unmarshal(raw, &reply); err != nil {
		return fmt.Errorf("%s: HTTP %d: %s", method, resp.StatusCode, strings.TrimSpace(string(raw)))
	}
	if reply.Error != nil {
		return reply.Error
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(reply.Result, out); err != nil {
		return fmt.Errorf("%s: decode result: %w", method, err)
	}
	return nil
}

type coreScriptPubKey struct {
	Asm     string `json:"asm"`
	Hex     string `json:"hex"`
	Type    string `json:"type"`
	Address string `json:"address"`
}

type coreVout struct {
	Value        json.Number      `json:"value"`
	N            int              `json:"n"`
	ScriptPubKey coreScriptPubKey `json:"scriptPubKey"`
}

type coreVin struct {
	Coinbase  string `json:"coinbase"`
	TxID      string `json:"txid"`
	Vout      int    `json:"vout"`
	ScriptSig struct {
		Hex string `json:"hex"`
	} `json:"scriptSig"`
	Witness  []string `json:"txinwitness"`
	Sequence int64    `json:"sequence"`
	Prevout  *struct {
		Value        json.Number      `json:"value"`
		ScriptPubKey coreScriptPubKey `json:"scriptPubKey"`
	} `json:"prevout"`
}

// coreTx is a transaction at getblock verbosity 3, or getrawtransaction
// verbosity 2. Both carry the prevouts.
type coreTx struct {
	TxID     string      `json:"txid"`
	Hex      string      `json:"hex"`
	Version  int32       `json:"version"`
	Locktime int64       `json:"locktime"`
	Size     int32       `json:"size"`
	Weight   int32       `json:"weight"`
	Fee      json.Number `json:"fee"`
	Vin      []coreVin   `json:"vin"`
	Vout     []coreVout  `json:"vout"`
}

type coreBlock struct {
	Hash              string   `json:"hash"`
	Height            int      `json:"height"`
	Version           int32    `json:"version"`
	Time              int64    `json:"time"`
	MedianTime        int64    `json:"mediantime"`
	Nonce             uint32   `json:"nonce"`
	Bits              string   `json:"bits"`
	Difficulty        float64  `json:"difficulty"`
	MerkleRoot        string   `json:"merkleroot"`
	PreviousBlockHash string   `json:"previousblockhash"`
	Size              int      `json:"size"`
	Weight            int      `json:"weight"`
	Tx                []coreTx `json:"tx"`
}

// sats reads a BTC amount from Core as satoshis, with no float rounding.
func sats(n json.Number) (int64, error) {
	s := n.String()
	if s == "" {
		return 0, nil
	}
	negative := strings.HasPrefix(s, "-")
	s = strings.TrimPrefix(s, "-")
	whole, frac, _ := strings.Cut(s, ".")
	if len(frac) > 8 {
		return 0, fmt.Errorf("amount %s has more than 8 decimals", n)
	}
	frac += strings.Repeat("0", 8-len(frac))
	var v int64
	for _, ch := range whole + frac {
		if ch < '0' || ch > '9' {
			return 0, fmt.Errorf("amount %s is not a number", n)
		}
		v = v*10 + int64(ch-'0')
	}
	if negative {
		v = -v
	}
	return v, nil
}
