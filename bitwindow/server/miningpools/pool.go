// Package miningpools attributes blocks to mining pools the way mempool does:
// by the coinbase's output addresses first, then by tags in its script.
package miningpools

import (
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"slices"
	"strings"
)

// Pool is one registry entry. The payout fields are empty for mempool's list.
type Pool struct {
	Name       string
	Slug       string
	Link       string
	Operator   string
	Mode       string
	FeeBps     int
	StratumURL string
	Payout     string
	Addresses  []string
	Tags       []string

	matchers []func(string) bool
}

// Unknown is the pool a coinbase no registry entry explains.
var Unknown = Pool{Name: "Unknown", Slug: "unknown"}

// Parse reads a registry document.
type Parse func(raw []byte) ([]Pool, error)

// Slug is the name lowercased with everything but letters and digits dropped.
func Slug(name string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(name) {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// ParseMempool reads mempool's pools-v2.json, a bare array of pools.
func ParseMempool(raw []byte) ([]Pool, error) {
	var entries []struct {
		Name      string   `json:"name"`
		Link      string   `json:"link"`
		Addresses []string `json:"addresses"`
		Tags      []string `json:"tags"`
	}
	if err := json.Unmarshal(raw, &entries); err != nil {
		return nil, fmt.Errorf("parse pools: %w", err)
	}
	if len(entries) == 0 {
		return nil, errors.New("parse pools: empty list")
	}
	pools := make([]Pool, len(entries))
	for i, e := range entries {
		pools[i] = Pool{Name: e.Name, Link: e.Link, Addresses: e.Addresses, Tags: e.Tags}
	}
	return finish(pools), nil
}

// ParseRegistry reads a pool.drivechain.info networks/<id>/pools.json document.
func ParseRegistry(raw []byte) ([]Pool, error) {
	var doc struct {
		Network string `json:"network"`
		Pools   []struct {
			Name              string   `json:"name"`
			Operator          string   `json:"operator"`
			Mode              string   `json:"mode"`
			FeeBps            int      `json:"fee_bps"`
			CoinbaseTag       string   `json:"coinbase_tag"`
			StratumURL        *string  `json:"stratum_url"`
			DashboardURL      *string  `json:"dashboard_url"`
			OperatorAddress   string   `json:"operator_address"`
			PoolBTCAddress    *string  `json:"pool_btc_address"`
			CoinbaseAddresses []string `json:"coinbase_addresses"`
			Payout            string   `json:"payout"`
		} `json:"pools"`
	}
	if err := json.Unmarshal(raw, &doc); err != nil {
		return nil, fmt.Errorf("parse registry: %w", err)
	}
	if doc.Network == "" {
		return nil, errors.New("parse registry: not a registry document")
	}
	pools := make([]Pool, len(doc.Pools))
	for i, e := range doc.Pools {
		pool := Pool{
			Name:       e.Name,
			Link:       deref(e.DashboardURL),
			Operator:   e.Operator,
			Mode:       e.Mode,
			FeeBps:     e.FeeBps,
			StratumURL: deref(e.StratumURL),
			Payout:     e.Payout,
		}
		if e.CoinbaseTag != "" {
			pool.Tags = []string{e.CoinbaseTag}
		}
		// The registry's own rule: what actually lands in the coinbase.
		switch {
		case e.CoinbaseAddresses != nil:
			pool.Addresses = e.CoinbaseAddresses
		case deref(e.PoolBTCAddress) != "":
			pool.Addresses = []string{*e.PoolBTCAddress}
		case e.FeeBps > 0 && e.OperatorAddress != "":
			pool.Addresses = []string{e.OperatorAddress}
		}
		pools[i] = pool
	}
	return finish(pools), nil
}

func deref(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

func finish(pools []Pool) []Pool {
	for i := range pools {
		pools[i].Slug = Slug(pools[i].Name)
		pools[i].matchers = tagMatchers(pools[i].Tags)
	}
	return pools
}

// A tag is a case-insensitive regex; one Go cannot compile is a plain substring.
func tagMatchers(tags []string) []func(string) bool {
	out := make([]func(string) bool, 0, len(tags))
	for _, tag := range tags {
		if re, err := regexp.Compile("(?i)" + tag); err == nil {
			out = append(out, re.MatchString)
			continue
		}
		lower := strings.ToLower(tag)
		out = append(out, func(text string) bool {
			return strings.Contains(strings.ToLower(text), lower)
		})
	}
	return out
}

// ScriptText decodes a script byte per character, as mempool's hex2ascii does.
func ScriptText(script []byte) string {
	runes := make([]rune, len(script))
	for i, b := range script {
		runes[i] = rune(b)
	}
	return string(runes)
}

// Match returns the first pool, in registry order, whose addresses or tags
// explain the coinbase, or Unknown.
func Match(script []byte, addresses []string, pools []Pool) Pool {
	text := ScriptText(script)
	for _, pool := range pools {
		if len(addresses) > 0 && slices.ContainsFunc(pool.Addresses, func(a string) bool {
			return slices.Contains(addresses, a)
		}) {
			return pool
		}
		for _, matches := range pool.matchers {
			if matches(text) {
				return pool
			}
		}
	}
	return Unknown
}
