package orchestrator

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync/atomic"
	"time"

	"github.com/rs/zerolog/log"
)

// bitcoindRPCMaxInflight caps how many in-flight RPCs the orchestrator
// may have against bitcoind at once. Mirrors the rpcthreads=10 cap on
// the bitcoind side: Core serialises most work behind cs_main, so
// flooding it with parallel requests during IBD only piles up
// contention and makes individual callers miss their deadlines.
const bitcoindRPCMaxInflight = 10

var (
	bitcoindRPCGate     = make(chan struct{}, bitcoindRPCMaxInflight)
	bitcoindRPCInflight atomic.Int32
)

// CallBitcoindRPC issues a single JSON-RPC call to bitcoind. Every
// orchestrator → bitcoind RPC goes through here so the concurrency cap
// is enforced at the one chokepoint — callers can't bypass it by
// reaching for http.DefaultClient. On overflow the goroutine waits for
// a free slot and a warning is logged with the method that hit it.
func CallBitcoindRPC(ctx context.Context, url, user, password, method string, params []interface{}) (json.RawMessage, error) {
	release, err := acquireBitcoindRPCSlot(ctx, method)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", method, err)
	}
	defer release()

	if params == nil {
		params = []interface{}{}
	}
	reqBody, err := json.Marshal(map[string]interface{}{
		"jsonrpc": "1.0",
		"id":      "orchestrator",
		"method":  method,
		"params":  params,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal %s: %w", method, err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(reqBody))
	if err != nil {
		return nil, fmt.Errorf("build %s request: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")
	if user != "" {
		req.SetBasicAuth(user, password)
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

	var rpcResp struct {
		Result json.RawMessage `json:"result"`
		Error  *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if jerr := json.Unmarshal(respBody, &rpcResp); jerr != nil {
		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("%s: HTTP %d", method, resp.StatusCode)
		}
		return nil, fmt.Errorf("decode %s: %w", method, jerr)
	}
	if rpcResp.Error != nil {
		return nil, fmt.Errorf("%s RPC error %d: %s", method, rpcResp.Error.Code, rpcResp.Error.Message)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%s: HTTP %d", method, resp.StatusCode)
	}
	return rpcResp.Result, nil
}

func acquireBitcoindRPCSlot(ctx context.Context, method string) (release func(), err error) {
	select {
	case bitcoindRPCGate <- struct{}{}:
		bitcoindRPCInflight.Add(1)
		return releaseBitcoindRPCSlot, nil
	default:
	}

	log.Warn().
		Str("method", method).
		Int32("inflight", bitcoindRPCInflight.Load()).
		Int("cap", bitcoindRPCMaxInflight).
		Msg("bitcoind RPC concurrency cap reached, queuing caller")
	waitStart := time.Now()

	select {
	case bitcoindRPCGate <- struct{}{}:
		bitcoindRPCInflight.Add(1)
		log.Debug().
			Str("method", method).
			Dur("waited", time.Since(waitStart)).
			Msg("bitcoind RPC slot acquired after queueing")
		return releaseBitcoindRPCSlot, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func releaseBitcoindRPCSlot() {
	bitcoindRPCInflight.Add(-1)
	<-bitcoindRPCGate
}
