// Package feerate reads what the next block pays, from a mempool.space style
// explorer.
package feerate

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

// timeout bounds one read. A bid waits on this answer, so it stays short.
const timeout = 5 * time.Second

// Explorer reads the recommended rates of one mempool.space style server.
type Explorer struct {
	baseURL string
	http    *http.Client
}

// NewExplorer points a reader at a server, such as
// https://explorer.alpha.ecash.ninja.
func NewExplorer(baseURL string) *Explorer {
	return &Explorer{
		baseURL: strings.TrimRight(baseURL, "/"),
		http:    &http.Client{Timeout: timeout},
	}
}

// URL is the server this reader asks.
func (e *Explorer) URL() string { return e.baseURL }

// recommended is what /api/v1/fees/recommended answers, in sats per vByte.
type recommended struct {
	FastestFee  float64 `json:"fastestFee"`
	HalfHourFee float64 `json:"halfHourFee"`
	HourFee     float64 `json:"hourFee"`
	MinimumFee  float64 `json:"minimumFee"`
}

// NextBlockFeeRate is what a transaction pays per vByte to enter the next
// block.
func (e *Explorer) NextBlockFeeRate(ctx context.Context) (float64, error) {
	url := e.baseURL + "/api/v1/fees/recommended"
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return 0, fmt.Errorf("build the request for %s: %w", url, err)
	}
	resp, err := e.http.Do(req)
	if err != nil {
		return 0, fmt.Errorf("read %s: %w", url, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	if resp.StatusCode != http.StatusOK {
		return 0, fmt.Errorf("%s answered %d", url, resp.StatusCode)
	}
	var rates recommended
	if err := json.NewDecoder(resp.Body).Decode(&rates); err != nil {
		return 0, fmt.Errorf("decode %s: %w", url, err)
	}
	if rates.FastestFee <= 0 {
		return 0, fmt.Errorf("%s reports no rate for the next block", url)
	}
	return rates.FastestFee, nil
}
