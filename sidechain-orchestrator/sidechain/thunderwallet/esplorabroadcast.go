package thunderwallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// IndexBroadcast hands a signed transaction to an Esplora index, which relays
// it to the node it reads. A light wallet runs no node of its own, so this is
// how its transactions reach the network.
type IndexBroadcast struct {
	baseURL string
	http    *http.Client
}

// NewIndexBroadcast submits through one index.
func NewIndexBroadcast(baseURL string) *IndexBroadcast {
	return &IndexBroadcast{
		baseURL: strings.TrimRight(baseURL, "/"),
		http:    &http.Client{Timeout: 30 * time.Second},
	}
}

// Broadcast posts the transaction and returns the txid the node answered with.
func (b *IndexBroadcast) Broadcast(ctx context.Context, tx AuthorizedTransaction) (Hash, error) {
	wire, err := encodeAuthorized(tx)
	if err != nil {
		return Hash{}, err
	}
	body, err := json.Marshal(wire)
	if err != nil {
		return Hash{}, fmt.Errorf("write the transaction: %w", err)
	}

	req, err := http.NewRequestWithContext(
		ctx, http.MethodPost, b.baseURL+"/tx", bytes.NewReader(body))
	if err != nil {
		return Hash{}, fmt.Errorf("build the broadcast request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := b.http.Do(req)
	if err != nil {
		return Hash{}, fmt.Errorf("broadcast through %s: %w", b.baseURL, err)
	}
	defer resp.Body.Close() //nolint:errcheck

	answer, err := io.ReadAll(resp.Body)
	if err != nil {
		return Hash{}, fmt.Errorf("read the broadcast answer: %w", err)
	}
	text := strings.TrimSpace(string(answer))
	if resp.StatusCode != http.StatusOK {
		return Hash{}, fmt.Errorf("the index answered %d: %s", resp.StatusCode, text)
	}

	var out Hash
	raw, err := hex.DecodeString(text)
	if err != nil || len(raw) != len(out) {
		return Hash{}, fmt.Errorf("the index answered with txid %q", text)
	}
	copy(out[:], raw)
	return out, nil
}

var _ Broadcaster = (*IndexBroadcast)(nil)
