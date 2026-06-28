// Package bip329 encodes and decodes the BIP329 wallet-label interchange
// format: a JSONL file with one JSON object per line.
package bip329

import (
	"bufio"
	"encoding/json"
	"strings"
)

// Recognized BIP329 label types.
const (
	TypeTx     = "tx"
	TypeAddr   = "addr"
	TypeOutput = "output"
	TypeInput  = "input"
	TypePubkey = "pubkey"
	TypeXpub   = "xpub"
)

// Label is one BIP329 record.
type Label struct {
	Type      string `json:"type"`
	Ref       string `json:"ref"`
	Label     string `json:"label"`
	Origin    string `json:"origin,omitempty"`
	Spendable *bool  `json:"spendable,omitempty"`
}

// Encode serializes labels to BIP329 JSONL. Each label is one line.
func Encode(labels []Label) (string, error) {
	var b strings.Builder
	enc := json.NewEncoder(&b)
	enc.SetEscapeHTML(false)
	for _, l := range labels {
		if err := enc.Encode(l); err != nil {
			return "", err
		}
	}
	return b.String(), nil
}

// Decode parses BIP329 JSONL, returning the well-formed labels and a count of
// skipped lines (blank or malformed JSON). A single malformed line never
// aborts the whole parse.
func Decode(jsonl string) (labels []Label, skipped int) {
	scanner := bufio.NewScanner(strings.NewReader(jsonl))
	scanner.Buffer(make([]byte, 0, 64*1024), 4*1024*1024)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		var l Label
		if err := json.Unmarshal([]byte(line), &l); err != nil {
			skipped++
			continue
		}
		labels = append(labels, l)
	}
	return labels, skipped
}
