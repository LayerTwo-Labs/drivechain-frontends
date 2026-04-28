package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
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

	// OnSync is invoked after each successful getblockchaininfo call with the
	// full blockchain state. The orchestrator wires this to the bitcoind
	// monitor's SetBlockchainSync so the WatchBinaries stream carries the tip
	// without a second RPC client. Optional — nil is fine.
	OnSync func(*BlockchainSync)
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

	// Headers count below 10 means we're still pre-syncing. Frontend reads
	// this off BlockchainSync.in_header_sync to gate "waiting for headers" UI.
	inHeaderSync := info.Headers < 10

	if h.OnSync != nil {
		h.OnSync(&BlockchainSync{
			Blocks:               int(info.Blocks),
			Headers:              int(info.Headers),
			VerificationProgress: info.VerificationProgress,
			InitialBlockDownload: info.InitialBlockDownload,
			InHeaderSync:         inHeaderSync,
			Time:                 info.Time,
			BestBlockHash:        info.BestBlockHash,
		})
	}

	// Even when getblockchaininfo answers cleanly, bitcoind can still be in a
	// phase where wallet RPCs (and the ZMQ socket) are not usable yet — most
	// commonly during the post-IBD wallet rescan. Probe a cheap wallet RPC
	// and surface its -28 message as the startup state so downstream engines
	// (cheque, ZMQ, enforcer boot) wait instead of crashing on first call.
	if walletErr := h.probeWalletReady(ctx); walletErr != nil {
		return walletErr
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

// probeWalletReady returns a startup-style error iff bitcoind is still in a
// phase that breaks wallet RPCs (e.g. mid-rescan, mid-verify). It returns nil
// in every other case — including transport failures — so a transient probe
// blip doesn't take the binary out of "connected" state.
func (h *BitcoindHealthCheck) probeWalletReady(ctx context.Context) error {
	raw, err := h.rpcCall(ctx, "listwallets", nil)
	if err == nil && raw != nil {
		return nil
	}
	if err == nil {
		return nil
	}
	msg := err.Error()
	for _, p := range []string{
		"-28",
		"Verifying blocks",
		"Loading block index",
		"Loading wallet",
		"Wallet loading",
		"Wallet already loading",
		"Rescanning",
		"Still rescanning",
	} {
		if strings.Contains(msg, p) {
			return fmt.Errorf("%s", strings.TrimSpace(msg))
		}
	}
	return nil
}

type bitcoindBlockchainInfo struct {
	Blocks               int64   `json:"blocks"`
	Headers              int64   `json:"headers"`
	VerificationProgress float64 `json:"verificationprogress"`
	InitialBlockDownload bool    `json:"initialblockdownload"`
	Time                 int64   `json:"time"`
	BestBlockHash        string  `json:"bestblockhash"`
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
