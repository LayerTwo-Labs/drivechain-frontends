package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"time"
)

// PresyncMessagePrefix is the prefix used in the synthesized startup error
// when bitcoind is in the BIP324 headers-presync phase. The connection
// monitor's startup-pattern list includes this prefix so the message is
// classified as startupError rather than connectionError and the UI shows
// "Pre-synchronizing blockheaders" instead of a frozen 0/0 connected state.
const PresyncMessagePrefix = "Pre-synchronizing blockheaders"

// BitcoindHealthCheck calls getblockchaininfo through the shared
// orchestrator → bitcoind RPC gate. When bitcoind reports blocks=0 and
// headers=0 it's still in BIP324 headers-presync — a vanilla success
// signal would freeze the UI at 0/0, so the checker synthesises a
// presync startup error instead. One RPC only.
type BitcoindHealthCheck struct {
	URL      string
	User     string
	Password string
	Timeout  time.Duration
}

func (h *BitcoindHealthCheck) Check(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, h.Timeout)
	defer cancel()

	raw, err := CallBitcoindRPC(ctx, h.URL, h.User, h.Password, "getblockchaininfo", nil)
	if err != nil {
		return err
	}

	var info struct {
		Blocks  int64 `json:"blocks"`
		Headers int64 `json:"headers"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return fmt.Errorf("decode getblockchaininfo: %w", err)
	}
	if info.Blocks == 0 && info.Headers == 0 {
		return fmt.Errorf("%s", PresyncMessagePrefix)
	}
	return nil
}
