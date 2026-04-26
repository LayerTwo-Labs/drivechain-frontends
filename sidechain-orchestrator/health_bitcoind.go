package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// BitcoindHealthCheck wraps the regular RPC ping with detection for the
// "Pre-synchronizing blockheaders" phase. During that phase, Bitcoin Core
// (BIP324, 22.0+) responds normally to RPC calls, but `getblockchaininfo`
// returns blocks=0 and headers=0 — so the UI sees no progress and looks
// frozen even though the daemon is actively downloading headers.
//
// We surface presync as a synthetic startup error containing the highest
// `presynced_headers` value across `getpeerinfo`, which the connection
// monitor's bitcoind startup-pattern list catches and routes into
// BinaryStatus.StartupError. The Dart side already renders that field.
type BitcoindHealthCheck struct {
	URL      string
	User     string
	Password string
	Timeout  time.Duration
}

// PresyncMessagePrefix is the prefix used in synthetic startup errors when
// bitcoind is in the headers-presync phase. The connection monitor's
// startup-pattern list includes this prefix so the message is classified
// as startupError rather than connectionError.
const PresyncMessagePrefix = "Pre-synchronizing blockheaders"

func (h *BitcoindHealthCheck) Check(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, h.Timeout)
	defer cancel()

	info, err := h.callBlockchainInfo(ctx)
	if err != nil {
		return err
	}

	if info.Headers > 0 || info.Blocks > 0 {
		return nil
	}

	height, ok, err := h.maxPresyncedHeaders(ctx)
	if err != nil || !ok {
		return nil
	}
	return fmt.Errorf("%s, height: %d", PresyncMessagePrefix, height)
}

type bitcoindBlockchainInfo struct {
	Blocks  int64 `json:"blocks"`
	Headers int64 `json:"headers"`
}

func (h *BitcoindHealthCheck) callBlockchainInfo(ctx context.Context) (bitcoindBlockchainInfo, error) {
	var info bitcoindBlockchainInfo
	raw, err := h.rpcCall(ctx, "getblockchaininfo", nil)
	if err != nil {
		return info, err
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return info, fmt.Errorf("decode getblockchaininfo: %w", err)
	}
	return info, nil
}

// maxPresyncedHeaders returns the highest `presynced_headers` reported by any
// connected peer. ok=false means no peer is currently in the headers-presync
// phase (either bitcoind has no peers yet, or it's already past presync).
func (h *BitcoindHealthCheck) maxPresyncedHeaders(ctx context.Context) (int64, bool, error) {
	raw, err := h.rpcCall(ctx, "getpeerinfo", nil)
	if err != nil {
		return 0, false, err
	}
	var peers []struct {
		PresyncedHeaders int64 `json:"presynced_headers"`
	}
	if err := json.Unmarshal(raw, &peers); err != nil {
		return 0, false, fmt.Errorf("decode getpeerinfo: %w", err)
	}
	var maxHeight int64
	found := false
	for _, p := range peers {
		if p.PresyncedHeaders > maxHeight {
			maxHeight = p.PresyncedHeaders
			found = true
		}
	}
	return maxHeight, found, nil
}

func (h *BitcoindHealthCheck) rpcCall(ctx context.Context, method string, params []interface{}) (json.RawMessage, error) {
	if params == nil {
		params = []interface{}{}
	}
	body, err := json.Marshal(map[string]interface{}{
		"jsonrpc": "1.0",
		"id":      "health",
		"method":  method,
		"params":  params,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal %s: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, h.URL, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("build %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")
	if h.User != "" {
		req.SetBasicAuth(h.User, h.Password)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", method, err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read %s response: %w", method, err)
	}

	var rpcResp jsonRPCResponse
	if jerr := json.Unmarshal(respBody, &rpcResp); jerr != nil {
		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("%s: HTTP %d", method, resp.StatusCode)
		}
		return nil, fmt.Errorf("decode %s: %w", method, jerr)
	}
	if rpcResp.Error != nil {
		return nil, fmt.Errorf("%s: %s", method, rpcResp.Error.Message)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%s: HTTP %d", method, resp.StatusCode)
	}
	return rpcResp.Result, nil
}
