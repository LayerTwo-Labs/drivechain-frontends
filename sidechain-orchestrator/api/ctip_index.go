package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// ctipReadTimeout bounds one read of the hosted index. A deposit waits on this,
// so it stays short.
const ctipReadTimeout = 8 * time.Second

// indexCtip is a sidechain's treasury outpoint, as the hosted index reports it.
type indexCtip struct {
	Txid  string
	Vout  uint32
	Value uint64
}

// readIndexCtip reads a slot's treasury outpoint from a hosted Esplora index.
// baseURL already carries the escrow path, so only the slot is appended.
//
// A light install runs no enforcer, and the index reads the escrow on its
// behalf. The treasury it reports is the outpoint an M5 deposit spends.
func readIndexCtip(ctx context.Context, baseURL string, slot uint32) (*indexCtip, error) {
	base := strings.TrimRight(baseURL, "/")
	url := fmt.Sprintf("%s/sidechain/%d", base, slot)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("build the treasury request: %w", err)
	}

	client := &http.Client{Timeout: ctipReadTimeout}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("read the treasury from %s: %w", base, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read the treasury answer: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("the index answered %d: %s", resp.StatusCode,
			strings.TrimSpace(string(body)))
	}

	var row struct {
		Treasury *struct {
			Txid      string `json:"txid"`
			Vout      uint32 `json:"vout"`
			ValueSats uint64 `json:"value_sats"`
		} `json:"treasury"`
	}
	if err := json.Unmarshal(body, &row); err != nil {
		return nil, fmt.Errorf("decode the treasury answer: %w", err)
	}

	// A slot that took no deposit yet holds no treasury, and the first deposit
	// creates one. That is not a fault.
	if row.Treasury == nil {
		return nil, nil
	}

	return &indexCtip{
		Txid:  row.Treasury.Txid,
		Vout:  row.Treasury.Vout,
		Value: row.Treasury.ValueSats,
	}, nil
}
