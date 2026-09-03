// Package feerate answers what a transaction pays to enter the next block.
package feerate

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

// timeout bounds one read. A bid waits on this answer, so it stays short.
const timeout = 5 * time.Second

// FeeEstimator answers what a transaction pays per vByte to enter the next
// block.
type FeeEstimator interface {
	EstimateFee(ctx context.Context) (satsPerVByte float64, err error)
}

// Func adapts a plain function to a FeeEstimator.
type Func func(ctx context.Context) (float64, error)

// EstimateFee calls the function.
func (f Func) EstimateFee(ctx context.Context) (float64, error) { return f(ctx) }

// Fallback asks each source in order and takes the first rate it gets. A
// caller lists the sources it trusts most first.
type Fallback struct {
	sources []FeeEstimator
}

// NewFallback reads the sources in the order given.
func NewFallback(sources ...FeeEstimator) *Fallback {
	return &Fallback{sources: sources}
}

// EstimateFee answers with the first rate a source reports. It names every
// failure when no source answers, so a caller sees why.
func (f *Fallback) EstimateFee(ctx context.Context) (float64, error) {
	if len(f.sources) == 0 {
		return 0, errors.New("no fee source")
	}
	var failures []error
	for _, source := range f.sources {
		rate, err := source.EstimateFee(ctx)
		if err == nil {
			return rate, nil
		}
		failures = append(failures, err)
	}
	return 0, errors.Join(failures...)
}

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

// EstimateFee is what a transaction pays per vByte to enter the next block.
// The explorer reads the blocks a miner made, so it answers the market rather
// than the mempool a node happens to hold.
func (e *Explorer) EstimateFee(ctx context.Context) (float64, error) {
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

var (
	_ FeeEstimator = (*Explorer)(nil)
	_ FeeEstimator = (*Fallback)(nil)
	_ FeeEstimator = Func(nil)
)
