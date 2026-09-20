package stratum

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

// PoolBlock is one block a pool reports.
type PoolBlock struct {
	Height        uint32
	Hash          string
	RewardSats    int64
	FeeSats       int64
	Finder        string
	Status        string
	Confirmations int32
	FoundAt       time.Time
}

// poolBlocksReply is the blocks document a pool serves.
type poolBlocksReply struct {
	Rows []struct {
		Timestamp     int64  `json:"ts"`
		Height        uint32 `json:"height"`
		Hash          string `json:"hash"`
		RewardSats    int64  `json:"reward_sats"`
		FeeSats       int64  `json:"fee_sats"`
		Finder        string `json:"finder"`
		Status        string `json:"status"`
		Confirmations int32  `json:"confirmations"`
	} `json:"rows"`
}

// ParsePoolBlocks reads the blocks a pool published.
func ParsePoolBlocks(body []byte) ([]PoolBlock, error) {
	var reply poolBlocksReply
	if err := json.Unmarshal(body, &reply); err != nil {
		return nil, fmt.Errorf("decode the pool blocks: %w", err)
	}
	blocks := make([]PoolBlock, 0, len(reply.Rows))
	for _, b := range reply.Rows {
		block := PoolBlock{
			Height:        b.Height,
			Hash:          b.Hash,
			RewardSats:    b.RewardSats,
			FeeSats:       b.FeeSats,
			Finder:        b.Finder,
			Status:        b.Status,
			Confirmations: b.Confirmations,
		}
		if b.Timestamp > 0 {
			block.FoundAt = time.Unix(b.Timestamp, 0)
		}
		blocks = append(blocks, block)
	}
	return blocks, nil
}

// PoolBlocksURL builds the blocks endpoint of a pool. It sits beside the
// overview endpoint the stats URL names.
func PoolBlocksURL(statsURL string, limit int) (string, error) {
	parsed, err := url.Parse(statsURL)
	if err != nil {
		return "", fmt.Errorf("pool stats URL %q: %w", statsURL, err)
	}
	if parsed.Scheme == "" || parsed.Host == "" {
		return "", fmt.Errorf("pool stats URL %q has no host", statsURL)
	}
	base := strings.TrimSuffix(parsed.Path, "/")
	if i := strings.LastIndex(base, "/"); i >= 0 {
		base = base[:i]
	}
	parsed.Path = base + "/blocks"
	parsed.RawQuery = "limit=" + strconv.Itoa(limit)
	return parsed.String(), nil
}

// FetchPoolBlocks reads the blocks a pool published at blocksURL.
func FetchPoolBlocks(ctx context.Context, client *http.Client, blocksURL string) ([]PoolBlock, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, blocksURL, nil)
	if err != nil {
		return nil, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("the pool answered %s", resp.Status)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, fmt.Errorf("read the pool blocks: %w", err)
	}
	return ParsePoolBlocks(body)
}
